# Shared helpers for the west Scotland zones (plan 5 group B).
import math
from wcommon import *
from wcommon import _stand

SCOT = "scotland"
WX_WEST = {"drizzle": 38, "clear": 20, "downpour": 14, "fog": 10, "gale": 8, "sunshine": 10}
WX_HIGH = {"fog": 34, "drizzle": 28, "downpour": 12, "clear": 12, "gale": 8, "frost": 6}


def mound(z, cx, cy, rx, ry, peak, tile=None, floor=0):
    """Raise an elliptical hill: heights fall by about one level per ring; optional tile char on tiles >= floor."""
    for y in range(max(0, cy - ry), min(z.h, cy + ry + 1)):
        for x in range(max(0, cx - rx), min(z.w, cx + rx + 1)):
            d = math.hypot((x - cx) / rx, (y - cy) / ry)
            if d < 1:
                hv = max(1, math.ceil(peak * (1 - d)))
                z.hg[y][x] = max(z.hg[y][x], hv)
                if tile and hv >= floor:
                    z.g[y][x] = tile


def lamps(z, pts):
    for (x, y) in pts:
        z.prop("lamp_post", x, y)


def creature_npc(z, nid, species, x, y, text, move="wander"):
    _stand(z, x, y)
    z.npc(id=nid, sprite="creature:" + species, x=x, y=y, facing="down", move=move, script=nid)
    script(z.d["id"], nid, say(species.capitalize(), text))
