import express from "express";
import axios from "axios";
import {
  paymentMiddleware,
  USDCxToMicroUSDCx,
} from "x402-stacks";
import { StacksMainnet, StacksTestnet } from "@stacks/network";
import {
  broadcastTransaction,
  deserializeTransaction,
} from "@stacks/transactions";
import "dotenv/config";

const PORT = process.env.PORT ?? 3000;
const NETWORK = process.env.NETWORK === "mainnet" ? "mainnet" : "testnet";
const PAY_TO = process.env.PAY_TO!;
const FACILITATOR_URL = process.env.FACILITATOR_URL ?? `http://localhost:${PORT}`;
const PRICE = USDCxToMicroUSDCx(0.1);

const stacksNetwork = NETWORK === "mainnet" ? new StacksMainnet() : new StacksTestnet();
const ALEX_API = "https://api.alexgo.io";

const FEATURED_POOLS: Record<string, number> = {
  "STX-ALEX": 1,
  "STX-USDA": 4,
  "STX-xBTC": 5,
  "ALEX-USDA": 6,
  "STX-aBTC": 13,
};

const app = express();
app.use(express.json());

// ── Facilitator ───────────────────────────────────────────────────────────────

app.get("/supported", (_, res) => {
  res.json({
    kinds: [
      { x402Version: 2, scheme: "exact", network: "stacks:1" },
      { x402Version: 2, scheme: "exact", network: "stacks:2147483648" },
    ],
    extensions: [],
    signers: {},
  });
});

app.post("/verify", (req, res) => {
  const { paymentPayload, paymentRequirements } = req.body;
  try {
    if (!paymentPayload?.payload?.transaction)
      return res.json({ valid: false, error: "Missing transaction" });
    if (paymentPayload.accepted?.amount !== paymentRequirements?.amount)
      return res.json({ valid: false, error: "Amount mismatch" });
    if (paymentPayload.accepted?.payTo !== paymentRequirements?.payTo)
      return res.json({ valid: false, error: "Recipient mismatch" });
    return res.json({ valid: true });
  } catch (e) {
    return res.json({ valid: false, error: `${e}` });
  }
});

app.post("/settle", async (req, res) => {
  const { paymentPayload, paymentRequirements } = req.body;
  try {
    const txHex = paymentPayload.payload.transaction.replace("0x", "");
    const tx = deserializeTransaction(txHex);
    const result = await broadcastTransaction(tx, stacksNetwork);

    if ("error" in result) {
      return res.status(400).json({
        success: false,
        error: result.error,
        reason: (result as any).reason,
        reason_data: (result as any).reason_data,
      });
    }

    console.log(`[settle] txid=${result.txid} payer=${paymentPayload.accepted?.from}`);

    return res.json({
      success: true,
      payer: paymentPayload.accepted?.from ?? "unknown",
      transaction: result.txid,
      network: paymentRequirements?.network ?? `stacks:${NETWORK === "mainnet" ? 1 : 2147483648}`,
    });
  } catch (e: any) {
    return res.status(500).json({ success: false, error: e?.message ?? `${e}` });
  }
});

// ── Paywall ───────────────────────────────────────────────────────────────────

const paywall = paymentMiddleware({
  amount: PRICE,
  asset: "USDCX",
  network: NETWORK,
  payTo: PAY_TO,
  facilitatorUrl: FACILITATOR_URL,
});

// GET /api/defi-yields
// Live APR + TVL for top Stacks pools on Alex Lab
// Demo: "What are the best yields on Stacks right now?"
app.get("/api/defi-yields", paywall, async (_, res) => {
  try {
    const poolResults = await Promise.allSettled(
      Object.entries(FEATURED_POOLS).map(async ([name, poolId]) => {
        const { data } = await axios.get(
          `${ALEX_API}/v1/pool_stats/${poolId}`,
          { params: { limit: 1 }, timeout: 8000 }
        );

        const latest = data?.pool_status?.[0];
        if (!latest) return null;

        return {
          pool: name,
          pool_id: poolId,
          apr_pct: latest.pool_token_lp_apr != null
            ? Number((latest.pool_token_lp_apr * 100).toFixed(2))
            : null,
          tvl_usd: latest.pool_tvl != null
            ? Number(latest.pool_tvl.toFixed(2))
            : null,
          volume_24h_usd: latest.volume_24h != null
            ? Number(latest.volume_24h.toFixed(2))
            : null,
          block_height: latest.block_height,
        };
      })
    );

    const pools = poolResults
      .filter((r) => r.status === "fulfilled" && r.value !== null)
      .map((r) => (r as PromiseFulfilledResult<any>).value)
      .sort((a, b) => (b.apr_pct ?? 0) - (a.apr_pct ?? 0));

    return res.json({
      timestamp: new Date().toISOString(),
      source: "Alex Lab (api.alexgo.io)",
      network: "Stacks Mainnet",
      note: "APR reflects LP fee rebates. Does not include impermanent loss.",
      pools,
    });
  } catch (e: any) {
    return res.status(502).json({ error: "Failed to fetch yield data", detail: e?.message });
  }
});

// GET /api/pool/:name
// Detailed stats for a single pool e.g. /api/pool/STX-ALEX
app.get("/api/pool/:name", paywall, async (req, res) => {
  const name = req.params.name.toUpperCase();
  const poolId = FEATURED_POOLS[name];

  if (!poolId) {
    return res.status(404).json({
      error: `Pool "${name}" not found`,
      available: Object.keys(FEATURED_POOLS),
    });
  }

  try {
    const { data } = await axios.get(`${ALEX_API}/v1/pool_stats/${poolId}`, {
      params: { limit: 5 },
      timeout: 8000,
    });

    const latest = data?.pool_status?.[0];
    const history = data?.pool_status?.map((s: any) => ({
      block_height: s.block_height,
      apr_pct: s.pool_token_lp_apr != null
        ? Number((s.pool_token_lp_apr * 100).toFixed(2))
        : null,
      tvl_usd: s.pool_tvl != null
        ? Number(s.pool_tvl.toFixed(2))
        : null,
    }));

    return res.json({
      timestamp: new Date().toISOString(),
      source: "Alex Lab (api.alexgo.io)",
      pool: name,
      pool_id: poolId,
      current: {
        apr_pct: latest?.pool_token_lp_apr != null
          ? Number((latest.pool_token_lp_apr * 100).toFixed(2))
          : null,
        tvl_usd: latest?.pool_tvl != null
          ? Number(latest.pool_tvl.toFixed(2))
          : null,
        block_height: latest?.block_height,
      },
      recent_history: history,
    });
  } catch (e: any) {
    return res.status(502).json({ error: "Failed to fetch pool data", detail: e?.message });
  }
});

// ── Health ────────────────────────────────────────────────────────────────────

app.get("/health", (_, res) => {
  res.json({
    status: "ok",
    network: NETWORK,
    payTo: PAY_TO,
    endpoints: ["/api/defi-yields", "/api/pool/:name"],
    available_pools: Object.keys(FEATURED_POOLS),
  });
});

// ── Start ─────────────────────────────────────────────────────────────────────

app.listen(PORT, () => {
  console.log(`x402 DeFi yields server on port ${PORT}`);
  console.log(`Network : ${NETWORK}`);
  console.log(`Pay to  : ${PAY_TO}`);
  console.log(`Price   : 0.1 USDCx per request`);
  console.log(`Pools   : ${Object.keys(FEATURED_POOLS).join(", ")}`);
});
