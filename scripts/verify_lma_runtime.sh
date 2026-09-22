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
test -d "${CARTOPY_DATA_DIR:-/usr/share/cartopy}"
test -f "${CARTOPY_DATA_DIR:-/usr/share/cartopy}/shapefiles/natural_earth/physical/ne_110m_land.shp"
test -f "${CARTOPY_DATA_DIR:-/usr/share/cartopy}/shapefiles/natural_earth/physical/ne_10m_coastline.shp"
test -f "${CARTOPY_DATA_DIR:-/usr/share/cartopy}/shapefiles/natural_earth/cultural/ne_50m_admin_1_states_provinces_lines.shp"
test -f "${LMA_RUNTIME_MANIFEST:-/usr/share/lma-runtime/manifest.json}"

python3 -m json.tool \
    "${LMA_RUNTIME_MANIFEST:-/usr/share/lma-runtime/manifest.json}" \
    >/dev/null

echo "LMA runtime verification passed"
