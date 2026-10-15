# Plan 6 group A (the north-east). Run from the repo root:
#   python3 tools/zones/p6a_zones.py tools/zones data/zones [part ...]
# Builds northumberland_coast, hadrians_wall, newcastle (+penshaw), north_york_moors, whitby, york (+crypt), their
# Sanctuaries, Corner Shops, dialogue and trainers, the Aberdeen south seam, and the yorkshire_dales / sheffield stubs.
# Aberdeen is edited in place (never regenerated).
import sys, os
sys.path.insert(0, sys.argv[1])
from p6a_common import *
import importlib

OUT = sys.argv[2]
parts = sys.argv[3:] or ["p6a_coast", "p6a_moors", "p6a_newcastle", "p6a_whitby", "p6a_york", "p6a_seams"]
for part in parts:
    importlib.import_module(part).build(OUT)
write_all(OUT)
