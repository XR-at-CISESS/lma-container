"""Download the Natural Earth resources used by lma_plot at image build time."""

import os

import cartopy
from cartopy.io import shapereader


RESOURCES = (
    ("110m", "physical", "land"),
    ("110m", "physical", "lakes"),
    ("110m", "physical", "ocean"),
    ("10m", "physical", "coastline"),
    ("50m", "cultural", "admin_1_states_provinces_lines"),
)

cartopy.config["data_dir"] = os.environ["CARTOPY_DATA_DIR"]

for resolution, category, name in RESOURCES:
    path = shapereader.natural_earth(
        resolution=resolution,
        category=category,
        name=name,
    )
    print(path)
