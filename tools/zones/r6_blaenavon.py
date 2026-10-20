# R6: Blaenavon (Blaenafon), the industrial landscape World Heritage Site: Big Pit and its ex-miner guides, the
# ironworks and Stack Square, the Workmen's Hall, and the moor above them. East of Merthyr, over the hill.
from r6_common import *


def blaenavon(OUT):
    W, H = 56, 46
    zid = "blaenavon"
    z = Z(zid, "Blaenavon", W, H, kind="town", region=SW, music="town_wales", weather={"drizzle": 30, "fog": 18, "downpour": 14, "gale": 12, "clear": 14, "sunshine": 12})
    z.d["stage"] = "moor"; z.d["town_id"] = zid; z.d["scaled_floor"] = FLOOR
    z.legend["g"] = {"tile": "grass", "colour": "#7a8052"}
    z.legend["h"] = {"tile": "tall_grass", "colour": "#86647c"}      # heather
    z.rect(0, 0, W, H, "g")
    z.border("T", 2, gaps=[(0, 22, 2, 3)])
    hills(z, [(52, 3, 3, 9), (52, 43, 3, 9), (3, 3, 2, 7), (3, 43, 2, 7)])
    # main street, pavements, the path up to Big Pit and out over the moor
    z.rect(2, 22, 44, 3, "=")
    z.rect(2, 21, 44, 1, ":"); z.rect(2, 25, 44, 1, ":")
    z.rect(46, 17, 2, 9, "#")
    z.rect(46, 26, 2, 16, "#")
    z.rect(4, 39, 23, 1, "#"); z.rect(20, 26, 2, 13, "#")
    # heather moor round the edges
    for (cx, cy, rx, ry, sd) in [(40, 34, 5, 6, 1), (14, 8, 9, 3, 2), (32, 7, 6, 3, 3), (50, 30, 3, 5, 4), (6, 32, 3, 6, 5), (30, 42, 7, 2, 6),
                                 (41, 5, 3, 2, 7), (51, 10, 2, 3, 8), (36, 28, 3, 2, 9)]:
        blob(z, cx, cy, rx, ry, "h", only="g", seed=sd, jitter=0.4)
    scatter_props(z, "pine", 3, 3, 48, 38, 8, 41, avoid=("g",))
    scatter_props(z, "rock", 3, 3, 48, 38, 10, 42, avoid=("g", "h"))
    for (x, y) in [(30, 31), (35, 38), (14, 12), (26, 9), (8, 36), (44, 31)]:
        z.prop("sheep", x, y)
    # north side: the Workmen's Hall, the cheese shop, Sanctuary, shop, Stack Square
    z.building(6, 15, 8, 6, "red_brick", "Workmen's Hall", door=4)
    z.warp(10, 20, "blaenavon_workmens", 6, 7, "up")
    z.building(16, 16, 5, 5, "cream_render", "Pwll Mawr Cheese", door=2)
    z.warp(18, 20, "blaenavon_cheese", 5, 6, "up")
    z.building(23, 17, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(26, 20, "blaenavon_sanctuary", 5, 6, "up")
    z.building(30, 17, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(32, 20, "blaenavon_shop", 4, 5, "up")
    z.building(37, 17, 6, 4, "stone", "Stack Square", door=2)
    z.warp(39, 20, "blaenavon_stacksq", 6, 7, "up")
    # south side: terraces, then the ironworks down the hill
    z.building(24, 27, 8, 3, "valley_terrace"); z.building(34, 27, 8, 3, "valley_terrace")
    z.building(8, 31, 11, 8, "ironworks", "Blaenavon Ironworks", door=5)
    z.warp(13, 38, "blaenavon_ironworks", 7, 8, "up")
    # Big Pit, on the hill: winding gear, the lamp room, a scatter of tips
    z.building(42, 11, 9, 6, "winding_gear", "Big Pit National Coal Museum", door=4)
    z.warp(46, 16, "blaenavon_bigpit", 6, 7, "up")
    for (x, y, v) in [(41, 14, 0), (52, 14, 1), (51, 17, 2), (53, 12, 0), (40, 12, 1)]:
        z.prop("slate_heap", x, y, variant=v)
    for x in (13, 22, 29, 42):
        z.prop("lamp_post", x, 21)
    z.prop("bench", 14, 21); z.prop("bench", 28, 25); z.prop("phone_box", 36, 21); z.prop("post_box", 12, 25)
    z.prop("planter", 44, 21); z.prop("washing_line", 28, 30, walk=True); z.prop("washing_line", 38, 30, walk=True)
    smooth(z)

    # ---- signs and plaques
    z.sign(3, 21, "BLAENAFON, or Blaenavon. Blaen afon: 'the head of the river'. World Heritage Site since 2000. West: Merthyr Tydfil, over the hill.")
    z.sign(47, 38, "THE MOOR. Heather, sheep and old iron pits. Stay on the path and out of the old workings, bach.")
    plaque(z, "blaenavon", "name", 4, 25, "Blaenavon",
           "Blaenavon means 'the head of the river' (blaen, head; afon, river). The ironworks were sited at the head of the valley because all four things iron needs, ore, coal, limestone and water, lay within a short walk.")
    plaque(z, "blaenavon", "unesco", 13, 25, "World Heritage",
           "In 2000 the Blaenavon Industrial Landscape became a UNESCO World Heritage Site, the first in Wales to be listed for its industry. It covers the ironworks, the pits, the quarries, the incline railways and the workers' homes, all in one preserved stretch of hill.")
    plaque(z, "blaenavon", "bigpit", 47, 19, "Big Pit",
           "Big Pit was sunk in 1860 and worked as a colliery until 1980. It reopened as the National Coal Museum in 1983, and visitors still go 90 metres down in the cage with a helmet and lamp. The guides are ex-miners. You won't find a better history teacher with a better wheezing cough.")
    plaque(z, "blaenavon", "ironworks", 15, 40, "Blaenavon Ironworks",
           "Founded in 1789, Blaenavon Ironworks is one of the best-preserved 18th-century ironworks in Europe. Its furnaces were charged from the top with ore, coal and limestone from the same hillside, and the great water-balance tower lifted trucks from the casting yard without a drop of steam.")
    plaque(z, "blaenavon", "gilchrist", 11, 40, "1878",
           "In 1878 a London police-court clerk named Sidney Gilchrist Thomas and his cousin Percy Gilchrist, a chemist at Blaenavon, solved the problem of making good steel from iron full of phosphorus. Their 'basic' process, tried out here, opened the world's phosphoric ores to steelmaking.")
    plaque(z, "blaenavon", "stacksq", 36, 25, "Stack Square",
           "Stack Square, built for ironworkers round 1788, still has its rows of cottages looking in on a courtyard. The ironworks owners also ran the company shop and the school. Wages came partly in tokens, which could only be spent in their shop.")
    plaque(z, "blaenavon", "cheddar", 22, 21, "Pwll Mawr",
           "Pwll Mawr is Big Pit's Welsh name, 'big pit'. A local cheddar is now matured in the mine's underground tunnels, in the same cool, damp air that preserved miners' sandwiches. It is the only cheese in Britain matured in an old coal mine.")
    plaque(z, "blaenavon", "workmens", 8, 21, "The Workmen's Hall",
           "In Blaenavon, as across the valleys, miners paid a few pence from every wage packet to build themselves a hall. Blaenavon's was a library, a reading room, a billiard hall, a stage and a meeting place all at once.")
    plaque(z, "blaenavon", "railway", 30, 25, "Pontypool and Blaenavon Railway",
           "A heritage steam railway runs on part of the old mineral line that took coal and iron down to the valley. At nearly 400 metres it is one of the highest standard-gauge railways in Wales, and the weather up there is a character in itself.")
    plaque(z, "blaenavon", "ponies", 45, 27, "Pit Ponies",
           "For about two centuries, ponies hauled the coal trams underground. They lived in underground stables, wore a hard hat of their own, and had names. By the end of the twentieth century machines had replaced them, and the last ponies in Wales retired to fields they had never seen.")

    # ---- people
    chat(z, "bla_old", "villager_3", 24, 26, "Old Boy",
         ["My grandad was an ironworker, my dad was a miner and I was a miner. My son sells insurance. He says it's very similar, with fewer hats.",
          "They say there's a quiet hill above the town where you can still hear Blaenavon thinking."], facing="up")
    chat(z, "bla_kid", "villager_6", 38, 26, "Kid",
         ["I went down Big Pit on a school trip. They took all our batteries off us at the lamp room. The guide said one spark in a gassy pit would be the end of the school trip. And possibly the school.",
          "It's dark. It's really, really dark. Don't bring a torch. You won't be allowed."], facing="left")
    chat(z, "bla_walker", "hiker", 22, 30, "Hiker",
         ["There's a footpath up to Keepers Pond and the Garn. On a clear day you can see across to the Brecon Beacons. On a normal day you can see your own boots.",
          "The old tramroads cross the hills like pencil lines. You can follow them for miles, and the ponies' hooves wore the stones smooth."], facing="up")
    # trainers
    trn(z, "bla_cheese", "Cheesemaker Sian", "Cheesemaker", "villager_5", [("moolet", 35), ("loaghtan", 35), ("herdlet", 36)], 17, 23, "right",
        ["Cheddar from a coal mine! You'd think it would taste of coal. It tastes of cheddar. Magnificent cheddar. Battle?"],
        "That was a bit of a mature performance.", "Pwll Mawr matures down Big Pit. The cool, damp air is perfect for it. They say the cheese hums when the pit ponies walk past.", 2800)
    trn(z, "bla_rail", "Volunteer Huw", "Railway Volunteer", "rail_guard", [("railspark", 36), ("treadlet", 35), ("bobbin", 36)], 40, 23, "left",
        ["I do the signals, the tea and the shovelling. I'm a volunteer. It's not about the money. It's about the steam. Race you!"],
        "Derailed, and in a good way.", "It's the highest standard-gauge steam railway in Wales, the heritage line. You can nearly touch the clouds. I did once. They were mostly wet.", 2800)
    trn(z, "bla_runner", "Fell Runner Carys", "Fell Runner", "fell_runner", [("kitelet", 35), ("leveret", 35), ("peregrin", 36)], 47, 33, "up",
        ["Up the Blorenge and back before the kettle's boiled. I've run it in hail. Hail's actually good for the knees. Want to see my kit?"],
        "Photo finish. And I lost it.", "The Blorenge, the Sugar Loaf and Pen y Fan, a skyline circuit. I'd love to do it in sunshine. I'd love to see it in sunshine.", 2800)
    trn(z, "bla_legend", "Dai Pwll Mawr", "Local Legend", "tin_miner",
        [("coblynn", 37), ("tunneller", 37), ("steelheart", 37), ("quarrion", 37), ("lanternis", 37), ("stagmajor", 38)], 47, 41, "up",
        ["Thirty-one years in Big Pit, boyo, and every shift I whistled. Never once got caught. The coblynau were scared of my tuneless noise. Show me you've got nerve, down here in the daylight."],
        "Duw, duw. You've a good ear for a seam. You'll go far.", "There's more under this hill than on top of it. Mind the plates. And never, ever whistle underground.", 4800)
    # wild
    wild(z, [("kidgruff", 34, 36, 12, {}), ("herdlet", 34, 36, 10, {}), ("moolet", 34, 36, 8, {}), ("slatelet", 34, 36, 8, {}), ("crumblet", 34, 36, 6, {}),
             ("cobblet", 34, 36, 10, {}), ("tapknock", 34, 36, 8, {}), ("steamlet", 35, 37, 6, {}), ("loaghtan", 34, 36, 6, {}), ("stagbeet", 34, 36, 6, {}),
             ("peatling", 33, 35, 6, {"weather": ["fog", "drizzle", "downpour"]}), ("flittermouse", 34, 36, 6, {"time": ["night"]}), ("hootlet", 34, 36, 6, {"time": ["night"]}),
             ("railspark", 35, 37, 4, {}), ("pigling", 33, 35, 6, {}), ("seamknocker", 38, 39, 2, {"time": ["night"]})])
    z.d["edges"] = {"west": {"to": "merthyr", "offset": 4}}
    z.d["spawn"] = [4, 23]
    done(z)
    z.save(OUT + "/" + zid + ".json")
    bad = reach_check(z)
    if bad:
        print("blaenavon unreachable:", bad)

    # ---- interiors
    sanctuary(OUT, zid, "Blaenavon", (26, 21))
    shop(OUT, zid, "Blaenavon", (32, 21))
    nurse(zid, ["Shwmae, cariad! Croeso to Blaenavon Sanctuary. You've got the Blorenge in your hair. Come in and get warm.",
                "There we are. Tea, a Welsh cake and a sit by the stove. A coal stove, naturally. It's Blaenavon.",
                "All mended. Off you go. Hwyl fawr, and mind the sheep. They've got right of way and they know it.",
                "The Ark's by the wall, love. It's quiet today. Not as quiet as down Big Pit, mind.",
                "No bother at all. Diolch."])
    shopkeeper(zid, "Shwmae! Snares, tea, a bit of cheese if you're lucky. What can I get you?", "Diolch, bach. Mind the weather. It's got an opinion.")

    interior(OUT, "blaenavon_workmens", "Workmen's Hall", zid, (10, 21), "library",
             [dict(id="bla_caretaker", sprite="choir_singer", x=6, y=3, facing="down", move="still", script="bla_caretaker", name="Hall caretaker"),
              dict(id="bla_billiards", sprite="villager_4", x=9, y=6, facing="left", move="still", script="bla_billiards", name="Billiards player")],
             furnish=False,
             extra=[P("table", 4, 6), P("table", 8, 6), P("wall_picture", 5, 1, walk=True), P("clock", 6, 1, walk=True), P("potted_plant", 1, 1), P("piano", 2, 3)])
    DLG["blaenavon_workmens"] = {"bla_caretaker": caretaker_script(),
                                 "bla_billiards": say("Billiards player", "Eight feet of green baize, bought with the pennies of men who'd already done a shift. It's still the best table in Gwent.",
                                                      "The hall had a library, a stage, a cinema and a committee. The committee argued about all four. A proper institution.")}

    interior(OUT, "blaenavon_cheese", "Pwll Mawr Cheese", zid, (18, 21), "cafe",
             [dict(id="bla_cheesemonger", sprite="shopkeeper", x=3, y=1, facing="down", move="still", script="bla_cheesemonger", name="Cheesemonger")],
             w=11, h=9, furnish=False,
             extra=[P("table", 8, 3), P("kettle_table", 8, 5), P("menu_board", 6, 1, walk=True), P("potted_plant", 9, 6), P("tea_urn", 1, 3)])
    DLG["blaenavon_cheese"] = {"bla_cheesemonger": say("Cheesemonger", "Cheddar, matured 90 metres down the old Big Pit. Wrapped in cloth, turned by hand, left alone in the dark. A bit like a miner, in a way, except the cheese gets better with age.",
                                                          "The mine air's cool, damp and steady, which is exactly what cheddar needs. Fancy a slice?")
                              + [{"do": "shop", "id": "blaenavon_cheese_stall"}] + say("Cheesemonger", "Diolch. Keep it cool, keep it damp and keep it away from the cat.")}

    interior(OUT, "blaenavon_stacksq", "Stack Square Cottage", zid, (39, 21), "home",
             [dict(id="bla_ironwife", sprite="mum", x=4, y=3, facing="right", move="still", script="bla_ironwife", name="Ironworker's wife")],
             furnish=True, extra=[P("kitchen_dresser", 8, 1)])
    DLG["blaenavon_stacksq"] = {"bla_ironwife": say("Ironworker's wife", "Two rooms up, two down. The row was built so the whole works could be seen from every door. It also meant the whole row could see you.",
                                                       "We got paid partly in tokens that only worked in the company shop. Nothing like being forced to spend your money in one place. We call that 'the truck system', and it was against the law by 1831. They did it anyway.")}

    interior(OUT, "blaenavon_ironworks", "Blaenavon Ironworks", zid, (13, 39), "mill",
             [dict(id="bla_ironguide", sprite="tour_guide", x=7, y=3, facing="down", move="still", script="bla_ironguide", name="Iolo, ironworks guide")],
             w=15, h=11, furnish=False, drop=("table", "slate_heap"),
             extra=[P("slate_heap", 1, 6), P("slate_heap", 13, 6, variant=1), P("table", 3, 5), P("brazier", 11, 3), P("brazier", 3, 3),
                    P("display_case", 11, 6, variant=1), P("wall_picture", 7, 1, walk=True)])
    DLG["blaenavon_ironworks"] = {"bla_ironguide": say("Iolo", "You're standing in the casting house, where white-hot iron ran in streams down channels in a bed of sand. The big channel was the sow, and the little ones, being its piglets, were the pigs. Pig iron.",
                                                          "Ore, coal and limestone came in the top. Iron and slag came out the bottom, and the furnace never went out. Never. If it went cold, it had to be dug out, and that cost a fortune.",
                                                          "Here in 1878 Percy Gilchrist and his cousin Sidney Gilchrist Thomas made steel from phosphoric iron. They'd tried it elsewhere and it didn't work. It worked here, and it changed the world's steel for good.")}

    # Big Pit: the lamp room at the top, and the dark below
    interior(OUT, "blaenavon_bigpit", "Big Pit: Lamp Room", zid, (46, 17), "mill",
             [dict(id="bla_gwilym", sprite="tin_miner", x=6, y=3, facing="down", move="still", script="bla_gwilym", name="Gwilym, ex-miner")],
             w=13, h=10, furnish=False, drop=("table", "slate_heap"),
             extra=[P("bookshelf", 2, 1), P("bookshelf", 3, 1), P("bookshelf", 9, 1), P("brick_arch", 10, 3), P("table", 2, 5), P("brazier", 11, 6),
                    P("wall_picture", 6, 1, walk=True), P("slate_heap", 1, 6)],
             signs=[{"x": 4, "y": 3, "plaque": "blaenavon_lamproom", "title": "The Lamp Room",
                     "text": "At the top of the shaft, visitors give up anything that could make a spark: lighters, matches, phones, watches. Methane, called firedamp, collects in pockets underground, and a single spark could set it off. Miners carried lamps designed so that they couldn't."}])
    DLG["blaenavon_bigpit"] = {"bla_gwilym": gwilym_script()}

    interior(OUT, "blaenavon_bigpit_below", "Big Pit: 90 metres down", "blaenavon_bigpit", (6, 6), "castle",
             [dict(id="bla_idris", sprite="tin_miner", x=3, y=3, facing="right", move="still", script="bla_idris", name="Idris, ex-miner"),
              dict(id="pit_knock", sprite="creature:cobblet", x=12, y=3, facing="left", move="still", script="pit_knock", hide_if=Q + "pit_caught"),
              dict(id="pit_pony", sprite="creature:foalmoor", x=2, y=6, facing="right", move="still", script="pit_pony")],
             w=15, h=11, furnish=False, drop=("table", "bench", "potted_plant"), dark=True, music="dungeon_underground",
             extra=[P("brick_arch", 7, 4), P("brick_arch", 7, 6), P("brazier", 4, 2), P("brazier", 11, 2), P("brazier", 4, 8),
                    P("slate_heap", 9, 6), P("slate_heap", 12, 6, variant=1), P("slate_heap", 5, 5, variant=2), P("rock", 13, 1), P("rock", 1, 1)])
    DLG["blaenavon_bigpit_below"] = {"bla_idris": idris_script(), "pit_knock": knock_script(),
                                     "pit_pony": say("Pit pony", "The pony snorts, flicks an ear and carries on chewing. It has seen a lot of visitors. It has not been impressed by any.")}


def caretaker_script():
    found = Q + "choir_3"
    ask = [{"do": "say", "who": "Caretaker", "text": "A bass? Baritone, I'll have you know! There's a difference. And I'm not singing for just anybody. Here: what is Wales' national anthem called?"},
           {"do": "choice", "text": "Wales' national anthem is...", "options": ["Calon Lan", "Cwm Rhondda", "Hen Wlad Fy Nhadau", "Myfanwy"], "set": "_caretaker_q"},
           {"do": "if", "flag": "_caretaker_q", "eq": 2,
            "then": say("Caretaker", "Hen Wlad Fy Nhadau: 'Land of My Fathers'. Written in Pontypridd in 1856 by Evan and James James, father and son. Right, I'll sing. Third from the left, baritone.")
                    + [setf(found), {"do": "sfx", "id": "item"},
                       {"do": "say", "who": "", "text": "You found a baritone for the eisteddfod choir."}],
            "else": say("Caretaker", "No, bach. That one's lovely, mind, but it's not the anthem. Try again.")}]
    return [flag_if(found, say("Caretaker", "I'll be there. I've got the hymn book out and everything."),
                    [flag_if(Q + "choir_started", ask,
                             say("Caretaker", "I look after the Workmen's Hall: the stage, the library, the billiards, the lot. I sing, too, in my own time. Mostly to the radiators.",
                                 "Ask me again if the choir needs a baritone. They do, usually."))])]


def gwilym_script():
    s = Q + "pit_"
    quiz = [{"do": "say", "who": "Gwilym", "text": "First, the lamp room rules. It's the rules or nothing. What do you hand in before you go down the shaft?"},
            {"do": "choice", "text": "What do you hand in at the lamp room?",
             "options": ["Nothing, I'll be fine", "Anything that could make a spark: matches, lighters, phones", "My sandwiches", "My boots"], "set": "_pit_q"},
            {"do": "if", "flag": "_pit_q", "eq": 1,
             "then": say("Gwilym", "Spot on. Methane collects in the roof and one spark in the wrong place is the end of the shift and then some.",
                         "Here's your lamp, and a hard hat, and a self-rescuer in case the air turns. You won't need it. Probably.")
                     + [setf(s + "1"), {"do": "give_item", "item": "big_pit_lamp", "n": 1}],
             "else": say("Gwilym", "No, no, no. Think about what's underground with you. Gas. What does gas hate? A spark. Try again.")}]
    descend = [{"do": "choice", "text": "Ride the cage down 90 metres?", "options": ["Go down", "Not just yet"], "set": "_pit_go"},
               {"do": "if", "flag": "_pit_go", "eq": 0,
                "then": [{"do": "fade_out"},
                         {"do": "say", "who": "", "text": "The cage doors clatter shut. The daylight shrinks to a postage stamp, then goes out. Ninety metres is a long way down, and it feels longer."},
                         {"do": "warp", "zone": "blaenavon_bigpit_below", "x": 7, "y": 8, "facing": "up"}, {"do": "fade_in"}],
                "else": say("Gwilym", "No rush. The coal's not going anywhere. It's had a few hundred million years.")}]
    bass = [{"do": "say", "who": "Gwilym", "text": "Sing for the Eisteddfod? Me? Bass, forty years, down the pit and up the chapel. Right. One question first: which hymn, a favourite of choirs and rugby crowds, asks for a pure heart?"},
            {"do": "choice", "text": "Which song asks for a 'pure heart'?", "options": ["Calon Lan", "Myfanwy", "Cwm Rhondda", "Delilah"], "set": "_gwilym_q"},
            {"do": "if", "flag": "_gwilym_q", "eq": 0,
             "then": say("Gwilym", "Calon Lan! 'Nid wy'n gofyn bywyd moethus': I do not ask for a life of luxury. Man after my own heart. Right, I'll sing.")
                     + [setf(Q + "choir_4"), {"do": "sfx", "id": "item"},
                        {"do": "say", "who": "", "text": "You found a bass for the eisteddfod choir."}],
             "else": say("Gwilym", "Not that one, bach. Think of the rugby crowd. Think of the second verse that nobody knows. Come back.")}]
    finish = (say("Gwilym", "You've been down, you've heard them, you've even got one in the bag. Not many can do that. Most visitors just hear the guide.",
                  "Here, a Davy lamp. Not a working one. A charm. Sir Humphry Davy made the first in 1815 so a flame couldn't ignite the gas. You've got the sense of a collier.",
                  "And a wedge of Pwll Mawr, from the cheese, down the pit. It tastes better after you've been down.")
              + [{"do": "give_item", "item": "davy_lamp", "n": 1}, {"do": "give_item", "item": "blaenavon_cheddar", "n": 3},
                 {"do": "standing", "nation": "wales", "amount": 8}, setf(s + "done")])
    return [flag_if(s + "done",
                    [flag_if(Q + "choir_started", [flag_if(Q + "choir_4",
                                                           say("Gwilym", "Mind how you go. And never whistle underground."),
                                                           bass)],
                             say("Gwilym", "Ah, the one who went down on her own two feet. I mean theirs. Anyway, any time you want to see the pit again, I'm here.",
                                 "Big Pit, the National Coal Museum. We do tours with ex-miners. We're the only place in Wales where the exhibits tell you off."))],
                    [flag_if(s + "3", finish,
                             [flag_if(s + "started",
                                      [flag_if(s + "1", say("Gwilym", "Lamp on? Helmet on? Mind your head. The roof is lower than you think.") + descend, quiz)],
                                      say("Gwilym", "Bore da! Gwilym. I worked in this pit until it closed in 1980. Now I show people down it. Same pit, different hat.",
                                          "Big Pit was sunk in 1860. Down the shaft, 90 metres, and a mile or more of tunnels. We go down in the cage with a lamp and a helmet. I won't lie to you: it's dark.",
                                          "They say there are knockers down there: the coblynau, little men in the rock who tap out the way to the best seams. I've never seen one. I've heard something, mind. Fancy a look?")
                                      + [setf(s + "started")] + quiz)])])]


def idris_script():
    s = Q + "pit_"
    return [flag_if(Q + "pit_caught",
                    say("Idris", "You've got a Cobblet in your pocket. That's the first time I've seen one caught. Don't tell the others, they'll want one each.",
                        "Off you go back up. Tell Gwilym. Mind how you go. And take care of the little knocker."),
                    [flag_if(s + "2",
                             say("Idris", "Over there, east, by the new face. Listen for it. Tap, tap, tap. Three knocks and a wait.", "Don't whistle. Don't shout. Coblynau don't like noise. They like a polite visitor."),
                             say("Idris", "Good, you made it. Thirty years I worked down here, and the dark never frightened me. The quiet did.",
                                 "That's the pony stable, on the west side. Ponies lived down here, nearly three hundred of them, working the trams. The last pit ponies in Wales retired when machines took over. Fine animals.",
                                 "Now hush. Do you hear it? Three little knocks. That's the coblynau. They tapped to lead a miner to the rich seam. Follow your ears: the knocking comes from the east face. Go on.")
                             + [setf(s + "2")])])]


def knock_script():
    s = Q + "pit_"
    return [flag_if(s + "2",
                    [{"do": "say", "who": "", "text": "Three little knocks from the coal face, and a tiny yellow hard hat bobs out from behind a slab of rock."},
                     {"do": "legend", "species": "cobblet", "level": 35, "scaled_floor": FLOOR, "music": "legend", "flag": Q + "pit_caught"},
                     flag_if(Q + "pit_caught",
                             [setf(s + "3"), {"do": "say", "who": "", "text": "The knocking stops, and a little cheer goes up somewhere down the tunnel. Idris will want to hear about this."}],
                             [{"do": "say", "who": "", "text": "The coblyn slips away behind the coal. It will knock again."}])],
                    [{"do": "say", "who": "", "text": "Tap. Tap. Tap. Something is knocking in the rock, faint and quite polite. Perhaps you should have a word with Idris first."}])]
