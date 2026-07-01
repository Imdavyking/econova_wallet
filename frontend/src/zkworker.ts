import { Noir, type CompiledCircuit } from "@noir-lang/noir_js";
import { UltraHonkBackend } from "@aztec/bb.js";
import initNoirC from "@noir-lang/noirc_abi";
import initACVM from "@noir-lang/acvm_js";
import acvmWasmUrl from "@noir-lang/acvm_js/web/acvm_js_bg.wasm?url";
import noircWasmUrl from "@noir-lang/noirc_abi/web/noirc_abi_wasm_bg.wasm?url";
import { poseidon2Hash } from "@zkpassport/poseidon2";
import { merkleTree } from "./helpers/merkle_tree";
import { flattenFieldsAsArray } from "./helpers/proof";
import circuit from "./assets/circuit.json";
import { addressToFieldHex } from "./lib/actions";

const log = (msg: string, ...args: any[]) =>
  console.log(`[ZkWorker] ${msg}`, ...args);
const err = (msg: string, ...args: any[]) =>
  console.error(`[ZkWorker] ${msg}`, ...args);

const b64ToBuffer = (b64: string): ArrayBuffer => {
  const raw = atob(b64);
  const buf = new Uint8Array(raw.length);
  for (let i = 0; i < raw.length; i++) buf[i] = raw.charCodeAt(i);
  return buf.buffer;
};

const waitForBridge = (message: string, timeoutMs = 15000) => {
  log(`waitForBridge: waiting to send "${message}"`);
  const start = Date.now();
  const poll = () => {
    const win = window as any;
    if (
      win.flutter_inappwebview &&
      typeof win.flutter_inappwebview.callHandler === "function"
    ) {
      log(`waitForBridge: bridge found after ${Date.now() - start}ms`);
      try {
        win.flutter_inappwebview.callHandler("ZkBridgeReady", message);
        log(`waitForBridge: ZkBridgeReady("${message}") sent ✅`);
      } catch (e) {
        err("waitForBridge: callHandler threw", e);
      }
    } else if (Date.now() - start > timeoutMs) {
      err(`waitForBridge: timed out after ${timeoutMs}ms`);
    } else {
      setTimeout(poll, 100);
    }
  };
  poll();
};

// ── Helpers ───────────────────────────────────────────────────────────────────

function randHex31(): string {
  return (
    "0x" +
    Array.from(crypto.getRandomValues(new Uint8Array(31)))
      .map((b) => b.toString(16).padStart(2, "0"))
      .join("")
  );
}

function bytesToHex(bytes: Uint8Array): string {
  return Array.from(bytes)
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

/**
 * Waits for Flutter to inject __acvmWasmB64 / __noircWasmB64 as base64
 * strings. If neither shows up within `timeoutMs`, falls back to fetching
 * the bundled WASM files directly (e.g. running standalone in a browser,
 * or the Flutter injection step failed/never ran).
 */
async function loadWasmBuffers(
  timeoutMs = 5000,
): Promise<{ acvmBuffer: ArrayBuffer; noircBuffer: ArrayBuffer }> {
  log(`loadWasmBuffers: waiting up to ${timeoutMs}ms for Flutter injection`);
  const waitStart = Date.now();

  const injected = await new Promise<boolean>((resolve) => {
    const poll = () => {
      const win = window as any;
      const hasAcvm = !!win.__acvmWasmB64;
      const hasNoir = !!win.__noircWasmB64;
      if (hasAcvm && hasNoir) {
        resolve(true);
      } else if (Date.now() - waitStart > timeoutMs) {
        resolve(false);
      } else {
        setTimeout(poll, 100);
      }
    };
    poll();
  });

  if (injected) {
    const win = window as any;
    log(
      `loadWasmBuffers: using Flutter-injected bytes after ${Date.now() - waitStart}ms — ` +
        `acvm=${win.__acvmWasmB64.length} chars, noirc=${win.__noircWasmB64.length} chars`,
    );
    const acvmBuffer = b64ToBuffer(win.__acvmWasmB64);
    const noircBuffer = b64ToBuffer(win.__noircWasmB64);
    win.__acvmWasmB64 = null;
    win.__noircWasmB64 = null;
    return { acvmBuffer, noircBuffer };
  }

  // ── Fallback: fetch bundled WASM directly ───────────────────────────────
  log(
    `loadWasmBuffers: no Flutter injection after ${timeoutMs}ms — ` +
      `falling back to bundled WASM via fetch`,
  );
  const [acvmRes, noircRes] = await Promise.all([
    fetch(acvmWasmUrl),
    fetch(noircWasmUrl),
  ]);
  if (!acvmRes.ok || !noircRes.ok) {
    throw new Error(
      `loadWasmBuffers: fallback fetch failed — acvm.status=${acvmRes.status} noirc.status=${noircRes.status}`,
    );
  }
  const [acvmBuffer, noircBuffer] = await Promise.all([
    acvmRes.arrayBuffer(),
    noircRes.arrayBuffer(),
  ]);
  log(
    `loadWasmBuffers: fallback fetch ok — acvm=${acvmBuffer.byteLength}b noirc=${noircBuffer.byteLength}b`,
  );
  return { acvmBuffer, noircBuffer };
}

// ── Main init ─────────────────────────────────────────────────────────────────

async function init() {
  if ((window as any).__zkInitialized) {
    log("init: already initialized, skipping");
    return;
  }
  (window as any).__zkInitialized = true;
  log("init: starting");

  try {
    // ── Step 1+2: get WASM bytes (Flutter injection, with fetch fallback) ──
    const { acvmBuffer, noircBuffer } = await loadWasmBuffers();

    // ── Step 3: init WASM ─────────────────────────────────────────────────
    log("init: calling initACVM + initNoirC");
    const wasmStart = Date.now();
    await Promise.all([initACVM(acvmBuffer), initNoirC(noircBuffer)]);
    log(`init: WASM ready in ${Date.now() - wasmStart}ms ✅`);

    // ── Step 4: expose functions ──────────────────────────────────────────
    const win = window as any;

    // 4a. Note generation (commitment = Poseidon2(nullifier, secret))
    win.__zkGenerateNote = (): {
      nullifier: string;
      secret: string;
      commitment: string;
    } => {
      log("__zkGenerateNote: generating");
      const nullifier = randHex31();
      const secret = randHex31();
      const commitment =
        "0x" + poseidon2Hash([BigInt(nullifier), BigInt(secret)]).toString(16);
      log(`__zkGenerateNote: commitment=${commitment.slice(0, 14)}…`);
      return { nullifier, secret, commitment };
    };

    // 4b. Proof generation (Merkle + Poseidon2 inputs + UltraHonk)
    win.__zkGenerateProof = async (input: {
      nullifier: string;
      secret: string;
      commitment: string;
      recipient: string; // raw G... Stellar address
      commitments: string[]; // all on-chain commitments
    }): Promise<{ proofBytesHex: string; publicInputsHex: string }> => {
      log(
        "__zkGenerateProof: building tree from",
        input.commitments.length,
        "commitments",
      );

      const tree = await merkleTree(input.commitments);
      const noteCommitment = BigInt(input.commitment).toString();
      const leafIndex = tree.getIndex(noteCommitment);
      if (leafIndex === -1)
        throw new Error("Commitment not found in deposit events");

      const merkleProof = tree.proof(leafIndex);
      log(`__zkGenerateProof: leafIndex=${leafIndex} root=${merkleProof.root}`);

      const nullifierHash =
        "0x" + poseidon2Hash([BigInt(input.nullifier)]).toString(16);

      const recipientField = addressToFieldHex(input.recipient);
      const recipientHash =
        "0x" + poseidon2Hash([BigInt(recipientField)]).toString(16);

      const noirInput = {
        root: merkleProof.root.toString(),
        nullifier_hash: nullifierHash,
        recipient: recipientField,
        recipient_hash: recipientHash,
        nullifier: input.nullifier,
        secret: input.secret,
        merkle_proof: merkleProof.pathElements.map((el: any) => el.toString()),
        is_even: merkleProof.pathIndices.map((el: any) => el % 2 === 0),
      };

      log("__zkGenerateProof: executing circuit");
      const execStart = Date.now();
      const noir = new Noir(circuit as CompiledCircuit);
      const { witness } = await noir.execute(noirInput);
      log(`__zkGenerateProof: witness in ${Date.now() - execStart}ms`);

      const honkStart = Date.now();
      let proof;
      try {
        const honk = new UltraHonkBackend(
          (circuit as { bytecode: any }).bytecode,
          { threads: 1 },
        );
        log(
          "__zkGenerateProof: UltraHonkBackend constructed, generating proof…",
        );
        proof = await honk.generateProof(witness, { keccak: true });
        honk.destroy();
        log(`__zkGenerateProof: proof in ${Date.now() - honkStart}ms`);
      } catch (e) {
        err("__zkGenerateProof: Honk proving failed", e);
        throw e; // re-throw so it's not silently swallowed
      }

      return {
        proofBytesHex: bytesToHex(proof.proof),
        publicInputsHex: bytesToHex(flattenFieldsAsArray(proof.publicInputs)),
      };
    };

    log("init: signalling Flutter — ready");
    waitForBridge("ready");
  } catch (e) {
    err("init: fatal error", e);
    waitForBridge("error:" + (e as Error).toString());
  }
}

log("module loaded, calling init()");
init();
