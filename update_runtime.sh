#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
index_source="${LMA_INDEX_SOURCE:-${script_dir}/../lma-index}"
image_tag="${LMA_CONTAINER_IMAGE:-lma-container:latest}"
lma_data_revision="${LMA_DATA_SCRIPTS_REVISION:-main}"
lmatools_revision="${LMATOOLS_REVISION:-master}"
glmtools_revision="${GLMTOOLS_REVISION:-master}"
lma_analysis_version="${LMA_ANALYSIS_VERSION:-latest}"
lma_analysis_sha256="${LMA_ANALYSIS_SHA256:-}"

if [[ ! -f "${index_source}/go.mod" ]]; then
    echo "lma-index source not found at ${index_source}" >&2
    echo "Set LMA_INDEX_SOURCE to its checkout directory." >&2
    exit 1
fi

index_revision="$(git -C "${index_source}" rev-parse HEAD)"

docker buildx build \
    --load \
    --pull \
    --no-cache \
    --platform linux/amd64 \
    --build-context "lma_index_source=${index_source}" \
    --build-arg "LMA_DATA_SCRIPTS_REVISION=${lma_data_revision}" \
    --build-arg "LMATOOLS_REVISION=${lmatools_revision}" \
    --build-arg "GLMTOOLS_REVISION=${glmtools_revision}" \
    --build-arg "LMA_INDEX_REVISION=${index_revision}" \
    --build-arg "LMA_ANALYSIS_VERSION=${lma_analysis_version}" \
    --build-arg "LMA_ANALYSIS_SHA256=${lma_analysis_sha256}" \
    --tag "${image_tag}" \
    "${script_dir}"
