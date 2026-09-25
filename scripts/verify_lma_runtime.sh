#!/bin/sh
set -eu

for command_name in lma_analysis lma_flash lma_plot lma-index; do
    command -v "${command_name}" >/dev/null
done

lma_analysis --version 2>&1 | grep -F "lma_analysis " >/dev/null
lma_flash --help 2>&1 | grep -F "data_dir" >/dev/null
lma_flash --help 2>&1 | grep -F "out_dir" >/dev/null
lma_plot --help 2>&1 | grep -F "data_dir" >/dev/null
lma_plot --help 2>&1 | grep -F "out_dir" >/dev/null
lma-index --help 2>&1 | grep -F "usage: lma-index" >/dev/null

test -f "${LMA_SHAPES_DIR:-/usr/share/lma_shapes}/countyl010g.shp"
test -f "${LMA_GPS_DIR:-/usr/share/lma_gps}/dclma.gps"
test -f "${LMA_GPS_DIR:-/usr/share/lma_gps}/wff.gps"
test -d "${CARTOPY_DATA_DIR:-/usr/share/cartopy}"
# The science image puts its separate application venv first on PATH. Cartopy
# belongs to the base image's system Python alongside the lma_plot command.
/usr/bin/python3 - <<'PY'
import os
from pathlib import Path
from unittest.mock import patch

from cartopy.io import shapereader

root = Path(os.environ["CARTOPY_DATA_DIR"]).resolve()
resources = [
    (scale, "physical", name)
    for scale in ("110m", "50m", "10m")
    for name in ("land", "lakes", "ocean")
] + [
    ("10m", "physical", "coastline"),
    ("50m", "cultural", "admin_1_states_provinces_lines"),
]
# Verify actual runtime lookup, without allowing downloads to hide missing assets.
with patch.object(shapereader.NEShpDownloader, "acquire_resource",
                  side_effect=RuntimeError("Required Cartopy data was not bundled")):
    for scale, category, name in resources:
        path = Path(shapereader.natural_earth(scale, category, name)).resolve()
        assert path.is_relative_to(root), f"Resource outside bundled directory: {path}"
        for extension in (".shp", ".shx", ".dbf"):
            assert path.with_suffix(extension).is_file(), path.with_suffix(extension)
        reader = shapereader.Reader(path)
        try:
            assert len(reader) > 0, f"Empty shapefile: {path}"
        finally:
            reader.close()
PY
test -f "${LMA_RUNTIME_MANIFEST:-/usr/share/lma-runtime/manifest.json}"

python3 -m json.tool \
    "${LMA_RUNTIME_MANIFEST:-/usr/share/lma-runtime/manifest.json}" \
    >/dev/null

echo "LMA runtime verification passed"
