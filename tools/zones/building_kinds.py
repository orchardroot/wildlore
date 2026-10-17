"""Tags each named town building whose door leads into a landmark() interior with that interior's kind
("museum", "library", "church", ...), as the building prop's "kind". ZoneBuilder's signage reads it to pick the
right sign (a stone name band for a museum, a fascia for a cafe) and the place indicator to say what the
building is. The kind is recovered from the interior itself (furnish.guess_kind). Edits in place; safe to re-run.

Usage: python3 tools/zones/building_kinds.py data/zones [--dry]"""
import glob
import json
import os
import sys

here = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, here)
import furnish  # noqa: E402


def interior_kind(path, cache):
    if path not in cache:
        kind = None
        if os.path.exists(path):
            d = json.load(open(path))
            if d.get("kind") == "interior":
                kind = furnish.guess_kind(d["id"], d["rows"], d["props"], d["npcs"], d["warps"], d["spawn"], d["name"])
        cache[path] = kind
    return cache[path]


def tag_all(zone_dir, dry=False):
    cache = {}
    tagged = 0
    for path in sorted(glob.glob(os.path.join(zone_dir, "*.json"))):
        raw = open(path, encoding="utf-8").read()
        d = json.loads(raw)
        if d.get("kind") == "interior":
            continue
        warps = {(int(w["x"]), int(w["y"])): w["to"] for w in d.get("warps", [])}
        changed = False
        for p in d["props"]:
            if p.get("type") != "building" or "label" not in p:
                continue
            bx, by, bw, bh = int(p["x"]), int(p["y"]), int(p["w"]), int(p["h"])
            to = next((warps[(x, by + bh - 1)] for x in range(bx, bx + bw) if (x, by + bh - 1) in warps), None)
            if to is None:
                continue
            kind = interior_kind(os.path.join(zone_dir, to + ".json"), cache)
            if kind is not None and p.get("kind") != kind:
                p["kind"] = kind
                changed = True
                tagged += 1
        if changed and not dry:
            # the file's own style: indent=1, escaping non-ASCII only where it already did
            out = json.dumps(d, indent=1, ensure_ascii="\\u" in raw)
            open(path, "w", encoding="utf-8").write(out + ("\n" if raw.endswith("\n") else ""))
    print("tagged", tagged)


if __name__ == "__main__":
    tag_all(sys.argv[1], dry="--dry" in sys.argv)
