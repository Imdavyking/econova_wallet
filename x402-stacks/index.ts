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

// ── Config ────────────────────────────────────────────────────────────────────

const PORT = process.env.PORT ?? 3000;
const NETWORK = process.env.NETWORK === "mainnet" ? "mainnet" : "testnet";
const PAY_TO = process.env.PAY_TO!; // your merchant Stacks address
const FACILITATOR_URL = process.env.FACILITATOR_URL ?? `http://localhost:${PORT}`;
const PRICE = USDCxToMicroUSDCx(0.1); // 0.1 USDCx per request

const stacksNetwork = NETWORK === "mainnet" ? new StacksMainnet() : new StacksTestnet();

// ── App ───────────────────────────────────────────────────────────────────────

const app = express();
app.use(express.json());

// ── Facilitator endpoints ─────────────────────────────────────────────────────

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
    if (!paymentPayload?.payload?.transaction) {
      return res.json({ valid: false, error: "Missing transaction" });
    }
    if (paymentPayload.accepted?.amount !== paymentRequirements?.amount) {
      return res.json({ valid: false, error: "Amount mismatch" });
    }
    if (paymentPayload.accepted?.payTo !== paymentRequirements?.payTo) {
      return res.json({ valid: false, error: "Recipient mismatch" });
    }
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
    console.error("[settle] exception:", e);
    return res.status(500).json({ success: false, error: e?.message ?? `${e}` });
  }
});

// ── Paywalled endpoints ───────────────────────────────────────────────────────

const paywall = paymentMiddleware({
  amount: PRICE,
  asset: "USDCX",
  network: NETWORK,
  payTo: PAY_TO,
  facilitatorUrl: FACILITATOR_URL,
});

/**
 * GET /api/prices
 * Returns live STX, BTC, and ETH prices in USD + 24h change.
 * Sourced from CoinGecko public API (no key required).
 *
 * Demo narrative:
 * "The AI needed live prices, hit a 402 paywall, paid 0.1 USDCx autonomously,
 *  and returned the current STX price — no user intervention."
 */
app.get("/api/prices", paywall, async (_, res) => {
  try {
    const { data } = await axios.get(
      "https://api.coingecko.com/api/v3/simple/price",
      {
        params: {
          ids: "blockstack,bitcoin,ethereum,wrapped-stx",
          vs_currencies: "usd",
          include_24hr_change: true,
          include_market_cap: true,
        },
        timeout: 8000,
      }
    );

    const fmt = (id: string, symbol: string) => ({
      symbol,
      price_usd: data[id]?.usd ?? null,
      change_24h_pct: data[id]?.usd_24h_change?.toFixed(2) ?? null,
      market_cap_usd: data[id]?.usd_market_cap ?? null,
    });

    return res.json({
      timestamp: new Date().toISOString(),
      source: "CoinGecko",
      assets: {
        STX: fmt("blockstack", "STX"),
        BTC: fmt("bitcoin", "BTC"),
        ETH: fmt("ethereum", "ETH"),
      },
    });
  } catch (e: any) {
    return res.status(502).json({ error: "Price fetch failed", detail: e?.message });
  }
});

/**
 * GET /api/stacks-stats
 * Returns live Stacks network stats from the Hiro API.
 * Useful for the AI to answer "What's the current block height?" etc.
 */
app.get("/api/stacks-stats", paywall, async (_, res) => {
  try {
    const [infoRes, feeRes] = await Promise.all([
      axios.get("https://api.hiro.so/v2/info", { timeout: 8000 }),
      axios.get("https://api.hiro.so/v2/fees/transfer", { timeout: 8000 }),
    ]);

    const info = infoRes.data;
    const fee = feeRes.data;

    return res.json({
      timestamp: new Date().toISOString(),
      network: NETWORK,
      block_height: info.stacks_tip_height,
      burn_block_height: info.burn_block_height,
      server_version: info.server_version,
      estimated_fee_ustx: fee,
    });
  } catch (e: any) {
    return res.status(502).json({ error: "Stats fetch failed", detail: e?.message });
  }
});

// ── Health ────────────────────────────────────────────────────────────────────

app.get("/health", (_, res) => {
  res.json({ status: "ok", network: NETWORK, payTo: PAY_TO });
});

// ── Start ─────────────────────────────────────────────────────────────────────

app.listen(PORT, () => {
  console.log(`x402 server running on port ${PORT}`);
  console.log(`Network : ${NETWORK}`);
  console.log(`Pay to  : ${PAY_TO}`);
  console.log(`Price   : 0.1 USDCx per request`);
  console.log(`Endpoints:`);
  console.log(`  GET  /api/prices       — live STX/BTC/ETH prices`);
  console.log(`  GET  /api/stacks-stats — Stacks network stats`);
  console.log(`  GET  /health           — health check`);
});
