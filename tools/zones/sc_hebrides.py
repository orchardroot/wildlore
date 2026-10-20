# 3.0 "Wider Isles", region agent hebrides: over the Minch from Skye to the Outer Hebrides.
#   harris (route/island): Tarbert quay, Luskentyre's sands, the machair and its corncrakes, Harris Tweed, peat banks,
#                          Uig sands, Gearrannan's blackhouses and the Callanish stones
#   stornoway (town): the harbour, Lews Castle and Museum nan Eilean (the Lewis Chessmen), black pudding, Gaelic
# Usage: python3 tools/zones/sc_hebrides.py data/zones   (writes zones, interiors, dialogue and trainers)
import sys, math, random
from p6a_common import *
from wcommon import _stand
from zlib import landmark

SCOT = "scotland"
FLOOR = 74          # Skye's band: every zone and trainer here is scaled from it
WX_WEST = {"drizzle": 34, "clear": 18, "downpour": 12, "fog": 12, "gale": 14, "sunshine": 10}
ROUTE = "portree_tarbert"


def plaque(z, x, y, pid, title, text):
    _stand(z, x, y)
    z.d["signs"].append({"x": x, "y": y, "plaque": pid, "title": title, "text": text})


def scaled(tids):
    for t in tids:
        TRN[t]["scaled_floor"] = FLOOR


def wild_set(z, rows, kind="grass"):
    wild(z, [(sp, FLOOR, FLOOR + 1, wt, extra) for (sp, wt, extra) in rows], kind)


def interior(OUT, zid, name, town, ret, kind, npcs, w=13, h=10, props=(), signs=(), rows=None):
    z = landmark(OUT, zid, name, town, ret, kind, npcs, w=w, h=h, write=False)
    for (t, x, y, kw) in props:
        clear_prop(z, x, y)
        z.prop(t, x, y, **kw)
    for (x, y, text) in signs:
        z.d["signs"].append({"x": x, "y": y, "text": text})
    if rows:
        for (x, y, w2, h2, ch) in rows:
            z.rect(x, y, w2, h2, ch)
    finish(z)
    z.save(OUT + "/" + zid + ".json")
    return z


def npc(id, sprite, x, y, script=None, facing="down", move="still", name=None, **kw):
    d = {"id": id, "sprite": sprite, "x": x, "y": y, "facing": facing, "move": move}
    if script:
        d["script"] = script
    if name:
        d["name"] = name
    d.update(kw)
    return d


def cmd_if(flag, then, els=None, eq=None):
    c = {"do": "if", "flag": flag, "then": then}
    if els is not None:
        c["else"] = els
    if eq is not None:
        c["eq"] = eq
    return c


def setf(flag, value=True):
    return {"do": "set", "flag": flag, "value": value}


def give(item, n=1):
    return {"do": "give_item", "item": item, "n": n}


def choice(text, options, flag):
    return {"do": "choice", "text": text, "options": options, "set": flag}


def when(cond, then, els=None):
    c = {"do": "when", "cond": cond, "then": then}
    if els is not None:
        c["else"] = els
    return c


def stand_at(z, x, y):
    _stand(z, x, y)


def door_to(z, bx, by, bw, bh, dx, style, label, zid, w=13, h=10):
    """a building with a door on its bottom row, warping into interior `zid`; returns the tile below the door."""
    z.building(bx, by, bw, bh, style, label, door=dx)
    z.warp(bx + dx, by + bh - 1, zid, w // 2, h - 3, "up")
    return (bx + dx, by + bh)


def fill_only(z, x, y, w, h, ch, only="k"):
    for yy in range(y, y + h):
        for xx in range(x, x + w):
            if 0 <= xx < z.w and 0 <= yy < z.h and z.g[yy][xx] in only:
                z.g[yy][xx] = ch


def piece(zid, nid, x, y, key, label, lines, z):
    """one scattered Lewis chessman: a Shieldbiter-faced ivory piece standing in the landscape, there only while the
    quest runs and until picked up. Finding the fifth sets q_hebrides_chess_1."""
    stand_at(z, x, y)
    z.npc(id=nid, sprite="creature:shieldbiter", x=x, y=y, facing="down", move="still", script=nid, name="Chessman",
          show_if="q_hebrides_chess_started", hide_if="hebrides_cm_" + key)
    others = [k for k in ("king", "queen", "bishop", "knight", "warder") if k != key]
    allthere = setf("q_hebrides_chess_1")
    chain = [allthere] + say("", "That is all five pieces. Back to the curator at Lews Castle with them.")
    for k in others:
        chain = [cmd_if("hebrides_cm_" + k, chain)]
    script(zid, nid, say(label, *lines) + [give("lewis_" + key), setf("hebrides_cm_" + key)] + chain)


def check(z):
    """warn about signs, NPCs and warps standing inside a building, or on water or rock."""
    rects = [(p["x"], p["y"], p["w"], p["h"]) for p in z.d["props"] if p["type"] == "building"]
    pts = [(s["x"], s["y"], "sign") for s in z.d["signs"]] + [(n["x"], n["y"], n["id"]) for n in z.d["npcs"]]
    for (x, y, what) in pts:
        for (bx, by, bw, bh) in rects:
            if bx <= x < bx + bw and by <= y < by + bh:
                print("  WARN %s: %s at (%d,%d) is inside a building" % (z.d["id"], what, x, y))
        if z.g[y][x] in "$~oRTP^":
            print("  WARN %s: %s at (%d,%d) is on %s" % (z.d["id"], what, x, y, z.g[y][x]))


def weather_gate(body, calm):
    return [when("gale", body, [when("fog", body, [when("night", body, calm)])])]


# =====================================================================================================
# harris
# =====================================================================================================

def harris(OUT):
    W, H = 64, 72
    zid = "harris"
    z = Z(zid, "Harris and Lewis", W, H, kind="route", region=SCOT, music="route_coast", weather=WX_WEST)
    z.d["stage"] = "coast"; z.d["scaled_floor"] = FLOOR
    z.legend["k"] = {"tile": "grass", "colour": "#7f8f52"}
    z.legend["m"] = {"tile": "grass", "colour": "#8bbd47"}                              # the machair
    z.legend["h"] = {"tile": "tall_grass", "colour": "#7a5c6a", "prop": "heather"}
    z.legend["p"] = {"tile": "path", "colour": "#5b4128"}                               # cut peat
    z.rect(0, 0, W, H, "k")

    def wshore(y):
        return 6 + int(round(2 * math.sin(y / 6.0)))

    def eshore(y):
        return 57 + int(round(2 * math.sin(y / 7.0)))

    def sandw(y):
        if 20 <= y < 31: return 7        # Uig sands
        if 32 <= y < 53: return 10       # Luskentyre
        return 3
    for y in range(H):
        sx = wshore(y)
        z.rect(0, y, sx - 1, 1, "$"); z.set(sx - 1, y, "w"); z.rect(sx, y, sandw(y), 1, "s")
        ex = eshore(y)
        z.rect(ex, y, W - ex, 1, "$"); z.set(ex - 1, y, "w"); z.rect(ex - 3, y, 2, 1, "s")
    z.rect(0, 66, W, 6, "$"); z.rect(0, 65, W, 1, "w"); z.rect(0, 64, W, 1, "s")
    for x in range(W):
        for y in (0, 1):
            if z.g[y][x] != "$":
                z.g[y][x] = "R"
    z.rect(30, 0, 3, 2, "=")
    # luskentyre's tidal pools, and the white sands' shallows
    blob(z, 12, 40, 3, 2, "w", only="s", seed=3, jitter=0.4)
    blob(z, 13, 48, 3, 1.5, "w", only="s", seed=4, jitter=0.4)
    blob(z, 10, 24, 2, 1.5, "w", only="s", seed=5, jitter=0.4)
    # the machair, a lime-rich meadow of flowers behind the dunes, and its corncrake grass
    for y in range(16, 64):
        for x in range(wshore(y) + sandw(y) + 1, 29):
            if z.g[y][x] == "k":
                z.g[y][x] = "m"
    r = random.Random(31)
    for y in range(16, 64):
        for x in range(0, 29):
            if z.g[y][x] == "m" and r.random() < 0.2:
                z.g[y][x] = "f"
    for (cx, cy, rx, ry, sd) in [(21, 22, 3, 2, 41), (19, 30, 3, 2, 42), (17, 56, 4, 3, 43), (24, 58, 3, 2, 44), (20, 44, 2, 3, 45), (26, 28, 2, 3, 46)]:
        blob(z, cx, cy, rx, ry, ",", only="mf", seed=sd, jitter=0.5)
    # the hills: the Clisham's shoulder, heather and grey rock east of the road
    hills(z, [(47, 34, 3, 12)])
    smooth(z)
    for y in range(H):
        for x in range(W):
            if z.hg[y][x] >= 1 and z.g[y][x] == "k" and 33 <= x <= 54 and 21 <= y <= 46:
                z.g[y][x] = "h"
    scatter_props(z, "rock", 33, 16, 22, 31, 18, 61, avoid=("h", "k"))
    # the road: down from Stornoway, then east to the quay at Tarbert
    z.rect(30, 0, 3, 56, "=")
    z.rect(30, 54, 24, 3, "=")
    z.rect(54, 54, 8, 3, ":")                         # the quay
    z.d["ferry"] = {"x": 60, "y": 55, "route": ROUTE}
    # ---- Gearrannan, the blackhouse village on the north-west cliffs ----
    z.rect(9, 9, 20, 1, "#"); z.rect(9, 13, 21, 1, "#"); z.rect(28, 9, 1, 5, "#")
    for (bx, by, lab) in [(10, 6, "Taigh Dubh"), (17, 6, "Taigh Dubh"), (24, 6, "Taigh Dubh"), (10, 10, "Taigh Dubh")]:
        z.building(bx, by, 6, 3, "blackhouse", lab, show_label=False)
    ret_bh = door_to(z, 17, 10, 6, 3, 2, "blackhouse", "Gearrannan Blackhouse", "harris_blackhouse", 13, 10)
    z.building(24, 10, 4, 3, "blackhouse", "Taigh Dubh", show_label=False)
    for (px, py) in [(9, 4), (16, 4), (23, 4), (8, 8), (6, 12), (28, 5)]:
        z.prop("rock", px, py)
    # a drystone wall around the blackhouse village's inbye land
    z.rect(8, 15, 15, 1, "W"); z.rect(8, 15, 1, 3, "W"); z.rect(22, 15, 1, 3, "W")
    z.rect(14, 15, 3, 1, "k")
    for (px, py) in [(11, 16), (19, 17), (13, 17)]:
        z.prop("sheep", px, py)
    # ---- Callanish: thirteen stones in a ring, the avenue and the long arms of a cross ----
    z.rect(33, 18, 9, 1, "#"); z.rect(33, 13, 5, 1, "#")
    hills(z, [(43, 12, 2, 7)])
    smooth(z)
    fill_only(z, 36, 5, 14, 15, "m", only="k")
    r2 = random.Random(7)
    for y in range(5, 20):
        for x in range(36, 50):
            if z.g[y][x] == "m" and r2.random() < 0.15:
                z.g[y][x] = "f"
    ring = []
    for k in range(13):
        a = k * 2 * math.pi / 13.0
        ring.append((43 + int(round(3 * math.cos(a))), 12 + int(round(2.4 * math.sin(a)))))
    for (sx, sy) in ring:
        z.prop("standing_stone", sx, sy, variant=(sx + sy) % 2)
    z.building(43, 12, 1, 1, "monolith", show_label=False)
    for yy in range(3, 9, 2):
        z.prop("standing_stone", 42, yy, variant=1); z.prop("standing_stone", 45, yy + 1, variant=0)
    for yy in (17, 18, 19):
        z.prop("standing_stone", 43, yy + 1, variant=1)
    for xx in (47, 49):
        z.prop("standing_stone", xx, 12, variant=0)
    for xx in (37, 39):
        z.prop("standing_stone", xx, 12, variant=1)
    ret_cc = door_to(z, 34, 22, 7, 4, 3, "croft_house", "Calanais Visitor Centre", "harris_callanish", 13, 10)
    z.rect(33, 26, 5, 1, "#"); z.rect(33, 22, 1, 5, "#")
    # ---- Uig sands, where the chessmen were found ----
    z.rect(14, 25, 16, 1, "#")
    # ---- the machair crofts: the weaver's, and a neighbour's ----
    ret_wv = door_to(z, 22, 36, 6, 4, 2, "croft_house", "The Weaver's Croft", "harris_weaver", 11, 9)
    z.rect(24, 40, 6, 1, "#")
    z.building(21, 46, 5, 4, "croft_house", "Croft")
    z.rect(23, 50, 7, 1, "#")
    z.rect(20, 35, 10, 1, "W"); z.rect(20, 35, 1, 6, "W"); z.rect(20, 41, 4, 1, "W")
    z.rect(25, 41, 5, 1, "W")
    for (px, py) in [(23, 43), (25, 45), (27, 44), (26, 47), (28, 46)]:
        z.prop("sheep", px, py)
    # ---- peat: the banks, and the stacks (rickles) drying beside the road ----
    z.rect(35, 47, 10, 3, "p")
    for (px, py) in [(36, 45), (39, 45), (42, 45), (46, 47)]:
        z.building(px, py, 2, 1, "turf_stack", show_label=False)
    z.rect(33, 46, 2, 1, "#")
    # ---- Tarbert ----
    ret_tw = door_to(z, 44, 49, 6, 4, 2, "croft_house", "Tarbert Tweed", "harris_tweedshop", 11, 9)
    z.rect(46, 53, 1, 1, ":")
    z.building(36, 50, 6, 3, "harbour_white", "Isthmus Road")
    z.building(36, 58, 6, 4, "croft_house", "Shore Road")
    z.building(44, 58, 6, 4, "harbour_white", "Quay Road")
    z.building(52, 58, 4, 3, "croft_house", "Pier House")
    for (px, py) in [(34, 53), (48, 53), (53, 57), (42, 57)]:
        z.prop("lamp_post", px, py)
    for (px, py) in [(55, 53), (58, 53), (61, 53), (57, 57), (60, 57)]:
        z.prop("bollard", px, py)
    z.prop("boat", 58, 59, variant=1); z.prop("boat", 61, 51, variant=1); z.prop("lobster_pots", 56, 57)
    z.prop("bench", 54, 53); z.prop("bench", 35, 56)
    # ---- plaques ----
    plaque(z, 33, 3, "hebrides_gaelic_roads", "Roads in Two Languages",
           "Road signs in the Outer Hebrides are in Gaelic first and English second, and a good few are in Gaelic only. Stornoway is Steòrnabhagh, Harris is Na Hearadh and Lewis is Leòdhas. Learn two words, ceud mìle fàilte, a hundred thousand welcomes, and you are halfway there.")
    plaque(z, 8, 12, "hebrides_gearrannan", "Gearrannan",
           "Gearrannan is a village of blackhouses (taighean dubha) on the Atlantic cliffs of Lewis, where families lived until 1974. They were saved, thatched afresh and now take visitors. Ropes weighted with stones hold the roofs down against the gales.")
    plaque(z, 21, 14, "hebrides_blackhouse", "The Blackhouse",
           "A taigh dubh has thick double drystone walls with an earth core, a thatched roof and a peat fire in the middle of the floor with no chimney. The smoke seeped up through the thatch, and the old thatch, soaked with soot, was spread on the fields as manure.")
    plaque(z, 34, 9, "hebrides_callanish", "Callanish",
           "Calanais is a cross-shaped setting of standing stones, raised about 5,000 years ago, older than Stonehenge. Thirteen stones form a ring around a tall central stone nearly five metres high, with an avenue of stones running north and rows to the east, south and west.")
    plaque(z, 41, 16, "hebrides_callanish_moon", "The Moon and the Sleeping Woman",
           "Every 18.6 years the moon skims very low over the southern hills here, and the long line of hills is said to look like a sleeping woman, Cailleach na Mointich, the old woman of the moors. Some think the stones were laid out to watch it. Legend says they were giants turned to stone for refusing to be baptised.")
    plaque(z, 12, 25, "hebrides_uig_sands", "Uig Sands",
           "In 1831 a hoard of 93 carved walrus-ivory chess pieces turned up in a sandbank at Uig, on the west of Lewis. Tradition says a local man dug them out of a dune. They were probably carved in Norway about 800 years ago, and most are now in the British Museum and the National Museum of Scotland.")
    plaque(z, 17, 26, "hebrides_berserkers", "The Berserkers",
           "The rooks among the Lewis Chessmen are carved as berserkers, Norse warriors in a battle frenzy, biting the tops of their shields. The kings, queens, bishops and knights are all solemn and a little worried. The berserkers are having the best time on the board.")
    plaque(z, 15, 44, "hebrides_luskentyre", "Luskentyre",
           "Tràigh Losgaintir has white sand made of crushed shell, and shallow water that turns turquoise in the sun, which makes it look like somewhere much warmer than the Atlantic. It is often named among the loveliest beaches in the world. The water is still the Atlantic.")
    plaque(z, 24, 31, "hebrides_machair", "The Machair",
           "Machair (a Gaelic word) is a low, fertile grassland on the Atlantic edge of Scotland and Ireland, fed by sea-shell sand blown inland. In June and July it is a meadow of buttercups, clover, orchids and lady's bedstraw. It is among the rarest habitats in Europe, and the islands keep it by crofting.")
    plaque(z, 27, 18, "hebrides_corncrake", "The Corncrake",
           "The corncrake's call is a rasping crex crex that goes on all night. The bird flies from Africa each spring and hides in tall meadow grass, so you hear far more than you see. The Hebrides are one of its last strongholds, because crofters mow late and in ways that leave the chicks a way out.")
    plaque(z, 28, 38, "hebrides_harris_tweed", "Harris Tweed",
           "By law Harris Tweed must be handwoven by islanders at their own homes in the Outer Hebrides, from pure virgin wool dyed and spun on the islands. The Orb mark, a globe with a cross, has stood for that since 1909 and is stamped on every length. The Harris Tweed Act of 1993 put the rule into law.")
    plaque(z, 27, 51, "hebrides_tweed_dye", "Crotal and the Colours",
           "Island dyers once made their colours from what was growing round them: heather, yellow iris and crotal, a grey lichen scraped from rocks that dyes wool a rusty orange-brown. Crotal is why old Harris Tweed smells faintly of the hill after rain.")
    plaque(z, 37, 44, "hebrides_peat", "Peat",
           "Peat (mòine) is old bog, centuries of plants pressed together, cut in spring with a tairsgeir, a special peat spade, then stacked in rickles to dry on the wind. It has heated island homes for centuries, and it still flavours some island malt whisky. Each family has its own peat bank.")
    plaque(z, 46, 24, "hebrides_clisham", "An Cliseam",
           "An Cliseam, the Clisham, is the highest hill in the Western Isles at 799 metres, in the North Harris hills. The road north from Tarbert climbs past its shoulders, and on a clear day you can look from the top across to Skye.")
    plaque(z, 38, 57, "hebrides_tarbert", "Tairbeart",
           "Tarbert's name comes from the Gaelic for an isthmus, because the village sits on a narrow neck of land between East and West Loch Tarbert, where North Harris meets South Harris. The ferry from Skye lands at the quay a few steps east of here.")
    z.sign(33, 5, "NORTH: Calanais (Callanish), Gearrannan and Steòrnabhagh (Stornoway). SOUTH: Tairbeart (Tarbert) and the ferry to Skye.")
    z.sign(55, 53, "TAIRBEART. The ferry for Skye leaves from the quay here. Mind the gulls, they know when you have a sandwich.")
    z.sign(29, 58, "STORNOWAY, 36 miles north by the road you're standing on. The sheep have right of way.")
    # ---- folk ----
    chat(z, "hr_callanish_guide", "tour_guide", 40, 15, "Stones Guide",
         ["The ring is thirteen stones and the big one in the middle is nearly five metres tall. It's a gneiss, one of the oldest rocks on Earth, about three thousand million years old. The stones are younger than the rock.",
          "Somebody, five thousand years ago, dragged those about on rollers or sleds and stood them upright. Then, about a thousand years later, a burial cairn was put in the middle of the ring beside the big stone. Nobody left a note."], "left", "still")
    chat(z, "hr_peatcutter", "farmer", 42, 48, "Peat Cutter",
         ["Peat bank. My granda's. His granda's before that, give or take a flood. You cut the turves in spring, stand them up in wee heaps to dry, then bring them home by trailer in summer.",
          "On a still evening the smell of a peat fire comes over the whole island. People have been known to cry. It's the smoke, or it's not."], "down", "still")
    chat(z, "hr_birder", "birdwatcher", 18, 21, "Corncrake Watcher",
         ["Shhh. That's a corncrake. Crex crex, crex crex. It's in the grass right there. Do not step in the grass. You will not see it. Nobody sees it. We just stand here and are happy.",
          "The Western Isles still have corncrakes because the crofters mow the machair late and from the middle outwards, so the chicks can run for the edge instead of being driven into a corner."], "down", "still")
    chat(z, "hr_walker", "hillwalker", 14, 38, "Beach Walker",
         ["Losgaintir. Luskentyre. Look at that! You'd think it was the Caribbean, if you ignored the sheep, the weather and the temperature. I'm in four layers and the sheep are in one.",
          "Hello is 'halo' and goodbye is 'mar sin leat'. I've got two phrases. I use them both on every sheep."], "right", "still")
    # the crofter beside the weaver's: starts the wool errand
    _stand(z, 26, 42)
    z.npc(id="hr_murdo", sprite="farmer", x=26, y=42, facing="left", move="still", script="hr_murdo", name="Crofter Murdo")
    script(zid, "hr_murdo", [
        cmd_if("q_hebrides_tweed_1", say("Crofter Murdo", "Seonag has the wool already, so away with you. The Blackface sheep give a springy fleece, and the Cheviots a soft one. You want a bit of both for a good tweed."),
               [cmd_if("q_hebrides_tweed_started",
                       say("Crofter Murdo", "Seonag sent you for fleece? Aye, she would. I clipped these myself in July, the old way, with the hand shears. A good fleece is thick, clean and sweet-smelling, like a cold wet afternoon.",
                           "Take this one, and tell her it's the best of the lot. It isn't, but she'll say it is.") +
                       [give("hebridean_fleece"), setf("q_hebrides_tweed_1")],
                       say("Crofter Murdo", "My sheep are Blackface mostly, a few Cheviots to keep them honest. Every croft has its stint on the common grazing. The sheep do not know where my bit stops and the neighbour's starts. Neither do I, some days."))])])
    # the dyer, outside the blackhouses at Gearrannan
    _stand(z, 14, 14)
    z.npc(id="hr_peigi", sprite="villager_5", x=14, y=14, facing="down", move="still", script="hr_peigi", name="Peigi the Dyer")
    script(zid, "hr_peigi", [
        cmd_if("q_hebrides_tweed_2", say("Peigi the Dyer", "That's crotal, scraped off the rocks and simmered in the pot. It dyes wool a rusty orange-brown that smells of the hill after the rain. Away and weave it before it loses its smell."),
               [cmd_if("q_hebrides_tweed_1",
                       say("Peigi the Dyer", "Fleece from Murdo for Seonag's tweed? Good. Wool takes colour from whatever grows round it: heather, iris, and crotal, the lichen on the rocks. Crotal makes the brown of a wet hill.",
                           "Here, I've a jar of crotal dye ready. Hand it to Seonag with the fleece and she'll know what to do.") +
                       [give("crotal_dye"), setf("q_hebrides_tweed_2")],
                       say("Peigi the Dyer", "Gearrannan's blackhouses were lived in until 1974. Now they're a museum and a holiday let, and I show people how we used to dye. No one believes it can be so brown. It's the nicest brown there is."))])])
    # ferry hand at Tarbert
    _stand(z, 57, 53)
    z.npc(id="hr_ferryhand", sprite="sailor", x=57, y=53, facing="down", move="still", script="hr_ferryhand", name="Ferry Hand")
    script(zid, "hr_ferryhand", say("Ferry Hand", "Back over the water to Skye? The Little Minch is in a good mood today, which is to say it's only trying to kill you a bit.") + [{"do": "ferry", "route": ROUTE}])
    # the scattered chessmen
    piece(zid, "hr_cm_warder", 13, 25, "warder", "Chessman",
          ["A carved ivory warrior sits in the dune with its teeth clamped on the rim of its shield. It does not seem to have noticed you. It is very busy being furious."], z)
    piece(zid, "hr_cm_king", 45, 10, "king", "Chessman",
          ["A tiny ivory king sits on a flat stone by the monolith with a sword across his knees, looking worried. Kings usually are."], z)
    piece(zid, "hr_cm_queen", 19, 14, "queen", "Chessman",
          ["An ivory queen, chin in hand, sits on the wall at Gearrannan. Every Lewis Chessman queen rests her chin in her hand. They look as if they'd rather be home."], z)
    piece(zid, "hr_cm_bishop", 11, 42, "bishop", "Chessman",
          ["An ivory bishop stands on the sand at Luskentyre with his crook, blessing the tide. The tide takes no notice."], z)
    piece(zid, "hr_cm_knight", 55, 51, "knight", "Chessman",
          ["An ivory knight on a stocky pony. The pony has a face like someone has just told it a long story. The knight keeps hold of his spear."], z)
    # ---- trainers ----
    trainer(z, "harris_crofter", "Crofter Donald", "Crofter", "farmer",
            [("heilan", 74), ("herdwick", 74), ("billgruff", 75)], 27, 48, "left",
            ["I've been out since five, rounding up sheep that think they're being followed. They are. By me. Fancy a battle? It'll give them a rest."],
            "Well done. I'll away and count my sheep again.",
            "A croft is a small farm, usually twenty acres or so, and the crofter has security of tenure by law. In other words: the landlord can't throw us off. That wasn't always so, and the islands remember.", 3100)
    trainer(z, "harris_birder", "Birder Fiona", "Birdwatcher", "birdwatcher",
            [("corncrake", 74), ("cragchough", 74), ("goldeneyrie", 75), ("snowbunting", 75)], 22, 18, "right",
            ["You walked straight through a corncrake's patch and it's in a huff. It'll be calling all night to tell the others. I'd like a word. And then a battle."],
            "Good battle. Mind the grass.",
            "The chough is a red-billed crow that likes machair and sea cliffs. A chough on the machair is lucky. Seeing a corncrake is luckier. I've seen four in thirty years.", 3150)
    trainer(z, "harris_peat", "Peat Cutter Angus", "Peat Cutter", "farmer",
            [("peatmonarch", 75), ("midgeswarm", 74), ("sphagnet", 74)], 34, 48, "right",
            ["Don't trample the bank, I've a month of work in there. If you want to stand on something, stand on me. Shall we?"],
            "Fair enough. You've the touch for it.",
            "A peat bank takes years to build and one wet summer to spoil. Don't ask me about the midges. Midges are not my fault.", 3100)
    trainer(z, "harris_surfer", "Surfer Kirsty", "Surfer", "surfer",
            [("selkie", 74), ("bayrunner", 75), ("orcaird", 75), ("plungebeak", 74)], 8, 46, "right",
            ["The waves at Luskentyre are great and the water is a sensible eight degrees. I'm warm because I'm angry that I'm so cold. Let's battle."],
            "Totally radical. Or, as they say here, 'glè mhath'. Very good.",
            "A wetsuit is four millimetres of neoprene between you and the Atlantic. It is not a lot.", 3200)
    trainer(z, "harris_seer", "Stone Seer Eilidh", "Stone Seer", "druid",
            [("roodstone", 75), ("sarsenite", 75), ("megalorn", 75)], 44, 15, "left",
            ["Thirteen in the ring. I counted twice. Three times. Is there one extra? Please say there isn't. I'll battle you for it."],
            "The stones are older than the argument. Well done.",
            "The people who raised these stones had no metal tools. They raised thirteen, a tall one, and an avenue, and they lined it up on the moon. We argue about what the stones are for. They never did.", 3300)
    trainer(z, "harris_deckhand", "Deckhand Ruaraidh", "Deckhand", "sailor",
            [("greyhaul", 74), ("clownbill", 75), ("pierlord", 75), ("minchman", 75)], 52, 55, "down",
            ["I do the ropes on the Skye boat. Up, down, up, down, nine times a day. A battle's the most exciting thing to happen since Tuesday."],
            "Aye, you've sea legs. Ropes next?",
            "On a rough crossing the whole boat is a bit green. The crew do not look green, because we are professionals and also not looking at the same time.", 3150)
    scaled(["harris_crofter", "harris_birder", "harris_peat", "harris_surfer", "harris_seer", "harris_deckhand"])
    wild_set(z, [("crexling", 16, {}), ("herdlet", 10, {}), ("heilan", 8, {}), ("goldeneyrie", 8, {"time": ["day"]}),
                 ("cragchough", 10, {}), ("buntling", 8, {}), ("ptarmlet", 6, {"weather": ["fog", "frost"]}),
                 ("midgeswarm", 10, {"time": ["dawn", "dusk"]}), ("hushwing", 6, {"time": ["night"]}), ("eaglet", 6, {"time": ["day"]}),
                 ("skaldling", 6, {"weather": ["gale", "fog"]}), ("shieldbiter", 3, {"weather": ["gale", "fog", "drizzle"]})])
    wild_set(z, [("selklet", 16, {}), ("greyhaul", 14, {}), ("dolphlet", 10, {"time": ["day"]}), ("plungebeak", 12, {"time": ["day"]}),
                 ("orcalet", 8, {}), ("clownbill", 8, {"time": ["day", "dawn"]}), ("skaldling", 16, {}), ("polartern", 6, {"weather": ["gale", "fog"]}),
                 ("minchman", 5, {"weather": ["gale", "downpour"]}), ("skaldwake", 3, {"weather": ["gale"], "time": ["dusk", "night"]})], "water")
    z.d["edges"] = {"north": {"to": "stornoway", "offset": -1}}
    z.d["spawn"] = [31, 52]
    check(z)
    finish(z)
    z.save(OUT + "/" + zid + ".json")

    # ---- interiors ----
    interior(OUT, "harris_weaver", "The Weaver's Croft", zid, ret_wv, "cottage",
             [npc("hw_seonag", "villager_4", 4, 3, "hw_seonag", name="Seonag the Weaver", facing="right")],
             w=11, h=9,
             props=[("kitchen_dresser", 1, 1, {}), ("rug", 6, 4, {}), ("fireplace", 8, 1, {"walk": True}), ("table", 3, 6, {})],
             signs=[(8, 4, "THE LOOM. A Hattersley double-width loom, a hundred years old and still going. Treadles below, shuttle across, beam forward, and again, thousands of times for one length of cloth. Harris Tweed is woven on looms like this in the islanders' own homes, often in a shed beside the house.")])
    script("harris_weaver", "hw_seonag", [
        cmd_if("q_hebrides_tweed_done", say("Seonag the Weaver", "Your length of tweed has the Orb on it now, and mine have too. You never forget the first one. I've kept my first for fifty years and I still check it for flaws."),
               [cmd_if("q_hebrides_tweed_3", say("Seonag the Weaver", "The tweed is woven and waiting. Take it over the hills to Stornoway, to the Harris Tweed Authority. The Orb mark has to be stamped on by the inspector. Without it, it's only a nice bit of cloth."),
                       [cmd_if("q_hebrides_tweed_started",
                               [cmd_if("q_hebrides_tweed_2",
                                       say("Seonag the Weaver", "The fleece, and a jar of crotal too. Peigi's very fast. Right. Warp the loom, thread the heddles, and weave.") +
                                       [choice("Which weave will you set on the loom?", ["Herringbone", "A twill check", "Plain weave"], "_hw_pattern")] +
                                       say("Seonag the Weaver", "Good choice. Treadle, shuttle, beat. Treadle, shuttle, beat. You'll feel it in your knees by teatime. It's the rhythm that keeps it even. Waulking songs, back in my granny's day, kept the rhythm for the women shrinking the cloth after.",
                                           "There now. Four metres of tweed, off the loom. It must be inspected before it can be called Harris Tweed. Take it to Stornoway.") +
                                       [give("tweed_bolt"), setf("q_hebrides_tweed_3")],
                                       say("Seonag the Weaver", "Fleece from Murdo, dye from Peigi at Gearrannan. Get both and the loom is yours. I'll keep the kettle on, and I'll keep it on all day, because I know how far that is."))],
                               say("Seonag the Weaver", "Fàilte! Welcome. You've caught me mid-pick. You see this loom? Every length of Harris Tweed starts here or on one like it, in a croft shed, with the weaver at the treadles. That's the law, and it's a good law.",
                                   "I'll show you how it's done if you fetch what I need: a fleece from Crofter Murdo, out on the machair, and a jar of crotal dye from Peigi, at Gearrannan. Then we'll weave a length. And when it's done, off to Stornoway for the Orb stamp.") +
                               [setf("q_hebrides_tweed_started")])])])])
    interior(OUT, "harris_blackhouse", "Gearrannan Blackhouse", zid, ret_bh, "cottage",
             [npc("hb_guide", "tour_guide", 5, 3, "hb_guide", name="Blackhouse Guide")],
             props=[("fireplace", 6, 4, {"walk": True}), ("kitchen_dresser", 2, 1, {}), ("bed", 10, 1, {}), ("bench", 4, 5, {})],
             signs=[(6, 6, "THE FIRE. In the middle of the floor, on a hearth of flat stones, with no chimney. A peat fire was kept alight for years on end, and the smoke found its own way out through the thatch.")])
    script("harris_blackhouse", "hb_guide", say("Blackhouse Guide",
           "Fàilte. A taigh dubh, a black house. Nobody's quite sure why black: the soot, or the dark inside, or because newer white houses made them look dark by contrast.",
           "The animals lived in one end, the people in the other, with a drain between. In winter the cattle's warmth helped keep the house up to temperature.",
           "The last families left Gearrannan in 1974. Now the houses are a museum and some are holiday lets. You can sleep in one. There is a chimney now, but we have promised not to tell the visitors."))
    interior(OUT, "harris_callanish", "Calanais Visitor Centre", zid, ret_cc, "museum",
             [npc("hc_curator", "tour_guide", 6, 4, "hc_curator", name="Centre Guide"),
              npc("hc_walker", "hiker", 9, 6, "hc_walker", name="Visitor", facing="left")],
             signs=[(4, 3, "THE CALANAIS CROSS. 13 stones in the ring, 19 in the avenue, with rows to the east, south and west: a cross laid on the land, about 5,000 years old. Raised from the local gneiss, a rock around 3,000 million years old.")])
    script("harris_callanish", "hc_curator", say("Centre Guide",
           "Calanais I is the best known, but there are other circles within sight, Calanais II and III and more. The whole landscape was set out as a sacred place.",
           "The stones are standing on peat now, but about 1857 the local landowner ordered the peat cleared away from around them, and found the base of the stones and the chambered cairn inside the ring.",
           "On the midsummer full moon, in the lunar standstill years, the moon rolls low along the hills and seems to set into the stones. Come back in 2025 or 2043 to see it. We'll leave the lights on."))
    script("harris_callanish", "hc_walker", say("Visitor",
           "I walked round it three times. Once for each time somebody told me not to touch the stones. They're so warm! Unless it's raining. Then they're just wet."))
    interior(OUT, "harris_tweedshop", "Tarbert Tweed", zid, ret_tw, "cottage",
             [npc("ht_keeper", "villager_2", 5, 3, "ht_keeper", name="Tweed Shop Keeper")],
             w=11, h=9,
             props=[("rug", 5, 5, {}), ("display_case", 1, 1, {"variant": 1}), ("display_case", 9, 1, {"variant": 2})],
             signs=[(8, 4, "THE ORB MARK. A globe topped with a Maltese cross, with the words HARRIS TWEED, 'Made from 100% pure virgin wool dyed, spun and finished in the Outer Hebrides and hand woven by the islanders at their homes'. Look for the Orb on the label.")])
    script("harris_tweedshop", "ht_keeper", say("Tweed Shop Keeper",
           "Everything in here has an Orb on it: jackets, caps, a very small bag for a very small dog. Harris Tweed is one of very few cloths protected by an Act of Parliament.",
           "In the 1840s the Countess of Dunmore had a go at selling the island's tweed to her friends in the south, and that's how it all began. Before then it was the islanders' own cloth, woven for use.",
           "Nowadays the wool is spun at a mill, but every metre is woven by hand in somebody's own house. A weaver can make about forty metres in a good week. The loom does the clacking, they do the thinking."))
    return ret_bh


# =====================================================================================================
# stornoway
# =====================================================================================================

def stornoway(OUT):
    W, H = 72, 60
    zid = "stornoway"
    z = Z(zid, "Stornoway", W, H, kind="town", region=SCOT, music="town_scotland", weather=WX_WEST)
    z.d["stage"] = "coast"; z.d["town_id"] = "stornoway"; z.d["scaled_floor"] = FLOOR
    z.legend["k"] = {"tile": "grass", "colour": "#7f8f52"}
    z.rect(0, 0, W, H, "k")
    z.border("T", 2, gaps=[(29, 58, 3, 2)])
    z.scatter(0, 0, W, H, "P", 22, 91, only="T")
    # the harbour, to the north
    z.rect(0, 0, W, 10, "$"); z.rect(0, 10, W, 1, "w")
    z.rect(24, 11, 46, 2, ":")                       # the quay
    # the castle grounds, on the wooded point to the north-west
    z.rect(2, 2, 22, 11, "k"); z.rect(1, 2, 1, 11, "w")
    z.scatter(3, 3, 20, 10, "T", 34, 93, only="k")
    # the streets
    z.rect(3, 17, 66, 2, ":")                        # Cromwell Street
    z.rect(3, 23, 66, 2, ":")                        # Church Street
    z.rect(3, 29, 66, 2, ":")                        # Kenneth Street
    z.rect(29, 19, 3, 41, "=")                       # the road in from Harris
    for lx in (11, 29, 46):
        z.rect(lx, 13, 3, 4, ":")
    z.rect(11, 9, 3, 4, "#")
    # Lews Castle: tower, battlements and a drive
    ret_castle = door_to(z, 5, 3, 13, 6, 6, "lews_castle", "Lews Castle", "stornoway_castle", 15, 11)
    z.rect(11, 9, 3, 1, "#")
    # row A: the harbour front
    ret_lan = door_to(z, 3, 13, 8, 4, 3, "granite_house", "An Lanntair", "stornoway_lanntair", 15, 11)
    ret_cafe = door_to(z, 14, 13, 7, 4, 3, "harbour_white", "Harbour Mission Cafe", "stornoway_cafe", 13, 10)
    z.building(21, 13, 8, 4, "granite_house", "Cromwell Street")
    ret_tw = door_to(z, 32, 13, 7, 4, 3, "granite_house", "Harris Tweed Authority", "stornoway_tweed", 13, 10)
    ret_bu = door_to(z, 39, 13, 7, 4, 3, "harbour_white", "Butcher", "stornoway_butcher", 11, 9)
    ret_pub = door_to(z, 49, 13, 8, 4, 3, "granite_house", "The Minch Arms", "stornoway_pub", 13, 10)
    z.building(57, 13, 7, 4, "harbour_white", "Quay Street")
    z.building(64, 13, 6, 4, "granite_house", "Quay Street")
    # row B: the Sanctuary, the shop, the kirk
    z.building(4, 19, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(7, 22, "stornoway_sanctuary", 5, 6, "up")
    z.building(11, 19, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(13, 22, "stornoway_shop", 4, 5, "up")
    z.building(17, 19, 7, 4, "croft_house", "Matheson Road")
    z.building(24, 19, 4, 4, "harbour_white", "Matheson Road")
    ret_kirk = door_to(z, 33, 19, 8, 4, 3, "chapel", "The Kirk", "stornoway_kirk", 13, 10)
    z.building(42, 19, 7, 4, "harbour_white", "Francis Street")
    z.building(50, 19, 8, 4, "granite_house", "Francis Street")
    z.building(59, 19, 8, 4, "croft_house", "Bayhead")
    # row C: homes
    ret_ha = door_to(z, 4, 25, 8, 4, 3, "croft_house", "Gaelic Teacher's House", "stornoway_home_a", 11, 9)
    z.building(13, 25, 7, 4, "granite_house", "Kenneth Street")
    z.building(21, 25, 7, 4, "harbour_white", "Kenneth Street")
    ret_hb = door_to(z, 33, 25, 8, 4, 3, "harbour_white", "Old Fisherman's House", "stornoway_home_b", 11, 9)
    z.building(42, 25, 8, 4, "granite_house", "Seaforth Road")
    z.building(51, 25, 8, 4, "croft_house", "Seaforth Road")
    z.building(60, 25, 7, 4, "harbour_white", "Seaforth Road")
    # the harbour: boats, a trawler, the quay's furniture
    z.building(42, 4, 5, 3, "trawler", "Trawler", show_label=False)
    z.building(53, 5, 5, 3, "trawler", "Trawler", show_label=False)
    for (bx, by) in [(36, 8), (48, 9), (62, 7), (66, 9), (30, 6)]:
        z.prop("boat", bx, by, variant=1)
    z.prop("lighthouse", 68, 11)
    for (bx, by) in [(26, 11), (33, 11), (40, 11), (52, 11), (59, 11)]:
        z.prop("bollard", bx, by)
    for (bx, by) in [(27, 12), (36, 12), (56, 12)]:
        z.prop("lobster_pots", bx, by)
    z.prop("buoy", 47, 12)
    # the green and the monument, the woods and the pond
    z.rect(33, 33, 36, 22, "k")
    z.building(52, 36, 1, 1, "obelisk", show_label=False)
    z.rect(52, 38, 1, 1, "#"); z.rect(40, 38, 13, 1, "#"); z.rect(40, 31, 1, 8, "#")
    for (bx, by) in [(44, 37), (48, 37), (56, 40)]:
        z.prop("bench", bx, by)
    for (bx, by) in [(36, 32), (50, 32), (64, 32), (36, 40), (64, 40)]:
        z.prop("lamp_post", bx, by)
    scatter_props(z, "oak", 3, 34, 24, 22, 28, 7, avoid=("k", "."))
    scatter_props(z, "oak", 34, 44, 34, 12, 12, 8, avoid=("k",))
    blob(z, 16, 44, 5, 3, "~", only="k", seed=11, jitter=0.3)
    blob(z, 16, 44, 7, 4.6, "w", only="k", seed=12, jitter=0.2)
    blob(z, 20, 52, 4, 2, ",", only="k", seed=13, jitter=0.5)
    blob(z, 44, 52, 5, 2, ",", only="k", seed=14, jitter=0.5)
    blob(z, 8, 36, 4, 2, ",", only="k", seed=15, jitter=0.5)
    z.rect(3, 31, 26, 1, "#")
    z.rect(29, 31, 3, 1, "=")
    # ---- plaques ----
    plaque(z, 30, 11, "hebrides_stornoway", "Steòrnabhagh",
           "Stornoway's name is Norse: Stjornavagr, the steering bay, or the bay you steer into. In Gaelic it is Steòrnabhagh. It is the only real town in the Western Isles, with a harbour that has sheltered boats for a thousand years.")
    plaque(z, 22, 10, "hebrides_lews_castle", "Lews Castle",
           "Sir James Matheson bought the whole of Lewis in 1844 with a fortune made in the China trade, and built this castle in the 1850s. Lord Leverhulme bought the island in 1918 with big plans, then gave the castle to the people of Stornoway in 1923. It now holds Museum nan Eilean.")
    plaque(z, 7, 10, "hebrides_castle_woods", "The Castle Woods",
           "The woods around Lews Castle were planted by the Mathesons, and they are one of the few real woods in the Outer Hebrides, where the wind and salt keep most trees down. Walk in them and you feel as if you've left the islands. Then you walk out and the wind says you haven't.")
    plaque(z, 28, 12, "hebrides_chessmen", "The Lewis Chessmen",
           "Ninety-three carved pieces, in walrus ivory and whale tooth, turned up at Uig in 1831. They were made in Norway in about 1150 to 1200. Most are in the British Museum and the National Museum of Scotland, and a few are shown on loan at Museum nan Eilean, home, near enough.")
    plaque(z, 27, 18, "hebrides_missing_knight", "The Knight in the Drawer",
           "One Lewis chessman went missing for nearly two centuries. A Scottish dealer bought a knight for a few pounds in 1964. His family kept it in a drawer, never knowing what it was, until it was recognised in 2019 and sold for hundreds of thousands of pounds. It is worth checking your drawers.")
    plaque(z, 44, 18, "hebrides_black_pudding", "Stornoway Black Pudding",
           "Stornoway Black Pudding is oatmeal, beef suet, onion and blood, shaped and cooked in a skin. It has protected geographical status, as Champagne does, so only the black pudding made in Stornoway can use the name. It is on every breakfast plate on the island, and a great many dinners.")
    plaque(z, 34, 12, "hebrides_orb_stornoway", "The Orb Stamp",
           "The Harris Tweed Authority, based here in Stornoway, inspects every length of Harris Tweed. Only cloth that has passed gets the Orb stamped on it, which is why a Harris Tweed jacket is a small piece of Hebridean law. The stamp goes on the cloth itself, not just the label.")
    plaque(z, 50, 30, "hebrides_gaelic", "A Language, Alive",
           "Around half the people of the Western Isles speak Gaelic, more than anywhere else in Scotland, and there are Gaelic road signs, schools, radio and television. Try 'Madainn mhath' (good morning), 'Mòran taing' (thank you very much) and 'Slàinte mhath' (good health).")
    plaque(z, 36, 30, "hebrides_sabbath", "A Quiet Sunday",
           "Many in Lewis keep Sunday as the Sabbath: a day for church and rest, with most shops shut and the streets quiet. Visitors are welcome to walk or just sit, and are asked to keep the day gently. The islanders will tell you the peace is the best part.")
    plaque(z, 38, 42, "hebrides_iolaire", "HMY Iolaire",
           "In the early hours of 1 January 1919 the yacht Iolaire, bringing home sailors from the First World War, struck rocks called the Beasts of Holm at the harbour mouth. More than 200 men were lost, within sight of home. A memorial stands at Holm, and the island remembers each New Year.")
    plaque(z, 52, 34, "hebrides_lanntair", "An Lanntair",
           "An Lanntair is Gaelic for the lantern, and it is the arts centre on the harbour here. It shows Gaelic and island art, music, film and theatre. Gaelic songs have been sung at every ceilidh in the islands, and the best ones are about the sea.")
    plaque(z, 66, 11, "hebrides_blue_men_plaque", "The Blue Men of the Minch",
           "The Minch is the stretch of water between the Outer Hebrides and the mainland, and the Blue Men (na fir ghorma) are said to live in the strait near the Shiant Isles. They swim up to boats and call out a line of verse. The skipper who can finish the rhyme gets through, and the rest are overturned.")
    z.sign(31, 56, "SOUTH: the road to Harris, Tairbeart (Tarbert) and the Skye ferry. FÀILTE GU STEÒRNABHAGH: welcome to Stornoway.")
    z.sign(26, 17, "WEST: Lews Castle and the woods. EAST: the harbour. FÀILTE GU STEÒRNABHAGH.")
    # ---- folk ----
    chat(z, "sw_gaelic_kid", "student", 28, 21, "Schoolkid",
         ["Madainn mhath! That's good morning. Feasgar math is good afternoon. Oidhche mhath is good night. We have lessons in Gaelic and then English. I'm better at one than the other, and I'm not telling you which.",
          "My granny only speaks Gaelic to the cat. The cat understands. The dog, we think, is learning."], "right", "wander")
    chat(z, "sw_harbour_hand", "fisherman_north", 44, 11, "Harbour Hand",
         ["Everything comes in here: the boat from Ullapool, fishing boats, creels, big crates of langoustines. The prawns go to Spain. Spain! We eat the haddock.",
          "In the old herring days, the harbour was so full of boats you could walk across the water. I'm told. I'm not that old."], "down", "wander")
    chat(z, "sw_castle_gardener", "ghillie", 20, 6, "Castle Gardener",
         ["These are the trees the Mathesons planted. Sycamore, ash, beech. In a place where the wind takes your hat in March. Somebody had a lot of money and a great deal of optimism.",
          "If you hear a thud in the night, it's a branch. If you hear two, it's a branch and a laird's idea."], "down", "still")
    chat(z, "sw_sabbath_visitor", "villager_3", 60, 30, "Local Woman",
         ["Sundays here are quiet. The shops are shut, the washing stays in, and many go to church twice. If you're visiting, walk by the shore, have a cup of tea. Folk are kind about it.",
          "My granny remembers when the swings in the park were chained on a Sunday. It's different now, and not everybody likes it. We all agree about the black pudding."], "left", "still")
    chat(z, "sw_pudding_fan", "villager_5", 41, 18, "Pudding Fan",
         ["Stornoway black pudding. It's got protected status, like Champagne. If you make a black pudding in Glasgow you can call it a black pudding, but you can't call it a Stornoway one. And you wouldn't want to. It's just not the same."], "down", "still")
    _stand(z, 36, 12)
    z.npc(id="sw_skipper", sprite="fisherman_north", x=36, y=12, facing="left", move="still", script="sw_skipper", name="Old Skipper")
    script(zid, "sw_skipper", [
        cmd_if("q_hebrides_rhyme_done", say("Old Skipper", "You answered the Blue Men and they let you by. That makes you the first in this harbour since my granda. Have a seat. Nobody will believe you, but I will."),
               [cmd_if("q_hebrides_rhyme_2",
                       say("Old Skipper", "You have the verses. Go to the end of the quay when the weather's bad, in a gale or a fog or at night, and listen. The Blue Men don't come on a calm day. Calm days are for people with no stories."),
                       [cmd_if("q_hebrides_rhyme_1",
                               say("Old Skipper", "A Skaldling! That's a Blue Man's wee one. They'll only come for those who've befriended one. Now go and see the Bard at the Minch Arms. He'll teach you how a rhyme goes."),
                               [cmd_if("q_hebrides_rhyme_started",
                                       [when("has_skaldling",
                                             say("Old Skipper", "You've one in your Fieldbook? Good lad, good lass. Then they'll know you. Away and see the Bard at the Minch Arms, he'll teach you the verses.") + [setf("q_hebrides_rhyme_1")],
                                             say("Old Skipper", "Not yet. Find a Skaldling in the shallows on the Harris coast or out at the end of the Skye quays. A wee blue thing in a foam crown, singing under its breath. Catch it."))],
                                       say("Old Skipper", "The Blue Men of the Minch. Everyone knows them, and nobody has ever met them and lived to say so, except me. They come up alongside the boat in a storm and call a line of verse. If you can finish the rhyme, off you go. If you can't, over you go.",
                                           "They don't ask much. But they only talk to those who have the ear. Catch me a Skaldling, one of their little ones, and I'll show you how it's done.") +
                                       [setf("q_hebrides_rhyme_started")])])])])])
    # the Blue Men, at the end of the quay: gale, fog or night only, and only once the verses are learned
    _stand(z, 67, 12)
    z.npc(id="sw_bluemen", sprite="creature:skaldwake", x=67, y=12, facing="up", move="still", script="sw_bluemen", name="Blue Man",
          show_if="q_hebrides_rhyme_2", hide_if="q_hebrides_rhyme_done")
    rhymes = [
        ("The wind is wild and the waves are high,", ["And still I'll sail beneath the sky", "So I'll be home for a cup of tea", "Which is why I stayed in bed today"], 0),
        ("Oh, the Minch is grey and the Minch is wide,", ["And I would rather be in Leeds", "But a brave heart rides the turning tide", "So I've brought sandwiches and a flask"], 1),
        ("Blue Man, Blue Man, under the foam,", ["I rather think I left the oven on", "Is that a haddock or an alarm clock?", "I'll answer your rhyme, then sail for home"], 2)]
    body = say("Blue Man", "A voice comes out of the spray, wet and amused: 'Skipper, skipper, in the stout little boat, if you can finish my rhyme you will float.'")
    final = say("Blue Man", "A cheer goes up from the waves. 'A skipper with an ear! The Minch is yours. But a Blue Man likes to see how you fight as well as how you rhyme.'") + \
        [{"do": "battle", "trainer": "blue_men", "intro": True}] + \
        say("Blue Man", "'Well rhymed, and well fought. Take this. The sea only gives away one in a hundred years.'") + \
        [give("blue_man_pebble"), {"do": "standing", "nation": "scotland", "amount": 2}, setf("q_hebrides_rhyme_3"), setf("q_hebrides_rhyme_done")]
    wrong = say("Blue Man", "'No! That doesn't scan! The sea takes your hat.' A wave arrives and takes your hat. Fortunately you weren't wearing one. Start again.")
    chain = final
    for i in (2, 1, 0):
        pre, opts, right = rhymes[i]
        inner = [choice("Finish the Blue Man's rhyme: '%s'" % pre, opts, "_rhyme_%d" % i), cmd_if("_rhyme_%d" % i, chain, wrong, eq=right)]
        chain = inner
    calm = say("", "The quay is quiet. A calm day, just the water slapping the stones. The Blue Men only come in a gale, in fog or in the dark.")
    script(zid, "sw_bluemen", weather_gate(body + chain, calm))
    # ---- trainers ----
    trainer(z, "stornoway_fisher", "Skipper Calum", "Skipper", "fisherman_north",
            [("greyhaul", 74), ("bayrunner", 75), ("polartern", 75), ("orcaird", 75)], 60, 12, "left",
            ["I fish for langoustines. Up at four, creels out, creels in. You've the look of a woman or man who does not get up at four. Battle?"],
            "Ah well. The sea's more forgiving than you.",
            "A langoustine is a small lobster. It is not a prawn. You can say 'Dublin Bay prawn' and a Dubliner will hold you to it. Here we sell them to Spain.", 3150)
    trainer(z, "stornoway_piper", "Piper Mhairi", "Piper", "piper",
            [("hushwing", 74), ("goldeneyrie", 75), ("ptarmigan", 75), ("highlynx", 75)], 39, 30, "up",
            ["I play the pipes on the sea wall at six o'clock every evening. A seal comes to listen. Some say it's to escape. I say it's the music."],
            "Nice work. The seal's behind you, looking at you disapprovingly.",
            "The Highland bagpipe has three drones and a chanter. It is the loudest instrument in the world that is not a car alarm.", 3200)
    trainer(z, "stornoway_baker", "Pudding Maker Hamish", "Butcher", "shopkeeper",
            [("pigling", 74), ("billgruff", 75), ("heilan", 75), ("herdwick", 75)], 47, 23, "up",
            ["The recipe is a secret. Oatmeal, suet, onion, blood, pepper. And a pinch of something I'm not telling you. It's just more pepper. Fancy a battle?"],
            "A fair fight. Come in for a slice, on the house.",
            "The best black pudding is crisp on the outside, soft inside, and has not been left under the grill while the cook has a chat. That's the secret.", 3100)
    trainer(z, "stornoway_bard", "Bard Alasdair", "Bard", "bard",
            [("minchman", 75), ("lanternis", 74), ("hushwing", 75)], 46, 29, "down",
            ["I make songs about the sea, the weather, and a woman in Back who will not return my phone calls. Each has more verses than you'd expect. Fancy a battle in four-four time?"],
            "A good fight. I'll put you in a verse.",
            "Gaelic song has a verse for every occasion: waulking songs, rowing songs, lullabies, songs for the weather and songs for a man who's late for his tea.", 3250)
    trainer(z, "stornoway_gardener", "Gardener Iain", "Gardener", "ghillie",
            [("sphagnet", 74), ("kelpie", 74), ("stagmor", 75), ("reindeer", 75)], 18, 8, "right",
            ["Please keep to the paths. The Mathesons planted these trees. They also planted me, I think, about forty years ago. I've never been moved."],
            "Not a branch broken. Well done.",
            "Wind is the enemy of a tree here. The trees in the castle grounds lean east, as though trying to get out of the weather. They never quite make it.", 3100)
    trainer(z, "stornoway_student", "Student Catriona", "Student", "student",
            [("ironwatch", 75), ("legionette", 74), ("sarsenite", 75)], 56, 31, "left",
            ["I'm at the Gaelic college, doing Chessmen history. Do you know the queens put their chins in their hands? It's a wonder they didn't all fall over. Let me show you what I've got."],
            "You've a fine strategy. Ever thought of playing chess?",
            "The Lewis Chessmen were found in 1831, but we only truly learnt how special they were once somebody knew what they were. A great many things sit in drawers.", 3150)
    # the quest-only battles
    TRN["hebrides_chessmaster"] = {"id": "hebrides_chessmaster", "name": "Chess Master Ailsa", "class": "Chess Master", "sprite": "poet",
                                   "party": [{"species": s, "level": lv} for s, lv in [("shieldbiter", 75), ("ironwatch", 75), ("legionette", 75), ("sarsenite", 76), ("megalorn", 76)]],
                                   "ai": "trainer", "money": 3800,
                                   "intro": say("Chess Master Ailsa", "Eight by eight, sixty-four squares, thirty-two pieces. We'll use the ivory ones, you and I, only they're a bit bigger and they bite. I play black. I always play black. White is for people with no sense of occasion."),
                                   "win": "Checkmate, in a manner of speaking. Well played. You've a mind for it.", "after": "I'll be at the board when you want a rematch. I'm always at the board.", "scaled_floor": FLOOR}
    TRN["blue_men"] = {"id": "blue_men", "name": "The Blue Men of the Minch", "class": "Sea Spirits", "sprite": "creature:skaldwake",
                       "party": [{"species": s, "level": lv} for s, lv in [("minchman", 75), ("skaldling", 74), ("skaldwake", 76), ("minchman", 76)]],
                       "ai": "trainer", "money": 3500,
                       "intro": say("The Blue Men of the Minch", "'We rhymed, you rhymed, but can you swim?' says the chief, and the sea stands up on its hind legs."),
                       "win": "A rhyme for the end: 'You win, we bow, our work's done now.'", "after": "The foam winks.", "scaled_floor": FLOOR}
    scaled(["stornoway_fisher", "stornoway_piper", "stornoway_baker", "stornoway_bard", "stornoway_gardener", "stornoway_student"])
    wild_set(z, [("heilan", 8, {}), ("herdlet", 8, {}), ("crexling", 8, {}), ("cragchough", 10, {}), ("buntling", 8, {}),
                 ("hushwing", 8, {"time": ["night"]}), ("flittermouse", 8, {"time": ["night"]}), ("midgeswarm", 10, {"time": ["dawn", "dusk"]}),
                 ("hootlet", 6, {"time": ["night"]}), ("eaglet", 4, {"time": ["day"]}), ("skaldling", 4, {"weather": ["fog"]})])
    wild_set(z, [("selklet", 14, {}), ("greyhaul", 14, {}), ("chipgull", 14, {}), ("plungebeak", 12, {"time": ["day"]}),
                 ("skaldling", 16, {}), ("dolphlet", 8, {"time": ["day"]}), ("bayrunner", 8, {}), ("minchman", 4, {"weather": ["gale"]})], "water")
    z.d["edges"] = {"south": {"to": "harris", "offset": 1}}
    z.d["spawn"] = [30, 22]
    check(z)
    finish(z)
    z.save(OUT + "/" + zid + ".json")

    # ---- interiors ----
    sanctuary(OUT, zid, "Stornoway", (7, 23), music="sanctuary")
    shop(OUT, zid, "Stornoway", (13, 23))
    nurse(zid, ["Fàilte! Welcome to Stornoway Sanctuary. You look as if you've crossed the Minch in a force eight. Pop them on the counter.",
                "There's a kettle on, and a plate of bannocks. You're welcome to the bannocks if you leave me the crumbs. Poor things, they're peely-wally. All better.",
                "There you go. Mòran taing, that's thank you very much, for being so patient. Mind the wind on the way out.",
                "The Ark's in the corner, it's the one with the sea-view. Have a click.",
                "No bother. Enjoy the town, and mind the swings on a Sunday."])
    shopkeeper(zid, "Fàilte! Tea, black pudding, bere bannocks and the odd snare. The pudding's from the butcher's, and so I can tell you it's the best.",
               "Mòran taing! Mind the wind on the way out. It has opinions.")
    castle = interior(OUT, "stornoway_castle", "Museum nan Eilean", zid, ret_castle, "museum",
                      [npc("sw_curator", "tour_guide", 6, 4, "sw_curator", name="Curator", facing="right"),
                       npc("sw_chessmaster", "poet", 10, 4, "sw_chessmaster", name="Chess Master", facing="left", show_if="q_hebrides_chess_2")],
                      w=15, h=11,
                      props=[("display_case", 2, 3, {"variant": 1}), ("display_case", 12, 3, {"variant": 2}), ("display_case", 7, 2, {"variant": 1})],
                      signs=[(4, 6, "THE LEWIS CHESSMEN. Carved in Norway around 1150 to 1200, from walrus ivory, and buried in a sandbank at Uig, Lewis. These are some of the pieces on loan from the British Museum: a king, a queen, a bishop, a knight, a berserker rook.")])
    script("stornoway_castle", "sw_curator", [
        cmd_if("q_hebrides_chess_done", say("Curator", "The five pieces are in their case, and the board's gathered a crowd. If you want to see ninety-three pieces in one place, go to the British Museum. If you want to see them near home, here. Hello again!"),
               [cmd_if("q_hebrides_chess_2",
                       say("Curator", "Ailsa, the chess master, is at the board, polishing a bishop. She plays with a full set of live creatures. I haven't asked how."),
                       [cmd_if("q_hebrides_chess_1",
                               say("Curator", "All five! Look at them. A king, a queen, a bishop, a knight and a warder, still biting its shield. I'll write them up in the register.",
                                   "Right. Now, the chess club at Stornoway has been waiting for pieces like these. Ailsa's the champion. Show her you can think as well as pick up.") +
                               [setf("q_hebrides_chess_2")],
                               [cmd_if("q_hebrides_chess_started",
                                       say("Curator", "Five to find: a king by the stones at Callanish, a queen at Gearrannan, a bishop at Luskentyre, a knight by the Tarbert quay and a warder in the dune at Uig. They are in the landscape, looking out of place."),
                                       say("Curator", "Welcome to Museum nan Eilean, in the castle. We're the home of the Lewis Chessmen, or some of them. The rest are in London and Edinburgh, which is a bit like leaving your family in two other cities.",
                                           "The truth is, now and then new pieces turn up. Walkers report odd carved things at Uig, Callanish, Gearrannan, Luskentyre and Tarbert. They could be hoax, they could be hoard. They could also bite. Will you go and see?") +
                                       [setf("q_hebrides_chess_started")])])])])])
    script("stornoway_castle", "sw_chessmaster", [
        cmd_if("q_hebrides_chess_done", say("Chess Master Ailsa", "I've never lost to a Shieldbiter. I've never lost to a person who can do a Shieldbiter. Until you. I'm still working out how I feel."),
               say("Chess Master Ailsa", "So these are the pieces from the dune? Look at the queen. Chin in hand. That's the face of someone who has just worked out she is going to win.",
                   "I'll play you, but with creatures. My board, my rules.") +
               [{"do": "battle", "trainer": "hebrides_chessmaster", "intro": True}] +
               say("Chess Master Ailsa", "A fair fight. Take this. It's a warder from my own set, carved from a walrus tusk. Or it's plastic. I forget which.") +
               [give("ivory_warder"), {"do": "standing", "nation": "scotland", "amount": 2}, setf("q_hebrides_chess_3"), setf("q_hebrides_chess_done")])])
    interior(OUT, "stornoway_lanntair", "An Lanntair", zid, ret_lan, "museum",
             [npc("sw_gallery_guide", "festival_goer", 6, 4, "sw_gallery_guide", name="Gallery Guide")], w=15, h=11,
             props=[("display_case", 2, 3, {"variant": 2}), ("display_case", 12, 3, {"variant": 1}), ("piano", 7, 2, {})],
             signs=[(4, 6, "AN LANNTAIR. Gaelic for 'the lantern'. Exhibitions of island art and photography, with a cinema, a theatre and a restaurant overlooking the harbour. Tonight: a ceilidh. Tomorrow night: a film about weather.")])
    script("stornoway_lanntair", "sw_gallery_guide", say("Gallery Guide",
           "Fàilte! The arts centre. Music, film, a very good cafe. A ceilidh is a dance with a band, a caller who knows what he's doing, and a roomful of people who don't.",
           "We have an exhibition of photographs from the herring days, when the whole of the harbour was full of boats and the whole of the quay was full of women gutting fish. The women were quicker than the machines and sang while they worked."))
    interior(OUT, "stornoway_cafe", "Harbour Mission Cafe", zid, ret_cafe, "cafe",
             [npc("sw_cafe_lady", "villager_4", 3, 1, "sw_cafe_lady", name="Cafe Lady"),
              npc("sw_tweed_gossip", "fisherman_north", 9, 3, "sw_tweed_gossip", name="Fisherman", facing="left")],
             props=[("fireplace", 6, 1, {"walk": True})])
    script("stornoway_cafe", "sw_cafe_lady", say("Cafe Lady",
           "Soup, scone, and a cup of tea you could stand a spoon in. There's a bannock fresh out the oven. A bere bannock, with barley from the machair. Warm, with butter. It's a plain thing and the best plain thing there is."))
    script("stornoway_cafe", "sw_tweed_gossip", say("Fisherman",
           "Mind, my mother wove tweed in the shed. Click-clack, click-clack. Every house had a loom, I thought everyone's mother did. It was a shock to move to Glasgow and find people with no click-clack at all.",
           "Mothers waulked the cloth too, thumping it on a table with their hands and feet, singing òran luaidh, waulking songs, to keep time and to pass the work. If you don't know a few verses, you're not from round here, or you're from Edinburgh."))
    interior(OUT, "stornoway_tweed", "Harris Tweed Authority", zid, ret_tw, "workshop",
             [npc("sw_inspector", "prof_garside", 6, 3, "sw_inspector", name="Inspector")],
             props=[("table", 3, 3, {}), ("table", 9, 3, {})],
             signs=[(6, 6, "THE ORB. Every length of Harris Tweed is inspected here and stamped on the cloth with the Orb. If it's not woven by hand in the islanders' own home, it can't have it.")])
    script("stornoway_tweed", "sw_inspector", [
        cmd_if("q_hebrides_tweed_done", say("Inspector", "Your first Orb. Many a weaver has framed the first one. I'd frame yours. Any length that comes in carrying the right feel gets the same stamp, whoever wove it."),
               [cmd_if("q_hebrides_tweed_3",
                       say("Inspector", "A length of tweed for stamping? Let me see. Handwoven, from pure wool dyed and spun on the islands, no machine anywhere in it. I can feel the beat in the weave. Seonag's work, with a bit of yours. Good.",
                           "Right. The Orb. A bang, a stamp, and that's another one for the Western Isles. Harris Tweed was woven in this length, and now it's official.",
                           "Here's a cap in the same cloth. It's warm, it's waterproof, and it's the nearest thing to armour a person can wear without a licence.") +
                       [give("harris_tweed_cap"), {"do": "standing", "nation": "scotland", "amount": 2}, setf("q_hebrides_tweed_4"), setf("q_hebrides_tweed_done")],
                       say("Inspector", "I stamp the Orb on every length. Before I do, I check the weave, the feel, and whether it smells of damp hill, which is a good sign. If you've a length that Seonag wove, bring it here.",
                           "The old test of good tweed: you could stand in a downpour in it and keep your thinking dry."))])])
    interior(OUT, "stornoway_butcher", "Black Pudding Butcher", zid, ret_bu, "workshop",
             [npc("sw_butcher", "shopkeeper", 5, 3, "sw_butcher", name="Butcher")], w=11, h=9,
             props=[("display_case", 2, 1, {"variant": 1}), ("display_case", 8, 1, {"variant": 2})])
    script("stornoway_butcher", "sw_butcher", say("Butcher",
           "Black pudding, white pudding, lamb, a bit of mutton and a sausage with a name. Oatmeal, suet, onion and blood. It's all in the seasoning, and I'll not be telling you what's in the seasoning.",
           "Most of the pudding goes into the 'full breakfast'. We do not do a half one. Two rounds of black pudding, two eggs, tomato, bacon and a potato scone. And mushrooms, for the look of it."))
    interior(OUT, "stornoway_pub", "The Minch Arms", zid, ret_pub, "cafe",
             [npc("sw_landlord", "villager_2", 3, 1, "sw_landlord", name="Landlord"),
              npc("sw_bard_npc", "bard", 9, 3, "sw_bard_npc", name="The Bard", facing="left")],
             props=[("fireplace", 6, 1, {"walk": True})])
    script("stornoway_pub", "sw_landlord", say("Landlord",
           "Fàilte! Welcome to the Minch Arms. If you're wanting a quiz, Scottish questions, losers buy the crisps. If you're wanting a pint, be prepared to wait. The queue's a long one and the tap is a slow one.") +
           [{"do": "quiz", "pub": "stornoway_pub", "region": "scotland", "who": "Landlord"}])
    script("stornoway_pub", "sw_bard_npc", [
        cmd_if("q_hebrides_rhyme_2", say("The Bard", "Go well. And remember: in the Gaelic tradition a verse is a gift. Answer a Blue Man's verse with a good one, and he'll give you a gift back."),
               [cmd_if("q_hebrides_rhyme_1",
                       say("The Bard", "The Skipper sent you? About the Blue Men? Right. A rhyme has two halves. The Blue Man gives you the first. You answer in the same tune, ending on the same sound. If it ends well, it holds.",
                           "Test: if he says 'tide', you say...") +
                       [choice("Which rhymes with tide?", ["Cat", "Ride", "Moon"], "_bard_1"),
                        cmd_if("_bard_1",
                               say("The Bard", "Ride! Exactly. 'Tide' and 'ride'. Tide-wide-ride-guide. Easy as that. You've the ear. Away and catch a gale.") + [setf("q_hebrides_rhyme_2")],
                               say("The Bard", "No, no. Listen to the ending. 'Tide'. Now think of something you do on a horse. Try again."), eq=1)],
                       say("The Bard", "I'm the Bard of Stornoway. Mostly of the Minch Arms. I wrote a song about the weather and it's got forty verses. It's about the same weather, but I think of it as an epic."))])])
    interior(OUT, "stornoway_kirk", "The Kirk", zid, ret_kirk, "church",
             [npc("sw_elder", "choir_singer", 6, 2, "sw_elder", name="Church Elder")])
    script("stornoway_kirk", "sw_elder", say("Church Elder",
           "Fàilte. You're welcome to sit. We keep the Sabbath here, the day of rest, and the church is full on a Sunday morning. The singing is unaccompanied.",
           "In Gaelic psalm singing, a precentor sings out each line, and the congregation takes it up and winds it round and round, every voice in its own time. It sounds like waves, and a good many visitors cry. Some of the singers do too.",
           "You needn't believe what we believe to find it beautiful. Sit as long as you like."))
    interior(OUT, "stornoway_home_a", "Gaelic Teacher's House", zid, ret_ha, "home",
             [npc("sw_teacher", "villager_6", 4, 3, "sw_teacher", name="Gaelic Teacher")], w=11, h=9)
    script("stornoway_home_a", "sw_teacher", say("Gaelic Teacher",
           "Ciamar a tha thu? How are you? Tha gu math, I'm well. 'Tha' is 'is'. 'Gu math' is 'very well'. You've just made a whole sentence, and they said it couldn't be done.",
           "Gaelic has no word for yes or no, did you know? You answer with the verb of the question. Are you tired? 'I am.' or 'I am not.' It's more honest. And quicker. Though it does mean you can never avoid a question."))
    interior(OUT, "stornoway_home_b", "Old Fisherman's House", zid, ret_hb, "home",
             [npc("sw_oldfisher", "fisherman_north", 5, 3, "sw_oldfisher", name="Old Fisherman")], w=11, h=9)
    script("stornoway_home_b", "sw_oldfisher", say("Old Fisherman",
           "In my day we fished the Minch for herring: hundreds of boats at the quay, and the herring girls travelling round the coast gutting for twelve hours a day. They sang and they were fast. Faster than the knife, some of them.",
           "I met a Blue Man once. I was fourteen, in a boat in a thick fog, and a wee voice said a rhyme. I got it wrong, mind. I swam ashore. The rhyme was 'Skipper, skipper, mind the rocks'. I said 'Aye'. It's not in the right metre."))


def memory_coach(OUT):
    """the Retired Keeper every Sanctuary has (see add_memory_coach.py; his lines are in data/dialogue/common.json)."""
    import json
    path = OUT + "/stornoway_sanctuary.json"
    z = json.load(open(path))
    if not any(n.get("id") == "memory_coach" for n in z["npcs"]):
        z["npcs"].append({"id": "memory_coach", "sprite": "poet", "x": 8, "y": 4, "facing": "down", "move": "still",
                          "script": "memory_coach", "name": "Retired Keeper"})
        json.dump(z, open(path, "w"), indent=1, ensure_ascii=False)


if __name__ == "__main__":
    OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
    harris(OUT)
    stornoway(OUT)
    memory_coach(OUT)
    write_all(OUT)
    print("hebrides: written")
