# 3.0 Wider Isles, region "humber": two cul-de-sacs off existing towns.
#   York (east gate) -> yorkshire_wolds (route) -> hull (town)
#   Nottingham (east lane) -> lincoln (town)
# Writes the three outdoor zones, their interiors, dialogue and trainers:
#     python3 tools/zones/humber.py tools/zones data/zones
# The anchors (york.json, nottingham.json) were opened by hand (an edge, a road through the wall, a fingerpost).
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from p6a_common import *
from wcommon import _stand, DLG, TRN
from zlib import landmark
import furnish as _furnish

YK = "yorkshire"
MID = "midlands"
WOLDS_FLOOR = 84
HULL_FLOOR = 84
LINCOLN_FLOOR = 88


# --- helpers -------------------------------------------------------------------

def bld(z, x, y, w, h, style, label, kind=None, door=None, show_label=True):
    pos = z.building(x, y, w, h, style, label, door=door, show_label=show_label)
    if kind:
        z.d["props"][-1]["kind"] = kind
    return pos


def plaque(z, x, y, pid, title, text, kind=None, dx=None):
    s = {"x": x, "y": y, "text": text, "plaque": pid, "title": title}
    if kind:
        s["kind"] = kind
    if dx is not None:
        s["dx"] = dx
    z.d["signs"].append(s)


def IF(flag, then, els=None, eq=None):
    c = {"do": "if", "flag": flag, "then": then, "else": els or []}
    if eq is not None:
        c["eq"] = eq
    return c


def SET(flag, value=True):
    return {"do": "set", "flag": flag, "value": value}


def GIVE(item, n=1):
    return {"do": "give_item", "item": item, "n": n}


def STAND(n):
    return {"do": "standing", "nation": "england", "amount": n}


def room(OUT, town_z, zid, name, door, kind, people, w=13, h=10, extra=(), tiles=(), music=""):
    """A walk-in interior behind the door at `door` (x, y) in town_z. people: (id, sprite, x, y, facing, who, lines|cmds).
    extra: prop dicts placed before the furnishing pass. tiles: (x, y, w, h, ch) rects painted first."""
    town = town_z.d["id"]
    ret = (door[0], door[1] + 1)
    npcs = []
    DLG.setdefault(zid, {})
    for (nid, sprite, x, y, facing, who, body) in people:
        npcs.append({"id": nid, "sprite": sprite, "x": x, "y": y, "facing": facing, "move": "still", "script": nid})
        if body is not None:
            DLG.setdefault(zid, {})[nid] = say(who, *body) if isinstance(body[0], str) else body
    zz = landmark(OUT, zid, name, town, ret, kind, npcs, w, h, furnish=False, write=False)
    zz.d["music"] = music
    for (x, y, ww, hh, ch) in tiles:
        zz.rect(x, y, ww, hh, ch)
    taken = {(n["x"], n["y"]) for n in npcs}
    zz.d["props"] = [p for p in zz.d["props"] if (p["x"], p["y"]) not in taken and zz.g[p["y"]][p["x"]] in "|+"]
    for p in extra:
        zz.d["props"] = [q for q in zz.d["props"] if not (q["x"] == p["x"] and q["y"] == p["y"] and not q.get("walk"))]
        zz.d["props"].append(p)
    zz.d["props"].extend(_furnish.furnish(kind, name, zid, ["".join(r) for r in zz.g], zz.d["props"], zz.d["npcs"], zz.d["warps"], zz.d["spawn"]))
    zz.save(OUT + "/" + zid + ".json")
    town_z.warp(door[0], door[1], zid, w // 2, h - 3, "up")


def scaled_trainers(prefix, floor):
    for tid, t in TRN.items():
        if tid.startswith(prefix):
            t["scaled_floor"] = floor


def trainer_def(tid, name, cls, sprite, party, intro, win, after, money):
    """A trainer fought from a script (no overworld NPC)."""
    TRN[tid] = {"id": tid, "name": name, "class": cls, "sprite": sprite,
                "party": [{"species": s, "level": l} for s, l in party], "ai": "trainer", "money": money,
                "intro": say(name, *intro), "win": win, "after": after}


def phone(z, x, y, hull=True):
    clear_prop(z, x, y)
    z.prop("phone_box", x, y, variant=1 if hull else 0)


# --- the Yorkshire Wolds ----------------------------------------------------------

def wolds(OUT):
    W, H = 64, 48
    zid = "yorkshire_wolds"
    z = Z(zid, "Yorkshire Wolds", W, H, kind="route", region=YK, music="route_moors",
          weather={"clear": 30, "sunshine": 22, "drizzle": 20, "gale": 14, "fog": 10, "downpour": 4})
    z.d["stage"] = "grass"
    z.d["scaled_floor"] = WOLDS_FLOOR
    z.legend["g"] = {"tile": "grass", "colour": "#9aae5e"}       # close-cropped chalk downland
    z.legend["k"] = {"tile": "path", "colour": "#e2dccb"}        # white chalk tracks
    z.rect(0, 0, W, H, "g")
    hills(z, [(14, 34, 2, 12), (50, 34, 2, 13), (16, 11, 1, 8)])
    z.border("T", 2, gaps=[(0, 22, 2, 3), (30, 46, 3, 2)])
    # the lane from York, and Woldgate south to Hull
    z.rect(0, 22, 33, 3, "k")
    z.rect(30, 22, 3, 26, "k")
    # a track north-east to Rudston
    z.rect(31, 12, 3, 10, "k")
    z.rect(31, 12, 20, 2, "k")
    # Rudston: All Saints' church and the monolith in its churchyard
    z.rect(38, 2, 18, 9, "g")
    for x in range(38, 56):
        z.set(x, 2, "H")
    for y in range(2, 11):
        z.set(38, y, "H"); z.set(55, y, "H")
    for x in range(38, 56):
        if x not in (46, 47, 48):
            z.set(x, 10, "H")
    bld(z, 45, 4, 7, 3, "limestone_church", "All Saints Church, Rudston", "church", door=3)
    bld(z, 42, 5, 1, 1, "monolith", "The Rudston Monolith", show_label=False)
    z.rect(46, 7, 3, 4, "k")
    z.prop("tomb_chest", 40, 8); z.prop("standing_stone", 53, 8, variant=0); z.prop("standing_stone", 40, 4, variant=0)
    z.prop("bench", 44, 8); z.prop("oak", 53, 4, variant=1)
    plaque(z, 41, 6, "wolds_rudston_monolith", "The Rudston Monolith",
           "THE RUDSTON MONOLITH. At about 7.6 metres, the tallest standing stone in Britain, and probably as much again "
           "below ground. It was raised around 4,000 years ago from gritstone dragged here from the coast near Scarborough, "
           "some ten miles off. The Normans built All Saints right beside it, which tells you who was here first.")
    # the Gypsey Race: a chalk stream that only runs some years
    path(z, [(57, 3), (57, 11), (52, 11)], "w")
    path(z, [(52, 11), (52, 16), (36, 16), (36, 20)], "w")
    plaque(z, 50, 15, "wolds_gypsey_race", "The Gypsey Race",
           "THE GYPSEY RACE. A chalk stream that flows past Rudston to Bridlington, except when it doesn't. For years at a time "
           "its bed lies dry, then the water rises out of the chalk. Wolds folk called it a woe water: when it ran, "
           "they said, bad times were coming, from failed harvests to war.")
    # Kilham: a chalk-walled farm with pantiles, fields of sheep, and the kite watchers
    bld(z, 6, 27, 6, 3, "pantile_chalk", "Kilham Farm", "cottage")
    bld(z, 13, 27, 4, 3, "pantile_brick", "Granary", show_label=False)
    for x in range(4, 26):
        z.set(x, 31, "H")
    for y in range(31, 44):
        z.set(4, y, "H"); z.set(25, y, "H")
    for x in range(4, 26):
        z.set(x, 43, "H")
    z.set(15, 31, "g")
    for (x, y, v) in [(8, 34, 1), (11, 37, 0), (19, 35, 1), (21, 40, 2), (9, 41, 1), (16, 39, 0)]:
        z.prop("sheep", x, y, variant=v)
    plaque(z, 18, 26, "wolds_red_kites", "Red Kites over Kilham",
           "RED KITES. Look up: a forked tail and a mewing whistle. Red kites were wiped out in England by the 1870s, "
           "poisoned and shot as vermin. Birds brought from Spain were released at Harewood near Leeds in 1999, and their "
           "young have spread east over the Wolds. Kilham folk now count them from the farm gate.")
    # Woldgate: an avenue of trees on the old Roman road, as painted by David Hockney
    for y in range(28, 45, 2):
        z.prop("oak", 28, y, variant=y % 3)
        z.prop("oak", 34, y, variant=(y + 1) % 3)
    plaque(z, 29, 26, "wolds_hockney", "Hockney's Wolds",
           "WOLDGATE. David Hockney, born in Bradford, came back to paint the Wolds from 2004, often outdoors and in all "
           "weathers. 'Bigger Trees Near Warter' (2007) was painted on fifty canvases at once, and 'The Arrival of Spring "
           "in Woldgate' (2011) partly on an iPad. Woldgate is an old Roman road from York to Bridlington.")
    # Wharram Percy: a village that emptied five hundred years ago
    for (x, y) in [(44, 30), (47, 31), (50, 29), (45, 34), (52, 33), (48, 36)]:
        z.prop("rock", x, y, variant=(x + y) % 3)
    z.prop("standing_stone", 49, 32, variant=2)
    plaque(z, 46, 28, "wolds_wharram_percy", "Wharram Percy",
           "WHARRAM PERCY. Up on the western Wolds lie the humps and bumps of a deserted medieval village, its roofless "
           "church still standing. Its people were slowly turned out around 1500 as the land went over to sheep, which "
           "paid better. Archaeologists dug there every summer for forty years.")
    # a dew pond
    z.rect(56, 22, 3, 2, "~"); z.rect(55, 21, 5, 1, "w"); z.rect(55, 24, 5, 1, "w")
    z.set(55, 22, "w"); z.set(55, 23, "w"); z.set(59, 22, "w"); z.set(59, 23, "w")
    plaque(z, 54, 25, "wolds_dew_pond", "Dew Pond",
           "DEW POND. Chalk drinks the rain straight down, so the Wolds have few streams. Farmers dug shallow ponds and "
           "lined them with puddled clay to catch the rain for their sheep. Despite the name, almost none of the water "
           "is dew.")
    plaque(z, 3, 21, "wolds_wolds_way", "The Yorkshire Wolds Way",
           "THE YORKSHIRE WOLDS WAY. A National Trail of 79 miles, from Hessle under the Humber Bridge to Filey Brigg on "
           "the coast, all chalk dales and big skies. Follow the acorn waymarks, and the sheep, who know a short cut.")
    z.sign(33, 25, "WOLDGATE. South: Hull, Hessle Road and the Humber. North-east: Rudston. West: York.")
    # tall grass and scattered trees
    blob(z, 20, 14, 6, 3, ",", only="g", seed=11, jitter=0.3)
    blob(z, 44, 21, 6, 3, ",", only="g", seed=12, jitter=0.3)
    blob(z, 13, 37, 6, 3, ",", only="g", seed=13, jitter=0.3)
    blob(z, 54, 40, 5, 3, ",", only="g", seed=14, jitter=0.3)
    blob(z, 9, 8, 4, 3, ",", only="g", seed=15, jitter=0.3)
    scatter_props(z, "oak", 3, 3, 30, 18, 7, 21, avoid=("g",))
    scatter_props(z, "bush", 36, 18, 26, 26, 8, 22, avoid=("g",))
    scatter_props(z, "birch", 3, 3, 28, 16, 3, 23, avoid=("g",))
    # NPCs
    chat(z, "wld_farmer", "farmer", 9, 30, "Kilham Farmer",
         ["Now then. Chalk, this, all the way down. Grows grand barley and lousy ponds. My granddad's sheep never knew a stream.",
          "See the roofs? Pantiles. Orange clay, curled like an S, made just over the Humber and shipped in from the Low Countries "
          "before that. Every barn in East Yorkshire wears a pantile hat."], "down")
    chat(z, "wld_flint", "hiker", 22, 18, "Flint Picker",
         ["The ploughs bring up flints every winter. Black inside, white crust, sharp as a tongue. Folk here built walls with them "
          "and Stone Age folk made arrowheads.",
          "Plenty for everyone. Take a handful, the field won't miss them."], "left")
    DLG[zid]["wld_flint"] += [{"do": "daily", "key": "humber_flint_day", "then": [GIVE("wolds_flint", 2)],
                               "else": say("Flint Picker", "That's today's lot. Come back tomorrow, the plough'll have turned up more.")}]
    chat(z, "wld_hare", "birdwatcher", 40, 24, "Hare Watcher",
         ["Brown hares, out on the open wolds. In spring the females box the males off when they get too keen. Everybody thinks "
          "it's two lads fighting. It's a lass saying no.",
          "Hares never dig burrows. They lie up in a scrape in the grass called a form, and trust their legs."], "up", "wander")
    # trainers
    trainer(z, "wld_rambler", "Rambler Gail", "Rambler", "hiker",
            [("gealhare", 84), ("forkwing", 84), ("herdwick", 84)], 18, 22, "down",
            ["Seventy-nine miles of Wolds Way and I've only fallen in one dew pond. Fancy a battle while I wring my socks out?"],
            "Fair enough. I'll walk it off. Literally, it's another forty miles.",
            "The acorn waymarks are on every gatepost. Keep the acorn on your left and the sheep on your right.", 3480)
    trainer(z, "wld_kites", "Kite Watcher Derek", "Birdwatcher", "birdwatcher",
            [("forkwing", 84), ("stoopfalcon", 84), ("hushwing", 85)], 13, 33, "right",
            ["Shh! Seventeen kites over Kilham this morning. Eighteen if you count the one I've got in my team."],
            "Outflown. A new tick for the notebook: beaten by a passer-by.",
            "Red kites will pinch washing off the line to build their nests. Pants, socks, a teddy once. Lock up your smalls.", 3500)
    trainer(z, "wld_painter", "Painter Iris", "Painter", "poet",
            [("pixiedell", 84), ("murmurant", 84), ("roodstone", 85)], 35, 36, "left",
            ["I'm doing what Hockney did: painting the same lane in every season. This is the battle season, apparently."],
            "You've a good eye. I'll paint you in. Small, in the corner, losing.",
            "Hockney painted the trees here on dozens of canvases at once, then stood the panels together like a jigsaw.", 3500)
    wild(z, [("leveret", 84, 84, 16, {}), ("kitelet", 84, 84, 10, {"time": ["day", "dawn"]}), ("starlet", 84, 84, 10, {}),
             ("rooklet", 84, 84, 10, {}), ("moldiwarp", 84, 84, 8, {}), ("herdlet", 84, 84, 8, {}), ("pipkin", 84, 84, 8, {}),
             ("spikkin", 84, 84, 6, {"time": ["dusk", "night"]}), ("hootlet", 84, 84, 6, {"time": ["night"]}),
             ("barnling", 84, 84, 6, {"time": ["night", "dusk"]}), ("stoatlet", 84, 84, 6, {}),
             ("roodstone", 85, 85, 3, {"time": ["night", "dusk", "dawn"]})])
    wild(z, [("dipling", 84, 84, 30, {}), ("stalklet", 84, 84, 25, {}), ("croakle", 84, 84, 25, {}), ("borelet", 84, 84, 10, {"weather": ["drizzle", "downpour"]})], "water")
    z.d["edges"] = {"west": {"to": "york", "offset": 8}, "south": {"to": "hull", "offset": 0}}
    z.d["spawn"] = [4, 23]
    smooth(z)
    done(z)
    z.save(OUT + "/" + zid + ".json")
    # All Saints, Rudston
    room(OUT, z, "wolds_rudston", "All Saints Church, Rudston", (48, 6), "church", [
        ("wld_warden", "choir_singer", 3, 2, "down", None, None)], w=13, h=10)
    z.save(OUT + "/" + zid + ".json")
    DLG["wolds_rudston"]["wld_warden"] = [
        IF("q_humber_petition_1", [IF("q_humber_petition_2", say("Churchwarden", "Signed, sealed and on its way. Wilberforce rode out to the Wolds villages himself at election time, you know. Mind, it took him four days to get round."),
                                       say("Churchwarden", "A petition against the slave trade, from Hull? Give it here.",
                                           "Wilberforce was MP for all of Yorkshire from 1784, and that meant the Wolds too. Our farmers voted for him.",
                                           "There. My name, and the vicar's, and the woman who does the flowers, who has very firm opinions.") + [SET("q_humber_petition_2"), {"do": "say", "who": "", "text": "Two names down on the petition. One more to go, in Hull."}])],
           say("Churchwarden", "Welcome to All Saints. Yes, the stone outside is older than the church. Older than the Romans. We've stopped arguing with it.",
               "Winifred Holtby, the writer, is buried in the churchyard here. She wrote 'South Riding', about East Yorkshire folk, and died young in 1935."))]


# --- Hull -----------------------------------------------------------------------

def hull(OUT):
    W, H = 72, 60
    zid = "hull"
    z = Z(zid, "Hull", W, H, kind="town", region=YK, music="town_north",
          weather={"drizzle": 26, "clear": 24, "gale": 16, "fog": 14, "sunshine": 14, "downpour": 6})
    z.d["stage"] = "docks"
    z.d["town_id"] = "hull"
    z.d["scaled_floor"] = HULL_FLOOR
    z.rect(0, 0, W, H, ".")
    z.border("T", 2, gaps=[(30, 0, 3, 2)])
    # roads: north from the Wolds down to the waterfront, and west to Hessle Road
    z.rect(30, 0, 3, 45, "=")
    z.rect(2, 20, 51, 3, "=")
    z.rect(7, 22, 2, 23, ":")
    # Paragon station (a terminus: buffer stops)
    station(z, 6, 10, 10, 5, "Hull Paragon Interchange")
    z.rect(0, 13, 6, 1, "!")
    z.prop("buffer_stop", 16, 13)
    z.rect(16, 11, 14, 1, ":"); z.rect(16, 12, 1, 1, ":")
    rail_guard(z, 17, 12, ["Hull Paragon. End of the line, and proud of it. The trains to London are Hull Trains, the city's own, "
                           "running to King's Cross since 2000.", "All aboard! Trains go to any station you've been to. Mind the gap and the gulls."],
               facing="left")
    z.prop("statue", 19, 9, variant=1)
    z.prop("bench", 21, 9)
    plaque(z, 19, 10, "hull_larkin", "Philip Larkin",
           "PHILIP LARKIN (1922 to 1985). Poet and, for thirty years, librarian at the University of Hull. His statue hurries "
           "for a train here, as in his poem 'The Whitsun Weddings', which starts on a slow train out of Hull one hot "
           "Saturday. He called the city 'in the world, yet sufficiently on the edge of it'.")
    # Sanctuary and shop on the way in
    z.rect(33, 10, 18, 1, ":")
    bld(z, 35, 6, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(38, 9, "hull_sanctuary", 5, 6, "up")
    bld(z, 43, 6, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(45, 9, "hull_shop", 4, 5, "up")
    # Queen Victoria Square: the statue, the Ferens and the City of Culture
    z.rect(16, 23, 14, 6, ":")
    z.prop("statue", 23, 25, variant=0)
    bld(z, 17, 15, 9, 4, "stone", "Ferens Art Gallery", "museum")
    bld(z, 34, 14, 10, 4, "stone", "Hull Maritime Museum", "museum")
    for (x, y) in [(18, 27), (28, 27)]:
        z.prop("planter", x, y)
    z.prop("bunting", 20, 23); z.prop("bunting", 26, 23)
    plaque(z, 21, 26, "hull_city_of_culture", "City of Culture 2017",
           "UK CITY OF CULTURE 2017. Hull's year of culture opened with a light show on the waterfront and filled the city "
           "with art. 'Blade', a 75-metre wind turbine blade made in Hull, was laid across this square like a giant had "
           "dropped it. Nine in ten people in Hull went to at least one event.")
    plaque(z, 25, 26, "hull_kingston", "Kingston upon Hull",
           "KINGSTON UPON HULL. The town of Wyke was bought by Edward I in 1293, renamed the King's Town on the River Hull, "
           "and given its charter in 1299. Hardly anybody calls it that. It's Hull, or 'Ull, depending how many aitches "
           "you've got spare.")
    # the River Hull, with the Arctic Corsair at her berth and the Scale Lane swing bridge
    z.rect(54, 2, 4, 45, "~")
    z.rect(53, 2, 1, 45, "w"); z.rect(58, 2, 1, 45, "w")
    z.rect(53, 32, 6, 2, ":")
    bld(z, 54, 24, 3, 8, "trawler", "Arctic Corsair", "museum", door=1)
    plaque(z, 52, 31, "hull_arctic_corsair", "The Arctic Corsair",
           "ARCTIC CORSAIR. A sidewinder trawler built in 1960, now the last of Hull's deep-sea fleet you can step aboard. "
           "Crews worked off Iceland and Norway for three weeks at a time, gutting fish on an open deck in Arctic gales. In "
           "the Cod War of 1976 she rammed an Icelandic gunboat.")
    # the Old Town: the Minster, Wilberforce House, Ye Olde White Harte
    z.rect(33, 31, 20, 3, ":")
    z.rect(33, 37, 20, 2, ":")
    z.rect(33, 23, 20, 1, ":")
    bld(z, 36, 26, 11, 4, "limestone_church", "Hull Minster", "church", door=4)
    bld(z, 44, 34, 6, 3, "georgian_brick", "Wilberforce House", "museum", door=2)
    bld(z, 35, 34, 6, 3, "pantile_brick", "Ye Olde White Harte", door=2)
    bld(z, 49, 24, 3, 3, "georgian_brick", "Old Town", show_label=False)
    plaque(z, 47, 36, "hull_wilberforce", "William Wilberforce", (
        "BLUE PLAQUE: William Wilberforce (1759 to 1833) was born in this house. As MP he led the twenty-year fight in "
        "Parliament against the slave trade, which Britain abolished in 1807. The Slavery Abolition Act passed in 1833, "
        "three days before he died."), kind="plaque", dx=0.5)
    plaque(z, 41, 30, "hull_minster", "Hull Minster",
           "HULL MINSTER. Holy Trinity, begun around 1300, is one of the earliest great buildings in England to use brick, "
           "made from Humber clay because stone was scarce. It is England's largest parish church by floor area, and "
           "became Hull Minster in 2017.")
    plaque(z, 34, 30, "hull_beverley_gate", "Beverley Gate, 1642",
           "BEVERLEY GATE. In April 1642 King Charles I rode up to Hull's gate to claim the arsenal stored here, and the "
           "governor, Sir John Hotham, shut it in his face. It was one of the first acts of defiance of the Civil War. "
           "Hotham switched sides later and lost his head for it.")
    # Hessle Road: the fishing community's terraces and the chippy
    z.rect(2, 33, 28, 2, ":")
    bld(z, 2, 30, 5, 3, "terrace", "Hessle Road", "home", door=2)
    bld(z, 10, 30, 6, 3, "white_render", "Patty and Chips", "cafe", door=2)
    bld(z, 18, 30, 6, 3, "terrace", "Hessle Road Terrace", show_label=False)
    bld(z, 10, 36, 14, 3, "terrace", "Fish Dock Terrace", show_label=False)
    z.rect(2, 39, 28, 1, ":")
    plaque(z, 12, 40, "hull_bullnose", "The Bullnose",
           "THE BULLNOSE. At the old St Andrew's Dock, where Hessle Road's trawlers sailed from, a memorial remembers the "
           "6,000 and more Hull fishermen lost at sea. After three trawlers sank in a few weeks in 1968, Lillian Bilocca "
           "and the Headscarf Revolutionaries of Hessle Road won new safety rules for every crew.")
    # the waterfront, the Humber, and the bridge away west at Hessle
    z.rect(0, 46, W, 14, "~")
    z.rect(0, 45, W, 1, "w")
    z.rect(7, 44, 46, 1, ":")
    z.rect(59, 44, 11, 1, ":")
    bld(z, 3, 42, 3, 18, "humber_bridge", "Humber Bridge", show_label=False)
    plaque(z, 9, 41, "hull_humber_bridge", "The Humber Bridge",
           "THE HUMBER BRIDGE. Opened in 1981, and for sixteen years the longest single-span suspension bridge in the "
           "world: 1,410 metres between the towers. The towers stand 155 metres tall, and are 36 millimetres further apart "
           "at the top than at the bottom, because the Earth is curved.")
    # east bank: Sammy's Point and The Deep
    z.rect(59, 32, 11, 2, ":")
    z.rect(68, 34, 2, 10, ":")
    bld(z, 59, 38, 8, 5, "the_deep", "The Deep", "museum", door=3)
    z.rect(59, 43, 9, 1, ":")
    plaque(z, 64, 43, "hull_the_deep", "The Deep",
           "THE DEEP. An aquarium shaped like a shard of rock rearing out of the Humber, opened in 2002 at Sammy's Point, "
           "where the River Hull meets the estuary. Its tall main tank holds sharks and rays, and a glass lift rides up "
           "through the middle of it.")
    plaque(z, 60, 31, "hull_sammys_point", "The Humber",
           "THE HUMBER. Not a river but an estuary, where the Trent and the Ouse meet and run out to the North Sea. Its "
           "water is brown with silt, not dirt: the tide churns up the mud twice a day. Ships have come up it to Hull "
           "for seven hundred years.")
    # cream phone boxes: Hull had its own telephone company
    for (x, y) in [(29, 5), (33, 24), (29, 36), (43, 33), (15, 29), (66, 31), (9, 24)]:
        phone(z, x, y)
    plaque(z, 28, 5, "hull_phone_boxes", "Cream Phone Boxes",
           "CREAM PHONE BOXES. Hull's K6 kiosks are cream, not red, and wear no crown. From 1902 the city council ran its "
           "own telephone service, the only one in Britain to stay independent of the national network, and it still "
           "goes its own way. Locals will tell you it's not a 'phone', it's a 'fern'.")
    plaque(z, 2, 35, "hull_amy_johnson", "Amy Johnson",
           "AMY JOHNSON (1903 to 1941). Born in Hull, she taught herself engineering and in 1930 became the first woman to "
           "fly solo from Britain to Australia, in a second-hand biplane called Jason. It took her nineteen days.")
    # streets: lamps, benches, trees
    for (x, y) in [(29, 14), (33, 18), (29, 28), (33, 41), (12, 19), (24, 19), (40, 19), (36, 43), (48, 43), (62, 35), (14, 43)]:
        z.prop("lamp_post", x, y)
    for (x, y) in [(18, 24), (28, 24), (38, 39), (46, 39), (20, 43), (26, 43), (64, 35)]:
        z.prop("bench", x, y)
    for (x, y) in [(40, 43), (44, 43)]:
        z.prop("bollard", x, y)
    for (x, y) in [(55, 40), (56, 44), (20, 50), (40, 52), (62, 50)]:
        z.prop("boat", x, y, variant=1)
    z.prop("buoy", 30, 50); z.prop("buoy", 48, 48, variant=1)
    # East Park, with long grass and old trees
    blob(z, 64, 12, 5, 6, ",", only=".", seed=31, jitter=0.3)
    scatter_props(z, "oak", 59, 4, 10, 22, 8, 32, avoid=(".",))
    scatter_props(z, "birch", 3, 3, 12, 6, 3, 33, avoid=(".",))
    blob(z, 22, 5, 4, 2, ",", only=".", seed=34, jitter=0.3)
    # NPCs
    chat(z, "hul_fern", "villager_3", 28, 7, "Hull Local",
         ["Nah then! You'll want a fern? A fern. The cream box, there. Hull's got its own fern company, always has. Red boxes? "
          "Never seen one till I went to Leeds.",
          "Hull's a funny old place. We say 'tenfoot' for the back alley between the terraces, 'nanna' for nan, and 'duck' when "
          "we like you."], "down")
    chat(z, "hul_bobber", "fisherman_north", 13, 34, "Old Bobber",
         ["I was a bobber on the fish dock: we unloaded the catch before dawn, swinging the baskets up out of the hold. "
          "Hessle Road never slept.",
          "Hull had over 300 trawlers once. Three weeks at sea, three days at home, and you spent the three days on Hessle "
          "Road in your best suit."], "down")
    chat(z, "hul_culture", "festival_goer", 26, 28, "Culture Volunteer",
         ["I was a volunteer in 2017. Blue coat, big smile. We had Blade in the square, ten thousand people on the "
          "waterfront and a nude photo shoot painted blue. It was a year, all right.",
          "Hull stopped apologising for itself that year. Hasn't started again since."], "up")
    chat(z, "hul_ferryman", "sailor", 47, 43, "Ferry Hand",
         ["The big ferries sail overnight from King George Dock to Rotterdam. You go to bed in Hull and wake up in Holland, "
          "which is a good trick.",
          "Hull's always faced the other way: east, over the North Sea. More Dutch in our history than Yorkshire likes to admit."],
         "down")
    chat(z, "hul_patty_fan", "villager_6", 18, 34, "Hungry Local",
         ["Patty and chips, love. A patty's mashed potato and sage, battered and deep-fried. Pattie butty if you put it in a "
          "bread cake. You'll not get one west of Goole.", "Don't call it a fishcake. There's no fish in it. That's the point."],
         "left")
    # trainers
    trainer(z, "hul_trawler", "Trawlerman Mick", "Trawlerman", "fisherman_north",
            [("greyhaul", 84), ("clawcastle", 84), ("aegir", 85)], 24, 38, "up",
            ["Three weeks off Bear Island, ice on the rigging, fish to the knees. You think you're tough? Go on then."],
            "You'd have made a deckie. Not a skipper, mind.", "Never whistle on a trawler. Never say 'pig' either. Call it a curly-tail. "
            "Old trawlermen'd turn the boat round for less.", 3480)
    trainer(z, "hul_aquarist", "Aquarist Priya", "Aquarist", "student",
            [("glimmerjaw", 85), ("bayrunner", 84), ("orcaird", 84)], 63, 36, "left",
            ["I feed the sharks at The Deep. They're less trouble than the school parties. Want to meet my team?"],
            "Wonderful. I'll tell the rays all about you.", "Sand tiger sharks look fierce, all those teeth, but they're quite gentle. "
            "Like a librarian with a bad smile.", 3520)
    trainer(z, "hul_rugby", "Rugby League Fan Gaz", "Rugby Fan", "rugby_player",
            [("samsonian", 84), ("warrender", 84), ("raidtail", 85)], 9, 25, "right",
            ["West Hull or East Hull? Hull FC or Hull KR? Answer wrong and we're fighting. Answer right and we're also fighting."],
            "Fair play. You'd get a game at the Boulevard.", "Hull's split by the river: black and white FC on the west, red and white KR "
            "on the east. Derby day, nobody crosses a bridge.", 3500)
    trainer(z, "hul_poet", "Poet Fenella", "Poet", "poet",
            [("lanternis", 84), ("murmurant", 84), ("hushwing", 84)], 22, 12, "left",
            ["Larkin said Hull was on the edge of the world. I've come to the edge to battle. Please be gentle, I'm sensitive."],
            "A rhyme: you won, I'm done. Not my best.", "Larkin wrote at night, in a flat overlooking Pearson Park, and kept his diaries "
            "in a drawer. He asked for them to be burnt, and they were.", 3500)
    trainer(z, "hul_walt", "Skipper Walt", "Silver Cod Skipper", "sailor",
            [("aegir", 87), ("glimmerjaw", 87), ("greyhaul", 86), ("clawcastle", 86), ("orcaird", 86), ("pierlord", 87)],
            38, 41, "down",
            ["Silver Cod Trophy, three years running: top catch of the whole Hull fleet. The Silver Cod went to the best skipper "
             "in Hull or Grimsby every year, and mostly it came to Hull.", "I'll not go easy. The sea never did."],
            "Well. I've been beaten by the North Atlantic, the Icelandic navy and now you. You're in good company.",
            "When the Cod Wars ended in 1976, Iceland had won its 200-mile limit and Hull lost its grounds. A whole way of "
            "life went in a few years. Remember them when you eat your haddock.", 9800)
    TRN["hul_walt"]["party"][0]["held"] = "hag_stone"
    TRN["hul_walt"]["party"][5]["held"] = "horseshoe"
    TRN["hul_walt"]["party"][1]["tea"] = "flask_of_tea"
    wild(z, [("chipgull", 84, 84, 18, {}), ("cooplet", 84, 84, 14, {}), ("binfox", 84, 84, 10, {"time": ["night", "dusk"]}),
             ("grizzlet", 84, 84, 10, {}), ("starlet", 84, 84, 10, {"time": ["dusk", "dawn", "day"]}), ("rooklet", 84, 84, 8, {}),
             ("peregrin", 84, 84, 6, {"time": ["day"]}), ("flittermouse", 84, 84, 6, {"time": ["night"]}),
             ("pepperling", 84, 84, 6, {})])
    wild(z, [("borelet", 84, 84, 18, {}), ("chipgull", 84, 84, 14, {}), ("pinchkin", 84, 84, 14, {}), ("pupplash", 84, 84, 12, {}),
             ("gannetling", 84, 84, 10, {}), ("stalklet", 84, 84, 10, {}), ("glimmerjaw", 85, 85, 6, {"time": ["night"]}),
             ("aegir", 85, 85, 4, {"weather": ["gale", "downpour", "drizzle"]})], "water")
    z.d["edges"] = {"north": {"to": "yorkshire_wolds", "offset": 0}}
    z.d["spawn"] = [31, 3]
    done(z)
    z.save(OUT + "/" + zid + ".json")
    sanctuary(OUT, zid, "Hull", (38, 10), music="sanctuary")
    shop(OUT, zid, "Hull", (45, 10))
    nurse(zid, ["Nah then, duck! Welcome to Hull Sanctuary. Pop your team on the counter and I'll sort 'em out.",
                "There's a cup of tea and a patty on the side. Don't tell the doctor about the patty.",
                "There you go, right as rain. Which in Hull is most days. Mind the gulls on the way out.",
                "The Ark's in the corner, duck. Same as everywhere, only ours is cream.",
                "No bother at all. Ta-ra, duck."])
    shopkeeper(zid, "Nah then! Patties, snares, and a cream fridge magnet you'll not find anywhere else. What can I get you?",
               "Ta-ra, duck! Mind how you go.")
    # interiors
    room(OUT, z, "hull_wilberforce", "Wilberforce House", (46, 36), "museum", [
        ("hul_curator", "tour_guide", 6, 2, "down", None, None),
        ("hul_equiano", "student", 2, 4, "right", "Museum Guide",
         ["Wilberforce spoke in Parliament, but he didn't do it alone. Thomas Clarkson rode thousands of miles gathering evidence. "
          "Quakers started the first petitions.",
          "And Olaudah Equiano, who had been enslaved as a boy, bought his freedom and wrote his life story in 1789. Thousands "
          "read it. People who had suffered spoke up loudest of all."]),
        ("hul_medallion", "villager_5", 10, 4, "left", "Visitor",
         ["Look at this little medallion: a kneeling man in chains, and the words 'Am I not a man and a brother?'. Josiah Wedgwood "
          "made them in 1787 and supporters wore them as brooches and hairpins.", "Like a campaign badge. Two hundred years before badges."])],
        w=13, h=10, extra=[{"type": "display_case", "x": 4, "y": 2}, {"type": "display_case", "x": 8, "y": 2}])
    DLG["hull_wilberforce"]["hul_curator"] = [
        IF("q_humber_petition_done",
           say("Curator", "Your petition's framed in the back office. Three names, and yours. That's how it was done: one signature at a time."),
           [IF("q_humber_petition_started",
               [IF("q_humber_petition_3",
                   say("Curator", "All three! The fisherman's widow, the Wolds churchwarden and even that clerk. Wonderful.",
                       "In 1792 more than five hundred petitions against the slave trade reached Parliament, the most ever sent on a "
                       "single subject at the time. Ordinary people, writing their names, changed the law.",
                       "Please, take this. It was pressed in an old hymn book from the Minster, for luck.")
                   + [GIVE("four_leaf_clover"), GIVE("hull_patty", 3), STAND(4), SET("q_humber_petition_done")],
                   [IF("q_humber_petition_2", say("Curator", "Two names! Now for the hard one: the Parliamentary Clerk in Hull Minster says the "
                                                  "form is wrong. Persuade him, firmly."),
                       [IF("q_humber_petition_1", say("Curator", "One name down. Next, out to the Wolds: the churchwarden at Rudston, by the great stone."),
                           say("Curator", "Start on Hessle Road. The fishing families knew all about hard lives. Ask in the terrace."))])])],
               say("Curator", "Welcome to Wilberforce House. William Wilberforce was born here in 1759, son of a Hull merchant.",
                   "He was elected MP for Hull at twenty-one, then for all Yorkshire. From 1787 he led the campaign in Parliament to "
                   "end the slave trade: British ships had carried millions of enslaved Africans across the Atlantic.",
                   "The campaign worked because ordinary people joined it: they boycotted slave-grown sugar and signed petitions in "
                   "their thousands.")
               + [{"do": "choice", "text": "Help gather names for a petition, as they did then?", "options": ["Gladly", "Not now"], "set": "_hul_pet"},
                  IF("_hul_pet", [SET("q_humber_petition_started"), GIVE("abolition_petition"),
                                  {"do": "say", "who": "Curator", "text": "Bless you. Three names: Hessle Road first, then Rudston on the Wolds, then that stubborn clerk at the Minster."}],
                     say("Curator", "Another time. The house isn't going anywhere. It's been here since the 1660s."), eq=0)])])]
    room(OUT, z, "hull_whiteharte", "Ye Olde White Harte", (37, 36), "cafe", [
        ("hul_landlady", "shopkeeper", 3, 3, "down", None, None),
        ("hul_plotter", "villager_2", 9, 3, "left", "Regular",
         ["Upstairs is the Plotting Parlour. Story goes Sir John Hotham decided there to shut Beverley Gate on the King in 1642. "
          "Whether he did or not, the beer's been good ever since.", "There's a skull in a case behind the bar. Nobody knows whose. "
          "Best not to ask after your second pint."])],
        w=13, h=9)
    DLG["hull_whiteharte"]["hul_landlady"] = say("Landlady", "Nah then, duck. Quiz night, every night. Northern questions, northern prizes.") + [
        {"do": "quiz", "pub": "hull_whiteharte", "region": "england_north", "who": "Landlady"}]
    room(OUT, z, "hull_minster", "Hull Minster", (40, 29), "church", [
        ("hul_verger", "choir_singer", 3, 2, "down", "Verger",
         ["This church is built of brick, and brick was still a newfangled thing in England when they started. Humber clay, baked "
          "in Hull. The stone was for the fancy bits.", "Wilberforce's family worshipped here. So did nearly everybody in Hull, at "
          "one time or another, usually at weddings."]),
        ("hul_clerk", "commuter", 10, 2, "down", None, None)], w=13, h=10)
    DLG["hull_minster"]["hul_clerk"] = [
        IF("q_humber_petition_3", say("Parliamentary Clerk", "Yes, yes, the petition is in order. I've stamped it twice. Don't tell anyone I helped."),
           [IF("q_humber_petition_2",
               say("Parliamentary Clerk", "A petition? To Parliament? Hm. The margins are wrong, the ink is common and I don't like your tone.",
                   "If you want my signature, you'll have to argue for it.")
               + [{"do": "battle", "trainer": "hul_clerk"}, SET("q_humber_petition_3"),
                  {"do": "say", "who": "Parliamentary Clerk", "text": "Oh, very well. A good argument is a good argument. There: signed, stamped, sanded."},
                  {"do": "say", "who": "", "text": "Three names on the petition. Back to Wilberforce House."}],
               say("Parliamentary Clerk", "I am on my lunch. I am always on my lunch."))])]
    trainer_def("hul_clerk", "Parliamentary Clerk Pemberton", "Clerk", "commuter",
            [("centurion", 85), ("stoopfalcon", 85), ("steelheart", 85)],
            ["Point of order!"], "Point taken.", "Petitions must be on paper, in English, and polite. Yours was two out of three.", 3600)
    room(OUT, z, "hull_deep", "The Deep", (62, 42), "museum", [
        ("hul_diver", "surfer", 3, 4, "right", "Aquarium Diver",
         ["I dive in the big tank every morning to clean the glass. The sharks watch me like I'm the show. To be fair, I am.",
          "The Deep calls itself a submarium: an aquarium you go down into. Start at the top with the ice, end at the bottom with "
          "the deep-sea things that make their own light."]),
        ("hul_kid", "villager_4", 9, 5, "up", "School Trip Kid",
         ["Miss said anglerfish make light with bacteria. Bacteria! In its face! That's the best thing I've ever heard.",
          "I'm going to be a marine biologist. Or a shark. Whichever."])],
        w=13, h=10, tiles=[(2, 1, 9, 2, "~")],
        extra=[{"type": "display_case", "x": 1, "y": 6}, {"type": "display_case", "x": 11, "y": 6}])
    room(OUT, z, "hull_corsair", "Arctic Corsair", (55, 31), "museum", [
        ("hul_skipper", "fisherman_north", 6, 2, "down", None, None),
        ("hul_deckie", "sailor", 2, 4, "right", "Old Deckhand",
         ["Deckies worked the fish on the open deck: gutting, washing, packing in ice down the fishroom. Eighteen hours on, six off.",
          "Sidewinders hauled the net over the side. The newer stern trawlers pulled it up a ramp at the back. Safer. Not much."])],
        w=13, h=9, extra=[{"type": "telescope", "x": 10, "y": 2}, {"type": "lobster_pots", "x": 1, "y": 2}])
    DLG["hull_corsair"]["hul_skipper"] = [
        IF("q_humber_trawler_done",
           say("Skipper", "Hope that little bore's treating you right. They follow the tide, not the boat, but that one took a shine to you."),
           [IF("q_humber_trawler_started",
               [IF("q_humber_trawler_1", [IF("q_humber_trawler_2",
                   say("Skipper", "Gansey on, patty in your pocket. Right. Let go fore and aft! We're off down the Humber.")
                   + [{"do": "fade_out"}, {"do": "say", "who": "", "text": "The trawler slides out past The Deep and down the brown Humber. "
                       "The land falls away flat on both sides. Out past Spurn Point the sea turns grey, and the swell lifts the bow."},
                      {"do": "fade_in"},
                      {"do": "say", "who": "First Mate Tommy", "text": "Skipper says every new deckie gets tested. Sea legs first, then manners!"},
                      {"do": "battle", "trainer": "hul_mate", "intro": False}, SET("q_humber_trawler_3"),
                      {"do": "fade_out"},
                      {"do": "say", "who": "", "text": "By dusk you're back alongside in the River Hull, salt in your hair. Something small and brown has followed the boat all the way up the estuary."},
                      {"do": "fade_in"},
                      {"do": "say", "who": "Skipper", "text": "Well I never. A Borelet, riding the tide in behind us. They don't do that for just anybody."},
                      {"do": "give_creature", "species": "borelet", "level": 32},
                      {"do": "say", "who": "Skipper", "text": "And keep the gansey. Every port knitted its own pattern, so if the sea gave a man back, they'd know where he was from."},
                      GIVE("hull_gansey"), STAND(3), SET("q_humber_trawler_done")],
                   say("Skipper", "Gansey's grand. Now, no deckie sails hungry: fetch a patty from the chippy on Hessle Road."))],
                   say("Skipper", "You'll need a gansey. Knitted, oily wool, keeps the spray out. Ask on Hessle Road."))],
               say("Skipper", "Welcome aboard the Arctic Corsair. Built 1960 at Beverley, just up the river, and she fished the Arctic for "
                   "twenty-five years.", "I sailed in her sister ships. Fancy a turn on the water? Proper trawlerman style?")
               + [{"do": "choice", "text": "Sign on as a deckie for a day?", "options": ["Aye, Skipper", "Maybe later"], "set": "_hul_trawl"},
                  IF("_hul_trawl", [SET("q_humber_trawler_started"),
                                    {"do": "say", "who": "Skipper", "text": "Good lad, good lass. First: a gansey from Hessle Road. Then a patty for the voyage. Then come back to me."}],
                     say("Skipper", "Tide waits for nobody. I do, though. Come back."), eq=0)])])]
    trainer_def("hul_mate", "First Mate Tommy", "First Mate", "sailor",
            [("aegir", 86), ("pierlord", 85), ("plungebeak", 85), ("greyhaul", 85)],
            ["Sea legs first, then manners!"], "Aye, you'll do. You'll do.", "Skipper's never wrong. Except about the weather. And football.", 3800)
    room(OUT, z, "hull_hessle", "Hessle Road", (4, 32), "home", [
        ("hul_nan", "villager_1", 3, 2, "down", None, None),
        ("hul_knitter", "villager_5", 9, 5, "left", None, None)], w=13, h=9)
    DLG["hull_hessle"]["hul_nan"] = [
        IF("q_humber_petition_started",
           [IF("q_humber_petition_1", say("Hessle Road Nan", "I've signed, duck. Go on, get it to the Wolds."),
               say("Hessle Road Nan", "A petition against slavery? Course I'll sign. My husband went to sea at fourteen and worked like a slave "
                   "half his life, and he'd tell you himself he was a free man. That's the difference that matters.",
                   "There. Mrs E. Fenwick, Hessle Road. Spelt right.") + [SET("q_humber_petition_1"),
                   {"do": "say", "who": "", "text": "One name on the petition. Next: the churchwarden at Rudston, out on the Wolds."}])],
           say("Hessle Road Nan", "Come in, duck, mind the step. Every house on this road had someone at sea.",
               "When the trawlers came in, the whole road came out. When one didn't come in, the whole road knew by teatime."))]
    DLG["hull_hessle"]["hul_knitter"] = [
        IF("q_humber_trawler_started",
           [IF("q_humber_trawler_1", say("Knitter", "Wear it with the pattern facing out. It's a Hull pattern. Proud of it."),
               say("Knitter", "A gansey for a new deckie? I've one on the needles now. Oiled wool, close knit, so the spray runs off.",
                   "Off you go. Mind you come back in it.") + [SET("q_humber_trawler_1"),
                   {"do": "say", "who": "", "text": "You pull on the gansey. It smells faintly of sheep and the sea."}])],
           say("Knitter", "Ganseys, they're called. Fishermen's jumpers. Every family had its own stitch, and every port its own pattern."))]
    room(OUT, z, "hull_chippy", "Patty and Chips", (12, 32), "cafe", [
        ("hul_frier", "shopkeeper", 3, 3, "down", None, None)], w=11, h=9)
    DLG["hull_chippy"]["hul_frier"] = [
        IF("q_humber_trawler_1", [IF("q_humber_trawler_2", say("Chip Shop Owner", "Enjoy your voyage. Don't feed the patty to the gulls, they'll follow you to Iceland."),
                                     say("Chip Shop Owner", "For the Corsair? On the house, duck. One patty, wrapped, still hot.") + [SET("q_humber_trawler_2"), GIVE("hull_patty")])], []),
        {"do": "say", "who": "Chip Shop Owner", "text": "Patty, chips and a scraps on top. That's Hull. Mashed spud and sage, battered, fried golden. Want a few for the road?"},
        {"do": "shop", "id": "hull_chippy"}]
    z.save(OUT + "/" + zid + ".json")


# --- Lincoln --------------------------------------------------------------------

def lincoln(OUT):
    W, H = 72, 60
    zid = "lincoln"
    z = Z(zid, "Lincoln", W, H, kind="town", region=MID, music="town_cheshire",
          weather={"clear": 28, "drizzle": 24, "sunshine": 18, "fog": 14, "gale": 10, "downpour": 6})
    z.d["stage"] = "castle"
    z.d["town_id"] = "lincoln"
    z.d["scaled_floor"] = LINCOLN_FLOOR
    z.rect(0, 0, W, H, ".")
    # uphill and downhill: the city climbs to the cathedral and the castle
    for y in range(H):
        v = 3 if y <= 17 else 2 if y <= 22 else 1 if y <= 28 else 0
        for x in range(W):
            z.hg[y][x] = v
    z.border("T", 2, gaps=[(0, 36, 2, 3)])
    # the main road in from Nottingham (along the Fossdyke) and the High Street
    z.rect(0, 36, 66, 3, "=")
    z.rect(30, 36, 3, 22, "=")
    # Steep Hill: cobbles all the way up
    z.rect(30, 12, 3, 24, ":")
    # Castle Square and Bailgate
    z.rect(2, 12, 66, 3, ":")
    z.rect(20, 3, 3, 9, ":")
    # the castle (west) and the cathedral (east)
    bld(z, 5, 3, 14, 8, "castle", "Lincoln Castle", "castle", door=7)
    z.rect(12, 11, 1, 1, ":")
    bld(z, 38, 3, 18, 7, "lincoln_cathedral", "Lincoln Cathedral", "church", door=9)
    z.rect(47, 10, 1, 2, ":")
    plaque(z, 45, 11, "lincoln_cathedral_spire", "The Tallest Building in the World",
           "LINCOLN CATHEDRAL. When its central spire was finished, around 1311, this was the tallest building in the world, "
           "taller than the Great Pyramid, and it stayed so for over two hundred years until the spire blew down in a storm in "
           "1548. Nobody built it back. The towers are still enormous, as your neck will tell you.")
    plaque(z, 52, 11, "lincoln_imp", "The Lincoln Imp",
           "THE LINCOLN IMP. Inside, high in the Angel Choir, sits a little stone imp with one leg crossed. The story goes the "
           "Devil sent two imps to make mischief; one smashed up the choir until an angel turned it to stone. The other is "
           "said to wait outside for it, which is why the wind always blows round the cathedral.")
    plaque(z, 13, 15, "lincoln_castle", "Lincoln Castle",
           "LINCOLN CASTLE. Built by William the Conqueror from 1068 on top of the Roman city. It has two mottes, the mounds "
           "under its towers, which only one other English castle can match. It was a prison into the 1870s, and you can "
           "still walk the full circuit of its walls.")
    plaque(z, 23, 15, "lincoln_magna_carta", "Magna Carta",
           "MAGNA CARTA. Four original copies of the charter King John sealed at Runnymede in June 1215 survive, and one of "
           "them is here in the castle, as it has been in Lincoln almost from the start. The Pope annulled it within ten "
           "weeks, but it was reissued, and three of its clauses are still law in England and Wales.")
    plaque(z, 36, 15, "lincoln_lincoln_green", "Lincoln Green",
           "LINCOLN GREEN. In the Middle Ages Lincoln was rich on wool and cloth, and its dyers were famous for a green made "
           "by dyeing woad blue over weld yellow. Robin Hood's men wore Lincoln green in the old ballads, which Nottingham "
           "is welcome to.")
    plaque(z, 26, 6, "lincoln_newport_arch", "Newport Arch",
           "NEWPORT ARCH. Up Bailgate stands the north gate of Roman Lincoln, Lindum Colonia, built in the 3rd century. It is "
           "the only Roman arch in Britain that traffic still drives through, though in 1964 a lorry got stuck in it and "
           "everybody held their breath.")
    plaque(z, 60, 11, "lincoln_peregrines", "Cathedral Peregrines",
           "PEREGRINES. A pair of peregrine falcons nest high on the cathedral, the fastest animal on Earth in a dive. Look "
           "for pigeon feathers drifting down on Minster Yard, and a lot of nervous pigeons.")
    # pubs and houses uphill
    z.rect(2, 15, 12, 1, ":")
    bld(z, 3, 12, 6, 3, "limestone_house", "The Strugglers Inn", door=3)
    # Steep Hill houses, three each side, each with its own step of pavement
    for (x, y, label, door, inside) in [(24, 18, "The Jew's House", 3, "lincoln_jewshouse"), (24, 22, "Steep Hill Tea Room", 3, "lincoln_tearoom"),
                                        (24, 26, "Steep Hill Books", None, None), (34, 18, "Sausage Makers", 2, "lincoln_butcher"),
                                        (34, 22, "Imp Jewellers", None, None), (34, 26, "Steep Hill Galleries", None, None)]:
        bld(z, x, y, 6, 3, "limestone_house", label, door=door)
        z.rect(x, y + 3, 6, 1, ":")
    plaque(z, 25, 20, "lincoln_jews_house", "The Jew's House", (
        "BLUE PLAQUE: The Jew's House, built around 1160, is one of the oldest houses in England still lived in. Lincoln had a "
        "large medieval Jewish community; Aaron of Lincoln was the richest man in England in his day. In 1290 Edward I "
        "expelled every Jew from the kingdom."), kind="plaque", dx=0.0)
    plaque(z, 33, 30, "lincoln_steep_hill", "Steep Hill",
           "STEEP HILL. It is. The cobbled street joining downhill to uphill climbs so sharply there are handrails, and in 2012 "
           "it was named Britain's best street. Cyclists in the Lincoln Grand Prix race up the cobbles nearby on Michaelgate, "
           "and some of them walk.")
    # downhill: the Sanctuary, the shop, the museum and the tank
    z.rect(34, 44, 17, 1, ":")
    bld(z, 35, 40, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(38, 43, "lincoln_sanctuary", 5, 6, "up")
    bld(z, 43, 40, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(45, 43, "lincoln_shop", 4, 5, "up")
    bld(z, 4, 29, 9, 4, "stone", "Museum of Lincolnshire Life", "museum", door=4)
    z.rect(8, 33, 1, 3, ":")
    bld(z, 57, 32, 3, 2, "tank_memorial", "Tank Memorial", show_label=False)
    z.rect(55, 34, 7, 2, ":")
    plaque(z, 58, 35, "lincoln_tanks", "The First Tanks",
           "THE FIRST TANKS. William Foster and Co. of Lincoln built Little Willie, the first tank, in 1915, then 'Mother', "
           "the shape of all the tanks that fought in the First World War. Workers were told they were making water carriers, "
           "so they were called tanks. The memorial is a Mark IV, built here too.")
    # Brayford Pool and the Fossdyke
    z.rect(4, 42, 19, 9, "~")
    z.rect(3, 41, 21, 1, "w"); z.rect(3, 51, 21, 1, "w"); z.rect(3, 42, 1, 9, "w"); z.rect(23, 42, 1, 9, "w")
    z.rect(0, 45, 3, 2, "~")
    z.rect(24, 41, 6, 1, ":")
    for (x, y) in [(8, 44), (14, 47), (19, 45)]:
        z.prop("canal_boat", x, y, variant=x % 3)
    z.prop("boat", 11, 49, variant=1)
    plaque(z, 25, 40, "lincoln_brayford", "Brayford Pool",
           "BRAYFORD POOL. A natural lake on the River Witham, and the reason Lincoln is here at all. The Romans dug the "
           "Fossdyke from here to the Trent, about AD 120, and it is the oldest canal in England still in use. Swans run "
           "the place now.")
    # Lincoln Central and the High Street level crossing
    station(z, 36, 48, 8, 4, "Lincoln Central")
    z.rect(0, 51, W, 1, "!")
    z.rect(30, 51, 3, 1, "&")
    z.rect(35, 49, 1, 2, ":"); z.rect(44, 49, 1, 2, ":")
    rail_guard(z, 45, 50, ["Lincoln Central. The trains cross the High Street right in the middle of town, so half of Lincoln "
                           "spends its life waiting at the barriers.", "All aboard! Trains run to any station you've been to."],
               facing="left")
    # over the line: the International Bomber Command Centre
    z.rect(30, 52, 3, 4, "=")
    z.rect(33, 55, 34, 1, ":")
    bld(z, 52, 52, 9, 3, "glass_tower", "International Bomber Command Centre", "museum", door=4)
    bld(z, 63, 52, 1, 1, "spire_memorial", "The Spire", show_label=False)
    plaque(z, 63, 54, "lincoln_bomber_county", "Bomber County", (
        "BOMBER COUNTY. Lincolnshire, flat and close to the North Sea, held dozens of RAF bomber airfields in the Second World "
        "War. The Dambusters flew from Scampton, just north of here, in May 1943. Crews coming home looked for the cathedral "
        "on its hill. This spire is as tall as a Lancaster's wings are wide, and the walls round it list more than 57,000 names."))
    # trees and the Arboretum
    blob(z, 62, 22, 6, 5, ",", only=".", seed=41, jitter=0.3)
    scatter_props(z, "oak", 56, 17, 13, 12, 9, 42, avoid=(".",))
    scatter_props(z, "birch", 3, 17, 18, 8, 4, 43, avoid=(".",))
    plaque(z, 56, 28, "lincoln_arboretum", "Lincoln Arboretum",
           "THE ARBORETUM. A Victorian park opened in 1872 for the people of Lincoln, with a maze, a bandstand and a lion "
           "statue that has seen generations of children climb on it.")
    for (x, y) in [(29, 16), (33, 20), (29, 33), (34, 39), (27, 39), (48, 39), (14, 39), (38, 11), (56, 11), (24, 11)]:
        z.prop("lamp_post", x, y)
    for (x, y) in [(42, 11), (50, 15), (17, 15), (26, 41), (52, 44)]:
        z.prop("bench", x, y)
    for (x, y) in [(29, 35), (51, 39)]:
        z.prop("phone_box", x, y)
    z.prop("post_box", 33, 35)
    # the Imp, out on the loose (once you've followed his trail)
    _stand(z, 54, 13)
    z.npc(id="lincoln_imp_spot", sprite="creature:lincolnimp", x=54, y=13, facing="down", move="still", script="imp_spot",
          show_if="q_humber_imp_2", hide_if="caught_lincolnimp")
    script(zid, "imp_spot", say("", "Up on the wall of Minster Yard a little stone figure sits cross-legged, grinning, with sausage grease on its chin.")
           + [{"do": "legend", "species": "lincolnimp", "level": 88, "music": "legend", "flag": "caught_lincolnimp"},
              IF("caught_lincolnimp", [SET("q_humber_imp_3"), {"do": "say", "who": "", "text": "The Lincoln Imp is yours. Best tell the Verger before he calls the police."}],
                 say("", "The Imp cackles and skitters off along the wall. He'll be back, he always is."))])
    # NPCs
    chat(z, "lin_yellowbelly", "villager_2", 28, 14, "Lincolnshire Local",
         ["Ey up, me duck! Born and bred in Lincolnshire, which makes me a Yellowbelly. Nobody agrees why. Some say the yellow "
          "waistcoats of the old county regiment, some say the frogs in the fens.", "Either way, it's a compliment. Mostly."], "down")
    chat(z, "lin_cyclist_fan", "jogger", 33, 32, "Puffing Walker",
         ["Steep Hill, they call it. Sounds like a description, not a name, doesn't it? That's because it's a warning.",
          "Halfway up there's a shop selling tea. That is not a coincidence."], "left", "wander")
    chat(z, "lin_swans", "canal_boater", 26, 42, "Boater",
         ["The Brayford's a proper harbour, right in the middle of the city. The Romans brought boats up the Fossdyke from the Trent, "
          "and I bring mine up it now. Same water, more swans.", "Mind the swans. They know they own the place."], "down")
    chat(z, "lin_spire_guide", "tour_guide", 57, 56, "Memorial Guide",
         ["Over 55,000 aircrew of Bomber Command were killed in the war, more than four in every ten who flew. Their average age was "
          "about twenty-two.", "Every name is on the walls. Families come and find theirs, and touch the letters."], "up")
    # trainers
    trainer(z, "lin_ringer", "Bell-Ringer Maud", "Bell-Ringer", "choir_singer",
            [("hushwing", 88), ("megalorn", 88), ("bansheen", 88)], 40, 13, "down",
            ["Great Tom of Lincoln is the big bell up there, five tonnes of it. I ring the little ones. Loudly. Want to hear?"],
            "Rung out! Very well struck, as we say.", "Great Tom strikes the hours. On a still night you'll hear him across half the county.", 3700)
    trainer(z, "lin_imps", "Imps Fan Wayne", "Football Fan", "rugby_player",
            [("rookery", 88), ("raidtail", 88), ("lanternis", 88)], 18, 37, "up",
            ["Lincoln City! The Imps! Red and white and a little devil on the badge. Come on then!"],
            "We'll have you next season.", "Sincil Bank's the ground. We sing 'We are Imps' till our voices go. Then we sing it quieter.", 3700)
    trainer(z, "lin_cyclist", "Cyclist Bryony", "Cyclist", "jogger",
            [("stormswift", 88), ("gealhare", 88), ("stoopfalcon", 88)], 33, 24, "left",
            ["Training for the Grand Prix: up Michaelgate cobbles twenty times before breakfast. I've got legs like pistons. Battle?"],
            "Blown. Done. Going to sit in the tea room.", "The trick on cobbles is staying in the saddle and not looking up. Never look up.", 3700)
    trainer(z, "lin_raf", "Historian Frank", "RAF Historian", "astronomer",
            [("stoopfalcon", 88), ("steelheart", 88), ("hushwing", 89)], 47, 56, "up",
            ["My grandad was a navigator in a Lancaster out of Waddington. He never talked about it. So I do. Battle?"],
            "Well flown. He'd have liked you.", "Lancasters had a crew of seven. The rear gunner sat alone in a glass turret at the back, "
            "for eight hours, freezing.", 3700)
    trainer(z, "lin_sausage", "Sausage Maker Dot", "Butcher", "villager_6",
            [("thornsow", 88), ("grandpuff", 88), ("samsonian", 88)], 40, 45, "up",
            ["Lincolnshire sausage: coarse pork and a fistful of sage. No rusk-heavy nonsense. Fight me, as the young ones say."],
            "Fair enough. I'll put you on the list for the Christmas order.", "Sage, that's the secret. Some add thyme. Some add rumours.", 3700)
    trainer(z, "lin_nicola", "Re-enactor Nicola", "Castle Champion", "keeper_maud",
            [("centurion", 89), ("landship", 89), ("causewarden", 89), ("megalorn", 89), ("stagmajor", 89), ("pyredrey", 90)],
            14, 13, "down",
            ["I play Nicola de la Haye, who held Lincoln Castle twice against sieges, and was made Sheriff of Lincolnshire in 1216, "
             "in her sixties. A woman sheriff, eight hundred years ago.", "She didn't give up the castle. I won't give up this battle."],
            "Yielded! The castle's yours, for today. Nicola would have made you swear an oath first.",
            "In 1217 the Second Battle of Lincoln was fought right here in the streets, and Nicola's castle held. The French "
            "prince's army was routed, and Magna Carta was reissued that year.", 10200)
    TRN["lin_nicola"]["party"][1]["held"] = "oak_acorn"
    TRN["lin_nicola"]["party"][5]["held"] = "horseshoe"
    TRN["lin_nicola"]["party"][0]["tea"] = "flask_of_tea"
    wild(z, [("rooklet", 88, 88, 14, {}), ("cooplet", 88, 88, 14, {}), ("peregrin", 88, 88, 8, {"time": ["day"]}),
             ("binfox", 88, 88, 10, {"time": ["night", "dusk"]}), ("starlet", 88, 88, 10, {}), ("legionette", 88, 88, 8, {"time": ["night", "dusk"]}),
             ("glowmite", 88, 88, 8, {"time": ["night"]}), ("hootlet", 88, 88, 6, {"time": ["night"]}), ("spikkin", 88, 88, 8, {}),
             ("pipkin", 88, 88, 8, {})])
    wild(z, [("stalklet", 88, 88, 20, {}), ("dipling", 88, 88, 18, {}), ("holtling", 88, 88, 14, {}), ("pollanet", 88, 88, 14, {}),
             ("cranelet", 88, 88, 10, {}), ("minkshade", 88, 88, 8, {"time": ["night", "dusk"]})], "water")
    z.d["edges"] = {"west": {"to": "nottingham", "offset": -4}}
    z.d["spawn"] = [3, 37]
    done(z)
    z.save(OUT + "/" + zid + ".json")
    sanctuary(OUT, zid, "Lincoln", (38, 44), music="sanctuary")
    shop(OUT, zid, "Lincoln", (45, 44))
    nurse(zid, ["Ey up, me duck! Welcome to Lincoln Sanctuary. Up or down the hill today?",
                "Sit yourself down. There's plum bread and a bit of Poacher on the side.",
                "All better. Mind Steep Hill on the way back up, it's a killer.",
                "The Ark's in the corner, me duck. Click away.",
                "Ta-ra, me duck."])
    shopkeeper(zid, "Ey up, me duck! Sausages, plum bread, and a little Imp pin for luck. What'll it be?",
               "Ta-ra! Mind the hill.")
    # interiors
    room(OUT, z, "lincoln_cathedral", "Lincoln Cathedral", (47, 9), "church", [
        ("lin_verger", "choir_singer", 6, 2, "down", None, None),
        ("lin_glass", "poet", 2, 2, "down", "Stained-Glass Guide",
         ["Look up at the two round windows: the Dean's Eye to the north and the Bishop's Eye to the south. The Dean watched for "
          "the Devil, the Bishop for the Holy Spirit. A sensible division of labour.",
          "The nave roof is so high a rainstorm once fell inside it as mist. Or so the vergers tell visitors."])],
        w=15, h=10)
    DLG["lincoln_cathedral"]["lin_verger"] = [
        IF("q_humber_imp_done",
           say("Verger", "The Angel Choir's very quiet without him. Too quiet. I almost miss the faces. Look after him."),
           [IF("q_humber_imp_started",
               [IF("q_humber_imp_3",
                   say("Verger", "You caught him! The little horror. Look at that grin, not a shred of remorse.",
                       "Do you know, I think he'd be happier travelling. He's sat on that pillar since the 1200s. Take him, with the Chapter's blessing.",
                       "And take one of these. Lincoln jewellers have sold Imp pins for luck since Victorian times.")
                   + [GIVE("lincoln_imp_pin"), GIVE("plum_bread", 2), STAND(4), SET("q_humber_imp_done")],
                   [IF("q_humber_imp_2", say("Verger", "Minster Yard? On the wall? Go on then, before he makes off with the collection plate."),
                       [IF("q_humber_imp_1", say("Verger", "A stolen sausage, you say? Then ask the sausage makers on Steep Hill. Follow the grease."),
                           say("Verger", "Start at the Strugglers Inn by the castle. If there's mischief in Lincoln, the Strugglers hears about it first."))])])],
               say("Verger", "Oh, thank goodness, a sensible face. The Imp's gone! His pillar in the Angel Choir is empty.",
                   "Legend says an angel turned him to stone for smashing up the choir. Seems the stone has worn off.")
               + [SET("q_humber_imp_started"),
                  {"do": "say", "who": "Verger", "text": "Could you find him? Try the Strugglers Inn by the castle. If there's mischief in Lincoln, the Strugglers hears about it first."}])])]
    room(OUT, z, "lincoln_castle", "Magna Carta Vault", (12, 10), "museum", [
        ("lin_guide", "tour_guide", 7, 2, "down", None, None),
        ("lin_c39", "student", 2, 2, "down", None, None),
        ("lin_c40", "villager_4", 12, 2, "down", None, None),
        ("lin_c33", "villager_3", 2, 6, "right", None, None),
        ("lin_c35", "poet", 12, 6, "left", None, None)], w=15, h=10,
        extra=[{"type": "display_case", "x": 6, "y": 4}, {"type": "display_case", "x": 8, "y": 4}])
    clauses = {
        "lin_c39": ("q_humber_magna_1", "Clause 39", ["Clause 39: 'No free man shall be seized or imprisoned, or stripped of his rights or "
                    "possessions... except by the lawful judgement of his equals or by the law of the land.'",
                    "That's the root of trial by jury and of habeas corpus. Even the king can't just lock you up."]),
        "lin_c40": ("q_humber_magna_2", "Clause 40", ["Clause 40: 'To no one will we sell, to no one deny or delay right or justice.'",
                    "No buying a verdict, no waiting forever for a trial. It's carved on courthouses around the world."]),
        "lin_c33": ("q_humber_magna_3", "Clause 33", ["Clause 33: 'All fish-weirs shall be removed from the Thames, the Medway and "
                    "throughout all England, except on the sea coast.'", "Weirs blocked the boats. Not every clause was grand. Some were about fish."]),
        "lin_c35": ("q_humber_magna_4", "Clause 35", ["Clause 35: 'Let there be one measure of wine throughout our kingdom, and one "
                    "measure of ale, and one measure of corn, namely the London quarter.'", "One set of measures for everyone, so nobody "
                    "could be cheated with a small pint. Pubs, take note."]),
    }
    for nid, (flag, who, lines) in clauses.items():
        DLG["lincoln_castle"][nid] = say(who + " Volunteer", *lines) + [IF("q_humber_magna_started", [SET(flag)])]
    quiz_win = say("Castle Guide", "Three out of three. You've read it properly, which is more than King John did.",
                   "Here: a facsimile seal, and a bit of Lincolnshire to go with it.") + [
        GIVE("lincolnshire_sausage", 3), GIVE("plum_bread", 2), STAND(4), SET("q_humber_magna_done")]
    quiz_fail = say("Castle Guide", "Not quite. Have another look at the clauses and come back. The charter's waited 800 years, it'll wait for you.")
    quiz = [{"do": "choice", "text": "Clause 39: nobody may be imprisoned except by...?",
             "options": ["The king's say-so", "Lawful judgement of their equals", "A vote of the barons"], "set": "_lin_q1"},
            IF("_lin_q1", [{"do": "choice", "text": "Clause 40: to no one will we sell, deny or delay...?",
                            "options": ["Right or justice", "Ale or bread", "Land or titles"], "set": "_lin_q2"},
                           IF("_lin_q2", [{"do": "choice", "text": "Clause 35: the one measure of corn for the whole kingdom was...?",
                                           "options": ["The Lincoln bushel", "The York peck", "The London quarter"], "set": "_lin_q3"},
                                          IF("_lin_q3", quiz_win, quiz_fail, eq=2)], quiz_fail, eq=0)], quiz_fail, eq=1)]
    DLG["lincoln_castle"]["lin_guide"] = [
        IF("q_humber_magna_done", say("Castle Guide", "You know Magna Carta better than most lawyers now. Don't tell them."),
           [IF("q_humber_magna_started",
               [IF("q_humber_magna_4", [IF("q_humber_magna_3", [IF("q_humber_magna_2", [IF("q_humber_magna_1",
                   say("Castle Guide", "Read all four? Then let's see what stuck.") + quiz,
                   say("Castle Guide", "Have you heard about Clause 39 yet? Our volunteer by the far wall knows it by heart."))],
                   say("Castle Guide", "Clause 40 is the one on the other side. Short, but it bites."))],
                   say("Castle Guide", "Don't skip Clause 33. It's about fish weirs. Trust me."))],
                   say("Castle Guide", "Four volunteers, four clauses. Hear them all, then come to me."))],
               say("Castle Guide", "Welcome to the vault. This is Lincoln's Magna Carta, one of four originals from 1215, written in Latin on "
                   "sheepskin by a royal clerk in a hurry.", "It has 63 clauses. Most are about medieval taxes and forests, but a few "
                   "changed the world.")
               + [{"do": "choice", "text": "Read four of its clauses with the volunteers?", "options": ["Go on then", "Not today"], "set": "_lin_mag"},
                  IF("_lin_mag", [SET("q_humber_magna_started"),
                                  {"do": "say", "who": "Castle Guide", "text": "Lovely. Our volunteers each know one clause: 39, 40, 33 and 35. Then come back to me for a little test."}],
                     say("Castle Guide", "Fair enough. It's not going anywhere. It's behind very thick glass."), eq=0)])])]
    room(OUT, z, "lincoln_strugglers", "The Strugglers Inn", (6, 14), "cafe", [
        ("lin_landlord", "shopkeeper", 3, 3, "down", None, None),
        ("lin_hangman", "villager_1", 9, 3, "left", "Old Regular",
         ["The Strugglers is named for the poor souls hanged at the castle. The gallows was on the walls, and the crowds drank here "
          "after. Grim, but it's a lovely pint.", "There's a little carving of a struggling man on the sign. Don't look too long."])],
        w=13, h=9)
    DLG["lincoln_strugglers"]["lin_landlord"] = [
        IF("q_humber_imp_started", [IF("q_humber_imp_1", [], say("Landlord", "Funny you should ask. Something small and stony nicked a "
                                                                 "Lincolnshire sausage off a plate at lunch. Ran off down Steep Hill, cackling.") + [SET("q_humber_imp_1")])], []),
        {"do": "say", "who": "Landlord", "text": "Ey up, me duck. Quiz tonight, and every night. Fancy it?"},
        {"do": "quiz", "pub": "lincoln_strugglers", "region": "england_north", "who": "Landlord"}]
    room(OUT, z, "lincoln_butcher", "Sausage Makers", (36, 20), "cafe", [
        ("lin_butcher", "shopkeeper", 3, 3, "down", None, None)], w=11, h=9)
    DLG["lincoln_butcher"]["lin_butcher"] = [
        IF("q_humber_imp_1", [IF("q_humber_imp_2", [], say("Sausage Maker", "A little stone lad? Ha! He was in here, licking the window. "
                                                          "Then he legged it up to Minster Yard and sat on the wall pulling faces at the tourists.") + [SET("q_humber_imp_2")])], []),
        {"do": "say", "who": "Sausage Maker", "text": "Lincolnshire sausages: coarse-chopped pork, plenty of sage, nothing daft. Want some?"},
        {"do": "shop", "id": "lincoln_butcher"}]
    room(OUT, z, "lincoln_tearoom", "Steep Hill Tea Room", (27, 24), "cafe", [
        ("lin_baker", "shopkeeper", 3, 3, "down", None, None),
        ("lin_poacher", "villager_5", 9, 4, "left", "Tea Room Regular",
         ["Plum bread with a slice of Lincolnshire Poacher cheese. Sweet and sharp. That's the county on a plate.",
          "There's no plums in plum bread. 'Plum' used to mean any dried fruit. Same with plum pudding. Victorians, eh."])],
        w=13, h=9)
    DLG["lincoln_tearoom"]["lin_baker"] = say("Baker", "Sit down, get your breath back. Everybody arrives in here panting. It's the hill.") + [
        {"do": "shop", "id": "lincoln_tearoom"}]
    room(OUT, z, "lincoln_jewshouse", "The Jew's House", (27, 20), "home", [
        ("lin_historian", "poet", 6, 2, "down", "Local Historian",
         ["This house was built of stone around 1160, when nearly every house was timber. Stone meant money, and safety.",
          "Lincoln's Jewish community lived along this hill: moneylenders, doctors, scholars. Aaron of Lincoln lent money to kings "
          "and abbeys; when he died the Crown seized his fortune.",
          "In 1290 Edward I expelled every Jew from England. They weren't allowed back for over 360 years. The house remembers "
          "them, and so should we."])], w=13, h=9)
    room(OUT, z, "lincoln_lincslife", "Museum of Lincolnshire Life", (8, 32), "museum", [
        ("lin_curator", "steelworker", 6, 2, "down", None, None),
        ("lin_land_girl", "farmer", 2, 4, "right", "Volunteer",
         ["Lincolnshire grew the potatoes and the sugar beet, and sent the sausages. Half the country's food came off these flat fields.",
          "There's a whole street of old shops in here: a chemist, a saddler, a wheelwright. Smells of polish and string."])],
        w=13, h=10, extra=[{"type": "display_case", "x": 2, "y": 1}, {"type": "display_case", "x": 10, "y": 1}])
    DLG["lincoln_lincslife"]["lin_curator"] = [
        {"do": "say", "who": "Curator", "text": "That big iron box in the hall is a First World War tank, built in Lincoln. Fosters made "
                                                 "agricultural machinery: traction engines, threshers. Then they made the first tanks."},
        IF("humber_treadlet_given", say("Curator", "How's your Treadlet? Still flattening hedges?"),
           say("Curator", "And look what's turned up rattling round the yard. A Treadlet! Little Willie's spirit, I reckon. It wants to see the world. Take it.")
           + [{"do": "give_creature", "species": "treadlet", "level": 33}, SET("humber_treadlet_given")])]
    room(OUT, z, "lincoln_ibcc", "International Bomber Command Centre", (56, 54), "museum", [
        ("lin_ibcc", "tour_guide", 6, 2, "down", "Guide",
         ["The Centre tells the story of Bomber Command: the crews, the ground staff, the women who packed the parachutes, and the "
          "people under the bombs too.", "It's not a place for glory. It's a place for remembering, and for asking hard questions "
          "about war. Both matter."]),
        ("lin_wireless", "astronomer", 10, 4, "left", "Volunteer",
         ["My aunt was a WAAF at Scampton, plotting the raids on a big table map. She knew which crews hadn't come back before "
          "anyone told her.", "She kept a little Lincoln Imp brooch the whole war. For luck, she said."])],
        w=13, h=9)
    z.save(OUT + "/" + zid + ".json")


def shops_and_items():
    root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    import json
    base = ["cup_of_tea", "flask_of_tea", "bakewell_tart", "buxton_water", "smelling_salts", "kendal_mint_cake", "wicker_snare",
            "iron_snare", "night_snare", "water_snare", "silver_snare", "yorkshire_pudding", "parkin", "pork_pie", "lavender_sachet"]
    shops = {
        "hull_corner_shop": ("Hull Corner Shop", base + ["hull_patty", "cream_tea", "whitby_jet"]),
        "lincoln_corner_shop": ("Lincoln Corner Shop", base + ["lincolnshire_sausage", "plum_bread", "lincoln_imp_pin"]),
        "hull_chippy": ("Patty and Chips", ["hull_patty", "cup_of_tea"]),
        "lincoln_butcher": ("Sausage Makers", ["lincolnshire_sausage", "pork_pie"]),
        "lincoln_tearoom": ("Steep Hill Tea Room", ["plum_bread", "cup_of_tea", "flask_of_tea", "bakewell_tart"]),
    }
    for sid, (name, stock) in shops.items():
        json.dump({"id": sid, "name": name, "stock": stock}, open(os.path.join(root, "data", "shops", sid + ".json"), "w"))


def build(OUT):
    wolds(OUT)
    hull(OUT)
    lincoln(OUT)
    scaled_trainers("wld_", WOLDS_FLOOR)
    scaled_trainers("hul_", HULL_FLOOR)
    scaled_trainers("lin_", LINCOLN_FLOOR)
    shops_and_items()


if __name__ == "__main__":
    OUT = sys.argv[2] if len(sys.argv) > 2 else "data/zones"
    build(OUT)
    write_all(OUT)
    print("humber: wrote", len(DLG), "dialogue files and", len(TRN), "trainers")
