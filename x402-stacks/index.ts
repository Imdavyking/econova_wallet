import express from "express";
import axios from "axios";
import {
  paymentMiddleware,
  USDCxToMicroUSDCx,
  wrapAxiosWithPayment,
  privateKeyToAccount,
} from "x402-stacks";
import { StacksTestnet } from "@stacks/network";
import {
  broadcastTransaction,
  deserializeTransaction,
} from "@stacks/transactions";
import "dotenv/config";
// ── Server + Facilitator ──────────────────────────────────────────────────────

const server = express();
server.use(express.json());

// GET /supported
server.get("/supported", (_, res) => {
  res.json({
    kinds: [
      { x402Version: 2, scheme: "exact", network: "stacks:1" },
      { x402Version: 2, scheme: "exact", network: "stacks:2147483648" },
    ],
    extensions: [],
    signers: {},
  });
});

// POST /verify
server.post("/verify", (req, res) => {
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

// POST /settle
server.post("/settle", async (req, res) => {
  const { paymentPayload, paymentRequirements } = req.body;
  try {
    console.log("settle request:", JSON.stringify(req.body, null, 2));

    const txHex = paymentPayload.payload.transaction.replace("0x", "");
    const network = new StacksTestnet();

    const tx = deserializeTransaction(txHex);
    const result = await broadcastTransaction(tx, network);

    console.log("broadcast result:", JSON.stringify(result, null, 2));

    if ("error" in result) {
      console.error("broadcast rejected:", result);
      return res.status(400).json({
        success: false,
        error: result.error,
        reason: (result as any).reason,
        reason_data: (result as any).reason_data,
        txid: (result as any).txid,
      });
    }

    return res.json({
      success: true,
      payer: paymentPayload.accepted?.from ?? "unknown",
      transaction: result.txid,
      network: paymentRequirements?.network ?? "stacks:2147483648",
    });
  } catch (e: any) {
    console.error("settle exception:", e);
    return res.status(500).json({
      success: false,
      error: e?.message ?? `${e}`,
      stack: e?.stack,
    });
  }
});
// GET /api/premium-data
server.get(
  "/api/premium-data",
  paymentMiddleware({
    amount: USDCxToMicroUSDCx(1),
    asset: "USDCX",
    network: "testnet",
    payTo: "ST2VRPAPFN63CWA9HZQF8TNK678JCZAX71JJJQWGS",
    facilitatorUrl: "http://localhost:3000",
  }),
  (_, res) => {
    res.json({ data: "This is premium content" });
  },
);

server.listen(3000, () =>
  console.log("Server + Facilitator running on port 3000"),
);

// ── Client ────────────────────────────────────────────────────────────────────

const client = express();
client.use(express.json());

client.get("/pay-and-fetch", async (_, res) => {
  try {
    const privateKey = process.env.PRIVATE_KEY;
    if (!privateKey) {
      return res.status(500).json({ error: "PRIVATE_KEY not set in env" });
    }

    const account = privateKeyToAccount(privateKey, "testnet");
    const base = axios.create({ baseURL: "http://localhost:3000" });
    const api = wrapAxiosWithPayment(base, account);

    const response = await base.get("/api/premium-data");

    return res.json({
      data: response.data,
      paymentResponse: response.headers["payment-response"] ?? null,
    });
  } catch (e: any) {
    console.error("pay-and-fetch error:", e);
    return res.status(500).json({ error: e?.message ?? `${e}` });
  }
});

client.listen(3001, () => console.log("Client running on port 3001"));
