# ────────────────────────────────────────────────────────────────────────
#  Makefile – Mouni Backend management
# ────────────────────────────────────────────────────────────────────────

# Path to the OpenAPI CLI (adjust if you use a Docker wrapper)
OPENAPI_GEN   := uv run openapi-generator-cli

# Input spec & output folder
SPEC          := swagger.yaml
OUT_DIR       := .

# Env setup
export PYTHONPATH := $(PWD)/src
export DB_PATH:= $(PWD)/data/mouni.db


.PHONY: generate install serve seed clear update reset-db clean-server clean

generate:
	$(OPENAPI_GEN) generate \
		-i $(SPEC) \
		-g python-fastapi \
		-o $(OUT_DIR) \
		--additional-properties=packageName=api_server \
		--global-property apis,models,apiTests=false,modelTests=false,supportingFiles= \
		--ignore-file-override .openapi-generator-ignore
	ruff check $(OUT_DIR)/src --fix --select I

install:
	@uv sync --group dev

serve:
	PASSWORD=NO_AUTH uv run uvicorn src.api_server.wrapped_main:app --reload --reload-dir $(OUT_DIR)/src/api_server  --host 0.0.0.0 --port 8080

clean-server:
	@echo "Removing api server generated code …"
	@find $(OUT_DIR)/src/api_server -mindepth 1 -maxdepth 1 ! -name 'impl' -exec rm -rf {} +

seed:
	@echo "Seeding API"
	@uv run python debug_cli.py seed

clear:
	@echo "Testing deletion endpoints by clearing seeded content"
	@uv run python debug_cli.py clear

update:
	@echo "Testing update endpoints by updating some resources"
	@uv run python debug_cli.py update

reset-db:
	@echo "Deleting default local database"
	@rm -r data/


clean: clean-server reset-db