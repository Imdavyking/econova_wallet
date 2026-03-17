import { useState } from "react";
import { createUnsecuredToken, decodeToken } from "jsontokens";
import * as secp from "@noble/secp256k1";
import { sha256 } from "@noble/hashes/sha2.js";
import { encode } from "varuint-bitcoin";
import { Cl, serializeCV } from "@stacks/transactions";
// ─── Types ────────────────────────────────────────────────────────────────────

type MethodName =
  | "getURL"
  | "authenticationRequest"
  | "signatureRequest"
  | "structuredDataSignatureRequest"
  | "transactionRequest"
  | "psbtRequest";

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

// Decoded from the authenticationResponse JWT — populated after runAuthenticationRequest
let cachedStxAddress = "";

/**
 * The authenticationResponse is a JWT. Its payload contains:
 *   profile.stxAddress.testnet  — SP...
 *   profile.stxAddress.testnet  — ST...
 *
 * We decode it and cache the testnet address so signatureRequest can use it
 * without any user input.
 */
function extractStxAddress(authResponse: unknown): string {
  if (typeof authResponse !== "string") return "";
  try {
    const decoded = decodeToken(authResponse) as any;
    console.log({ decoded });
    const payload = decoded?.payload ?? decoded;
    // Leather / Xverse both put the address here after a successful auth
    const addr =
      payload?.profile?.stxAddress?.testnet ??
      payload?.stxAddress?.testnet ??
      payload?.address ??
      "";
    return addr;
  } catch {
    return "";
  }
}

// ─── Method Runners ───────────────────────────────────────────────────────────

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
    do_not_include_profile: false, // we NEED the profile to get stxAddress
    supports_hub_url: true,
    scopes: ["store_write", "publish_data"],
    appDetails: {
      name: "Demo App",
      icon: `${window.location.origin}/favicon.ico`,
    },
  });

  const response = await provider.authenticationRequest(token);

  // The response is itself a JWT — decode it to extract stxAddress
  // and cache it for all subsequent calls in this session
  const addr = extractStxAddress(response);
  if (addr) {
    cachedStxAddress = addr;
    console.log("[demo] cached stxAddress from auth response:", addr);
  }

  return response;
}

async function runSignatureRequest(): Promise<unknown> {
  const provider = getProvider();
  if (!provider) throw new Error("StacksProvider not found");

  if (!cachedStxAddress) {
    throw new Error(
      "No STX address cached. Run authenticationRequest first to connect and get your address.",
    );
  }

  const message = "Hello from demo.tsx — sign me!";

  const token = createUnsecuredToken({
    message: message,
    stxAddress: cachedStxAddress,
    network: "testnet",
    appDetails: {
      name: "Demo App",
      icon: `${window.location.origin}/favicon.ico`,
    },
    redirect_uri: window.location.href,
    domain_name: window.location.hostname,
  });
  // for xverse gives {
  //   "signature": "0d96b65f498a2328d544a5cb866960d3eaca8a4ca5b0b4c091b8f8a88159aef25175207f55b83afeedeae457599fdb7625f9c5de9536a188c18cb02abef2e13300",
  //   "publicKey": "02f2761827990110805d8b434a9234928cdbf54a9853dafdf9499ff4836832756d"
  // }

  // mine gives

  // for xverse gives {
  //   "signature": "00c5eb4a...",
  //   "publicKey": "02f2761827990110805d8b434a9234928cdbf54a9853dafdf9499ff4836832756d"
  // }

  return await provider.signatureRequest(token);
}

// 'Stacks Message Signing:\n'.length //  = 24
// 'Stacks Message Signing:\n'.length.toString(16) //  = 18
const chainPrefix = "\x18Stacks Message Signing:\n";

export function hashMessage(message: string): Buffer {
  return Buffer.from(sha256(encodeMessage(message)));
}

export function encodeMessage(message: string | Buffer): Buffer {
  const encoded = encode(Buffer.from(message).length);
  return Buffer.concat([
    Buffer.from(chainPrefix),
    encoded,
    Buffer.from(message),
  ]);
}

async function runStructuredDataSignatureRequest(): Promise<unknown> {
  const provider = getProvider();
  if (!provider) throw new Error("StacksProvider not found");

  if (!cachedStxAddress) {
    throw new Error("No STX address cached. Run authenticationRequest first.");
  }

  // message and domain must be Clarity-serialized hex strings
  const clarityMessage = Cl.tuple({
    action: Cl.stringAscii("test-nice-data"),
    value: Cl.uint(42),
  });

  const clarityDomain = Cl.tuple({
    name: Cl.stringAscii("Demos App"),
    version: Cl.stringAscii("1.0.0"),
    "chain-id": Cl.uint(1),
  });

  const token = createUnsecuredToken({
    stxAddress: cachedStxAddress,
    network: "testnet",
    message: serializeCV(clarityMessage), // already hex string ✓
    domain: serializeCV(clarityDomain), // already hex string ✓
    primaryType: "Action",
    appDetails: {
      name: "Demos App",
      icon: `${window.location.origin}/favicon.ico`,
    },
    redirect_uri: window.location.href,
    domain_name: window.location.hostname,
  });

  const result = await provider.structuredDataSignatureRequest(token);
  console.log({ result });
  return result;
}
async function runTransactionRequest(): Promise<unknown> {
  const provider = getProvider();
  if (!provider) throw new Error("StacksProvider not found");

  if (!cachedStxAddress) {
    throw new Error("No STX address cached. Run authenticationRequest first.");
  }

  // 1 USDCx = 1_000_000 (6 decimals)
  const amount = Cl.uint(1_000_000);
  const sender = Cl.principal(cachedStxAddress);
  const recipient = Cl.principal(cachedStxAddress); // sending to self for test
  const memo = Cl.none();

  const token = createUnsecuredToken({
    txType: "contract_call",
    contractAddress: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM",
    contractName: "usdcx",
    functionName: "transfer",
    functionArgs: [
      serializeCV(amount),
      serializeCV(sender),
      serializeCV(recipient),
      serializeCV(memo),
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

  if (typeof provider.psbtRequest !== "function") {
    throw new Error(
      "psbtRequest is not a function on this provider — likely unimplemented (TODO)",
    );
  }

  const psbtHex = "70736274ff01000a01000000000000000000000000";
  return await provider.psbtRequest({ psbt: psbtHex });
}

// ─── Method Metadata ──────────────────────────────────────────────────────────

const METHOD_META: Record<
  MethodName,
  {
    label: string;
    description: string;
    warning?: string;
    runner: () => Promise<unknown>;
  }
> = {
  getURL: {
    label: "getURL",
    description: "Returns the URL of the wallet provider.",
    runner: runGetURL,
  },
  authenticationRequest: {
    label: "authenticationRequest",
    description:
      "Connects the wallet and caches the STX address from the auth response. Run this first.",
    runner: runAuthenticationRequest,
  },
  signatureRequest: {
    label: "signatureRequest",
    description:
      "Signs a plain text message. Requires authenticationRequest to have run first.",
    runner: runSignatureRequest,
  },
  structuredDataSignatureRequest: {
    label: "structuredDataSignatureRequest",
    description:
      "Signs structured domain+message data. Requires authenticationRequest first.",
    warning: "Not in official docs. May vary by wallet version.",
    runner: runStructuredDataSignatureRequest,
  },
  transactionRequest: {
    label: "transactionRequest",
    description: "Submits a placeholder pox contract-call token for signing.",
    warning: "Wallet will open a confirmation prompt.",
    runner: runTransactionRequest,
  },
  psbtRequest: {
    label: "psbtRequest",
    description: "Sends a PSBT hex to the wallet.",
    warning: "Marked TODO in source. May not be implemented.",
    runner: runPsbtRequest,
  },
};

const METHOD_ORDER: MethodName[] = [
  "getURL",
  "authenticationRequest",
  "signatureRequest",
  "structuredDataSignatureRequest",
  "transactionRequest",
  "psbtRequest",
];

const NEEDS_AUTH: MethodName[] = [
  "signatureRequest",
  "structuredDataSignatureRequest",
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

// ─── Main Component ───────────────────────────────────────────────────────────

export default function Demo() {
  const [results, setResults] = useState<
    Partial<Record<MethodName, MethodResult>>
  >({});
  // Track whether auth has been completed so we can show hints in the UI
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
      // After a successful auth, update the UI to reflect that we now have an address
      if (name === "authenticationRequest" && cachedStxAddress) {
        setAuthed(true);
        setResolvedAddress(cachedStxAddress);
      }
    } catch (err: any) {
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

  return (
    <div style={styles.root}>
      {/* Header */}
      <div style={styles.header}>
        <div>
          <span style={styles.chip}>window.StacksProvider</span>
          <h1 style={styles.title}>Deprecated Methods Testbed</h1>
          <p style={styles.subtitle}>
            All six methods are marked{" "}
            <code style={styles.code}>TODO: deprecated</code> in source.
          </p>
        </div>
        <button
          style={styles.runAllBtn}
          onClick={() =>
            METHOD_ORDER.reduce(
              (p, n) => p.then(() => invoke(n)),
              Promise.resolve(),
            )
          }
        >
          ▶ Run All
        </button>
      </div>

      {/* Auth status banner */}
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
            is extracted from the auth response and reused by signatureRequest
            automatically.
          </span>
        )}
      </div>

      {/* Cards */}
      <div style={styles.grid}>
        {METHOD_ORDER.map((name) => {
          const meta = METHOD_META[name];
          const result = results[name];
          const status: Status = result?.status ?? "idle";
          const blocked = NEEDS_AUTH.includes(name) && !authed;

          return (
            <div
              key={name}
              style={{ ...styles.card, ...borderByStatus(status) }}
            >
              <div style={styles.cardHeader}>
                <StatusDot status={status} />
                <span style={styles.methodName}>{meta.label}</span>
                {blocked && <span style={styles.badge}>auth first</span>}
                {result?.durationMs !== undefined && (
                  <span style={styles.duration}>{result.durationMs} ms</span>
                )}
              </div>

              <p style={styles.desc}>{meta.description}</p>

              {meta.warning && (
                <div style={styles.warning}>⚠ {meta.warning}</div>
              )}

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
        })}
      </div>
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
  runAllBtn: {
    background: "#2b6cb0",
    color: "#bee3f8",
    border: "none",
    borderRadius: 6,
    padding: "10px 20px",
    fontSize: 13,
    fontFamily: "inherit",
    fontWeight: 600,
    cursor: "pointer",
    letterSpacing: "0.04em",
    whiteSpace: "nowrap",
  },
  banner: {
    display: "flex",
    alignItems: "center",
    flexWrap: "wrap",
    gap: 4,
    border: "1px solid",
    borderRadius: 8,
    padding: "12px 16px",
    marginBottom: 24,
    fontSize: 13,
    lineHeight: 1.5,
  },
  grid: {
    display: "grid",
    gridTemplateColumns: "repeat(auto-fill, minmax(340px, 1fr))",
    gap: 16,
  },
  card: {
    background: "#161b22",
    border: "1px solid #2d3748",
    borderRadius: 8,
    padding: "18px 20px",
    display: "flex",
    flexDirection: "column",
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
    fontSize: 14,
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
    overflowX: "auto",
    whiteSpace: "pre-wrap",
    wordBreak: "break-all",
    maxHeight: 180,
    overflowY: "auto",
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
