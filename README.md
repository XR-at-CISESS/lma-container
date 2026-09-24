# LMA container

This repository builds the shared LMA scientific runtime used for development,
testing, and LMAO deployments. The image provides `lma_analysis`, `lma_flash`,
`lma_plot`, `lma-index`, the Python `lma_data` package, county shapes, the
`dclma.gps` and `wff.gps` survey files, and the Cartopy resources required for
offline plotting. The survey files are available under `/usr/share/lma_gps`;
`LMA_GPS_DIR` points to that directory.

The distributed `lma_analysis` executable is x86-64, so the image targets
`linux/amd64`. Docker Desktop can run it through platform emulation on Apple
Silicon.

## Installation

1. Download [Docker](https://docs.docker.com/engine/install/) on your system. If
you plan to install these utilities on a Windows or macOS machine, you can install
[Docker Desktop](https://www.docker.com/products/docker-desktop/) to provide a
user-friendly interface for installing and managing Docker.

2. Install this Git repository:

```
git clone https://github.com/XR-at-CISESS/lma-container.git
git clone https://github.com/XR-at-CISESS/lma-index.git
```

Keep the repositories next to one another. The container build uses the
`lma-index` checkout as a named build context because that repository is not
publicly readable without GitHub credentials.

## Usage

Use `lma.sh` to build the image when necessary and open an interactive shell:

```
$ ./lma.sh

lma@...$ lma_analysis
```

You can optionally pass a host directory to `lma.sh`. It is mounted at `/host`
for input data and generated products:

```
$ mkdir test/
$ echo "hello world" > test/hello.txt
$ ./lma.sh ./test/

lma@...$ cat /host/hello.txt
hello world
lma@...$
```

## Refresh the scientific runtime

Run `./update_runtime.sh` to force a clean build against the current
`lma-data-scripts`, `lmatools`, and `glmtools` default branches and the current
local `lma-index` checkout. `update_pip.sh` remains as a compatibility alias.
Set `LMA_DATA_SCRIPTS_REVISION`, `LMATOOLS_REVISION`, `GLMTOOLS_REVISION`,
`LMA_ANALYSIS_VERSION`, or `LMA_ANALYSIS_SHA256` before running the script to
pin those inputs. `LMA_CONTAINER_IMAGE` selects the resulting image tag.

Build arguments can select exact dependency revisions for reproducible CI and
production images:

```console
docker buildx build --load --platform linux/amd64 \
  --build-context lma_index_source=../lma-index \
  --build-arg LMA_DATA_SCRIPTS_REVISION=7eba018f29c9cfe226b7acf17525e06bf77ac50b \
  --build-arg LMATOOLS_REVISION=9508e4643f8c83d816235b6cae4a86099a493f3f \
  --build-arg LMA_INDEX_REVISION=805adeb17c28eafa81c3c3d55ef50392e2cf8377 \
  --tag lma-container:latest .
```

The resolved Python VCS revisions and runtime versions are written to
`/usr/share/lma-runtime/manifest.json`. Run `verify_lma_runtime` in the image to
repeat the command and asset checks performed during the build.
