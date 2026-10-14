# Plan 5 group B: west Scotland. Run from the repo root:
#   python3 tools/zones/scotland_b.py tools/zones data/zones [sc_south sc_glasgow sc_east sc_highlands]
import sys, os
sys.path.insert(0, sys.argv[1])
from wcommon import *
import importlib

OUT = sys.argv[2]
for part in sys.argv[3:] or ["sc_south", "sc_glasgow", "sc_east", "sc_highlands"]:
    importlib.import_module(part).build(OUT)
write_all(OUT)
