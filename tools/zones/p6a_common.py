# Shared helpers for the plan 6 north-east zones (group A).
from ie_common import *
from wcommon import _stand

NE = "north_east"
YK = "yorkshire"


def smooth(z, passes=12):
    """clamp heights so neighbours differ by at most one level (everything stays walkable)."""
    for _ in range(passes):
        ch = False
        for y in range(z.h):
            for x in range(z.w):
                for dx, dy in ((1, 0), (0, 1)):
                    xx, yy = x + dx, y + dy
                    if xx < z.w and yy < z.h:
                        a, b = z.hg[y][x], z.hg[yy][xx]
                        if a - b > 1:
                            z.hg[y][x] = b + 1; ch = True
                        elif b - a > 1:
                            z.hg[yy][xx] = a + 1; ch = True
        if not ch:
            break


def vsea(z, coast_x, y0=0, y1=None, sand=3):
    """sea on the east: sand from coast_x, one shallow tile, then open sea to the edge."""
    y1 = z.h if y1 is None else y1
    for y in range(y0, y1):
        for x in range(coast_x, z.w):
            d = x - coast_x
            z.set(x, y, "s" if d < sand else ("w" if d == sand else "$"))


def island(z, x, y, w, h, inner="."):
    z.rect(x, y, w, h, "s")
    z.rect(x + 1, y + 1, w - 2, h - 2, inner)


def line_props(z, kind, pts, **kw):
    for (x, y) in pts:
        z.prop(kind, x, y, **kw)


def done(z):
    finish(z)
