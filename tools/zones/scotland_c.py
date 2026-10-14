# Plan 5 group C: north Scotland. Run from the repo root:
#   python3 tools/zones/scotland_c.py tools/zones data/zones
# Builds loch_ness, inverness (+rink), skye (+faerie_glen), portree, cairngorms (+cave), aberdeen, kirkwall,
# their Sanctuary/Shop interiors, dialogue and trainers, and the great_glen stub.
import sys, os
sys.path.insert(0, sys.argv[1])
from wcommon import *
import importlib

OUT = sys.argv[2]
for part in sys.argv[3:] or ["sc_loch", "sc_skye", "sc_northeast"]:
    importlib.import_module(part).build(OUT)
write_all(OUT)
