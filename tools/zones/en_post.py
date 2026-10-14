# Part of england_north.py (exec'd last): stages for the template interiors and the Buxton north-edge chatter.

for town in ("manchester", "liverpool", "chester", "douglas"):
    for suffix, stage in (("sanctuary", "spa_interior"), ("shop", "town")):
        pth = os.path.join(OUT, town + "_" + suffix + ".json")
        zd = json.load(open(pth)); zd["stage"] = stage
        json.dump(zd, open(pth, "w"), indent=1)

# Buxton: a walker by the new north gap, with one real fact about the road to Manchester
bp = os.path.join(OUT, "buxton.json")
bz = json.load(open(bp))
bz["npcs"] = [n for n in bz["npcs"] if n.get("id") != "buxton_goyt_guide"]
if True:
    bz["npcs"].append({"id": "buxton_goyt_guide", "sprite": "villager_2", "x": 30, "y": 3, "facing": "left", "move": "still",
                       "script": "goyt_guide", "name": "Walker"})
    json.dump(bz, open(bp, "w"), indent=1)
bd = os.path.join(DLG_DIR, "buxton.json")
bdl = json.load(open(bd))
bdl["goyt_guide"] = [
    {"do": "say", "who": "Walker", "text": "That gap leads up into the Goyt Valley. It's the old packhorse road to Manchester."},
    {"do": "say", "who": "Walker", "text": "Salt and silk went one way, cotton the other. Nowadays it's mostly walkers and the odd lost sat-nav."},
    {"do": "say", "who": "Walker", "text": "Wrap up. Manchester is thirty miles north and, I'm told, wetter."}]
json.dump(bdl, open(bd, "w"), indent=1)
