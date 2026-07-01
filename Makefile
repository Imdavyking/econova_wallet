install-bun:
	curl -fsSL https://bun.sh/install | bash

install-noir:
	curl -L https://raw.githubusercontent.com/noir-lang/noirup/refs/heads/main/install | bash
	noirup -v 1.0.0-beta.9

install-rust:
	rustup override set 1.91.1

install-barretenberg:
	curl -L https://raw.githubusercontent.com/AztecProtocol/aztec-packages/refs/heads/master/barretenberg/bbup/install | bash
	bbup -v 0.87.0

install-app-deps:
	cd frontend && yarn
	cd contracts && yarn
	cd indexer && yarn
	cd keeper && yarn


build-circuit:
	cd circuit && nargo build

exec-circuit:
	cd circuit && nargo execute witness

gen-vk:
	bb write_vk --scheme ultra_honk --oracle_hash keccak -b ./circuit/target/circuit.json -o ./circuit/target 


prove-circuit:
	bb prove --scheme ultra_honk --oracle_hash keccak -b ./circuit/target/circuit.json -w ./circuit/target/witness.gz -o ./circuit/target


# ─── Verifier Contract ────────────────────────────────────────────────────────


build-verifier:
	stellar contract build \
		--manifest-path contracts/soroban-ultrahonk-verifier/Cargo.toml \
		--optimize

upload-verifier: build-verifier
	stellar contract upload \
		--wasm contracts/target/wasm32v1-none/release/soroban_ultrahonk_verifier.wasm \
		--network testnet \
		--source dave

deploy-verifier: upload-verifier
	bash scripts/deploy_verifier.sh



build-contract:
	stellar contract build \
		--manifest-path contracts/Cargo.toml \
		--optimize
 
upload-contract: build-contract
	stellar contract upload \
		--wasm contracts/target/wasm32v1-none/release/usdc_private.wasm \
		--network testnet \
		--source dave
 
# The registry's constructor deploys the executor itself, so it needs the
# executor's wasm *hash* (not address) up front. `stellar contract upload`
# is idempotent — re-running it just returns the same hash if already
# uploaded — so we capture it inline rather than needing a separate step.
deploy-contract: upload-contract
	stellar contract deploy \
		--wasm contracts/target/wasm32v1-none/release/usdc_private.wasm \
		--network testnet \
		--source dave \
		--fee 1000000 \
		-- \
		--owner $$(stellar keys address dave) \
		--verifier $(VERIFIER)
 
# ─── Executor Contract ────────────────────────────────────────────────────────
#
# No standalone `deploy-executor` — the executor is deployed automatically
# by the registry's constructor (see `deploy-registry` above). These targets
# are kept for building/uploading the wasm independently, e.g. to get its
# hash for `deploy-registry`, or to inspect/test it in isolation.
 
build-executor:
	stellar contract build \
		--manifest-path contracts/prova-executor/Cargo.toml \
		--optimize
 
upload-executor: build-executor
	stellar contract upload \
		--wasm contracts/target/wasm32v1-none/release/prova_executor.wasm \
		--network testnet \
		--source dave
		
run-app:
	cd frontend && yarn dev

# ── Docker stack ─────────────────────────────────────────────────────────────

start:
	docker compose up --build

stop:
	docker compose down

indexer-start:
	cd indexer && docker compose up --build

indexer-stop:
	cd indexer && docker compose down

logs:
	docker compose logs -f

# ── Local dev (no Docker) ─────────────────────────────────────────────────────

run-indexer:
	cd indexer && yarn install && yarn dev

run-frontend:
	cd frontend && yarn install && yarn dev