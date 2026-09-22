"""Record the source revisions resolved while building the runtime image."""

from __future__ import annotations

import importlib.metadata
import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Any


def distribution_source(name: str) -> dict[str, Any]:
    distribution = importlib.metadata.distribution(name)
    direct_url: dict[str, Any] = {}
    for file in distribution.files or ():
        if str(file).endswith(".dist-info/direct_url.json"):
            with distribution.locate_file(file).open(encoding="utf-8") as stream:
                direct_url = json.load(stream)
            break
    return {
        "name": name,
        "version": distribution.version,
        "source": direct_url,
    }


def command_first_line(*command: str) -> str:
    result = subprocess.run(
        command,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    return result.stdout.splitlines()[0]


manifest = {
    "schema_version": 1,
    "platform": "linux/amd64",
    "components": {
        "lma-analysis": {
            "requested_version": os.environ["LMA_ANALYSIS_REQUESTED_VERSION"],
            "reported_version": command_first_line("lma_analysis", "--version"),
        },
        "lma-data-scripts": distribution_source("lma-data"),
        "lmatools": distribution_source("lmatools"),
        "glmtools": distribution_source("glmtools"),
        "lma-index": {
            "revision": os.environ["LMA_INDEX_REVISION"],
            "help": command_first_line("lma-index", "--help"),
        },
    },
}

destination = Path(sys.argv[1])
destination.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")
