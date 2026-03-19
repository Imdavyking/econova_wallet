import express from "express";
import axios from "axios";
import { paymentMiddleware, USDCxToMicroUSDCx } from "x402-stacks";
import { StacksMainnet, StacksTestnet } from "@stacks/network";
import {
  broadcastTransaction,
  deserializeTransaction,
} from "@stacks/transactions";
import "dotenv/config";

const PORT = process.env.PORT ?? 3000;
const NETWORK = process.env.NETWORK === "mainnet" ? "mainnet" : "testnet";
const PAY_TO =
  process.env.PAY_TO ?? "ST2VRPAPFN63CWA9HZQF8TNK678JCZAX71JJJQWGS";
const FACILITATOR_URL =
  process.env.FACILITATOR_URL ?? `http://localhost:${PORT}`;
const PRICE = USDCxToMicroUSDCx(0.1);

const stacksNetwork =
  NETWORK === "mainnet" ? new StacksMainnet() : new StacksTestnet();

const app = express();
app.use(express.json());

// ── Facilitator ───────────────────────────────────────────────────

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

    console.log(
      `[settle] txid=${result.txid} payer=${paymentPayload.accepted?.from}`,
    );

    return res.json({
      success: true,
      payer: paymentPayload.accepted?.from ?? "unknown",
      transaction: result.txid,
      network:
        paymentRequirements?.network ??
        `stacks:${NETWORK === "mainnet" ? 1 : 2147483648}`,
    });
  } catch (e: any) {
    return res
      .status(500)
      .json({ success: false, error: e?.message ?? `${e}` });
  }
});

// ── Paywall ───────────────────────────────────────────────────────

const paywall = paymentMiddleware({
  amount: PRICE,
  asset: "USDCX",
  network: NETWORK,
  payTo: PAY_TO,
  facilitatorUrl: FACILITATOR_URL,
});

// GET /api/market
// Full market report: STX, BTC, ETH
// Price, 1h/24h/7d change, market cap, volume, ATH
// Demo: "Give me a full market report on STX"
app.get("/api/market", paywall, async (_, res) => {
  try {
    const { data } = await axios.get(
      "https://api.coingecko.com/api/v3/coins/markets",
      {
        params: {
          vs_currency: "usd",
          ids: "blockstack,bitcoin,ethereum",
          order: "market_cap_desc",
          sparkline: false,
          price_change_percentage: "1h,24h,7d",
        },
        timeout: 8000,
      },
    );

    const fmt = (coin: any) => ({
      symbol: coin.symbol?.toUpperCase(),
      name: coin.name,
      price_usd: coin.current_price,
      change_1h_pct:
        coin.price_change_percentage_1h_in_currency?.toFixed(2) ?? null,
      change_24h_pct:
        coin.price_change_percentage_24h_in_currency?.toFixed(2) ?? null,
      change_7d_pct:
        coin.price_change_percentage_7d_in_currency?.toFixed(2) ?? null,
      market_cap_usd: coin.market_cap,
      volume_24h_usd: coin.total_volume,
      ath_usd: coin.ath,
      ath_change_pct: coin.ath_change_percentage?.toFixed(2) ?? null,
      last_updated: coin.last_updated,
    });

    return res.json({
      timestamp: new Date().toISOString(),
      source: "CoinGecko",
      market: data.map(fmt),
    });
  } catch (e: any) {
    return res
      .status(502)
      .json({ error: "Failed to fetch market data", detail: e?.message });
  }
});

// ── Health ────────────────────────────────────────────────────────

app.get("/health", (_, res) => {
  res.json({
    status: "ok",
    network: NETWORK,
    payTo: PAY_TO,
    price: "0.1 USDCx per request",
    endpoints: ["/api/market"],
  });
});

// ── Start ─────────────────────────────────────────────────────────

app.listen(PORT, () => {
  console.log(`x402 server on port ${PORT}`);
  console.log(`Network : ${NETWORK}`);
  console.log(`Pay to  : ${PAY_TO}`);
  console.log(`Price   : 0.1 USDCx per request`);
});
