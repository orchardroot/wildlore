from lib import *

WEATHER = {"clear": 36, "sunshine": 38, "fog": 6, "drizzle": 6, "gale": 10, "downpour": 4}
LEGEND = {'g': {'tile': 'grass', 'colour': '#b9ad6a'}, 'k': {'tile': 'tall_grass', 'colour': '#9c9452'},
          'c': {'tile': 'cobbles', 'colour': '#e4d9bd'}, 'a': {'tile': 'path', 'colour': '#eadfc2'}}
BASIC = ["cup_of_tea", "flask_of_tea", "buxton_water", "smelling_salts", "kendal_mint_cake", "wicker_snare", "iron_snare",
         "night_snare", "water_snare", "silver_snare", "lavender_sachet"]


def build():
    z = Zone("la_linea", "La Línea de la Concepción", 64, 52, kind="town", region="overseas_la_linea", music="town_city",
             stage="town", weather=WEATHER, legend=LEGEND)
    z.rect(0, 0, 64, 2, 'P')
    z.rect(0, 2, 7, 50, '$'); z.rect(7, 2, 1, 48, 'w'); z.rect(8, 2, 2, 48, 's')
    z.rect(62, 2, 2, 50, 'P')
    z.rect(7, 50, 55, 2, 'F'); z.rect(0, 50, 7, 2, '$')
    # dry scrub on the old neutral ground and round the edge of town
    z.rect(12, 3, 11, 8, 'k'); z.rect(40, 3, 19, 7, 'k'); z.rect(44, 43, 16, 6, 'k'); z.rect(11, 44, 6, 5, 'k')
    z.rect(16, 20, 29, 10, 'c')            # the Plaza de la Iglesia
    z.rect(10, 33, 54, 3, 'a')              # the street east to the Levante beach
    z.rect(26, 30, 3, 22, '=')              # the avenue from the frontier
    z.rect(18, 42, 8, 6, 'c')               # the frontier forecourt, west of the road
    church = z.building(23, 12, 11, 8, "andaluz_church", "Iglesia de la Inmaculada", door=5)
    pena = z.building(37, 14, 6, 4, "andaluz_house", "Peña Flamenca", door=3)
    club = z.building(46, 21, 8, 4, "andaluz_house", "Frontier Workers' Club", door=4)
    market = z.building(10, 21, 6, 5, "andaluz_house", "Mercado", door=3)
    tapas = z.building(12, 37, 7, 4, "andaluz_house", "Bar Pilar", door=3)
    sanct = z.building(31, 37, 6, 4, "andaluz_house", "Sanctuary", door=3)
    ultra = z.building(39, 37, 6, 4, "andaluz_house", "Ultramarinos", door=3)
    for bx, by, bw, bh in [(10, 13, 6, 4), (46, 13, 6, 4), (54, 13, 6, 4), (55, 21, 6, 4), (20, 37, 5, 4), (47, 37, 6, 4), (54, 37, 6, 4)]:
        z.building(bx, by, bw, bh, "andaluz_house")
    z.building(30, 44, 6, 3, "frontier_post", "Spanish Frontier Post")
    for x, y in [(17, 21), (43, 21), (17, 28), (43, 28), (30, 31), (24, 31)]:
        z.prop("palm", x, y)
    for x, y in [(20, 24), (38, 24)]:
        z.prop("bench", x, y)
    for x in [12, 22, 36, 48, 58]:
        z.prop("lamp_post", x, 32)
    z.prop("market_stall", 34, 27, variant=2); z.prop("market_stall", 36, 27, variant=4)
    z.prop("planter", 22, 21); z.prop("planter", 34, 21)
    z.spawn = (27, 48)

    z.sign(29, 36, "GIBRALTAR, straight on through the frontier. PLAYA DE LEVANTE, east along the street. The Rock is the big grey thing you can't miss.")
    z.sign(31, 21, "La Línea takes its name from a line: the Línea de Contravalación, a row of Spanish forts and walls built across the isthmus in the 1730s to hem in British Gibraltar. 'De la Concepción' is for the Immaculate Conception, the town's patron. The forts were blown up in 1810, during the war against Napoleon, so the French could not use them against the Rock.",
           "la_linea_name", "Why 'the Line'")
    z.sign(24, 46, "In June 1969 General Franco's government shut the frontier. For thirteen years families on either side could only wave and shout across the fence, and the way to Gibraltar was a ferry to Tangier, in Morocco, and another one back. The gate opened to people on foot in December 1982, and to everything in February 1985.",
           "la_linea_closure", "The Closed Frontier")
    z.sign(22, 43, "Spain ceded Gibraltar to Britain in the Treaty of Utrecht in 1713 and has asked for it back ever since. Gibraltarians voted 12,138 to 44 to stay British in 1967, and turned down shared sovereignty in 2002. Feelings run deep on both sides of the fence. Most people in the queue just want it to move.",
           "la_linea_two_views", "Two Views of the Rock")
    z.sign(37, 47, "Every working day, thousands of people walk, ride or drive from La Línea and the towns round the bay to jobs on the Rock: shops, building sites, hotels, care homes and the port. Gibraltar leans on their work, and La Línea's high street leans on their wages. The queue is the town's tide: out at dawn, back at dusk.",
           "la_linea_workers", "The Frontier Workers")
    z.sign(30, 41, "Step over the line and the money changes. Gibraltar runs on its own pounds and sterling, at par; Spain has used the euro since 2002, when it replaced the peseta. Plenty of shops near the frontier will take either, at a rate that suits the shop. Change your money at a bureau and you'll see the difference.",
           "la_linea_money", "Two Moneys, One Queue")
    z.sign(36, 48, "Gibraltar keeps Central European Time, like Spain, an hour ahead of London. So the clocks don't change at the frontier. They change at the airport, which confuses everyone who flew in.",
           "la_linea_clock", "The Same Clock as the Rock")
    z.sign(17, 41, "In Andalusia a tapa is a small plate that comes with, or next to, a drink. Round the bay look for pescaíto frito, little fried fish, and tortillitas de camarones, crisp fritters full of tiny shrimp, a Cádiz speciality. Tapa means 'lid', and one story says the first ones were slices of bread laid over a glass to keep out the flies.",
           "la_linea_tapas", "A Tapa")
    z.sign(9, 30, "The Spanish call it the Bahía de Algeciras and the British the Bay of Gibraltar: the same water, two names. Dolphins feed in it all year, and big ships wait at anchor to take on fuel. On a clear day you can see Africa past the end of the Rock.",
           "la_linea_bay", "One Bay, Two Names")
    z.sign(45, 26, "Listen in the queue and you'll hear Llanito, the everyday talk of Gibraltar: Andalusian Spanish and English swapped mid-sentence, with words picked up from the many peoples who settled on the Rock. 'Oye, I'll see you later, ¿vale?' is a perfectly good Llanito goodbye.",
           "la_linea_llanito", "Llanito")
    z.sign(43, 18, "Flamenco is Andalusian: song (cante), guitar (toque) and dance (baile), with handclaps (palmas) keeping the rhythm. Gitano families, the Roma of Spain, shaped it over centuries. UNESCO added it to its list of the world's intangible cultural heritage in 2010. A peña is a club where people who love it meet to listen.",
           "la_linea_flamenco", "Flamenco")
    z.sign(23, 49, "In the 2016 referendum Gibraltar voted 96 per cent to stay in the European Union, more than anywhere else that voted. The UK left anyway, in 2020, and since then Britain, Spain and the EU have had to work out how this frontier should run. Ask anyone in the queue for their view. Then allow an hour.",
           "la_linea_brexit", "After Brexit")

    z.npc("lal_carmen", "commuter", 25, 45, "right", script="lal_carmen", name="Carmen")
    z.npc("lal_guard", "rail_guard", 29, 47, "left", script="lal_guard", name="Frontier Officer")
    z.npc("lal_driver", "rocker", 24, 48, "right", trainer="lal_driver")
    z.npc("lal_paco", "commuter", 20, 46, "right", trainer="lal_paco")
    z.npc("lal_abuela", "villager_3", 21, 23, "down", script="lal_abuela", name="Abuela")
    z.npc("lal_llanito", "villager_1", 40, 34, "down", script="lal_llanito", name="Gibraltarian Neighbour")
    z.npc("lal_fan", "jogger", 35, 30, "left", trainer="lal_fan")
    z.npc("lal_kid", "villager_6", 31, 26, "down", script="lal_kid", name="Kid with a Ball")
    z.npc("lal_cambio", "commuter", 37, 42, "down", script="lal_cambio", name="Bureau Clerk")
    z.npc("lal_macaque", "tour_guide", 18, 31, "right", script="lal_macaque", name="Tour Guide")

    Q = "q_overseas_la_linea_"
    z.dialogue["lal_carmen"] = [
        iff(Q + "done", [say("Carmen", "Thank you again. Mamá says you're welcome at the bar any time, and she means it, which is rare.")], [
            iff(Q + "2", [iff("trainer_lal_driver", [
                say("Carmen", "My tortilla! Still warm, too. You're a saint. And the man in the van behind me has stopped shouting, so I think that was you as well."),
                say("Carmen", "Here, from Mamá's kitchen and from me. Off I go: I'll be on the Rock in ten minutes, if the planes behave."),
                setf(Q + "3"), setf(Q + "done"), give("tortillitas_camarones", 3), give("churros_chocolate", 2), standing(10)],
                [say("Carmen", "You've got it! But the van driver behind me says nobody's passing anything up this queue without going through him. He's the man in the leather jacket. Please, settle it, or I'll be late.")])],
                [iff(Q + "1", [say("Carmen", "The bar's on the street, Bar Pilar, by the market. Ask for my mother, and say Carmen forgot her lunch again. She'll roll her eyes. That's normal.")],
                     [say("Carmen", "¡Ay, no! I've left my lunch at my mother's bar. If I step out of the queue I lose my place, and my shift at the care home starts at eight."),
                      say("Carmen", "I've crossed this frontier every working day for nineteen years. Would you run to Bar Pilar for me? It's just up the avenue, next to the market."),
                      setf(Q + "started"), setf(Q + "1")])])])]
    z.dialogue["lal_guard"] = [
        say("Frontier Officer", "Buenos días. Pasaporte, por favor. That's 'passport, please', and it's the most useful Spanish you'll learn today."),
        say("Frontier Officer", "Since Brexit, British passports get a closer look on this side. Gibraltar checks you on its side and we check you on ours. It's very thorough, and very slow."),
    ]
    z.dialogue["lal_abuela"] = [
        say("Abuela", "In 1969 I was nineteen and my novio worked on the Rock. One morning they shut the gate, and that was that."),
        say("Abuela", "We used to stand at the fence on a Sunday and shout across. You learn to shout very clearly. When the gate opened in 'eighty-two I cried, and then I went shopping, like everybody else."),
        say("Abuela", "Did I marry him? No. I married a man from Algeciras. But I still shout very clearly."),
    ]
    z.dialogue["lal_llanito"] = [
        say("Gibraltarian Neighbour", "I'm from Gib, but flats over there cost a fortune, so I live here and cross to work. Lots of us do. It's the frontier in reverse."),
        say("Gibraltarian Neighbour", "At home we speak Llanito. Like, 'Oye, I'm going to Morrisons, ¿quieres algo?' English, Spanish, whatever word gets there first."),
    ]
    z.dialogue["lal_kid"] = [
        say("Kid with a Ball", "My team is La Balona, Real Balompédica Linense. My cousin in Gibraltar supports a team in England he's never seen."),
        say("Kid with a Ball", "I told him that's mad. He said at least his team wins. I don't talk to him now."),
    ]
    z.dialogue["lal_cambio"] = [
        say("Bureau Clerk", "Euros this side of the line. I'll change your pounds at the day's rate, less my bit. Don't change Gibraltar notes on the mainland: nobody here wants them back."),
        {"do": "bureau"},
    ]
    z.dialogue["lal_macaque"] = [
        say("Tour Guide", "Everyone asks me where the monkeys are. They're Barbary macaques, they live on the Upper Rock, and they don't come through the frontier. They don't need a passport. They just don't fancy it."),
        say("Tour Guide", "The ones on the Rock are Europe's only wild monkeys. On this side we have to make do with pigeons and men selling sunglasses."),
    ]

    trainer("lal_driver", "Van Driver", "Commuter", "rocker", [("binfox", 96), ("pierlord", 96), ("stoopfalcon", 97)],
            ["You! Are you in the queue or not? I've been here since half six. I'll fight you for your place.",
             "And don't tell me about the planes. I know about the planes."],
            "Fine. Fine! Have the place. I'll be here till Christmas anyway.",
            "The trick is to go at lunchtime. Nobody goes at lunchtime. Except everybody.")
    trainer("lal_paco", "Paco, Thirty Years of Queues", "Local Legend", "commuter",
            [("bayrunner", 98), ("stoopfalcon", 98), ("levanter", 98), ("duneskink", 98), ("chameleer", 98), ("macaquet", 98)],
            ["Thirty years I've crossed this line, morning and evening. Through the closure stories, the gate, the euro, Brexit. I've seen everything a queue can do.",
             "My team has waited in every queue with me. Patience is a weapon, you know."],
            "Thirty years and you're the first to beat me before the barrier went up. Respect.",
            "When the gate opened in 'eighty-five, my father walked me through and said: 'Remember this.' I remember it every morning, about ten past seven.", money=9000)
    trainer("lal_fan", "La Balona Fan", "Football Fan", "jogger", [("chipgull", 96), ("moggle", 96), ("parakit", 97)],
            ["Real Balompédica Linense! La Balona! The pride of La Línea! Do you want to fight about it?"],
            "We'll get you next season. We always say that.",
            "Being a fan of a small club is good for you. It teaches hope, patience and how to eat a sandwich in the rain.")

    # ---- interiors
    ins = []
    s = sanctuary(z, sanct, "la_linea_sanctuary", "La Línea Sanctuary",
                  ["Hola, buenas. La Línea Sanctuary. If it's the sun, sit in the shade first; if it's the queue, there's no cure.",
                   "Pop them down here. We get the whole bay: Gibraltar, Algeciras, the odd lost tourist from Marbella.",
                   "Todo bien, all done. Drink water, wear a hat, and don't eat churros on an empty stomach. Actually, do.",
                   "The Ark's through the back. It's cooler there, which is why the doctor is always in it.",
                   "Tranquilo. No rush. Nothing in Andalusia happens before the coffee."])
    ins.append(s)
    shopid = "la_linea_ultramarinos"
    dump("data/shops/%s.json" % shopid, {"id": shopid, "name": "Ultramarinos, La Línea",
                                       "stock": BASIC + ["pasty", "soda_bread", "calentita", "tortillitas_camarones", "churros_chocolate", "pescaito_frito"]})
    ins.append(shop(z, ultra, "la_linea_shop", "Ultramarinos", shopid,
                    "Buenas. Ultramarinos means 'from overseas': these shops once sold goods from the colonies. Now it's mostly crisps. What'll it be?",
                    "Gracias, and hasta luego. That means 'see you later', and here it nearly always does.", who="Grocer"))
    t = interior(z, tapas, "la_linea_tapas", "Bar Pilar", w=11, h=9, counter=(2, 2, 6),
                 props=[{"type": "table", "x": 6, "y": 5}, {"type": "table", "x": 8, "y": 5}, {"type": "table", "x": 2, "y": 5},
                        {"type": "menu_board", "x": 6, "y": 1, "walk": True}, {"type": "wall_picture", "x": 2, "y": 1, "walk": True, "variant": 1},
                        {"type": "barrel", "x": 9, "y": 1}, {"type": "clock", "x": 8, "y": 1, "walk": True}],
                 npcs=[npcd("lal_pilar", "shopkeeper", 4, 1, script="lal_pilar", name="Pilar"),
                       npcd("lal_waiter", "villager_2", 7, 3, script="lal_waiter", name="Camarero"),
                       npcd("lal_regular", "villager_5", 3, 5, "right", script="lal_regular", name="Regular")])
    t.dialogue["lal_pilar"] = [
        iff(Q + "done", [say("Pilar", "Carmen rang. She says you're a treasure. I say she should write her lunch on her hand.")], [
            iff(Q + "1", [
                iff(Q + "2", [say("Pilar", "Go on, before it gets cold! And if that van man is still shouting, you have my permission to shout back.")], [
                    say("Pilar", "Carmen forgot her lunch again? Of course she did. Here: tortilla, bread and an orange. She's thirty-eight and I still pack it."),
                    say("Pilar", "When they shut the frontier in 1969 my mother lost her job on the Rock overnight. Thousands did. So when it opened again, I said: my children will cross it every day, and they'll have a good lunch doing it."),
                    say("Pilar", "Mind the van driver at the back of the queue. He's been there since dawn and he's in a mood. You may have to settle it the usual way."),
                    setf(Q + "2")])],
                [say("Pilar", "Buenas. Sit down, have a caña. That's a small beer, the small one, because it's hot and you're not on holiday. Or you are. Either way."),
                 say("Pilar", "The tortillitas are from my grandmother's recipe. Chickpea flour, shrimp, a little onion and parsley. And a fryer older than me.")])])]
    t.dialogue["lal_waiter"] = [
        say("Camarero", "If you want to order like a local: 'Una caña, por favor', a small beer, please. 'La cuenta, por favor', the bill, please. 'Gracias', thanks."),
        say("Camarero", "And 'buenas'. Round here we drop the rest of 'buenos días' and just say 'buenas'. It saves energy for the important things, like lunch."),
    ]
    t.dialogue["lal_regular"] = [
        say("Regular", "Lunch here is at three. Dinner is at ten. Tea is at nobody-knows. You'll adjust."),
        say("Regular", "In summer the whole town comes out after dark, when it's cool. Children on the plaza at midnight, grandmothers on chairs in the street. It's the best part of the day."),
    ]
    ins.append(t)
    m = interior(z, market, "la_linea_market", "Mercado", w=13, h=9, counter=(2, 3, 9),
                 props=[{"type": "market_stall", "x": 2, "y": 1, "variant": 0}, {"type": "market_stall", "x": 6, "y": 1, "variant": 1},
                        {"type": "market_stall", "x": 10, "y": 1, "variant": 3}, {"type": "barrel", "x": 1, "y": 6}, {"type": "barrel", "x": 11, "y": 6}],
                 npcs=[npcd("lal_fishmonger", "fisherman_north", 3, 2, script="lal_fishmonger", name="Fishmonger"),
                       npcd("lal_jamon", "shopkeeper", 8, 2, script="lal_jamon", name="Ham Seller"),
                       npcd("lal_shopper", "villager_4", 9, 5, "left", script="lal_shopper", name="Shopper")])
    m.dialogue["lal_fishmonger"] = [
        say("Fishmonger", "Atún rojo, bluefin tuna, from the almadraba. That's a maze of nets the fishermen of the Cádiz coast have set in the sea since ancient times, to catch the tuna as they come through the Strait each spring."),
        say("Fishmonger", "A big one weighs more than a horse. I don't sell them whole. I'm strong, but I'm not stupid."),
    ]
    m.dialogue["lal_jamon"] = [
        say("Ham Seller", "Jamón ibérico, from black Iberian pigs. The best ones spend their last autumn eating acorns under the oaks. Sliced so thin you can read the paper through it."),
        say("Ham Seller", "A whole leg takes years to cure. Like a good friendship. Or a planning application."),
    ]
    m.dialogue["lal_shopper"] = [
        say("Shopper", "I shop on this side and work on that side. Bread's cheaper here, petrol's cheaper there. My whole life is a spreadsheet with a fence across it."),
    ]
    ins.append(m)
    ch = interior(z, church, "la_linea_church", "Iglesia de la Inmaculada Concepción", w=11, h=11,
                  props=[{"type": "candelabra", "x": 3, "y": 1}, {"type": "candelabra", "x": 7, "y": 1},
                         {"type": "bench", "x": 2, "y": 4}, {"type": "bench", "x": 8, "y": 4}, {"type": "bench", "x": 2, "y": 6}, {"type": "bench", "x": 8, "y": 6},
                         {"type": "potted_plant", "x": 1, "y": 8}, {"type": "potted_plant", "x": 9, "y": 8}],
                  npcs=[npcd("lal_sacristan", "pilgrim", 5, 2, script="lal_sacristan", name="Sacristan"),
                        npcd("lal_bride", "festival_goer", 4, 7, "up", script="lal_bride", name="Visitor")])
    ch.dialogue["lal_sacristan"] = [
        say("Sacristan", "The town is named for the Immaculate Conception, and her feast day, the eighth of December, is a holiday all over Spain. Here it's ours twice over."),
        say("Sacristan", "Semana Santa, Holy Week, is the big one in Andalusia: brotherhoods carry great floats of the Virgin through the streets at night, very slowly, to drums. Even the people who never come to Mass come to watch."),
    ]
    ch.dialogue["lal_bride"] = [
        say("Visitor", "My grandparents married here in 1971, the year the frontier was shut. Half the family watched from the other side of the fence. They waved the whole way through the vows."),
    ]
    ins.append(ch)
    p = interior(z, pena, "la_linea_pena", "Peña Flamenca", w=11, h=9,
                 props=[{"type": "hall_stage", "x": 4, "y": 1}, {"type": "stacked_chairs", "x": 1, "y": 1}, {"type": "table", "x": 2, "y": 5},
                        {"type": "table", "x": 8, "y": 5}, {"type": "wall_picture", "x": 8, "y": 1, "walk": True, "variant": 3}],
                 npcs=[npcd("lal_guitarist", "bard", 5, 3, trainer="lal_guitarist"),
                       npcd("lal_singer", "choir_singer", 7, 3, script="lal_singer", name="Cantaora")])
    p.dialogue["lal_singer"] = [
        say("Cantaora", "Flamenco isn't a show for tourists, not in here. It's how people sang about poverty, love, prison and the sea. Cante jondo, deep song."),
        say("Cantaora", "When it's really good, we say it has duende: a shiver, a something, that you can't explain. You'll know it if you hear it. The palmas, the handclaps, keep the compás, the rhythm. Clap on the wrong beat and everyone will look at you."),
    ]
    trainer("lal_guitarist", "Tocaor", "Flamenco Guitarist", "bard", [("swiftlet", 96), ("graftling", 96), ("thornwyn", 97), ("chameleer", 97)],
            ["Six strings, five fingers and a rhythm in twelve beats. Shall we see if you can keep up?"],
            "Olé. You kept the compás. Mostly.",
            "A flamenco guitarist taps the wood of the guitar as well as the strings. It's called golpe. My neighbours call it something else.")
    ins.append(p)
    c = interior(z, club, "la_linea_club", "Frontier Workers' Club", w=11, h=9,
                 props=[{"type": "card_table", "x": 2, "y": 4}, {"type": "card_table", "x": 7, "y": 4}, {"type": "noticeboard", "x": 2, "y": 1, "walk": True},
                        {"type": "tea_urn", "x": 8, "y": 1}, {"type": "wall_map", "x": 5, "y": 1, "walk": True}],
                 npcs=[npcd("lal_pensioner", "villager_5", 3, 3, script="lal_pensioner", name="Retired Bricklayer"),
                       npcd("lal_moroccan", "villager_2", 7, 3, script="lal_moroccan", name="Visitor from the Rock"),
                       npcd("lal_teacher_es", "student", 4, 6, "right", script="lal_teacher_es", name="Spanish Teacher")])
    c.dialogue["lal_pensioner"] = [
        say("Retired Bricklayer", "I laid bricks on the Rock from 1962. In June 1969 they closed the gate and I had no job the next morning. Neither did thousands of us."),
        say("Retired Bricklayer", "Some went to work in Germany, some to the shipyards. I went to Algeciras, then back to the Rock in 'eighty-five, older and slower. The walls I built are still standing. I check."),
    ]
    c.dialogue["lal_moroccan"] = [
        say("Visitor from the Rock", "When the Spanish workers could no longer cross, Gibraltar brought in workers from Morocco. I came over in 1970 and stayed fifty years."),
        say("Visitor from the Rock", "So I'm part of the story too. A frontier closes in one place and a ferry opens in another. I come here on Fridays for the cards, and because the coffee's better. Don't tell Gibraltar."),
    ]
    c.dialogue["lal_teacher_es"] = [
        say("Spanish Teacher", "¡Hola! I teach English to the workers and Spanish to the visitors, so everyone in this room owes me money."),
        say("Spanish Teacher", "Start with 'hola', hello, and 'buenas', the lazy Andalusian good day. 'Por favor' is please, 'gracias' is thanks, and 'perdón' gets you through any queue."),
        say("Spanish Teacher", "Andalusians often drop the 's' at the end of a word: 'gracias' can come out like 'gracia'. Don't correct them. You're the one with the accent here."),
    ]
    ins.append(c)

    # ---- the beach and the old Spanish lines, east
    lv = Zone("la_linea_levante", "Playa de Levante", 44, 40, kind="route", region="overseas_la_linea", music="route_coast",
              stage="coast", weather=WEATHER, legend=LEGEND)
    lv.rect(0, 0, 44, 2, 'P'); lv.rect(0, 38, 44, 2, 'P'); lv.rect(0, 0, 2, 40, 'P')
    lv.rect(28, 2, 7, 36, 's'); lv.rect(35, 0, 1, 40, 'w'); lv.rect(36, 0, 8, 40, '$')
    lv.rect(0, 17, 28, 3, 'a')
    lv.rect(4, 3, 9, 6, 'k'); lv.rect(15, 4, 10, 9, 'k'); lv.rect(5, 10, 7, 5, 'k')
    lv.rect(6, 25, 12, 10, 'k'); lv.rect(20, 23, 6, 12, 'k')
    lv.building(10, 20, 9, 3, "fort_ruin", "Fuerte de Santa Bárbara")
    for x, y in [(30, 22), (32, 27), (31, 31)]:
        lv.prop("boat", x, y)
    lv.prop("lobster_pots", 29, 25)
    lv.prop("palm", 26, 15); lv.prop("palm", 26, 21)
    lv.spawn = (2, 18)
    lv.sign(19, 21, "These sandstone stubs are what's left of Fort Santa Bárbara, the eastern end of the Spanish line across the isthmus, built in the 1730s. In 1810, with Napoleon's armies marching south, the forts were blown up so the French could not turn them on Gibraltar. Spain and Britain were allies that year, which doesn't happen every century.",
            "la_linea_santa_barbara", "Fort Santa Bárbara")
    lv.sign(26, 16, "The levante is the east wind that funnels through the Strait. When it blows, damp air piles up against the Rock and pours over the top as a long white cloud, the Levanter, while the town underneath sits in a grey, sticky gloom. The west wind, the poniente, brings the clear days.",
            "la_linea_levante_wind", "The Levante")
    lv.sign(29, 20, "La Atunara is La Línea's old fishing quarter on the Mediterranean shore, and takes its name, people say, from the tuna. Small boats still go out from the beach for sardines, mackerel and whatever the sea is in the mood to give.",
            "la_linea_atunara", "La Atunara")
    lv.sign(30, 34, "Just south of here the Strait of Gibraltar narrows to about fourteen kilometres between Europe and Africa. Every spring and autumn white storks, eagles and kites ride the warm air across it in their tens of thousands, because a soaring bird hates flapping over open sea.",
            "la_linea_strait", "Fourteen Kilometres to Africa")
    lv.npc("lal_fisher", "fisherman_north", 31, 24, "left", script="lal_fisher", name="Atunara Fisherman")
    lv.npc("lal_birder", "birdwatcher", 20, 10, "down", trainer="lal_birder")
    lv.npc("lal_angler", "angler", 33, 14, "right", trainer="lal_angler")
    lv.dialogue["lal_fisher"] = [
        say("Atunara Fisherman", "My father fished from this beach, and his father. We pull the boats up on the sand, like they do in Cornwall, I'm told. Is that true? Do they also complain about the price of diesel?"),
        say("Atunara Fisherman", "In the old days the tuna came through the Strait so thick you could, they said, walk on them. They exaggerated. Fishermen always do. Except me."),
    ]
    trainer("lal_birder", "Birder", "Birdwatcher", "birdwatcher", [("kitelet", 96), ("stoopfalcon", 96), ("swiftlet", 96), ("forkwing", 97)],
            ["Shh! Storks, coming over from Africa. Don't move. Actually, do move. Battle me while we wait."],
            "Two hundred storks just went over and I missed them. Worth it.",
            "Raptors cross the Strait at its narrowest, on warm days, when the thermals rise. A hawk on a cold wet morning stays put. So do I.")
    trainer("lal_angler", "Beach Angler", "Angler", "angler", [("gannetling", 96), ("bayrunner", 97), ("plungebeak", 97)],
            ["Nothing's biting. You'll do instead."],
            "That's the most action I've had all day.",
            "Sea bream in the morning, nothing in the afternoon, and at night a very confident cat who thinks my bucket is his.")

    G = [enc("chamelet", 7), enc("duneskink", 10), enc("chipgull", 12), enc("kitelet", 8, time=["dawn", "day"]),
         enc("parakit", 6), enc("binfox", 6, time=["dusk", "night"]), enc("moggle", 8), enc("swiftlet", 8), enc("stoopfalcon", 4)]
    W = [enc("dolphlet", 14), enc("dolfeen", 10), enc("bayrunner", 8), enc("gannetling", 10), enc("pinchkin", 8)]
    z.encounters = {"grass": G, "water": W}
    lv.encounters = {"grass": [enc("chamelet", 10), enc("duneskink", 12), enc("scuttlet", 10), enc("kitelet", 8, time=["dawn", "day"]),
                               enc("swiftlet", 8), enc("stoopfalcon", 6), enc("hootlet", 4, time=["night"]),
                               enc("levanter", 4, weather=["fog", "gale"]), enc("chameleer", 2)],
                     "water": [enc("dolphlet", 14), enc("bayrunner", 8), enc("gannetling", 10), enc("pinchkin", 8), enc("plungebeak", 6), enc("glimmerjaw", 3)]}
    z.edges["east"] = {"to": "la_linea_levante", "offset": -16}
    lv.edges["west"] = {"to": "la_linea", "offset": 16}
    z.edges["south"] = {"to": "gibraltar", "offset": 0}
    return [z, lv] + ins

