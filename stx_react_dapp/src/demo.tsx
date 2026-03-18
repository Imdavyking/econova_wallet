import { useState } from "react";
import { createUnsecuredToken, decodeToken } from "jsontokens";
import * as secp from "@noble/secp256k1";
import { sha256 } from "@noble/hashes/sha2.js";
import { encode } from "varuint-bitcoin";
import { Cl, serializeCV } from "@stacks/transactions";
// ─── Types ────────────────────────────────────────────────────────────────────

type MethodName =
  // ── Legacy (hiroWallet / StacksProvider) ──────────────────────────────────
  | "getURL"
  | "authenticationRequest"
  | "signatureRequest"
  | "structuredDataSignatureRequest"
  | "transactionRequest"
  | "psbtRequest"
  // ── request() API (LeatherProvider.request) ───────────────────────────────
  | "getInfo"
  | "getAddresses"
  | "stx_getAddresses"
  | "getAccounts"
  | "stx_getAccounts"
  | "stx_getNetworks"
  | "disconnect"
  | "stx_signMessage"
  | "stx_signStructuredMessage"
  | "stx_signTransaction"
  | "stx_transferStx"
  | "stx_transferSip10Ft"
  | "stx_callContract"
  | "stx_deployContract";

type Status = "idle" | "pending" | "success" | "error";

interface MethodResult {
  status: Status;
  data?: unknown;
  error?: string;
  durationMs?: number;
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

function getProvider(): any {
  if (typeof window !== "undefined" && (window as any).StacksProvider) {
    return (window as any).StacksProvider;
  }
  return null;
}

let cachedStxAddress = "";
let cachedPublicKey = "";

function extractStxAddress(authResponse: unknown): string {
  if (typeof authResponse !== "string") return "";
  try {
    const decoded = decodeToken(authResponse) as any;
    const payload = decoded?.payload ?? decoded;
    return (
      payload?.profile?.stxAddress?.testnet ??
      payload?.stxAddress?.testnet ??
      payload?.address ??
      ""
    );
  } catch {
    return "";
  }
}

// ─── Legacy Method Runners ────────────────────────────────────────────────────

async function runGetURL(): Promise<unknown> {
  const provider = getProvider();
  if (!provider) throw new Error("StacksProvider not found");
  return await provider.getURL();
}

async function runAuthenticationRequest(): Promise<unknown> {
  const provider = getProvider();
  if (!provider) throw new Error("StacksProvider not found");
  const transitPrivateKey = secp.utils.randomPrivateKey();
  const transitPublicKey = secp.getPublicKey(transitPrivateKey, true);
  const pubKeyHex = Buffer.from(transitPublicKey).toString("hex");
  const token = createUnsecuredToken({
    jti: crypto.randomUUID(),
    iat: Math.floor(Date.now() / 1000),
    exp: Math.floor(Date.now() / 1000) + 3600,
    iss: pubKeyHex,
    public_keys: [pubKeyHex],
    domain_name: window.location.hostname,
    manifest_uri: `${window.location.origin}/manifest.json`,
    redirect_uri: window.location.href,
    version: "1.3.1",
    do_not_include_profile: false,
    supports_hub_url: true,
    scopes: ["store_write", "publish_data"],
    appDetails: {
      name: "Demo App",
      icon: `${window.location.origin}/favicon.ico`,
    },
  });
  const response = await provider.authenticationRequest(token);
  const addr = extractStxAddress(response);
  if (addr) {
    cachedStxAddress = addr;
    console.log("[demo] cached stxAddress:", addr);
  }
  return response;
}

async function runSignatureRequest(): Promise<unknown> {
  const provider = getProvider();
  if (!provider) throw new Error("StacksProvider not found");
  if (!cachedStxAddress) throw new Error("Run authenticationRequest first.");
  const token = createUnsecuredToken({
    message: "Hello from demo.tsx — sign me!",
    stxAddress: cachedStxAddress,
    network: "testnet",
    appDetails: {
      name: "Demo App",
      icon: `${window.location.origin}/favicon.ico`,
    },
    redirect_uri: window.location.href,
    domain_name: window.location.hostname,
  });
  return await provider.signatureRequest(token);
}

export function hashMessage(message: string): Buffer {
  const chainPrefix = "\x18Stacks Message Signing:\n";
  const encoded = encode(Buffer.from(message).length);
  return Buffer.from(
    sha256(
      Buffer.concat([Buffer.from(chainPrefix), encoded, Buffer.from(message)]),
    ),
  );
}

async function runStructuredDataSignatureRequest(): Promise<unknown> {
  const provider = getProvider();
  if (!provider) throw new Error("StacksProvider not found");
  if (!cachedStxAddress) throw new Error("Run authenticationRequest first.");
  const token = createUnsecuredToken({
    stxAddress: cachedStxAddress,
    network: "testnet",
    message: serializeCV(
      Cl.tuple({
        action: Cl.stringAscii("test-nice-data"),
        value: Cl.uint(42),
      }),
    ),
    domain: serializeCV(
      Cl.tuple({
        name: Cl.stringAscii("Demos App"),
        version: Cl.stringAscii("1.0.0"),
        "chain-id": Cl.uint(1),
      }),
    ),
    primaryType: "Action",
    appDetails: {
      name: "Demos App",
      icon: `${window.location.origin}/favicon.ico`,
    },
    redirect_uri: window.location.href,
    domain_name: window.location.hostname,
  });
  return await provider.structuredDataSignatureRequest(token);
}

async function runTransactionRequest(): Promise<unknown> {
  const provider = getProvider();
  if (!provider) throw new Error("StacksProvider not found");
  if (!cachedStxAddress) throw new Error("Run authenticationRequest first.");
  const token = createUnsecuredToken({
    txType: "contract_call",
    contractAddress: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM",
    contractName: "usdcx",
    functionName: "transfer",
    functionArgs: [
      serializeCV(Cl.uint(1_000_000)),
      serializeCV(Cl.principal(cachedStxAddress)),
      serializeCV(Cl.principal(cachedStxAddress)),
      serializeCV(Cl.none()),
    ],
    postConditions: [],
    network: "testnet",
    appDetails: {
      name: "Demo App",
      icon: `${window.location.origin}/favicon.ico`,
    },
    stxAddress: cachedStxAddress,
  });
  return await provider.transactionRequest(token);
}

async function runPsbtRequest(): Promise<unknown> {
  const provider = getProvider();
  if (!provider) throw new Error("StacksProvider not found");
  if (typeof provider.psbtRequest !== "function")
    throw new Error("psbtRequest not implemented on this provider.");
  return await provider.psbtRequest({
    psbt: "70736274ff01000a01000000000000000000000000",
  });
}

// ─── request() API Runners ────────────────────────────────────────────────────

async function req(
  method: string,
  params: Record<string, unknown> = {},
): Promise<unknown> {
  const provider = getProvider();
  if (!provider) throw new Error("Stacks Provider not found");
  return await provider.request(method, params);
}

async function runGetInfo(): Promise<unknown> {
  return await req("getInfo");
}
async function cacheStxAccount(account: any) {
  if (!account) return;
  if (account.publicKey) cachedPublicKey = account.publicKey as string;
  if (!cachedStxAddress && account.address) cachedStxAddress = account.address;
}

async function runGetAddresses(): Promise<unknown> {
  const result = (await req("getAddresses")) as any;
  const addresses = result?.result?.addresses ?? result?.addresses ?? [];
  const account = addresses.find(
    (a: any) => a.address?.startsWith("ST") || a.address?.startsWith("SP"),
  );
  await cacheStxAccount(account);
  return result;
}

async function runStxGetAddresses(): Promise<unknown> {
  const result = (await req("stx_getAddresses")) as any;
  const addresses = result?.result?.addresses ?? result?.addresses ?? [];
  const account = addresses.find(
    (a: any) => a.address?.startsWith("ST") || a.address?.startsWith("SP"),
  );
  await cacheStxAccount(account);
  return result;
}

async function runGetAccounts(): Promise<unknown> {
  const result = (await req("getAccounts")) as any;
  const accounts = result?.result?.accounts ?? result?.accounts ?? [];
  const account = accounts.find(
    (a: any) => a.address?.startsWith("ST") || a.address?.startsWith("SP"),
  );
  await cacheStxAccount(account);
  return result;
}

async function runStxGetAccounts(): Promise<unknown> {
  const result = (await req("stx_getAccounts")) as any;
  const accounts = result?.result?.accounts ?? result?.accounts ?? [];
  const account = accounts.find(
    (a: any) => a.address?.startsWith("ST") || a.address?.startsWith("SP"),
  );
  await cacheStxAccount(account);
  return result;
}

async function runStxGetNetworks(): Promise<unknown> {
  return await req("stx_getNetworks");
}

async function runDisconnect(): Promise<unknown> {
  return await req("disconnect");
}

async function runStxSignMessage(): Promise<unknown> {
  if (!cachedPublicKey) throw new Error("Run getAddresses first.");
  return await req("stx_signMessage", { message: "Hello from request() API!" });
}

async function runStxSignStructuredMessage(): Promise<unknown> {
  if (!cachedPublicKey) throw new Error("Run getAddresses first.");
  return await req("stx_signStructuredMessage", {
    message: serializeCV(
      Cl.tuple({ action: Cl.stringAscii("test"), value: Cl.uint(1) }),
    ),
    domain: serializeCV(
      Cl.tuple({
        name: Cl.stringAscii("Demo App"),
        version: Cl.stringAscii("1.0.0"),
        "chain-id": Cl.uint(1),
      }),
    ),
  });
}

async function runStxSignTransaction(): Promise<unknown> {
  if (!cachedStxAddress) throw new Error("Run authenticationRequest first.");

  const { makeUnsignedSTXTokenTransfer } = await import("@stacks/transactions");

  const tx = await makeUnsignedSTXTokenTransfer({
    recipient: "ST2NA77FDECF5422YVK1FPDAAW4MGK24W9EQ42CWR",
    amount: 1n,
    fee: 200n,
    nonce: 0n,
    network: "testnet",
    publicKey: cachedPublicKey,
  });

  const serialized = tx.serialize();
  // serialize() returns a hex string in newer @stacks/transactions
  const hex =
    typeof serialized === "string"
      ? serialized
      : Buffer.from(serialized).toString("hex");

  console.log("[stx_signTransaction] first byte:", hex.slice(0, 2)); // should be "80" for testnet

  return await req("stx_signTransaction", { transaction: hex });
}
async function runStxTransferStx(): Promise<unknown> {
  if (!cachedPublicKey) throw new Error("Run getAddresses first.");
  // Transfer 1 µSTX to self
  return await req("stx_transferStx", {
    recipient: "ST2NA77FDECF5422YVK1FPDAAW4MGK24W9EQ42CWR",
    amount: "1",
    memo: "test transfer",
  });
}

async function runStxTransferSip10Ft(): Promise<unknown> {
  if (!cachedPublicKey) throw new Error("Run getAddresses first.");
  // Transfer 1 USDCx (1_000_000 base units) to self
  return await req("stx_transferSip10Ft", {
    asset: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.usdcx::usdcx",
    recipient: "ST2NA77FDECF5422YVK1FPDAAW4MGK24W9EQ42CWR",
    amount: "1000000",
  });
}

async function runStxCallContract(): Promise<unknown> {
  if (!cachedPublicKey) throw new Error("Run getAddresses first.");
  return await req("stx_callContract", {
    contract: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.usdcx",
    functionName: "transfer",
    functionArgs: [
      serializeCV(Cl.uint(1)), // amount
      serializeCV(Cl.principal(cachedStxAddress)), // sender
      serializeCV(Cl.principal(cachedStxAddress)), // recipient (self)
      serializeCV(Cl.none()), // memo
    ],
  });
}

async function runStxDeployContract(): Promise<unknown> {
  if (!cachedPublicKey) throw new Error("Run getAddresses first.");
  return await req("stx_deployContract", {
    name: `demo-contract-${Date.now()}`,
    clarityCode: ';; Demo contract\n(define-public (hello) (ok "world"))',
    clarityVersion: 2,
  });
}

// ─── Method Metadata ──────────────────────────────────────────────────────────

type GroupName = "Legacy (StacksProvider)" | "request() API (LeatherProvider)";

const METHOD_META: Record<
  MethodName,
  {
    label: string;
    description: string;
    warning?: string;
    runner: () => Promise<unknown>;
    group: GroupName;
  }
> = {
  // ── Legacy ───────────────────────────────────────────────────────────────
  getURL: {
    group: "Legacy (StacksProvider)",
    label: "getURL",
    description: "Returns the URL of the wallet provider.",
    runner: runGetURL,
  },
  authenticationRequest: {
    group: "Legacy (StacksProvider)",
    label: "authenticationRequest",
    description:
      "Connects the wallet and caches the STX address. Run this first.",
    runner: runAuthenticationRequest,
  },
  signatureRequest: {
    group: "Legacy (StacksProvider)",
    label: "signatureRequest",
    description: "Signs a plain-text message. Requires auth first.",
    runner: runSignatureRequest,
  },
  structuredDataSignatureRequest: {
    group: "Legacy (StacksProvider)",
    label: "structuredDataSignatureRequest",
    description: "Signs domain+message structured data. Requires auth first.",
    warning: "Not in official docs. May vary by wallet version.",
    runner: runStructuredDataSignatureRequest,
  },
  transactionRequest: {
    group: "Legacy (StacksProvider)",
    label: "transactionRequest",
    description: "Submits USDCx transfer (1 token, self) via JWT.",
    warning: "Opens a confirmation prompt.",
    runner: runTransactionRequest,
  },
  psbtRequest: {
    group: "Legacy (StacksProvider)",
    label: "psbtRequest",
    description: "Sends a stub Bitcoin PSBT hex to the wallet.",
    warning: "Stubbed — not supported by EcoNova.",
    runner: runPsbtRequest,
  },

  // ── request() ─────────────────────────────────────────────────────────────
  getInfo: {
    group: "request() API (LeatherProvider)",
    label: "getInfo",
    description: "Returns wallet name, version, supported methods.",
    runner: runGetInfo,
  },
  getAddresses: {
    group: "request() API (LeatherProvider)",
    label: "getAddresses",
    description: "Prompts connection and returns STX + BTC addresses.",
    runner: runGetAddresses,
  },
  stx_getAddresses: {
    group: "request() API (LeatherProvider)",
    label: "stx_getAddresses",
    description: "Stacks-specific address fetch (same as getAddresses).",
    runner: runStxGetAddresses,
  },
  getAccounts: {
    group: "request() API (LeatherProvider)",
    label: "getAccounts",
    description: "Returns full account objects including publicKey + network.",
    runner: runGetAccounts,
  },
  stx_getAccounts: {
    group: "request() API (LeatherProvider)",
    label: "stx_getAccounts",
    description: "Stacks-specific account fetch.",
    runner: runStxGetAccounts,
  },
  stx_getNetworks: {
    group: "request() API (LeatherProvider)",
    label: "stx_getNetworks",
    description: "Returns the active network (mainnet / testnet) and chainId.",
    runner: runStxGetNetworks,
  },
  disconnect: {
    group: "request() API (LeatherProvider)",
    label: "disconnect",
    description: "Clears the saved web3 address from the wallet's store.",
    warning: "You'll need to re-run getAddresses after this.",
    runner: runDisconnect,
  },
  stx_signMessage: {
    group: "request() API (LeatherProvider)",
    label: "stx_signMessage",
    description: "Signs a plain-text message via the modern request() path.",
    runner: runStxSignMessage,
  },
  stx_signStructuredMessage: {
    group: "request() API (LeatherProvider)",
    label: "stx_signStructuredMessage",
    description: "Signs a Clarity-serialised domain+message (SIP-018).",
    runner: runStxSignStructuredMessage,
  },
  stx_signTransaction: {
    group: "request() API (LeatherProvider)",
    label: "stx_signTransaction",
    description: "Signs a raw pre-built transaction hex without broadcasting.",
    warning: "Stub tx — will sign but result won't broadcast.",
    runner: runStxSignTransaction,
  },
  stx_transferStx: {
    group: "request() API (LeatherProvider)",
    label: "stx_transferStx",
    description: "Builds, signs, and broadcasts a 1 µSTX self-transfer.",
    warning: "Broadcasts to testnet.",
    runner: runStxTransferStx,
  },
  stx_transferSip10Ft: {
    group: "request() API (LeatherProvider)",
    label: "stx_transferSip10Ft",
    description: "Transfers 1 USDCx (1_000_000 base units) to self on testnet.",
    warning: "Broadcasts to testnet.",
    runner: runStxTransferSip10Ft,
  },
  stx_callContract: {
    group: "request() API (LeatherProvider)",
    label: "stx_callContract",
    description: "Calls usdcx.get-balance for the connected address.",
    runner: runStxCallContract,
  },
  stx_deployContract: {
    group: "request() API (LeatherProvider)",
    label: "stx_deployContract",
    description: "Deploys a minimal 'hello world' Clarity contract.",
    warning: "Broadcasts to testnet. Costs STX fees.",
    runner: runStxDeployContract,
  },
};

const LEGACY_METHODS: MethodName[] = [
  "getURL",
  "authenticationRequest",
  "signatureRequest",
  "structuredDataSignatureRequest",
  "transactionRequest",
  "psbtRequest",
];

const REQUEST_METHODS: MethodName[] = [
  "getInfo",
  "getAddresses",
  "stx_getAddresses",
  "getAccounts",
  "stx_getAccounts",
  "stx_getNetworks",
  "disconnect",
  "stx_signMessage",
  "stx_signStructuredMessage",
  "stx_signTransaction",
  "stx_transferStx",
  "stx_transferSip10Ft",
  "stx_callContract",
  "stx_deployContract",
];

const NEEDS_AUTH: MethodName[] = [
  "signatureRequest",
  "structuredDataSignatureRequest",
  "stx_signMessage",
  "stx_signStructuredMessage",
  "stx_signTransaction",
  "stx_transferStx",
  "stx_transferSip10Ft",
  "stx_callContract",
  "stx_deployContract",
];

// ─── UI Components ────────────────────────────────────────────────────────────

const StatusDot = ({ status }: { status: Status }) => {
  const colors: Record<Status, string> = {
    idle: "#4a5568",
    pending: "#f6c90e",
    success: "#48bb78",
    error: "#fc8181",
  };
  return (
    <span
      style={{
        display: "inline-block",
        width: 8,
        height: 8,
        borderRadius: "50%",
        background: colors[status],
        boxShadow: status !== "idle" ? `0 0 6px ${colors[status]}` : "none",
        flexShrink: 0,
        marginTop: 2,
      }}
    />
  );
};

function SectionHeader({
  title,
  onRunAll,
}: {
  title: string;
  onRunAll: () => void;
}) {
  return (
    <div style={styles.sectionHeader}>
      <div style={styles.sectionLabel}>{title}</div>
      <button style={styles.runAllBtn} onClick={onRunAll}>
        ▶ Run All
      </button>
    </div>
  );
}

// ─── Main Component ───────────────────────────────────────────────────────────

export default function Demo() {
  const [results, setResults] = useState<
    Partial<Record<MethodName, MethodResult>>
  >({});
  const [authed, setAuthed] = useState(false);
  const [resolvedAddress, setResolvedAddress] = useState("");

  async function invoke(name: MethodName) {
    setResults((prev) => ({ ...prev, [name]: { status: "pending" } }));
    const t0 = performance.now();
    try {
      const data = await METHOD_META[name].runner();
      setResults((prev) => ({
        ...prev,
        [name]: {
          status: "success",
          data,
          durationMs: Math.round(performance.now() - t0),
        },
      }));
      if (name === "authenticationRequest" && cachedStxAddress) {
        setAuthed(true);
        setResolvedAddress(cachedStxAddress);
      }
    } catch (err: any) {
      console.log(JSON.stringify(err));
      setResults((prev) => ({
        ...prev,
        [name]: {
          status: "error",
          error: err?.message ?? String(err),
          durationMs: Math.round(performance.now() - t0),
        },
      }));
    }
  }

  function runGroup(methods: MethodName[]) {
    methods.reduce((p, n) => p.then(() => invoke(n)), Promise.resolve());
  }

  function renderCard(name: MethodName) {
    const meta = METHOD_META[name];
    const result = results[name];
    const status: Status = result?.status ?? "idle";
    const blocked = NEEDS_AUTH.includes(name) && !authed;

    return (
      <div key={name} style={{ ...styles.card, ...borderByStatus(status) }}>
        <div style={styles.cardHeader}>
          <StatusDot status={status} />
          <span style={styles.methodName}>{meta.label}</span>
          {blocked && <span style={styles.badge}>auth first</span>}
          {result?.durationMs !== undefined && (
            <span style={styles.duration}>{result.durationMs} ms</span>
          )}
        </div>

        <p style={styles.desc}>{meta.description}</p>

        {meta.warning && <div style={styles.warning}>⚠ {meta.warning}</div>}

        {result && result.status !== "idle" && (
          <pre style={{ ...styles.output, ...outputColor(status) }}>
            {status === "pending"
              ? "Waiting for wallet…"
              : status === "error"
                ? `Error: ${result.error}`
                : JSON.stringify(result.data, null, 2)}
          </pre>
        )}

        <button
          style={{
            ...styles.btn,
            opacity: status === "pending" ? 0.5 : 1,
            cursor: status === "pending" ? "not-allowed" : "pointer",
          }}
          disabled={status === "pending"}
          onClick={() => invoke(name)}
        >
          {status === "pending"
            ? "⏳ Waiting…"
            : status === "success"
              ? "↺ Re-run"
              : "▶ Run"}
        </button>
      </div>
    );
  }

  return (
    <div style={styles.root}>
      {/* Header */}
      <div style={styles.header}>
        <div>
          <span style={styles.chip}>EcoNova · Stacks Provider Testbed</span>
          <h1 style={styles.title}>Wallet Method Runner</h1>
          <p style={styles.subtitle}>
            Legacy <code style={styles.code}>StacksProvider</code> methods &amp;
            modern <code style={styles.code}>LeatherProvider.request()</code>{" "}
            API
          </p>
        </div>
        <button
          style={styles.runAllBtn}
          onClick={() => runGroup([...LEGACY_METHODS, ...REQUEST_METHODS])}
        >
          ▶ Run All
        </button>
      </div>

      {/* Auth banner */}
      <div
        style={{
          ...styles.banner,
          borderColor: authed ? "#48bb78" : "#744210",
          background: authed ? "#1a2d1e" : "#2d2006",
        }}
      >
        {authed ? (
          <>
            <span style={{ color: "#48bb78" }}>✓ Authenticated</span>
            <span style={{ color: "#718096", marginLeft: 12 }}>
              STX address:
            </span>
            <code style={{ color: "#9ae6b4", marginLeft: 8, fontSize: 12 }}>
              {resolvedAddress}
            </code>
          </>
        ) : (
          <span style={{ color: "#f6ad55" }}>
            ⚠ Run <strong>authenticationRequest</strong> first — the STX address
            is extracted from the auth response and reused by signed calls
            automatically.
          </span>
        )}
      </div>

      {/* Legacy group */}
      <SectionHeader
        title="Legacy (StacksProvider / hiroWallet*)"
        onRunAll={() => runGroup(LEGACY_METHODS)}
      />
      <div style={styles.grid}>{LEGACY_METHODS.map(renderCard)}</div>

      {/* request() group */}
      <SectionHeader
        title="request() API (LeatherProvider.request)"
        onRunAll={() => runGroup(REQUEST_METHODS)}
      />
      <div style={styles.grid}>{REQUEST_METHODS.map(renderCard)}</div>
    </div>
  );
}

// ─── Style helpers ────────────────────────────────────────────────────────────

function borderByStatus(s: Status): React.CSSProperties {
  if (s === "success") return { borderColor: "#48bb78" };
  if (s === "error") return { borderColor: "#fc8181" };
  if (s === "pending") return { borderColor: "#f6c90e" };
  return {};
}

function outputColor(s: Status): React.CSSProperties {
  if (s === "error") return { color: "#fc8181", background: "#2d1a1a" };
  if (s === "success") return { color: "#9ae6b4", background: "#1a2d1e" };
  return {};
}

// ─── Styles ───────────────────────────────────────────────────────────────────

const styles: Record<string, React.CSSProperties> = {
  root: {
    fontFamily: '"IBM Plex Mono", "Fira Code", monospace',
    background: "#0d1117",
    minHeight: "100vh",
    color: "#e2e8f0",
    padding: "32px 24px 64px",
    boxSizing: "border-box",
  },
  header: {
    display: "flex",
    alignItems: "flex-start",
    justifyContent: "space-between",
    gap: 24,
    marginBottom: 20,
    flexWrap: "wrap",
  },
  chip: {
    display: "inline-block",
    background: "#1e3a5f",
    color: "#63b3ed",
    fontSize: 11,
    padding: "3px 10px",
    borderRadius: 4,
    letterSpacing: "0.08em",
    marginBottom: 10,
  },
  title: {
    margin: "0 0 8px",
    fontSize: 26,
    fontWeight: 700,
    color: "#f7fafc",
    letterSpacing: "-0.02em",
  },
  subtitle: {
    margin: 0,
    fontSize: 13,
    color: "#718096",
    lineHeight: 1.6,
  },
  code: {
    fontFamily: "inherit",
    background: "#1a202c",
    color: "#f6ad55",
    padding: "1px 5px",
    borderRadius: 3,
    fontSize: 12,
  },
  sectionHeader: {
    display: "flex",
    alignItems: "center",
    justifyContent: "space-between",
    margin: "28px 0 12px",
    paddingBottom: 8,
    borderBottom: "1px solid #2d3748",
  },
  sectionLabel: {
    fontSize: 12,
    fontWeight: 600,
    color: "#718096",
    letterSpacing: "0.1em",
    textTransform: "uppercase" as const,
  },
  runAllBtn: {
    background: "#2b6cb0",
    color: "#bee3f8",
    border: "none",
    borderRadius: 6,
    padding: "8px 16px",
    fontSize: 12,
    fontFamily: "inherit",
    fontWeight: 600,
    cursor: "pointer",
    letterSpacing: "0.04em",
    whiteSpace: "nowrap" as const,
  },
  banner: {
    display: "flex",
    alignItems: "center",
    flexWrap: "wrap" as const,
    gap: 4,
    border: "1px solid",
    borderRadius: 8,
    padding: "12px 16px",
    marginBottom: 8,
    fontSize: 13,
    lineHeight: 1.5,
  },
  grid: {
    display: "grid",
    gridTemplateColumns: "repeat(auto-fill, minmax(340px, 1fr))",
    gap: 14,
  },
  card: {
    background: "#161b22",
    border: "1px solid #2d3748",
    borderRadius: 8,
    padding: "18px 20px",
    display: "flex",
    flexDirection: "column" as const,
    gap: 10,
    transition: "border-color 0.2s",
  },
  cardHeader: {
    display: "flex",
    alignItems: "center",
    gap: 8,
  },
  methodName: {
    fontWeight: 700,
    fontSize: 13,
    color: "#90cdf4",
    flex: 1,
  },
  badge: {
    fontSize: 10,
    color: "#f6ad55",
    background: "#2d2006",
    border: "1px solid #744210",
    borderRadius: 4,
    padding: "1px 6px",
  },
  duration: {
    fontSize: 11,
    color: "#4a5568",
  },
  desc: {
    margin: 0,
    fontSize: 12,
    color: "#718096",
    lineHeight: 1.55,
  },
  warning: {
    background: "#2d2006",
    border: "1px solid #744210",
    borderRadius: 5,
    color: "#f6ad55",
    fontSize: 11,
    padding: "7px 10px",
    lineHeight: 1.5,
  },
  output: {
    background: "#0d1117",
    border: "1px solid #2d3748",
    borderRadius: 5,
    fontSize: 11,
    padding: "10px 12px",
    overflowX: "auto" as const,
    whiteSpace: "pre-wrap" as const,
    wordBreak: "break-all" as const,
    maxHeight: 180,
    overflowY: "auto" as const,
    margin: 0,
    color: "#a0aec0",
    lineHeight: 1.6,
  },
  btn: {
    alignSelf: "flex-start",
    marginTop: 4,
    background: "transparent",
    border: "1px solid #2d3748",
    borderRadius: 5,
    color: "#90cdf4",
    fontSize: 12,
    fontFamily: "inherit",
    padding: "6px 14px",
    letterSpacing: "0.04em",
  },
};
