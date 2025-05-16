// Helper to wait for Flutter WebView readiness and call handler
function callFlutterHandler(payload) {
  return new Promise((resolve, reject) => {
    const interval = setInterval(() => {
      if (window.isFlutterInAppWebViewReady) {
        clearInterval(interval);
        // callHandler returns a promise, so resolve with its result
        resolve(window.flutter_inappwebview.callHandler("StarknetHandler", JSON.stringify(payload)));
      }
    }, 100);

    // Optional timeout to avoid waiting forever
    setTimeout(() => {
      clearInterval(interval);
      reject(new Error("Flutter InAppWebView not ready"));
    }, 30000);
  });
}

// Helper to listen for response messages filtered by requestId
function waitForResponse(requestId, timeout = 30000) {
  return new Promise((resolve, reject) => {
    const handler = (event) => {
      try {
        const data = JSON.parse(event.data);
        if (data?.requestId === requestId) {
          window.removeEventListener("message", handler);
          clearTimeout(timeoutId);
          resolve(data.response);
        }
      } catch {
        throw new Error("Invalid message format");
      }
    };
    window.addEventListener("message", handler);

    const timeoutId = setTimeout(() => {
      window.removeEventListener("message", handler);
      reject(new Error("Request timed out"));
    }, timeout);
  });
}

window.starknet = {
  id: "argentX",
  name: "Argent X",
  icon: "data:image/svg+xml;base64,Cjxzdmcgd2lkdGg9IjQwIiBoZWlnaHQ9IjM2IiB2aWV3Qm94PSIwIDAgNDAgMzYiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxwYXRoIGQ9Ik0yNC43NTgyIC0zLjk3MzY0ZS0wN0gxNC42MjM4QzE0LjI4NTEgLTMuOTczNjRlLTA3IDE0LjAxMzggMC4yODExNzggMTQuMDA2NCAwLjYzMDY4M0MxMy44MDE3IDEwLjQ1NDkgOC44MjIzNCAxOS43NzkyIDAuMjUxODkzIDI2LjM4MzdDLTAuMDIwMjA0NiAyNi41OTMzIC0wLjA4MjE5NDYgMjYuOTg3MiAwLjExNjczNCAyNy4yNzA5TDYuMDQ2MjMgMzUuNzM0QzYuMjQ3OTYgMzYuMDIyIDYuNjQwOTkgMzYuMDg3IDYuOTE3NjYgMzUuODc1NEMxMi4yNzY1IDMxLjc3MjggMTYuNTg2OSAyNi44MjM2IDE5LjY5MSAyMS4zMzhDMjIuNzk1MSAyNi44MjM2IDI3LjEwNTcgMzEuNzcyOCAzMi40NjQ2IDM1Ljg3NTRDMzIuNzQxIDM2LjA4NyAzMy4xMzQxIDM2LjAyMiAzMy4zMzYxIDM1LjczNEwzOS4yNjU2IDI3LjI3MDlDMzkuNDY0MiAyNi45ODcyIDM5LjQwMjIgMjYuNTkzMyAzOS4xMzA0IDI2LjM4MzdDMzAuNTU5NyAxOS43NzkyIDI1LjU4MDQgMTAuNDU0OSAyNS4zNzU5IDAuNjMwNjgzQzI1LjM2ODUgMC4yODExNzggMjUuMDk2OSAtMy45NzM2NGUtMDcgMjQuNzU4MiAtMy45NzM2NGUtMDdaIiBmaWxsPSIjRkY4NzVCIi8+Cjwvc3ZnPgo=",

  request: (args) => {
    const requestId = Math.random().toString(36).substr(2, 9);

    // Send request to Flutter and wait for response message with requestId
    return callFlutterHandler({
      type: "request",
      requestId,
      args,
      url: window.location.origin,
    }).then(() => waitForResponse(requestId));
  },

  enable: async () => {
    return callFlutterHandler({
      type: "enable",
      url: window.location.origin,
    });
  },

  isPreauthorized: async () => {
    return callFlutterHandler({
      type: "isPreauthorized",
      url: window.location.origin,
    });
  },

  on: (event, handler) => {
    callFlutterHandler({
      type: "on",
      event,
      url: window.location.origin,
    });

    window._starknetHandlers = window._starknetHandlers || {};
    window._starknetHandlers[event] = handler;
  },

  off: (event) => {
    callFlutterHandler({
      type: "off",
      event,
      url: window.location.origin,
    });

    if (window._starknetHandlers) delete window._starknetHandlers[event];
  },
};
