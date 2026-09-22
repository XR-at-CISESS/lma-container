#!/usr/bin/env bash
set -euo pipefail

# Compatibility entry point retained for existing users. This now refreshes
# the complete scientific runtime rather than only Python packages.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${script_dir}/update_runtime.sh"
