(function () {
  const config = {
    ethereum: {
      chainId: 1,
      rpcUrl: "https://mainnet.infura.io/v3/53163c736f1d4ba78f0a39ffda8d87b4",
      address: "0x7fBfB631D9719A92e5D833B10973e52DA8985A7B",
    },
    solana: {
       cluster: "https://api.mainnet-beta.solana.com",
    },
    aptos: {
      network: "Mainnet",
      chainId: "1",
    },
  };

  const strategy = "CALLBACK";

  try {
    const core = trustwallet.core(strategy, (params) => {
      // Disabled methods
      if (params.name === "wallet_requestPermissions") {
        core.sendResponse(params.id, null);
        return;
      }

      

      webkit.messageHandlers._tw_.postMessage(params);
    });

    console.log("Core initialized", core);

    // Generate instances
    const ethereum = trustwallet.ethereum(config.ethereum);
    console.log("Ethereum provider initialized", ethereum);
    const solana = trustwallet.solana(config.solana);
    console.log("Solana provider initialized", solana);
    const cosmos = trustwallet.cosmos();
    console.log("Cosmos provider initialized", cosmos);
    const aptos = trustwallet.aptos(config.aptos);
    console.log("Aptos provider initialized", aptos);
    const ton = trustwallet.ton();
    console.log("Ton provider initialized", ton);

    console.log("Providers initialized");

    const walletInfo = {
      deviceInfo: {
        platform: "iphone",
        appName: "trustwalletTon",
        appVersion: "2",
        maxProtocolVersion: 2,
        features: [
          "SendTransaction",
          {
            name: "SendTransaction",
            maxMessages: 4,
          },
        ],
      },
      walletInfo: {
        name: "Trust",
        image: "https://assets-cdn.trustwallet.com/dapps/trust.logo.png",
        about_url: "https://trustwallet.com/about-us",
      },
      isWalletBrowser: true,
    };

    console.log("Wallet info", walletInfo);

    const tonBridge = trustwallet.tonBridge(walletInfo, ton);

    core.registerProviders(
      [ethereum, solana, cosmos, aptos, ton].map((provider) => {
        provider.sendResponse = core.sendResponse.bind(core);
        provider.sendError = core.sendError.bind(core);
        return provider;
      })
    );

    window.trustwalletTon = { tonconnect: tonBridge, provider: ton };

    console.log("Providers registered");

    // Custom methods
    ethereum.emitChainChanged = (chainId) => {
      ethereum.setChainId("0x" + parseInt(chainId || "1").toString(16));
      ethereum.emit("chainChanged", ethereum.getChainId());
      ethereum.emit("networkChanged", parseInt(chainId || "1"));
    };

    ethereum.setConfig = (config) => {
      ethereum.setChainId(
        "0x" + parseInt(config.ethereum.chainId || "1").toString(16)
      );
      ethereum.setAddress(config.ethereum.address);
      if (config.ethereum.rpcUrl) {
        ethereum.setRPCUrl(config.ethereum.rpcUrl);
      }
    };

    console.log("Custom methods set");
    // End custom methods

    cosmos.mode = "extension";
    cosmos.providerNetwork = "cosmos";
    cosmos.isKeplr = true;
    cosmos.version = "0.12.106";

    // Attach to window
    trustwallet.ethereum = ethereum;
    trustwallet.solana = solana;
    trustwallet.cosmos = cosmos;
    trustwallet.TrustCosmos = trustwallet.cosmos;
    trustwallet.aptos = aptos;
    trustwallet.ton = ton;
    
    console.log("Providers attached to window");
    window.ethereum = trustwallet.ethereum;
    window.keplr = trustwallet.cosmos;
    window.aptos = trustwallet.aptos;
    window.ton = trustwallet.ton;

    console.log("Window properties set");

    const getDefaultCosmosProvider = (chainId) => {
      return trustwallet.cosmos.getOfflineSigner(chainId);
    };

    window.getOfflineSigner = getDefaultCosmosProvider;
    window.getOfflineSignerOnlyAmino = getDefaultCosmosProvider;
    window.getOfflineSignerAuto = getDefaultCosmosProvider;

    console.log("Cosmos provider set"); 

    Object.assign(window.trustwallet, {
      isTrust: true,
      isTrustWallet: true,
      request: ethereum.request.bind(ethereum),
      send: ethereum.send.bind(ethereum),
      on: (...params) => ethereum.on(...params),
      off: (...params) => ethereum.off(...params),
    });

    const provider = ethereum;
    const proxyMethods = [
      "chainId",
      "networkVersion",
      "address",
      "enable",
      "send",
    ];

    // Attach properties to trustwallet object (legacy props)
    const proxy = new Proxy(window.trustwallet, {
      get(target, prop, receiver) {
        if (proxyMethods.includes(prop)) {
          switch (prop) {
            case "chainId":
              return ethereum.getChainId.bind(provider);
            case "networkVersion":
              return ethereum.getNetworkVersion.bind(provider);
            case "address":
              return ethereum.getAddress.bind(provider);
            case "enable":
              return ethereum.enable.bind(provider);
            case "send":
              return ethereum.send.bind(provider);
          }
        }

        return Reflect.get(target, prop, receiver);
      },
    });

    window.trustwallet = proxy;
    window.trustWallet = proxy;

    const EIP6963Icon =
      "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNTgiIGhlaWdodD0iNjUiIHZpZXdCb3g9IjAgMCA1OCA2NSIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTAgOS4zODk0OUwyOC44OTA3IDBWNjUuMDA0MkM4LjI1NDUgNTYuMzM2OSAwIDM5LjcyNDggMCAzMC4zMzUzVjkuMzg5NDlaIiBmaWxsPSIjMDUwMEZGIi8+CjxwYXRoIGQ9Ik01Ny43ODIyIDkuMzg5NDlMMjguODkxNSAwVjY1LjAwNDJDNDkuNTI3NyA1Ni4zMzY5IDU3Ljc4MjIgMzkuNzI0OCA1Ny43ODIyIDMwLjMzNTNWOS4zODk0OVoiIGZpbGw9InVybCgjcGFpbnQwX2xpbmVhcl8yMjAxXzY5NDIpIi8+CjxkZWZzPgo8bGluZWFyR3JhZGllbnQgaWQ9InBhaW50MF9saW5lYXJfMjIwMV82OTQyIiB4MT0iNTEuMzYxNSIgeTE9Ii00LjE1MjkzIiB4Mj0iMjkuNTM4NCIgeTI9IjY0LjUxNDciIGdyYWRpZW50VW5pdHM9InVzZXJTcGFjZU9uVXNlIj4KPHN0b3Agb2Zmc2V0PSIwLjAyMTEyIiBzdG9wLWNvbG9yPSIjMDAwMEZGIi8+CjxzdG9wIG9mZnNldD0iMC4wNzYyNDIzIiBzdG9wLWNvbG9yPSIjMDA5NEZGIi8+CjxzdG9wIG9mZnNldD0iMC4xNjMwODkiIHN0b3AtY29sb3I9IiM0OEZGOTEiLz4KPHN0b3Agb2Zmc2V0PSIwLjQyMDA0OSIgc3RvcC1jb2xvcj0iIzAwOTRGRiIvPgo8c3RvcCBvZmZzZXQ9IjAuNjgyODg2IiBzdG9wLWNvbG9yPSIjMDAzOEZGIi8+CjxzdG9wIG9mZnNldD0iMC45MDI0NjUiIHN0b3AtY29sb3I9IiMwNTAwRkYiLz4KPC9saW5lYXJHcmFkaWVudD4KPC9kZWZzPgo8L3N2Zz4K";

    const info = {
      uuid: crypto.randomUUID(),
      name: "Trust Wallet",
      icon: EIP6963Icon,
      rdns: "com.trustwallet.app",
    };

    const announceEvent = new CustomEvent("eip6963:announceProvider", {
      detail: Object.freeze({ info, provider: ethereum }),
    });

    window.dispatchEvent(announceEvent);

    window.addEventListener("eip6963:requestProvider", () => {
      window.dispatchEvent(announceEvent);
    });
  } catch (e) {
    console.error(e);
  }
})();
