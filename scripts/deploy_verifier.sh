#!/usr/bin/env bash
set -euo pipefail

VK_PATH="circuit/target/vk"

echo "VK size: $(wc -c < "$VK_PATH") bytes"
echo "Deploying..."

VK_BYTES=$(xxd -p -c 0 "$VK_PATH" | python3 -c "
import sys
data = bytes.fromhex(sys.stdin.read().strip())
print('[' + ','.join(str(b) for b in data) + ']')
")

stellar contract deploy \
  --wasm contracts/target/wasm32v1-none/release/soroban_ultrahonk_verifier.wasm \
  --network testnet \
  --source dave \
  -- \
  --vk_bytes "$VK_BYTES"