# plan 6 group B: the north-west, the Peak and Sherwood. Run from the repo root:
#   python3 tools/zones/england_nw.py tools/zones data/zones [nw_dales nw_lakes mid_peak]
# Builds yorkshire_dales, lancaster, lake_district, keswick, sheffield, sherwood, nottingham (+ interiors, dialogue, trainers).
# The york and birmingham stubs and the Buxton gap are written by nw_seams.py.
import sys, os
sys.path.insert(0, sys.argv[1])
from wcommon import *
import importlib

OUT = sys.argv[2]
for part in sys.argv[3:] or ["nw_dales", "nw_lakes", "mid_peak"]:
    importlib.import_module(part).build(OUT)
write_all(OUT)
