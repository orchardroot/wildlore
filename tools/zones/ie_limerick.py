# Wildlore 3.0 "Wider Isles": the Shannon estuary, Limerick city and Lough Gur, hung off Galway's south side.
# Usage (from the repo root): python3 tools/zones/ie_limerick.py
# Writes data/zones/{shannon_estuary,limerick,lough_gur}.json and their interiors, data/dialogue/<zone>.json,
# data/trainers/<id>.json (all scaled to par 58), and opens Galway's south wall (idempotent, text edit).
import json, os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ie_common import *
from zlib import landmark
from wcommon import _stand
import furnish as _furnish

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, "data", "zones")
FLOOR = 58   # Galway's band: every zone and trainer here is scaled from this par
IRL = "ireland_west"


# --- helpers -------------------------------------------------------------------------------------------------

def bld(z, x, y, w, h, style, label=None, door=None, kind=None, to=None, room=(13, 10), show=True):
    """A building; with `to`, its door warps into interior `to` (a room of size `room`). Returns the door tile."""
    d = z.building(x, y, w, h, style, label if show else None, door=door, show_label=show)
    if kind:
        z.d["props"][-1]["kind"] = kind
    if to:
        z.warp(d[0], d[1], to, room[0] // 2, room[1] - 3, "up")
    return d


def plaque(z, x, y, pid, title, text):
    z.d["signs"].append({"x": x, "y": y, "text": text, "plaque": pid, "title": title})


def person(z, nid, sprite, x, y, who, lines=None, facing="down", move="still", cmds=None, radius=None, times=None):
    _stand(z, x, y)
    n = {"id": nid, "sprite": sprite, "x": x, "y": y, "facing": facing, "move": move, "script": nid, "name": who}
    if radius:
        n["radius"] = radius
    if times:
        n["times"] = times
    z.npc(**n)
    script(z.d["id"], nid, cmds if cmds is not None else say(who, *lines))


def flag_if(flag, then, other=None):
    c = {"do": "if", "flag": flag, "then": then}
    if other is not None:
        c["else"] = other
    return c


def sets(*flags):
    return [{"do": "set", "flag": f} for f in flags]


def give(item, n=1):
    return {"do": "give_item", "item": item, "n": n}


def stand(n):
    return {"do": "standing", "nation": "ireland", "amount": n}


def room(zid, name, town, door, kind, npcs, w=13, h=10, extra=(), legend=None, rects=(), furnish=True):
    """A walk-in interior whose exit returns to the tile south of `door` in `town`. `npcs`: (id, sprite, x, y,
    facing, who, lines or cmds). `extra`: (type, x, y, {kw}) props placed before furnishing. `rects`: (x, y, w, h, ch)."""
    r = landmark(OUT, zid, name, town, (door[0], door[1] + 1), kind, [], w, h, furnish=False, write=False)
    if legend:
        r.legend.update(legend)
    for (x, y, ww, hh, ch) in rects:
        r.rect(x, y, ww, hh, ch)
    for (t, x, y, kw) in extra:
        r.d["props"] = [p for p in r.d["props"] if not (p["x"] == x and p["y"] == y)]
        p = {"type": t, "x": x, "y": y}
        p.update(kw)
        r.d["props"].append(p)
    for (nid, sprite, x, y, facing, who, body) in npcs:
        r.d["props"] = [p for p in r.d["props"] if not (p["x"] == x and p["y"] == y and not p.get("walk"))]
        if body is None:   # a trainer that fights on sight
            r.npc(id=nid, sprite=sprite, x=x, y=y, facing=facing or "down", move="still", trainer=nid)
            continue
        r.npc(id=nid, sprite=sprite, x=x, y=y, facing=facing, move="still", script=nid, name=who)
        script(zid, nid, body if isinstance(body[0], dict) else say(who, *body))
    if furnish:
        r.d["props"].extend(_furnish.furnish(kind, name, zid, ["".join(row) for row in r.g], r.d["props"], r.d["npcs"],
                                             r.d["warps"], r.d["spawn"]))
    finish(r)
    r.save(os.path.join(OUT, zid + ".json"))


def scaled_trainers():
    for t in TRN.values():
        t["scaled_floor"] = FLOOR


def script_trainer(tid, name, cls, sprite, party, intro, win, after, money):
    """A trainer fought from a quest script ({"do": "battle"}), not on sight."""
    TRN[tid] = {"id": tid, "name": name, "class": cls, "sprite": sprite,
                "party": [{"species": s, "level": l} for s, l in party], "ai": "trainer", "money": money,
                "intro": say(name, *intro), "win": win, "after": after}


# --- Galway: open the south wall (a causeway over the bay) -------------------------------------------------

def open_galway():
    p = os.path.join(OUT, "galway.json")
    txt = open(p).read()
    if '"south"' in txt.split('"encounters"')[0]:
        return
    d = json.loads(txt)
    rows = d["rows"]
    new_rows = list(rows)
    for y in range(41, 56):
        r = list(rows[y])
        r[33] = "W"; r[37] = "W"
        r[34] = r[35] = r[36] = "="
        new_rows[y] = "".join(r)
    for y in range(41, 56):
        txt = txt.replace('  "%s"' % rows[y], '  "%s"' % new_rows[y], 1)
    # the south edge, after the west one
    txt = txt.replace('"to": "burren"\n  }\n }', '"to": "burren"\n  },\n  "south": {\n   "offset": 0.0,\n   "to": "shannon_estuary"\n  }\n }', 1)
    # the buoy that sat on the causeway line goes a little east
    txt = re.sub(r'("type": "buoy",\n\s*"x": )36\.0(,\n\s*"y": 43\.0)', r'\g<1>39.0\2', txt, count=1)
    # a fingerpost at the head of the causeway
    sign = ('  {\n   "text": "SOUTH TO CLARE, THE SHANNON AND LIMERICK. The old coast road. In real life it goes the long way round the bay '
            'by Oranmore and Ennis; the Wildlore causeway is a shortcut the Atlantic puts up with, mostly.",\n   "x": 33,\n   "y": 40\n  },\n')
    txt = txt.replace(' "signs": [\n', ' "signs": [\n' + sign, 1)
    json.loads(txt)
    open(p, "w").write(txt)


# --- the Shannon estuary (route) ----------------------------------------------------------------------------

def estuary():
    W, H = 72, 52
    zid = "shannon_estuary"
    z = Z(zid, "Shannon Estuary", W, H, kind="route", region=IRL, music="route_ireland",
          weather={"drizzle": 28, "clear": 20, "sunshine": 12, "gale": 16, "fog": 10, "downpour": 14})
    z.d["stage"] = "coast"
    z.d["scaled_floor"] = FLOOR
    z.legend["a"] = {"tile": "road", "colour": "#55585c"}          # runway
    z.legend["b"] = {"tile": "road", "colour": "#d9d8cc"}          # runway centre line
    z.legend["m"] = {"tile": "sand", "colour": "#7f7560"}          # estuary mud
    z.legend["k"] = {"tile": "grass", "colour": "#6e8f48"}
    z.rect(0, 0, W, H, "k")
    z.border("T", 2, gaps=[(34, 0, 3, 2), (70, 17, 2, 3)])
    z.rect(34, 0, 3, 2, "=")
    z.rect(70, 17, 2, 3, "=")
    z.scatter(0, 0, W, H, "P", 18, 7, only="T")
    # roads: the Ennis road down from Galway, and the Limerick road east along the north shore
    z.rect(34, 0, 3, 17, "=")
    z.rect(6, 17, 66, 3, "=")
    z.rect(33, 2, 1, 15, ":"); z.rect(37, 2, 1, 15, ":")
    # Shannon Airport: a runway, an apron and the terminal
    z.rect(3, 3, 29, 3, "a")
    for x in range(4, 31, 3):
        z.rect(x, 4, 2, 1, "b")
    z.rect(4, 6, 27, 2, ":")
    bld(z, 5, 8, 12, 3, "airport_terminal", "Shannon Airport", door=5, kind="hall", to="shannon_airport", room=(15, 10))
    z.rect(4, 11, 30, 1, ":"); z.rect(10, 11, 1, 1, ":")
    # the dairy farm (the Golden Vale's cream)
    z.rect(18, 12, 14, 4, ","); z.rect(4, 13, 12, 3, ",")
    bld(z, 26, 12, 5, 3, "field_barn", "Dairy", show=False)
    for x in range(18, 32):
        z.set(x, 16, "F")
    z.set(24, 16, "k")
    # Bunratty: the castle, the folk park, the Ratty and Durty Nelly's
    z.rect(57, 2, 2, 15, "~"); z.rect(57, 20, 2, 2, "~")
    z.rect(57, 10, 2, 1, ":")
    bld(z, 46, 3, 8, 6, "tower_house", "Bunratty Castle", door=4, kind="castle", to="shannon_bunratty", room=(15, 11))
    z.rect(43, 9, 13, 2, ":"); z.rect(50, 11, 1, 6, ":")
    bld(z, 38, 3, 5, 3, "clare_thatch", "Folk Park Cottage", door=2, kind="cottage", to="shannon_cottage")
    bld(z, 38, 10, 4, 3, "clare_thatch", show=False)
    bld(z, 43, 12, 4, 3, "clare_thatch", show=False)
    z.rect(38, 6, 6, 2, ":"); z.rect(37, 8, 1, 9, ":"); z.rect(38, 15, 12, 1, ":")
    bld(z, 60, 7, 7, 3, "white_render", "Durty Nelly's", door=2, kind="cafe", to="shannon_nellys")
    z.rect(59, 10, 9, 1, ":"); z.rect(63, 11, 1, 6, ":")
    z.rect(60, 12, 9, 4, ",")
    bld(z, 64, 3, 4, 3, "clare_thatch", show=False)
    for (x, y) in [(44, 10), (55, 10), (59, 11), (67, 11)]:
        z.prop("lamp_post", x, y)
    z.prop("bench", 47, 11); z.prop("bench", 53, 11)
    # the estuary: mud, shallows, the channel (wade it with Brook Wade) and the sea lane
    z.rect(2, 20, 68, 1, "m"); z.rect(2, 21, 68, 1, "w"); z.rect(0, 22, 70, 2, "o")
    z.rect(0, 24, 70, 8, "$")
    z.rect(0, 32, 70, 2, "o"); z.rect(2, 34, 68, 1, "w"); z.rect(2, 35, 68, 1, "m")
    z.rect(0, 20, 2, 16, "$"); z.rect(70, 20, 2, 16, "T")
    # the crossing at the head of the estuary
    z.rect(63, 20, 3, 16, "="); z.rect(62, 21, 1, 14, "W"); z.rect(66, 21, 1, 14, "W")
    # ferry slips (Killimer and Tarbert)
    z.rect(9, 20, 3, 3, ":"); z.rect(9, 33, 3, 3, ":")
    z.prop("bollard", 9, 22); z.prop("bollard", 9, 33)
    for (x, y, v) in [(16, 27, 1), (40, 25, 0), (52, 29, 1), (28, 30, 1)]:
        z.prop("boat", x, y, variant=v)
    for (x, y) in [(22, 26), (46, 28), (34, 24)]:
        z.prop("buoy", x, y)
    # Foynes on the south bank
    z.rect(4, 42, 62, 3, "=")
    z.rect(63, 36, 3, 6, "=")
    bld(z, 18, 37, 9, 4, "cream_render", "Foynes Flying Boat Museum", door=4, kind="museum", to="shannon_foynes", room=(15, 10))
    z.rect(17, 41, 12, 1, ":")
    bld(z, 29, 37, 9, 4, "flying_boat", "Yankee Clipper", show=True)
    z.rect(28, 41, 11, 1, ":")
    bld(z, 41, 37, 5, 3, "cream_render", show=False)
    bld(z, 47, 37, 5, 3, "white_render", show=False)
    bld(z, 53, 37, 5, 3, "clare_thatch", show=False)
    z.rect(40, 40, 19, 2, ":")
    for (x, y) in [(17, 40), (39, 40), (52, 41), (30, 36)]:
        z.prop("lamp_post", x, y)
    z.rect(4, 45, 22, 4, ","); z.rect(42, 45, 22, 4, ",")
    z.rect(28, 45, 12, 4, "f")
    # signs and plaques
    plaque(z, 33, 12, "limerick_shannon_airport", "Shannon Airport",
           "SHANNON AIRPORT. In 1947 it opened the world's first duty-free shop, the idea of its catering boss, Brendan O'Regan. Before jets could cross the Atlantic in one hop, almost every transatlantic flight stopped here to refuel.")
    plaque(z, 45, 10, "limerick_bunratty_castle", "Bunratty Castle",
           "BUNRATTY CASTLE. A great tower house built around 1425 by the MacNamaras and later held by the O'Briens, Earls of Thomond. It was restored in the 1950s, and it has been serving medieval banquets since the 1960s.")
    plaque(z, 39, 9, "limerick_bunratty_folk_park", "Bunratty Folk Park",
           "BUNRATTY FOLK PARK. Farmhouses, a forge and a village street rebuilt as they stood in nineteenth-century Ireland. The thatch is real and so is the turf smoke, which gets into your coat and stays.")
    plaque(z, 59, 11, "limerick_durty_nellys", "Durty Nelly's",
           "DURTY NELLY'S. A pub at the castle bridge said to date from 1620, named for a woman who kept the toll on the bridge and a pot of something on the fire. The name has outlived any record of whether she was durty.")
    plaque(z, 30, 20, "limerick_shannon_dolphins", "The Shannon Dolphins",
           "THE SHANNON DOLPHINS. Over a hundred bottlenose dolphins live in the Shannon estuary all year round, Ireland's only known resident group. They hunt the channels on the tide. Please don't chase them; they're faster than you anyway.")
    plaque(z, 12, 23, "limerick_killimer_ferry", "The Killimer Ferry",
           "THE SHANNON FERRY. Since 1969 a car ferry has crossed the estuary between Killimer in Clare and Tarbert in Kerry, about twenty minutes over and saving a long drive round by Limerick.")
    plaque(z, 17, 41, "limerick_foynes_flying_boats", "Foynes Flying Boats",
           "FOYNES. From 1937 to 1945 this small port was one of the biggest civil airports in Europe: great flying boats landed on the estuary on their way across the Atlantic. The museum keeps a full-size replica of a Boeing 314 Clipper.")
    plaque(z, 27, 41, "limerick_irish_coffee", "The Birth of Irish Coffee",
           "IRISH COFFEE. One winter night in 1943 a flying boat to America turned back to Foynes in bad weather. The chef, Joe Sheridan, warmed the frozen passengers with coffee, whiskey, sugar and cream. Asked if it was Brazilian coffee, he said it was Irish coffee.")
    z.sign(62, 36, "THE ROAD ROUND. There's no bridge across the lower Shannon: drivers take the ferry, or go round by Limerick, where a tunnel has run under the river since 2010. This crossing is a Wildlore liberty. The dolphins don't mind it.")
    z.sign(38, 2, "BUNRATTY AND LIMERICK, EAST. GALWAY, NORTH. SHANNON AIRPORT, WEST. FOYNES, OVER THE WATER.")
    z.sign(67, 16, "LIMERICK CITY, EAST. Mind the cattle trucks.")
    # creature life on the shore
    for (sp, x, y, who, line) in [("heronarch", 6, 20, "Heron", "A grey heron stands in the mud as still as a fence post. It has been here since breakfast. It will be here at tea."),
                                   ("moolet", 20, 14, "Dairy Cow", "A Friesian of the Golden Vale chews thoughtfully. Somewhere in that chewing is your Irish coffee's cream."),
                                   ("moolet", 21, 13, "Dairy Cow", "This one is called Daisy. Every cow on this farm is called Daisy. It saves time.")]:
        creature(z, zid, sp, x, y, "still", line, who)
    # --- quests: dolphin watching (skipper, three pods, a speedboat) --------------------------------------
    person(z, "dolphin_skipper", "sailor", 13, 20, "Skipper Gráinne", facing="down", cmds=[
        flag_if("q_limerick_dolphins_done", say("Skipper Gráinne", "The pods are grand. Somebody's got their dorsal fins all catalogued, you know. Each one's notched different, like a fingerprint."), [
            flag_if("q_limerick_dolphins_4", say("Skipper Gráinne",
                    "You saw him off? Dónal and his speedboat? Fair play to you. Here, take these. And thank you, from me and from about a hundred and forty dolphins.")
                    + [give("water_snare", 5), give("limerick_ham", 2), stand(3)] + sets("q_limerick_dolphins_done")
                    + say("Skipper Gráinne", "Go easy, look, don't chase, let them come to you. That's the whole of dolphin watching."), [
                flag_if("q_limerick_dolphins_started", say("Skipper Gráinne",
                        "Three pods: off the mud east of here, down by the crossing, and off Foynes on the far shore. Then if you see a fella in a speedboat buzzing them, Dónal, have a word. A firm word."), [
                    *say("Skipper Gráinne", "Dia dhuit! I run the dolphin watch. The Shannon's got its own dolphins, did you know? Over a hundred, here all year, the only resident pod in Ireland.",
                         "I'm counting them for the survey. Will you spot three pods for me? Off the mud east of the slip, by the crossing, and off Foynes. Wade out if you've the legs for it, but don't crowd them."),
                    *sets("q_limerick_dolphins_started")])])])])
    for (nid, x, y, f, where) in [("dolphin_a", 30, 21, "q_limerick_dolphins_1", "off the Bunratty mud"),
                                  ("dolphin_b", 59, 34, "q_limerick_dolphins_2", "by the crossing"),
                                  ("dolphin_c", 20, 34, "q_limerick_dolphins_3", "off Foynes")]:
        _stand(z, x, y)
        z.npc(id=nid, sprite="creature:dolfeen", x=x, y=y, facing="down", move="still", script=nid, name="Bottlenose Dolphin")
        script(zid, nid, [flag_if(f, say("Dolphin", "The dolphin rolls, blows a fine spray, and pretends it hasn't seen you. It has."), [
            flag_if("q_limerick_dolphins_started",
                    say("", "A fin, then another, then a whole family arcing through the water %s. You note the pod for Skipper Gráinne's survey." % where) + sets(f),
                    say("Dolphin", "A bottlenose dolphin surfaces with a pfff and looks you over. It's a lot bigger than it looks from the road."))])])
    script_trainer("est_speedboat", "Speedboat Dónal", "Boat Owner", "surfer", [("bayrunner", 59), ("plungebeak", 58), ("severnshock", 58), ("dolfeen", 59)],
                   ["Ah, they love it! They love the wake! Do they? They do. Go on, prove me wrong."],
                   "Grand, grand. I'll keep to the speed limit. And the far side of the channel.",
                   "Gráinne says dolphins hear an engine for miles. Probably hate my music too.", 2600)
    person(z, "speedboat_donal", "surfer", 14, 35, "Speedboat Dónal", facing="up", cmds=[
        flag_if("q_limerick_dolphins_4", say("Speedboat Dónal", "I've taken up kayaking. It's very quiet. I hate it. The dolphins love it."), [
            flag_if("q_limerick_dolphins_3", [flag_if("q_limerick_dolphins_2", [flag_if("q_limerick_dolphins_1", [
                {"do": "battle", "trainer": "est_speedboat", "intro": True},
                flag_if("trainer_est_speedboat", sets("q_limerick_dolphins_4") + say("", "Dónal ties up his speedboat. The dolphins, somewhere out on the channel, carry on regardless."))],
                say("Speedboat Dónal", "Dolphins? Haven't seen any. Have you looked?"))],
                say("Speedboat Dónal", "Dolphins? Haven't seen any. Have you looked?"))],
                say("Speedboat Dónal", "Lovely day for a blast down the estuary. Vroom."))])])
    # --- quest: Irish coffee (the dairy farmer's cream) ---------------------------------------------------------
    person(z, "dairy_farmer", "farmer", 24, 16, "Dairy Farmer Pádraig", facing="down", cmds=[
        flag_if("q_limerick_coffee_started", [flag_if("q_limerick_coffee_1",
            say("Dairy Farmer Pádraig", "Float it, mind. Never stir an Irish coffee. You drink the hot through the cold. That's the magic."),
            say("Dairy Farmer Pádraig", "Cream for the Foynes coffee? Of course. Golden Vale cream, the richest grass in Ireland goes into that.",
                "Lightly whipped, so it'll float. Not stiff. Stiff cream sits on top like a hat.") + sets("q_limerick_coffee_1")
            + say("", "You've got a jug of cream for the chef at Foynes."))],
            say("Dairy Farmer Pádraig", "This is the Golden Vale, or the edge of it, the best dairy land in Ireland. Limestone under the grass, rain on top. The cows are very pleased with themselves.",
                "Half the butter on Irish tables starts with cows like these. The other half's lying."))])
    # --- the banquet's harpist, in the Folk Park ------------------------------------------------------------------
    person(z, "folk_harpist", "harpist", 44, 7, "Harpist Síle", facing="down", cmds=[
        flag_if("q_limerick_banquet_started", [flag_if("q_limerick_banquet_3",
            say("Harpist Síle", "I'll be there, tuned and fed. The harp's the national symbol, you know. It's on the coins and the passports. And the stout, which I don't mention at the banquet."),
            say("Harpist Síle", "Play for the banquet tonight? I will, of course. The Butler always forgets to ask till the soup's on.",
                "Turlough O'Carolan wrote two hundred tunes for the big houses, and he was blind from the age of eighteen. I play his Planxty for the toast.") + sets("q_limerick_banquet_3")
            + say("", "Síle the harpist will play at the banquet."))],
            say("Harpist Síle", "The wire-strung harp is older in Ireland than anyone can say for sure. I play gut strings. My great-great-grandmother would have something to say about that."))])
    # --- the Killimer and Tarbert ferry: a shortcut across the water -------------------------------------------
    person(z, "ferry_north", "sailor", 10, 22, "Ferryman", facing="down", cmds=say("Ferryman", "Killimer to Tarbert, twenty minutes, all aboard. The dolphins race us most days.")
           + [{"do": "choice", "text": "Cross to the Foynes side?", "options": ["All aboard", "Not today"], "set": "_shannon_ferry"},
              flag_if("_shannon_ferry", [], [{"do": "fade_out"}, {"do": "warp", "zone": zid, "x": 11, "y": 34, "facing": "down"}, {"do": "fade_in"}])])
    person(z, "ferry_south", "sailor", 10, 33, "Ferryman", facing="up", cmds=say("Ferryman", "Tarbert to Killimer, back over to Clare. Mind the step, it's wet. It's always wet.")
           + [{"do": "choice", "text": "Cross to the Clare side?", "options": ["All aboard", "Not today"], "set": "_shannon_ferry"},
              flag_if("_shannon_ferry", [], [{"do": "fade_out"}, {"do": "warp", "zone": zid, "x": 11, "y": 21, "facing": "up"}, {"do": "fade_in"}])])
    # chat
    person(z, "est_plane_spotter", "student", 28, 7, "Plane Spotter", facing="down", move="wander", radius=2, lines=[
        "Shannon's runway is over three kilometres long. It was a NASA emergency landing site for the Space Shuttle, you know. It never came. I waited anyway.",
        "Charles Lindbergh flew in to look at Foynes before the war. Everybody who was anybody came through here on the way to New York."])
    person(z, "est_folk_guide", "tour_guide", 41, 7, "Folk Park Guide", facing="right", lines=[
        "Those cottages are Clare and Limerick farmhouses, saved and moved here stone by stone. The half-door keeps the hens out and lets the news in.",
        "The thatch is reed and straw. A good thatch lasts twenty years if the jackdaws behave. They don't."])
    person(z, "est_mudlarker", "birdwatcher", 47, 20, "Wader Counter", facing="down", move="wander", radius=3, lines=[
        "The estuary mud's the richest larder in Ireland at low tide. Dunlin, godwits, curlew, lapwing, thousands of them, every winter.",
        "It's a Special Protection Area for the birds and a Special Area of Conservation for the dolphins. Very special, all round."])
    person(z, "est_foynes_local", "villager_3", 45, 41, "Foynes Local", facing="down", lines=[
        "My granny served tea to film stars off the flying boats. Maureen O'Hara's husband flew them, you know. Charles Blair. She ran the museum's honour after, God rest her.",
        "In the war, Ireland was neutral, so Foynes had passengers from both sides through the same lounge. My granny said the tea was strictly neutral too."], times=["dawn", "day", "dusk"])
    person(z, "est_cattle_jobber", "farmer", 66, 18, "Cattle Jobber", facing="left", lines=[
        "Off to the mart in Limerick. Grand city. King John's Castle, the Treaty Stone, and the best rugby supporters on God's earth. Ask them.",
        "Don't ask them in the middle of a match, mind."], times=["dawn", "day"])
    # trainers (scaled)
    trainer(z, "est_birder", "Birdwatcher Clodagh", "Birdwatcher", "birdwatcher", [("heronarch", 59), ("corncrake", 58), ("polartern", 58)],
            25, 20, "down", ["Twitcher's honour, I was here first. There's a black-tailed godwit on the mud. Battle quietly."],
            "Shh! You've scared the godwit. And me.", "Black-tailed godwits fly in from Iceland for the winter. Iceland! For this mud!", 2400)
    trainer(z, "est_pilot", "Pilot Eamon", "Pilot", "commuter", [("stormswift", 58), ("plungebeak", 59), ("railspark", 58)],
            20, 7, "down", ["Pre-flight checks: wings, wheels, a quick battle. Standard procedure."],
            "Turbulence. Seatbelts on, everybody.", "Flying in to Shannon over the estuary on a clear morning, you'd swear the whole country was green velvet.", 2450)
    trainer(z, "est_cyclist", "Cyclist Aoife", "Cyclist", "jogger", [("selkie", 58), ("gealhare", 59), ("versling", 58)],
            50, 44, "left", ["I'm doing the Shannon from source to sea. Three hundred and sixty kilometres. I'm on day nine. Battle me while my legs recover."],
            "Ah, my legs were the stronger half of my team.", "The Shannon rises in the Shannon Pot in County Cavan. It's a little round pool. You'd never guess.", 2420)
    trainer(z, "est_thatcher", "Thatcher Seosamh", "Thatcher", "farmer", [("rooklet", 58), ("strutcoo", 58), ("kidgruff", 59)],
            42, 16, "up", ["Twenty years I've thatched these cottages. The jackdaws undo it in five. A battle's nothing to me."],
            "Undone by a whippersnapper. Like a roof in a gale.", "Reed from the Shannon callows is the best thatch. Hard as nails and twice as straight.", 2380)
    z.d["edges"] = {"north": {"to": "galway", "offset": 0}, "east": {"to": "limerick", "offset": 0}}
    z.d["spawn"] = [35, 3]
    wild(z, [("moolet", 58, 59, 14, {}), ("corncrake", 58, 59, 8, {"time": ["dawn", "dusk"]}), ("crexling", 58, 58, 6, {"time": ["night", "dawn"]}),
             ("rooklet", 58, 59, 12, {}), ("gealhare", 58, 59, 10, {"time": ["dawn", "dusk"]}), ("versling", 58, 59, 6, {"time": ["dusk", "night"]}),
             ("cuppeen", 58, 58, 4, {"weather": ["drizzle", "downpour", "fog"]}), ("redbreast", 58, 59, 10, {}), ("starlet", 58, 59, 8, {"time": ["dusk"]}),
             ("chipgull", 58, 59, 10, {"time": ["day"]}), ("cluricaun", 58, 59, 4, {"time": ["night"]}), ("sheridram", 59, 59, 2, {"weather": ["fog"], "time": ["night"]})])
    wild(z, [("dolfeen", 58, 59, 20, {}), ("selkie", 58, 59, 12, {}), ("bradan", 58, 59, 10, {}), ("heronarch", 58, 59, 12, {}),
             ("plungebeak", 58, 59, 10, {"weather": ["gale", "clear"]}), ("parrlet", 58, 58, 8, {}), ("merrow", 58, 59, 4, {"time": ["night"], "weather": ["fog"]})], "water")
    finish(z)
    z.save(os.path.join(OUT, zid + ".json"))
    estuary_rooms()


def estuary_rooms():
    T = "shannon_estuary"
    # Bunratty Castle: the Great Hall and the banquet
    script_trainer("est_champion", "Sir Conor, the Earl's Champion", "Champion", "hurler",
                   [("stagmor", 60), ("rookery", 59), ("billgruff", 59), ("selkie", 59), ("megalorn", 60)],
                   ["By order of the Earl of Thomond: a guest who would feast must first face the Earl's champion. Or the dungeon. Your pick."],
                   "The Earl is satisfied. The dungeon will have to make do with the Butler.",
                   "A guest gets sent down to the dungeon every banquet, for some imagined crime. It's a great honour, apparently.", 3000)
    butler = [flag_if("q_limerick_banquet_done", say("The Butler", "My lady, my lord, the mead is poured and the champion is sulking. A fine banquet. Come back any night."), [
        flag_if("q_limerick_banquet_started", [flag_if("q_limerick_banquet_1", [flag_if("q_limerick_banquet_2", [flag_if("q_limerick_banquet_3", [
            *say("The Butler", "Mead, bread and a harper! Then let the banquet begin. Be upstanding for the Earl of Thomond!",
                 "Tradition demands a guest be found guilty of some crime and thrown in the dungeon. Tonight's accused is... you. The crime: eating soup without a spoon. Unless you can best the Earl's champion."),
            {"do": "battle", "trainer": "est_champion", "intro": True},
            flag_if("trainer_est_champion", say("The Butler", "Acquitted! The court rises. Mead all round, and a jug for our guest, and the Earl's thanks.")
                    + [give("bunratty_mead", 3), stand(3)] + sets("q_limerick_banquet_4", "q_limerick_banquet_done")
                    + say("The Butler", "No forks at a medieval banquet, mind. A knife, your fingers and a great deal of confidence."))],
            say("The Butler", "We have mead and bread. But a banquet without music is just a big dinner. Find the harpist in the Folk Park."))],
            say("The Butler", "Mead, yes. Bread, no. The bean an tí in the Folk Park cottage bakes the best brown bread in Clare. Ask her nicely."))],
            say("The Butler", "First, the mead. Durty Nelly's, over the bridge. Tell the barman the Butler sent you; he'll sigh, but he'll do it."))],
            say("The Butler", "Welcome to Bunratty! I am the Butler. Tonight there is a medieval banquet in the Great Hall, as there has been most nights since the 1960s.",
                "But I am short of three things: mead from Durty Nelly's, brown bread from the Folk Park, and a harpist. Could you fetch them? There'll be a seat at the high table in it.")
            + sets("q_limerick_banquet_started"))])]
    room("shannon_bunratty", "Bunratty Castle Great Hall", T, (50, 8), "castle", [
        ("bunratty_butler", "tour_guide", 7, 3, "down", "The Butler", butler),
        ("bunratty_wench", "villager_5", 3, 3, "right", "Banquet Singer", [
            "We sing between courses. The songs are old and the jokes are older. Grace before meat is sung in Latin, mostly to stop people starting on the bread.",
            "The tapestries are mostly from the fifteenth and sixteenth centuries. Lord Gort bought the castle in 1954 and filled it with medieval furniture. Very good furniture. Nobody's allowed to sit on it."]),
        ("bunratty_historian", "poet", 11, 5, "left", "Castle Historian", [
            "There's been a fort on this spot since the Vikings had a trading post here. This castle is the fourth on the site, built around 1425.",
            "The O'Briens took it in the 1500s and held it as Earls of Thomond. In 1646 Cromwell's side... well, Parliament's side, took it after a siege. The castle's seen a few dinners go badly."])],
        w=15, h=11,
        extra=[("table", 4, 6, {}), ("table", 5, 6, {}), ("table", 9, 6, {}), ("table", 10, 6, {}), ("bench", 4, 5, {}), ("bench", 10, 5, {}),
               ("candelabra", 3, 6, {}), ("candelabra", 11, 6, {}), ("harp", 1, 3, {}), ("brazier", 13, 3, {}), ("tomb_chest", 13, 7, {})])
    room("shannon_nellys", "Durty Nelly's", T, (62, 9), "cafe", [
        ("nellys_barman", "shopkeeper", 3, 1, "down", "Barman", [
            flag_if("q_limerick_banquet_started", [flag_if("q_limerick_banquet_1",
                say("Barman", "Another jug for the castle? The Butler's lucky I'm fond of him. What'll you have yourself?"),
                say("Barman", "The Butler sent you. Of course he did. Here: a jug of Bunratty mead, honey wine, the way the old earls drank it.",
                    "Mead's the oldest drink there is, they say. Honey, water and patience.") + sets("q_limerick_banquet_1")
                + say("", "You've got a jug of mead for the banquet."))], []),
            *say("Barman", "Welcome to Nelly's. Mead, coffee, tea, and a fire that's not been out since about the Famine."),
            {"do": "shop", "id": "shannon_nellys_bar"},
            *say("Barman", "Slán abhaile. Safe home.")]),
        ("nellys_trad", "fiddler", 9, 3, "down", "Session Fiddler", [
            "Tuesday's the trad session. Thursday's the trad session. Every day's the trad session if enough fiddles turn up.",
            "Clare music is slow and sweet, they say. They've never heard me after the third pint."]),
        ("est_regular", "villager_2", 10, 5, None, "Regular Mossie", None)])
    trainer_def_only("est_regular", "Regular Mossie", "Regular", "villager_2", [("cluricaun", 59), ("pooka", 58), ("moolet", 58)],
                     ["I've been coming here forty years. I'm practically a fixture. Mind your elbows."],
                     "Beaten on me own stool. Same again, so.", "Nelly's has a bit of a reputation. Most of it's my fault.", 2350)
    room("shannon_cottage", "Folk Park Cottage", T, (40, 5), "cottage", [
        ("bean_an_ti", "mum", 9, 3, "down", "Bean an Tí", [
            flag_if("q_limerick_banquet_started", [flag_if("q_limerick_banquet_2",
                say("Bean an Tí", "Mind the bread doesn't get dropped in the moat."),
                say("Bean an Tí", "Brown bread for the Butler? It's just out of the bastable. That's a pot oven, on the turf fire, with coals heaped on the lid.",
                    "Buttermilk, wholemeal, soda, salt. No yeast. And a cross cut on top to let the fairies out.") + sets("q_limerick_banquet_2")
                + say("", "You've got a warm loaf of brown bread for the banquet."))], []),
            *say("Bean an Tí", "Bean an tí, that's 'woman of the house'. Sit in by the fire. The kettle's always on the crane.",
                 "In the old days the fire never went out. It was raked over with ashes at night and blown back to life in the morning. Two hundred years, some hearths.")]),
        ("cottage_settle", "villager_4", 3, 4, "right", "Old Farmer", [
            "That's a settle bed. A bench by day, a bed by night, for whichever child lost the argument.",
            "The half-door? Top open for light and chat, bottom shut for the hens and the pig. Very civilised."])],
        extra=[("fireplace", 6, 1, {}), ("kitchen_dresser", 2, 1, {}), ("rug", 5, 3, {"w": 3, "h": 2, "variant": 1, "walk": True})])
    coffee = [flag_if("q_limerick_coffee_done", say("Chef Bríd", "Mind how you go. And the cream: float it, never stir."), [
        flag_if("q_limerick_coffee_started", [flag_if("q_limerick_coffee_1", [flag_if("q_limerick_coffee_2", [
            *say("Chef Bríd", "Cream from the farm and brown sugar from the duty free. Now. Show me you were listening."),
            {"do": "choice", "text": "What goes into the warmed glass first?", "options": ["The cream", "Brown sugar and hot coffee", "A splash of whiskey on its own"], "set": "_lim_cof"},
            flag_if("_lim_cof", [{"do": "if", "flag": "_lim_cof", "eq": 1, "then": [
                {"do": "choice", "text": "Stirred till the sugar's gone. Then?", "options": ["A good measure of Irish whiskey", "Ice", "Milk"], "set": "_lim_cof"},
                {"do": "if", "flag": "_lim_cof", "eq": 0, "then": [
                    {"do": "choice", "text": "And the cream?", "options": ["Stir it well in", "Float it over the back of a spoon", "A squirt from a can"], "set": "_lim_cof"},
                    {"do": "if", "flag": "_lim_cof", "eq": 1, "then": [
                        *say("Chef Bríd", "Hot through the cold. That's it, exactly as Joe Sheridan made it in 1943. Taste that.",
                             "Here, something came out of the steam while you were stirring. It seems to have taken a liking to you."),
                        {"do": "give_creature", "species": "cuppeen", "level": 50},
                        give("irish_coffee", 3), stand(3), *sets("q_limerick_coffee_3", "q_limerick_coffee_done")],
                     "else": say("Chef Bríd", "Ah, no. Joe Sheridan is turning in his grave. Come back and try again.")}],
                 "else": say("Chef Bríd", "Ice? Milk? In an Irish coffee? Away with you and try again.")}],
              "else": say("Chef Bríd", "Not first, no. Have another think and come back to me.")}],
                    say("Chef Bríd", "Not first, no. Have another think and come back to me."))],
            say("Chef Bríd", "Lovely cream. Now brown sugar: the duty-free shop at Shannon Airport, the first duty free in the world. Ask for the good stuff."))],
            say("Chef Bríd", "Cream first. Golden Vale cream, from the dairy farm north of the river. Lightly whipped, mind."))],
            say("Chef Bríd", "This is where Irish coffee was invented, did you know? 1943. A flying boat to America turned back in a winter storm, and Joe Sheridan, the chef, warmed the passengers up.",
                "A passenger asked was it Brazilian coffee. 'No,' says Joe, 'that's Irish coffee.' I make it the same way. Will you help me make a proper one?",
                "I need cream from the dairy farm north of the river, and brown sugar from the duty free at Shannon Airport.")
            + sets("q_limerick_coffee_started"))])]
    room("shannon_foynes", "Foynes Flying Boat Museum", T, (22, 40), "museum", [
        ("foynes_chef", "shopkeeper", 3, 3, "down", "Chef Bríd", coffee),
        ("foynes_curator", "tour_guide", 11, 3, "down", "Museum Curator", [
            "The flying boats came in from 1937. Pan Am's Yankee Clipper, the Boeing 314, carried seventy-odd passengers in luxury: a dining room, beds, a honeymoon suite at the back.",
            "In 1939 the first scheduled passenger flights across the Atlantic landed here. The radio and weather room upstairs is how it was, all valves and Morse."]),
        ("foynes_pilot", "commuter", 8, 5, "left", "Retired Navigator", [
            "Navigating a flying boat across the Atlantic was dead reckoning and star sights. You'd take a sextant to the window and pray for a gap in the clouds.",
            "Coming home to Foynes on the Shannon at dawn was the loveliest sight in the world. The water flat as a plate. Then breakfast."])],
        w=15, extra=[("display_case", 2, 5, {"variant": 1}), ("display_case", 12, 5, {"variant": 2}), ("wall_map", 7, 1, {"walk": True}), ("telescope", 13, 1, {})])
    room("shannon_airport", "Shannon Airport", T, (10, 10), "hall", [
        ("duty_free", "shopkeeper", 3, 3, "down", "Duty Free Assistant", [
            flag_if("q_limerick_coffee_started", [flag_if("q_limerick_coffee_2",
                say("Duty Free Assistant", "Enjoy the coffee! Tell Bríd we said hello."),
                say("Duty Free Assistant", "Brown sugar for Chef Bríd? Coming up. It's on the house: we owe Foynes, really. Shannon took over when the flying boats stopped.") + sets("q_limerick_coffee_2")
                + say("", "You've got a bag of brown sugar for the Irish coffee."))],
                say("Duty Free Assistant", "Welcome to the world's first duty-free shop! Opened 1947. Whiskey, perfume, cheese, a remarkable number of leprechauns.")),
            *say("Duty Free Assistant", "Brendan O'Regan thought it up: let the transatlantic passengers buy without tax while the plane refuels. Now every airport has one. You're welcome, world.")]),
        ("airport_announcer", "commuter", 11, 3, "down", "Gate Agent", [
            "Shannon has US preclearance: you go through American immigration here, before you fly. You land in America like a domestic passenger. Very handy.",
            "Before the jets, nearly every flight between Europe and North America stopped here for fuel. Shannon was the doorway to the New World. Now it's a doorway with a very good shop."]),
        ("airport_child", "villager_6", 4, 6, "right", "Excited Child", [
            "I'm going to Boston to see my aunties! There are more Irish people in America than in Ireland, my da says. They all want to see me."])],
        w=15, extra=[("bench", 6, 5, {}), ("bench", 8, 5, {}), ("plant_stand", 13, 6, {}), ("display_case", 1, 5, {"variant": 0})])


def trainer_def_only(tid, name, cls, sprite, party, intro, win, after, money):
    TRN[tid] = {"id": tid, "name": name, "class": cls, "sprite": sprite,
                "party": [{"species": s, "level": l} for s, l in party], "ai": "trainer", "money": money,
                "intro": say(name, *intro), "win": win, "after": after}


# --- Limerick (city) ------------------------------------------------------------------------------------------

def limerick():
    W, H = 72, 56
    zid = "limerick"
    z = Z(zid, "Limerick", W, H, kind="town", region=IRL, music="town_ireland",
          weather={"drizzle": 30, "clear": 22, "sunshine": 12, "gale": 10, "fog": 8, "downpour": 18})
    z.d["stage"] = "town"; z.d["town_id"] = "limerick"; z.d["scaled_floor"] = FLOOR
    z.legend["k"] = {"tile": "grass", "colour": "#6e8f48"}
    z.legend["q"] = {"tile": "cobbles", "colour": "#a7a399"}    # limestone quays
    z.rect(0, 0, W, H, "k")
    z.border("T", 2, gaps=[(0, 17, 2, 3), (40, 54, 3, 2)])
    z.scatter(0, 0, W, H, "P", 12, 5, only="T")
    # the Shannon, north to south, and the Abbey River round King's Island
    z.rect(18, 0, 5, H, "~")
    z.rect(23, 21, 47, 2, "~")
    z.rect(17, 2, 1, 52, "q"); z.rect(23, 2, 1, 19, "q"); z.rect(23, 23, 1, 31, "q")
    z.rect(17, 44, 1, 9, "o"); z.rect(23, 44, 1, 9, "o")
    # Thomond Bridge and the roads
    z.rect(0, 17, 70, 3, "=")
    z.rect(40, 17, 3, 39, "=")
    z.rect(30, 21, 2, 2, ":")            # Matthew Bridge
    z.rect(60, 21, 2, 2, ":")            # Baal's Bridge, more or less
    # --- the west bank (Thomondgate): the Treaty Stone, Thomond Park, Ardnacrusha
    bld(z, 3, 3, 12, 6, "thomond_stadium", "Thomond Park", door=6, kind="hall", to="limerick_thomond", room=(17, 12))
    z.rect(2, 9, 15, 1, ":"); z.rect(9, 10, 1, 7, ":")
    z.rect(12, 13, 5, 4, ":")
    z.prop("standing_stone", 14, 14, variant=1)
    z.prop("lamp_post", 12, 13); z.prop("lamp_post", 16, 16)
    bld(z, 3, 27, 11, 5, "hydro_station", "Ardnacrusha Power Station", door=5, kind="mill", to="limerick_ardnacrusha", room=(15, 10))
    z.rect(2, 32, 15, 1, ":"); z.rect(16, 20, 1, 13, ":")
    z.rect(3, 22, 12, 4, ","); z.rect(3, 36, 13, 7, ","); z.rect(3, 45, 13, 8, ",")
    z.rect(9, 33, 1, 3, ":")
    # --- King's Island: King John's Castle and St Mary's Cathedral
    bld(z, 24, 3, 12, 7, "king_johns", "King John's Castle", door=6, kind="castle", to="limerick_kingjohn", room=(15, 10))
    z.rect(24, 10, 46, 2, ":")
    bld(z, 43, 3, 9, 6, "cathedral", "St Mary's Cathedral", door=4, kind="church", to="limerick_stmarys", room=(15, 10))
    bld(z, 55, 4, 5, 3, "stone", show=False)
    bld(z, 61, 4, 5, 3, "slate_cottage", show=False)
    z.rect(30, 12, 1, 5, ":"); z.rect(47, 12, 1, 5, ":"); z.rect(63, 12, 1, 5, ":")
    z.rect(24, 13, 5, 3, "f"); z.rect(50, 13, 9, 3, ",")
    for (x, y) in [(29, 12), (36, 12), (42, 12), (53, 12)]:
        z.prop("lamp_post", x, y)
    # --- the Georgian city south of the Abbey River (Newtown Pery)
    for y in (29, 35, 42):
        z.rect(24, y, 46, 2, ":")
    z.rect(24, 23, 46, 1, "q")
    bld(z, 24, 24, 9, 4, "stone", "Hunt Museum", door=4, kind="museum", to="limerick_hunt", room=(15, 10))
    bld(z, 50, 24, 11, 5, "milk_market", "Milk Market", door=5, kind="hall", to="limerick_milkmarket", room=(17, 11))
    bld(z, 34, 24, 5, 4, "georgian_brick", show=False)
    bld(z, 44, 24, 5, 4, "georgian_brick", show=False)
    bld(z, 62, 24, 7, 4, "georgian_brick", show=False)
    bld(z, 24, 31, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(27, 34, "limerick_sanctuary", 5, 6, "up")
    bld(z, 31, 31, 4, 4, "shop", "Corner Shop", door=2)
    z.warp(33, 34, "limerick_shop", 4, 5, "up")
    bld(z, 44, 31, 6, 4, "georgian_brick", "The Poet's Rest", door=2, kind="cafe", to="limerick_poets")
    bld(z, 51, 31, 7, 4, "stone", "Frank McCourt Museum", door=3, kind="school", to="limerick_mccourt")
    bld(z, 59, 31, 10, 4, "georgian_brick", show=False)
    bld(z, 24, 38, 7, 4, "georgian_brick", "Pery Square", door=3, kind="home", to="limerick_home_pery")
    bld(z, 32, 38, 7, 4, "georgian_brick", show=False)
    bld(z, 44, 38, 7, 4, "georgian_brick", show=False)
    bld(z, 52, 38, 7, 4, "georgian_brick", show=False)
    bld(z, 60, 38, 9, 4, "georgian_brick", show=False)
    # Colbert Station
    pf = station(z, 26, 46, 8, 4, "Colbert Station")
    z.rect(25, 44, 10, 2, ":")
    z.prop("buffer_stop", 25, 49); z.prop("buffer_stop", 34, 49)
    rail_guard(z, 31, 48, ["Colbert Station, named for Con Colbert, one of the leaders executed after the 1916 Rising. Born in County Limerick.",
                           "The Wildlore rail runs to any town on this island you have visited. Where to?"])
    # People's Park
    z.rect(44, 44, 14, 9, "k"); z.rect(44, 44, 14, 1, ":"); z.rect(50, 44, 2, 9, "#"); z.rect(44, 48, 14, 1, "#")
    z.rect(45, 45, 4, 3, "f"); z.rect(53, 49, 4, 3, "f")
    z.prop("statue", 50, 48, variant=1)
    for (x, y) in [(45, 50), (47, 52), (56, 45), (55, 47)]:
        z.prop("oak", x, y, variant=(x + y) % 3)
    z.prop("bench", 49, 46); z.prop("bench", 52, 50)
    z.rect(59, 44, 10, 9, ",")
    for (x, y) in [(26, 30), (38, 30), (49, 30), (60, 30), (26, 36), (49, 36), (63, 36), (39, 43), (44, 43)]:
        z.prop("lamp_post", x, y)
    z.prop("post_box", 36, 36); z.prop("phone_box", 38, 37); z.prop("noticeboard", 37, 31)
    z.prop("bunting", 50, 30, variant=4, walk=True)
    # plaques and signs
    plaque(z, 13, 16, "limerick_treaty_stone", "The Treaty Stone",
           "THE TREATY STONE. The Treaty of Limerick ended the Williamite War in Ireland on 3 October 1691, and tradition says it was signed on this very stone. Its promises to Catholics were soon broken, and Limerick is still called the City of the Broken Treaty.")
    plaque(z, 36, 11, "limerick_king_johns_castle", "King John's Castle",
           "KING JOHN'S CASTLE. Built for King John in the early 1200s to guard the crossing of the Shannon. It held out through sieges in 1642, 1651 and 1690 to 1691, and you can still see where the walls were mined.")
    plaque(z, 42, 9, "limerick_st_marys", "St Mary's Cathedral",
           "ST MARY'S CATHEDRAL. Founded in 1168 by Dónall Mór Ó Briain, King of Munster, on the site of his palace. It is the oldest building in Limerick still in daily use, and keeps a set of carved fifteenth-century misericords, the only medieval set left in Ireland.")
    plaque(z, 33, 28, "limerick_hunt_museum", "The Hunt Museum",
           "THE HUNT MUSEUM. The collection of John and Gertrude Hunt, about two thousand pieces from the Stone Age to the twentieth century, shown in the Georgian Custom House of the 1760s on the river.")
    plaque(z, 61, 29, "limerick_milk_market", "The Milk Market",
           "THE MILK MARKET. Market day has drawn the county into this square since 1852. Under the big canopy you'll find farm cheese, Limerick ham, soda bread, coffee and people who know exactly what you should be cooking.")
    plaque(z, 58, 35, "limerick_angelas_ashes", "Angela's Ashes",
           "ANGELA'S ASHES. Frank McCourt's memoir of a poor Limerick childhood in the 1930s and 40s won the Pulitzer Prize in 1997. He went to Leamy's School here, now the Frank McCourt Museum. Not everybody in Limerick liked how he told it.")
    plaque(z, 16, 21, "limerick_river_shannon", "The River Shannon",
           "THE RIVER SHANNON. The longest river in Ireland and in Britain too, about 360 kilometres from the Shannon Pot in County Cavan to the sea beyond Loop Head. It drains a fifth of the whole island.")
    plaque(z, 14, 33, "limerick_ardnacrusha", "Ardnacrusha",
           "ARDNACRUSHA. A few kilometres upriver, the Shannon Scheme power station was built by Siemens and opened in 1929, then the largest hydroelectric station in the world. It lit up the young Irish Free State.")
    plaque(z, 9, 10, "limerick_thomond_park", "Thomond Park",
           "THOMOND PARK. Home of Munster rugby. On 31 October 1978 Munster beat the touring New Zealand All Blacks here, 12 points to nil, the first Irish side ever to beat them. Plenty more people say they were there than the ground could hold.")
    plaque(z, 39, 34, "limerick_the_limerick", "The Limerick",
           "THE LIMERICK. Five lines, A A B B A, and usually rude. Edward Lear made the form famous in 1846. Whether it is named after the city, perhaps from an old party song, 'Will you come up to Limerick?', nobody can prove. The city is happy to take the credit.")
    plaque(z, 62, 36, "limerick_ham", "Limerick Ham",
           "LIMERICK HAM. In the nineteenth century Limerick's bacon factories made the city's cured ham famous across the world. It was smoked over oak shavings and juniper berries, and boiled with cabbage for the Sunday dinner.")
    plaque(z, 35, 43, "limerick_lace", "Limerick Lace",
           "LIMERICK LACE. Brought here in 1829, this fine lace embroidered on machine-made net became a fashion all over Victorian Britain and Ireland. The Sisters of Mercy kept the craft alive when the factories closed.")
    z.sign(3, 18, "LIMERICK, LUIMNEACH: 'the bare spot of land' by the river. WEST TO BUNRATTY AND THE ESTUARY.")
    z.sign(39, 52, "SOUTH TO LOUGH GUR, twenty kilometres or so. Stone circles, a lake with a sleeping earl in it, and the best picnic spot in Munster.")
    # NPCs: locals who teach
    person(z, "lim_treaty_guide", "tour_guide", 12, 15, "Treaty Stone Guide", facing="right", lines=[
        "After the Battle of the Boyne, the Jacobite army held Limerick through two sieges. Patrick Sarsfield led the defence. He's a hero here. There's a statue and a bridge and a great many pubs.",
        "The Treaty let the soldiers sail to France with honour, the Wild Geese, they called them. The civil articles for the Catholics who stayed were never honoured. Hence the Broken Treaty."])
    person(z, "lim_rugby_fan", "rugby_player", 11, 11, "Munster Supporter", facing="down", lines=[
        "Thomond Park is famous for its silence. When a Munster man is kicking for goal, twenty-five thousand people go so quiet you could hear a pin drop on the hallowed sod.",
        "The anthem's 'Stand Up and Fight'. Sung loud. Usually just before we do."])
    person(z, "lim_hurling_fan", "hurler", 39, 26, "Hurling Fan", facing="right", lines=[
        "Limerick won the All-Ireland hurling in 2018 and then four in a row, 2020 to 2023. I've been hoarse since 2018.",
        "Hurling's the fastest field game on grass. A sliotar can go a hundred and fifty kilometres an hour. My nerves can't."])
    person(z, "lim_lace_maker", "villager_5", 31, 43, "Lace Maker", facing="down", lines=[
        "Limerick lace is needlework on net, tambour or needle-run. It took a girl months to make a veil. Queen Victoria had some, of course.",
        "It's slow work. You can't rush lace. You can't rush a lace maker either. Try."])
    person(z, "lim_river_warden", "angler", 23, 26, "River Warden", facing="left", lines=[
        "That's the Shannon. Biggest river on these islands. It drops about a hundred metres from source to sea and most of that drop is right here, at Ardnacrusha and the rapids.",
        "The salmon used to run up past the castle in their thousands. They're fewer now. We're working on it, and so are they."])
    person(z, "lim_verse_scholar", "student", 48, 36, "Student of Verse", facing="down", lines=[
        "Did the limerick come from Limerick? Ah. That's the question. There was a parlour game where each guest made up a verse and everybody sang 'Will you come up to Limerick?'. Maybe. Possibly. Nobody can prove a thing.",
        "Here's one for you: 'The limerick's a curious beast, / From the city, or not in the least. / Though the name's a mystery, / We'll take it for history, / And we'll celebrate with a big feast.' I'm working on it."])
    person(z, "lim_mccourt_fan", "poet", 55, 36, "Book Lover", facing="up", lines=[
        "'Worse than the ordinary miserable childhood is the miserable Irish childhood, and worse yet is the miserable Irish Catholic childhood.' That's the start of Angela's Ashes.",
        "The lanes he wrote about are long gone. The rain he wrote about is still here. Bring a coat."])
    person(z, "lim_butcher", "villager_1", 64, 30, "Butcher", facing="down", lines=[
        "Limerick ham, boiled, then glazed and baked, with cabbage and parsley sauce. The Sunday dinner of your dreams.",
        "Limerick was called Pigtown once, for all the bacon factories. We say it with pride. Mostly."], times=["dawn", "day"])
    person(z, "lim_engineer", "steelworker", 9, 34, "Retired Engineer", facing="up", lines=[
        "Ardnacrusha was the biggest engineering job the new state had ever done. German engineers, Irish labourers, five years of digging canals.",
        "When it opened, there was talk it was too big for the country. Within a decade it was supplying most of Ireland's electricity. Somebody owed somebody an apology."])
    # trainers
    trainer(z, "lim_hurler", "Hurler Cian", "Hurler", "hurler", [("stagmor", 59), ("dextera", 58), ("raidtail", 58)],
            42, 33, "left", ["Limerick! Limerick! Sorry, I'm still celebrating. Which year? All of them."],
            "A clean strike. Fair play.", "You need a good first touch in hurling. And in battles. And in life, really.", 2450)
    trainer(z, "lim_student", "Student Saoirse", "Student", "student", [("versling", 58), ("rooklet", 58), ("binfox", 59)],
            53, 13, "down", ["I'm studying at the University of Limerick. I've an essay due. A battle is research, if you squint."],
            "Two thousand words on why I lost. Easy.", "UL's campus has a bridge across the Shannon. Very handy for dramatic walks home.", 2380)
    trainer(z, "lim_busker", "Busker Ronan", "Busker", "fiddler", [("cluricaun", 58), ("starlet", 59), ("versling", 59)],
            41, 37, "down", ["I'll play you a tune. Or battle you. The crowd prefers the battle, which says something about my tunes."],
            "I'll stick to the fiddle.", "The Cranberries came from Limerick, you know. Every busker in town owes them a few euro.", 2400)
    trainer(z, "lim_legend", "Nora of the Treaty Stone", "Local Legend", "keeper_nuala",
            [("rhymerick", 61), ("estuarch", 61), ("sheridram", 60), ("stagmor", 60), ("samsonian", 60), ("bansheen", 61)],
            15, 14, "left", ["Three hundred years and more this stone has stood here. I've stood here a fair while myself. Beat me and you'll have the city's respect. Lose and you'll have its sympathy, which is worse."],
            "Well. The city will be talking. They always are.",
            "Sarsfield said, after the Treaty, 'Change kings with us, and we'll fight you again.' I feel the same about battles.", 4800)
    z.d["edges"] = {"west": {"to": "shannon_estuary", "offset": 0}, "south": {"to": "lough_gur", "offset": 0}}
    z.d["spawn"] = [41, 25]
    wild(z, [("versling", 58, 59, 12, {"time": ["dusk", "night"]}), ("chipgull", 58, 59, 14, {"time": ["day"]}), ("rooklet", 58, 59, 10, {}),
             ("binfox", 58, 59, 10, {"time": ["night", "dusk"]}), ("pipkin", 58, 59, 10, {}), ("strutcoo", 58, 59, 10, {}),
             ("raidtail", 58, 59, 8, {}), ("cluricaun", 58, 59, 5, {"time": ["night"]}), ("starlet", 58, 59, 8, {"time": ["dusk"]}),
             ("redbreast", 58, 59, 8, {}), ("rhymerick", 59, 59, 3, {"time": ["night"]})])
    wild(z, [("estuarch", 58, 59, 6, {}), ("bradan", 58, 59, 16, {}), ("heronarch", 58, 59, 14, {}), ("rillotter", 58, 59, 12, {}),
             ("spatelord", 58, 59, 8, {"time": ["night"]})], "water")
    finish(z)
    z.save(os.path.join(OUT, zid + ".json"))
    sanctuary(OUT, "limerick", "Limerick", (27, 35))
    shop(OUT, "limerick", "Limerick", (33, 35))
    nurse("limerick", ["Fáilte go Luimneach! That's 'welcome to Limerick'. You've a tired look about you. Pop them on the counter.",
                       "Sit down there. There's tea in the pot and a biscuit if you're quick.",
                       "Right as rain. Which is handy, because it's raining.",
                       "The Ark's in the corner, behind the umbrella stand.",
                       "Grand so. Mind yourself on the quays."])
    shopkeeper("limerick", "How's it going? Limerick ham, Irish coffee, snares and the usual. Ham's very good today.",
               "Slán! Up Munster!")
    limerick_rooms()


def limerick_rooms():
    T = "limerick"
    room("limerick_kingjohn", "King John's Castle", T, (30, 9), "castle", [
        ("kj_guide", "tour_guide", 11, 3, "down", "Castle Guide", [
            flag_if("q_limerick_verse_started", [flag_if("q_limerick_verse_1",
                say("Castle Guide", "How's the poem coming? If you need a rhyme for 'castle', I've been looking for forty years. There isn't one. Not a decent one."),
                say("Castle Guide", "A first line for Máire's limerick night? Well, they always want the castle in it. Here:",
                    "'A young trainer who came to King John's...'", "That's da-DUM-da-da-DUM-da-da-DUM. Take it to Máire; she'll do the rest with you.")
                + sets("q_limerick_verse_1") + say("", "You learnt a first line: 'A young trainer who came to King John's'."))], []),
            *say("Castle Guide", "King John never actually set foot in his castle, as far as anyone knows. Very typical of a landlord.",
                 "Down in the excavations you can see the mine and countermine from the 1642 siege. The Confederates dug under the walls and the defenders dug to meet them. In the dark. With shovels.")]),
        ("kj_reenactor", "warden_grunt", 3, 3, "right", "Re-enactor", [
            "I'm a Williamite soldier, 1690. Tomorrow I'm a Jacobite. The pay's the same either way, which is very historically accurate.",
            "In the 1690 siege the women of Limerick fought on the walls and threw bottles and stones at the attackers. They're on the pub signs now."]),
        ("lim_castle_knight", "hurler", 9, 5, None, "Knight Errant Fergal", None)],
        w=15, extra=[("brazier", 1, 2, {}), ("display_case", 13, 5, {"variant": 2}), ("candelabra", 2, 6, {})])
    trainer_def_only("lim_castle_knight", "Knight Errant Fergal", "Re-enactor", "hurler", [("stagmor", 58), ("cutlet", 59), ("steelheart", 59)],
                     ["Halt! Who goes there? You do, apparently. Have at you!"],
                     "I yield! My chainmail is knitted. Don't tell anyone.", "The real chainmail's in the museum. Forty kilos. I'd last ten minutes.", 2500)
    room("limerick_stmarys", "St Mary's Cathedral", T, (47, 8), "church", [
        ("stmarys_verger", "choir_singer", 7, 2, "down", "Verger", [
            "St Mary's was founded in 1168 by Dónall Mór Ó Briain, on the site of his own palace. Bits of the palace doorway are in the west wall still.",
            "Come and see the misericords: carved black oak seats from the 1400s. The choir could lean on the ledge during long services and look as if they were standing. Medieval ingenuity."]),
        ("stmarys_carver", "poet", 12, 5, "left", "Wood Carver", [
            "The misericords have all sorts carved under them: a wyvern, a swan, a boar, and a few creatures I wouldn't describe in church.",
            "Twenty-three of them survive. The only medieval set in Ireland. I'm not allowed to touch them, which is a cruelty to a carver."])],
        w=15, extra=[("candelabra", 3, 1, {}), ("candelabra", 11, 1, {}), ("tomb_chest", 13, 7, {})])
    room("limerick_hunt", "The Hunt Museum", T, (28, 27), "museum", [
        ("hunt_curator", "tour_guide", 7, 2, "down", "Curator", [
            "John and Gertrude Hunt were collectors and dealers. They gave everything they'd gathered to the people of Ireland: Bronze Age gold, medieval crosses, a Picasso, a Renoir, and a great deal of very small, very old things.",
            "The building's the old Custom House, 1760s, by the river. When the ships came in, the taxman was right here. Now it's art. A big improvement in my view."]),
        ("hunt_child", "villager_6", 3, 5, "right", "School Visitor", [
            "There's a tiny bronze horse in there that's about four hundred years old. I'm going to draw it. Then I'm going to the café."])],
        w=15, extra=[("display_case", 2, 3, {"variant": 0}), ("display_case", 12, 3, {"variant": 1}), ("display_case", 12, 6, {"variant": 2})])
    script_trainer("lim_bard", "Bard Ruairí", "Bard", "poet", [("versling", 59), ("rhymerick", 60), ("cluricaun", 59), ("bansheen", 59)],
                   ["A verse-off! Recite, and then we battle, and the crowd decides. Ready? 'There once was a bard of the market...' Your go. Then your team."],
                   "The crowd's spoken. They want yours. I want a lie down.",
                   "I've a limerick for every stall in this market. The cheese one's filthy. Ask me after the watershed.", 3000)
    bard = [flag_if("q_limerick_verse_3", say("Bard Ruairí", "Your verse is going round the market already. Somebody's put it on a tea towel."), [
        flag_if("q_limerick_verse_2", [
            *say("Bard Ruairí", "Máire sent you? With a new limerick? Then stand up on that crate and give it to the crowd. Then you face me."),
            *say("", "You recite: 'A young trainer who came to King John's / Brought a team made of ducks and of swans. / They hissed at the gate, / And a guard yelled, \"Ye're late!\" / And they guard it themselves now with wands.'"),
            *say("Market Crowd", "Ha! Wands! Go on, Ruairí, top that!"),
            {"do": "battle", "trainer": "lim_bard", "intro": True},
            flag_if("trainer_lim_bard", sets("q_limerick_verse_3") + say("", "The Milk Market gives you a round of applause and a free scone. Back to Máire at the Poet's Rest."))],
            say("Bard Ruairí", "Market day's for verse and cheese. Come back when you've a limerick of your own. Máire at the Poet's Rest will set you right."))])]
    room("limerick_milkmarket", "The Milk Market", T, (55, 28), "hall", [
        ("milk_bard", "poet", 8, 2, "down", "Bard Ruairí", bard),
        ("milk_cheese", "shopkeeper", 3, 3, "down", "Cheesemonger", [
            "Farmhouse cheese from Clare and Limerick and Cork. This one's washed in cider. This one's washed in sea water. This one, I'd rather not say.",
            "Saturday's the big day. The whole county's in here by nine. By ten there's no parking from here to Ennis."]),
        ("milk_baker", "villager_4", 13, 3, "down", "Baker", [
            "Brown soda bread, white soda farls, barmbrack, and a tart that'll make your granny jealous.",
            "The market's been here since 1852. The canopy's newer. The rain is the original."]),
        ("lim_stallholder", "farmer", 12, 6, None, "Stallholder Bríd", None)],
        w=17, h=11,
        extra=[("market_stall", 2, 2, {"variant": 0}), ("market_stall", 4, 2, {"variant": 1}), ("market_stall", 12, 2, {"variant": 2}),
               ("market_stall", 14, 2, {"variant": 0}), ("market_stall", 3, 6, {"variant": 1}), ("market_stall", 13, 6, {"variant": 2})], furnish=False)
    trainer_def_only("lim_stallholder", "Stallholder Bríd", "Stallholder", "farmer", [("moolet", 59), ("pipkin", 58), ("cuppeen", 58)],
                     ["Free sample? It's a battle. Everything's a free sample on market day."],
                     "Grand. Take a scone for your trouble.", "Buy local, battle local. That's my motto. It's on the apron.", 2420)
    verse = [flag_if("q_limerick_verse_done", say("Poet Máire", "There's a trainer who came to King John's... I'll be humming it for weeks. Thank you."), [
        flag_if("q_limerick_verse_3", say("Poet Máire", "Ruairí beaten and the market laughing! That's a limerick doing its job. Here: a Munster scrum cap, and a scrap of Limerick lace for luck. You're a poet now. God help us.")
                + [give("thomond_scrum_cap"), give("limerick_lace", 2), stand(4)] + sets("q_limerick_verse_done"), [
            flag_if("q_limerick_verse_2", say("Poet Máire", "Off to the Milk Market with it! Ruairí the bard holds court there. Recite it to the crowd, then see him off."), [
                flag_if("q_limerick_verse_1", [
                    *say("Poet Máire", "'A young trainer who came to King John's.' Lovely. Now. Line two has to rhyme with 'John's' and keep the bounce."),
                    {"do": "choice", "text": "Line two: 'Brought a team made of...'", "options": ["...geese and three hens", "...ducks and of swans", "...a bull called Big Ben"], "set": "_lim_verse"},
                    {"do": "if", "flag": "_lim_verse", "eq": 1, "then": [
                        *say("Poet Máire", "'Ducks and of swans.' Perfect. Lines three and four are short and rhyme with each other. I'll give you three: 'They hissed at the gate,'"),
                        {"do": "choice", "text": "Line four:", "options": ["And a guard yelled, \"Ye're late!\"", "And one bit a guard on the bum", "Which upset the man on duty"], "set": "_lim_verse"},
                        {"do": "if", "flag": "_lim_verse", "eq": 0, "then": [
                            *say("Poet Máire", "Ha! Now the last line. It has to rhyme with John's and swans, and it has to land the joke."),
                            {"do": "choice", "text": "Line five:", "options": ["So they all went home for a nap.", "And they guard it themselves now with wands.", "And King John said a very rude word."], "set": "_lim_verse"},
                            {"do": "if", "flag": "_lim_verse", "eq": 1, "then": say("Poet Máire",
                                "'A young trainer who came to King John's / Brought a team made of ducks and of swans. / They hissed at the gate, / And a guard yelled, \"Ye're late!\" / And they guard it themselves now with wands.'",
                                "Wands! It's nonsense. It's perfect. Now go and try it on the Milk Market crowd. If Ruairí the bard doesn't heckle you off the crate, it's a keeper.") + sets("q_limerick_verse_2"),
                             "else": say("Poet Máire", "The rude word, I'll allow. But it has to rhyme, pet. Have a think and come back.")}],
                         "else": say("Poet Máire", "Ha! Filthy. And it doesn't rhyme. Save it for the second verse. Have a think and come back.")}],
                     "else": say("Poet Máire", "It doesn't rhyme with John's, does it? Say them out loud. Go on. Have a think and come back to me.")}],
                    [flag_if("q_limerick_verse_started", say("Poet Máire", "King John's Castle first. The guide has a first line for you; he's been sitting on it for years."),
                            say("Poet Máire", "Welcome to the Poet's Rest. Tonight's limerick night, and I'm a verse short. Five lines: one, two and five rhyme; three and four are short and rhyme with each other.",
                                "Nobody can prove the limerick comes from Limerick. We've decided not to let that stop us.",
                                "Will you write one with me? Get a first line from the guide at King John's Castle. He's been dying to be asked.")
                            + sets("q_limerick_verse_started"))])])])])]
    room("limerick_poets", "The Poet's Rest", T, (46, 34), "cafe", [
        ("poet_maire", "sean_nos_singer", 9, 3, "down", "Poet Máire", verse),
        ("poets_quizmaster", "ceilidh_caller", 3, 5, "right", "Quizmaster", [
            *say("Quizmaster", "Pub quiz, every night bar Sunday. Questions on the whole of these islands, and a few on Limerick, of course."),
            {"do": "quiz", "pub": "limerick_poets", "region": "ireland", "who": "Quizmaster"}]),
        ("poets_regular", "villager_1", 11, 5, "left", "Old Regular", [
            "There was an old man from Thomondgate / Who drank till a quarter past eight. / He went home to bed, / With a hat on his head... I forget the rest. It's very good, the rest."])])
    room("limerick_mccourt", "Frank McCourt Museum", T, (54, 34), "school", [
        ("mccourt_guide", "tour_guide", 6, 2, "down", "Museum Guide", [
            "This was Leamy's School, where Frank McCourt went as a boy. We've a classroom set up as it was in the 1930s: inkwells, slates and a master with a strap.",
            "Frank grew up in the lanes, emigrated to New York at nineteen, taught in schools there for thirty years and then wrote it all down. Angela's Ashes came out in 1996 when he was sixty-six. Never too late."]),
        ("mccourt_reader", "student", 10, 5, "left", "Reader", [
            "'Tis, the sequel, is about New York. Teacher Man is about teaching. I've read all three twice. My copy of Angela's Ashes is mostly sellotape."])])
    room("limerick_thomond", "Thomond Park", T, (9, 8), "hall", [
        ("thomond_groundsman", "farmer", 3, 8, "right", "Groundsman", [
            "31 October 1978. Munster 12, New Zealand 0. Christy Cantillon scored the try, Tony Ward kicked the conversion and two drop goals. The All Blacks had never lost to an Irish side.",
            "There's a play about it, 'Alone It Stands', with six actors doing the whole match. I've seen it nine times. I cried at every one. Even at the scrums."]),
        ("lim_prop", "rugby_player", 8, 5, None, "Prop Forward Tadhg", None)],
        w=17, h=12, legend={"g": {"tile": "grass", "colour": "#4f8a3a"}}, rects=[(2, 2, 13, 6, "g")],
        extra=[("rugby_posts", 8, 2, {}), ("floodlight", 1, 1, {}), ("floodlight", 15, 1, {}), ("stadium_stand", 1, 5, {}), ("stadium_stand", 15, 5, {}),
               ("pitch_line", 8, 4, {"walk": True})], furnish=False)
    trainer_def_only("lim_prop", "Prop Forward Tadhg", "Rugby Player", "rugby_player", [("billgruff", 59), ("samsonian", 59), ("stagmor", 60), ("raidtail", 59)],
                     ["Stand up and fight! That's the anthem. It's also my whole tactical plan."],
                     "That's a penalty against me. Fair cop.", "Front row's the engine room. Nobody sees what we do. Everybody hears it.", 2700)
    room("limerick_ardnacrusha", "Ardnacrusha Power Station", T, (8, 31), "mill", [
        ("hydro_engineer", "steelworker", 7, 2, "down", "Station Engineer", [
            "Four turbines, fed by a headrace canal from the Shannon and dropping the water about thirty metres. When it opened in 1929 it was the biggest hydro station in the world.",
            "The Shannon Scheme was the Free State's big bet: the whole country wired up from one river. It worked. Your granny's first light bulb probably came from here."]),
        ("hydro_eel", "angler", 12, 5, "left", "Eel Fisher", [
            "The eels still try to get up the river past the dam. We catch them below and carry them up in tanks. Trap and transport, they call it. I call it eel taxi."])],
        w=15, extra=[("display_case", 2, 5, {"variant": 1}), ("wall_map", 4, 1, {"walk": True})])
    room("limerick_home_pery", "Pery Square House", T, (27, 41), "home", [
        ("pery_owner", "villager_3", 3, 5, "right", "Householder", [
            "These Georgian houses went up in the 1830s. Newtown Pery was laid out on a grid by Edmund Sexton Pery. Tall windows, fanlights over the doors, four storeys of stairs.",
            "Frank McCourt grew up a mile from here and a world away. The lanes had one tap for the whole street. These houses had a ballroom."]),
        ("pery_cat", "creature:binfox", 10, 3, "down", "The Fox in the Garden", [
            "A fox has let itself in through the back and sat on the good rug. It regards you as the intruder."])])


# --- Lough Gur (route) ----------------------------------------------------------------------------------------

def lough_gur():
    W, H = 60, 44
    zid = "lough_gur"
    z = Z(zid, "Lough Gur", W, H, kind="route", region=IRL, music="route_ireland",
          weather={"drizzle": 26, "clear": 22, "sunshine": 14, "fog": 16, "gale": 8, "downpour": 14})
    z.d["stage"] = "moor"; z.d["scaled_floor"] = FLOOR
    z.legend["k"] = {"tile": "grass", "colour": "#6e8f48"}
    z.rect(0, 0, W, H, "k")
    z.border("T", 2, gaps=[(40, 0, 3, 2)])
    z.rect(40, 0, 3, 2, "#")
    z.scatter(0, 0, W, H, "P", 10, 3, only="T")
    # the lake, horseshoe round Knockadoon
    blob(z, 24, 23, 15, 8, "o", seed=4, jitter=0.15)
    blob(z, 24, 23, 13, 6.5, "~", seed=5, jitter=0.1)
    blob(z, 22, 24, 5, 3, "k", seed=6)              # Knockadoon, the hill in the lake
    z.rect(22, 27, 2, 5, "#")                        # a causeway on to it
    blob(z, 24, 23, 16, 9, "w", only="k", seed=7, jitter=0.0)
    # paths
    z.rect(40, 0, 3, 8, "#"); z.rect(6, 6, 50, 2, "#"); z.rect(46, 6, 2, 30, "#"); z.rect(6, 34, 42, 2, "#"); z.rect(6, 6, 2, 30, "#")
    z.rect(22, 32, 2, 2, "#")
    # the Grange Stone Circle (south-east)
    cx, cy = 52, 26
    import math as _m
    for i in range(14):
        a = i * 2 * _m.pi / 14
        x, y = int(round(cx + 4 * _m.cos(a))), int(round(cy + 3.2 * _m.sin(a)))
        if (x, y) != (48, 26):
            z.prop("standing_stone", x, y, variant=i % 3)
    z.rect(49, 24, 7, 5, "f"); z.rect(48, 25, 1, 3, "#")
    # the visitor centre and Bourchier's Castle
    bld(z, 30, 2, 7, 3, "clare_thatch", "Lough Gur Visitor Centre", door=3, kind="museum", to="loughgur_centre")
    z.rect(33, 5, 1, 1, "#")
    bld(z, 10, 2, 5, 4, "tower_house", "Bourchier's Castle", show=True)
    z.rect(9, 38, 18, 4, ","); z.rect(30, 38, 24, 4, ","); z.rect(50, 9, 7, 12, ",")
    z.rect(9, 9, 6, 8, ",")
    scatter_props(z, "bush", 3, 3, 54, 38, 12, 9, avoid=("k",))
    for (x, y) in [(12, 36), (36, 36), (54, 8), (4, 20)]:
        z.prop("oak", x, y, variant=(x + y) % 3)
    plaque(z, 47, 24, "limerick_grange_stone_circle", "Grange Stone Circle",
           "GRANGE STONE CIRCLE. The largest stone circle in Ireland, raised about four thousand years ago, more than a hundred stones set edge to edge round a level floor. At the summer solstice the sun rises in line with the entrance.")
    plaque(z, 24, 33, "limerick_lough_gur", "Lough Gur",
           "LOUGH GUR. People have lived round this lake for six thousand years. The remains of Neolithic houses, crannógs, forts and tombs crowd its shores, which makes it one of the richest archaeological places in Ireland.")
    plaque(z, 30, 34, "limerick_gearoid_iarla", "Gearóid Iarla",
           "GEARÓID IARLA. Gerald FitzGerald, Earl of Desmond, was a fourteenth-century poet in Irish and, they said, a magician. Legend says he sleeps under Lough Gur and rides out over the water every seven years on a horse shod with silver. When the shoes wear through, he will return.")
    plaque(z, 41, 8, "limerick_lough_gur_shield", "The Lough Gur Shield",
           "THE LOUGH GUR SHIELD. A Bronze Age shield of beaten bronze, about 2,700 years old, found near the lake. Its rings of studs still shine. It's in the National Museum in Dublin now; the lake would like it back.")
    # quest: the earl beneath the lake
    person(z, "lg_folklorist", "druid", 30, 33, "Folklorist Nóra", facing="down", cmds=[
        flag_if("q_limerick_iarla_done", say("Folklorist Nóra", "You saw the silver shoes. Most people only hear the hoofbeats. The lake will be talking about you for seven years."), [
            flag_if("q_limerick_iarla_1", say("Folklorist Nóra", "You've walked the circle. Now wait by the shore at night, out past the causeway. Listen for hooves on water."), [
                flag_if("q_limerick_iarla_started", say("Folklorist Nóra", "The Grange Stone Circle, east of the lake. Walk in by the entrance, the way the sun does at midsummer, and pay your respects."),
                        say("Folklorist Nóra", "Do you know the story of Gearóid Iarla? The Earl of Desmond, a poet and a magician. His wife begged to see his magic, and he turned into a goose before her eyes. She screamed, and broke the spell, and he vanished into the lake.",
                            "Every seven years he rides out across Lough Gur on a white horse shod with silver. When the shoes are worn thin, he'll come back. I've been coming here thirty years to see the shoes.",
                            "Walk the Grange Stone Circle first, then come back to the shore at night. The old places listen to those who visit them properly.")
                        + sets("q_limerick_iarla_started"))])])])
    person(z, "lg_circle_keeper", "hillwalker", 48, 27, "Circle Walker", facing="right", cmds=[
        flag_if("q_limerick_iarla_started", [flag_if("q_limerick_iarla_1",
            say("Circle Walker", "Back to the lake with you. Nóra will have you up all night."),
            say("Circle Walker", "In through the entrance passage, that's it, the way the midsummer sun comes in. You can feel it, can't you? Four thousand years of people standing just here.",
                "Off you go to the lake. Respects paid.") + sets("q_limerick_iarla_1"))],
            say("Circle Walker", "A hundred and more stones in a ring, and inside the floor was built up a metre with clay. They found broken pots in it: a feast, or a lot of very clumsy people."))])
    z.npc(id="silvershod_mist", sprite="creature:silvershod", x=24, y=31, facing="up", move="still", script="silvershod_mist",
          name="Mist on the Water", hide_if="caught_silvershod")
    script(zid, "silvershod_mist", [
        flag_if("q_limerick_iarla_1", [{"do": "when", "cond": "night", "then": [
            *say("", "Out on the dark water there's a sound like hooves on stone. A pale horse comes walking over the lake, and its four shoes shine silver in the moonlight."),
            {"do": "legend", "species": "silvershod", "level": 60, "flag": "caught_silvershod"},
            flag_if("caught_silvershod", sets("q_limerick_iarla_done") + [stand(2)] + say("", "The shoes are still bright. Gearóid Iarla will be a while yet."))],
            "else": say("", "A thin mist lies on the lake. Nóra said the silver horse rides at night.")}],
            say("", "A thin mist hangs over the water. It looks, for a moment, like the shape of a horse. Then it's mist again."))])
    trainer(z, "lg_archaeologist", "Archaeologist Fiachra", "Archaeologist", "tour_guide", [("tubemole", 59), ("basaltling", 58), ("sarsenite", 59)],
            44, 7, "down", ["Careful! You're standing on about three thousand years of somebody's kitchen."],
            "Dug up and dusted.", "Every field round here has a fort or a tomb or a house in it. The farmers plough round them. Mostly.", 2450)
    trainer(z, "lg_angler", "Angler Siobhán", "Angler", "angler", [("bradan", 59), ("heronarch", 58), ("rillotter", 59)],
            8, 22, "right", ["Pike in Lough Gur grow big enough to take a duckling. Not a trainer, though. Probably."],
            "Got away from me, that one.", "There's an old rule here: never take the biggest fish. It might be somebody's grandfather.", 2400)
    trainer(z, "lg_walker", "Hillwalker Dara", "Hillwalker", "hillwalker", [("gealhare", 58), ("megalorn", 59), ("pooka", 59)],
            47, 31, "left", ["Knockadoon, Knockfennell, Knockainey: every hill round here has a story and a goddess. I'm doing all of them before lunch."],
            "Puffed out. Lunch first, then.", "Knockainey is Áine's hill. She's the goddess of summer and love, and a bit of trouble, by all accounts.", 2420)
    z.d["edges"] = {"north": {"to": "limerick", "offset": 0}}
    z.d["spawn"] = [41, 2]
    wild(z, [("gealhare", 58, 59, 12, {}), ("stagmor", 58, 59, 8, {"time": ["dawn", "dusk"]}), ("megalorn", 58, 59, 4, {"weather": ["fog"], "time": ["dawn", "dusk"]}),
             ("pooka", 58, 59, 8, {"time": ["night"]}), ("bansheen", 58, 59, 5, {"time": ["night"], "weather": ["fog", "drizzle"]}),
             ("corncrake", 58, 59, 8, {"time": ["dawn", "dusk"]}), ("rooklet", 58, 59, 12, {}), ("horseshoe", 58, 59, 6, {"time": ["night"]}),
             ("moolet", 58, 59, 10, {}), ("cluricaun", 58, 59, 4, {"time": ["night"]})])
    wild(z, [("bradan", 58, 59, 16, {}), ("rillotter", 58, 59, 14, {}), ("heronarch", 58, 59, 14, {}), ("spatelord", 58, 59, 8, {"time": ["night"]}),
             ("parrlet", 58, 59, 10, {})], "water")
    finish(z)
    z.save(os.path.join(OUT, zid + ".json"))
    room("loughgur_centre", "Lough Gur Visitor Centre", zid, (33, 4), "museum", [
        ("lgc_guide", "tour_guide", 7, 2, "down", "Heritage Guide", [
            "Six thousand years of people at one lake. Neolithic farmers built rectangular houses here, some of the earliest in Ireland. Later came crannógs, artificial islands of timber and stone.",
            "The lake was partly drained in the 1840s and the shores gave up axes, pots, bones and a great Irish elk's antlers. Every farmer had a collection on the mantelpiece."]),
        ("lgc_kid", "villager_6", 3, 5, "right", "Young Visitor", [
            "Did you know the lake had a goddess AND an earl in it? It's very crowded down there."])],
        extra=[("display_case", 2, 3, {"variant": 2}), ("display_case", 11, 3, {"variant": 0})])


def main():
    open_galway()
    estuary()
    limerick()
    lough_gur()
    scaled_trainers()
    write_all(OUT)


if __name__ == "__main__":
    main()
