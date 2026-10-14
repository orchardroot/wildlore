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
