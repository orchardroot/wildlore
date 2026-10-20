# R6: Merthyr Tydfil, the iron capital: Cyfarthfa Castle above its lake, the Ynysfach engine house, Soar chapel, the
# pub where the 1831 Rising is remembered, and Trevithick's locomotive on the old tramroad.
from r6_common import *


def merthyr(OUT):
    W, H = 64, 56
    zid = "merthyr"
    z = Z(zid, "Merthyr Tydfil", W, H, kind="town", region=SW, music="town_wales", weather=WX)
    z.d["stage"] = "town"; z.d["town_id"] = zid; z.d["scaled_floor"] = FLOOR
    z.legend["g"] = {"tile": "grass", "colour": "#6e8c4a"}
    z.rect(0, 0, W, H, "g")
    z.border("T", 2, gaps=[(29, 54, 3, 2), (62, 26, 2, 3)])
    hills(z, [(5, 47, 3, 10), (58, 47, 3, 10), (58, 5, 3, 8)])
    # the main street and the road down the valley
    z.rect(2, 26, 62, 3, "=")
    z.rect(2, 25, 60, 1, ":"); z.rect(2, 29, 60, 1, ":")
    z.rect(29, 29, 3, 27, "=")
    z.rect(28, 30, 1, 24, ":"); z.rect(32, 30, 1, 24, ":")
    # the park: Cyfarthfa Lake, paths, trees
    z.rect(13, 4, 19, 10, "w"); z.rect(14, 5, 17, 8, "~")
    z.rect(8, 14, 34, 1, "#"); z.rect(14, 14, 2, 12, "#"); z.rect(40, 11, 2, 15, "#"); z.rect(42, 14, 17, 1, "#")
    scatter_props(z, "oak", 3, 3, 30, 14, 14, 11, avoid=("g",))
    scatter_props(z, "birch", 43, 3, 17, 14, 8, 12, avoid=("g",))
    for (cx, cy, rx, ry, sd) in [(8, 8, 4, 3, 1), (46, 8, 4, 4, 2), (55, 16, 4, 3, 3), (6, 40, 3, 3, 4), (22, 48, 4, 3, 5), (47, 46, 5, 4, 6), (56, 36, 3, 3, 7)]:
        blob(z, cx, cy, rx, ry, ",", only="g", seed=sd, jitter=0.4)
    z.prop("bench", 33, 15); z.prop("bench", 20, 15); z.prop("bench", 44, 15); z.prop("lamp_post", 38, 15); z.prop("lamp_post", 28, 15)
    # north side: Ynysfach, the market, the library, Soar, the pub, the locomotive
    z.building(5, 18, 9, 7, "engine_house", "Ynysfach Engine House", door=3)
    z.warp(8, 24, "merthyr_ynysfach", 6, 7, "up")
    z.building(16, 20, 8, 5, "red_brick", "Merthyr Market", door=4)
    z.warp(20, 24, "merthyr_market", 6, 7, "up")
    z.building(25, 20, 6, 5, "georgian_brick", "Merthyr Library", door=3)
    z.warp(28, 24, "merthyr_library", 6, 7, "up")
    z.building(33, 19, 6, 6, "chapel", "Soar Chapel", door=3)
    z.warp(36, 24, "merthyr_chapel", 5, 7, "up")
    z.building(33, 3, 14, 8, "castle", "Cyfarthfa Castle", door=7)
    z.warp(40, 10, "merthyr_cyfarthfa", 7, 8, "up")
    z.building(43, 21, 7, 4, "white_render", "Y Dic Penderyn", door=3)
    z.warp(46, 24, "merthyr_pub", 5, 6, "up")
    z.building(52, 22, 7, 3, "steam_loco", "Trevithick's Locomotive")
    # south side: Sanctuary, shop, the station, terraces up the slope
    z.building(8, 30, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(11, 33, "merthyr_sanctuary", 5, 6, "up")
    z.building(16, 30, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(18, 33, "merthyr_shop", 4, 5, "up")
    z.rect(2, 34, 26, 1, ":")
    station(z, 36, 31, 8, 4, "Merthyr Tydfil Station")
    z.rect(34, 30, 2, 4, ":"); z.rect(44, 33, 2, 1, ":")
    z.prop("buffer_stop", 35, 34); z.prop("tunnel_portal", 44, 34)
    rail_guard(z, 42, 33, ["Merthyr Tydfil! End of the line, and not a metaphor. This is where the Taff Vale Railway opened in 1841, taking iron and coal down to Cardiff docks.",
                           "Trains back down the valley run all the way to Cardiff. Hold on to your hat: there's a tunnel and a lot of weather."], facing="left")
    for (x, y, w, lab) in [(22, 38, 6, None), (34, 38, 5, None), (40, 38, 6, None), (22, 42, 6, None), (34, 42, 5, None), (40, 42, 6, None)]:
        z.building(x, y, w, 3, "valley_terrace", lab)
    z.rect(21, 37, 26, 1, ":")
    for (x, y) in [(20, 36), (28, 36), (38, 36)]:
        z.prop("lamp_post", x, y)
    z.prop("washing_line", 24, 41, walk=True); z.prop("washing_line", 42, 41, walk=True)
    z.prop("phone_box", 27, 25); z.prop("post_box", 31, 25); z.prop("lamp_post", 10, 25); z.prop("lamp_post", 48, 29)
    z.prop("bench", 44, 29); z.prop("planter", 22, 29)
    for (x, y, v) in [(60, 6, 0), (58, 3, 1), (61, 10, 2)]:
        z.prop("slate_heap", x, y, variant=v)
    smooth(z)

    # ---- signs and plaques
    z.sign(27, 52, "MERTHYR TYDFIL. Croeso! The iron capital of the world, once upon a time. East: Blaenafon, over the hill. South: the Rhondda and Caerdydd.")
    z.sign(60, 25, "BLAENAFON (Blaenavon). World Heritage, big pit, bigger weather. Mind the sheep on the road.")
    plaque(z, "merthyr", "name", 3, 29, "Merthyr Tydfil",
           "Merthyr means 'martyr'. The town is named for Tydfil, a daughter of the Welsh king Brychan, who was killed by raiders about 480 AD and is remembered as a saint. There has been a church on the site since long before there was an ironworks.")
    plaque(z, "merthyr", "iron", 6, 29, "Iron Capital",
           "In 1831 Merthyr was the largest town in Wales, with some 22,000 people, because of its four great ironworks: Cyfarthfa, Dowlais, Penydarren and Plymouth. They made rails, cannon and girders from iron ore, coal and limestone all found in the same hillsides.")
    plaque(z, "merthyr", "cyfarthfa", 39, 12, "Cyfarthfa Castle",
           "William Crawshay II built Cyfarthfa Castle in 1824 as a home above his ironworks, with the furnaces in plain view of the dining room. His workers could see the castle from the works, and he could see them. It became a museum and art gallery in 1910.")
    plaque(z, "merthyr", "trevithick", 55, 25, "21 February 1804",
           "Here began the first railway journey by a steam locomotive. Richard Trevithick's engine hauled ten tons of iron, five wagons and about seventy men from Penydarren to Abercynon, nearly ten miles in around four hours. It won its owner a bet of 500 guineas, then broke the cast-iron rails it ran on.")
    plaque(z, "merthyr", "rising", 44, 25, "The Merthyr Rising",
           "In June 1831 thousands of ironworkers, angry at wage cuts and unpayable debts, marched through Merthyr under a red flag, which is said to be the first time it was raised in Britain by workers in revolt. Soldiers fired on the crowd, and about two dozen protesters died.")
    plaque(z, "merthyr", "dic", 49, 25, "Dic Penderyn",
           "Richard Lewis, known as Dic Penderyn, was hanged in Cardiff on 13 August 1831 for wounding a soldier during the Rising. Many thought him innocent. His last words are said to have been 'O Arglwydd, dyma gamwedd': 'O Lord, here is injustice'.")
    plaque(z, "merthyr", "hardie", 30, 25, "Keir Hardie",
           "In 1900 Merthyr Tydfil elected James Keir Hardie, a Scot who had first gone down a mine aged ten, as one of its two MPs. He became the first leader of the Labour Party, and Merthyr kept sending him back until his death in 1915.")
    plaque(z, "merthyr", "parry", 24, 29, "Joseph Parry",
           "Joseph Parry was born in Merthyr in 1841 and worked in the ironworks as a boy. He emigrated to America and later returned to Wales. He wrote 'Myfanwy' in 1875, the love song every Welsh choir has on the bottom of its folder.")
    plaque(z, "merthyr", "ynysfach", 12, 25, "Ynysfach",
           "The Ynysfach Engine House, built in 1836, housed the great blowing engine that forced air into the furnaces of Crawshay's second ironworks. It is now the Iron Heritage Centre, and it's the last building standing of the works.")
    plaque(z, "merthyr", "market", 18, 25, "Merthyr Market",
           "Welsh markets are for cawl, Welsh cakes, secondhand books and the best conversation in town. In Merthyr Market you can buy a pair of wellies, a lamp, and a ten-minute opinion on the rugby.")
    plaque(z, "merthyr", "taffvale", 33, 31, "The Taff Vale",
           "The Taff Vale Railway opened between Merthyr and Cardiff in 1841, carrying iron and coal to the docks. It later carried the people, and the Merthyr line is still a main way into the valleys.")
    z.sign(57, 25, "Trevithick's locomotive of 1804, with a stretch of the plate-way it ran on. It was heavy and the rails were brittle. A very important failure.")

    # ---- people
    chat(z, "mer_mam", "mum", 22, 30, "Mam",
         ["Merthyr people are the friendliest in Wales, and the most argumentative. They go together.",
          "Cyfarthfa Park's lovely on a dry day. Go on, have a walk round the lake. You'll meet dippers, tits, and my sister, who feeds the swans out of spite."], facing="down")
    chat(z, "mer_busker", "choir_singer", 45, 30, "Busker",
         ["(Humming 'Myfanwy' on the pavement.) You've caught me. Joseph Parry wrote it, a Merthyr man. It's about a girl who doesn't love him back. Typical Welsh love song.",
          "Every choir in Wales sings it. They sing it at weddings, funerals, and half time."], facing="up")
    chat(z, "mer_rising", "villager_4", 49, 26, "Local",
         ["Dic Penderyn's name is on half the pubs and a lot of the walls in this town. Merthyr doesn't forget its own.",
          "They say he was innocent. Nearly two centuries on, people are still saying it, and the campaign for a pardon has never quite gone quiet."], facing="left")
    chat(z, "mer_walker", "hillwalker", 25, 14, "Park Walker",
         ["Cyfarthfa Lake was dug to feed the ironworks' water wheels. Now it feeds the ducks.",
          "The castle's much grander than the house the ironmaster needed. That was the idea. He wanted the workers to look up and see who was in charge."], facing="down")
    # trainers
    trn(z, "mer_ironworker", "Ironworker Bryn", "Ironworker", "steelworker", [("rivetling", 36), ("cutlet", 35), ("tinnet", 36)], 9, 27, "right",
        ["Merthyr iron went into bridges, rails and railways across half the world. And into a lot of cannon. I make what Merthyr makes: noise. Fancy a go?"],
        "You've got a decent temper on you. Tempered, that is.", "Cyfarthfa's blast furnaces lit up the night sky red. People said Merthyr was the only town that didn't need streetlamps.", 2800)
    trn(z, "mer_chartist", "Chartist Haf", "Radical", "poet", [("versling", 35), ("wispet", 35), ("stencilette", 36)], 41, 18, "left",
        ["A fair day's wage for a fair day's work! The vote for every man! And an end to the Court of Requests! Right, now I've got that out of my system, battle?"],
        "A fair result! Mostly.", "The Merthyr radicals asked for what we'd now call the basics. A vote, a decent wage, and not to be fined by the company shop.", 2800)
    trn(z, "mer_angler", "Angler Tegwen", "Angler", "angler", [("pupplash", 35), ("holtling", 35), ("pincray", 36)], 33, 14, "left",
        ["Nothing in the lake but roach and rumours. Shh, you'll scare them. Oh, you've scared me instead. Battle!"],
        "That's me done for the day.", "I've been fishing here since I was seven. The biggest thing I ever caught was a shopping trolley.", 2800)
    T("mer_agent", "Ironmaster's Agent", "Ironmaster's Agent", "villager_1", [("gaugelet", 36), ("bobbin", 36), ("rustelver", 37)],
      ["A steam engine on rails! Haul ten tons of iron nearly ten miles? I'll bet you five hundred guineas, no, I'll bet my reputation, that it breaks down before Quaker's Yard."],
      "Hmph. The wager's lost. Don't tell the ironmaster I said it was impressive.", "A steam engine is the future. Don't tell the horses.", 3200)
    z.npc(id="mer_agent", sprite="villager_1", x=57, y=26, facing="left", move="still", script="mer_agent")
    DLG[zid]["mer_agent"] = agent_script()
    # wild
    wild(z, [("steamlet", 35, 37, 14, {}), ("cobblet", 34, 36, 8, {}), ("tapknock", 34, 36, 8, {}), ("tinnet", 34, 36, 6, {}), ("bobbin", 34, 36, 6, {}),
             ("rivetling", 35, 37, 5, {}), ("rooklet", 33, 35, 8, {"time": ["day"]}), ("hootlet", 34, 36, 6, {"time": ["night"]}),
             ("pipkin", 33, 35, 8, {}), ("moldiwarp", 34, 36, 6, {}), ("kidgruff", 34, 36, 6, {}), ("railspark", 35, 37, 4, {}), ("penydarren", 38, 39, 2, {})])
    wild(z, [("dipling", 34, 36, 16, {}), ("holtling", 34, 36, 12, {}), ("ductling", 34, 36, 8, {}), ("stalklet", 33, 35, 8, {}), ("pupplash", 33, 35, 6, {})], "water")
    z.d["edges"] = {"south": {"to": "rhondda", "offset": 0}, "east": {"to": "blaenavon", "offset": -4}}
    z.d["spawn"] = [30, 52]
    done(z)
    z.save(OUT + "/" + zid + ".json")
    bad = reach_check(z)
    if bad:
        print("merthyr unreachable:", bad)

    # ---- interiors
    sanctuary(OUT, zid, "Merthyr", (11, 34))
    shop(OUT, zid, "Merthyr", (18, 34))
    nurse(zid, ["Shwmae, cariad! Croeso to Merthyr Sanctuary. You look like you've walked up the valley in the rain. Which you have.",
                "There we are. A cup of tea, a Welsh cake each, and a sit by the radiator, where the ironmasters never sat.",
                "Right as rain! Better than rain, actually, because rain's what we've got. Hwyl fawr, bach.",
                "The Ark's in the corner, love. It hums a bit when the trains go by. They say it hums a hymn.",
                "No bother at all. Diolch for popping in."])
    shopkeeper(zid, "Shwmae! Snares, tea, cawl and Welsh cakes. What can I get you?", "Diolch, bach. Mind the hill on the way home.")

    interior(OUT, "merthyr_cyfarthfa", "Cyfarthfa Castle", zid, (40, 11), "museum",
             [dict(id="mer_curator", sprite="poet", x=7, y=3, facing="down", move="still", script="mer_curator", name="Curator Eleri"),
              dict(id="mer_guard", sprite="villager_3", x=11, y=6, facing="left", move="still", script="mer_guard", name="Attendant")],
             w=15, h=11, furnish=False, drop=("statue",),
             extra=[P("display_case", 3, 2, variant=1), P("display_case", 11, 2, variant=2), P("wall_picture", 5, 1, walk=True), P("wall_picture", 9, 1, walk=True),
                    P("wall_picture", 7, 1, walk=True), P("table", 3, 6), P("candelabra", 13, 5), P("clock", 12, 1, walk=True), P("fireplace", 1, 1)],
             signs=[{"x": 5, "y": 3, "plaque": "merthyr_crawshay", "title": "The Crawshays",
                     "text": "The Crawshay family owned Cyfarthfa for most of the nineteenth century. William Crawshay II built the castle; his son Robert Thompson Crawshay was the last of the 'Iron Kings'. The great furnaces had gone cold by the early twentieth century."}])
    DLG["merthyr_cyfarthfa"] = {
        "mer_curator": say("Curator Eleri", "Welcome to Cyfarthfa Castle. Technically a mansion in a castle costume. Mr Crawshay had it built in 1824 with towers and battlements, because iron kings like a battlement.",
                           "Upstairs is the art gallery, and downstairs is Merthyr's history in glass cases. The Rising, the ironworks, the chapels, the choirs. We've even got a Merthyr rugby shirt from 1895.",
                           "It was a school for years, before it was a museum. Hundreds of Merthyr children did their sums where the ironmaster once ate his breakfast."),
        "mer_guard": say("Attendant", "Don't touch the cases, please. The cannon was made at Cyfarthfa. They cast the barrels solid, then bored them out on a lathe, and a lot of iron went to Wellington's armies.",
                         "There's a ghost, apparently, but she's very shy. Only comes out when the visitors go home.")}

    interior(OUT, "merthyr_ynysfach", "Ynysfach Engine House", zid, (8, 25), "museum",
             [dict(id="mer_ironguide", sprite="tour_guide", x=6, y=3, facing="down", move="still", script="mer_ironguide", name="Bryn, Iron Heritage guide")],
             furnish=False, drop=("statue",),
             extra=[P("display_case", 3, 2, variant=1), P("display_case", 9, 2, variant=2), P("slate_heap", 1, 5), P("slate_heap", 11, 5, variant=1),
                    P("wall_map", 6, 1, walk=True), P("clock", 4, 1, walk=True), P("table", 2, 6)],
             signs=[{"x": 8, "y": 5, "plaque": "merthyr_penydarren", "title": "The Penydarren Engine",
                     "text": "Trevithick's locomotive was a high-pressure steam engine with one horizontal cylinder let into the boiler, a tall chimney and a great flywheel. The exhaust steam was turned up the chimney to make the fire draw, which was a clever trick. It was the first of its kind to haul a load on rails."}])
    DLG["merthyr_ynysfach"] = {"mer_ironguide": wager_script()}

    interior(OUT, "merthyr_chapel", "Soar Chapel", zid, (36, 25), "church",
             [dict(id="mer_sexton", sprite="villager_2", x=5, y=2, facing="down", move="still", script="mer_sexton", name="Sexton")],
             w=11, h=10, furnish=False,
             extra=[P("piano", 8, 2), P("wall_picture", 5, 1, walk=True)])
    DLG["merthyr_chapel"] = {"mer_sexton": say("Sexton", "Soar. 'Zoar' in the Bible, 'Soar' in Welsh. It's a refuge, a little place of safety, the place Lot ran to.",
                                                 "Welsh chapels held hundreds. They were what the valleys had instead of a theatre, a concert hall and a debating society. Sunday school, Cymanfa Ganu, the lot.",
                                                 "A Cymanfa Ganu is a hymn-singing festival. Everyone sings, in four parts, without conductor or rehearsal. It's the loudest thing in Wales. Louder than the rugby, if the rugby's going badly.")}

    interior(OUT, "merthyr_pub", "Y Dic Penderyn", zid, (46, 25), "cafe",
             [dict(id="mer_landlord", sprite="shopkeeper", x=3, y=1, facing="down", move="still", script="mer_landlord", name="Emlyn the landlord"),
              dict(id="mer_regular", sprite="tin_miner", x=4, y=5, facing="left", move="still", script="mer_regular", name="Regular")],
             w=11, h=9, furnish=False,
             extra=[P("table", 7, 3), P("kettle_table", 1, 5), P("menu_board", 6, 1, walk=True), P("tea_urn", 1, 3), P("wall_picture", 9, 1, walk=True)],
             signs=[{"x": 5, "y": 2, "plaque": "merthyr_pubrising", "title": "The Landlord's Corner",
                     "text": "Every pub in Merthyr has a view on the Rising, and most of them are on the wall. The 1831 march ended in front of the Castle Inn, where the soldiers were lodged. The old inn is long gone, but the name, and the grievance, have stuck."}])
    DLG["merthyr_pub"] = {"mer_landlord": landlord_script(),
                          "mer_regular": say("Regular", "Chwarae teg, that's fair play, and you've not had a drink so you're playing fair. I'll have yours.",
                                             "There's a pub quiz on Thursdays. Tough one. The local history round has a question about every single ironmaster and a different one about what they did to their workers.")}

    interior(OUT, "merthyr_market", "Merthyr Market", zid, (20, 25), "hall",
             [dict(id="mer_cook", sprite="shopkeeper", x=3, y=3, facing="down", move="still", script="mer_cook", name="Cawl stall"),
              dict(id="mer_shopper", sprite="villager_5", x=9, y=5, facing="left", move="still", script="mer_shopper", name="Shopper")],
             w=13, h=10, furnish=False, drop=("statue", "table"),
             extra=[P("market_stall", 2, 2), P("market_stall", 4, 2), P("market_stall", 8, 2), P("market_stall", 10, 2), P("market_stall", 2, 5), P("market_stall", 10, 6),
                    P("menu_board", 6, 1), P("bunting", 3, 1, variant=1, walk=True), P("bunting", 9, 1, variant=2, walk=True), P("kettle_table", 11, 3), P("clock", 7, 1, walk=True)])
    DLG["merthyr_market"] = {
        "mer_cook": say("Cawl stall", "Cawl: lamb, leeks, swede, potatoes, carrots and patience. Better the next day, they say, but nobody ever lets it last till the next day.",
                        "In the old days you ate it with bread and cheese on the side, and a spoon you'd had since your wedding.") + [{"do": "shop", "id": "merthyr_market_stall"}]
        + say("Cawl stall", "Diolch, bach. Eat it hot."),
        "mer_shopper": say("Shopper", "I come for the cheese and leave with a pair of wellies, a lamp and three secondhand books. They all work out, somehow.",
                           "Glamorgan sausage is a vegetarian sausage, you know. Cheese, leeks and breadcrumbs. They used to make it with real sausage; Glamorgan said no thank you.")}

    interior(OUT, "merthyr_library", "Merthyr Tydfil Library", zid, (28, 25), "library",
             [dict(id="mer_librarian", sprite="poet", x=6, y=3, facing="down", move="still", script="mer_librarian", name="Librarian"),
              dict(id="mer_student", sprite="student", x=3, y=6, facing="right", move="still", script="mer_student", name="Student")],
             furnish=False,
             extra=[P("table", 4, 6), P("table", 8, 6), P("wall_picture", 5, 1, walk=True), P("clock", 6, 1, walk=True), P("potted_plant", 1, 1)])
    DLG["merthyr_library"] = {"mer_librarian": say("Librarian", "Shh. Well, quietly. This is Merthyr's library, and before that it was the reading room of an institute that the iron workers' pennies paid for.",
                                                    "We keep the local history archive. Letters, tickets, the lot. There's a copy of the 1831 report on the Rising that I'm not allowed to take home. I've asked."),
                             "mer_student": say("Student", "I'm writing an essay on Keir Hardie. He was a miner at ten, a union man, then an MP for Merthyr from 1900. Hardie told Parliament about the poor and was told to sit down.",
                                                "That's essay-writing: three paragraphs of passion and one of footnotes.")}


def landlord_script():
    found = Q + "choir_2"
    ask = [{"do": "say", "who": "Emlyn", "text": "Second tenor? Me? Aye, I sing. But I'll be damned if I give my voice for free. Answer this: who wrote 'Myfanwy', Merthyr's own?"},
           {"do": "choice", "text": "Who wrote 'Myfanwy'?", "options": ["Joseph Parry", "Ivor Novello", "Daniel James", "Edward Elgar"], "set": "_emlyn_q"},
           {"do": "if", "flag": "_emlyn_q", "eq": 0,
            "then": say("Emlyn", "Joseph Parry! Born a stone's throw from the bar. I'll sing. And I'll bring half the regulars, they'll sing too whether they like it or not.")
                    + [setf(found), {"do": "sfx", "id": "item"},
                       {"do": "say", "who": "", "text": "You found a second tenor for the eisteddfod choir."}],
            "else": say("Emlyn", "No, bach. Elgar's English. Think of the busker outside the pub: he's humming it. Come back when you know.")}]
    return [flag_if(found, say("Emlyn", "Saturday at Bethania. I've written it on the bar. Mind, it's written under a pint."),
                    [flag_if(Q + "choir_started", ask,
                             say("Emlyn", "Y Dic Penderyn, the pub. Named for the Merthyr boy hanged in Cardiff in 1831. We don't have a statue in here, just a very big portrait and a very strong opinion.",
                                 "I'm a second tenor on a good night. If there's ever a choir that needs one, ask."))])]


def wager_script():
    s = Q + "wager_"
    return [flag_if(Q + "wager_done",
                    say("Bryn", "A fine wager, and a fine win, and in two hundred years we've yet to stop telling it."),
                    [flag_if(s + "3",
                             say("Bryn", "Beat Crawshay's man at his own game! The engine made it to Abercynon, the iron's all delivered, and I'd say the bet's won. Five hundred guineas. Here, a keepsake for you.",
                                 "And a bar of Penydarren pig iron, cast right here. It's heavy, mind. Put it in the right pocket.")
                             + [{"do": "give_item", "item": "wager_guinea", "n": 1}, {"do": "give_item", "item": "penydarren_pig", "n": 2},
                                {"do": "standing", "nation": "wales", "amount": 8}, setf(Q + "wager_done")],
                             [flag_if(s + "2",
                                      say("Bryn", "Steam, coal and a creature to fire it. Now the wager. Go and find Crawshay's agent at the tramroad plinth by the main street. He's the one who doesn't believe in engines."),
                                      [flag_if(s + "1",
                                               [{"do": "when", "cond": "has_steamlet",
                                                 "then": say("Bryn", "A Steamlet! And in good fettle too. It'll do. They're all over the valley, chuffing around the old tramroad. Right: coal, check. Creature, check.",
                                                             "Now for the agent. Crawshay's man will say it can't be done. Go and show him. He's waiting at the plinth by the main street, next to Trevithick's locomotive.")
                                                         + [setf(s + "2")],
                                                 "else": say("Bryn", "You've got the coal. Now you need something to burn it. Steamlets live around the old tramroad and the park. Catch one and come back.")}],
                                               [flag_if(s + "started",
                                                        say("Bryn", "Coal first. Dai at the Rhondda Heritage Park in the valley has the best Rhondda steam coal. Ask him, tell him it's for Trevithick's wager."),
                                                        say("Bryn", "Bore da. Bryn, Iron Heritage guide. I'll tell you a story. On 21 February 1804 a Cornishman named Trevithick took a steam locomotive from Penydarren ironworks along the tramroad to Abercynon.",
                                                            "It hauled ten tons of iron, five wagons and seventy men, nearly ten miles, in about four hours. Samuel Homfray, the Penydarren ironmaster, had bet 500 guineas that it could. And it did.",
                                                            "I want to see it done again. Not with real iron. With a real creature. We'll need three things: steam coal from the Rhondda, a Steamlet to fire the boiler, and somebody to see off the doubting agent. Interested?")
                                                        + [setf(s + "started")])])])])])]


def agent_script():
    s = Q + "wager_"
    won = "trainer_mer_agent"
    return [flag_if(s + "3", say("Ironmaster's Agent", "I stand corrected. Don't tell Mr Crawshay. I'd be dismissed. He'd say it was pure Cyfarthfa spite."),
                    [flag_if(s + "2",
                             [{"do": "battle", "trainer": "mer_agent", "intro": True}, flag_if(won, [setf(s + "3")])],
                             say("Ironmaster's Agent", "Another gawper? That engine'll never go anywhere. Five hundred guineas says it breaks the rails before the first bend."))])]
