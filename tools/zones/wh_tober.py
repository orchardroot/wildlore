"""Tobermory (a small harbour town on Mull, reached by the Oban ferry), Staffa's Fingal's Cave and Iona Abbey."""
from wh_lib import *
from wh_oban import sanctuary, shop_room, chain

Z = "tobermory"


def build():
    o = Out(Z, "Tobermory", "town", 64, 46, "town_scotland", "coast",
            {"drizzle": 32, "clear": 16, "downpour": 14, "fog": 8, "gale": 10, "sunshine": 20}, town=True)
    o.border()
    o.rect(0, 30, 64, 16, "$")
    o.rect(2, 29, 60, 1, "w")
    o.rect(4, 24, 56, 3, ":")             # Main Street, along the harbour front
    o.rect(29, 27, 3, 9, ":")             # the pier
    o.rect(45, 13, 2, 11, "#")            # the lane up to the distillery
    o.rect(42, 13, 5, 1, "#")
    o.ell(14, 10, 8, 5, ",", only=".")
    o.ell(54, 10, 4, 4, ",", only=".")
    o.ell(25, 14, 4, 2, ",", only=".")
    o.ell(10, 20, 3, 2, ",", only=".")
    for _ in range(90):
        x, y = o.rng.randrange(2, 62), o.rng.randrange(2, 18)
        if o.at(x, y) == ".":
            o.put(x, y, "P" if _ % 3 else "T")
    ds = {}
    o.building(4, 19, 6, 5, "painted_yellow", "Harbour Gift Shop", "cafe", -1)
    o.building(11, 19, 5, 5, "painted_pink", "Sweet Shop", "cafe", -1)
    ds["museum"] = o.building(17, 19, 7, 5, "painted_blue", "Mull Museum", "museum", 3, "tobermory_museum", 6, 7)
    ds["sanct"] = o.building(25, 19, 6, 5, "painted_teal", "Tobermory Sanctuary", None, 3, "tobermory_sanctuary", 5, 7)
    ds["mishnish"] = o.building(32, 19, 6, 5, "painted_green", "The Mishnish", None, 3, "tobermory_mishnish", 7, 7)
    ds["shop"] = o.building(39, 19, 6, 5, "painted_red", "Tobermory Corner Shop", None, 3, "tobermory_shop", 4, 6)
    ds["boats"] = o.building(47, 19, 7, 5, "painted_pink", "Staffa and Iona Boat Trips", None, 3, "tobermory_boats", 6, 6)
    o.building(55, 19, 5, 5, "painted_blue", "Fishing Supplies", "cafe", -1)
    ds["distillery"] = o.building(36, 8, 12, 5, "distillery", "Tobermory Distillery", "workshop", 6, "tobermory_distillery", 7, 8)
    o.building(6, 12, 5, 4, "slate_cottage", "Cottage", "cottage", -1)
    o.building(22, 10, 5, 4, "white_render", "Cottage", "cottage", -1)
    o.extra["ferry"] = {"x": 30, "y": 35, "route": "oban_tobermory"}
    o.spawn = [30, 25]
    # dressing
    for x in (8, 16, 24, 35, 42, 52, 58):
        o.prop("lamp_post", x, 27)
    o.prop("clock_tower", 36, 28)
    o.prop("bench", 10, 27)
    o.prop("bench", 48, 27)
    o.prop("bollard", 29, 33)
    o.prop("bollard", 31, 33)
    o.prop("bollard", 29, 28)
    o.prop("bollard", 31, 28)
    o.prop("lobster_pots", 28, 28, variant=0)
    o.prop("boat", 12, 34, variant=1)
    o.prop("boat", 21, 37, variant=1)
    o.prop("boat", 45, 34, variant=1)
    o.prop("boat", 52, 39, variant=1)
    o.prop("boat", 38, 41, variant=0)
    o.prop("buoy", 16, 32)
    o.prop("buoy", 48, 33)
    o.prop("hanging_basket", 28, 24)
    o.prop("hanging_basket", 33, 24)
    o.prop("planter", 20, 24)
    o.prop("planter", 41, 24)
    o.prop("post_box", 14, 24)
    o.prop("phone_box", 56, 24)
    o.sprinkle("bush", 20, only=".", variants=3, rows=(2, 18))
    o.sprinkle("rock", 14, only=".", variants=3, rows=(2, 18))
    S = o.sign
    S(30, 36, "PIER. The Oban ferry docks here. Staffa and Iona boat trips run from the harbour front, tide and weather permitting, and the weather is usually the deciding vote.")
    S(23, 28, "HARBOUR FRONT. Gift shops, galleries, a chippy and about nine hundred photographs being taken at once.")
    P = S
    P(12, 25, "TOBERMORY. Tobar Mhoire in Gaelic, 'Mary's Well', named after a well by an old chapel. The town was founded in 1788 by the British Fisheries Society as a herring port, which explains why it is so neatly laid out.",
      "tob_name", "Tobermory")
    P(26, 28, "THE HARBOUR FRONT. The row of brightly painted houses along the bay is one of the most photographed views in Scotland, and a children's television programme filmed here in the early 2000s made it famous with the under-fives.",
      "tob_harbour", "The Harbour Front")
    P(40, 28, "THE TOBERMORY GALLEON. A ship of the Spanish Armada is said to have sunk in the bay in 1588, laden with gold. Treasure hunters have dug, dived and dredged for four centuries and found a few cannon and a great deal of mud.",
      "tob_galleon", "The Tobermory Galleon")
    P(44, 14, "TOBERMORY DISTILLERY. Founded in 1798, it is among the oldest on the islands. It has changed its name, its owners and its fortunes several times, and has been shut and reopened more often than the pub.",
      "tob_distillery", "Tobermory Distillery")
    P(53, 27, "SEA EAGLES. The white-tailed eagle has a wingspan of about two and a half metres and was hunted to extinction in Britain by 1918. Birds from Norway were released on Rum from 1975, and Mull now has one of the best known populations. If something that looks like a barn door flies past, wave.",
      "tob_sea_eagles", "Sea Eagles")
    P(33, 25, "THE MISHNISH. A famous harbour front pub with folk sessions most nights. In spring it is one of the venues for the Mull Music Festival, which is the only time the town's population doubles and the quiet doesn't.",
      "tob_mishnish", "The Mishnish")
    P(44, 28, "STAFFA. A small uninhabited island of basalt columns, made about 60 million years ago when lava cooled and cracked into hexagons. The name is Norse, 'staff island', for the columns. It is the same lava as the Giant's Causeway, and the old story says the two are one causeway.",
      "tob_staffa", "Staffa")
    P(51, 25, "FINGAL'S CAVE. In 1829 the composer Felix Mendelssohn, aged twenty, sailed here, was seasick, and was still so taken with the echoing arches that he used them for the opening of his Hebrides Overture. The Gaelic name is Uamh-Binn, the cave of melody.",
      "tob_fingals_cave", "Fingal's Cave")
    P(58, 25, "IONA. In 563 St Columba, an Irish monk, landed here with twelve companions and founded a monastery that became a great centre of learning. The Book of Kells is thought to have been begun on Iona, before Viking raids drove the monks to Ireland.",
      "tob_iona", "Iona")
    P(20, 25, "MULL MUSEUM. A small, friendly museum on the harbour front, covering Mull from its rocks and wildlife to its crofters and the wreck of the galleon.",
      "tob_mull_museum", "Mull Museum")
    P(8, 25, "MULL LITTLE THEATRE. At Dervaig, a few miles from here, a professional theatre of about forty seats. It claims to be the smallest in Britain, which means every seat is the front row.",
      "tob_little_theatre", "Mull Little Theatre")
    P(37, 30, "ISLE OF MULL CHEDDAR. Made on a farm just outside Tobermory, strong, crumbly and prize-winning. You'll find it in the shop and on the ploughman's lunch at the pub.",
      "tob_cheddar", "Isle of Mull Cheddar")
    for sp, lo, hi, w, cond in [
        ("eaglet", 69, 70, 12, {"time": ["day"]}), ("goldeneyrie", 69, 70, 8, {"time": ["dawn", "day"]}),
        ("stagmor", 69, 70, 8, {"time": ["dawn", "dusk"]}), ("fawnlet", 69, 70, 10, {}), ("wildkit", 69, 70, 6, {"time": ["dusk", "night"]}),
        ("hootlet", 69, 70, 8, {"time": ["night"]}), ("midgie", 69, 70, 8, {"weather": ["drizzle", "downpour"]}),
        ("thistlet", 69, 70, 8, {}), ("cragchough", 69, 70, 6, {}), ("starlet", 69, 70, 6, {"time": ["dusk", "dawn"]}),
        ("lekling", 69, 70, 5, {"time": ["day", "dawn"]}),
    ]:
        o.enc("grass", sp, lo, hi, w, **cond)
    for sp, lo, hi, w, cond in [
        ("rillotter", 69, 70, 14, {}), ("selklet", 69, 70, 12, {}), ("clownbill", 69, 70, 10, {"time": ["dawn", "day"]}),
        ("gannetling", 69, 70, 10, {}), ("dolphlet", 69, 70, 10, {}), ("orcalet", 69, 70, 4, {}), ("plungebeak", 69, 70, 6, {}),
    ]:
        o.enc("water", sp, lo, hi, w, **cond)
    o.npc("tob_birder", "birdwatcher", 53, 28, "tob_birder", "up", name="Eagle Watcher")
    o.npc("tob_hunter", "sailor", 38, 28, "tob_hunter", "down", name="Galleon Hunter")
    o.npc("tob_painter", "poet", 22, 26, "tob_painter", "down", name="Artist")
    o.npc("tob_kid", "villager_4", 17, 25, "tob_kid", "down", "wander", radius=1, name="Child")
    o.npc("tob_otter", "creature:rillotter", 15, 29, "tob_otter", "down", "wander", radius=1)
    o.trainer_npc("tob_eagle", "birdwatcher", 56, 26, "tob_eagle", "left")
    o.trainer_npc("tob_diver", "sailor", 24, 25, "tob_diver", "right")
    o.trainer_npc("tob_walker", "hiker", 30, 15, "tob_walker", "down")
    for n in o.npcs:
        if o.at(n["x"], n["y"]) in "TPR^~BF$":
            o.put(n["x"], n["y"], ".")
    for p in o.props:
        if p["type"] != "building" and o.at(p["x"], p["y"]) in "TPBF$":
            o.put(p["x"], p["y"], ".")
    for s in o.signs:
        if o.at(s["x"], s["y"]) in "TP":
            o.put(s["x"], s["y"], ".")
    o.save()
    interiors(ds)
    trainers()
    return ds


def trainers():
    trainer("tob_eagle", "Eagle Watcher Morag", "Birdwatcher", "birdwatcher",
            [("goldeneyrie", 70), ("eaglet", 69), ("lochosprey", 70), ("polartern", 70)], 2500,
            ["Don't speak. Sea eagle, one o'clock. Gone. Right, I've lost it, and it's your fault. Eyes up, we'll settle this the old way."],
            "A good eye on you. I'll try again with the binoculars the right way round.",
            "A sea eagle is the size of a door with a hooked beak. They harass the otters, take fish off the surface, and ignore anyone who isn't a lamb.")
    trainer("tob_diver", "Galleon Hunter Rory", "Treasure Diver", "sailor",
            [("pierlord", 70), ("greyhaul", 70), ("clawcastle", 70), ("bayrunner", 70)], 2550,
            ["I'm after the Tobermory galleon. Armada ship, 1588, holds a fortune in gold. I have a metal detector, a boat and a dream. The dream is doing most of the work."],
            "I'll find it yet. I always find something. Last week it was a Tesco bag.",
            "The legend says she was blown up by an accident, a Spanish ship called the San Juan de Sicilia. Four hundred years of looking has found a lot of mud and a handful of cannon.")
    trainer("tob_walker", "Dram Taster Hilary", "Hillwalker", "hiker",
            [("stagmor", 70), ("highlynx", 70), ("heilan", 70)], 2400,
            ["I've walked up from the distillery. Four miles. I've regretted three of them. The view is wonderful, though. Dear me, are you challenging me? In this state?"],
            "Quite right. That was a better walk than mine.",
            "Always have the cheese, then the hill, then the pub. In that order, or you'll go up the hill in the wrong spirits.")


def interiors(ds):
    sanctuary("tobermory_sanctuary", "Tobermory Sanctuary", Z, ds["sanct"],
              "Failte to Tobermory Sanctuary. We have heating, and tea, and a very good view of the harbour. You've just come off the ferry? You'll want to sit down.",
              "All done. Mind the cobbles outside, they've seen off more than one ferry passenger.")
    shop_room("tobermory_shop", "Tobermory Corner Shop", Z, ds["shop"], "tobermory_corner_shop",
              "Welcome in. We've got Mull cheddar, oatcakes and every kind of waterproof under the sun. Or rather, over it.",
              "Thanks now. Don't let the midges follow you out.")
    interior("tobermory_distillery", "Tobermory Distillery", 15, 10, Z, ds["distillery"],
             props=[{"type": "table", "x": 3, "y": 3}, {"type": "table", "x": 11, "y": 3}, {"type": "steel_plates", "x": 2, "y": 1},
                    {"type": "steel_plates", "x": 12, "y": 1}, {"type": "display_case", "x": 7, "y": 2, "variant": 2},
                    {"type": "bench", "x": 3, "y": 6}, {"type": "bench", "x": 11, "y": 6}, {"type": "potted_plant", "x": 1, "y": 8},
                    {"type": "wall_picture", "x": 5, "y": 1, "walk": True, "variant": 3}, {"type": "wall_picture", "x": 9, "y": 1, "walk": True, "variant": 2},
                    {"type": "rug", "x": 7, "y": 4, "w": 1, "h": 4, "variant": 1, "walk": True}],
             npcs=[inpc("tob_tour", "tour_guide", 6, 3, "tob_tour", name="Distillery Guide"),
                   inpc("tob_mashman", "steelworker", 10, 6, "tob_mashman", "left", name="Mashman")], floor="+")
    script("tobermory_distillery", "tob_tour", [
        say("Distillery Guide", "Welcome to Tobermory Distillery. Founded 1798, one of the oldest on the islands, and the only one with a view of the harbour from the warehouse."),
        say("Distillery Guide", "It's made from barley, water and yeast. This time of year we're doing a peated run, a smoky one, and the smell gets into your jumper for a week."),
        say("Distillery Guide", "The tour starts at ten sharp. The door's locked at ten past. Nobody has ever been let in late. Some have begged."),
        if_("q_westhighlands_hop_started", [set_flag("q_westhighlands_hop_1")])])
    talk("tobermory_distillery", "tob_mashman", "Mashman",
         "I stir the mash. Hot water on malted barley, and the sugars come out. It smells like warm porridge. I eat a lot of porridge, for research.")
    interior("tobermory_museum", "Mull Museum", 13, 9, Z, ds["museum"],
             props=[{"type": "display_case", "x": 2, "y": 3, "variant": 1}, {"type": "display_case", "x": 4, "y": 3, "variant": 2},
                    {"type": "display_case", "x": 8, "y": 3, "variant": 3}, {"type": "specimen_shelf", "x": 10, "y": 1},
                    {"type": "wall_map", "x": 6, "y": 1, "walk": True}, {"type": "wall_picture", "x": 3, "y": 1, "walk": True, "variant": 2},
                    {"type": "bench", "x": 3, "y": 6}, {"type": "potted_plant", "x": 11, "y": 7}],
             npcs=[inpc("tob_curator", "student", 6, 4, "tob_curator", name="Curator")])
    talk("tobermory_museum", "tob_curator", "Curator",
         "Mull is made of old lava. Staffa, Ulva and a good chunk of the island were the same volcanic outpouring, about sixty million years ago. The hexagonal columns you see at Fingal's Cave are the same stuff.",
         "In the 1800s a great many people left Mull in the Clearances, when landlords turned crofters out to make room for sheep. You'll see the ruins of their houses on the hills. The island's population is about a tenth of what it was.")
    interior("tobermory_mishnish", "The Mishnish", 15, 9, Z, ds["mishnish"],
             props=[{"type": "table", "x": 3, "y": 4}, {"type": "table", "x": 11, "y": 4}, {"type": "bench", "x": 3, "y": 5}, {"type": "bench", "x": 11, "y": 5},
                    {"type": "fireplace", "x": 7, "y": 1}, {"type": "band_kit", "x": 12, "y": 2, "variant": 0}, {"type": "wall_picture", "x": 4, "y": 1, "walk": True, "variant": 2},
                    {"type": "potted_plant", "x": 1, "y": 7}, {"type": "rug", "x": 6, "y": 3, "w": 3, "h": 3, "variant": 2, "walk": True}],
             counters=[(3, 2, 3), (9, 2, 2)],
             npcs=[inpc("tob_fiddler", "fiddler", 12, 4, "tob_fiddler", "left", name="Fiddler"),
                   inpc("tob_barman", "shopkeeper", 4, 1, "tob_barman", name="Barman")])
    talk("tobermory_mishnish", "tob_fiddler", "Fiddler",
         "We start slow, so everyone can find the tune, then we speed up until somebody falls off. Come back on a Friday, and bring your ears and your dancing shoes.")
    talk("tobermory_mishnish", "tob_barman", "Barman",
         "Whisky's from just up the hill, the cheese is from just out of town, and the fish is from just off the pier. It's a short menu, and a good one.")
    # boats: Staffa and Iona
    interior("tobermory_boats", "Boat Trips Office", 13, 8, Z, ds["boats"],
             props=[{"type": "wall_map", "x": 4, "y": 1, "walk": True}, {"type": "menu_board", "x": 8, "y": 1, "walk": True},
                    {"type": "bench", "x": 2, "y": 5}, {"type": "lobster_pots", "x": 10, "y": 5, "variant": 1}, {"type": "potted_plant", "x": 11, "y": 6}],
             counters=[(3, 2, 6)],
             npcs=[inpc("tob_skipper", "fisherman_north", 6, 1, "tob_skipper", name="Skipper")])
    script("tobermory_boats", "tob_skipper", [
        say("Skipper", "Staffa, Fingal's Cave, the puffins if the season's right, and Iona on the same ticket. I'm the skipper. The boat is the Ocean Maid, which has been mistaken for a small ferry and a large dinghy."),
        say("Skipper", "The Staffa boat sails at twelve. Not before, not after, because the cave is only open when the swell lets us. Three hours there and back."),
        if_("q_westhighlands_hop_started", [set_flag("q_westhighlands_hop_2")]),
        choice("Where to?", ["Staffa and Fingal's Cave", "Iona and the abbey", "Not today"], "_boat_choice"),
        if_("_boat_choice", [say("", "The boat leaves the harbour into a long grey swell. Past Ulva, past the Treshnish isles, and then a small green-black island shapes up out of the water, with a great arched mouth in its side. The sea breathes in and out of it."),
                             {"do": "warp", "zone": "staffa_cave", "x": 8, "y": 14, "facing": "up"}, {"do": "end"}],
            [if_("_boat_choice", [say("", "The boat rounds Ardnamurchan's cousin, Mull's long west coast, and heads for a low green island with a white beach and a small stone abbey. Iona."),
                                  {"do": "warp", "zone": "iona_abbey", "x": 7, "y": 11, "facing": "up"}, {"do": "end"}],
                 [say("Skipper", "Fair enough. The sea'll be here tomorrow, and so will I.")], eq=1)], eq=0)])
    # Staffa
    cave_rows = [
        "xxxxxxxxxxxxxxxxx",
        "x~~~~~~~~~~~~~~~x",
        "x~~eeeeeeeeeee~~x",
        "x~~emmmmmmmmme~~x",
        "x~~emmmmmmmmme~~x",
        "x~~eeeeeeeeeee~~x",
        "xxxeeeeeeeeeeexxx",
        "xxxemmmeeemmmexxx",
        "xxxemmmeeemmmexxx",
        "xxxeeeeeeeeeeexxx",
        "xxxemmmeeemmmexxx",
        "xxxemmmeeemmmexxx",
        "xxxeeeeeeeeeeexxx",
        "xxxxxxeeeexxxxxxx",
        "xxxxxxeeeexxxxxxx",
        "xxxxxxxxDxxxxxxxx",
    ]
    cave_props = [{"type": "standing_stone", "x": 2, "y": y, "variant": (y % 3)} for y in (3, 5, 7)]
    cave_props += [{"type": "standing_stone", "x": 14, "y": y, "variant": (y % 3)} for y in (3, 5, 7)]
    cave_props += [{"type": "standing_stone", "x": 3, "y": y, "variant": (y % 3)} for y in (9, 11)]
    cave_props += [{"type": "standing_stone", "x": 13, "y": y, "variant": (y % 3)} for y in (9, 11)]
    ZONES["staffa_cave"] = {
        "id": "staffa_cave", "name": "Fingal's Cave", "region": "", "kind": "interior", "music": "route_north_coast",
        "weather": {}, "props": cave_props, "warps": [{"x": 8, "y": 15, "to": Z, "tx": 50, "ty": 24, "facing": "down"}], "edges": {},
        "npcs": [inpc("tob_mendelssohn", "poet", 7, 9, "tob_mendelssohn", name="Young Composer"),
                 inpc("tob_staffa_puffin", "creature:puffling", 11, 6, "tob_staffa_puffin", "down", name="Puffin")],
        "encounters": {}, "signs": [], "spawn": [8, 14], "rows": cave_rows, "stage": "cave",
        "legend_extra": {"e": {"tile": "path", "colour": "#4c4f58"}, "m": {"tile": "tall_grass", "colour": "#3b4651", "prop": "none"}},
        "scaled_floor": 69,
    }
    z = ZONES["staffa_cave"]
    z["rows"] = [r.replace("D", "e") if i < 15 else r for i, r in enumerate(cave_rows)]
    z["rows"][15] = "xxxxxxxxDxxxxxxxx"
    z["signs"] = [{"text": "FINGAL'S CAVE. The cave is about 69 metres deep and the arched roof rises like a cathedral's. The walls are made of columns of basalt, thousands of them, as tidy as organ pipes. Fingal is Fionn mac Cumhaill, the giant, in Scottish clothes. The same giant built the Giant's Causeway, the story goes, to walk across to fight a rival here.",
                   "x": 7, "y": 12, "plaque": "tob_fingals_cave_inside", "title": "Fingal's Cave"}]
    for sp, lo, hi, w, cond in [
        ("staffling", 69, 71, 16, {}), ("fingalith", 70, 72, 4, {}), ("clownbill", 69, 71, 12, {"time": ["dawn", "day"]}),
        ("selklet", 69, 71, 10, {}), ("polartern", 69, 71, 8, {}), ("gannetling", 69, 71, 6, {}), ("minchman", 69, 71, 4, {}),
    ]:
        e = {"species": sp, "min": lo, "max": hi, "weight": w}
        e.update(cond)
        z["encounters"].setdefault("grass", []).append(e)
    talk("staffa_cave", "tob_mendelssohn", "Young Composer",
         "Dreadfully seasick on the crossing, I must tell you. But then the swell comes into the cave and the whole place sings. The rhythm of the waves, the echo of the columns. I shall write it down before I forget.",
         "My sister Fanny will love it. I'll call the overture after the Hebrides, and let the cave take the credit.")
    talk("staffa_cave", "tob_staffa_puffin", "", "A puffin shuffles on a ledge, looking like a small, stout waiter who has forgotten what he came in for. It is carrying about nine sand eels crosswise in its beak, which is a skill.")
    # Iona
    interior("iona_abbey", "Iona Abbey", 15, 13, Z, (50, 24),
             props=[{"type": "bench", "x": 4, "y": 5}, {"type": "bench", "x": 4, "y": 7}, {"type": "bench", "x": 10, "y": 5},
                    {"type": "bench", "x": 10, "y": 7}, {"type": "candelabra", "x": 6, "y": 1}, {"type": "candelabra", "x": 8, "y": 1},
                    {"type": "standing_stone", "x": 1, "y": 9, "variant": 2}, {"type": "standing_stone", "x": 13, "y": 9, "variant": 2},
                    {"type": "statue", "x": 2, "y": 2}, {"type": "statue", "x": 12, "y": 2},
                    {"type": "rug", "x": 7, "y": 3, "w": 1, "h": 8, "variant": 1, "walk": True}],
             npcs=[inpc("tob_columba", "poet", 7, 2, "tob_columba", name="Warden of the Abbey"),
                   inpc("tob_pilgrim", "hiker", 3, 8, "tob_pilgrim", "right", name="Pilgrim")], floor="+")
    # the Iona zone returns to the Tobermory boat office; fix its door warp to the quay
    ZONES["iona_abbey"]["warps"][0].update({"tx": 50, "ty": 24})
    talk("iona_abbey", "tob_columba", "Warden of the Abbey",
         "St Columba came here from Ireland in 563, with twelve companions, and built a monastery of wood and wattle. The abbey you see is much later, from the 1200s, but the island has been holy for over fourteen hundred years.",
         "Kings of Scotland were buried here for centuries, including, they say, Macbeth. A nice bit of good press for a man usually described as a murderer.",
         "Iona's called the cradle of Scottish Christianity. Also of Scottish tourism. Please don't picnic on the graves.")
    script("iona_abbey", "tob_pilgrim", [
        say("Pilgrim", "I walked the island from the jetty. The beach on the south end has little green stones, a marble that's local. People pick them up and carry them home."),
        say("Pilgrim", "The abbey's open till five. Don't dawdle, the last boat leaves shortly afterwards, and the skipper doesn't wait for dreamers."),
        if_("q_westhighlands_hop_started", [set_flag("q_westhighlands_hop_3")])])
    talk(Z, "tob_birder", "Eagle Watcher",
         "There, over Aros, a speck. White tail, big as a barn door. Sea eagle. There's a whole family of them on Mull. They're called flying barn doors, and they don't mind.")
    talk(Z, "tob_hunter", "Galleon Hunter",
         "Down there under the pier lies a Spanish galleon, loaded with ducats. Or a wreck. Or a Victorian bath. I'm persuaded it's the galleon.")
    talk(Z, "tob_painter", "Artist",
         "I paint the front. Everyone says it's the colours. Yellow, pink, blue, green, red, teal. The truth is that the sea's grey and the sky's grey, so the houses have to be loud.")
    talk(Z, "tob_kid", "Child", "I live on a boat. Well, a house. Next to a boat. There's an otter that comes at four. I've named it Gary.")
    talk(Z, "tob_otter", "", "An otter hauls out on the pontoon, grooms for a while, and then stares at you with the look of someone who is entirely in the right.")
