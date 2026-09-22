#!/bin/sh
set -eu

base_url="ftp://lma-tech.com/pub/lma_analysis"
download_dir="$(mktemp -d)"
trap 'rm -rf "${download_dir}"' EXIT

version="${LMA_ANALYSIS_VERSION:-latest}"
if [ "${version}" = "latest" ]; then
    wget -q -r --no-parent -nH --cut-dirs=1 -P "${download_dir}" "${base_url}/"
    binary="$(find "${download_dir}" -type f -name 'lma_analysis_v*' | sort | tail -n 1)"
else
    binary="${download_dir}/lma_analysis_v${version}"
    wget -q -O "${binary}" "${base_url}/lma_analysis_v${version}"
fi

if [ -z "${binary}" ] || [ ! -f "${binary}" ]; then
    echo "lma_analysis download did not contain an executable" >&2
    exit 1
fi

if [ -n "${LMA_ANALYSIS_SHA256:-}" ]; then
    printf '%s  %s\n' "${LMA_ANALYSIS_SHA256}" "${binary}" | sha256sum -c -
fi

install -m 0755 "${binary}" /usr/local/bin/lma_analysis
/usr/local/bin/lma_analysis --version
