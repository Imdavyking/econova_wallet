import 'package:flutter/material.dart';

import '../coins/ethereum_coin.dart';
import '../main.dart';
import '../screens/dapp.dart';
import '../service/wallet_service.dart';
import 'app_config.dart';
import 'rpc_urls.dart';

Future<String> setupWebViewWalletBridge(int chainId, String rpc) async {
  await pref.put(dappChainIdKey, chainId);
  final data = WalletService.getActiveKey(walletImportType)!.data;
  final coin = evmFromChainId(chainId)!;
  final response = await coin.importData(data);
  final address = response.address;

  final twProvider = """
        (function() {
            const config = {
                ethereum: {
                    chainId: $chainId,
                    rpcUrl: "$rpc",  
                    address: "$address"
                },
                solana: {
                     cluster: "${solanaChains.first.rpc}",
                     useLegacySign: true
                },
                aptos: {
                   network: "network",
                   chainId: "chainId"
                }
            };

            const strategy = 'CALLBACK';

            try {
                const core = trustwallet.core(strategy, (params) => {
                    if (params.name === 'wallet_requestPermissions') {
                        core.sendResponse(params.id, null);
                        return;
                    }
                    const interval = setInterval(() => {
                      if (isFlutterInAppWebViewReady) {
                        clearInterval(interval);
                        window.flutter_inappwebview.callHandler(
                          "CryptoHandler",
                          JSON.stringify({ ...params, url: window.location.origin })
                        );
                      }
                    }, 100);
                });

                const ethereum = trustwallet.ethereum(config.ethereum);
                const solana = trustwallet.solana(config.solana);
                const cosmos = trustwallet.cosmos();
                const aptos = trustwallet.aptos(config.aptos);
                const ton = trustwallet.ton();

                const walletInfo = {
                  deviceInfo: {
                    platform: 'iphone',
                    appName: 'trustwalletTon',
                    appVersion: "2",
                    maxProtocolVersion: 2,
                    features: ['SendTransaction', { name: 'SendTransaction', maxMessages: 4 }],
                  },
                  walletInfo: {
                    name: 'Trust',
                    image: 'https://assets-cdn.trustwallet.com/dapps/trust.logo.png',
                    about_url: 'https://trustwallet.com/about-us',
                  },
                  isWalletBrowser: true,
                };

                const tonBridge = trustwallet.tonBridge(walletInfo, ton);

                core.registerProviders([ethereum, solana, cosmos, aptos, ton].map(provider => {
                  provider.sendResponse = core.sendResponse.bind(core);
                  provider.sendError = core.sendError.bind(core);
                  return provider;
                }));

                window.trustwalletTon = { tonconnect: tonBridge, provider: ton };

                ethereum.emitChainChanged = (chainId) => {
                  ethereum.setChainId('0x' + parseInt(chainId || '1').toString(16));
                  ethereum.emit('chainChanged', ethereum.getChainId());
                  ethereum.emit('networkChanged', parseInt(chainId || '1'));
                };

                ethereum.setConfig = (config) => {
                  ethereum.setChainId('0x' + parseInt(config.ethereum.chainId || '1').toString(16));
                  ethereum.setAddress(config.ethereum.address);
                  if (config.ethereum.rpcUrl) ethereum.setRPCUrl(config.ethereum.rpcUrl);
                };

                cosmos.mode = 'extension';
                cosmos.providerNetwork = 'cosmos';
                cosmos.isKeplr = true;
                cosmos.version = "0.12.106";

                trustwallet.ethereum = ethereum;
                trustwallet.solana = solana;
                trustwallet.cosmos = cosmos;
                trustwallet.TrustCosmos = trustwallet.cosmos;
                trustwallet.aptos = aptos;
                trustwallet.ton = ton;

                window.ethereum = trustwallet.ethereum;
                window.keplr = trustwallet.cosmos;
                window.aptos = trustwallet.aptos;
                window.ton = trustwallet.ton;
                window.solana = trustwallet.solana;

                const getDefaultCosmosProvider = (chainId) =>
                  trustwallet.cosmos.getOfflineSigner(chainId);
                window.getOfflineSigner = getDefaultCosmosProvider;
                window.getOfflineSignerOnlyAmino = getDefaultCosmosProvider;
                window.getOfflineSignerAuto = getDefaultCosmosProvider;

                Object.assign(window.trustwallet, {
                  isTrust: true,
                  isTrustWallet: true,
                  request: ethereum.request.bind(ethereum),
                  send: ethereum.send.bind(ethereum),
                  on: (...params) => ethereum.on(...params),
                  off: (...params) => ethereum.off(...params),
                });

                const provider = ethereum;
                const proxyMethods = ['chainId', 'networkVersion', 'address', 'enable', 'send'];
                const proxy = new Proxy(window.trustwallet, {
                  get(target, prop, receiver) {
                    if (proxyMethods.includes(prop)) {
                      switch (prop) {
                        case 'chainId': return ethereum.getChainId.bind(provider);
                        case 'networkVersion': return ethereum.getNetworkVersion.bind(provider);
                        case 'address': return ethereum.getAddress.bind(provider);
                        case 'enable': return ethereum.enable.bind(provider);
                        case 'send': return ethereum.send.bind(provider);
                      }
                    }
                    return Reflect.get(target, prop, receiver);
                  },
                });

                window.trustwallet = proxy;
                window.trustWallet = proxy;

                const EIP6963Icon = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNTgiIGhlaWdodD0iNjUiIHZpZXdCb3g9IjAgMCA1OCA2NSIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTAgOS4zODk0OUwyOC44OTA3IDBWNjUuMDA0MkM4LjI1NDUgNTYuMzM2OSAwIDM5LjcyNDggMCAzMC4zMzUzVjkuMzg5NDlaIiBmaWxsPSIjMDUwMEZGIi8+CjxwYXRoIGQ9Ik01Ny43ODIyIDkuMzg5NDlMMjguODkxNSAwVjY1LjAwNDJDNDkuNTI3NyA1Ni4zMzY5IDU3Ljc4MjIgMzkuNzI0OCA1Ny43ODIyIDMwLjMzNTNWOS4zODk0OVoiIGZpbGw9InVybCgjcGFpbnQwX2xpbmVhcl8yMjAxXzY5NDIpIi8+CjxkZWZzPgo8bGluZWFyR3JhZGllbnQgaWQ9InBhaW50MF9saW5lYXJfMjIwMV82OTQyIiB4MT0iNTEuMzYxNSIgeTE9Ii00LjE1MjkzIiB4Mj0iMjkuNTM4NCIgeTI9IjY0LjUxNDciIGdyYWRpZW50VW5pdHM9InVzZXJTcGFjZU9uVXNlIj4KPHN0b3Agb2Zmc2V0PSIwLjAyMTEyIiBzdG9wLWNvbG9yPSIjMDAwMEZGIi8+CjxzdG9wIG9mZnNldD0iMC4wNzYyNDIzIiBzdG9wLWNvbG9yPSIjMDA5NEZGIi8+CjxzdG9wIG9mZnNldD0iMC4xNjMwODkiIHN0b3AtY29sb3I9IiM0OEZGOTEiLz4KPHN0b3Agb2Zmc2V0PSIwLjQyMDA0OSIgc3RvcC1jb2xvcj0iIzAwOTRGRiIvPgo8c3RvcCBvZmZzZXQ9IjAuNjgyODg2IiBzdG9wLWNvbG9yPSIjMDAzOEZGIi8+CjxzdG9wIG9mZnNldD0iMC45MDI0NjUiIHN0b3AtY29sb3I9IiMwNTAwRkYiLz4KPC9saW5lYXJHcmFkaWVudD4KPC9kZWZzPgo8L3N2Zz4K';
                const info = {
                  uuid: crypto.randomUUID(),
                  name: 'Trust Wallet',
                  icon: EIP6963Icon,
                  rdns: 'com.trustwallet.app',
                };
                const announceEvent = new CustomEvent('eip6963:announceProvider', {
                  detail: Object.freeze({ info, provider: ethereum }),
                });
                window.dispatchEvent(announceEvent);
                window.addEventListener('eip6963:requestProvider', () => {
                  window.dispatchEvent(announceEvent);
                });
            } catch (e) {
              console.error(e)
            }
        })();
        """;

  return '''
   (function() {
    let isFlutterInAppWebViewReady = false;
    window.addEventListener("flutterInAppWebViewPlatformReady", function (event) {
      isFlutterInAppWebViewReady = true;
      console.log("done and ready");
    });

    $twProvider

    nightly.postMessage = (json) => {
      const interval = setInterval(() => {
        if (isFlutterInAppWebViewReady) {
          clearInterval(interval);
          window.flutter_inappwebview.callHandler(
            "NightyHandler",
            JSON.stringify({...json,'url': window.location.origin})
          );
        }
      }, 100);
    }

    window.nightly = nightly;

    window.addEventListener("message", function (e) {
      if(e.data.target !== "erdw-inpage") return;
      const interval = setInterval(() => {
        if (isFlutterInAppWebViewReady) {
          clearInterval(interval);
          window.flutter_inappwebview.callHandler(
            "Multiversx",
            JSON.stringify({...e.data,'url': e.origin})
          );
        }
      }, 100);
    });

    window.elrondWallet = {'extensionId':"dngmlblcodfobpdpecaadgfbcggfjfnm"};

    window.starknet = {
      id: "argentX",
      name: "Argent X",
      eventName: "starknet-contentScript",
      icon: "data:image/svg+xml;base64,Cjxzdmcgd2lkdGg9IjQwIiBoZWlnaHQ9IjM2IiB2aWV3Qm94PSIwIDAgNDAgMzYiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxwYXRoIGQ9Ik0yNC43NTgyIC0zLjk3MzY0ZS0wN0gxNC42MjM4QzE0LjI4NTEgLTMuOTczNjRlLTA3IDE0LjAxMzggMC4yODExNzggMTQuMDA2NCAwLjYzMDY4M0MxMy44MDE3IDEwLjQ1NDkgOC44MjIzNCAxOS43NzkyIDAuMjUxODkzIDI2LjM4MzdDLTAuMDIwMjA0NiAyNi41OTMzIC0wLjA4MjE5NDYgMjYuOTg3MiAwLjExNjczNCAyNy4yNzA5TDYuMDQ2MjMgMzUuNzM0QzYuMjQ3OTYgMzYuMDIyIDYuNjQwOTkgMzYuMDg3IDYuOTE3NjYgMzUuODc1NEMxMi4yNzY1IDMxLjc3MjggMTYuNTg2OSAyNi44MjM2IDE5LjY5MSAyMS4zMzhDMjIuNzk1MSAyNi44MjM2IDI3LjEwNTcgMzEuNzcyOCAzMi40NjQ2IDM1Ljg3NTRDMzIuNzQxIDM2LjA4NyAzMy4xMzQxIDM2LjAyMiAzMy4zMzYxIDM1LjczNEwzOS4yNjU2IDI3LjI3MDlDMzkuNDY0MiAyNi45ODcyIDM5LjQwMjIgMjYuNTkzMyAzOS4xMzA0IDI2LjM4MzdDMzAuNTU5NyAxOS43NzkyIDI1LjU4MDQgMTAuNDU0OSAyNS4zNzU5IDAuNjMwNjgzQzI1LjM2ODUgMC4yODExNzggMjUuMDk2OSAtMy45NzM2NGUtMDcgMjQuNzU4MiAtMy45NzM2NGUtMDdaIiBmaWxsPSIjRkY4NzVCIi8+Cjwvc3ZnPgo=",
      request: (args) => {
        const requestId = Math.random().toString(36).substr(2, 9);
        return window.starknet.callFlutterHandler({ type: "request", requestId, args, url: window.location.origin })
          .then(() => window.starknet.waitForResponse(requestId));
      },
      callFlutterHandler: (payload) => new Promise((resolve, reject) => {
        const interval = setInterval(() => {
          if (isFlutterInAppWebViewReady) {
            resolve();
            clearInterval(interval);
            window.flutter_inappwebview.callHandler("StarknetHandler", JSON.stringify(payload));
          }
        }, 100);
      }),
      waitForResponse: (requestId) => new Promise((resolve, reject) => {
        const handler = (event) => {
          try {
            const data = event.detail;
            if(typeof data.error !== 'undefined'){ reject(new Error(data.error)); return; }
            const { requestType, chainId, address } = data;
            switch(requestType){
              case 'wallet_requestAccounts':
                starknet.selectedAddress = address; starknet.chainId = chainId; starknet.isConnected = true;
                resolve([address]); break;
              case 'wallet_requestChainId': resolve(chainId); break;
              case 'wallet_deploymentData': resolve(data); break;
              case 'wallet_addInvokeTransaction': resolve({ transaction_hash: data.txHash }); break;
              case 'wallet_getPermissions': resolve(data.permissions); break;
              case 'wallet_supportedSpecs': resolve(data.specs); break;
              case 'wallet_addDeclareTransaction': resolve({ transaction_hash: data.txHash, class_hash: data.classHash }); break;
              case 'wallet_signTypedData': resolve(data.signature); break;
              default: reject(new Error("Invalid request type "+ requestType)); break;
            }
          } catch (err) { reject(new Error(err.toString())); }
          finally { window.removeEventListener(requestId, handler); }
        };
        window.addEventListener(requestId, handler);
      }),
      sendResponse: (requestId, payload) => {
        window.dispatchEvent(new CustomEvent(requestId, { detail: payload }));
      },
      enable: () => {
        console.warn("Warning: enable() is deprecated. Use request({ type: 'wallet_requestAccounts' }) directly.");
        return window.starknet.request({ type: "wallet_requestAccounts" });
      },
      isPreauthorized: () => false,
      on: (event, handler) => {
        window.starknet.callFlutterHandler({ type: "on", event, url: window.location.origin });
        window._starknetHandlers = window._starknetHandlers || {};
        window._starknetHandlers[event] = handler;
      },
      off: (event) => {
        window.starknet.callFlutterHandler({ type: "off", event, url: window.location.origin });
        if (window._starknetHandlers) delete window._starknetHandlers[event];
      },
    };

    window.starknet_argentX = window.starknet;

    // ── Stacks provider ────────────────────────────────────────────────────
    window.stacks = {
      isStacksWallet: true,

      // Send a request to the Flutter StacksHandler and await the response.
      request: (method, params) => {
        const id = Math.floor(Math.random() * 1e9);
        return new Promise((resolve, reject) => {
          const eventName = 'stacks_response_' + id;
          window.addEventListener(eventName, (event) => {
            const { result, error } = event.detail;
            if (error) { reject(new Error(error)); } else { resolve(result); }
          }, { once: true });

          const interval = setInterval(() => {
            if (isFlutterInAppWebViewReady) {
              clearInterval(interval);
              window.flutter_inappwebview.callHandler(
                'StacksHandler',
                JSON.stringify({
                  id,
                  name: method,
                  object: params ?? {},
                  url: window.location.origin,
                })
              );
            }
          }, 100);
        });
      },

      // Called by StacksHandler._sendResponse / _sendError via evaluateJavascript.
      sendResponse: (id, result) => {
        window.dispatchEvent(new CustomEvent('stacks_response_' + id, {
          detail: { result },
        }));
      },

      sendError: (id, message) => {
        window.dispatchEvent(new CustomEvent('stacks_response_' + id, {
          detail: { error: message },
        }));
      },

      // ── Standard SIP-030 / Leather / Xverse methods ────────────────────
      getInfo:                   (p)  => window.stacks.request('getInfo', p ?? {}),
      getAddresses:              (p)  => window.stacks.request('getAddresses', p ?? {}),
      getAccounts:               (p)  => window.stacks.request('getAccounts', p ?? {}),
      disconnect:                ()   => window.stacks.request('disconnect', {}),

      signMessage:               (p)  => window.stacks.request('signMessage', p),
      stx_signMessage:           (p)  => window.stacks.request('stx_signMessage', p),
      stx_signStructuredMessage: (p)  => window.stacks.request('stx_signStructuredMessage', p),
      stx_signTransaction:       (p)  => window.stacks.request('stx_signTransaction', p),

      sendTransfer:              (p)  => window.stacks.request('sendTransfer', p),
      stx_transferStx:           (p)  => window.stacks.request('stx_transferStx', p),
      stx_callContract:          (p)  => window.stacks.request('stx_callContract', p),
      stx_deployContract:        (p)  => window.stacks.request('stx_deployContract', p),
      stx_getAccounts:           (p)  => window.stacks.request('stx_getAccounts', p ?? {}),
      stx_getAddresses:          (p)  => window.stacks.request('stx_getAddresses', p ?? {}),

      // signPsbt is in the standard list but not supported (BTC-only).
      signPsbt: () => Promise.reject(new Error('signPsbt not supported by this wallet')),
    };

  })();
''';
}

Future<void> navigateToDappBrowser(BuildContext context, String data) async {
  final evmChains = getEVMBlockchains();

  if (pref.get(dappChainIdKey) == null) {
    await pref.put(dappChainIdKey, evmChains[0].chainId);
  }

  int chainId = pref.get(dappChainIdKey);
  final isActive = evmChains.any((c) => c.chainId == chainId);
  if (!isActive) {
    await pref.put(dappChainIdKey, evmChains[0].chainId);
    chainId = pref.get(dappChainIdKey);
  }

  final coin = evmFromChainId(chainId)!;
  final init = await setupWebViewWalletBridge(chainId, coin.rpc);

  if (context.mounted) {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Dapp(
          provider: '$trustWalletProvider;$leatherWalletProvider;$nightly',
          webNotifier: webNotifer,
          init: init,
          data: data,
        ),
      ),
    );
  }
}
