window.starknet = {
  id: "argentX",
  name: "Argent X",
  eventName: "starknet-contentScript",
  icon: "data:image/svg+xml;base64,Cjxzdmcgd2lkdGg9IjQwIiBoZWlnaHQ9IjM2IiB2aWV3Qm94PSIwIDAgNDAgMzYiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxwYXRoIGQ9Ik0yNC43NTgyIC0zLjk3MzY0ZS0wN0gxNC42MjM4QzE0LjI4NTEgLTMuOTczNjRlLTA3IDE0LjAxMzggMC4yODExNzggMTQuMDA2NCAwLjYzMDY4M0MxMy44MDE3IDEwLjQ1NDkgOC44MjIzNCAxOS43NzkyIDAuMjUxODkzIDI2LjM4MzdDLTAuMDIwMjA0NiAyNi41OTMzIC0wLjA4MjE5NDYgMjYuOTg3MiAwLjExNjczNCAyNy4yNzA5TDYuMDQ2MjMgMzUuNzM0QzYuMjQ3OTYgMzYuMDIyIDYuNjQwOTkgMzYuMDg3IDYuOTE3NjYgMzUuODc1NEMxMi4yNzY1IDMxLjc3MjggMTYuNTg2OSAyNi44MjM2IDE5LjY5MSAyMS4zMzhDMjIuNzk1MSAyNi44MjM2IDI3LjEwNTcgMzEuNzcyOCAzMi40NjQ2IDM1Ljg3NTRDMzIuNzQxIDM2LjA4NyAzMy4xMzQxIDM2LjAyMiAzMy4zMzYxIDM1LjczNEwzOS4yNjU2IDI3LjI3MDlDMzkuNDY0MiAyNi45ODcyIDM5LjQwMjIgMjYuNTkzMyAzOS4xMzA0IDI2LjM4MzdDMzAuNTU5NyAxOS43NzkyIDI1LjU4MDQgMTAuNDU0OSAyNS4zNzU5IDAuNjMwNjgzQzI1LjM2ODUgMC4yODExNzggMjUuMDk2OSAtMy45NzM2NGUtMDcgMjQuNzU4MiAtMy45NzM2NGUtMDdaIiBmaWxsPSIjRkY4NzVCIi8+Cjwvc3ZnPgo=",
  request: (args) => {
    const requestId = Math.random().toString(36).substr(2, 9);

    return window.starknet
      .callFlutterHandler({
        type: "request",
        requestId,
        args,
        url: window.location.origin,
      })
      .then(() => {
        return window.starknet.waitForResponse(requestId);
      });
  },

  callFlutterHandler: (payload) => {
    return new Promise((resolve, reject) => {
      const interval = setInterval(() => {
        if (isFlutterInAppWebViewReady) {
          resolve();
          clearInterval(interval);
          window.flutter_inappwebview.callHandler(
            "StarknetHandler",
            JSON.stringify(payload)
          );
        }
      }, 100);
    });
  },

  waitForResponse: (requestId) => {
    console.log("waiting for response", requestId);
    return new Promise((resolve, reject) => {
      const handler = (event) => {
        try {
          const data = event.detail;
          if (typeof data.error !== "undefined") {
            reject(new Error(data.error));
            return;
          }
          const requestType = data.requestType;
          const chainId = data.chainId;
          const address = data.address;
          switch (requestType) {
            case "wallet_requestAccounts":
              starknet.selectedAddress = address;
              starknet.chainId = data.chainId;
              starknet.isConnected = true;
              resolve([address]);
              break;
            case "wallet_requestChainId":
              resolve(chainId);
              break;
            case "wallet_addInvokeTransaction":
              const txHash = data.txHash;
              console.log("txHash", txHash);
              resolve({
                transaction_hash: txHash,
              });
              break;
            case "wallet_getPermissions":
              const permissions = data.permissions;
              console.log("permissions", permissions);
              resolve(permissions);
              break;
            case "wallet_supportedSpecs":
              const specs = data.specs;
              console.log("specs", specs);
              resolve(specs);
              break;
            case "wallet_addDeclareTransaction":
              const declareTx = data.txHash;
              const classHash = data.classHash;
              console.log("txHash", txHash);
              resolve({
                transaction_hash: declareTx,
                class_hash: classHash,
              });
              break;
            case "wallet_signTypedData":
              const signature = data.signature;
              console.log("signature", signature);
              resolve(signature);
              break;
            default:
              reject(new Error("Invalid request type " + requestType));
              break;
          }
        } catch (err) {
          console.error("error gotten", err);
          reject(new Error(err.toString()));
        } finally {
          window.removeEventListener(requestId, handler);
        }
      };

      window.addEventListener(requestId, handler);
    });
  },

  sendResponse: (requestId, payload) => {
    const customEvent = new CustomEvent(requestId, {
      detail: payload,
    });
    window.dispatchEvent(customEvent);
  },

  enable: () => {
    console.warn(
      "Warning: `enable()` is deprecated and may be removed in future versions. Please use `request({ type: 'wallet_requestAccounts' })` directly."
    );
    return window.starknet.request({
      type: "wallet_requestAccounts",
    });
  },

  isPreauthorized: () => {
    return false;
  },
  on: (event, handler) => {
    window.starknet.callFlutterHandler({
      type: "on",
      event,
      url: window.location.origin,
    });

    window._starknetHandlers = window._starknetHandlers || {};
    window._starknetHandlers[event] = handler;
  },

  off: (event) => {
    window.starknet.callFlutterHandler({
      type: "off",
      event,
      url: window.location.origin,
    });

    if (window._starknetHandlers) {
      delete window._starknetHandlers[event];
    }
  },
};

window.starknet_argentX = window.starknet;
