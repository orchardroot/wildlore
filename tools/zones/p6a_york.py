# plan 6 group A, part 5: york (the Minster, the city walls, the Shambles, a station) and york_minster_crypt (Keeper Hester's arena).
from p6a_common import *
from wcommon import _stand


def build(OUT):
    york(OUT)
    crypt(OUT)


def york(OUT):
    W, H = 76, 68
    zid = "york"
    z = Z(zid, "York", W, H, kind="town", region=YK, music="town_york",
          weather={"drizzle": 26, "clear": 26, "fog": 12, "gale": 8, "sunshine": 22, "downpour": 6})
    z.d["stage"] = "city"; z.d["town_id"] = "york"
    z.border("T", 2, gaps=[(14, 0, 3, 2), (0, 20, 2, 3), (30, 66, 3, 2)])
    z.scatter(0, 0, W, H, "P", 22, 101, only="T")
    X0, Y0, X1, Y1 = 10, 8, 66, 58
    # the city walls: parapet, walkway (raised), a bank inside
    for x in range(X0, X1 + 1):
        for (y, ch, hv) in [(Y0, "W", 2), (Y0 + 1, ":", 2), (Y0 + 2, ".", 1), (Y1, "W", 2), (Y1 - 1, ":", 2), (Y1 - 2, ".", 1)]:
            z.g[y][x] = ch; z.hg[y][x] = hv
    for y in range(Y0, Y1 + 1):
        for (x, ch, hv) in [(X0, "W", 2), (X0 + 1, ":", 2), (X0 + 2, ".", 1), (X1, "W", 2), (X1 - 1, ":", 2), (X1 - 2, ".", 1)]:
            z.g[y][x] = ch; z.hg[y][x] = hv
    # streets and the four gates (bars)
    z.rect(14, 0, 3, 31, "=")
    z.rect(0, 20, 46, 3, "=")
    z.rect(14, 30, 52, 3, "=")
    z.rect(30, 30, 3, 38, "=")
    for (x, y, w, h) in [(14, 8, 3, 3), (10, 20, 3, 3), (30, 56, 3, 3), (64, 30, 3, 3)]:
        z.rect(x, y, w, h, "=")
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                z.hg[yy][xx] = 0
    smooth(z)
    z.building(11, 11, 3, 2, "castle", "Bootham Bar"); z.building(17, 11, 3, 2, "castle")
    z.building(11, 17, 3, 2, "castle", "Micklegate Bar"); z.building(11, 24, 3, 2, "castle")
    z.building(27, 53, 3, 2, "castle", "Fishergate Bar"); z.building(33, 53, 3, 2, "castle")
    z.building(61, 27, 3, 2, "castle", "Walmgate Bar"); z.building(61, 34, 3, 2, "castle")
    for (x, y) in [(15, 7), (15, 4), (6, 21), (6, 18)]:
        z.prop("lamp_post", x, y)
    z.sign(17, 7, "THE CITY WALLS. About two miles of medieval wall round the old city, mostly rebuilt on Roman and Viking foundations, and the longest circuit of town walls in England. You can walk nearly the whole way on top. The gates are called 'bars', and the roads are called 'gates'. It's York. Don't ask.")
    # York Minster and the plaza
    z.rect(17, 19, 42, 9, ":")
    z.building(30, 11, 16, 8, "cathedral", "York Minster", door=8)
    z.warp(38, 18, "york_minster_crypt", 9, 11, "up")
    z.prop("statue", 29, 20, variant=2); z.prop("statue", 47, 20, variant=1)
    z.prop("lamp_post", 33, 20); z.prop("lamp_post", 43, 20); z.prop("bench", 35, 22); z.prop("bench", 41, 22)
    z.prop("planter", 31, 23); z.prop("planter", 45, 23)
    z.sign(37, 20, "YORK MINSTER. The largest medieval Gothic cathedral in northern Europe, begun in 1220 and finished 252 years later. The Great East Window is the size of a tennis court and holds the biggest piece of medieval stained glass in Britain. The stonemasons have been repairing it ever since, so it is never quite finished, and it is never quite not.")
    z.sign(28, 18, "THE CRYPT. Under the Minster lie Saxon, Norman and Roman stones, and a Viking burial. Locals tell the story that the Keeper of the cathedral's quiet places holds court below. If you find the door, say good morning.")
    # Museum Gardens
    z.rect(20, 11, 9, 8, ".")
    blob(z, 25, 16, 4, 2, ",", only=".", seed=3, jitter=0.4)
    z.building(21, 12, 5, 3, "castle", "Multangular Tower")
    z.rect(24, 15, 1, 4, "#"); z.rect(20, 18, 9, 1, "#")
    z.prop("bench", 22, 17); z.prop("oak", 20, 16); z.prop("oak", 28, 12, variant=1); z.prop("birch", 27, 15)
    z.sign(23, 19, "MULTANGULAR TOWER. A Roman tower from the fortress of Eboracum, with later medieval stones on top. Constantine the Great was proclaimed emperor here in AD 306, which is why York's coffee mugs say 'Rome's Backup Capital'.")
    # Sanctuary and Corner Shop
    z.rect(17, 28, 42, 2, ":")
    z.building(18, 24, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(21, 27, "york_sanctuary", 5, 6, "up")
    z.building(25, 24, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(27, 27, "york_shop", 4, 5, "up")
    z.building(53, 24, 8, 4, "cream_render", "Bettys Tea Rooms", door=4)
    z.building(53, 19, 8, 3, "stone", "Stonegate Books", door=3)
    # more of the old city
    z.building(18, 34, 11, 4, "tudor", "Micklegate"); z.building(18, 40, 11, 4, "terrace", "Bishopthorpe Road")
    z.building(50, 12, 10, 5, "tudor", "Merchant Adventurers' Hall")
    z.rect(48, 17, 14, 2, ":")
    z.rect(18, 38, 11, 1, ":"); z.rect(18, 44, 11, 1, ":")
    z.rect(47, 19, 4, 1, ":")
    # the Shambles: a narrow lane between jettied tudor houses
    z.rect(33, 38, 25, 2, ":")
    z.building(34, 34, 6, 4, "tudor", "The Shambles"); z.building(41, 34, 6, 4, "tudor"); z.building(48, 34, 5, 4, "tudor"); z.building(54, 34, 5, 4, "tudor")
    z.rect(33, 38, 25, 5, ":")
    for x in range(36, 58, 4):
        z.prop("market_stall", x, 41, variant=x % 3)
    z.rect(33, 33, 1, 7, ":")
    z.prop("lamp_post", 40, 39); z.prop("lamp_post", 47, 39); z.prop("lamp_post", 53, 39)
    z.sign(45, 38, "THE SHAMBLES. A Viking-age and medieval street of butchers' shops, whose name comes from the 'shamel', the wooden bench where meat was laid out. The upper floors lean out so far that neighbours across the lane can nearly shake hands. Some say a certain wizarding alley was inspired by it, which is a very polite way of saying you could film it here.")
    # Clifford's Tower and the museum
    hills(z, [(52, 49, 3, 7)])
    z.building(49, 47, 7, 4, "castle", "Clifford's Tower", door=3)
    z.rect(33, 51, 20, 2, "#")
    z.rect(20, 51, 13, 2, ":")
    z.building(20, 53, 6, 3, "red_brick", "National Railway Museum")
    z.prop("bench", 37, 53); z.prop("lamp_post", 40, 53); z.prop("lamp_post", 46, 53)
    z.sign(50, 52, "CLIFFORD'S TOWER. A stone keep on a mound, built in the 13th century on the site of William the Conqueror's wooden castle. It has been a royal fortress, a prison, a gunpowder store and a very good view. Don't let anyone tell you the mound is natural.")
    # York station
    station(z, 15, 46, 10, 5, "York Station")
    z.rect(14, 48, 1, 2, ":"); z.rect(25, 48, 1, 2, ":"); z.rect(26, 48, 4, 1, "#")
    z.prop("bench", 17, 50); z.prop("lamp_post", 22, 50)
    rail_guard(z, 23, 48, ["York Station. The curve of the roof is famous, and it is one of the longest curved platforms in the country, so the trains seem to arrive politely round a corner.",
                            "Right, where to? We'll have you there before the tea goes cold."], facing="left")
    # outside the walls
    blob(z, 18, 62, 8, 3, ",", only=".", seed=5, jitter=0.4)
    blob(z, 48, 62, 9, 3, ",", only=".", seed=6, jitter=0.4)
    blob(z, 70, 20, 3, 8, ",", only=".", seed=7, jitter=0.4)
    blob(z, 5, 8, 3, 5, ",", only=".", seed=8, jitter=0.4)
    scatter_props(z, "oak", 3, 3, 70, 62, 22, 9, avoid=(".",))
    scatter_props(z, "birch", 3, 3, 70, 62, 14, 10, avoid=(".",))
    z.sign(31, 60, "KNAVESMIRE. York Racecourse, a huge flat meadow that floods in winter, a good place for an afternoon, and once the site of the northern gallows. Today, thankfully, it only gallops.")
    # the Treasurer's House ghosts, as the cellar story goes
    creature(z, zid, "legionette", 59, 23, move="wander",
             line="A faint tramp of marching feet and a glimmer of bronze. In 1953 an apprentice plumber in the Treasurer's House cellar saw a Roman legion march through the wall, up to their knees in the floor. They were walking on a lost Roman road.", who="Legionette")
    creature(z, zid, "legionette", 25, 44, move="wander",
             line="A small spirit in a very old helmet stands to attention, and stands very correctly, for rather a long while. It seems to be waiting to be dismissed.", who="Legionette")
    # NPCs
    chat(z, "yrk_guide", "tour_guide", 36, 21, "Minster Guide",
         ["Welcome to the Minster. The Great East Window has 311 panels and tells the story from Creation to the Apocalypse. The guide leaflet is 20 pages and the best part is the sandwiches.",
          "There are 275 steps up the central tower. I've counted them for thirty years and they've never been the same number twice. They are, sir, medieval."], "down", "still")
    chat(z, "yrk_viking", "villager_2", 60, 31, "Jorvik Guide",
         ["The Vikings called York 'Jorvik'. In the Coppergate dig they found a Viking sock, knitted with a single needle in a technique called nålbinding. It's a bit holey, and 1,000 years old.",
          "York had Romans, Vikings, Normans and railway barons. If you want to know why the street names end in 'gate', the Vikings' word for street was 'gata'. A 'bar' is a gate. A 'gate' is a street. It makes sense, when it's explained twice."], "left", "wander")
    chat(z, "yrk_choc", "shopkeeper", 38, 29, "Chocolate Seller",
         ["York is chocolate city. Rowntree's and Terry's were both here. The KitKat came from York in 1935, and they make them in a factory just down the road. They still do.",
          "Terry's Chocolate Orange: tap it on the table, whack it, and the segments fall out. That's the York test. Nobody has ever failed it, but plenty have been stopped by the family."], "down", "still")
    chat(z, "yrk_rail", "farmer", 22, 52, "Railway Volunteer",
         ["The National Railway Museum holds Mallard, the fastest steam locomotive in the world. In 1938 she reached 126 miles an hour, which is still the record, and the driver had a neat little bit of tweed on.",
          "York was the railway capital of the north. Seven lines met here. Even now, you can't get anywhere in Britain without a change at York, as the saying goes."], "right", "still")
    chat(z, "yrk_ghost", "villager_6", 44, 22, "Ghost Tour Seller",
         ["York is the most haunted city in Europe, they say. I say there's a ghost on every street, and a ghost tour on every corner. A hundred and fifty haunted sites. And the same chap with a lantern in all of them.",
          "The best ghost is the one you don't see. The second best is the one with a good gift shop."], "down", "wander")
    # trainers
    trainer(z, "yrk_ghost_walker", "Ghost Walker Beatrice", "Ghost Walker", "tour_guide",
            [("legionette", 84), ("hushwing", 84), ("pinewraith", 84)], 45, 39, "left",
            ["Gather round, ladies and gentlemen, and listen. In this very lane in 1666... oh, you wanted a fight. Very well, the story can wait."],
            "Oh! You've broken the spell. The ghost will be furious. He'll haunt you at breakfast.", "A good ghost tour is five parts history, three parts legend and two parts cold, damp air.", 3600)
    trainer(z, "yrk_historian", "Historian Dr Alcuin", "Historian", "poet",
            [("centurion", 84), ("lanternis", 84), ("brockmoor", 84)], 30, 9, "right",
            ["I'm walking the walls. Two miles, with commentary. Care to join? I've been doing it since 1998. The commentary has grown."],
            "A revised footnote. 'The visitor won.' I'll have to change the guidebook.", "Alcuin of York was Charlemagne's chief scholar. The man taught the Emperor his letters. That's the sort of pupil you want.", 3620)
    trainer(z, "yrk_warden", "Warden Ptolemy", "Warden", "warden_grunt",
            [("shuttlecog", 84), ("sootwing", 84), ("raidtail", 85)], 40, 51, "right",
            ["The Enclosure will 'curate' the Shambles. Make it straight. Tidy the lean. Cut the crooked bits. I've a spirit level."],
            "My spirit level has a crack in it. My spirit does too.", "The crooked houses lean because they're old. Our boss calls them 'a hazard'. I call them lovely and I'm not telling him.", 3580)
    wild(z, [("peregrin", 84, 85, 16, {"time": ["day", "dawn"]}), ("legionette", 84, 85, 14, {"time": ["night", "dusk"]}), ("hootlet", 84, 85, 8, {"time": ["night"]}),
             ("pepperling", 84, 85, 8, {}), ("flittermouse", 84, 85, 8, {"time": ["night"]}), ("binfox", 84, 85, 8, {"time": ["night", "dusk"]}),
             ("grizzlet", 84, 85, 8, {}), ("cooplet", 84, 85, 8, {}), ("rooklet", 84, 85, 8, {}), ("starlet", 84, 85, 8, {"time": ["dusk", "dawn"]}),
             ("barnling", 84, 85, 6, {"time": ["night"]})])
    z.d["edges"] = {"north": {"to": "whitby", "offset": 0}, "west": {"to": "yorkshire_dales", "offset": 0}, "south": {"to": "sheffield", "offset": 0}}
    z.d["spawn"] = [15, 14]
    done(z)
    z.save(OUT + "/" + zid + ".json")
    sanctuary(OUT, zid, "York", (21, 28), music="sanctuary")
    shop(OUT, zid, "York", (27, 28))
    nurse(zid, ["Now then, love, and welcome to York Sanctuary. Put the team on the counter and I'll sort them. You've the look of someone who's walked the walls, and then the walls again.",
                "Sit thissen down. There's a pot of tea, a slice of parkin, and a view of the Minster, which is leaning slightly, I think. It always does when people stare.",
                "Champion! All fixed. Off you pop. Mind the cobbles, they're the original ones, and they've a grudge.",
                "The Ark's in the corner. It has the faint scent of old stone and good chocolate. I do not know why. Have a click.",
                "No bother, love. We'll be here, same as the Minster. Longer, if the stonemasons have anything to do with it."])
    shopkeeper(zid, "Ey up! Snares, tea, Yorkshire puddings, parkin, and a very small bag of pork-pie seasoning I'm not allowed to explain. What'll it be, love?",
               "Ta-ra, love! If you hear a marching sound in the cellar, it's a customer. Probably.")


def crypt(OUT):
    zid = "york_minster_crypt"
    a = Z(zid, "The Minster Crypt", 19, 14, fill="q", kind="interior", region="", music="battle_keeper", weather={})
    a.d["stage"] = "cave"
    a.legend["q"] = {"tile": "floor_tile", "colour": "#5f5f68"}
    a.legend["r"] = {"tile": "floor_tile", "colour": "#7b6f60"}
    a.border("x", 1)
    a.rect(8, 2, 3, 10, "r")
    a.rect(2, 11, 15, 1, "r")
    a.set(9, 12, "D")
    a.rect(9, 11, 1, 1, "r")
    a.warp(9, 12, "york", 38, 19, "down")
    for (x, y) in [(4, 3), (4, 6), (4, 9), (14, 3), (14, 6), (14, 9)]:
        a.prop("standing_stone", x, y, variant=(x + y) % 3)
    for (x, y) in [(6, 2), (12, 2)]:
        a.prop("lamp_post", x, y)
    a.prop("bench", 2, 8); a.prop("bench", 16, 8); a.prop("statue", 2, 2); a.prop("statue", 16, 2)
    a.npc(id="keeper_hester", sprite="keeper_hester", x=9, y=2, facing="down", move="still", script="keeper_hester", name="Keeper Hester")
    script(zid, "keeper_hester", say("Keeper Hester", "Placeholder: the story agent rewrites this Keeper battle script."))
    trainer(a, "yrk_junior_1", "Ghost Walker Albert", "Ghost Walker", "tour_guide",
            [("legionette", 84), ("hushwing", 84), ("pinewraith", 85)], 9, 8, "down",
            ["Hester sees visitors who can find the crypt door. I see them first. Good evening. Mind your head, and your footing, and the Roman soldier."],
            "Oh well done. Go on in. She's a stickler, but a fair one.", "Hester's family have kept this place for a very long time. The ghosts say she's the best caretaker they've ever had. Mostly because she lets them stay up.", 3700)
    trainer(a, "yrk_junior_2", "Ghost Walker Mina", "Ghost Walker", "tour_guide",
            [("lanternis", 84), ("coblynn", 85), ("centurion", 85)], 7, 5, "right",
            ["Down here the stones remember everything. Quiet now. Let's see how you hold a thought in the dark."],
            "A fine battle. The stones remember it now, so be careful.", "The crypt is cold all year. That's the only haunting I've actually verified. The draught.", 3720)
    a.d["spawn"] = [9, 11]
    a.save(OUT + "/" + zid + ".json")
