#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
export QUARTO_PYTHON="${QUARTO_PYTHON:-$PWD/.venv/bin/python}"

uv run jupyter lab "$@"
