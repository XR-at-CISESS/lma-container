"""Download the Natural Earth resources used by lma_plot at image build time."""

import os

import cartopy
from cartopy.io import shapereader


RESOURCES = (
    # LAND, LAKES and OCEAN automatically select a scale from the map extent.
    *((scale, "physical", name)
      for scale in ("110m", "50m", "10m")
      for name in ("land", "lakes", "ocean")),
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
