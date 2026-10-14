# plan 5 group B, part 3: central_belt (canal route east of Glasgow) and edinburgh (city) with Sanctuary and Corner Shop.
from sc_common import *


def build(OUT):
    central_belt(OUT)
    edinburgh(OUT)


def central_belt(OUT):
    W, H = 72, 50
    z = Z("central_belt", "The Central Belt", W, H, kind="route", region=SCOT, music="route_forest",
          weather={"drizzle": 36, "clear": 24, "downpour": 10, "fog": 10, "sunshine": 14, "gale": 6})
    z.d["stage"] = "grass"
    z.legend["h"] = {"tile": "tall_grass", "colour": "#7d5f8c", "prop": "heather"}     # thistle meadow
    z.border("T", 2, gaps=[(0, 20, 2, 3), (70, 25, 2, 3)])
    z.scatter(0, 0, W, H, "P", 30, 31, only="T")
    path(z, [(0, 20), (38, 20), (38, 25), (71, 25)], "#", 3)
    # the canal: Forth and Clyde to the west, the Wheel in the north-east
    z.rect(2, 13, 56, 5, "w"); z.rect(2, 14, 56, 3, "~")
    z.rect(56, 10, 11, 7, "w"); z.rect(57, 11, 9, 5, "~")
    z.rect(30, 5, 14, 5, "w"); z.rect(30, 6, 14, 3, "~")
    for x in (10, 22, 34, 46):
        z.prop("canal_boat", x, 15)
    z.prop("canal_boat", 60, 13); z.prop("canal_boat", 36, 7)
    z.building(58, 3, 8, 6, "liver_building", "Falkirk Wheel")
    z.building(44, 6, 14, 2, "aqueduct")
    z.rect(44, 8, 14, 1, "."); z.rect(45, 9, 10, 1, ".")
    z.sign(53, 9, "THE FALKIRK WHEEL. Opened in 2002, it lifts boats 24 metres between the Forth and Clyde Canal and the Union Canal in about five minutes, and it's the only rotating boat lift in the world. Before it, you needed eleven locks and a free afternoon. Now you need a ticket and a snack.")
    z.sign(12, 18, "FORTH AND CLYDE CANAL. Opened in 1790 to link the east and west coasts of Scotland, so ships needn't go all the way round the top. The towpath is for walkers, cyclists and the occasional heron who thinks it owns the right of way.")
    z.sign(31, 10, "THE UNION CANAL. About thirty-one miles with no locks at all: it runs on one level, which is why it's called a contour canal. It brought coal into Edinburgh. Now it brings in rowers and dog walkers.")
    # the Kelpies at the Helix
    z.rect(6, 36, 16, 10, "w"); z.rect(7, 37, 14, 8, "~")
    z.building(9, 30, 3, 6, "liver_building", "The Kelpies")
    z.building(16, 30, 3, 6, "liver_building", show_label=False)
    z.rect(13, 23, 2, 14, "#"); z.rect(12, 36, 4, 1, "s")
    z.rect(5, 28, 4, 1, "."); z.rect(4, 22, 6, 5, "h"); z.rect(18, 22, 6, 5, "h")
    z.sign(14, 28, "THE KELPIES. Two steel horse heads, thirty metres tall, standing at the entrance to the Forth and Clyde Canal. They honour the heavy horses that once pulled barges and ploughs, and they take their name from the water spirit of Scottish legend. They're bigger than the legend, and better behaved.")
    # Linlithgow Palace on its lochside
    z.rect(34, 40, 18, 8, "w"); z.rect(35, 41, 16, 6, "~")
    z.building(40, 30, 10, 6, "castle", "Linlithgow Palace")
    z.rect(40, 36, 10, 2, ":"); z.rect(38, 28, 1, 10, "#"); z.rect(39, 37, 1, 1, "#")
    z.rect(38, 38, 12, 1, "#")
    z.sign(47, 38, "LINLITHGOW PALACE. A royal palace ruined by fire, with a loch at its door. Mary, Queen of Scots, was born here in 1542, which is a lot to live up to as a first day.")
    z.sign(56, 24, "THE ANTONINE WALL. Nearby ran a Roman wall of turf, built around AD 142 on a stone base. It was the northern edge of the Roman Empire, for about twenty years. The Romans left. The turf, mostly, stayed.")
    # thistle meadows and long grass
    for (x, y, w, h) in [(4, 4, 12, 7), (18, 6, 9, 5), (60, 17, 9, 5), (46, 42, 9, 6), (56, 28, 12, 8), (24, 24, 10, 5), (4, 42, 8, 6), (22, 42, 10, 5)]:
        z.rect(x, y, w, h, "h")
    for (x, y, w, h) in [(44, 20, 12, 4), (60, 36, 8, 8), (26, 32, 8, 5)]:
        z.rect(x, y, w, h, ",")
    z.building(24, 36, 6, 4, "slate_cottage")
    z.prop("bench", 17, 19); z.prop("lamp_post", 14, 19); z.prop("lamp_post", 32, 19); z.prop("bench", 33, 19)
    scatter_props(z, "bush", 3, 3, 66, 44, 22, 32, avoid=(".",))
    scatter_props(z, "oak", 3, 3, 66, 44, 22, 33, avoid=(".",))
    scatter_props(z, "rock", 3, 3, 66, 44, 8, 34, avoid=(".",))
    # NPCs
    chat(z, "cb_boater", "villager_2", 20, 19, "Narrowboater",
         ["Eleven locks down to the old canal, or five minutes in the Wheel. The Wheel's a showoff. I like a showoff.",
          "My boat's called 'Wee Dram'. Nae jokes about the name, the harbourmaster's heard them all."], "down", "still")
    chat(z, "cb_horse", "farmer", 13, 27, "Horse Keeper",
         ["The Kelpies are based on Clydesdales, the great heavy horses bred on the River Clyde. They used to pull half of Scotland's ploughs. Now they just stand there looking noble.",
          "In the old stories, a kelpie is a water horse that lures walkers onto its back and then runs for the loch. I'd keep an eye on the lagoon. Just in case."], "down", "still")
    chat(z, "cb_cyclist", "jogger", 44, 21, "Cyclist",
         ["The canal towpaths are marvellous for a bike. Flat as a pancake, and you can ride them from one side of Scotland to the other. I'm doing the trip for the fifth time. I keep losing my sandwich.",
          "Mind the swans. They have right of way, and they know it."], "right", "wander")
    chat(z, "cb_historian", "tour_guide", 55, 24, "Wall Walker",
         ["The Romans built a wall right across here, turf on a stone base, and manned it with soldiers who wrote grumpy letters home about the weather.",
          "That's the oldest known rainfall complaint in Scotland. It's still the national sport."], "down", "still")
    trainer(z, "cb_shinty", "Shinty Player Iain", "Shinty Player", "shinty_player", [("raidtail", 69), ("warrender", 70), ("thistlet", 69)],
            30, 21, "right", ["Shinty! The same as hurling, only we hit it on the way up. A fine and ancient game. Do you play?"],
            "A cracking hit! I'll have to tape my caman.", "Shinty is older than the Union. And a good deal rougher. Wear your shin guards.", 2700)
    trainer(z, "cb_angler", "Angler Dougie", "Angler", "angler", [("heronarch", 69), ("stalklet", 69), ("rillotter", 70)],
            34, 19, "up", ["I've been fishing this canal since I was a wean. I've caught three perch, a bicycle and a rumour."],
            "Fair play. You've a keen eye and a dry net.", "The best bit of canal fishing is the sitting. The fish is just a bonus.", 2650)
    trainer(z, "cb_student", "Student Hamish", "Student", "student", [("flittermouse", 69), ("hootlet", 69), ("raidtail", 70)],
            50, 26, "left", ["I'm writing a dissertation on the Antonine Wall. I've got eleven thousand words on turf."],
            "A solid argument. I'll cite you.", "I've read that Romans described the Scots as 'a wee bit moist'. I'm paraphrasing.", 2650)
    trainer(z, "cb_caller", "Ceilidh Caller Mairi", "Ceilidh Caller", "ceilidh_caller", [("cooplet", 69), ("murmurant", 70), ("stagmor", 70)],
            18, 21, "right", ["Take your partners! Oh, I've only got you. Well, that'll do for a gay gordons."],
            "Brilliant. You can swing me round any day.", "A good caller keeps the room moving and the elbows in. The elbows are non-negotiable.", 2750)
    z.d["edges"] = {"west": {"to": "glasgow", "offset": 0}, "east": {"to": "edinburgh", "offset": 0}}
    z.d["spawn"] = [20, 21]
    wild(z, [("thistlet", 69, 70, 22, {}), ("raidtail", 69, 70, 10, {}), ("grizzlet", 69, 70, 8, {"time": ["dawn", "day"]}),
             ("starlet", 69, 70, 8, {"time": ["dawn", "dusk"]}), ("swiftlet", 69, 70, 8, {"weather": ["gale", "clear"]}),
             ("sootwing", 69, 70, 8, {"weather": ["fog", "drizzle"]}), ("bobbin", 69, 70, 6, {}), ("flittermouse", 69, 70, 8, {"time": ["night"]}),
             ("hootlet", 69, 70, 8, {"time": ["night"]}), ("natterjack", 69, 70, 6, {"weather": ["drizzle", "downpour"]}),
             ("strutcoo", 69, 70, 8, {"time": ["day", "dawn"]})])
    wild(z, [("stalklet", 69, 70, 20, {}), ("rillotter", 69, 70, 20, {}), ("dipling", 69, 70, 20, {}), ("heronarch", 69, 70, 10, {}),
             ("minkshade", 69, 70, 10, {"time": ["dusk", "night"]}), ("pierlord", 69, 70, 10, {})], "water")
    z.save(OUT + "/central_belt.json")


def edinburgh(OUT):
    W, H = 72, 62
    z = Z("edinburgh", "Edinburgh", W, H, kind="town", region=SCOT, music="town_scotland",
          weather={"drizzle": 30, "clear": 24, "downpour": 8, "fog": 14, "gale": 10, "sunshine": 14})
    z.d["stage"] = "city"; z.d["town_id"] = "edinburgh"
    z.border("T", 2, gaps=[(0, 25, 2, 3)])
    z.scatter(0, 0, W, H, "P", 30, 41, only="T")
    # streets: Princes Street along the top, the west road, and the stair-street down to the Royal Mile
    z.rect(2, 8, 68, 3, "=")
    z.rect(0, 25, 50, 3, "=")
    z.rect(32, 8, 3, 31, ":")
    z.rect(35, 15, 3, 1, ":")
    # the New Town
    z.building(3, 3, 10, 5, "terrace"); z.building(14, 4, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(17, 7, "edinburgh_sanctuary", 5, 6, "up")
    z.building(22, 4, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(24, 7, "edinburgh_shop", 4, 5, "up")
    z.building(28, 3, 4, 5, "cream_render"); z.building(36, 3, 9, 5, "terrace"); z.building(46, 3, 9, 5, "cream_render")
    z.building(56, 3, 9, 5, "terrace")
    # Princes Street Gardens
    z.rect(4, 12, 28, 13, ".")
    z.rect(4, 17, 28, 1, "#"); z.rect(18, 12, 1, 13, "#")
    z.rect(9, 13, 6, 3, "f"); z.rect(10, 14, 4, 1, ",")
    z.rect(21, 20, 5, 3, "|")
    z.rect(5, 19, 7, 5, ",")
    z.rect(24, 12, 4, 4, ".")
    z.building(26, 12, 3, 4, "chapel", "Scott Monument")
    z.rect(22, 13, 3, 2, "w"); z.rect(22, 13, 1, 1, "~")
    z.prop("bench", 20, 18); z.prop("bench", 16, 18); z.prop("bench", 6, 18); z.prop("lamp_post", 18, 19); z.prop("lamp_post", 18, 16)
    z.prop("statue", 17, 14); z.prop("bench", 22, 19)
    scatter_props(z, "oak", 4, 12, 28, 13, 9, 42, avoid=(".",))
    scatter_props(z, "birch", 4, 12, 28, 13, 5, 43, avoid=(".",))
    z.sign(10, 19, "THE FLORAL CLOCK. A working clock made from thousands of plants, laid out afresh every spring, and the oldest in the world. It keeps good time. It also keeps its hands, very tidily, in the border.")
    z.sign(25, 16, "THE SCOTT MONUMENT. Sir Walter Scott's Gothic spire, 61 metres tall and the biggest monument to a writer anywhere. There are 287 steps to the top. Scott wrote about forty books. The steps are fewer than the pages.")
    z.sign(33, 11, "PRINCES STREET GARDENS. Once the Nor' Loch, a muddy lake under the Castle. It was drained, and the gardens were laid out in the early 1800s. It's far more peaceful now. The lake monsters left.")
    # Waverley station, in its valley
    station(z, 38, 13, 12, 6, "Waverley Station")
    z.rect(38, 11, 12, 1, ":"); z.rect(51, 13, 6, 3, ":")
    z.rect(37, 17, 14, 6, ",")
    z.prop("bench", 40, 15); z.prop("lamp_post", 48, 15)
    rail_guard(z, 46, 15, ["Waverley Station, the only station in the world named after a novel. It's named after Sir Walter Scott's 'Waverley'. The trains are not obliged to be as long.",
                           "Hop aboard! The Wildlore rail runs to every station you've visited in Great Britain. Where to?"], facing="left")
    # the Castle on its rock: rings of cliff, one ramp (the Royal Mile) on the east side
    z.rect(6, 28, 26, 22, "^")
    z.height(6, 28, 26, 22, 1); z.height(8, 30, 22, 18, 2); z.height(10, 32, 18, 14, 3); z.height(12, 34, 14, 10, 4)
    z.rect(12, 34, 14, 10, ".")
    z.rect(26, 41, 6, 3, ":")
    z.rect(12, 41, 14, 3, ":")
    z.building(14, 35, 10, 6, "castle", "Edinburgh Castle")
    z.prop("lamp_post", 13, 41); z.prop("lamp_post", 24, 41); z.prop("bollard", 15, 43); z.prop("bollard", 17, 43); z.prop("bollard", 22, 43)
    z.prop("statue", 25, 42); z.prop("bench", 12, 36); z.prop("bench", 12, 38)
    z.sign(14, 42, "EDINBURGH CASTLE. It sits on Castle Rock, the stump of a volcano that went quiet about 340 million years ago. The Crown Jewels of Scotland and the Stone of Destiny live inside. Every day but Sunday, the One O'Clock Gun is fired at one o'clock. People set their watches by it. The gun sets nothing by anyone.")
    z.sign(27, 40, "THE ESPLANADE. A flat parade ground in front of the Castle, where the Royal Edinburgh Military Tattoo is held every August. A lot of pipers, drummers and dancers. A lot of tartan, too, worn in the proper way.")
    # the Royal Mile
    z.rect(32, 39, 18, 6, ":")
    z.building(36, 34, 9, 5, "cathedral", "St Giles' Cathedral"); z.building(46, 35, 4, 4, "tudor", "Camera Obscura")
    z.building(32, 45, 8, 4, "terrace", "Mary King's Close"); z.building(41, 45, 6, 4, "red_brick")
    z.building(50, 37, 12, 7, "stone", "Palace of Holyroodhouse")
    z.rect(48, 39, 2, 6, ":")
    for (x, y) in [(33, 39), (38, 39), (44, 39), (47, 44), (36, 44), (41, 44)]:
        z.prop("lamp_post", x, y)
    z.prop("market_stall", 39, 41); z.prop("market_stall", 43, 41); z.prop("planter", 37, 39); z.prop("planter", 45, 39)
    z.prop("statue", 40, 44); z.prop("post_box", 34, 44)
    z.sign(35, 40, "THE ROYAL MILE. About a mile long, from the Castle to Holyrood, and made of closes, wynds, pubs, shops and old stairs. Underneath it lie buried streets, like Mary King's Close, closed up and built over. It's like a city that decided to keep a very old diary.")
    z.sign(49, 42, "HOLYROOD. The King's home in Scotland. Mary, Queen of Scots, lived here, and so did a choir of very shiny crowns. At the foot of the Mile, it's the end of the road and the beginning of the park.")
    z.sign(36, 33, "AULD REEKIE. Edinburgh's old nickname, from the smoke of chimneys when the Old Town was packed in tight. It's far fresher now. The nickname stuck. Nicknames do.")
    z.sign(10, 27, "DÙN ÈIDEANN. The Gaelic name of this city, 'the fort of Eidyn'. It's pronounced about like 'doon AY-dinn'. Say it with a straight face and a few locals will take you aside to say it better.")
    # the Grassmarket, below the rock
    z.rect(3, 50, 28, 5, ":")
    z.building(4, 55, 10, 5, "terrace", "The Grassmarket"); z.building(15, 55, 8, 5, "tudor", "The Last Drop")
    z.building(24, 55, 7, 5, "red_brick")
    z.prop("market_stall", 8, 52); z.prop("market_stall", 14, 52); z.prop("market_stall", 22, 52); z.prop("lamp_post", 5, 50)
    z.prop("lamp_post", 18, 50); z.prop("lamp_post", 29, 50); z.prop("bench", 26, 52)
    z.sign(12, 51, "THE GRASSMARKET. Once a cattle market under the Castle, now a square of pubs, shops and tartan scarves. Greyfriars Bobby, the loyal little Skye terrier who guarded his master's grave for fourteen years, is a short walk away. Everyone loves Bobby. Even the cats.")
    # Holyrood Park and Arthur's Seat
    mound(z, 58, 52, 10, 7, 6)
    for y in range(45, 60):
        for x in range(48, 70):
            if z.hg[y][x] >= 2 and x <= 50:
                z.g[y][x] = "^"
    z.rect(58, 45, 2, 8, "#")
    for (x, y, w, h) in [(52, 48, 5, 5), (62, 48, 4, 6), (53, 54, 6, 4), (61, 55, 6, 3)]:
        z.rect(x, y, w, h, ",")
    z.sign(57, 49, "ARTHUR'S SEAT. A hill made from an extinct volcano, 251 metres high, right beside the city. It's an easy hour's walk to the top, with views of the whole of Edinburgh, the Forth and, on a good day, a smug seagull who got there first.")
    scatter_props(z, "bush", 3, 3, 66, 56, 12, 44, avoid=("."))
    z.prop("rock", 60, 51)
    # NPCs
    z.npc(id="kit", sprite="kit", x=20, y=42, facing="down", move="still", script="kit_edinburgh")
    script("edinburgh", "kit_edinburgh", say("Kit", "Placeholder: the story agent writes Kit's Edinburgh Castle esplanade battle here."))
    chat(z, "edi_guide", "tour_guide", 16, 42, "Castle Guide",
         ["The Castle's on a volcanic plug. A big old volcano chilled out about 340 million years ago, and the glaciers scraped it into a crag with a long tail. Hence 'Crag and Tail'.",
          "The One O'Clock Gun goes off at one o'clock. It started in 1861 so ships in the Forth could set their clocks. Now it startles tourists. A fine tradition."], "down", "still")
    chat(z, "edi_fringe", "festival_goer", 41, 42, "Fringe Performer",
         ["In August the Fringe takes over the whole city: thousands of shows, a few hundred of them with real audiences, and one with a very committed accordion.",
          "It's the biggest arts festival in the world. I'm doing a comedy set about pigeons. It's called 'Squab Goes Hungry'. Come on Tuesday. There'll be a seat."], "down", "wander")
    chat(z, "edi_gardener", "farmer", 20, 19, "Gardener",
         ["The Floral Clock's a proper working clock and, I'll have you know, the oldest in the world. It's all planted in spring. It takes a month and a lot of kneeling.",
          "Mind the daffs. Children can walk on the daffs, but only after school."], "down", "wander")
    chat(z, "edi_walker", "birdwatcher", 56, 46, "Seat Walker",
         ["Arthur's Seat is an extinct volcano with a nice view and a path. You can be on top of it in an hour, and you will want a scone afterwards.",
          "They say King Arthur sat there, but there's no real evidence. There's a lot of evidence for seagulls."], "down", "wander")
    trainer(z, "edi_piper", "Piper Hamish", "Piper", "piper", [("murmurant", 69), ("strutcoo", 69), ("cooplet", 70)],
            38, 40, "down", ["I pipe on the Mile for the tourists. And the tourists, bless them, take photos. I'd like to see the photos."],
            "A fine reel! I'll try not to squeak in sympathy.", "Piping is breathing with commitment. I breathe with commitment for four hours a day.", 2750)
    trainer(z, "edi_student", "Student Eilidh", "Student", "student", [("hootlet", 69), ("sootwing", 70), ("raidtail", 69)],
            10, 17, "right", ["I'm supposed to be revising. The Gardens are the best place to avoid it. Fancy a battle instead?"],
            "Brilliant. That's me out of excuses. Back to the books.", "The university's here to teach, and the Gardens are here to distract. I've studied both.", 2650)
    trainer(z, "edi_hillwalker", "Hillwalker Catriona", "Hillwalker", "hiker", [("fawnlet", 69), ("eaglet", 70), ("railspark", 70)],
            60, 48, "left", ["I hill-walk before breakfast. This is my breakfast hill. Come on, a quick bout before my porridge."],
            "A grand match. Eat your porridge, you've earned it.", "The summit's windy. You can hold your hat or you can hold your breath. I recommend neither.", 2700)
    trainer(z, "edi_warden", "Warden Rennie", "Warden", "warden_grunt", [("thornsow", 69), ("zigzlet", 70), ("adderking", 70), ("bramblehog", 69)],
            36, 20, "left", ["Princes Street Gardens: lovingly curated. By me. Please stay on the paths I've drawn. They're very nice paths."],
            "Unscheduled! This wasn't on the rota!", "I'll note it down: 'visitor, spirited'. Under 'problems'.", 2800)
    z.d["edges"] = {"west": {"to": "central_belt", "offset": 0}}
    z.d["spawn"] = [33, 26]
    wild(z, [("railspark", 69, 70, 18, {}), ("raidtail", 69, 70, 10, {}), ("grizzlet", 69, 70, 8, {"time": ["dawn", "day"]}),
             ("binfox", 69, 70, 10, {"time": ["night", "dusk"]}), ("strutcoo", 69, 70, 8, {"time": ["day", "dawn"]}),
             ("starlet", 69, 70, 8, {"time": ["dusk", "dawn"]}), ("flittermouse", 69, 70, 8, {"time": ["night"]}), ("hootlet", 69, 70, 8, {"time": ["night"]}),
             ("sootwing", 69, 70, 8, {"weather": ["fog", "drizzle"]}), ("bobbin", 69, 70, 6, {}), ("fawnlet", 69, 70, 6, {"time": ["dawn", "dusk"]})])
    wild(z, [("pierlord", 69, 70, 25, {}), ("chipgull", 69, 70, 25, {}), ("dipling", 69, 70, 20, {}), ("stalklet", 69, 70, 15, {}),
             ("rillotter", 69, 70, 12, {}), ("bradan", 69, 70, 8, {})], "water")
    z.save(OUT + "/edinburgh.json")
    sanctuary(OUT, "edinburgh", "Edinburgh", (17, 8))
    shop(OUT, "edinburgh", "Edinburgh", (24, 8))
    nurse("edinburgh", ["Good day, and welcome to Edinburgh Sanctuary. It's the nicest Sanctuary in the world, in a city that has several nice things. Pop your team on the counter.",
                        "Take a seat. Have a shortbread, a wee dram of tea, whatever you fancy. Don't mind the wind. It likes to rearrange us.",
                        "All done, and in excellent form! Mòran taing for waiting. Dùn Èideann is lovely, but it's a lot of hills for a tired team.",
                        "The Ark terminal. It's in the cellar, which is where every self-respecting Edinburgh object lives.",
                        "Right you are. Beannachd leibh, and mind the cobbles: they're older than the streets."])
    shopkeeper("edinburgh", "Good day! We've tablet, snares, and umbrellas that survive the wind. It's a very small list. It's a very windy city.",
               "Thank you kindly! Away you go, and mind the hill. It's always uphill. It's a mystery.")
