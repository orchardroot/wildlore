# North Wales: Dee Valley, Llangollen, Ogwen, Llanberis (+ quarry), Yr Wyddfa, Dinas Emrys, plus stubs for Chester and Cambrian Coast.
# python3 tools/zones/north_wales.py tools/zones data/zones
import sys
sys.path.insert(0, sys.argv[1])
OUT = sys.argv[2]
import nwlib
import nw_dee
nw_dee.dee_valley(OUT)
nw_dee.llangollen(OUT)
for mod in ("nw_ogwen", "nw_wyddfa"):
    try:
        m = __import__(mod)
    except ImportError:
        continue
    m.build(OUT)
nwlib.write_all(OUT)
