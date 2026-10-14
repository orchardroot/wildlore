# Mid and South Wales (plan 3, group B2). Run from the repo root:
#   python3 tools/zones/wales_south.py tools/zones data/zones
# Builds cambrian_coast, aberystwyth, aber_lab, pembroke_coast, st_davids, beacons, cardiff, cardiff_arena,
# their Sanctuary/Corner Shop interiors, dialogue and trainers, plus a minimal llanberis stub when none exists.
import sys, os
sys.path.insert(0, sys.argv[1])
from wcommon import *
import importlib

OUT = sys.argv[2]
for part in sys.argv[3:] or ["ws_cambrian"]:
    importlib.import_module(part).build(OUT)
write_all(OUT)
