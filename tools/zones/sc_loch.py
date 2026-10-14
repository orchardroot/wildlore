# plan 5 group C, part 1: loch_ness (landmark route), inverness (town) + inverness_rink (Keeper arena), great_glen stub.
from ie_common import *
from wcommon import _stand
import math

WX = {"fog": 26, "drizzle": 28, "clear": 20, "downpour": 10, "sunshine": 10, "gale": 6}


def build(OUT):
    loch_ness(OUT)
    inverness(OUT)
    rink(OUT)
    great_glen_stub(OUT)


def great_glen_stub(OUT):
    z = Z("great_glen", "Great Glen", 40, 40, kind="route", region="scotland", music="route_highlands")
    z.d["stage"] = "valley"
    z.d["stub"] = True
    z.border("T", 2, gaps=[(38, 20, 2, 3)])
    z.d["edges"]["east"] = {"to": "loch_ness", "offset": 0}
    z.d["spawn"] = [20, 20]
    z.save(OUT + "/great_glen.json")


def loch_ness(OUT):
    W, H = 72, 46
    z = Z("loch_ness", "Loch Ness", W, H, kind="route", region="scotland", music="route_highlands", weather=WX)
    z.d["stage"] = "valley"
    z.legend["h"] = {"tile": "tall_grass", "colour": "#7a5c6a", "prop": "heather"}
    z.legend["k"] = {"tile": "grass", "colour": "#7f8f52"}
    z.rect(0, 0, W, H, "k")
    z.border("P", 2, gaps=[(0, 20, 2, 3), (34, 0, 3, 2)])
    z.scatter(0, 0, W, H, "T", 30, 3, only="P")
    hills(z, [(8, 7, 3, 15), (62, 7, 3, 16), (36, 3, 2, 10), (66, 18, 2, 8)])

    def e(x):
        return 26 + round(1.4 * math.sin(x / 6.0))
    # the loch: long, dark and deep
    for x in range(2, 70):
        ex = e(x)
        z.set(x, ex - 2, "s"); z.set(x, ex - 1, "w")
        for y in range(ex, H):
            z.set(x, y, "$")
    for x in range(0, 2):
        for y in range(28, H):
            z.set(x, y, "$")
    # roads: the A82 along the north shore, then north to Inverness
    z.rect(0, 20, 37, 3, "=")
    z.rect(34, 0, 3, 20, "=")
    z.rect(37, 20, 14, 3, "#")
    # the headland and Urquhart Castle
    z.rect(43, 23, 11, 9, "k")
    z.rect(44, 32, 9, 1, "w")
    for y in range(24, 32):
        z.set(42, y, "w"); z.set(54, y, "w")
    z.set(43, 31, "w"); z.set(53, 31, "w")
    z.rect(48, 23, 2, 2, "#")
    z.rect(45, 27, 8, 4, ":")
    z.rect(46, 28, 3, 2, "f")
    z.rect(47, 25, 4, 2, "k")
    z.rect(44, 27, 1, 4, "W"); z.rect(53, 27, 1, 2, "W")
    z.set(44, 29, "R"); z.set(53, 30, "R"); z.set(46, 31, "R"); z.set(52, 31, "R")
    z.building(44, 24, 3, 3, "castle", "Gate Tower", show_label=False)
    z.building(51, 24, 3, 3, "castle", "Grant Tower", show_label=False)
    z.rect(47, 24, 1, 1, "W"); z.rect(50, 24, 1, 1, "W"); z.rect(48, 24, 2, 1, "#")
    # the island out in deep water
    z.rect(50, 33, 13, 9, "o")
    z.rect(52, 36, 9, 4, "k")
    z.rect(53, 37, 3, 2, ",")
    z.rect(57, 38, 3, 1, ",")
    # the jetty and the survey boat
    z.rect(23, e(23) - 1, 2, 8, "|")
    z.rect(23, e(23) - 2, 2, 1, "s")
    # the monster exhibition and visitor centre
    z.building(8, 11, 8, 4, "white_render", "Monster Exhibition")
    z.building(41, 12, 9, 4, "stone", "Visitor Centre")
    z.rect(8, 15, 8, 1, ":"); z.rect(11, 16, 2, 4, "#"); z.rect(44, 16, 2, 4, "#")
    # heather and bracken
    blob(z, 24, 8, 8, 4, "h", only="k", seed=1, jitter=0.4)
    blob(z, 58, 10, 9, 5, "h", only="k", seed=2, jitter=0.4)
    blob(z, 10, 24, 4, 2, ",", only="k", seed=3)
    blob(z, 66, 20, 3, 3, ",", only="k", seed=4)
    blob(z, 28, 15, 5, 2, ",", only="k", seed=5)
    scatter_props(z, "pine", 3, 3, 66, 16, 34, 9, avoid=("k",))
    scatter_props(z, "birch", 3, 3, 66, 18, 14, 10, avoid=("k",))
    scatter_props(z, "rock", 3, 3, 66, 22, 12, 11, avoid=("k",))
    z.prop("pine", 54, 38, variant=1); z.prop("rock", 58, 37, variant=0); z.prop("rock", 55, 39, variant=2)
    z.prop("boat", 27, 30, variant=1); z.prop("buoy", 21, 31); z.prop("buoy", 31, 29, variant=1); z.prop("boat", 14, 33, variant=1)
    z.prop("bollard", 22, e(23) - 1); z.prop("bollard", 25, e(23) - 1)
    z.prop("bench", 20, 23); z.prop("bench", 30, 23); z.prop("lamp_post", 22, 19); z.prop("lamp_post", 37, 19)
    z.prop("phone_box", 16, 19); z.prop("planter", 7, 15); z.prop("planter", 16, 15)
    z.prop("standing_stone", 66, 12, variant=1)
    # signs
    z.sign(33, 18, "LOCH NIS · LOCH NESS. 37 km long, about 230 m deep, and holding more fresh water than all the lakes of England and Wales put together. The peat stains it the colour of strong tea, so you can see about a metre down. Whatever's in there has an excellent hiding place.")
    z.sign(46, 21, "URQUHART CASTLE (Caisteal Urchadain). A fortress on this headland for 700 years. In 1692 the garrison blew up their own gatehouse so the Jacobites couldn't use it, which is the kind of thing you only do when you're very cross about the furniture.")
    z.sign(10, 17, "THE MONSTER EXHIBITION. Admission includes a talking sea serpent, a sonar room and a gift shop with 41 different Nessies. The one in the window is smiling. It may know something.")
    z.sign(22, 22, "NESS SURVEY JETTY. Authorised vessels only. Keep a hand on your hat, a hand on your phone, and a hand on your sandwiches. That's three hands. Seagulls have more.")
    z.sign(56, 32, "DEEP WATER. The loch drops off sharply here. The sign is a request. The water is not a path.")
    # chatty people
    chat(z, "monster_hunter", "villager_3", 29, 23, "Monster Hunter",
         ["Nessie was first written about in the year 565, when St Columba told a water beast to stop eating a man, and it did. That's the oldest sighting. The newest is probably this morning.",
          "In 2018 scientists sampled the loch's water for DNA. They found a lot of eel. I'm choosing to believe it's one very large eel. Or a very friendly one."], "down", "still")
    chat(z, "castle_guide", "tour_guide", 49, 29, "Castle Guide",
         ["Welcome to Urquhart. It's a ruin, but it's a well-organised ruin. That tower is the Grant Tower, and the view from the top is the best on the loch. There's a lift for the view. Lift: me. Shouting.",
          "A Gaelic phrase, 'Fàilte gu Caisteal Urchadain'. Welcome to Urquhart Castle. Say it three times and the ghost of a medieval cook brings you a scone. Possibly."], "down", "still")
    chat(z, "coach_kid", "student", 16, 23, "Day Tripper",
         ["I've been here forty minutes and I haven't seen the monster. I've seen a duck. The duck is quite large.",
          "My gran says to watch the water for a V-shaped ripple, with nothing making it. I saw one. It was a swan. I felt a bit let down."], "up", "wander")
    chat(z, "old_boatman", "farmer", 38, 24, "Old Boatman",
         ["Fifty years on this loch, and I've never seen a monster. Mind you, I've never been looking. It's rude to stare.",
          "The Caledonian Canal runs through the loch. It was built by Thomas Telford in the early 1800s, so ships could skip the long way round the north of Scotland. The loch's a motorway, to the right sort of boat."], "left", "still")
    # story placeholders
    z.npc(id="strachan_boat", sprite="strachan", x=24, y=e(23) + 6, facing="down", move="still", script="strachan_loch_ness")
    script("loch_ness", "strachan_loch_ness", say("Director Strachan", "Placeholder: the story agent writes Strachan's survey-boat battle and Nessie's surfacing here."))
    _stand(z, 56, 37)
    z.npc(id="nessie_spot", sprite="creature:nessie", x=56, y=37, facing="down", move="still", script="nessie", hide_if="caught_nessie")
    script("loch_ness", "nessie", say("Nessie", "Placeholder: the story agent writes Nessie's surfacing and the legend encounter here."))
    # trainers
    trainer(z, "ness_angler", "Angler Calum", "Angler", "angler", [("heronarch", 72), ("spatelord", 73), ("kelpie", 72)],
            14, 23, "up", ["Ssh. I'm fishing for brown trout, and the monster's not biting. Neither is anything else."],
            "Aye, you've landed me. That's a first for the morning.", "A trout, a monster, a battle. Nothing bites when the tourists are shouting.", 2250)
    trainer(z, "ness_ghillie", "Ghillie Archie", "Ghillie", "ghillie", [("lochosprey", 73), ("rillotter", 73), ("peatmonarch", 72)],
            28, 19, "down", ["A ghillie looks after the river and the guests who fish it. The guests need more looking after than the river."],
            "Well. You'd make a fine ghillie. You've the patience of a heron.", "The secret of good fishing is to be there. And then to still be there.", 2300)
    trainer(z, "ness_birder", "Birdwatcher Morven", "Birdwatcher", "birdwatcher", [("lochosprey", 73), ("goldeneyrie", 74), ("heronarch", 73)],
            42, 19, "down", ["There's an osprey that fishes here. It dives from thirty metres, feet first. I've been trying to photograph it for three summers. I have 400 photos of the sky."],
            "Hm. You moved. I'd have liked to see the dive.", "Ospreys come back from West Africa every spring to the same nest. Think about that next time you complain about the A82.", 2330)
    trainer(z, "ness_warden", "Warden Fenella", "Warden", "warden_grunt", [("peatmonarch", 73), ("bufomire", 73), ("kelpie", 74)],
            49, 26, "up", ["Welcome to the Urquhart Heritage Experience! Entry to the ruin: eleven pounds. Entry to the bit I'm standing in: negotiable."],
            "I'll note that in the guest book. Under 'complaints'.", "The Enclosure says: if it's old, charge for it. If it's older, charge twice.", 2290)
    trainer(z, "ness_walker", "Hillwalker Iona", "Hillwalker", "hiker", [("heilan", 73), ("highlynx", 73), ("midgeswarm", 73)],
            33, 11, "right", ["I'm walking the Great Glen Way, 79 miles from Fort William to Inverness. I'm on day four. My feet have written a letter of complaint."],
            "Fair play. I'd say my feet need a break, but they're taking it already.", "The midges are the real defenders of the Highlands. They have never lost a battle.", 2270)
    z.d["edges"] = {"west": {"to": "great_glen", "offset": 0}, "north": {"to": "inverness", "offset": 0}}
    z.d["spawn"] = [30, 21]
    wild(z, [("heronarch", 72, 74, 14, {}), ("lochosprey", 72, 74, 12, {"time": ["dawn", "day"]}), ("peatmonarch", 72, 74, 12, {}),
             ("bufomire", 72, 74, 10, {"weather": ["drizzle", "downpour", "fog"]}), ("midgeswarm", 72, 74, 12, {"time": ["dawn", "dusk"]}),
             ("kelpie", 73, 74, 6, {"time": ["dusk", "night"], "weather": ["fog", "drizzle"]}), ("hushwing", 72, 74, 8, {"time": ["night"]}),
             ("hootlet", 72, 73, 6, {"time": ["night"]}), ("heilan", 73, 74, 6, {"time": ["day"]}), ("redbreast", 72, 73, 8, {"time": ["dawn", "day"]})])
    wild(z, [("rillotter", 72, 74, 22, {}), ("spatelord", 72, 74, 18, {}), ("heronarch", 72, 74, 14, {}), ("kelpie", 73, 74, 10, {"time": ["dusk", "night"]}),
             ("bradan", 72, 74, 16, {"weather": ["drizzle", "downpour"]}), ("lochosprey", 72, 74, 10, {"time": ["day"]}), ("minkshade", 72, 73, 10, {"time": ["night"]})], "water")
    finish(z)
    z.save(OUT + "/loch_ness.json")


def inverness(OUT):
    W, H = 64, 48
    z = Z("inverness", "Inverness", W, H, kind="town", region="scotland", music="town_scotland", weather={"drizzle": 30, "clear": 28, "sunshine": 16, "fog": 10, "downpour": 8, "gale": 8})
    z.d["stage"] = "town"; z.d["town_id"] = "inverness"
    z.legend["k"] = {"tile": "grass", "colour": "#7f8f52"}
    z.rect(0, 0, W, H, "k")
    z.border("T", 2, gaps=[(0, 20, 2, 3), (62, 24, 2, 3), (34, 46, 3, 2)])
    z.scatter(0, 0, W, H, "P", 30, 4, only="T")
    # the Moray Firth in the north and the River Ness flowing down to it
    z.rect(0, 0, W, 4, "$"); z.rect(2, 4, 60, 1, "w"); z.rect(2, 5, 60, 2, "s")
    z.rect(22, 4, 4, H - 4, "~")
    z.rect(19, 36, 10, 11, "~")
    z.rect(20, 7, 2, 29, ":"); z.rect(26, 7, 2, 29, ":")
    # roads
    z.rect(0, 20, 22, 3, "="); z.rect(26, 20, 21, 3, "="); z.rect(44, 20, 3, 7, "="); z.rect(44, 24, 19, 3, "=")
    z.rect(34, 22, 3, 26, "=")
    # the Ness Bridge, a footbridge, and the Ness Islands
    z.rect(22, 20, 4, 3, "|"); z.rect(22, 19, 4, 1, "W"); z.rect(22, 23, 4, 1, "W")
    z.rect(22, 12, 4, 1, "|")
    z.rect(21, 37, 3, 5, ","); z.rect(24, 41, 3, 5, ",")
    z.rect(21, 39, 3, 1, "#"); z.rect(19, 39, 2, 1, "|"); z.rect(24, 39, 5, 1, "|")
    z.prop("oak", 21, 37); z.prop("oak", 23, 41, variant=1); z.prop("birch", 25, 43); z.prop("birch", 26, 45, variant=2); z.prop("bench", 22, 38)
    for (x, y) in [(20, 11), (26, 11), (20, 13), (26, 13), (21, 19), (26, 19), (21, 24), (26, 24), (20, 32), (27, 32), (20, 8), (27, 8)]:
        z.prop("lamp_post", x, y)
    z.prop("bench", 20, 16); z.prop("bench", 27, 16); z.prop("bench", 27, 28); z.prop("bench", 20, 28)
    # the castle on its bluff (east bank)
    z.height(29, 6, 15, 9, 1)
    z.building(32, 7, 10, 5, "castle", "Inverness Castle")
    z.rect(36, 12, 2, 8, "#")
    z.prop("statue", 34, 13); z.prop("oak", 30, 13); z.prop("oak", 42, 13, variant=1); z.prop("planter", 40, 13)
    # shop and Sanctuary on the high street
    z.building(28, 16, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(30, 19, "inverness_shop", 4, 5, "up")
    z.building(38, 16, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(41, 19, "inverness_sanctuary", 5, 6, "up")
    # the Keeper arena: the ice rink
    z.building(48, 10, 11, 6, "cream_render", "Inverness Ice Rink", door=5)
    z.warp(53, 15, "inverness_rink", 8, 11, "up")
    z.rect(52, 16, 2, 8, "#"); z.rect(50, 16, 6, 1, ":")
    z.prop("planter", 50, 17); z.prop("planter", 55, 17); z.prop("lamp_post", 51, 17); z.prop("lamp_post", 54, 17)
    z.rect(46, 7, 14, 2, ":")
    z.sign(53, 18, "INVERNESS ICE RINK. Home to curling, skating and one Keeper who will not be hurried. Curling is 'the roaring game' because of the sound the granite stones make on the ice. Sweeping is allowed. Shouting is encouraged.")
    # Victorian Market and the square
    z.building(48, 28, 11, 3, "terrace", "Victorian Market")
    z.rect(46, 31, 15, 3, ":")
    for x in (48, 51, 54, 57):
        z.prop("market_stall", x, 32, variant=x % 3)
    z.prop("lamp_post", 47, 31); z.prop("lamp_post", 60, 31); z.prop("planter", 50, 34); z.prop("planter", 56, 34)
    z.sign(47, 33, "THE VICTORIAN MARKET. Built in 1870 and rebuilt after a fire in 1890, with a wrought iron roof that still keeps the rain off the tablet. Look for the tablet. Scottish tablet is sugar, butter and condensed milk, and it will try to buy you a new filling.")
    # the station
    station(z, 41, 36, 9, 4, "Inverness Station")
    z.rect(37, 38, 4, 1, ":"); z.rect(40, 39, 22, 1, "!")
    z.prop("bench", 43, 38); z.prop("lamp_post", 38, 37); z.prop("lamp_post", 50, 38)
    rail_guard(z, 48, 38, ["Inverness Station, the northern end of the line. The Kyle line goes west to the sea, the Far North line goes up to Thurso, and the sleeper train goes all the way to London. Most of these trains have a view you'll talk about for a week.",
                           "Hop aboard. The Wildlore rail runs to any town you have visited in Great Britain. Where to?"], "left")
    # houses and the cathedral
    for (x, y, w, h, st) in [(29, 28, 4, 3, "red_brick"), (29, 33, 4, 3, "white_render"), (38, 28, 5, 3, "stone"),
                             (38, 42, 6, 4, "terrace"), (46, 42, 6, 4, "red_brick"), (54, 42, 6, 4, "white_render"),
                             (3, 8, 8, 4, "terrace"), (13, 8, 6, 4, "white_render"), (3, 14, 6, 4, "stone"), (11, 14, 7, 4, "red_brick"),
                             (15, 24, 3, 4, "slate_cottage")]:
        z.building(x, y, w, h, st, show_label=False)
    z.building(3, 24, 9, 4, "cathedral", "St Andrew's Cathedral", door=4)
    z.rect(7, 28, 1, 2, "#")
    z.rect(3, 29, 15, 1, ":")
    # shinty field (west bank, south)
    z.rect(13, 23, 2, 9, "#")
    z.rect(3, 32, 15, 10, "k")
    z.rect(3, 32, 15, 1, "F"); z.rect(3, 41, 15, 1, "F"); z.rect(3, 32, 1, 10, "F"); z.rect(17, 32, 1, 10, "F")
    z.rect(13, 32, 2, 1, "#")
    z.prop("lamp_post", 5, 36); z.prop("lamp_post", 5, 38); z.prop("lamp_post", 15, 36); z.prop("lamp_post", 15, 38)
    z.rect(5, 30, 5, 2, ",")
    z.sign(12, 31, "THE CAMANACHD PITCH. Shinty is the Highland game, a cousin of Irish hurling, played with a stick called a caman (the same word as 'crooked') and a ball. Two teams of twelve. Everyone swings. Everyone pretends it was an accident.")
    # tall grass, parks, trees
    z.rect(29, 41, 5, 5, ",")
    scatter_props(z, "oak", 2, 8, 17, 14, 7, 20, avoid=("k",))
    scatter_props(z, "birch", 28, 24, 6, 18, 6, 21, avoid=("k",))
    scatter_props(z, "bush", 2, 7, 60, 38, 22, 22, avoid=("k",))
    z.prop("boat", 8, 2, variant=1); z.prop("boat", 40, 2, variant=1); z.prop("buoy", 15, 3); z.prop("buoy", 52, 3, variant=1); z.prop("buoy", 28, 2)
    z.sign(15, 7, "THE MORAY FIRTH. The sea off Inverness is home to Britain's biggest pod of bottlenose dolphins, about 200 of them. They're the largest of their kind in the world, and they jump for fun. The ones at Chanonry Point do it at high tide, in front of a crowd with cameras.")
    z.sign(23, 11, "THE RIVER NESS (Abhainn Nis). Only about 10 km long, which makes it one of the shortest rivers in Britain, but it carries all of Loch Ness down to the sea. The town's Gaelic name, Inbhir Nis, means 'mouth of the Ness'.")
    z.sign(22, 36, "THE NESS ISLANDS. A park on a string of river islands, linked by Victorian footbridges since 1853. The trees are huge. The bridges wobble gently, as a hint.")
    z.sign(34, 14, "INVERNESS CASTLE. The pink sandstone building you see was built in the 1830s as a courthouse and jail, on a site that has had a fortress for nearly a thousand years. The statue is Flora MacDonald, who helped Prince Charles Edward Stuart escape in 1746.")
    z.sign(10, 29, "ST ANDREW'S CATHEDRAL. Built in the 1860s, it was the first new cathedral in Britain since the Reformation. The two towers were added later, which is why one of them is a bit shy.")
    z.sign(30, 21, "INBHIR NIS · INVERNESS. 'Capital of the Highlands' since 565 AD, when St Columba came to visit the Pictish king Brude and had a word about a monster on the way. Fàilte.")
    # NPCs
    chat(z, "verger", "villager_5", 8, 31, "Cathedral Verger",
         ["St Andrew's was built in the 1860s with a red stone front and two spires. It has a great ring of bells, a labyrinth path in the garden and a visitor who once asked if the cathedral was real. It is.",
          "Please keep your voice down, we're a little shy. The pigeons, however, are not."], "down", "still")
    chat(z, "market_trader", "villager_2", 51, 33, "Market Trader",
         ["Tablet, shortbread, fudge, and a Highland coo made of wool. Not that kind of coo, the other one. Well, also that kind.",
          "The Victorian Market's been selling since 1870. The roof's been up longer than I have, and it's the more waterproof of the two of us."], "up", "wander")
    chat(z, "dolphin_watcher", "birdwatcher", 18, 7, "Dolphin Watcher",
         ["The dolphins come in with the tide, so I check the tide tables like other people check the football results. High water at Chanonry is the kick-off.",
          "Our dolphins are bottlenose. They're the biggest in the world, because the Firth is cold, and a bigger body keeps the heat in. They are, in other words, wearing a very good jumper."], "right", "still")
    chat(z, "castle_walker", "villager_6", 33, 14, "Statue Admirer",
         ["That's Flora MacDonald. She helped the Prince escape from Skye in a small boat, disguised as her maid. History has made a lot of her. The maid costume has got a lot of press, too.",
          "Mind, the castle's a courthouse these days. Everyone looks up at it nervously. It's the sandstone. It looks like it knows what you did."], "down", "wander")
    chat(z, "ceilidh_dad", "farmer", 56, 22, "Local Dad",
         ["Fàilte to Inverness! We say 'Inbhir Nis' in Gaelic. It means 'mouth of the Ness', which tells you where to look if you're lost: downhill, towards the sea.",
          "The Keeper's at the ice rink. Isla's a curler. If she says 'hurry hard', do as you're told. She's got a stone and a broom, and she knows how to use both."], "down", "still")
    trainer(z, "inv_piper", "Piper Rory", "Piper", "piper", [("heilan", 74), ("goldeneyrie", 74), ("ptarmigan", 74)],
            24, 20, "down", ["A piper on a bridge! Tradition. Also, the acoustics are lovely, and it's much harder for anyone to ask me to stop."],
            "Och, a clean finish. I'll play you off.", "The great Highland bagpipe has nine notes. It makes up for the lack with volume.", 2400)
    trainer(z, "inv_shinty", "Shinty Player Eilidh", "Shinty Player", "shinty_player", [("highlynx", 74), ("heilan", 74), ("thistlord", 74)],
            14, 34, "up", ["No hurling jokes! It's shinty. Same sort of idea, different sort of stick, a lot more shouting. Come on."],
            "Good camanachd! You'd fit on our team. We'd put you in goal.", "In shinty, you can hit the ball in the air. It's the only sport where the ball and the head share the same space regularly.", 2380)
    z.d["edges"] = {"west": {"to": "skye", "offset": 0}, "east": {"to": "cairngorms", "offset": 0}, "south": {"to": "loch_ness", "offset": 0}}
    z.d["spawn"] = [35, 23]
    wild(z, [("brownie", 74, 74, 14, {"time": ["dusk", "night"]}), ("redbreast", 73, 74, 14, {"time": ["dawn", "day"]}), ("warrender", 73, 74, 12, {}),
             ("strutcoo", 73, 74, 12, {"time": ["day", "dawn"]}), ("hootlet", 73, 74, 8, {"time": ["night"]}), ("flittermouse", 73, 74, 8, {"time": ["night"]}),
             ("pierlord", 73, 74, 10, {"time": ["day", "dusk"]}), ("lochosprey", 74, 74, 8, {"time": ["day"]}), ("rillotter", 73, 74, 6, {"weather": ["drizzle", "downpour"]})])
    wild(z, [("rillotter", 73, 74, 24, {}), ("pierlord", 73, 74, 18, {}), ("bradan", 73, 74, 18, {"weather": ["drizzle", "downpour"]}), ("spatelord", 73, 74, 16, {}),
             ("bayrunner", 74, 74, 8, {"time": ["day"]}), ("heronarch", 73, 74, 12, {})], "water")
    finish(z)
    z.save(OUT + "/inverness.json")
    sanctuary(OUT, "inverness", "Inverness", (41, 20))
    shop(OUT, "inverness", "Inverness", (30, 20))
    nurse("inverness", ["Fàilte to the Inverness Sanctuary. That's 'welcome', so you've learned something. Pop your team on the counter and have a seat, there's a kettle on.",
                        "Och, they've had a day. Sit down, take a tablet, and watch the kettle. It's a very slow kettle. It's very good.",
                        "All done. Mòran taing, that's 'many thanks'. Wrap up warm out there, it's wetter than it looks. Even when it looks wet.",
                        "The Ark terminal. It's powered by tea and a hamster wheel that nobody has volunteered to explain.",
                        "Dè a tha thu ag iarraidh? That's 'what do you want?'. Take your time. We're not going anywhere. It's raining."])
    shopkeeper("inverness", "Fàilte! Tablet, shortbread, a flask and a wee map. If you're after a monster, I'd bring a bigger bag.",
               "Mar sin leibh! That's 'goodbye'. Watch for the midges, they do the checkout.")


def rink(OUT):
    a = Z("inverness_rink", "Inverness Ice Rink", 17, 14, fill="|", kind="interior", region="", music="battle_keeper", weather={})
    a.d["stage"] = "town"
    a.legend["i"] = {"tile": "floor_tile", "colour": "#d6eaf6"}
    a.legend["j"] = {"tile": "floor_tile", "colour": "#e8f3fb"}
    a.border("x", 1)
    a.rect(2, 2, 13, 9, "i")
    for x in range(2, 15):
        for y in range(2, 11):
            if (x + y) % 5 == 0:
                a.set(x, y, "j")
    a.rect(1, 1, 15, 1, "|"); a.rect(2, 11, 13, 1, "|"); a.rect(7, 11, 3, 1, "|")
    a.set(8, 12, "D"); a.warp(8, 12, "inverness", 53, 16, "down")
    a.prop("bench", 3, 11); a.prop("bench", 13, 11); a.prop("planter", 1, 2); a.prop("planter", 15, 2)
    a.prop("bollard", 4, 4); a.prop("bollard", 12, 4); a.prop("bollard", 4, 8); a.prop("bollard", 12, 8)   # curling stones
    a.prop("lamp_post", 7, 2); a.prop("lamp_post", 9, 2)
    a.npc(id="keeper_isla", sprite="keeper_isla", x=8, y=3, facing="down", move="still", script="keeper_isla")
    script("inverness_rink", "keeper_isla", say("Keeper Isla", "Placeholder: the story agent rewrites this Keeper battle script."))
    trainer(a, "rink_curler", "Curler Fergus", "Curler", "student", [("ermine", 74), ("heilan", 74), ("snowbunting", 74)],
            11, 7, "left", ["Hurry hard! Hurry hard! ... Sorry, that's not for you. That's for the stone. Though you could hurry too."],
            "Good shot. That was a draw to the button. Or a battle. I forget.", "The curling stones are made of granite from Ailsa Craig, a lonely island off the Ayrshire coast. They weigh about 20 kg.", 2420)
    trainer(a, "rink_skater", "Skater Mhairi", "Skater", "jogger", [("polartern", 75), ("ptarmigan", 74), ("haarling", 74)],
            4, 6, "right", ["Triple axel? I can do a triple. It's an axel in intent, at least. Let's see how you spin."],
            "Slippery! I'm going to lie down on the ice for a minute.", "I've fallen over more times than you've had hot dinners. And I get up each time. Eventually.", 2440)
    a.d["spawn"] = [8, 11]
    a.save(OUT + "/inverness_rink.json")
