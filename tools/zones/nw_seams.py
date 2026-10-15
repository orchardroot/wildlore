# plan 6 group B seams: the york and birmingham stubs (other agents replace them) and the Buxton east gap to Sheffield.
# python3 tools/zones/nw_seams.py tools/zones data/zones
# The Buxton patch edits data/zones/buxton.json and data/dialogue/buxton.json in place and is idempotent.
import sys, os, json
sys.path.insert(0, sys.argv[1])
from wcommon import *

OUT = sys.argv[2]
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(OUT)))


def york_stub():
    z = Z("york", "York", 40, 40, kind="town", region="yorkshire", music="town_city")
    z.d["stage"] = "town"; z.d["town_id"] = "york"; z.d["stub"] = True
    z.border("T", 2, gaps=[(0, 20, 2, 3), (30, 38, 3, 2)])
    z.rect(2, 20, 36, 3, "="); z.rect(30, 20, 3, 18, "=")
    z.d["edges"] = {"west": {"to": "yorkshire_dales", "offset": 0}, "south": {"to": "sheffield", "offset": 0}}
    z.d["spawn"] = [20, 21]
    z.save(OUT + "/york.json")


def birmingham_stub():
    z = Z("birmingham", "Birmingham", 40, 40, kind="town", region="midlands", music="town_city")
    z.d["stage"] = "city"; z.d["town_id"] = "birmingham"; z.d["stub"] = True
    z.border("T", 2, gaps=[(30, 0, 3, 2)])
    z.rect(30, 2, 3, 18, "="); z.rect(2, 19, 36, 3, "=")
    z.d["edges"] = {"north": {"to": "nottingham", "offset": 0}}
    z.d["spawn"] = [31, 20]
    z.save(OUT + "/birmingham.json")


def buxton_gap():
    p = OUT + "/buxton.json"
    d = json.load(open(p))
    rows = [list(r) for r in d["rows"]]
    for y, ch in ((20, ":"), (21, "="), (22, ":")):
        for x in range(50, 56):
            rows[y][x] = ch
    d["rows"] = ["".join(r) for r in rows]
    d["edges"]["east"] = {"to": "sheffield", "offset": 0}
    d["npcs"] = [n for n in d["npcs"] if not str(n.get("id", "")).startswith("sheffield_warden")]
    for i, y in enumerate((20, 21, 22)):
        d["npcs"].append({"id": "sheffield_warden_%d" % (i + 1), "sprite": "warden_grunt", "x": 54, "y": y, "facing": "right",
                          "move": "still", "script": "sheffield_warden", "hide_if": "badge_spirit"})
    json.dump(d, open(p, "w"), indent=1)
    dp = ROOT + "/data/dialogue/buxton.json"
    dl = json.load(open(dp))
    dl["sheffield_warden"] = say("Warden", "The road to Sheffield's closed for resurfacing. Come back when you've seen a bit more of the country.")
    json.dump(dl, open(dp, "w"), indent=1)


york_stub()
birmingham_stub()
buxton_gap()
