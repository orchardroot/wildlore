# plan 5 group C, part 3: cairngorms (+cairngorm_cave), aberdeen (granite city, ferry), kirkwall (Orkney, ferry back).
from ie_common import *
from wcommon import _stand
import math


def build(OUT):
    cairngorms(OUT)
    cave(OUT)
    aberdeen(OUT)
    kirkwall(OUT)


def cairngorms(OUT):
    W, H = 76, 50
    z = Z("cairngorms", "Cairngorms", W, H, kind="route", region="scotland", music="route_highlands",
          weather={"frost": 28, "fog": 16, "drizzle": 12, "clear": 20, "sunshine": 12, "gale": 12})
    z.d["stage"] = "mountain"
    z.legend["k"] = {"tile": "grass", "colour": "#6f8a52"}
    z.legend["n"] = {"tile": "grass", "colour": "#eef3f8"}                       # snow
    z.legend["N"] = {"tile": "tall_grass", "colour": "#d5e0ea", "prop": "none"}  # drifted snow
    z.legend["h"] = {"tile": "tall_grass", "colour": "#7a5c6a", "prop": "heather"}
    z.legend["c"] = {"tile": "door", "colour": "#16161b"}                        # the cave mouth
    z.rect(0, 0, W, H, "k")
    z.border("P", 2, gaps=[(0, 24, 2, 3), (74, 24, 2, 3)])
    hills(z, [(40, 22, 4, 24), (20, 40, 3, 10), (60, 38, 3, 10), (30, 8, 2, 7)])
    # tracks
    z.rect(0, 24, 76, 3, "#")
    z.rect(36, 9, 2, 15, "#")
    z.rect(33, 27, 2, 10, "#"); z.rect(33, 36, 3, 1, "#")
    z.rect(54, 16, 2, 8, "#"); z.rect(11, 14, 2, 10, "#")
    # the cave mouth
    z.rect(32, 3, 9, 5, "R"); z.set(36, 7, "c")
    z.prop("rock", 35, 8); z.prop("rock", 38, 8, variant=1)
    # snow up on the plateau
    for y in range(2, H - 2):
        for x in range(2, W - 2):
            if z.g[y][x] == "k" and (z.hg[y][x] >= 2 or x >= 30):
                z.g[y][x] = "n"
    # Loch Morlich at the foot
    blob(z, 16, 41, 9, 6, "s", only="kn", seed=21, jitter=0.2)
    blob(z, 16, 41, 8, 5, "w", only="kns", seed=22, jitter=0.2)
    blob(z, 16, 41, 6, 3, "~", only="kwns", seed=23, jitter=0.2)
    # snow drifts (tall) and heather/bracken in the pinewood
    blob(z, 44, 12, 7, 3, "N", only="n", seed=31, jitter=0.4)
    blob(z, 48, 36, 5, 3, "N", only="n", seed=32, jitter=0.4)
    blob(z, 26, 20, 4, 3, "N", only="n", seed=33, jitter=0.4)
    blob(z, 62, 28, 5, 3, "N", only="n", seed=34, jitter=0.4)
    blob(z, 66, 10, 5, 3, "N", only="n", seed=35, jitter=0.4)
    blob(z, 8, 18, 4, 3, "h", only="k", seed=36, jitter=0.4)
    blob(z, 6, 32, 4, 4, ",", only="k", seed=37)
    blob(z, 20, 12, 5, 3, ",", only="kn", seed=38)
    blob(z, 24, 30, 4, 3, ",", only="kn", seed=39)
    # bog patches, and the peat hollow only Bog-cross can reach
    blob(z, 52, 30, 3, 2, "*", only="nN", seed=41)
    blob(z, 70, 17, 3, 2, "*", only="nN", seed=43)
    z.rect(55, 33, 16, 13, "*")
    z.rect(57, 35, 12, 9, "n")
    z.rect(60, 38, 3, 2, "N")
    z.prop("standing_stone", 58, 36, variant=1); z.prop("rock", 67, 36); z.prop("rock", 66, 43, variant=2)
    z.npc(id="peat_hermit", sprite="farmer", x=64, y=40, facing="down", move="still", script="peat_hermit")
    script("cairngorms", "peat_hermit", [
        {"do": "say", "who": "Peat Hermit", "text": "Och! You crossed the bog? In those boots? Come in, come in. I haven't had a visitor since the last ice age."},
        {"do": "if", "flag": "cairn_hermit_gift",
         "then": [{"do": "say", "who": "Peat Hermit", "text": "I gave you the cranachan already. It's whisky-free, I'm assured. Mostly raspberries. Mind how you go back across."}],
         "else": [{"do": "say", "who": "Peat Hermit", "text": "Take this. It's cranachan, toasted oats, cream and raspberries. I make it with a spoon, a bowl and no sense of urgency."},
                  {"do": "give_item", "item": "cranachan", "n": 2},
                  {"do": "set", "flag": "cairn_hermit_gift"}]}])
    # buildings: ski centre, reindeer centre, bothy
    z.building(56, 12, 8, 4, "white_render", "Ski Centre")
    z.building(26, 33, 6, 4, "slate_cottage", "Reindeer Centre")
    z.building(9, 10, 5, 4, "slate_cottage", "Bothy")
    z.rect(56, 16, 8, 1, ":"); z.prop("lamp_post", 56, 17); z.prop("lamp_post", 63, 17); z.prop("bench", 60, 17)
    # reindeer paddock
    z.rect(35, 33, 12, 1, "F"); z.rect(35, 41, 12, 1, "F"); z.rect(35, 33, 1, 9, "F"); z.rect(46, 33, 1, 9, "F")
    z.set(35, 36, "#")
    z.prop("bench", 32, 38); z.prop("planter", 28, 38)
    for i, (x, y) in enumerate([(38, 36), (41, 35), (43, 38), (39, 39), (44, 35)]):
        _stand(z, x, y)
        z.npc(id="reindeer_%d" % i, sprite="creature:reindeer", x=x, y=y, facing="down", move="wander", script="reindeer")
    for i, (x, y) in enumerate([(47, 18), (28, 14)]):
        _stand(z, x, y)
        z.npc(id="reindeer_out_%d" % i, sprite="creature:reindeer", x=x, y=y, facing="down", move="wander", script="reindeer")
    script("cairngorms", "reindeer", say("Reindeer", "It sniffs your sleeve for lichen, finds none, and goes back to being majestic. A very big pair of antlers sways, gently."))
    scatter_props(z, "pine", 3, 3, 28, 44, 30, 51, avoid=("k",))
    scatter_props(z, "pine", 30, 3, 44, 44, 12, 52, avoid=("n",))
    scatter_props(z, "birch", 3, 3, 28, 44, 10, 53, avoid=("k",))
    scatter_props(z, "rock", 24, 3, 50, 44, 18, 54, avoid=("n",))
    z.prop("rock", 40, 30); z.prop("rock", 41, 30, variant=1)
    # signs
    z.sign(5, 22, "THE CAIRNGORMS (Am Monadh Ruadh). The largest national park in Britain, about 4,500 square kilometres, with five of the six highest mountains in the country. The plateau up here is the closest thing Britain has to the Arctic. Wrap up. The weather is a hobby.")
    z.sign(32, 34, "THE REINDEER CENTRE. Britain's only free-ranging herd of reindeer. A Sami herder, Mikel Utsi, brought them here in 1952. About 150 live on the hills today, and they come down to the paddock to say hello and ask for lichen. Antlers fall off every year, so the herd is mostly Santa's team: the ones still wearing antlers in December are the females.")
    z.sign(38, 10, "CAIRN GORM. Gaelic for 'blue cairn' or 'blue mountain', a granite plateau up to 1,245 m. The cave in the crags is closed to visitors without a lamp. Seriously. Take a lamp. The sign says so, and the sign has never been wrong.")
    z.sign(26, 25, "THE OLD CALEDONIAN PINEWOOD. A scrap of the great forest that covered Scotland long ago. Capercaillie, crested tits and red squirrels live here. In spring the male capercaillie performs a display dance on the forest floor. It's a very proud and very silly bird.")
    z.sign(53, 27, "PEAT BOG. The black pools are deep and sticky. Don't step in, or you'll need a rescue and a new pair of boots. If you have a way to walk on bog, there's a dry hollow to the south-east with a view.")
    # chatty people
    chat(z, "reindeer_herder", "farmer", 31, 38, "Reindeer Herder",
         ["Each reindeer has a name and a rude personality. Frost, Bramble, Bagpipes. That one's called Dolly. She's not very polite.",
          "Reindeer hooves click when they walk, a sound like castanets. It helps the herd stay together in a blizzard. The best part of my job is the herd. The worst bit is the blizzards."], "right", "still")
    chat(z, "ski_instructor", "jogger", 59, 18, "Ski Instructor",
         ["Scotland has skiing! The snow isn't always there, but when it is, it's glorious. And when it isn't, I teach people to fall over in a dignified way.",
          "Cairn Gorm has the UK's highest funicular railway, running up to near the summit. We love it dearly. It has also been closed for a long time. The affection is constant, the railway less so."], "down", "still")
    chat(z, "rescue_volunteer", "hiker", 40, 22, "Mountain Rescue",
         ["Mountain Rescue here is volunteers, who go out in all weathers for anyone who needs them. We are not paid and not grateful for puns about 'rocks'.",
          "The golden rules: tell someone where you're going, carry a map, a compass and a head torch. And never trust a cloud that looks friendly."], "down", "still")
    chat(z, "snow_kid", "student", 45, 29, "Snowball Kid",
         ["I made a snowman! He's got a pine cone for a nose and a wooden spoon for a scepter. I call him Sir Ben Macdui. He's the second-highest snowman in Britain.",
          "Ben Macdui's the second highest mountain in the UK, and legend says there's a tall grey man up there. Not a snowman. A 'Big Grey Man'. People hear his footsteps. I hear mine. It's the same thing, probably."], "left", "wander")
    # trainers
    trainer(z, "cairn_walker", "Hillwalker Struan", "Hillwalker", "hiker", [("ptarmigan", 76), ("ermine", 76), ("heilan", 76)],
            14, 23, "down", ["Up to the plateau in two hours, back down in one. Mostly because I fall over. Come on, let's see your footwork."],
            "That was brisk. Like the wind. Cold as the wind.", "Always carry a map. Phones die in the cold. Mine died when I looked at the weather.", 2640)
    trainer(z, "cairn_ghillie", "Ghillie Alasdair", "Ghillie", "ghillie", [("capercaillie", 76), ("highlynx", 77), ("heilan", 76)],
            22, 27, "up", ["Red deer, capercaillie, wildcat. I look after the estate and the people who aren't looking where they're going."],
            "Aye, you've the eye. Maybe the nose too.", "The estate and I have an understanding: it makes me wet and I make it wet. We are even.", 2650)
    trainer(z, "cairn_birder", "Birdwatcher Catriona", "Birdwatcher", "birdwatcher", [("snowbunting", 77), ("ptarmigan", 77), ("goldeneyrie", 77)],
            31, 22, "down", ["Ptarmigan! A grouse that turns white in winter. Snow bunting! A bunting that thinks it's a snowflake. I'm on a list. It's long."],
            "My list is a little shorter. And a little less dignified.", "The ptarmigan changes into three different outfits a year. Brown in summer, white in winter and sort of patchy in-between.", 2670)
    trainer(z, "cairn_walker2", "Hillwalker Murdo", "Hillwalker", "hiker", [("ermine", 77), ("calfrein", 76), ("reindeer", 77)],
            48, 27, "up", ["Munros! There are 282 mountains over 3,000 feet in Scotland, and I'm on 190. I'm going to bag them all. When my knees let me."],
            "A fine hand. You'd make a decent Munro-bagger.", "Sir Hugh Munro made the list in 1891. He never climbed them all himself. He ran out of time. We have that in common.", 2660)
    trainer(z, "cairn_warden", "Warden Hector", "Warden", "warden_grunt", [("stoatlet", 76), ("highlynx", 77), ("capercaillie", 77)],
            36, 15, "down", ["Welcome to the Cairngorm Summit Experience! The lift is closed. The cafe is closed. The view is also closed. Please buy a postcard."],
            "I'll note this in the visitor survey. Under 'experience'.", "The Enclosure says: if it's a mountain, it needs a gift shop. If it's a gift shop, it needs a mountain.", 2680)
    z.d["edges"] = {"west": {"to": "inverness", "offset": 0}, "east": {"to": "aberdeen", "offset": 0}}
    z.d["spawn"] = [4, 25]
    wild(z, [("calfrein", 76, 77, 12, {}), ("buntling", 76, 77, 12, {"time": ["day", "dawn"]}), ("caperling", 76, 77, 12, {"time": ["dawn", "dusk"]}),
             ("stoatlet", 76, 77, 12, {}), ("ptarmigan", 77, 78, 10, {"weather": ["frost", "fog"]}), ("snowbunting", 77, 78, 8, {"time": ["day"]}),
             ("heilan", 77, 78, 8, {}), ("capercaillie", 77, 78, 6, {"time": ["dawn"]}), ("ermine", 77, 78, 6, {"weather": ["frost"]}),
             ("goldeneyrie", 77, 78, 6, {"time": ["day"]}), ("highlynx", 77, 78, 6, {"time": ["night", "dusk"]}), ("reindeer", 78, 78, 3, {"weather": ["frost"]})])
    wild(z, [("rillotter", 76, 78, 20, {}), ("spatelord", 76, 78, 16, {}), ("lochosprey", 76, 78, 14, {"time": ["day"]}), ("bradan", 76, 78, 16, {"weather": ["drizzle", "downpour"]}),
             ("heronarch", 76, 78, 14, {}), ("kelpie", 77, 78, 8, {"time": ["night"]})], "water")
    finish(z)
    z.save(OUT + "/cairngorms.json")


def cave(OUT):
    W, H = 26, 22
    z = Z("cairngorm_cave", "Cairngorm Cave", W, H, fill="x", kind="route", region="scotland", music="route_mountain", weather={})
    z.d["stage"] = "cave"
    z.d["dark"] = True
    z.legend["e"] = {"tile": "path", "colour": "#565d69"}
    z.legend["m"] = {"tile": "tall_grass", "colour": "#3f565a", "prop": "none"}
    z.rect(12, 15, 3, 6, "e"); z.rect(5, 10, 16, 5, "e"); z.rect(12, 6, 3, 4, "e"); z.rect(6, 1, 14, 6, "e")
    z.rect(2, 11, 3, 3, "e"); z.rect(21, 11, 3, 3, "e"); z.rect(4, 2, 2, 3, "e")
    z.rect(7, 11, 4, 3, "m"); z.rect(16, 11, 4, 3, "m"); z.rect(8, 2, 4, 3, "m"); z.rect(15, 3, 4, 3, "m")
    z.set(13, 20, "D")
    z.warp(13, 20, "cairngorms", 36, 8, "down")
    for (x, y, v) in [(6, 10, 0), (20, 10, 1), (9, 14, 2), (18, 14, 0), (7, 1, 1), (19, 1, 2), (3, 11, 0), (23, 13, 1), (12, 16, 2), (14, 18, 0)]:
        z.prop("rock", x, y, variant=v)
    for (x, y) in [(10, 6), (16, 6), (6, 5), (20, 5)]:
        z.prop("standing_stone", x, y, variant=(x + y) % 3)
    z.sign(12, 19, "CAIRN GORM CAVE. Cold, dark and very old. A lamp helps. Without one, keep one hand on the wall and the other on your sense of humour. The way out is behind you.")
    z.sign(13, 9, "THE INNER CHAMBER. The walls here are covered in tiny crystals that glitter in a lamp's beam. Without a lamp, you will have to take their word for it.")
    z.npc(id="cave_ranger", sprite="hiker", x=13, y=3, facing="down", move="still", script="cave_ranger")
    script("cairngorm_cave", "cave_ranger", [
        {"do": "say", "who": "Old Ranger", "text": "Ha! A visitor. I've been down here since breakfast looking for a lost glove. It's a very good glove. It had a pocket."},
        {"do": "if", "flag": "cave_ranger_gift",
         "then": [{"do": "say", "who": "Old Ranger", "text": "The tonic's yours, the glove's mine. Keep to the wall on the way out, and give my regards to the daylight."}],
         "else": [{"do": "say", "who": "Old Ranger", "text": "Here, take these. Irn tonic, for what ails you, and a tablet for the road. Sweet as a rock, and about as soft."},
                  {"do": "give_item", "item": "irn_tonic", "n": 2},
                  {"do": "give_item", "item": "tablet", "n": 3},
                  {"do": "set", "flag": "cave_ranger_gift"}]}])
    z.d["spawn"] = [13, 18]
    wild(z, [("ermine", 77, 78, 14, {}), ("lanternis", 77, 78, 12, {}), ("flittermouse", 77, 78, 14, {"time": ["night", "dusk"]}), ("highlynx", 77, 78, 8, {}),
             ("hushwing", 77, 78, 10, {}), ("gwyllgi", 78, 78, 5, {"time": ["night"]}), ("snowhare", 77, 78, 12, {}), ("snowbunting", 77, 78, 8, {}),
             ("stoatlet", 77, 77, 8, {})])
    finish(z)
    z.save(OUT + "/cairngorm_cave.json")


def aberdeen(OUT):
    W, H = 68, 52
    z = Z("aberdeen", "Aberdeen", W, H, kind="town", region="scotland", music="town_scotland",
          weather={"fog": 24, "drizzle": 26, "clear": 20, "gale": 12, "downpour": 8, "sunshine": 10})
    z.d["stage"] = "docks"; z.d["town_id"] = "aberdeen"
    z.legend["g"] = {"tile": "grass", "colour": "#7a9a58"}
    z.rect(0, 0, W, H, "g")
    z.border("T", 2, gaps=[(0, 24, 2, 3)])
    z.scatter(0, 0, W, H, "P", 24, 8, only="T")
    # the North Sea, the beach and the harbour
    z.rect(56, 0, 12, H, "$")
    z.rect(52, 0, 4, 34, "s"); z.rect(55, 0, 1, 34, "w")
    z.rect(48, 2, 4, 15, ",")
    z.rect(46, 34, 10, 12, ":"); z.rect(50, 46, 6, 6, "$")
    z.rect(47, 30, 8, 4, "s")
    z.rect(55, 35, 8, 3, ":")
    z.d["ferry"] = {"x": 62, "y": 36, "route": "aberdeen_kirkwall"}
    z.prop("boat", 63, 33, variant=0)
    z.prop("bollard", 56, 35); z.prop("bollard", 56, 37); z.prop("bollard", 59, 35); z.prop("bollard", 59, 37)
    z.prop("boat", 58, 41, variant=1); z.prop("boat", 61, 44, variant=1); z.prop("boat", 66, 30, variant=1); z.prop("buoy", 60, 40); z.prop("buoy", 64, 41, variant=1); z.prop("buoy", 58, 28)
    z.rect(55, 46, 6, 2, "$")
    z.prop("lighthouse", 56, 47)
    # Union Street and the grid
    z.rect(0, 24, 2, 3, "="); z.rect(2, 23, 46, 5, "=")
    z.rect(2, 32, 44, 1, ":"); z.rect(0, 29, 0, 0, "=")
    z.rect(23, 5, 3, 18, "="); z.rect(23, 28, 3, 15, "=")
    z.rect(36, 5, 3, 18, "="); z.rect(36, 28, 3, 4, "=")
    z.rect(46, 23, 8, 12, ":")
    # granite north row
    for (x, y, w, h, lab) in [(3, 18, 6, 5, None), (10, 17, 8, 6, None), (27, 19, 8, 4, None), (40, 18, 6, 5, None)]:
        z.building(x, y, w, h, "stone", lab, show_label=bool(lab))
    z.building(26, 8, 16, 7, "stone", "Marischal College")
    z.building(5, 6, 8, 5, "stone", "Town House")
    z.building(14, 6, 7, 5, "castle", "Provost Skene's House", show_label=False)
    z.rect(6, 11, 3, 6, ":"); z.rect(26, 15, 11, 3, ":")
    # south row: Sanctuary, shop, granite
    z.building(10, 28, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(13, 31, "aberdeen_sanctuary", 5, 6, "up")
    z.building(18, 28, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(20, 31, "aberdeen_shop", 4, 5, "up")
    z.building(26, 28, 7, 4, "stone", show_label=False)
    z.building(39, 28, 6, 4, "stone", show_label=False)
    z.building(6, 34, 6, 4, "stone", show_label=False)
    z.building(13, 34, 8, 4, "stone", show_label=False)
    z.building(26, 34, 9, 4, "stone", "Maritime Museum")
    z.building(37, 34, 6, 4, "stone", show_label=False)
    # the station
    z.rect(3, 33, 2, 10, ":")
    station(z, 6, 40, 10, 5, "Aberdeen Station")
    z.rect(3, 42, 3, 1, ":"); z.rect(4, 43, 42, 1, "!")
    z.prop("bench", 8, 42); z.prop("lamp_post", 12, 42)
    rail_guard(z, 14, 42, ["Aberdeen Station. It's the most northerly stop on the east coast main line, and the platform is exactly as exposed as you'd expect.",
                           "Hop aboard. The Wildlore rail runs to any town you have visited in Great Britain. Where to?"], "left")
    # Footdee, the fishing huts
    for i, (x, y) in enumerate([(41, 39), (45, 38), (29, 39), (33, 39)]):
        z.building(x, y, 3, 3, ["white_render", "cream_render", "slate_cottage"][i % 3], show_label=False)
    # parks
    z.rect(4, 2, 18, 3, ",")
    z.rect(30, 2, 5, 3, ",")
    z.rect(39, 44, 2, 1, ",")
    scatter_props(z, "birch", 2, 2, 22, 4, 6, 61, avoid=("g",))
    scatter_props(z, "oak", 2, 2, 46, 48, 10, 62, avoid=("g",))
    scatter_props(z, "bush", 2, 2, 46, 48, 20, 63, avoid=("g",))
    for (x, y) in [(5, 23), (12, 23), (20, 23), (30, 23), (42, 23), (5, 28), (31, 27), (45, 27)]:
        z.prop("lamp_post", x, y)
    z.prop("planter", 24, 22); z.prop("planter", 24, 28); z.prop("bench", 40, 27); z.prop("bench", 8, 27)
    z.prop("statue", 24, 16)
    z.prop("market_stall", 48, 24); z.prop("market_stall", 51, 24); z.prop("market_stall", 48, 28); z.prop("market_stall", 51, 28)
    # signs
    z.sign(1, 22, "ABERDEEN (Obar Dheathain). The Granite City. 'Obar Dheathain' means 'mouth of the Don'. The big grey buildings are built of local granite that sparkles in the sun, thanks to the mica. It sparkles for about an hour a year.")
    z.sign(28, 16, "MARISCHAL COLLEGE. The second largest granite building in the world, finished in 1906 with a spiky pinnacled front. It cost a fortune and looks it. It's now the city council offices, so you can walk in and pay your parking fine under a Gothic ceiling.")
    z.sign(52, 33, "ABERDEEN HARBOUR. Founded before 1136, it's Scotland's oldest business. The ferries to Orkney and Shetland sail from here, and so do the supply boats for the oil rigs. Look out for the dolphins at Torry Battery, and the pungent smell of the fish market.")
    z.sign(33, 33, "THE MARITIME MUSEUM. A whole offshore oil rig in a hall, a model of a clipper ship called the Thermopylae and a very sensible hat.")
    z.sign(38, 21, "UNION STREET. A mile of granite built on a bridge over a ravine, so the shops on the street don't know that underneath them there's a valley. Hope the foundations don't, either.")
    z.sign(44, 38, "FOOTDEE (Fittie). A tiny seaside village of fishermen's cottages arranged in squares, with their backs to the North Sea gales. They've been rebuilt many times, and are still lovely.")
    # chatty people
    z.npc(id="abdn_sailor", sprite="sailor", x=61, y=36, facing="right", move="still", script="sailor")
    script("aberdeen", "sailor", say("Sailor", "Orkney, is it? The Hjaltland Gull sails six hours north, and the gannets are free entertainment. Bring a jumper. Bring two.") + [{"do": "ferry", "route": "aberdeen_kirkwall"}])
    chat(z, "granite_mason", "farmer", 15, 25, "Granite Mason",
         ["Aberdeen granite is grey, and hard as an argument. They built half of London's bridges from it, and the Terrace at the Houses of Parliament, and all our own grand buildings.",
          "It sparkles when it's wet. Which, in Aberdeen, is Tuesday to Monday. We're not complaining. It sparkles more."], "down", "still")
    chat(z, "doric_speaker", "villager_2", 30, 25, "Aberdonian",
         ["'Fit like?' That's how we say 'how are you?' in Doric, the Aberdeen dialect. You answer, 'Nae bad, fit like yersel?', which is 'not bad, how are you?'.",
          "A 'quine' is a girl and a 'loon' is a boy. 'Fit' means 'what', 'far' means 'where' and 'foo' means 'how'. It's not hard, just very fast."], "right", "wander")
    chat(z, "harbour_master", "villager_6", 50, 36, "Harbour Master",
         ["It's the oldest business in Scotland, this harbour. We've shipped granite, herring, whisky and the occasional pony. Nowadays, it's supply boats and cruise ships.",
          "Haar is what we call the sea fog that rolls in from the North Sea. A cold, wet blanket you can't see through. We love it, a bit. It's moody."], "down", "still")
    chat(z, "oil_engineer", "student", 44, 33, "Oil Engineer",
         ["Aberdeen's the oil capital of Europe. Oil was found under the North Sea in 1969, and the city's been busy ever since. I work on the rigs two weeks on, two weeks off.",
          "Two weeks offshore, and you start talking to the seagulls. They're surprisingly good listeners. I recommend them over most of my colleagues."], "left", "wander")
    trainer(z, "abdn_fisher", "Fisher Duncan", "Fisher", "angler", [("clownbill", 78), ("haarling", 78), ("polartern", 78)],
            50, 41, "left", ["Herring, haddock and a fine bit of cod, straight off the boat. The seagulls nick the cod, I nick the herring, and the harbour master nicks us both."],
            "Och, away. You're a good catch.", "A trawler goes out for five days and comes back with six tonnes of fish and a very bad mood.", 2760)
    trainer(z, "abdn_piper", "Piper Fiona", "Piper", "piper", [("heilan", 78), ("goldeneyrie", 78), ("capercaillie", 78)],
            34, 26, "up", ["Union Street's the best place to play. The granite bounces the sound back. I'm told I can be heard in Dundee. By request, that is."],
            "I'll play you a lament. For me.", "The bagpipe is a bag, a chanter and three drones. It's easy to take apart and impossible to put back together.", 2780)
    z.d["edges"] = {"west": {"to": "cairngorms", "offset": 0}}
    z.d["spawn"] = [3, 25]
    wild(z, [("haarling", 78, 78, 14, {"weather": ["fog", "drizzle"]}), ("pierlord", 78, 78, 14, {"time": ["day", "dusk"]}), ("clownbill", 78, 78, 10, {"time": ["day"]}),
             ("polartern", 78, 78, 10, {"weather": ["gale", "fog"]}), ("sootwing", 78, 78, 8, {"time": ["night"]}), ("redbreast", 78, 78, 10, {"time": ["dawn", "day"]}),
             ("binfox", 78, 78, 8, {"time": ["night", "dusk"]}), ("snowbunting", 78, 78, 6, {"weather": ["frost"]}), ("plungebeak", 78, 78, 8, {"time": ["day"]})])
    wild(z, [("pierlord", 78, 78, 18, {}), ("haarling", 78, 78, 16, {"weather": ["fog"]}), ("bayrunner", 78, 78, 16, {}), ("greyhaul", 78, 78, 16, {}),
             ("plungebeak", 78, 78, 14, {}), ("orcalet", 78, 78, 4, {"time": ["dawn"]}), ("selkie", 78, 78, 8, {"time": ["night", "dusk"]})], "water")
    finish(z)
    z.save(OUT + "/aberdeen.json")
    sanctuary(OUT, "aberdeen", "Aberdeen", (13, 32))
    shop(OUT, "aberdeen", "Aberdeen", (20, 32))
    nurse("aberdeen", ["Fit like? Welcome to the Aberdeen Sanctuary. That's Doric for 'how are you?'. Put your team on the counter, and we'll get them sorted.",
                       "Sit yersel doon. We've a wee kettle, a damp biscuit and a seat with a very good view of the fog.",
                       "Aa done! Awa ye go, and mind the haar. It rolls in like a bad rumour. Ye'll nae see yer ain feet.",
                       "The Ark terminal. It's in the cupboard with the lifebelts. Aberdeen takes its emergencies seriously.",
                       "Nae bother. Come back when yer ready. We'll still be here. The fog is, too."])
    shopkeeper("aberdeen", "Fit like! Butteries, oatcakes, a flask and a good strong rope for the ferry. Aberdeen butteries are rich, flaky and unreasonably delicious. They're also called rowies.",
               "Tak care! And if the ferry's rough, dinna look at the horizon. Look at the biscuit.")


def kirkwall(OUT):
    W, H = 64, 46
    z = Z("kirkwall", "Kirkwall", W, H, kind="town", region="scotland", music="town_scotland",
          weather={"gale": 22, "fog": 18, "drizzle": 22, "clear": 20, "sunshine": 12, "downpour": 6})
    z.d["stage"] = "coast"; z.d["town_id"] = "kirkwall"
    z.legend["g"] = {"tile": "grass", "colour": "#86a05a"}
    z.legend["h"] = {"tile": "tall_grass", "colour": "#7a5c6a", "prop": "heather"}
    z.rect(0, 0, W, H, "g")
    z.border("R", 2)
    z.scatter(0, 0, W, H, "T", 6, 9, only="R")
    # Wide Firth to the north, the harbour quay and the ferry
    z.rect(0, 0, W, 8, "$"); z.rect(2, 8, 60, 1, "w"); z.rect(26, 9, 32, 3, ":")
    z.rect(44, 4, 3, 5, ":")
    z.d["ferry"] = {"x": 45, "y": 4, "route": "aberdeen_kirkwall"}
    z.prop("boat", 50, 3, variant=0); z.prop("boat", 36, 5, variant=1); z.prop("boat", 30, 6, variant=1); z.prop("boat", 56, 6, variant=1)
    z.prop("buoy", 22, 5); z.prop("buoy", 40, 3, variant=1); z.prop("bollard", 43, 5); z.prop("bollard", 47, 5); z.prop("bollard", 43, 7); z.prop("bollard", 47, 7)
    # streets
    z.rect(4, 25, 58, 3, "=")
    z.rect(38, 12, 3, 13, ":"); z.rect(38, 28, 3, 16, ":")
    z.rect(22, 22, 22, 3, ":")
    # St Magnus Cathedral and the palaces
    z.building(26, 15, 12, 7, "cathedral", "St Magnus Cathedral")
    z.building(13, 15, 7, 5, "castle", "Bishop's Palace")
    z.rect(22, 13, 16, 2, ":"); z.rect(20, 13, 2, 9, ":")
    z.prop("planter", 24, 22); z.prop("planter", 41, 22); z.prop("lamp_post", 25, 13); z.prop("lamp_post", 37, 13)
    # Sanctuary, Corner Shop
    z.building(46, 18, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(49, 21, "kirkwall_sanctuary", 5, 6, "up")
    z.building(54, 18, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(56, 21, "kirkwall_shop", 4, 5, "up")
    z.rect(45, 22, 16, 3, ":")
    # houses in Orkney flagstone
    for (x, y, w, h, st) in [(5, 12, 6, 4, "stone"), (5, 17, 6, 4, "slate_cottage"), (46, 13, 6, 4, "white_render"), (54, 13, 6, 4, "stone"),
                             (44, 30, 6, 4, "stone"), (52, 30, 5, 4, "terrace"), (58, 30, 4, 4, "white_render"),
                             (44, 37, 5, 4, "red_brick"), (51, 37, 6, 4, "stone"), (59, 37, 3, 4, "slate_cottage"),
                             (31, 30, 6, 4, "terrace"), (31, 37, 6, 4, "white_render")]:
        z.building(x, y, w, h, st, show_label=False)
    # the Ring of Brodgar, outside town
    cx, cy, r = 13, 36, 7
    skip = {18, 19, 20, 0, 1}
    for i in range(24):
        if i in skip:
            continue
        a = i * 2 * math.pi / 24
        x, y = int(round(cx + r * math.cos(a))), int(round(cy + r * math.sin(a)))
        z.prop("standing_stone", x, y, variant=i % 3)
    z.prop("standing_stone", 26, 33, variant=1)       # the Watch Stone, a lone tall one
    z.rect(2, 29, 22, 15, "h")
    z.rect(cx - 5, cy - 5, 11, 11, "g")
    z.rect(12, 28, 3, 3, "#"); z.rect(12, 30, 3, 4, "#")
    blob(z, 20, 31, 3, 2, ",", only="h", seed=70)
    blob(z, 6, 41, 3, 2, ",", only="h", seed=71)
    z.rect(3, 29, 9, 2, "h"); z.rect(3, 30, 3, 14, "h")
    for (x, y) in [(5, 33), (21, 40), (8, 42), (22, 36)]:
        z.prop("rock", x, y, variant=(x + y) % 3)
    z.sign(13, 31, "THE RING OF BRODGAR. A great circle of standing stones, 104 metres wide, raised between 2500 and 2000 BC. There were once 60. Twenty-seven still stand, up to 4.7 m tall. Nobody knows why they built it, but they surveyed it with more care than the Council surveyed the road outside.")
    z.sign(25, 34, "THE WATCH STONE. A lone, tall slab nearby. People have made guesses about it for centuries. Mine is that it's watching the ring, and the ring is watching the sheep.")
    z.sign(40, 24, "KIRKWALL (Kirkjuvagr). 'Church Bay' in Old Norse, because the Vikings built a church by the water. Orkney was Norse until 1468, when it was pledged to the Scottish king as part of a wedding dowry. Nobody has ever asked for it back.")
    z.sign(30, 23, "ST MAGNUS CATHEDRAL. Begun in 1137 by Earl Rognvald in memory of his uncle Magnus, and built of red and yellow sandstone. It took 300 years. Inside, a stone pillar once hid a very old skeleton. It was Rognvald's, which is rather a surprise for the guide on a school trip.")
    z.sign(53, 12, "THE BA' GAME. On Christmas Day and New Year's Day the town splits into two teams, the Uppies and the Doonies, who push a leather ball through the streets. It takes hours. The goals are the harbour and a wall. Shopkeepers board up their windows. It is all perfectly polite.")
    z.sign(8, 24, "THE ROAD TO BRODGAR. Orkney's mainland is a place of stones, birds, light, and not many trees. Skara Brae, a village of stone houses older than the pyramids, is a short drive away. You are standing in one of the great Neolithic landscapes of the world.")
    z.sign(48, 10, "FERRY TO ABERDEEN. The Hjaltland Gull takes six hours, and the sea is rarely calm. The return trip costs just as many sandwiches.")
    # NPCs
    z.npc(id="kwl_sailor", sprite="sailor", x=46, y=5, facing="left", move="still", script="sailor")
    script("kirkwall", "sailor", say("Sailor", "Back to Aberdeen? We sail with the tide and the weather. The weather is currently 'interesting'. Hold on to your hat and your lunch.") + [{"do": "ferry", "route": "aberdeen_kirkwall"}])
    chat(z, "cathedral_guide", "tour_guide", 32, 23, "Cathedral Guide",
         ["St Magnus was begun in 1137, and it took three hundred years to finish. The builders ran out of money, then stone, then patience. The red and yellow sandstone makes stripes in the arches, like a very solemn sweet shop.",
          "The cathedral has never had a bishop's palace next door that lasted. The ruin by the door is the Bishop's Palace, and it's a good place to practise your dramatic sigh."], "down", "still")
    chat(z, "ba_player", "rugby_player", 39, 27, "Ba' Game Veteran",
         ["I've played the Ba' for twenty years. Uppie, born north of the cathedral. Doonie, born south. A baby born in the town is an Uppie or Doonie from its first day. My sister's a Doonie, which is basically a different nationality.",
          "The ball's made of leather, stuffed with cork, and weighs a kilo and a bit. It's not thrown, it's pushed along by a hundred people at once. A scrum with a street in it."], "left", "still")
    chat(z, "stone_scholar", "student", 15, 33, "Stone Scholar",
         ["The Ring of Brodgar's older than Stonehenge. The Neolithic people of Orkney built stone houses, a great tomb at Maeshowe, and the stone circle, and they lined them up with the sun. They were serious about their calendars.",
          "I'm counting the stones. I get 27, every time. A sheep behind me gets a different number. She's just very confident."], "down", "wander")
    chat(z, "orkney_fisher", "farmer", 52, 11, "Pier Regular",
         ["On a clear winter night the northern lights dance over the water. We call them the Merry Dancers. You'll be in the kitchen, and your gran will say 'quick, they're out'.",
          "Orkney's mostly flat, with the sea in every direction. It's windy. The kind of wind that has opinions about your hat, and a plan."], "down", "wander")
    trainer(z, "kwl_fisher", "Fisher Magnus", "Fisher", "angler", [("greyhaul", 80), ("orcaird", 80), ("haarling", 80)],
            37, 12, "right", ["I'm named after the saint. He'd have been a lovely fisherman. He was a vegetarian, but it's the thought."],
            "Och, you're a fine hand with the net.", "I've fished Scapa Flow all my life. The seals watch. The cormorants judge. The gulls take notes.", 2900)
    trainer(z, "kwl_birder", "Birdwatcher Thora", "Birdwatcher", "birdwatcher", [("clownbill", 80), ("polartern", 80), ("goldeneyrie", 80)],
            12, 27, "down", ["Orkney's got more hen harriers than you'd credit, plus puffins in the summer and skuas that attack your hat. I recommend a helmet."],
            "You're a fine observer. The sea eagle overhead agrees.", "Great skuas are known as bonxies. They dive-bomb walkers. One once took my sandwich and my dignity.", 2920)
    z.d["edges"] = {}
    z.d["spawn"] = [45, 10]
    wild(z, [("clownbill", 80, 80, 14, {"time": ["day"]}), ("polartern", 80, 80, 12, {}), ("snowbunting", 80, 80, 10, {"weather": ["frost", "fog"]}),
             ("goldeneyrie", 80, 80, 8, {"time": ["day"]}), ("haarling", 80, 80, 10, {"weather": ["fog"]}), ("midgeswarm", 80, 80, 10, {"time": ["dawn", "dusk"]}),
             ("cragchough", 80, 80, 10, {}), ("plungebeak", 80, 80, 8, {"time": ["day"]}), ("hushwing", 80, 80, 6, {"time": ["night"]}), ("selkie", 80, 80, 6, {"time": ["dusk", "night"]})])
    wild(z, [("greyhaul", 80, 80, 16, {}), ("orcaird", 80, 80, 8, {"time": ["dawn", "dusk"]}), ("selkie", 80, 80, 12, {"time": ["dusk", "night"]}), ("bayrunner", 80, 80, 16, {}),
             ("plungebeak", 80, 80, 14, {}), ("haarling", 80, 80, 12, {"weather": ["fog"]}), ("pierlord", 80, 80, 12, {})], "water")
    finish(z)
    z.save(OUT + "/kirkwall.json")
    sanctuary(OUT, "kirkwall", "Kirkwall", (49, 22))
    shop(OUT, "kirkwall", "Kirkwall", (56, 22))
    nurse("kirkwall", ["Welcome to the Kirkwall Sanctuary. The last stop before the Arctic, as far as the sign on the wall is concerned. Pop your team on the counter and hang up your coat.",
                       "There, sit down. We've a stove, a kettle and a cat who sits on whatever you put down. We call him the Senior Registrar.",
                       "All done, and good as new. Mind the wind on the way out. It's got a stronger grip than a Viking at a family wedding.",
                       "The Ark terminal. It runs on peat, oatcakes and a surprisingly large battery. Don't ask where it came from. Don't ask where the battery went.",
                       "Right you are. Come back any time. There's nowhere else to go from here but the sea."])
    shopkeeper("kirkwall", "Welcome! Fudge, oatcakes, a woolly hat and a good flask. The woolly hats are on the left. The wind is on the outside.",
               "Safe home. And if you see the Merry Dancers tonight, wave. They like that.")
