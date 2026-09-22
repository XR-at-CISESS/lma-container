# syntax=docker/dockerfile:1.7

ARG GO_VERSION=1.24
ARG UBUNTU_VERSION=24.04

FROM --platform=$BUILDPLATFORM golang:${GO_VERSION}-bookworm AS lma_index_builder
ARG TARGETOS=linux
ARG TARGETARCH=amd64
WORKDIR /src
COPY --from=lma_index_source . .
RUN go test ./...
RUN mkdir -p /out \
    && CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
       go build -trimpath -ldflags="-s -w" \
       -o /out/lma-index ./cmd/lma-index

FROM ubuntu:${UBUNTU_VERSION} AS os_setup
ARG TARGETARCH
ARG DEBIAN_FRONTEND=noninteractive

ENV TZ=Etc/UTC

# lma_analysis is currently distributed only as an x86-64 Linux executable.
RUN test "${TARGETARCH}" = "amd64"

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       fonts-paratype \
       git \
       libgeos-dev \
       python3 \
       python3-pip \
       python3-venv \
       tmux \
       vim \
       wget \
    && rm -rf /var/lib/apt/lists/*

FROM os_setup AS lma_scripts
ARG LMA_DATA_SCRIPTS_REVISION=main
ARG LMATOOLS_REVISION=master
ARG GLMTOOLS_REVISION=master
ARG LMA_INDEX_REVISION=workspace
ARG LMA_ANALYSIS_VERSION=latest
ARG LMA_ANALYSIS_SHA256=""

ENV PIP_DISABLE_PIP_VERSION_CHECK=1 \
    LMA_DATA_SCRIPTS_REQUESTED_REVISION=${LMA_DATA_SCRIPTS_REVISION} \
    LMATOOLS_REQUESTED_REVISION=${LMATOOLS_REVISION} \
    GLMTOOLS_REQUESTED_REVISION=${GLMTOOLS_REVISION} \
    LMA_INDEX_REVISION=${LMA_INDEX_REVISION} \
    LMA_ANALYSIS_REQUESTED_VERSION=${LMA_ANALYSIS_VERSION}

RUN python3 -m pip install --no-cache-dir --break-system-packages \
    "git+https://github.com/XR-at-CISESS/lmatools.git@${LMATOOLS_REVISION}" \
    "git+https://github.com/deeplycloudy/glmtools.git@${GLMTOOLS_REVISION}" \
    "git+https://github.com/XR-at-CISESS/lma-data-scripts.git@${LMA_DATA_SCRIPTS_REVISION}"

COPY ./scripts/install_lma_analysis.sh /tmp/install_lma_analysis.sh
RUN LMA_ANALYSIS_VERSION=${LMA_ANALYSIS_VERSION} \
    LMA_ANALYSIS_SHA256=${LMA_ANALYSIS_SHA256} \
    /tmp/install_lma_analysis.sh \
    && rm /tmp/install_lma_analysis.sh

COPY --from=lma_index_builder /out/lma-index /usr/local/bin/lma-index

COPY ./shapes /usr/share/lma_shapes
COPY ./scripts/preload_cartopy.py /tmp/preload_cartopy.py
ENV CARTOPY_DATA_DIR=/usr/share/cartopy
RUN mkdir -p "${CARTOPY_DATA_DIR}" \
    && python3 /tmp/preload_cartopy.py \
    && rm /tmp/preload_cartopy.py \
    && chmod -R a+rX /usr/share/lma_shapes "${CARTOPY_DATA_DIR}"

COPY ./scripts/initialize_lma.sh /usr/local/bin/initialize_lma.sh
COPY ./scripts/verify_lma_runtime.sh /usr/local/bin/verify_lma_runtime
COPY ./scripts/write_runtime_manifest.py /tmp/write_runtime_manifest.py
ENV LMA_RUNTIME_MANIFEST=/usr/share/lma-runtime/manifest.json
RUN chmod 0555 \
      /usr/local/bin/initialize_lma.sh \
      /usr/local/bin/lma-index \
      /usr/local/bin/verify_lma_runtime \
    && mkdir -p /usr/share/lma-runtime \
    && python3 /tmp/write_runtime_manifest.py "${LMA_RUNTIME_MANIFEST}" \
    && rm /tmp/write_runtime_manifest.py \
    && /usr/local/bin/verify_lma_runtime

ENV LMA_DATA_DIR=/home/lma/lma_data \
    LMA_OUT_DIR=/home/lma/lma_out \
    LMA_SHAPES_DIR=/usr/share/lma_shapes \
    MPLCONFIGDIR=/tmp/matplotlib

RUN groupadd --gid 1001 lma \
    && useradd --uid 1001 --gid lma --create-home lma
USER lma
WORKDIR /home/lma

ENTRYPOINT ["/usr/local/bin/initialize_lma.sh"]
CMD ["/bin/bash"]
