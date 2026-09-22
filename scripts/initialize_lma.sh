#!/bin/sh
set -eu

mkdir -p "${LMA_DATA_DIR:-/home/lma/lma_data}"
mkdir -p "${LMA_OUT_DIR:-/home/lma/lma_out}"

exec "$@"
