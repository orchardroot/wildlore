# Builds data/world_map.json: towns, places and ferries (what travel and the map cursor use) plus the drawing data
# for ui/map_view.gd (nations, coastlines, borders, uplands and hill marks, railways, ferry paths, sea names).
# The coastlines are Natural Earth's 1:10m map subunits (public domain), simplified. Fetch them once, then run:
#   curl -L -o /tmp/ne_subunits.geojson \
#     https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_10m_admin_0_map_subunits.geojson
#   python3 tools/map/world_map.py data/world_map.json /tmp/ne_subunits.geojson
import json, math, sys
LON0, LON1, LAT0, LAT1 = -11.0, 2.0, 59.5, 49.8
def pt(lon, lat):
    return [round((lon - LON0) / (LON1 - LON0) * 1000), round((LAT0 - lat) / (LAT0 - LAT1) * 1300)]
# The first hand-drawn outlines: nothing draws them now, but tests still count their points.
GB = [(-3.52,58.6),(-3.0,58.64),(-3.1,58.44),(-3.65,58.1),(-4.0,57.87),(-4.2,57.52),(-3.87,57.6),(-2.95,57.68),(-2.0,57.69),(-1.78,57.5),
(-2.08,57.15),(-2.2,56.96),(-2.47,56.7),(-2.58,56.56),(-2.97,56.46),(-2.8,56.34),(-2.58,56.28),(-3.15,56.11),(-3.2,55.98),(-2.52,56.0),
(-2.13,55.9),(-2.0,55.77),(-1.71,55.6),(-1.43,55.0),(-1.37,54.9),(-1.2,54.69),(-0.61,54.49),(-0.4,54.28),(-0.08,54.12),(0.12,53.58),
(0.34,53.14),(0.2,52.9),(0.5,52.95),(1.3,52.93),(1.73,52.6),(1.75,52.47),(1.35,51.96),(1.15,51.79),(0.7,51.54),(1.38,51.39),(1.31,51.13),
(0.97,50.91),(0.57,50.85),(-0.14,50.82),(-1.09,50.79),(-1.88,50.72),(-2.45,50.6),(-2.94,50.72),(-3.4,50.62),(-3.64,50.22),(-4.14,50.37),
(-5.2,49.96),(-5.71,50.07),(-5.48,50.21),(-5.07,50.42),(-4.94,50.54),(-4.55,50.83),(-4.52,51.02),(-4.12,51.21),(-3.47,51.2),(-2.98,51.35),
(-2.65,51.55),(-2.98,51.55),(-3.17,51.46),(-3.27,51.39),(-3.7,51.48),(-3.94,51.6),(-4.33,51.56),(-4.7,51.67),(-4.94,51.6),(-5.15,51.7),
(-5.3,51.9),(-4.98,52.0),(-4.7,52.1),(-4.26,52.24),(-4.08,52.41),(-4.05,52.55),(-4.05,52.72),(-4.11,52.86),(-4.14,52.92),(-4.41,52.89),
(-4.72,52.8),(-4.52,52.95),(-4.28,53.14),(-4.7,53.31),(-4.33,53.42),(-4.09,53.27),(-3.83,53.33),(-3.49,53.32),(-3.32,53.36),(-3.1,53.25),
(-3.18,53.38),(-3.0,53.42),(-3.07,53.56),(-3.0,53.65),(-3.05,53.82),(-3.0,53.93),(-2.87,54.07),(-3.23,54.11),(-3.64,54.49),(-3.57,54.64),
(-3.5,54.71),(-3.2,54.95),(-4.05,54.83),(-4.86,54.64),(-5.03,54.97),(-5.0,55.1),(-4.63,55.46),(-4.87,55.8),(-4.75,55.95),(-5.3,55.85),
(-5.55,55.4),(-5.8,55.3),(-5.6,55.75),(-5.6,56.0),(-5.47,56.41),(-5.85,56.7),(-6.22,56.73),(-5.83,57.0),(-5.71,57.28),(-5.8,57.6),
(-5.7,57.73),(-5.16,57.9),(-5.24,58.15),(-5.0,58.62),(-4.75,58.57)]
IRELAND = [(-7.37,55.38),(-7.0,55.2),(-6.66,55.2),(-6.15,55.23),(-5.8,54.86),(-5.9,54.65),(-5.45,54.5),(-5.55,54.35),(-5.88,54.2),(-6.4,54.0),
(-6.25,53.72),(-6.2,53.35),(-6.03,52.98),(-6.45,52.33),(-6.36,52.17),(-7.0,52.15),(-7.85,51.95),(-8.25,51.8),(-8.5,51.7),(-9.8,51.45),
(-10.45,52.12),(-9.9,52.4),(-9.93,52.56),(-9.43,52.97),(-9.05,53.27),(-10.2,53.4),(-10.2,53.95),(-10.0,54.25),(-9.2,54.25),(-8.6,54.3),
(-8.3,54.6),(-8.8,54.65),(-8.3,55.15)]
MAN = [(-4.36,54.42),(-4.3,54.3),(-4.42,54.15),(-4.65,54.06),(-4.8,54.1),(-4.7,54.25),(-4.5,54.38)]
SKYE = [(-6.3,57.7),(-5.9,57.55),(-5.7,57.25),(-6.0,57.05),(-6.5,57.3),(-6.75,57.45)]
ORKNEY = [(-3.35,59.1),(-2.75,59.1),(-2.6,58.9),(-3.0,58.8),(-3.4,58.9)]
TOWNS = {
 "macclesfield": ("Macclesfield", -2.13, 53.26, "england"), "buxton": ("Buxton", -1.91, 53.26, "england"),
 "manchester": ("Manchester", -2.24, 53.48, "england"), "liverpool": ("Liverpool", -2.99, 53.41, "england"),
 "chester": ("Chester", -2.89, 53.19, "england"), "keswick": ("Keswick", -3.13, 54.6, "england"),
 "lancaster": ("Lancaster", -2.8, 54.05, "england"), "york": ("York", -1.08, 53.96, "england"),
 "whitby": ("Whitby", -0.61, 54.49, "england"), "newcastle": ("Newcastle", -1.61, 54.97, "england"),
 "sheffield": ("Sheffield", -1.47, 53.38, "england"), "nottingham": ("Nottingham", -1.15, 52.95, "england"),
 "birmingham": ("Birmingham", -1.9, 52.49, "england"), "bath": ("Bath", -2.36, 51.38, "england"),
 "glastonbury": ("Glastonbury", -2.72, 51.15, "england"), "penzance": ("Penzance", -5.54, 50.12, "england"),
 "london": ("London", -0.13, 51.51, "england"),
 "llangollen": ("Llangollen", -3.17, 52.97, "wales"), "llanberis": ("Llanberis", -4.13, 53.12, "wales"),
 "aberystwyth": ("Aberystwyth", -4.08, 52.41, "wales"), "st_davids": ("St Davids", -5.27, 51.88, "wales"),
 "cardiff": ("Cardiff", -3.18, 51.48, "wales"),
 "edinburgh": ("Edinburgh", -3.19, 55.95, "scotland"), "glasgow": ("Glasgow", -4.25, 55.86, "scotland"),
 "fort_william": ("Fort William", -5.1, 56.82, "scotland"), "inverness": ("Inverness", -4.22, 57.48, "scotland"),
 "portree": ("Portree", -6.19, 57.41, "scotland"), "aberdeen": ("Aberdeen", -2.1, 57.15, "scotland"),
 "kirkwall": ("Kirkwall", -2.96, 58.98, "scotland"),
 "belfast": ("Belfast", -5.93, 54.6, "northern_ireland"), "bushmills": ("Bushmills", -6.52, 55.2, "northern_ireland"),
 "derry": ("Derry~Londonderry", -7.31, 55.0, "northern_ireland"),
 "dublin": ("Dublin", -6.26, 53.35, "ireland"), "kilkenny": ("Kilkenny", -7.25, 52.65, "ireland"),
 "cork": ("Cork", -8.47, 51.9, "ireland"), "dingle": ("Dingle", -10.27, 52.14, "ireland"),
 "galway": ("Galway", -9.05, 53.27, "ireland"), "sligo": ("Sligo", -8.47, 54.27, "ireland"),
 "newgrange": ("Newgrange", -6.48, 53.69, "ireland"), "douglas": ("Douglas", -4.48, 54.15, "man"),
 "holyhead": ("Holyhead", -4.63, 53.31, "wales"),
 "cairnryan": ("Cairnryan", -5.03, 54.97, "scotland"),
}
# routes and landmarks shown as small dots (for Creaturepedia habitats)
PLACES = {
 "macc_forest": (-2.03, 53.24), "cat_and_fiddle": (-1.99, 53.25), "goyt_valley": (-2.02, 53.33), "chat_moss": (-2.6, 53.46),
 "wirral_way": (-3.1, 53.3), "dee_valley": (-3.05, 52.98), "ogwen": (-3.7, 53.12), "yr_wyddfa": (-4.08, 53.07),
 "dinas_emrys": (-4.08, 53.02), "anglesey": (-4.35, 53.25),
 "severn_crossing": (-2.7, 51.6), "mendips": (-2.7, 51.28), "somerset_levels": (-2.85, 51.1), "dartmoor": (-3.9, 50.57),
 "tintagel": (-4.75, 50.67), "wicklow": (-6.35, 53.0), "comeraghs": (-7.6, 52.3), "ring_of_kerry": (-9.8, 51.95),
 "burren": (-9.1, 53.05), "mournes": (-6.0, 54.18), "antrim_coast": (-6.0, 55.05), "causeway": (-6.51, 55.24),
 "galloway": (-4.5, 55.05), "central_belt": (-3.7, 55.9), "glencoe": (-4.95, 56.67), "great_glen": (-4.9, 57.1),
 "loch_ness": (-4.45, 57.3), "skye": (-6.2, 57.3), "cairngorms": (-3.65, 57.08), "connemara": (-9.8, 53.5), "boyne_valley": (-6.6, 53.7), "cambrian_coast": (-4.06, 52.7), "pembroke_coast": (-4.95, 51.75), "beacons": (-3.44, 51.88),
}

# ---- drawing data (ui/map_view.gd): real coastlines, nations, uplands, rail, ferry paths, names on the sea ----

SUBUNITS = {"England": "england", "Wales": "wales", "Scotland": "scotland", "Northern Ireland": "northern_ireland",
            "Ireland": "ireland", "Isle of Man": "mann"}
# the near Continent, for the corners of the map (one muted colour, no borders); Germany and friends are only
# here so their borders with the others aren't mistaken for coast
ABROAD = ["France", "Flemish Region", "Walloon Region", "Brussels Capital Region", "Netherlands", "Germany",
          "Luxembourg", "Norway", "Denmark"]
ABROAD_BOX = (-450.0, -150.0, 1330.0, 1700.0)   # map units: as far as the map ever scrolls, and a bit
MIN_AREA = 22.0     # map units^2 (about 15 km^2): smaller islets are dropped
TOL = 0.9           # Douglas-Peucker tolerance, map units

def ptf(lon, lat):
    return ((lon - LON0) / (LON1 - LON0) * 1000.0, (LAT0 - lat) / (LAT0 - LAT1) * 1300.0)

def area(r):
    return abs(sum(r[i][0] * r[(i + 1) % len(r)][1] - r[(i + 1) % len(r)][0] * r[i][1] for i in range(len(r)))) * 0.5

def seg_dist(p, a, b):
    dx, dy = b[0] - a[0], b[1] - a[1]
    l2 = dx * dx + dy * dy
    if l2 == 0:
        return math.hypot(p[0] - a[0], p[1] - a[1])
    t = max(0.0, min(1.0, ((p[0] - a[0]) * dx + (p[1] - a[1]) * dy) / l2))
    return math.hypot(p[0] - a[0] - t * dx, p[1] - a[1] - t * dy)

def dp(pts, tol):
    """Douglas-Peucker, keeping both ends (iterative)."""
    if len(pts) < 3:
        return list(pts)
    keep = [False] * len(pts)
    keep[0] = keep[-1] = True
    stack = [(0, len(pts) - 1)]
    while stack:
        a, b = stack.pop()
        best, bi = -1.0, -1
        for i in range(a + 1, b):
            d = seg_dist(pts[i], pts[a], pts[b])
            if d > best:
                best, bi = d, i
        if best > tol:
            keep[bi] = True
            stack += [(a, bi), (bi, b)]
    return [p for p, k in zip(pts, keep) if k]

def key(lonlat):
    return (round(lonlat[0], 6), round(lonlat[1], 6))

def clip_poly(poly, box):
    """Sutherland-Hodgman against an axis-aligned box."""
    x0, y0, x1, y1 = box
    edges = [(lambda p: p[0] >= x0, lambda a, b: _ix(a, b, x0, 0)), (lambda p: p[0] <= x1, lambda a, b: _ix(a, b, x1, 0)),
             (lambda p: p[1] >= y0, lambda a, b: _ix(a, b, y0, 1)), (lambda p: p[1] <= y1, lambda a, b: _ix(a, b, y1, 1))]
    out = poly
    for inside, cut in edges:
        src, out = out, []
        for i, cur in enumerate(src):
            prev = src[i - 1]
            if inside(cur):
                if not inside(prev):
                    out.append(cut(prev, cur))
                out.append(cur)
            elif inside(prev):
                out.append(cut(prev, cur))
        if not out:
            break
    return out

def _ix(a, b, v, axis):
    t = (v - a[axis]) / (b[axis] - a[axis])
    p = [a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t]
    p[axis] = v
    return tuple(p)

def clip_line(line, box):
    """Splits a polyline into the pieces inside the box (whole segments only: the box is off screen anyway)."""
    x0, y0, x1, y1 = box
    ins = lambda p: x0 <= p[0] <= x1 and y0 <= p[1] <= y1
    out, cur = [], []
    for p in line:
        if ins(p):
            cur.append(p)
        elif cur:
            cur.append(p)
            out.append(cur)
            cur = []
    if len(cur) >= 2:
        out.append(cur)
    return [c for c in out if len(c) >= 2]

def flat(pts):
    return [v for p in pts for v in (round(p[0], 1), round(p[1], 1))]

def inside(p, ring):
    x, y = p
    c = False
    j = len(ring) - 1
    for i in range(len(ring)):
        xi, yi = ring[i]
        xj, yj = ring[j]
        if (yi > y) != (yj > y) and x < (xj - xi) * (y - yi) / (yj - yi) + xi:
            c = not c
        j = i
    return c

def chaikin(pts, n=3):
    for _ in range(n):
        out = []
        for i in range(len(pts)):
            a, b = pts[i], pts[(i + 1) % len(pts)]
            out += [(a[0] * 0.75 + b[0] * 0.25, a[1] * 0.75 + b[1] * 0.25), (a[0] * 0.25 + b[0] * 0.75, a[1] * 0.25 + b[1] * 0.75)]
        pts = out
    return pts

def shapes(geojson_path):
    feats = json.load(open(geojson_path))["features"]
    rings = {}  # unit -> [ring of (lon, lat)]
    for f in feats:
        name = f["properties"]["SUBUNIT"]
        if name not in SUBUNITS and name not in ABROAD:
            continue
        g = f["geometry"]
        polys = g["coordinates"] if g["type"] == "MultiPolygon" else [g["coordinates"]]
        rings[name] = [[tuple(p) for p in poly[0][:-1]] for poly in polys]
    owners = {}  # vertex -> units that have it (shared vertices are land borders)
    for name, rs in rings.items():
        for r in rs:
            for p in r:
                owners.setdefault(key(p), set()).add(name)
    land, coast, borders = {}, {}, []
    for name, rs in rings.items():
        nation = SUBUNITS.get(name, "abroad")
        for r in rs:
            n = len(r)
            proj = [ptf(*p) for p in r]
            if area(proj) < MIN_AREA or max(q[1] for q in proj) < -30:
                continue
            shared = [len(owners[key(p)]) > 1 for p in r]
            kinds = ["border" if shared[i] and shared[(i + 1) % n] else "coast" for i in range(n)]
            if len(set(kinds)) == 1:  # all coast: split the ring at its far point so both halves simplify
                far = max(range(n), key=lambda i: (proj[i][0] - proj[0][0]) ** 2 + (proj[i][1] - proj[0][1]) ** 2)
                chains = [("coast", list(range(0, far + 1))), ("coast", list(range(far, n)) + [0])]
            else:
                start = next(i for i in range(n) if kinds[i] != kinds[i - 1])
                chains = []
                for s in range(n):
                    i = (start + s) % n
                    if not chains or kinds[i] != chains[-1][0]:
                        chains.append((kinds[i], [i]))
                    chains[-1][1].append((i + 1) % n)
            ring = []
            for kind, idx in chains:
                simple = dp([proj[i] for i in idx], TOL)
                ring += simple[:-1]
                if kind == "coast":
                    coast.setdefault(nation, []).append(simple)
                elif nation != "abroad":
                    mid = r[idx[len(idx) // 2]]
                    other = sorted(owners[key(mid)] - {name})
                    if other and SUBUNITS.get(other[0], "abroad") != "abroad" and name < other[0]:
                        borders.append(simple)
            if nation == "abroad":
                ring = clip_poly(ring, ABROAD_BOX)
                if len(ring) < 3 or area(ring) < MIN_AREA:
                    continue
            land.setdefault(nation, []).append(ring)
    if "abroad" in coast:
        coast["abroad"] = [piece for line in coast["abroad"] for piece in clip_line(line, ABROAD_BOX)]
    return land, coast, borders

# Uplands (lon, lat), rough and then smoothed: the hills get a shade and little hill marks. Clipped to the land
# when drawn, so they may spill into the sea.
UPLANDS = {
 "Highlands": [(-5.9, 58.5), (-4.6, 58.55), (-3.9, 58.2), (-3.4, 57.75), (-2.8, 57.35), (-2.6, 56.95), (-3.6, 56.55),
               (-4.4, 56.25), (-5.2, 56.0), (-5.6, 56.35), (-6.0, 56.8), (-5.9, 57.4), (-6.0, 57.9)],
 "Cairngorms": [(-4.0, 57.2), (-3.2, 57.25), (-3.0, 56.95), (-3.6, 56.85), (-4.1, 56.95)],
 "Southern Uplands": [(-4.9, 55.2), (-3.8, 55.65), (-2.6, 55.75), (-2.2, 55.45), (-3.0, 55.2), (-4.0, 55.0), (-4.7, 54.95)],
 "Lake District": [(-3.45, 54.7), (-2.85, 54.65), (-2.8, 54.35), (-3.2, 54.25), (-3.5, 54.45)],
 "Pennines": [(-2.6, 55.05), (-1.95, 55.0), (-1.85, 54.4), (-1.85, 53.8), (-1.7, 53.25), (-1.95, 53.05), (-2.15, 53.3),
              (-2.25, 53.8), (-2.45, 54.4)],
 "The Peak": [(-2.05, 53.5), (-1.65, 53.45), (-1.6, 53.15), (-1.85, 53.05), (-2.08, 53.2)],
 "North York Moors": [(-1.3, 54.5), (-0.6, 54.48), (-0.55, 54.3), (-1.2, 54.25)],
 "Snowdonia": [(-4.3, 53.2), (-3.75, 53.25), (-3.6, 52.85), (-3.95, 52.7), (-4.25, 52.85)],
 "Cambrian Mountains": [(-4.05, 52.55), (-3.55, 52.6), (-3.35, 52.15), (-3.8, 51.95), (-4.1, 52.2)],
 "Brecon Beacons": [(-3.95, 51.98), (-3.0, 51.95), (-3.05, 51.78), (-3.9, 51.8)],
 "Dartmoor": [(-4.1, 50.72), (-3.8, 50.72), (-3.75, 50.5), (-4.05, 50.48)],
 "Mournes": [(-6.15, 54.25), (-5.85, 54.25), (-5.88, 54.08), (-6.12, 54.07)],
 "Sperrins": [(-7.35, 54.85), (-6.75, 54.88), (-6.7, 54.7), (-7.25, 54.68)],
 "Wicklow": [(-6.5, 53.25), (-6.15, 53.22), (-6.2, 52.88), (-6.55, 52.9)],
 "Kerry": [(-10.25, 52.2), (-9.4, 52.15), (-9.3, 51.85), (-10.0, 51.75)],
 "Connemara": [(-10.0, 53.65), (-9.3, 53.7), (-9.35, 53.45), (-9.9, 53.42)],
}
# where each upland's name goes (only the ones worth naming), in lon, lat
UPLAND_NAMES = {"Highlands": (-4.95, 57.75), "The Peak": (-1.62, 53.32), "Snowdonia": (-3.62, 52.98), "Lake District": (-3.1, 54.25),
                "Mournes": (-5.95, 54.05), "Cairngorms": (-3.3, 57.0)}
SEAS = {"North Sea": (1.0, 56.4), "Irish Sea": (-5.0, 53.55), "Atlantic Ocean": (-9.9, 56.9), "Celtic Sea": (-7.6, 50.9),
        "English Channel": (-2.4, 50.25), "The Minch": (-6.25, 58.15)}
NATION_NAMES = {"england": (0.45, 52.5), "wales": (-3.55, 52.25), "scotland": (-3.7, 56.55),
                "northern_ireland": (-6.85, 54.55), "ireland": (-7.9, 52.95)}
# Railways, stop by stop (town ids or lon, lat junctions): a sketch of the main lines, not a timetable.
RAIL = [
 ["london", "birmingham", (-2.18, 52.8), "macclesfield", "manchester", (-2.63, 53.55), "lancaster", (-2.75, 54.66), (-2.93, 54.89), (-3.6, 55.6), "glasgow"],
 [(-2.93, 54.89), "newcastle"], ["glasgow", "edinburgh"],
 ["london", (-0.25, 52.57), (-1.13, 53.52), "york", (-1.55, 54.52), "newcastle", (-2.0, 55.77), "edinburgh", (-3.4, 56.1), (-3.43, 56.4), (-2.97, 56.46), (-2.47, 56.7), "aberdeen", (-3.2, 57.6), "inverness"],
 [(-3.43, 56.4), (-3.6, 56.75), (-3.85, 57.05), "inverness"],
 ["glasgow", (-4.75, 56.0), (-4.65, 56.4), "fort_william", (-5.83, 57.0)], ["inverness", (-5.2, 57.45), (-5.71, 57.28)],
 ["london", (-1.15, 52.63), "nottingham", "sheffield", (-1.55, 53.8), "york"], ["sheffield", (-1.75, 53.33), "manchester"],
 ["manchester", "buxton"], ["liverpool", "manchester"], ["liverpool", (-2.73, 53.34), (-2.43, 53.09), (-2.18, 52.8)],
 ["chester", (-2.43, 53.09)], ["chester", (-3.81, 53.28), (-4.13, 53.22), "holyhead"], ["york", (-1.23, 54.57), "whitby"],
 ["birmingham", (-2.75, 52.71), (-3.85, 52.59), "aberystwyth"],
 ["london", (-0.97, 51.46), (-1.78, 51.56), "bath", (-2.58, 51.45), (-3.1, 51.02), (-3.53, 50.73), (-4.14, 50.37), (-5.05, 50.27), "penzance"],
 [(-2.58, 51.45), (-2.68, 51.58), "cardiff", (-3.94, 51.62), (-4.31, 51.86), (-4.98, 52.01)], ["birmingham", (-2.58, 51.45)],
 ["dublin", "newgrange", (-6.4, 54.0), (-6.33, 54.18), "belfast"], ["belfast", (-6.67, 55.13), "derry"], ["belfast", (-6.52, 54.9), (-6.67, 55.13)],
 ["dublin", (-6.9, 53.15), "kilkenny", (-7.11, 52.26)], ["dublin", (-7.2, 53.15), (-8.0, 52.65), "cork"], [(-8.0, 52.65), (-8.62, 52.66)],
 ["dublin", (-7.34, 53.53), (-7.94, 53.42), "galway"], [(-7.34, 53.53), (-7.8, 53.73), "sligo"], [(-9.7, 52.27), (-8.62, 52.66)],
 ["douglas", (-4.63, 54.07), (-4.75, 54.08)],
]
# Ferry crossings as sailed (route id from data/ferries.json -> waypoints from port a to port b), so they keep off the land.
FERRY_PATHS = {
 "liverpool_douglas": ["liverpool", (-3.08, 53.47), (-3.5, 53.62), (-4.2, 54.05), "douglas"],
 "holyhead_dublin": ["holyhead", (-4.9, 53.36), (-5.9, 53.36), "dublin"],
 "belfast_cairnryan": ["belfast", (-5.68, 54.7), (-5.42, 54.85), (-5.1, 55.0), "cairnryan"],
 "aberdeen_kirkwall": ["aberdeen", (-1.85, 57.25), (-1.95, 58.0), (-2.4, 58.82), (-2.68, 59.0), "kirkwall"],
}

def stops(seq):
    return [ptf(TOWNS[s][1], TOWNS[s][2]) if isinstance(s, str) else ptf(*s) for s in seq]

def hill_marks(uplands, land):
    """Little hill glyphs on a jittered grid inside the uplands and on dry land: [x, y, size]."""
    rings = [r for n in land if n != "abroad" for r in land[n]]
    out = []
    step = 21.0
    for name, ring in uplands.items():
        xs = [p[0] for p in ring]
        ys = [p[1] for p in ring]
        y = min(ys)
        row = 0
        while y < max(ys):
            x = min(xs) + (step * 0.5 if row % 2 else 0.0)
            while x < max(xs):
                h = (math.sin(x * 12.9898 + y * 78.233) * 43758.5453) % 1.0
                p = (x + (h - 0.5) * 6.0, y + ((h * 7.0) % 1.0 - 0.5) * 5.0)
                if inside(p, ring) and any(inside(p, r) for r in rings):
                    big = name in ("Highlands", "Cairngorms", "Snowdonia", "Lake District")
                    out.append([round(p[0], 1), round(p[1], 1), round((5.0 if big else 4.0) + h * 1.5, 1)])
                x += step
            y += step * 0.8
            row += 1
    return out

def drawing(geojson_path):
    land, coast, borders = shapes(geojson_path)
    uplands = {k: chaikin([ptf(*p) for p in v]) for k, v in UPLANDS.items()}
    return {
        "land": {n: [flat(r) for r in rs] for n, rs in land.items()},
        "coast": {n: [flat(l) for l in ls] for n, ls in coast.items()},
        "borders": [flat(b) for b in borders],
        "uplands": [{"name": k, "pts": flat(v)} | ({"label": [round(c, 1) for c in ptf(*UPLAND_NAMES[k])]} if k in UPLAND_NAMES else {})
                    for k, v in uplands.items()],
        "hills": hill_marks(uplands, land),
        "seas": [{"name": k, "x": round(ptf(*v)[0], 1), "y": round(ptf(*v)[1], 1)} for k, v in SEAS.items()],
        "nation_labels": {k: [round(c, 1) for c in ptf(*v)] for k, v in NATION_NAMES.items()},
        "rail": [flat(stops(line)) for line in RAIL],
        "ferry_paths": {k: flat(stops(v)) for k, v in FERRY_PATHS.items()},
    }

if __name__ == "__main__":
    d = {"space": [1000, 1300], "outlines": {"gb": [pt(*p) for p in GB], "ireland": [pt(*p) for p in IRELAND], "man": [pt(*p) for p in MAN],
         "skye": [pt(*p) for p in SKYE], "orkney": [pt(*p) for p in ORKNEY]},
         "towns": {k: {"name": v[0], "x": pt(v[1], v[2])[0], "y": pt(v[1], v[2])[1], "nation": v[3],
                       "island": "orkney" if k == "kirkwall" else {"ireland": "ireland", "northern_ireland": "ireland", "man": "man"}.get(v[3], "gb")} for k, v in TOWNS.items()},
         "places": {k: {"x": pt(*v)[0], "y": pt(*v)[1]} for k, v in PLACES.items()},
         "ferries": [["liverpool", "douglas"], ["holyhead", "dublin"], ["belfast", "cairnryan"], ["aberdeen", "kirkwall"]]}
    d.update(drawing(sys.argv[2]))
    with open(sys.argv[1], "w") as f:  # a key per line, each value on one line: diffs stay readable
        f.write("{\n" + ",\n".join("%s: %s" % (json.dumps(k), json.dumps(v, separators=(",", ":"))) for k, v in d.items()) + "\n}\n")
