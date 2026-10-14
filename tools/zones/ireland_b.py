# Plan 4 group B: Anglesey and Ireland east. Run from the repo root:
#   python3 tools/zones/ireland_b.py tools/zones data/zones ie_wales ie_dublin ie_south
# Builds anglesey, holyhead, dublin(+dublin_hall), wicklow, kilkenny, comeraghs, cork, their Sanctuary and Corner Shop
# interiors, dialogue and trainers. Llanberis, ferries.json and the two stubs are patched by ie_seams.py.
import sys, os
sys.path.insert(0, sys.argv[1])
from wcommon import *
import importlib

OUT = sys.argv[2]
for part in sys.argv[3:] or ["ie_wales", "ie_dublin", "ie_south"]:
    importlib.import_module(part).build(OUT)
write_all(OUT)
