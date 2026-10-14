# The South of England, group A (plan 4 task 6). Run from the repo root:
#   python3 tools/zones/south_a.py tools/zones data/zones sa_severn sa_mendips sa_west
# Builds severn_crossing, bath(+baths), mendips(+cave), glastonbury(+tor), somerset_levels, dartmoor, tintagel,
# penzance(+geevor), their Sanctuary and Corner Shop interiors, dialogue and trainers.
import sys, os
sys.path.insert(0, sys.argv[1])
from wcommon import *
import importlib

OUT = sys.argv[2]
for part in sys.argv[3:] or ["sa_severn", "sa_mendips", "sa_west"]:
    importlib.import_module(part).build(OUT)
write_all(OUT)
