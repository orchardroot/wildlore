"""Oban: Gateway to the Isles. Town, twelve interiors, the Games field, three of the four quests' Oban halves."""
from wh_lib import *

Z = "oban"
SEA = "$"


def nurse_script(zone, town_line, sign_off):
    script(zone, "nurse", [
        say("Nurse", town_line),
        choice("What can we do for you?", ["Heal my team", "Open the Ark", "Just looking"], "_nurse_choice"),
        if_("_nurse_choice", [say("Nurse", "Sit yourself down. Have a cuppa. Don't mind the rain, it's only passing through."),
                              {"do": "heal"}, say("Nurse", sign_off)],
            [if_("_nurse_choice", [say("Nurse", "The Ark terminal's in the corner. It runs on hot water, determination and an enormous amount of tea."), {"do": "ark"}],
                 [say("Nurse", "No bother at all. Away you go. Mind the puddles, they're deeper than they look.")], eq=1)], eq=0)])


def chain(flags, then, other):
    """All of `flags` set: run `then`; otherwise `other`."""
    cmds = then
    for f in reversed(flags):
        cmds = [if_(f, cmds, other)]
    return cmds


def sanctuary(zid, name, parent, door, town_line, sign_off):
    t = interior(zid, name, 11, 9, parent, door, music="sanctuary",
                 props=[{"type": "potted_plant", "x": 1, "y": 1}, {"type": "potted_plant", "x": 9, "y": 1},
                        {"type": "bookshelf", "x": 1, "y": 4}, {"type": "table", "x": 9, "y": 4}],
                 counters=[(3, 3, 5)],
                 npcs=[inpc("nurse", "sanctuary_nurse", 5, 2, "nurse"), inpc("memory_coach", "poet", 8, 5, "memory_coach", name="Retired Keeper")],
                 rows_extra=lambda g: [g[6].__setitem__(i, "+") for i in (1, 2, 8, 9)])
    nurse_script(zid, town_line, sign_off)
    return t


def shop_room(zid, name, parent, door, shop_id, hello, bye):
    t = interior(zid, name, 9, 8, parent, door,
                 props=[{"type": "bookshelf", "x": 1, "y": 1}, {"type": "potted_plant", "x": 7, "y": 5}],
                 counters=[(2, 2, 3), (6, 2, 2), (6, 3, 2), (6, 4, 2)],
                 npcs=[inpc("shopkeeper", "shopkeeper", 3, 1, "shopkeeper")])
    script(zid, "shopkeeper", [say("Shopkeeper", hello), {"do": "shop", "id": shop_id}, say("Shopkeeper", bye)])
    return t


def build():
    o = Out(Z, "Oban", "town", 72, 56, "town_scotland", "coast",
            {"drizzle": 32, "clear": 18, "downpour": 14, "fog": 8, "gale": 8, "sunshine": 20}, town=True)
    o.border()
    o.rect(0, 0, 13, 56, SEA)
    # Kerrera across the bay: a green island that shelters the harbour
    o.ell(5, 27, 3.5, 12, ".", only=SEA)
    for _ in range(40):
        x, y = o.rng.randrange(2, 9), o.rng.randrange(16, 39)
        if o.at(x, y) == ".":
            o.put(x, y, "T" if _ % 3 else "P")
    o.rect(13, 2, 1, 52, "s")
    o.rect(14, 6, 3, 45, ":")
    # lanes first, so pavements and George Street run over them
    o.rect(48, 11, 2, 28, "#")           # McCaig's lane north, the Games lane south
    o.rect(62, 13, 4, 1, "#")
    o.rect(64, 13, 2, 7, "#")
    o.rect(16, 9, 9, 1, "#")             # to Dunollie
    o.rect(24, 8, 1, 1, "#")
    o.rect(14, 19, 56, 1, ":")
    o.rect(14, 23, 56, 1, ":")
    o.rect(17, 20, 55, 3, "=")
    # the shore: shallows for the water table
    for y in list(range(8, 25)) + list(range(33, 45)):
        o.put(12, y, "w")
    # North Pier quay and the ferry quay
    o.rect(6, 26, 8, 6, ":")
    o.rect(14, 45, 13, 4, ":")
    o.rect(7, 46, 7, 3, ":")
    # --- the Games ground: a fenced field with a gate on the lane
    for x in range(38, 69):
        o.put(x, 36, "F")
        o.put(x, 52, "F")
    for y in range(36, 53):
        o.put(38, y, "F")
        o.put(68, y, "F")
    o.rect(48, 36, 2, 3, "#")
    o.ell(64, 48, 3, 3, ",", only=".")
    o.ell(41, 49, 2.5, 2.5, ",", only=".")
    o.rect(40, 38, 7, 1, "f")
    o.rect(52, 38, 15, 1, "f")
    # tall grass elsewhere, and the hill's pines
    o.ell(30, 5, 5, 2, ",", only=".")
    o.ell(38, 7, 3, 2, ",", only=".")
    o.ell(26, 34, 6, 3, ",", only=".")
    for _ in range(70):
        x, y = o.rng.randrange(30, 69), o.rng.randrange(2, 11)
        if o.at(x, y) == ".":
            o.put(x, y, "P")
    for _ in range(40):
        x, y = o.rng.randrange(18, 68), o.rng.randrange(54, 55) if False else o.rng.randrange(40, 53)
        if o.at(x, y) == "." and not (38 <= x <= 68 and 36 <= y <= 52):
            o.put(x, y, "T" if _ % 2 else "P")
    o.rect(58, 13, 4, 1, "_")
    o.rect(58, 14, 6, 1, "!")
    o.rect(64, 14, 2, 1, "&")
    o.prop("buffer_stop", 57, 14)
    o.prop("buffer_stop", 66, 14)
    # --- buildings
    ds = {}
    ds["dunollie"] = o.building(20, 3, 9, 5, "castle", "Dunollie Castle", "castle", 4, "oban_dunollie", 6, 9)
    ds["mccaig"] = o.building(44, 2, 9, 9, "mccaig", "McCaig's Tower", None, 4, "oban_mccaig", 7, 9)
    ds["cathedral"] = o.building(19, 12, 10, 7, "cathedral", "St Columba's Cathedral", "church", 5, "oban_cathedral", 7, 10)
    ds["inn"] = o.building(31, 15, 7, 4, "granite", "The Oban Inn", None, 3, "oban_inn", 7, 8)
    ds["museum"] = o.building(40, 15, 8, 4, "granite", "Oban War and Peace Museum", "museum", 4, "oban_warmuseum", 6, 8)
    ds["sanct"] = o.building(50, 15, 6, 4, "sanctuary", "Oban Sanctuary", None, 3, "oban_sanctuary", 5, 7)
    ds["shop"] = o.building(58, 15, 6, 4, "shop", "Oban Corner Shop", None, 3, "oban_shop", 4, 6)
    ds["home_a"] = o.building(66, 15, 4, 4, "white_render", "Home", "home", 1, "oban_home_a", 6, 7)
    ds["station"] = o.building(58, 9, 8, 4, "station", "Oban Station", None, 4)
    ds["guest"] = o.building(19, 24, 7, 5, "granite", "Esplanade Guest House", "home", -1)
    o.building(28, 24, 6, 5, "white_render", "Corran Tea Room", "cafe", -1)
    ds["distillery"] = o.building(36, 24, 12, 5, "distillery", "Oban Distillery", "workshop", 6, "oban_distillery", 7, 8)
    ds["home_b"] = o.building(50, 24, 5, 5, "granite", "Home", "home", 2, "oban_home_b", 6, 7)
    o.building(57, 24, 6, 5, "cream_render", "Chocolate Shop", "cafe", -1)
    ds["seafood"] = o.building(7, 26, 5, 3, "white_render", "Pier Seafood Shack", "cafe", 2, "oban_seafood", 6, 6)
    ds["calmac"] = o.building(19, 40, 9, 5, "granite", "CalMac Ferry Terminal", None, 4, "oban_calmac", 7, 9)
    o.extra["station"] = {"x": 62, "y": 13}
    o.extra["ferry"] = {"x": 8, "y": 47, "route": "oban_tobermory"}
    o.edges = {"east": {"to": "loch_lomond", "offset": 0}}
    o.spawn = [30, 21]
    # --- dressing
    for x, y in ((17, 10), (17, 26), (17, 36), (17, 44), (30, 19), (38, 23), (60, 19), (60, 23), (52, 21)):
        if o.at(x, y) in ".:":
            o.prop("lamp_post", x, y)
    for x, y in ((14, 14), (14, 32), (14, 40), (15, 28)):
        o.prop("bench", x, y)
    o.prop("lobster_pots", 6, 29, variant=1)
    o.prop("lobster_pots", 13, 31, variant=0)
    o.prop("boat", 4, 31, variant=1)
    o.prop("boat", 3, 34, variant=1)
    o.prop("boat", 4, 47, variant=0)
    o.prop("buoy", 5, 24)
    o.prop("buoy", 4, 38)
    o.prop("bollard", 6, 31)
    o.prop("bollard", 13, 26)
    o.prop("bollard", 7, 48)
    o.prop("bollard", 13, 48)
    for x, y in ((24, 10), (26, 10)):
        o.prop("rock", x, y, variant=1)
    o.prop("flagpole", 47, 37, variant=1)
    o.prop("flagpole", 50, 37, variant=1)
    o.prop("market_stall", 44, 39)
    o.prop("market_stall", 54, 39)
    o.prop("bench", 42, 51)
    o.prop("bench", 64, 51)
    o.prop("bunting", 41, 40, variant=6)
    o.prop("hanging_basket", 33, 19)
    o.prop("hanging_basket", 36, 19)
    o.prop("planter", 59, 19)
    o.prop("post_box", 29, 19)
    o.prop("phone_box", 56, 19)
    o.sprinkle("bush", 30, only=".", variants=3, rows=(2, 53))
    o.sprinkle("rock", 14, only=".", variants=3, rows=(2, 53))
    # --- signs and plaques (a dozen)
    S = o.sign
    S(68, 23, "FINGERPOST. East: Loch Lomond, the Trossachs and Glasgow. West: the sea, then the Isles. Please don't try the second one on foot.")
    S(18, 21, "GEORGE STREET. The high street, running up from the bay. Gift shops, fish and chips, wet waterproofs and a great many people eating ice cream in the rain.")
    S(47, 38, "MOSSFIELD. The Games ground. Heavy events at the east end, piping at the west, shinty on the green. Please do not throw anything unless a Marshal has told you to.")
    P = S
    P(22, 20, "OBAN. An t-Oban in Gaelic, which means 'the little bay'. It is a small town on a big bay, tucked behind the island of Kerrera, and it has been the main port for the western isles for about two hundred years.",
      "obn_name", "Oban")
    P(16, 41, "GATEWAY TO THE ISLES. Ferries leave from here for Mull, Coll, Tiree, Colonsay, Barra, South Uist and Lismore. The terminal is the busiest bit of town, with a lot of cars and a great deal of luggage.",
      "obn_gateway", "Gateway to the Isles")
    P(47, 12, "MCCAIG'S TOWER. A banker called John Stuart McCaig had it built between 1897 and 1902 to give local stonemasons winter work and as a memorial to his family. He planned statues of the family for its arches, but died before they were made, so they are still waiting. It looks like the Colosseum and has never been finished.",
      "obn_mccaigs_tower", "McCaig's Tower")
    P(44, 29, "OBAN DISTILLERY. Founded in 1794, it is one of the smallest in Scotland, and it stands in the middle of the town, squeezed between the cliff and the shops. Oban grew up around it, which is how a lot of Scottish towns are described, usually by the distillery.",
      "obn_distillery", "Oban Distillery")
    P(25, 9, "DUNOLLIE CASTLE. The ruined keep on the headland was the stronghold of the MacDougalls, lords of Lorn. In 1306 they took the Brooch of Lorn from Robert the Bruce's cloak after a fight at Dalrigh, and the clan treasured it for centuries.",
      "obn_dunollie", "Dunollie Castle")
    P(24, 20, "ST COLUMBA'S CATHEDRAL. Built of granite in the 1930s to a design by Sir Giles Gilbert Scott, who also designed Liverpool's Anglican cathedral and, rather less grandly, the red telephone box.",
      "obn_cathedral", "St Columba's Cathedral")
    P(45, 19, "WAR AND PEACE MUSEUM. A small museum on the seafront full of photographs, medals and models. In the Second World War Oban was a flying boat base, and Catalinas and Sunderlands used to land in the bay.",
      "obn_war_peace", "War and Peace Museum")
    P(8, 21, "KERRERA. The island across the bay that shelters Oban from the Atlantic. King Alexander II died there in 1249 while gathering a fleet to win back the Hebrides from the Norwegians.",
      "obn_kerrera", "Kerrera")
    P(46, 37, "ARGYLLSHIRE GATHERING. The Oban Highland Games, held each summer for well over a century. Pipers, dancers and the heavy events: tossing the caber, throwing the hammer and putting the stone.",
      "obn_gathering", "Argyllshire Gathering")
    P(60, 36, "SHINTY. A stick-and-ball game played with a curved caman, twelve a side, with the ball allowed in the air. It shares ancestors with Irish hurling, and the two sides play each other under compromise rules, mostly with great enthusiasm and some blood.",
      "obn_shinty", "Shinty")
    P(8, 30, "SEAFOOD. Scallops, langoustines and crab come off the boats and straight into the huts on the pier, which makes it about the shortest supply chain in Scotland.",
      "obn_pier_seafood", "Pier Seafood")
    P(60, 14, "OBAN STATION. The Callander and Oban Railway reached the harbour in 1880, and the line from Glasgow still ends here, as near the ferries as a train can get.",
      "obn_station", "Oban Station")
    # --- wild tables
    for sp, lo, hi, w, cond in [
        ("raidtail", 69, 70, 8, {}), ("binfox", 69, 70, 8, {"time": ["night", "dusk"]}), ("strutcoo", 69, 70, 8, {"time": ["day", "dawn"]}),
        ("cooplet", 69, 70, 6, {"weather": ["drizzle", "downpour"]}), ("chipgull", 69, 70, 10, {}),
        ("starlet", 69, 70, 8, {"time": ["dusk", "dawn"]}), ("lekling", 69, 70, 8, {"time": ["day", "dawn"]}),
        ("heilan", 69, 70, 5, {}), ("eaglet", 69, 70, 5, {"time": ["day"]}),
    ]:
        o.enc("grass", sp, lo, hi, w, **cond)
    for sp, lo, hi, w, cond in [
        ("selklet", 69, 70, 12, {}), ("clownbill", 69, 70, 12, {"time": ["dawn", "day"]}), ("gannetling", 69, 70, 10, {}),
        ("dolphlet", 69, 70, 10, {}), ("greyhaul", 69, 70, 8, {}), ("baskling", 69, 70, 6, {"time": ["dusk", "night"]}),
        ("orcalet", 69, 70, 3, {}), ("minchman", 69, 70, 4, {"weather": ["gale", "downpour"]}),
    ]:
        o.enc("water", sp, lo, hi, w, **cond)
    # --- people
    o.npc("rail_guard", "rail_guard", 61, 13, "rail_guard", "right")
    o.npc("obn_marshal", "piper", 49, 41, "obn_marshal", "up", name="Games Marshal")
    o.npc("obn_hamish", "fisherman_north", 12, 30, "obn_hamish", "left", name="Old Hamish")
    o.npc("obn_cailleach", "creature:cailleach", 6, 30, "obn_cailleach", "right", show_if="q_westhighlands_cail_1", hide_if="caught_cailleach")
    o.npc("obn_gull", "creature:chipgull", 16, 28, "obn_gull", "down", "wander", radius=1)
    o.npc("obn_guide", "tour_guide", 49, 14, "obn_guide", "down", name="Tower Guide", times=["day", "dusk"])
    o.npc("obn_porter", "sailor", 20, 46, "obn_porter", "right", name="Pier Porter")
    o.npc("obn_walker", "hiker", 40, 21, "obn_walker", "down", name="Visitor")
    o.npc("obn_shinty_fan", "shinty_player", 62, 41, "obn_shinty_fan", "down", name="Shinty Player")
    o.trainer_npc("obn_caber", "rugby_player", 44, 43, "obn_caber", "right")
    o.trainer_npc("obn_hammer", "steelworker", 55, 43, "obn_hammer", "left")
    o.trainer_npc("obn_stones", "farmer", 50, 47, "obn_stones", "up")
    o.trainer_npc("obn_champ", "rugby_player", 60, 47, "obn_champ", "left", show_if="q_westhighlands_games_done")
    o.trainer_npc("obn_piper", "piper", 49, 16, "obn_piper", "down")
    o.trainer_npc("obn_fisher", "fisher", 9, 31, "obn_fisher", "right")
    for n in o.npcs:
        if o.at(n["x"], n["y"]) in "TPR^~BF$":
            o.put(n["x"], n["y"], ".")
    for p in o.props:
        if p["type"] != "building" and o.at(p["x"], p["y"]) in "TPBF$":
            o.put(p["x"], p["y"], ".")
    o.save()
    interiors(ds)
    return ds


def trainers():
    trainer("obn_caber", "Caber Tosser Fergus", "Heavy Events", "rugby_player",
            [("quayhulk", 70), ("billgruff", 70), ("lekbruiser", 69)], 2600,
            ["The caber is about nineteen feet of larch and weighs as much as a small wardrobe. You don't throw it for distance. You throw it to turn over, like a clock hand at twelve. Want to see?"],
            "Fair play. You'd have tipped it clean.",
            "A caber is judged on the turn, not the distance. Twelve o'clock is a perfect score. I'm told it takes years to stop hitting my own foot.")
    trainer("obn_hammer", "Hammer Thrower Isla", "Heavy Events", "steelworker",
            [("samsonian", 70), ("warrender", 70), ("finnmacool", 70), ("steelheart", 69)], 2650,
            ["The Scottish hammer has a wooden handle and a lead head, and you throw it over your shoulder from a spin. Stand well back. No, further. Further."],
            "A fine throw of your own. Don't tell the hammer, it gets ideas.",
            "I threw one clean over a marquee once. There was a tea urn. We don't talk about the urn.")
    trainer("obn_stones", "Stone Putter Dougal", "Heavy Events", "farmer",
            [("billgruff", 71), ("clawcastle", 70), ("raidtail", 70), ("thistlord", 70)], 2700,
            ["The Braemar stone is a big round rock you put from a standing start, with one hand, like a shot. Lift it, don't drop it on your toe, and don't ask why we do this."],
            "That was a proper put. Have a seat on the stone. Mind it's heavy.",
            "In the old days they'd lift a heavy boulder to prove they were strong enough for the clan. We have progressed to doing it in a field for a rosette.")
    trainer("obn_champ", "Big Dougie MacLeod", "Heavy Events Champion", "rugby_player",
            [("quayhulk", 72), ("lekbruiser", 72), ("finnmacool", 72), ("warrender", 72), ("samsonian", 72), ("billgruff", 73)], 5400,
            ["So you're the one who beat the whole programme. I've held the Heavy Events cup for eleven summers. I tossed a caber over the Oban Inn once. I was aiming for the pub."],
            "Well. There's twelve summers of rosettes in your future. And a place at my table.",
            "You're welcome at the Gathering any year. Wear something with room in the shoulders.")
    trainer("obn_piper", "Piper Calum", "Piper", "piper",
            [("heilan", 69), ("ptarmigan", 70), ("highlynx", 70)], 2400,
            ["That's 'The Skye Boat Song', or it was, before the wind got it. The pipes are wind instruments, and I'll have you know wind is not a problem in Oban."],
            "A finer foe than the wind, I'll say.",
            "The Great Highland Bagpipe has three drones and a chanter. People say it's loud. I say it's finely tuned for the outdoors.")
    trainer("obn_fisher", "Creel Fisher Mairi", "Fisher", "fisher",
            [("clownbill", 70), ("pierlord", 70), ("greyhaul", 70), ("bayrunner", 70)], 2500,
            ["Creels are the pots we set for lobsters, crab and langoustine. We bring them up before sunrise. You're standing on my bait."],
            "Right enough. I'll buy you a scallop.",
            "The langoustine is pink, the size of a hand and the nicest thing in the sea. The scallop comes second. The crab will tell you it is first.")


def interiors(ds):
    # Sanctuary and shop
    sanctuary("oban_sanctuary", "Oban Sanctuary", Z, ds["sanct"],
              "Failte, welcome to Oban Sanctuary. We take in anything that's come off a ferry looking green. That includes the creatures.",
              "There you go, right as rain. Mind how you go, and mind the gulls on the pier. They've seen you with chips.")
    shop_room("oban_shop", "Oban Corner Shop", Z, ds["shop"], "oban_corner_shop",
              "Hello there. We have scallops, cheddar from Mull, and a rack of waterproofs for the sunshine that isn't coming.",
              "Cheers now. Don't let the ferry leave without you.")
    # Distillery
    interior("oban_distillery", "Oban Distillery", 15, 10, Z, ds["distillery"],
             props=[{"type": "table", "x": 3, "y": 3}, {"type": "table", "x": 11, "y": 3}, {"type": "steel_plates", "x": 2, "y": 1},
                    {"type": "steel_plates", "x": 12, "y": 1}, {"type": "display_case", "x": 7, "y": 2, "variant": 2},
                    {"type": "bench", "x": 3, "y": 6}, {"type": "bench", "x": 11, "y": 6}, {"type": "potted_plant", "x": 1, "y": 8},
                    {"type": "wall_picture", "x": 5, "y": 1, "walk": True, "variant": 3}, {"type": "wall_picture", "x": 9, "y": 1, "walk": True, "variant": 1},
                    {"type": "rug", "x": 7, "y": 4, "w": 1, "h": 4, "variant": 2, "walk": True}],
             npcs=[inpc("obn_stillman", "steelworker", 6, 3, "obn_stillman", name="Stillman"),
                   inpc("obn_cooper", "farmer", 9, 6, "obn_cooper", "left", name="Cooper")], floor="+")
    talk("oban_distillery", "obn_stillman", "Stillman",
         "Barley, water and yeast. That's the lot. We malt it, mash it, ferment it, then double distil it in copper stills that are small enough to look like they belong in a cottage.",
         "The town grew up around this place in 1794. We've outlasted the town council, three bypasses and all the ferries that said they'd never come back.")
    talk("oban_distillery", "obn_cooper", "Cooper",
         "A cooper makes the casks. Barrels that held sherry or bourbon, mostly. The wood gives the whisky its colour, and a good deal of the flavour.",
         "About two per cent of the whisky evaporates out of every cask every year. That's called the angel's share. The angels, in Scotland, are heavy drinkers.")
    # McCaig's Tower
    interior("oban_mccaig", "McCaig's Tower", 13, 11, Z, ds["mccaig"],
             props=[{"type": "bench", "x": 3, "y": 8}, {"type": "bench", "x": 9, "y": 8}, {"type": "statue", "x": 6, "y": 3},
                    {"type": "planter", "x": 2, "y": 2}, {"type": "planter", "x": 10, "y": 2}, {"type": "planter", "x": 2, "y": 6},
                    {"type": "planter", "x": 10, "y": 6}, {"type": "potted_plant", "x": 4, "y": 5}, {"type": "potted_plant", "x": 8, "y": 5}],
             npcs=[inpc("obn_folly_guide", "poet", 6, 6, "obn_folly_guide", name="Folly Guide")],
             floor=".", rows_extra=lambda g: [g[y].__setitem__(x, "f") for (x, y) in ((3, 3), (4, 3), (8, 3), (9, 3), (3, 4), (9, 4))])
    talk("oban_mccaig", "obn_folly_guide", "Folly Guide",
         "The architect was an Oban banker called John Stuart McCaig, and the plan was a tower, inspired by the Colosseum, with bronze statues of himself and his family in every arch.",
         "He died in 1902, and the family said no to the statues. The tower stayed an empty shell. A folly is an ornamental building with no practical use, and this one has had work for the stonemasons, the pigeons and the view.",
         "Today the inside is a garden. It's free, open all hours, and the best view in Oban. Don't tell the town council, they'll start charging.")
    # Dunollie
    interior("oban_dunollie", "Dunollie Castle", 15, 10, Z, ds["dunollie"],
             props=[{"type": "fireplace", "x": 7, "y": 1}, {"type": "table", "x": 3, "y": 4}, {"type": "bench", "x": 3, "y": 5},
                    {"type": "display_case", "x": 11, "y": 3, "variant": 1}, {"type": "bookshelf", "x": 1, "y": 1},
                    {"type": "wall_picture", "x": 4, "y": 1, "walk": True, "variant": 2}, {"type": "wall_picture", "x": 10, "y": 1, "walk": True, "variant": 3},
                    {"type": "candelabra", "x": 12, "y": 7}, {"type": "rug", "x": 6, "y": 3, "w": 3, "h": 3, "variant": 1, "walk": True}],
             npcs=[inpc("obn_steward", "poet", 9, 4, "obn_steward", name="MacDougall Steward"),
                   inpc("obn_castle_piper", "piper", 12, 5, "obn_castle_piper", "left", name="Castle Piper")], floor="+")
    talk("oban_dunollie", "obn_steward", "MacDougall Steward",
         "The MacDougalls are one of the oldest clans in Scotland, lords of Lorn, and Dunollie has been their seat for about eight centuries.",
         "In 1306 the clan fought Robert the Bruce at Dalrigh and took his brooch, a big silver and crystal thing known as the Brooch of Lorn. Bruce got his own back in time. The brooch is still famous.")
    talk("oban_dunollie", "obn_castle_piper", "Castle Piper",
         "I play at the gate on Saturdays. The acoustics in the keep are wonderful. The neighbours haven't made their minds up.")
    # Cathedral
    interior("oban_cathedral", "St Columba's Cathedral", 13, 11, Z, ds["cathedral"],
             props=[{"type": "bench", "x": 3, "y": 4}, {"type": "bench", "x": 3, "y": 6}, {"type": "bench", "x": 9, "y": 4},
                    {"type": "bench", "x": 9, "y": 6}, {"type": "candelabra", "x": 5, "y": 1}, {"type": "candelabra", "x": 7, "y": 1},
                    {"type": "statue", "x": 1, "y": 2}, {"type": "statue", "x": 11, "y": 2},
                    {"type": "rug", "x": 6, "y": 3, "w": 1, "h": 6, "variant": 1, "walk": True}],
             npcs=[inpc("obn_verger", "poet", 6, 2, "obn_verger", name="Verger")], floor="+")
    talk("oban_cathedral", "obn_verger", "Verger",
         "The cathedral is named for St Columba, the Irish monk who crossed to Iona in 563 and carried Christianity into the Highlands.",
         "It was designed by Sir Giles Gilbert Scott, and it is built of local granite. It was begun in the 1930s and finished in the early 1950s. Scotland tends to take its time with big projects.")
    # War and Peace Museum
    interior("oban_warmuseum", "War and Peace Museum", 13, 9, Z, ds["museum"],
             props=[{"type": "display_case", "x": 2, "y": 3, "variant": 1}, {"type": "display_case", "x": 4, "y": 3, "variant": 2},
                    {"type": "display_case", "x": 8, "y": 3, "variant": 3}, {"type": "wall_map", "x": 6, "y": 1, "walk": True},
                    {"type": "wall_picture", "x": 3, "y": 1, "walk": True, "variant": 2}, {"type": "wall_picture", "x": 9, "y": 1, "walk": True, "variant": 1},
                    {"type": "telescope", "x": 10, "y": 6}, {"type": "bench", "x": 3, "y": 6}, {"type": "potted_plant", "x": 11, "y": 7}],
             npcs=[inpc("obn_curator", "student", 6, 4, "obn_curator", name="Curator")])
    script("oban_warmuseum", "obn_curator", [
        say("Curator", "Welcome to the museum. It's small, but it has a lot of heart, and a model of a Sunderland flying boat that I'm very proud of."),
        say("Curator", "Oban was a flying boat base in the Second World War. Sunderlands and Catalinas used to land in the bay, which must have been a sight: planes landing on the water, for the herring gulls' benefit."),
        if_("q_westhighlands_cail_started",
            [if_("q_westhighlands_cail_1",
                 [say("Curator", "The Corryvreckan? Hamish's tale. You've heard the lot already.")],
                 [say("Curator", "Ah, Hamish sent you about the Cailleach? Between Jura and Scarba the tide squeezes through a narrow strait and whips up the Corryvreckan, the third largest whirlpool in the world, so they say. You can hear the roar ten miles away."),
                  say("Curator", "The old story says the Cailleach, a hag of winter, washes her great plaid in it before the cold season. When it comes out pure white, the snow is on its way. George Orwell nearly drowned there in 1947, when his boat was sucked into it. He survived, and wrote 1984 afterwards, which says something."),
                  say("Curator", "If you'd like to meet her, she'll be waiting at the end of the North Pier. Be polite. Bring a warm coat."),
                  set_flag("q_westhighlands_cail_1")])],
            [])])
    # Seafood shack
    interior("oban_seafood", "Pier Seafood Shack", 11, 8, Z, ds["seafood"],
             props=[{"type": "fryer", "x": 2, "y": 1}, {"type": "menu_board", "x": 5, "y": 1, "walk": True},
                    {"type": "lobster_pots", "x": 9, "y": 5, "variant": 0}, {"type": "table", "x": 7, "y": 3}, {"type": "bench", "x": 7, "y": 4},
                    {"type": "table", "x": 2, "y": 5}, {"type": "potted_plant", "x": 9, "y": 1}],
             counters=[(1, 3, 4)],
             npcs=[inpc("obn_shack_cook", "shopkeeper", 3, 2, "obn_shack_cook", name="Shack Cook")])
    script("oban_seafood", "obn_shack_cook", [
        say("Shack Cook", "Scallops, langoustines, crab sandwiches and a chowder that has no business being this good. Straight off the boats."),
        {"do": "shop", "id": "oban_seafood"},
        say("Shack Cook", "Go on, eat it on the pier, with a seagull watching. That's the proper way.")])
    # CalMac office: the island-hop puzzle
    interior("oban_calmac", "CalMac Ferry Terminal", 15, 10, Z, ds["calmac"],
             props=[{"type": "wall_map", "x": 4, "y": 1, "walk": True}, {"type": "clock", "x": 7, "y": 1, "walk": True},
                    {"type": "menu_board", "x": 10, "y": 1, "walk": True}, {"type": "bench", "x": 2, "y": 6}, {"type": "bench", "x": 3, "y": 6},
                    {"type": "bench", "x": 11, "y": 6}, {"type": "bench", "x": 12, "y": 6}, {"type": "potted_plant", "x": 13, "y": 8},
                    {"type": "rug", "x": 6, "y": 4, "w": 3, "h": 3, "variant": 1, "walk": True}],
             counters=[(3, 3, 9)],
             npcs=[inpc("obn_morag", "student", 7, 2, "obn_morag", name="Morag"),
                   inpc("obn_ferry_kid", "villager_3", 4, 7, "obn_ferry_kid", "up", name="Traveller")])
    talk("oban_calmac", "obn_ferry_kid", "Traveller",
         "I've been here since eight. The ferry to Mull leaves at nine. I like to be early. My dad says early is another word for lost.")
    plan_ok = ["q_westhighlands_hop_1", "q_westhighlands_hop_2", "q_westhighlands_hop_3"]
    plan = [
        say("Morag", "Let's lay it out. Three stops on Mull and the isles, one day, and the last boat back leaves late afternoon. What's the order?"),
        choice("The day-trip plan", ["Distillery, then Staffa, then Iona", "Staffa, then Iona, then the distillery", "Iona, then the distillery, then Staffa"], "_hop_plan"),
        if_("_hop_plan", [say("Morag", "That's it exactly. Distillery tour at ten, before the doors close. The Staffa boat at twelve with the tide, back by three. Then the Iona run, with the abbey open till five. You've saved a day. And possibly a marriage."),
                          item("mull_cheddar", 3), item("iona_pebble"), item("calmac_timetable"), standing("scotland", 3),
                          set_flag("q_westhighlands_hop_4"), set_flag("q_westhighlands_hop_done"),
                          say("Morag", "The pebble's a gift from the Iona pilgrims, they say it brings good crossings. And the cheddar's from Mull, for the road. Safe travels, from all of us at CalMac.")],
            [if_("_hop_plan", [say("Morag", "Staffa first? The boat only goes at twelve, so you'd miss it by hours, and the distillery tour is at ten. No. Try again, with the times in mind.")],
                 [say("Morag", "Iona first? You'd go there, then miss the tour at ten and the Staffa boat at twelve. Try again, and read your own notes.")], eq=1)], eq=0)]
    script("oban_calmac", "obn_morag", [
        if_("q_westhighlands_hop_done", [say("Morag", "Good to see you again. Anywhere I can send you? Not Staffa. You've had Staffa.")],
            [if_("q_westhighlands_hop_started",
                 [if_("q_westhighlands_hop_3",
                      [if_("q_westhighlands_hop_2", [if_("q_westhighlands_hop_1", plan,
                                                       [say("Morag", "Not got all three times yet. The distillery guide at Tobermory has the tour time, the boatman has the Staffa time, and the Iona pilgrim has the abbey's.")])],
                           [say("Morag", "Not got all three times yet. The distillery guide at Tobermory has the tour time, the boatman has the Staffa time, and the Iona pilgrim has the abbey's.")])],
                      [say("Morag", "Not got all three times yet. The distillery guide at Tobermory has the tour time, the boatman has the Staffa time, and the Iona pilgrim has the abbey's. The Tobermory boat is on the quay, just south of the terminal.")])],
                 [say("Morag", "Welcome to CalMac. We run the ferries: big red-and-blue ships and a timetable more complex than any I've seen. I've a problem for you, if you've a day."),
                  say("Morag", "A group wants to see Mull and the isles in a day: a distillery tour, the boat to Staffa and Iona's abbey. They want the plan in order. I can't make it fit, but I think you can."),
                  say("Morag", "Here's the trick: ask the guides on Mull what time each thing happens. Tobermory is the place to start. Take the ferry from the quay, just south of here, then come back and tell me."),
                  set_flag("q_westhighlands_hop_started")])])])
    # The Oban Inn (pub quiz)
    interior("oban_inn", "The Oban Inn", 15, 9, Z, ds["inn"],
             props=[{"type": "table", "x": 3, "y": 4}, {"type": "table", "x": 11, "y": 4}, {"type": "bench", "x": 3, "y": 5}, {"type": "bench", "x": 11, "y": 5},
                    {"type": "fireplace", "x": 7, "y": 1}, {"type": "wall_picture", "x": 4, "y": 1, "walk": True, "variant": 2},
                    {"type": "wall_picture", "x": 10, "y": 1, "walk": True, "variant": 3}, {"type": "potted_plant", "x": 1, "y": 7},
                    {"type": "rug", "x": 6, "y": 3, "w": 3, "h": 3, "variant": 2, "walk": True}],
             counters=[(3, 2, 3), (9, 2, 3)],
             npcs=[inpc("obn_quizmaster", "poet", 7, 3, "obn_quizmaster", name="Quizmaster"),
                   inpc("obn_barmaid", "mum", 4, 1, "obn_barmaid", name="Landlady")], floor="|")
    script("oban_inn", "obn_quizmaster", [
        say("Quizmaster", "Quiz night. Highlands and isles, general knowledge, and a round on ferries that nobody has ever passed."),
        {"do": "quiz", "pub": "oban_inn", "region": "scotland", "who": "Quizmaster", "set": "oban_quiz_score"}])
    talk("oban_inn", "obn_barmaid", "Landlady",
         "Last orders are called by the foghorn, and the fog is out. So that's it. Have a cuppa, there's a dear.")
    # Homes
    interior("oban_home_a", "Harbour Flat", 13, 9, Z, ds["home_a"],
             props=[{"type": "sofa", "x": 2, "y": 5, "variant": 1}, {"type": "fireplace", "x": 6, "y": 1}, {"type": "bookshelf", "x": 1, "y": 1},
                    {"type": "table", "x": 9, "y": 4}, {"type": "bed", "x": 11, "y": 1}, {"type": "window", "x": 3, "y": 1, "walk": True},
                    {"type": "rug", "x": 5, "y": 3, "w": 3, "h": 3, "variant": 0, "walk": True}],
             npcs=[inpc("obn_gran", "mum", 6, 4, "obn_gran", name="Granny")])
    talk("oban_home_a", "obn_gran", "Granny",
         "I've watched every ferry come in since 1958. The first rule of Oban: don't stand where the ferry is about to go. The second is: bring a coat.",
         "Gaelic's still spoken round here, you'll hear 'madainn mhath', that's good morning, and 'ciamar a tha thu', how are you. It's pronounced 'kimmer a ha oo', and nobody expects you to get it right.")
    interior("oban_home_b", "Hillside House", 13, 9, Z, ds["home_b"],
             props=[{"type": "kitchen_dresser", "x": 3, "y": 1}, {"type": "table", "x": 6, "y": 4}, {"type": "bench", "x": 5, "y": 5},
                    {"type": "bench", "x": 7, "y": 5}, {"type": "fireplace", "x": 9, "y": 1}, {"type": "potted_plant", "x": 1, "y": 7},
                    {"type": "rug", "x": 4, "y": 3, "w": 3, "h": 3, "variant": 2, "walk": True}],
             npcs=[inpc("obn_shintykid", "student", 9, 6, "obn_shintykid", "left", name="Shinty Kid")])
    talk("oban_home_b", "obn_shintykid", "Shinty Kid",
         "My caman's got a curve at the bottom, like a hockey stick but better. In shinty, you can hit the ball in the air. You can also be hit. It's twelve a side. Come and watch on Saturday.")
    # Games talk
    talk(Z, "obn_gull", "", "A herring gull stands guard over a polystyrene tray. It has never lost an argument about a chip.")
    talk(Z, "obn_guide", "Tower Guide",
         "That's McCaig's Tower, the folly on the hill. A banker built it to give masons work in winter. It's free to go in and the climb is short but steep. Take your time, and a pair of lungs.")
    talk(Z, "obn_porter", "Pier Porter",
         "The ferries run all year. Mull, Coll, Tiree, Colonsay, Barra, South Uist and Lismore. The Mull boat is the big one. Mind the car deck. Cars first, people after, and gulls everywhere.")
    talk(Z, "obn_walker", "Visitor",
         "Everyone says Oban's the seafood capital of Scotland. Having now eaten six scallops at nine in the morning, I believe them.")
    talk(Z, "obn_shinty_fan", "Shinty Player",
         "It's a bit like hurling and a bit like hockey and a bit like a brawl that got organised. Twelve a side. Oban has a team. Nobody's ever told me the offside rule and I've been playing for years.")
    script(Z, "rail_guard", [
        say("Rail Guard", "Oban Station, the end of the line from Glasgow. A hundred miles of lochs and hills and a ten-minute stop at Crianlarich for tea."),
        say("Rail Guard", "Hop aboard. The Wildlore rail runs to any town you have visited in Great Britain. Where to?"), {"do": "rail"}])
    # Games marshal
    done = [
        say("Games Marshal", "Three events, three wins. You've done more than most do in a season. The Gathering committee has a medal for you, and it's the heaviest we've got. Mind your neck."),
        item("highland_medal"), item("tablet", 3), standing("scotland", 3), set_flag("q_westhighlands_games_5"), set_flag("q_westhighlands_games_done"),
        say("Games Marshal", "And... Big Dougie MacLeod, our Heavy Events champion, has heard. He's out on the field now. You'll want a bite first.")]
    script(Z, "obn_marshal", [
        if_("q_westhighlands_games_done", [say("Games Marshal", "Champion! Anything I can do, ask. The only thing I can't do is weigh the caber. I tried once. The scales threw in the towel.")],
            [if_("q_westhighlands_games_started",
                 chain(["trainer_obn_caber", "trainer_obn_hammer", "trainer_obn_stones"], done,
                       [say("Games Marshal", "Three heavy events: the caber, the hammer and the stones. Beat Fergus, Isla and Dougal in turn. You'll find them in the field. Come back to me when you're done.")]),
                 [say("Games Marshal", "Welcome to Mossfield, the Oban Games ground. The Argyllshire Gathering has been held here for well over a century."),
                  say("Games Marshal", "We have a Heavy Events programme: the caber, the hammer and the stones. Three athletes, three events, and you need to win all three. It's the creature version, naturally. We have brawn."),
                  set_flag("q_westhighlands_games_started"),
                  say("Games Marshal", "Fergus has the caber, Isla the hammer and Dougal the stones. Beat them in the field. Report back when you're done.")])])])
    # Hamish and the Cailleach
    script(Z, "obn_hamish", [
        if_("q_westhighlands_cail_done", [say("Old Hamish", "The Cailleach's with you now? Then it'll be a mild winter, and I'll be the first to say I didn't believe in her.")],
            [if_("q_westhighlands_cail_started",
                 [if_("caught_cailleach",
                      [say("Old Hamish", "You've brought the Cailleach home! Well I never. Seventy years I've told that tale, and I never once thought she'd sit down for it."),
                       item("cailleachs_plaid"), item("oban_scallops", 2), standing("scotland", 2), set_flag("q_westhighlands_cail_3"), set_flag("q_westhighlands_cail_done"),
                       say("Old Hamish", "That's a scrap of her plaid, they say. It turns white at the first frost. Keep it dry. Or don't, it's a good sort of cold.")],
                      [say("Old Hamish", "Ask the curator in the War and Peace Museum what the old tale says. Then walk to the end of the quay. She'll be there for you. She'll not stay long.")])],
                 [say("Old Hamish", "See out there, past Kerrera, past Lismore, where the sea goes white between Jura and Scarba? That's the Corryvreckan, and it's the Cailleach's wash-tub."),
                  say("Old Hamish", "The Cailleach, the old hag, the winter queen, washes her plaid in the whirlpool every autumn. When she's done it comes out white as snow, and that's the first frost. Some say she walks the quays, if you're quiet."),
                  set_flag("q_westhighlands_cail_started"),
                  say("Old Hamish", "Go and ask at the museum, that's the War and Peace, they keep the old stories. Then come and find me. And mind your manners with her.")])])])
    script(Z, "obn_cailleach", [
        say("", "The end of the pier is cold. Frost feathers the bollards, though it is not a cold day. At the edge of the quay stands a tall grey figure with a plaid over her shoulders, as white as a gull's wing, dripping seawater that crackles into ice."),
        say("The Cailleach", "You have the look of someone sent by Hamish. He is a good old fool. I washed his father's boat once, in the Corryvreckan, and he has been telling the story ever since."),
        say("The Cailleach", "I am the wash-woman of the winter, child. I bring the frost and take the summer. Each autumn I wash my plaid in the whirlpool, and the first frost is when it dries. Look at it. Cold. Clean. White."),
        say("The Cailleach", "I do not do company. But I am curious, and a challenge is a challenge. Let us see if you are as warm as you look."),
        {"do": "legend", "species": "cailleach", "level": 72, "flag": "caught_cailleach", "music": "legend_sea"},
        if_("caught_cailleach",
            [say("", "The Cailleach folds into your team like a snowfall. The whirlpool out past Kerrera goes briefly quiet. On the pier, Hamish drops a creel and says a word you can't repeat.")],
            [say("", "The Cailleach turns away and walks off the end of the pier. The water goes white, then black, then still. She will come back, if you are ready to try again.")])])
