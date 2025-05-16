
 window.starknet = {
  id: "argentX",
  name: "Argent X",
  eventName: "starknet-contentScript",
  icon: "data:image/svg+xml;base64,Cjxzdmcgd2lkdGg9IjQwIiBoZWlnaHQ9IjM2IiB2aWV3Qm94PSIwIDAgNDAgMzYiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxwYXRoIGQ9Ik0yNC43NTgyIC0zLjk3MzY0ZS0wN0gxNC42MjM4QzE0LjI4NTEgLTMuOTczNjRlLTA3IDE0LjAxMzggMC4yODExNzggMTQuMDA2NCAwLjYzMDY4M0MxMy44MDE3IDEwLjQ1NDkgOC44MjIzNCAxOS43NzkyIDAuMjUxODkzIDI2LjM4MzdDLTAuMDIwMjA0NiAyNi41OTMzIC0wLjA4MjE5NDYgMjYuOTg3MiAwLjExNjczNCAyNy4yNzA5TDYuMDQ2MjMgMzUuNzM0QzYuMjQ3OTYgMzYuMDIyIDYuNjQwOTkgMzYuMDg3IDYuOTE3NjYgMzUuODc1NEMxMi4yNzY1IDMxLjc3MjggMTYuNTg2OSAyNi44MjM2IDE5LjY5MSAyMS4zMzhDMjIuNzk1MSAyNi44MjM2IDI3LjEwNTcgMzEuNzcyOCAzMi40NjQ2IDM1Ljg3NTRDMzIuNzQxIDM2LjA4NyAzMy4xMzQxIDM2LjAyMiAzMy4zMzYxIDM1LjczNEwzOS4yNjU2IDI3LjI3MDlDMzkuNDY0MiAyNi45ODcyIDM5LjQwMjIgMjYuNTkzMyAzOS4xMzA0IDI2LjM4MzdDMzAuNTU5NyAxOS43NzkyIDI1LjU4MDQgMTAuNDU0OSAyNS4zNzU5IDAuNjMwNjgzQzI1LjM2ODUgMC4yODExNzggMjUuMDk2OSAtMy45NzM2NGUtMDcgMjQuNzU4MiAtMy45NzM2NGUtMDdaIiBmaWxsPSIjRkY4NzVCIi8+Cjwvc3ZnPgo=",
  request: (args) => {
    const requestId = Math.random().toString(36).substr(2, 9);

    console.log("requesting", requestId);

    return window.starknet
      .callFlutterHandler({
        type: "request",
        requestId,
        args,
        url: window.location.origin,
      })
      .then(() => {
        console.log("request sent with requestId", requestId);
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

  waitForResponse: (requestId, timeout = 30000) => {
    console.log("waiting for response", requestId);
    return new Promise((resolve, reject) => {
      const handler = (event) => {
        try {
          const data = event.detail;
          const response = data.response;
          const chainId = data.chainId;
          window.removeEventListener(requestId, handler);
          clearTimeout(timeoutId);
          starknet.selectedAddress = address
          starknet.chainId = network.chainId
          starknet.isConnected = true
          resolve([address]);
        } catch (err) {
          console.error("Invalid message format", err);
          reject(new Error(err.toString()));
        }
      };

      window.addEventListener(requestId, handler);
      console.log("added event listener", requestId);
      const timeoutId = setTimeout(() => {
        window.removeEventListener(requestId, handler);
        reject(new Error("Request timed out"));
      }, timeout);
    });
  },

  sendResponse: (requestId, payload) => {
    console.log("sending payload", payload);
    const customEvent = new CustomEvent(requestId, {
      detail: payload,
    });
    window.dispatchEvent(customEvent);
    console.log("sent payload", customEvent);
  },

  enable: () => {
    return window.starknet.callFlutterHandler({
      type: "enable",
      url: window.location.origin,
    });
  },

  isPreauthorized: () => {
    return window.starknet.callFlutterHandler({
      type: "isPreauthorized",
      url: window.location.origin,
    });
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