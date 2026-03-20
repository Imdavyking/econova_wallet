import axios from "axios";
import "dotenv/config";
import { wrapAxiosWithPayment, privateKeyToAccount } from "x402-stacks";

const account = privateKeyToAccount(process.env.PRIVATE_KEY!, "testnet");

const api = wrapAxiosWithPayment(
  axios.create({ baseURL: "http://localhost:3000" }),
  account,
);

const main = async () => {
  const response = await api.get("/api/premium-data");
  console.log("Response:", response.data);
  console.log(
    "Payment header sent:",
    response.config.headers?.["payment-signature"],
  );
};

main();
