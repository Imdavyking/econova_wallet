import { StrictMode } from "react";
import { createRoot, type Container } from "react-dom/client";
import "./index.css";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import client from "./services/apollo.services";
import { ApolloProvider } from "@apollo/client";
import App from "./App.js";

import { StellarProvider } from "./providers/StellarProvider";
const queryClient = new QueryClient();

createRoot(document.getElementById("root") as Container).render(
  <StrictMode>
    <ApolloProvider client={client}>
      <QueryClientProvider client={queryClient}>
        <StellarProvider>
          <App />
        </StellarProvider>
      </QueryClientProvider>
    </ApolloProvider>
  </StrictMode>,
);
