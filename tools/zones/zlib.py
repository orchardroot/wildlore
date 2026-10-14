import json, random
class Z:
    def __init__(s, zid, name, w, h, fill=".", kind="town", region="cheshire", music="", weather=None):
        s.d = {"id": zid, "name": name, "region": region, "kind": kind, "music": music,
               "weather": weather if weather is not None else {"drizzle": 45, "clear": 35, "fog": 8, "sunshine": 12},
               "props": [], "warps": [], "edges": {}, "npcs": [], "encounters": {}, "signs": [], "spawn": [0, 0]}
        s.w, s.h = w, h
        s.g = [[fill]*w for _ in range(h)]
        s.hg = [[0]*w for _ in range(h)]
        s.legend = {}
    def rect(s, x, y, w, h, ch):
        for yy in range(y, y+h):
            for xx in range(x, x+w):
                if 0 <= xx < s.w and 0 <= yy < s.h: s.g[yy][xx] = ch
    def height(s, x, y, w, h, lv):
        for yy in range(y, y+h):
            for xx in range(x, x+w): s.hg[yy][xx] = lv
    def set(s, x, y, ch): s.g[y][x] = ch
    def border(s, ch, t=3, gaps=()):
        for y in range(s.h):
            for x in range(s.w):
                if x < t or y < t or x >= s.w-t or y >= s.h-t: s.g[y][x] = ch
        for (x, y, w, h) in gaps: s.rect(x, y, w, h, ".")
    def scatter(s, x, y, w, h, ch, n, seed, only="."):
        r = random.Random(seed)
        for _ in range(n):
            xx, yy = r.randrange(x, x+w), r.randrange(y, y+h)
            if s.g[yy][xx] == only: s.g[yy][xx] = ch
    def building(s, x, y, w, h, style, label=None, door=None, show_label=True):
        s.rect(x, y, w, h, "B")
        p = {"type": "building", "style": style, "x": x, "y": y, "w": w, "h": h}
        if label: p["label"] = label
        if not show_label: p["show_label"] = False
        s.d["props"].append(p)
        if door is not None:
            s.g[y+h-1][x+door] = "D"
            return (x+door, y+h-1)
    def warp(s, x, y, to, tx, ty, facing):
        s.d["warps"].append({"x": x, "y": y, "to": to, "tx": tx, "ty": ty, "facing": facing})
    def prop(s, t, x, y, **kw):
        p = {"type": t, "x": x, "y": y}; p.update(kw); s.d["props"].append(p)
    def sign(s, x, y, text): s.d["signs"].append({"x": x, "y": y, "text": text})
    def npc(s, **kw): s.d["npcs"].append(kw)
    def save(s, path):
        s.d["rows"] = ["".join(r) for r in s.g]
        if any(any(v for v in r) for r in s.hg):
            s.d["heights"] = ["".join(str(v) for v in r) for r in s.hg]
        if s.legend: s.d["legend_extra"] = s.legend
        json.dump(s.d, open(path, "w"), indent=1)
        # compact rows/heights onto single lines for readability
        txt = open(path).read()
        open(path, "w").write(txt)


# ---------------- shared interiors ----------------
def sanctuary(out, town, town_name, ret, music="sanctuary"):
    """<town>_sanctuary: 11x9, arrive at (5,6) facing up; the exit door (5,7) returns to `ret` = (x, y) in the town
    (the tile just south of the town's Sanctuary door). Nurse script id "nurse" in data/dialogue/<town>_sanctuary.json."""
    z = Z(town + "_sanctuary", town_name + " Sanctuary", 11, 9, fill="|", kind="interior", region="", music=music, weather={})
    z.border("x", 1); z.rect(3, 3, 5, 1, "C"); z.rect(1, 6, 2, 1, "+"); z.rect(8, 6, 2, 1, "+"); z.set(5, 7, "D")
    z.warp(5, 7, town, ret[0], ret[1], "down")
    z.prop("potted_plant", 1, 1); z.prop("potted_plant", 9, 1); z.prop("bookshelf", 1, 4); z.prop("table", 9, 4)
    z.npc(id="nurse", sprite="sanctuary_nurse", x=5, y=2, facing="down", move="still", script="nurse")
    z.d["spawn"] = [5, 6]
    z.save(out + "/" + town + "_sanctuary.json")

def shop(out, town, town_name, ret, music=""):
    """<town>_shop: 9x8, arrive at (4,5) facing up; exit door (4,6) returns to `ret`. Script "shopkeeper" in
    data/dialogue/<town>_shop.json, which runs {"do": "shop", "id": "<town>_corner_shop"}."""
    z = Z(town + "_shop", town_name + " Corner Shop", 9, 8, fill="|", kind="interior", region="", music=music, weather={})
    z.border("x", 1); z.rect(2, 2, 3, 1, "C"); z.rect(6, 2, 2, 3, "C"); z.set(4, 6, "D")
    z.warp(4, 6, town, ret[0], ret[1], "down")
    z.prop("bookshelf", 1, 1); z.prop("potted_plant", 7, 5)
    z.npc(id="shopkeeper", sprite="shopkeeper", x=3, y=1, facing="down", move="still", script="shopkeeper")
    z.d["spawn"] = [4, 5]
    z.save(out + "/" + town + "_shop.json")
