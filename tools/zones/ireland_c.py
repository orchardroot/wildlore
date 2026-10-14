# Ireland, group C (west of Ireland; plan 4 task 6). Run from the repo root:
#   python3 tools/zones/ireland_c.py tools/zones data/zones ie_kerry ie_burren ie_north
# Builds ring_of_kerry, dingle, burren, galway(+docks), connemara, sligo, boyne_valley, newgrange(+tomb), their
# Sanctuary and Corner Shop interiors, dialogue and trainers. cork and dublin stubs are only written with --stubs
# (group B owns the real zones).
import sys, os
sys.path.insert(0, sys.argv[1])
from ie_common import *
import importlib

OUT = sys.argv[2]
args = sys.argv[3:]
stubs = "--stubs" in args
parts = [a for a in args if not a.startswith("--")] or ["ie_kerry", "ie_burren", "ie_north"]
for part in parts:
    importlib.import_module(part).build(OUT)
write_all(OUT)
if stubs:
    stub(OUT, "cork", "Cork", {"west": (20, "ring_of_kerry")})
    stub(OUT, "dublin", "Dublin", {"north": (30, "boyne_valley")})
