#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if (($#)); then
    exec "$SCRIPT_DIR/../install.sh" "$@"
fi

exec "$SCRIPT_DIR/../install.sh" --profile niri
