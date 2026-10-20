# 3.2 "Up Helly Aa": Shetland, over the sea from Kirkwall.
#   lerwick (town): Bressay Sound's harbour, Fort Charlotte, the Shetland Museum, the Galley Shed, Commercial Street's
#                   lodberries, Clickimin Broch, the Kirkwall boat at the quay
#   shetland_mainland (route): ponies, the Jarlshof dig, the road across Sumburgh's runway, Sumburgh Head and its puffins,
#                   Mousa Broch across the water and St Ninian's Isle
# Usage: python3 tools/zones/sc_shetland.py data/zones   (writes zones, interiors, dialogue and trainers)
import sys, math, random
from sc_hebrides import (plaque, interior, npc, cmd_if, setf, give, choice, when, check, door_to, SCOT)
from p6a_common import *
from wcommon import _stand
from zlib import landmark

FLOOR = 80          # Kirkwall's band: every zone and trainer here is scaled from it
WX = {"gale": 24, "fog": 18, "drizzle": 22, "clear": 16, "sunshine": 10, "downpour": 10}
ROUTE = "kirkwall_lerwick"


def scaled(tids):
    for t in tids:
        TRN[t]["scaled_floor"] = FLOOR


def wild_set(z, rows, kind="grass"):
    wild(z, [(sp, FLOOR, FLOOR + 1, wt, extra) for (sp, wt, extra) in rows], kind)


def fair(sp, *more):
    return [(sp, FLOOR)] + [(m, FLOOR + 1) for m in more]


# =====================================================================================================
# lerwick
# =====================================================================================================

def lerwick(OUT):
    W, H = 72, 56
    zid = "lerwick"
    z = Z(zid, "Lerwick", W, H, kind="town", region=SCOT, music="town_scotland", weather=WX)
    z.d["stage"] = "coast"; z.d["town_id"] = "lerwick"; z.d["scaled_floor"] = FLOOR
    z.legend["k"] = {"tile": "grass", "colour": "#7d8c55"}
    z.legend["h"] = {"tile": "tall_grass", "colour": "#7a5c6a", "prop": "heather"}
    z.rect(0, 0, W, H, "k")
    z.border("R", 2, gaps=[(34, 54, 3, 2)])
    # Bressay Sound to the east, with Bressay a green hump across the water
    for y in range(H):
        ex = 62 + int(round(math.sin(y / 4.0)))
        z.rect(ex, y, W - ex, 1, "$"); z.set(ex - 1, y, "w")
    for y in (H - 2, H - 1):
        for x in range(W):
            if x < 34 or x > 36:
                z.set(x, y, "R" if x < 58 else "$")
    blob(z, 68, 28, 3, 9, "k", only="$", seed=5, jitter=0.3)
    z.prop("lighthouse", 68, 34)
    # the old town: Commercial Street down the middle, lanes across, the Esplanade on the water
    z.rect(38, 6, 3, 30, ":")                         # Commercial Street, flagged and narrow
    for sy in (16, 25, 34):
        z.rect(3, sy, 52, 2, ":")
    z.rect(50, 6, 5, 40, ":")                         # the Esplanade
    z.rect(50, 38, 11, 7, ":")                        # the Victoria Pier quay
    z.d["ferry"] = {"x": 59, "y": 41, "route": ROUTE}
    z.rect(34, 36, 3, 20, "=")                        # the road south to Sumburgh
    # row A: the Museum, the Town Hall, the Galley Shed; Fort Charlotte on the water
    ret_mus = door_to(z, 3, 12, 8, 4, 3, "granite_house", "Shetland Museum and Archives", "lerwick_museum", 15, 11)
    ret_hall = door_to(z, 12, 12, 8, 4, 3, "granite_house", "Town Hall", "lerwick_townhall", 13, 10)
    ret_gal = door_to(z, 21, 12, 9, 4, 4, "harbour_white", "Up Helly Aa Galley Shed", "lerwick_galley_shed", 15, 11)
    z.building(30, 12, 6, 4, "orkney_flagstone", "Hillhead")
    ret_fort = door_to(z, 42, 12, 8, 4, 3, "castle", "Fort Charlotte", "lerwick_fort", 13, 10)
    # row B: the Sanctuary, the shop, the pub, the tea room, the wool shop
    z.building(4, 21, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(7, 24, "lerwick_sanctuary", 5, 6, "up")
    z.building(11, 21, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(13, 24, "lerwick_shop", 4, 5, "up")
    ret_pub = door_to(z, 17, 21, 8, 4, 3, "orkney_flagstone", "The Lounge", "lerwick_pub", 13, 10)
    ret_tea = door_to(z, 26, 21, 8, 4, 3, "harbour_white", "Harbour Tea Room", "lerwick_tearoom", 13, 10)
    ret_wool = door_to(z, 42, 21, 8, 4, 3, "orkney_flagstone", "Fair Isle Knitwear", "lerwick_wool", 13, 10)
    # row C: homes
    ret_fid = door_to(z, 4, 30, 8, 4, 3, "croft_house", "Fiddler's House", "lerwick_home_a", 11, 9)
    z.building(13, 30, 7, 4, "harbour_white", "King Harald Street")
    z.building(21, 30, 8, 4, "orkney_flagstone", "Burns Lane")
    z.building(30, 30, 3, 4, "croft_house", "Burns Lane")
    z.building(42, 30, 8, 4, "orkney_flagstone", "Commercial Road")
    # the lodberries: stone houses with their own landing steps, standing out over the water
    for (bx, by) in [(55, 19), (55, 29)]:
        z.building(bx, by, 3, 3, "orkney_flagstone", "Lodberry", show_label=False)
    # Clickimin Loch with its broch on a causeway, and the playing field where the galley burns
    blob(z, 12, 46, 6, 3.2, "~", only="k", seed=21, jitter=0.2)
    blob(z, 12, 46, 7.6, 4.4, "w", only="k", seed=22, jitter=0.2)
    z.rect(10, 45, 5, 3, "k")
    z.building(11, 45, 3, 2, "kirk_ruin", "Clickimin Broch", show_label=True)
    z.rect(12, 43, 1, 2, "#")                          # the causeway
    z.rect(21, 38, 12, 14, "k")
    z.prop("boat", 26, 44, variant=1)
    z.prop("bunting", 22, 38); z.prop("bunting", 31, 38)
    # heather, rocks and sheep: nothing grows tall in Shetland
    z.scatter(2, 36, 18, 16, "h", 40, 71, only="k")
    z.scatter(36, 40, 12, 14, "h", 30, 72, only="k")
    scatter_props(z, "rock", 3, 3, 32, 7, 10, 73, avoid=("k", "h"))
    scatter_props(z, "rock", 36, 38, 12, 16, 6, 74, avoid=("k", "h"))
    for (sx, sy) in [(5, 6), (9, 8), (20, 8), (26, 6), (8, 50), (40, 48)]:
        z.prop("sheep", sx, sy)
    for (lx, ly) in [(39, 8), (39, 20), (45, 17), (52, 10), (52, 30), (20, 17), (8, 25), (30, 34)]:
        z.prop("lamp_post", lx, ly)
    for (bx, by) in [(53, 14), (53, 26), (53, 36)]:
        z.prop("bench", bx, by)
    for (bx, by) in [(52, 24), (52, 34), (52, 8)]:
        z.prop("bollard", bx, by)
    z.prop("lobster_pots", 51, 40); z.prop("buoy", 58, 38)
    # ---- plaques ----
    plaque(z, 42, 17, "shetland_lerwick_name", "Leirvik",
           "Lerwick comes from the Old Norse Leirvik, the muddy or clay bay. Not the grandest name for a capital, but it is honest. It is the only town of any size in Shetland, and home to about a third of everyone who lives on the islands.")
    plaque(z, 46, 17, "shetland_fort_charlotte", "Fort Charlotte",
           "The fort was begun in 1665, in one of the wars with the Dutch, and the Dutch burned it down in 1673 before it was properly finished. It was rebuilt in 1781 and named for Queen Charlotte, wife of George III. It is now in the care of Historic Environment Scotland, and the ramparts are a fine place to watch the ferry come in.")
    plaque(z, 24, 17, "shetland_up_helly_aa", "Up Helly Aa",
           "Up Helly Aa is Lerwick's fire festival, held on the last Tuesday of January. Around a thousand guizers march with burning torches through the town, led by the Guizer Jarl, and then throw the torches into a replica longship. The name meant the end of the holy days, the old end of Yule.")
    plaque(z, 28, 17, "shetland_galley", "The Galley",
           "A new galley is built every year by the Jarl Squad, over the autumn, in a shed like the one behind you. It is about ten metres long, with a dragon head, and it is burned within minutes at the King George V Playing Field. Months of work, and then fire. Everyone agrees it is worth it.")
    plaque(z, 6, 17, "shetland_museum", "The Shetland Museum",
           "The Shetland Museum and Archives opened on Hay's Dock in 2007. Its boat hall holds the sleek wooden Shetland boats, with their Norse lines, and the galleries hold Pictish carved stones and four thousand years of island life. It is lovely, and it is dry, which is not nothing.")
    plaque(z, 53, 22, "shetland_lodberries", "The Lodberries",
           "A lodberry is a Shetland word for a stone-built house or store with its own landing place, sitting at the water's edge. The Lerwick ones date from the 1700s, when merchants had goods landed straight from the boats. Smuggled tea and gin were popular, and the stories are better than the paperwork.")
    plaque(z, 40, 28, "shetland_commercial_street", "Commercial Street",
           "Commercial Street was once the shoreline, which is why the old houses stand with their feet in the water on one side and narrow lanes, called closes, running up the other. It is paved with big flagstones. It is also properly narrow, so passing a delivery van is a social event.")
    plaque(z, 11, 41, "shetland_clickimin", "Clickimin Broch",
           "On a small island in Clickimin Loch stands a broch, an Iron Age tower of dry stone over two thousand years old. It began as a fortified farmstead and was added to over the centuries. A stone causeway runs out to it, and the loch is a pleasant spot for a walk if you ignore the swans.")
    plaque(z, 52, 32, "shetland_bus", "The Shetland Bus",
           "From 1940 to 1945 Norwegian fishermen ran a secret ferry service from Shetland to occupied Norway, carrying agents, radios and refugees across the North Sea in winter nights. They called it the Shetland Bus. The route ran from Lunna and then Scalloway, and was an astonishing piece of seamanship.")
    plaque(z, 45, 26, "shetland_fair_isle", "Fair Isle Knitting",
           "Fair Isle is a tiny island between Shetland and Orkney, and it gave its name to the stranded knitting with bands of patterns in several colours, never more than two in a row. The wool comes from the small Shetland sheep, and the finest lace shawls are so thin they can be pulled through a wedding ring.")
    plaque(z, 14, 17, "shetland_norse", "Norse Shetland",
           "Shetland was part of Norway for centuries and became Scottish in 1469, when it was pledged as part of the dowry of Margaret of Denmark on her marriage to James III. The pledge was never redeemed. You can still find Norse in the place names, the dialect and the festival.")
    plaque(z, 30, 26, "shetland_ponies", "The Shetland Pony",
           "The Shetland pony is among the smallest of horse breeds, no taller than about a metre at the shoulder, and tough as boots. They hauled peat and seaweed on crofts and, in the 1800s, pulled coal wagons underground in mines across Britain. They are small, and they are well aware of it, and they do not care.")
    plaque(z, 53, 12, "shetland_mirrie_dancers", "Mirrie Dancers",
           "In Shetland the northern lights are the mirrie dancers, the merry dancers. On a clear winter night they ripple green across the sky above the harbour, and everyone goes outside for a look, however cold. The islands are so far north that midsummer nights never quite get dark.")
    z.sign(35, 53, "SOUTH: the road to Sumburgh Head, Jarlshof, the ponies and the puffins. WELCOME TO LERWICK.")
    z.sign(36, 17, "THE WATERFRONT: Commercial Street and the Victoria Pier, for the boat to Kirkwall and Aberdeen. NORTH: Fort Charlotte. WEST: the Museum and the Galley Shed.")
    # ---- folk ----
    z.npc(id="ls_ferryhand", sprite="sailor", x=58, y=41, facing="left", move="still", script="ls_ferryhand", name="Ferry Hand")
    script(zid, "ls_ferryhand", say("Ferry Hand",
           "The boat for Kirkwall, and on to Aberdeen. Overnight, the old way: cabin, a hot breakfast and a sea that has views. Hold on to your hat, and your dinner, and sometimes both.") +
           [{"do": "ferry", "route": ROUTE}])
    chat(z, "ls_harbour_hand", "fisherman_north", 52, 40, "Harbour Hand",
         ["Bressay's just across the sound there. The harbour's sheltered by it, which is why Lerwick is here at all. The Dutch herring fleets used to anchor in the sound by the hundred, and the town grew up selling them things.",
          "Mind you don't say 'Shetland Islands' to anyone local who's feeling prickly. 'Shetland' is fine. 'The Shetlands' makes some folk wince, though most are too polite to say."], "down", "wander")
    chat(z, "ls_dialect", "villager_3", 30, 18, "Local Woman",
         ["Shetland dialect is half Scots and half Norse. A 'peerie' thing is a small thing. A 'voe' is a sea inlet, from the Norse. A 'böd' is an old fishing store. A 'ness' is a headland. If you hear 'da' it means 'the', and you're to nod.",
          "The northern lights we call the mirrie dancers. Some say they dance on the ice at the edge of the world. Others say it's the weather. I prefer the dancing."], "right", "wander")
    chat(z, "ls_knitter", "villager_4", 44, 27, "Knitter",
         ["I knit Fair Isle. Two colours a row, no more. It's the carrying of the yarn that does you in, not the knitting. Knit in the round and you've no seams. The old fishermen's jerseys were done that way so there was nothing to rub.",
          "There's a story that the pattern was borrowed from Spanish sailors from a wrecked Armada ship in 1588. It's a nice story. The experts are not convinced."], "down", "still")
    chat(z, "ls_birder", "birdwatcher", 8, 40, "Birdwatcher",
         ["Puffins at Sumburgh Head from May to August, if you're patient, and quiet, and a bit lucky. Then they vanish out to sea for the winter and nobody knows quite where. Arctic terns will dive-bomb you at the nest. Wear a hat. Wear a thick hat.",
          "Shetland has a wren, the Shetland wren, that's a bit bigger and louder than the mainland one. It lives on the cliffs. I think it's smug."], "right", "wander")
    chat(z, "ls_pier_kid", "student", 48, 40, "Schoolkid",
         ["We get a day off for Up Helly Aa. Mum says it's because everyone's been up all night. I say it's because they burned a ship.",
          "My da's in the Jarl Squad this year. He's grown a beard for it. Mum wants it gone. They've been to counselling."], "left", "wander")
    # ---- trainers ----
    trainer(z, "lerwick_skipper", "Skipper Tammie", "Skipper", "fisherman_north",
            fair("greyhaul", "orcaird", "bayrunner", "plungebeak"), 56, 36, "left",
            ["I fish for whitefish and for langoustine, out past Bressay. Up at four, back by lunch, in a mood by six. Fancy a battle? It beats the quota."],
            "Right, fair enough. I'll make the tea.",
            "A boat in Shetland is called a 'yoal' if it's small and a 'sixareen' if it's big. The sixareen has six oars and a fierce crew. The mood in the boat is that of a very long walk.", 3300)
    trainer(z, "lerwick_fiddler", "Fiddler Eilidh", "Fiddler", "fiddler",
            fair("skaldling", "hushwing", "polartern", "goldeneyrie"), 22, 18, "down",
            ["Shetland fiddling is its own thing, quick and Norse-edged, with tunes for every boat and wedding. I'll play you one if you win. If I win, I'll play you three."],
            "A cracker of a battle. Have a tune.",
            "The fiddle came to Shetland in the 1700s. There's now a fiddle in nearly every house and a fiddler in every second one. Weddings go on for days, with the dancing led by whoever can still stand.", 3200)
    trainer(z, "lerwick_knitter", "Knitter Morag", "Knitter", "villager_4",
            fair("herdlet", "heilan", "herdwick", "foalmoor"), 47, 28, "up",
            ["The sheep is the heart of Shetland knitting. Small, tough, a dozen colours in its fleece. I've been clacking needles forty years and I'll clack yours. Battle?"],
            "I'll have to start a new row. Good fight.",
            "The finest Shetland lace comes from the soft undercoat of the sheep, 'rooed' by hand: not cut, but plucked as it moulted. The result is so light a shawl will fit through a ring and a good deal of it will fit in a pocket.", 3150)
    trainer(z, "lerwick_birder", "Birder Hamish", "Birdwatcher", "birdwatcher",
            fair("puffling", "gannetling", "polartern", "snowbunting"), 14, 38, "right",
            ["Shh! Shh. Oh, it's a battle. I'm in the middle of counting terns. Fine, but quietly, in a hushed and respectful manner."],
            "Respectfully done. I lost count of the terns, though.",
            "Arctic terns fly from Shetland to the Antarctic and back every year, about 70,000 kilometres. They see two summers a year. They also, if you get too close, see your hat.", 3200)
    trainer(z, "lerwick_guizer", "Guizer Olaf", "Guizer", "explorer",
            fair("kindlet", "emberdrey", "pyredrey", "heilan"), 24, 40, "right",
            ["I'm practising for Up Helly Aa. Helmet, shield, axe, the lot. The axe is wood and the shield is plywood, mind. Don't think I'll hurt you. Think I'll hurt your feelings."],
            "A noble defeat. Back to the shed.",
            "Guizer means someone in disguise. Every squad has a theme: Vikings, comic characters, anything goes. The Jarl Squad, who march at the front, are always in full Viking.", 3250)
    trainer(z, "lerwick_jarl", "Jarl Sigurd", "Guizer Jarl", "ghillie",
            [("pyredrey", 81), ("orcaird", 81), ("skaldwake", 82), ("tormane", 81), ("clownbill", 81), ("spatelord", 82)], 28, 46, "up",
            ["Behold, the Jarl of Lerwick! Well, this year's, anyway. It's a once in a lifetime job, you only get one go. I've grown a beard, learned to carry a torch with dignity and not fall over. One more thing: win me a battle."],
            "A fine fight. The torches will remember it. Probably in the form of a smell.",
            "Being Guizer Jarl is a lifetime ambition. You wait years, and the choosing is a fraction of the process. The honour is the brightest moment of a man's life and a very big bill for the cloak.", 4200)
    scaled(["lerwick_skipper", "lerwick_fiddler", "lerwick_knitter", "lerwick_birder", "lerwick_guizer", "lerwick_jarl"])
    wild_set(z, [("foalmoor", 10, {}), ("herdlet", 10, {}), ("puffling", 8, {"time": ["day"]}), ("cragchough", 10, {}), ("polartern", 10, {}),
                 ("snowbunting", 8, {"weather": ["frost", "fog"]}), ("midgeswarm", 8, {"time": ["dawn", "dusk"]}), ("hushwing", 6, {"time": ["night"]}),
                 ("haarling", 6, {"weather": ["fog"]}), ("gannetling", 6, {"time": ["day"]})])
    wild_set(z, [("rillotter", 14, {}), ("selklet", 14, {}), ("greyhaul", 12, {}), ("dolphlet", 8, {"time": ["day"]}), ("orcaird", 6, {"time": ["dawn", "dusk"]}),
                 ("gannetling", 10, {}), ("plungebeak", 12, {}), ("chipgull", 8, {}), ("skaldling", 6, {"weather": ["gale", "fog"]})], "water")
    z.d["edges"] = {"south": {"to": "shetland_mainland", "offset": 0}}
    z.d["spawn"] = [35, 33]
    check(z)
    finish(z)
    z.save(OUT + "/" + zid + ".json")

    # ---- interiors ----
    sanctuary(OUT, zid, "Lerwick", (7, 25), music="sanctuary")
    shop(OUT, zid, "Lerwick", (13, 25))
    nurse(zid, ["Hello, hello, come in out of that. Lerwick Sanctuary. You look like you've crossed the North Sea on a bad night. Pop the team on the counter.",
                "There's a kettle on and a plate of bannocks. A Shetland bannock is a sort of soft round loaf, if you were wondering. Poor things, they're perished. There. All better.",
                "There you go. Mind the wind on the way out. It has a grudge against hats.",
                "The Ark's in the corner. Have a look. It has a view of Bressay, which is more than I get.",
                "No bother. If you're here for the fire festival, bring a coat."])
    shopkeeper(zid, "Come away in! Shetland has a shop for everything and I stock most of it: reestit mutton, bannocks, a Fair Isle tammy for the head, tea for the soul.",
               "Thanks, my dear. Mind the wind, and come back when you've the weather for it.")
    interior(OUT, "lerwick_museum", "Shetland Museum and Archives", zid, ret_mus, "museum",
             [npc("ls_curator", "tour_guide", 6, 4, "ls_curator", name="Curator Ingrid", facing="right"),
              npc("ls_boatman", "shipwright", 10, 4, "ls_boatman", name="Boat Builder", facing="left")],
             w=15, h=11,
             props=[("display_case", 2, 3, {"variant": 1}), ("display_case", 12, 3, {"variant": 2}), ("display_case", 7, 2, {"variant": 1})],
             signs=[(4, 6, "THE BOAT HALL. A sixareen, a six-oared fishing boat of the type that went out to the far haaf fishing, forty miles into the Atlantic, in open boats. The men were out a day or more at a time in open boats. The Norse lines of the hull have changed very little in a thousand years."),
                    (10, 6, "THE PICTISH STONES. Carved around 1,300 years ago by the Picts, who lived here before the Norse arrived. A mirror, a comb, a serpent, a crescent. No-one is quite sure what the symbols mean, but they are very stylish about it.")])
    script("lerwick_museum", "ls_curator", [
        cmd_if("q_shetland_survey_done", say("Curator Ingrid", "Your survey is in the files, in a folder called 'The Helpful Visitor', which is a folder of one. Thank you again. The spindle whorl is a copy, by the way. The real ones are in the cupboard."),
               [cmd_if("q_shetland_survey_2",
                       say("Curator Ingrid", "You've done all three! Jarlshof, the cliffs and the answers. Wonderful. I'll write it up: 'Visitor completed South Mainland, unsupervised, did not fall off anything.'",
                           "Here's a spindle whorl. A copy, not a real one: the real ones are over two thousand years old and not in my budget. It's a nice flat stone with a hole in it, and I'm told it's lucky.") +
                       [give("jarlshof_whorl"), {"do": "standing", "nation": "scotland", "amount": 2}, setf("q_shetland_survey_3"), setf("q_shetland_survey_done")],
                       [cmd_if("q_shetland_survey_started",
                               say("Curator Ingrid", "The survey of the South Mainland. Three stops: the archaeologist at Jarlshof, the warden at Sumburgh Head with a Puffling for the cliff records, and then back to me. Take the road south. Watch for the runway."),
                               say("Curator Ingrid", "Welcome to the Shetland Museum! Four thousand years in one building, with a shop. We're short of someone who'll walk to the south end of the Mainland and ask questions on our behalf. I'll make it worth your while.",
                                   "It's a survey. At Jarlshof, the archaeologist will tell you about the oldest settlement in these islands. At Sumburgh Head, the warden will want to see a Puffling for our records. Then come back and tell me about it. Will you do it?") +
                               [choice("Take the Museum's survey?", ["Count me in", "Not just now"], "_survey_ans"),
                                cmd_if("_survey_ans",
                                       say("Curator Ingrid", "Marvellous. South, along the road, all the way. Don't miss the sheep.") + [setf("q_shetland_survey_started")],
                                       say("Curator Ingrid", "The offer stands. The museum is not going anywhere. It is, after all, a museum."), eq=0)])])])])
    script("lerwick_museum", "ls_boatman", say("Boat Builder",
           "Shetland boats are built clinker, with overlapping planks, the way the Norse did, and the old shape is still the best. Hulls like a gull in flight. These are the boats that went out to the haaf, the deep-sea fishery, and the men were out for days. Hard folk.",
           "I build them to the old pattern. It takes a few months, and the paint is applied with great ceremony and a flask of tea. If you build a boat in Shetland you must not leave a nail to hold the wind out. I forget why, but it's an old rule."))
    interior(OUT, "lerwick_townhall", "Lerwick Town Hall", zid, ret_hall, "hall",
             [npc("ls_provost", "choir_singer", 6, 3, "ls_provost", name="Hall Keeper")],
             signs=[(6, 6, "THE WINDOWS. Lerwick Town Hall, built in the 1880s in grand Scottish baronial style, has stained glass windows telling the story of the islands: a Norse earl, a Scottish king, a Viking raid. The tea urn is below that.")])
    script("lerwick_townhall", "ls_provost", say("Hall Keeper",
           "It's a splendid hall, if I say so myself. The windows are my favourites, with the Norse earls in their helmets. Up Helly Aa's feast is held in halls like this one, after the burning: the squads go from hall to hall all night, performing a short act at each, and drinking something warming at every stop.",
           "By the end, it's a sight. Dozens of squads, a dozen halls. Everyone ends up in the wrong hall at least once. Nobody minds."))
    interior(OUT, "lerwick_galley_shed", "Up Helly Aa Galley Shed", zid, ret_gal, "hall",
             [npc("ls_galley_builder", "shipwright", 5, 4, "ls_galley_builder", name="Galley Builder", facing="right"),
              npc("ls_jarl_squad", "ghillie", 10, 4, "ls_jarl_squad", name="Jarl Squad Member", facing="left")],
             w=15, h=11,
             props=[("table", 3, 2, {}), ("table", 11, 2, {}), ("boat", 7, 3, {"variant": 1})],
             signs=[(7, 6, "THE GALLEY. Every year the Jarl Squad builds a new Viking longship here, with a dragon head, about ten metres long. It stands in the shed, then in the town, then on the field. For about twenty minutes, in January, it is the finest thing in Shetland.")])
    script("lerwick_galley_shed", "ls_galley_builder", say("Galley Builder",
           "It takes months. We start in the autumn. The shape is true Viking, with a dragon head carved fresh each year. All of it, from keel to dragon, is built to burn. That's a funny thing to put your heart into.",
           "There's no heartbreak about it. You build it well because you want it to burn well. A bad galley burns badly. A beautiful galley goes up like a cathedral, and the crowd goes quiet, and then roars. Worth every nail."))
    script("lerwick_galley_shed", "ls_jarl_squad", say("Jarl Squad Member",
           "The Guizer Jarl and the Jarl Squad lead the procession in Viking dress: helmet, breastplate, shield, axe, cloak. The Jarl himself is chosen years ahead, and the squad is his friends and family. A thousand torches follow in the dark behind.",
           "We march to the field with the galley on a trailer. At the field, the torches are thrown in, and then we sing 'The Norseman's Home'. If you've never heard a thousand people sing in the cold, with a ship on fire, you've missed a trick."))
    interior(OUT, "lerwick_fort", "Fort Charlotte", zid, ret_fort, "castle",
             [npc("ls_guide", "tour_guide", 6, 3, "ls_guide", name="Fort Guide")],
             signs=[(6, 6, "THE RAMPARTS. A five-sided fort, built to guard Bressay Sound. Cannon on the walls, grass on the roof, and a view of the harbour that makes it worth the climb. From here you can watch the ferry coming in from Aberdeen at dawn.")])
    script("lerwick_fort", "ls_guide", say("Fort Guide",
           "The fort was meant to guard the sound against the Dutch, who were fishing for herring here in huge numbers. The irony is that they got annoyed in 1673 and burned the unfinished walls. They rebuilt it later, and named it after Queen Charlotte.",
           "It is open for visitors now. The cannon face the water. Every so often a tourist asks if they work. They do not. We have checked."))
    interior(OUT, "lerwick_pub", "The Lounge", zid, ret_pub, "cafe",
             [npc("ls_landlord", "villager_2", 3, 1, "ls_landlord", name="Landlord"),
              npc("ls_fiddle_pub", "fiddler", 9, 3, "ls_fiddle_pub", name="Session Fiddler", facing="left")],
             props=[("fireplace", 6, 1, {"walk": True})])
    script("lerwick_pub", "ls_landlord", say("Landlord",
           "Welcome to The Lounge. We've a session on a Saturday, and the quiz is on Thursday. Shetland trivia, with penalties for people who say 'Orkney' by mistake. Losers buy the crisps.") +
           [{"do": "quiz", "pub": "lerwick_pub", "region": "scotland", "who": "Landlord"}])
    script("lerwick_pub", "ls_fiddle_pub", say("Session Fiddler",
           "A session is when a lot of folk with fiddles sit in a corner and play the same tune at different speeds, and it works. The tunes are named for places and boats and people who annoyed the composer.",
           "Shetland tunes have a lift to them, a swing. Strong and quick, and you can feel the Norse in them. The old tunes are called things like 'Da Slockit Light', which means 'the light that has gone out'. A famous slow air, and a cheerful one, all things considered."))
    interior(OUT, "lerwick_tearoom", "Harbour Tea Room", zid, ret_tea, "cafe",
             [npc("ls_tea_lady", "villager_4", 3, 1, "ls_tea_lady", name="Tea Room Lady"),
              npc("ls_soup_fan", "fisherman_north", 9, 3, "ls_soup_fan", name="Fisherman", facing="left")],
             props=[("fireplace", 6, 1, {"walk": True})])
    script("lerwick_tearoom", "ls_tea_lady", say("Tea Room Lady",
           "Soup, bannocks and a pot of tea strong enough to stand a spoon in. The Shetland bannock is a soft round loaf, cooked on a girdle, good with butter and jam. We do a lot of reestit mutton soup in winter, if you're after something proper.",
           "Reestit mutton is mutton that's been salted and hung to dry in the rafters, the old way. In the soup it's wonderful. It is also, I'm told, an acquired taste. The acquiring takes about one bowl."))
    script("lerwick_tearoom", "ls_soup_fan", say("Fisherman",
           "Fish tea, we called it when I was a lad. Not tea, mind. A fish supper with the tea. The boats came in, the fish were boiled with tatties, and everyone sat down. That was it. It was glorious.",
           "Now we've got tasting menus. I had a lamb the size of a thumb on a plate the size of a hat. I paid thirty pounds and went home for a sandwich."))
    interior(OUT, "lerwick_wool", "Fair Isle Knitwear", zid, ret_wool, "workshop",
             [npc("ls_wool_dyer", "villager_6", 6, 3, "ls_wool_dyer", name="Dyer")],
             props=[("table", 3, 3, {}), ("table", 9, 3, {})],
             signs=[(6, 6, "FAIR ISLE. Bands of pattern, never more than two colours in a row. Crosses, stars, snowflakes and OXO motifs. The colours are the colours of Shetland: peat brown, sea blue, moorit (a warm brown sheep colour), and the red of someone who just remembered it was 4 degrees.")])
    script("lerwick_wool", "ls_wool_dyer", say("Dyer",
           "Shetland has eleven natural sheep colours, from white through fawn and moorit to grey and black, and most of them come off the animal that way. Traditional dyes came from the land: crottle lichen from rocks, madder, indigo, heather for yellow.",
           "I've a hat for sale in every colour you can name, and some you can't. There's a name for a knitter who can read a Fair Isle chart on sight. It's 'grandmother'."))
    interior(OUT, "lerwick_home_a", "Fiddler's House", zid, ret_fid, "home",
             [npc("ls_fiddler_home", "fiddler", 4, 3, "ls_fiddler_home", name="Old Fiddler")], w=11, h=9)
    script("lerwick_home_a", "ls_fiddler_home", say("Old Fiddler",
           "I've played the fiddle for sixty years. Weddings, funerals, once a christening in a gale. The wedding fiddler plays all night, and if the bride isn't danced off her feet, it's a poor do.",
           "My granny said the best tunes came from the sea. A fiddler sat in a boat, listening to the waves, would get a rhythm, and the rhythm became a reel. It's a lie, I think. But a good one."))


# =====================================================================================================
# the Mainland, south of Lerwick
# =====================================================================================================

def mainland(OUT):
    W, H = 56, 64
    zid = "shetland_mainland"
    z = Z(zid, "Mainland and Sumburgh", W, H, kind="route", region=SCOT, music="route_coast", weather=WX)
    z.d["stage"] = "coast"; z.d["scaled_floor"] = FLOOR
    z.legend["k"] = {"tile": "grass", "colour": "#7d8c55"}
    z.legend["h"] = {"tile": "tall_grass", "colour": "#7a5c6a", "prop": "heather"}
    z.rect(0, 0, W, H, "k")

    def wshore(y):
        return 6 + int(round(2 * math.sin(y / 7.0)))

    def eshore(y):
        return 49 + int(round(2 * math.sin(y / 6.0)))
    for y in range(H):
        sx = wshore(y)
        z.rect(0, y, sx - 1, 1, "$"); z.set(sx - 1, y, "w")
        ex = eshore(y)
        z.rect(ex, y, W - ex, 1, "$"); z.set(ex - 1, y, "w")
    z.rect(0, 61, W, 3, "$"); z.rect(0, 60, W, 1, "w")
    z.rect(0, 0, 8, 2, "$"); z.rect(46, 0, 10, 2, "$")
    for x in range(W):
        for y in (0, 1):
            if z.g[y][x] != "=":
                z.g[y][x] = "R" if 8 <= x < 46 else "$"
    # the road: down from Lerwick, a jog east, back west, then south to the lighthouse
    z.rect(34, 0, 3, 23, "=")
    z.rect(34, 21, 10, 3, "=")
    z.rect(41, 21, 3, 22, "=")
    z.rect(34, 41, 10, 3, "=")
    z.rect(34, 41, 3, 17, "=")
    # heather hill, rocks, sheep
    z.scatter(9, 4, 22, 14, "h", 60, 81, only="k")
    z.scatter(8, 50, 18, 8, "h", 25, 82, only="k")
    scatter_props(z, "rock", 8, 3, 40, 56, 22, 83, avoid=("k", "h"))
    for (sx, sy) in [(12, 24), (20, 27), (28, 28), (14, 54), (24, 52), (46, 36), (47, 10)]:
        z.prop("sheep", sx, sy)
    # the pony field: Shetland ponies on the hill, with their breeder at the gate
    z.rect(9, 5, 22, 1, "W"); z.rect(9, 14, 22, 1, "W"); z.rect(9, 5, 1, 10, "W"); z.rect(30, 5, 1, 10, "W")
    z.rect(30, 9, 1, 2, "k")  # the gate
    for (px, py, mv) in [(14, 8, "wander"), (19, 10, "wander"), (24, 7, "wander"), (26, 12, "wander")]:
        _stand(z, px, py)
        z.npc(id="sm_pony_%d_%d" % (px, py), sprite="creature:foalmoor", x=px, y=py, facing="down", move=mv, script="sm_pony", name="Shetland Pony")
    script(zid, "sm_pony", say("", "A Shetland pony, about the size of a large dog, chewing with great concentration. It looks at you as if you were a delivery it hadn't ordered."))
    # Gudrun and the judge
    _stand(z, 32, 10)
    z.npc(id="sm_breeder", sprite="farmer", x=32, y=10, facing="left", move="still", script="sm_breeder", name="Gudrun the Breeder")
    _stand(z, 32, 13)
    z.npc(id="sm_judge", sprite="shipwright", x=32, y=13, facing="left", move="still", script="sm_judge", name="Show Judge", show_if="q_shetland_ponies_1", hide_if="q_shetland_ponies_done")
    script(zid, "sm_breeder", [
        cmd_if("q_shetland_ponies_done", say("Gudrun the Breeder", "The rosette's on the kitchen wall. Between the ponies and the knitting, you'd think my house was a county fair. Come back any time. Mind the biting one."),
               [cmd_if("q_shetland_ponies_2",
                       say("Gudrun the Breeder", "You beat the judge! Nobody beats the judge. He's been judging for thirty years, and has decided against everyone on principle. Here: the show rosette, and a word of thanks from the ponies, who can't give you one themselves.") +
                       [give("pony_rosette"), {"do": "standing", "nation": "scotland", "amount": 2}, setf("q_shetland_ponies_done")],
                       [cmd_if("q_shetland_ponies_1",
                               say("Gudrun the Breeder", "A Foalmoor, in your Fieldbook! A fine pony. The judge is at the gate. He's strict, so mind your manners. Go on."),
                               [cmd_if("q_shetland_ponies_started",
                                       [when("has_foalmoor",
                                             say("Gudrun the Breeder", "That's a Foalmoor, right enough. Stocky, handsome and inclined to bite. A proper Shetland. The show judge is by the gate. He'll test your nerve, and your team's.") + [setf("q_shetland_ponies_1")],
                                             say("Gudrun the Breeder", "Not yet. The small stocky ones on the heath, they're Foalmoors. Catch one and bring it to show me."))],
                                       say("Gudrun the Breeder", "Ponies! Shetland ponies, the real thing. Small, strong, clever, and with the tact of a brick. We've a show coming and I need someone to take part. A good show needs a pony and a proper fight.",
                                           "Catch a Foalmoor on the hill, and show me. Then the judge will want a word. Will you?") +
                                       [choice("Join the pony show?", ["Count me in", "Not just now"], "_pony_ans"),
                                        cmd_if("_pony_ans", [setf("q_shetland_ponies_started")], say("Gudrun the Breeder", "The ponies will wait. They're good at it."), eq=0)])])])])])
    script(zid, "sm_judge", say("Show Judge",
           "I've judged this show for thirty years. A good pony stands square, holds its head high, and has that look of someone who's just remembered an appointment. Let's see your team stand up. Your creatures, I mean. Not the ponies.") +
           [{"do": "battle", "trainer": "shetland_ponyjudge", "intro": True}] +
           say("Show Judge", "Well. I may have been too harsh with the last lot. Ten out of ten. Tell Gudrun I said 'adequate', which is as high as I go.") + [setf("q_shetland_ponies_2")])
    # ---- Jarlshof ----
    z.rect(24, 34, 18, 1, "#")
    z.building(14, 30, 8, 4, "kirk_ruin", "Jarlshof", show_label=True)
    for (rx, ry) in [(12, 29), (22, 36), (10, 35), (18, 37)]:
        z.prop("standing_stone", rx, ry)
    z.rect(11, 34, 13, 1, "#")
    _stand(z, 20, 35)
    z.npc(id="sm_archaeologist", sprite="prof_garside", x=20, y=35, facing="up", move="still", script="sm_archaeologist", name="Archaeologist")
    script(zid, "sm_archaeologist", [
        cmd_if("q_shetland_survey_1", say("Archaeologist", "Back again? The pot's still a pot. Take the road south to the lighthouse. And mind the runway. They stop the road for aeroplanes, it's the only place in the country where you can be late for a flight and early for a ferry."),
               [cmd_if("q_shetland_survey_started",
                       say("Archaeologist", "A visitor, with a clipboard from the museum! Excellent. Jarlshof is four thousand years of settlement in one place: Bronze Age houses, an Iron Age broch, Norse longhouses, a medieval farmhouse and a laird's house, all on top of each other.",
                           "The name is a joke, in fact. Walter Scott invented it in a novel, 'The Pirate', in 1822. The place had a different name. We've forgotten it. One question, and I'll sign your sheet: who were the first inhabitants?") +
                       [choice("Who lived here first?", ["Prehistoric farmers", "The Romans", "Medieval monks"], "_jarl_ans"),
                        cmd_if("_jarl_ans", say("Archaeologist", "Prehistoric farmers, thousands of years before the Norse. The Bronze Age round houses are the oldest you can see, and the later folk built on top. Excellent. Your sheet is signed. On to Sumburgh Head!") + [setf("q_shetland_survey_1")],
                               say("Archaeologist", "No, no. Think older. The Romans never came this far north. Try again; the pottery is certainly not in a hurry."), eq=0)],
                       say("Archaeologist", "Jarlshof! Four thousand years of people, one on top of the other, like a very old sandwich. Do look round. The museum in Lerwick has a survey if you're interested in helping out."))])])
    # ---- the runway: the road crosses it ----
    z.rect(7, 47, 42, 3, "_")
    z.rect(34, 47, 3, 3, "=")
    z.building(10, 42, 11, 4, "airport_terminal", "Sumburgh Airport", show_label=True)
    _stand(z, 38, 46)
    z.npc(id="sm_marshal", sprite="rail_guard", x=38, y=46, facing="down", move="still", script="sm_marshal", name="Airport Marshal")
    script(zid, "sm_marshal", say("Airport Marshal",
           "Yes, the road crosses the runway. Yes, they stop the traffic when a plane lands, with a barrier like a level crossing, red lights and all. It's one of the few places in Britain where you can be held up by a Saab.",
           "Don't stand on the runway. It's not the planes I worry about. It's the paperwork."))
    # ---- Mousa across the water, and St Ninian's Isle ----
    blob(z, 52, 27, 2.4, 2, "k", only="$", seed=9, jitter=0.2)
    z.building(51, 26, 2, 2, "kirk_ruin", "Mousa Broch", show_label=True)
    z.rect(9, 17, 25, 1, "#")
    z.rect(4, 16, 5, 3, "s")
    blob(z, 3, 17, 2, 2, "k", only="$", seed=3, jitter=0.1)
    # ---- Sumburgh Head ----
    z.rect(30, 56, 10, 3, "k")
    z.prop("lighthouse", 38, 58)
    _stand(z, 36, 55)
    z.npc(id="sm_warden", sprite="warden_grunt", x=36, y=55, facing="up", move="still", script="sm_warden", name="Head Warden")
    script(zid, "sm_warden", [
        cmd_if("q_shetland_survey_2", say("Head Warden", "That's you in the log: 'one visitor, one Puffling, no incidents.' Away back up the road to the Museum. And thank you."),
               [cmd_if("q_shetland_survey_1",
                       [when("has_puffling",
                             say("Head Warden", "A Puffling! In the book it goes. They're on these cliffs from May to August, in burrows, with their little orange feet. Then in autumn they head out to sea, and nobody quite knows where, which I find very restful.") + [setf("q_shetland_survey_2")],
                             say("Head Warden", "Sumburgh Head, with the lighthouse of 1821 by Robert Stevenson, grandfather of the author. We need a Puffling for the log. They like the cliff tops and the grass. Catch one and show me."))],
                       say("Head Warden", "Sumburgh Head! The lighthouse, the cliffs, and the puffins in summer. If the museum sent you, you'll want the archaeologist at Jarlshof first."))])])
    # ---- plaques ----
    plaque(z, 35, 56, "shetland_sumburgh", "Sumburgh Head",
           "Sumburgh Head lighthouse was built in 1821 to a design by Robert Stevenson, one of the famous family of lighthouse engineers, to guard the dangerous waters where the North Sea meets the Atlantic. Today it is a nature reserve, and from May to August the cliffs are crowded with puffins, guillemots and fulmars.")
    plaque(z, 24, 33, "shetland_jarlshof", "Jarlshof",
           "Jarlshof was a settlement for about four thousand years, from Bronze Age round houses to Iron Age brochs, Norse longhouses and a medieval farm. A storm in the 1890s stripped away the dune and revealed it all. The name comes from Walter Scott's 1822 novel The Pirate, and it stuck.")
    plaque(z, 44, 26, "shetland_mousa", "Mousa Broch",
           "On the little island of Mousa across the sound stands the best-preserved broch in the world, about thirteen metres tall, built over two thousand years ago. It is mentioned in a Norse saga, where two runaway lovers hole up inside. Today storm petrels nest in the stonework on summer nights.")
    plaque(z, 8, 17, "shetland_st_ninians", "St Ninian's Isle",
           "St Ninian's Isle is joined to the Mainland by a tombolo, a curving ridge of sand, one of the finest in Britain. In 1958 a schoolboy found a hoard of silver under a slab in the ruined chapel: bowls, brooches and a sword chape, probably hidden around 800 AD. The originals are in Edinburgh.")
    plaque(z, 38, 45, "shetland_runway", "The Runway Crossing",
           "At Sumburgh, the main road across the south of the Mainland crosses the airport runway. When a plane is due, barriers come down and the road is closed. It is one of the few roads in Britain where you can be held up by a Saab.")
    z.sign(35, 3, "NORTH: Lerwick, the museum and the Victoria Pier. SOUTH: Jarlshof, Sumburgh Airport and Sumburgh Head. Please close the gate; ponies have no sense of direction.")
    # ---- more trainers ----
    trainer(z, "mainland_crofter", "Crofter Magnus", "Crofter", "farmer",
            fair("foalmoor", "herdlet", "herdwick", "heilan"), 26, 20, "down",
            ["I've twelve sheep, three ponies and a dog that thinks it's a pony. A croft is a very small farm with a very large number of opinions. Fancy a battle?"],
            "Not bad. Take a bannock for the road.",
            "A croft is a small farm worked by a tenant, with common grazing on the hill. Crofters have rights in law, which is why they're so hard to shift. In the 1880s the crofters fought for those rights and won.", 3200)
    trainer(z, "mainland_diver", "Diver Freya", "Diver", "surfer",
            fair("rillotter", "selklet", "dolphlet", "spatelord"), 10, 20, "down",
            ["I dive the wrecks round Sumburgh. Cold? It's colder than a Tuesday in Glasgow. But the water is clear and the otters wave at you, so I forgive the frostbite."],
            "Swimmingly done. I'll dry off now.",
            "Shetland otters live on the coast, in the sea. They eat fish and crabs among the kelp and sleep in holts above the shore. You might see one at dusk, rolling in the weed with a crab.", 3150)
    trainer(z, "mainland_ranger", "Ranger Bryony", "Ranger", "hillwalker",
            fair("puffling", "gannetling", "polartern", "peregrin"), 40, 52, "left",
            ["I look after the cliffs. My job is to stand around in a hi-vis jacket and tell people to keep back from the edge. I'm very, very good at it. Now keep back. Battle?"],
            "A fair win. Mind the edge on the way off.",
            "A puffin's beak is at its brightest in the breeding season, and it sheds the colourful plates in winter. It can hold a dozen sandeels at once, lined up crosswise, and it flies at 80 kilometres an hour with its wings a blur.", 3250)
    TRN["shetland_ponyjudge"] = {"id": "shetland_ponyjudge", "name": "Show Judge", "class": "Show Judge", "sprite": "shipwright",
                                 "party": [{"species": s, "level": lv} for s, lv in [("tormane", 81), ("foalmoor", 80), ("heilan", 81), ("herdwick", 81)]],
                                 "ai": "trainer", "money": 3600,
                                 "intro": say("Show Judge", "Four of yours against four of mine. Remember: stand square, hold your head high, and no biting. The ponies may bite. You may not."),
                                 "win": "Adequate. Highly adequate.", "after": "The ponies are watching. They have opinions.", "scaled_floor": FLOOR}
    scaled(["mainland_crofter", "mainland_diver", "mainland_ranger"])
    wild_set(z, [("foalmoor", 14, {}), ("herdlet", 10, {}), ("puffling", 10, {"time": ["day"]}), ("cragchough", 8, {}), ("polartern", 10, {}),
                 ("gannetling", 6, {"time": ["day"]}), ("snowbunting", 6, {"weather": ["frost", "fog"]}), ("midgeswarm", 8, {"time": ["dawn", "dusk"]}),
                 ("hushwing", 6, {"time": ["night"]}), ("haarling", 6, {"weather": ["fog"]}), ("crexling", 6, {})])
    wild_set(z, [("rillotter", 16, {}), ("selklet", 12, {}), ("greyhaul", 12, {}), ("gannetling", 12, {}), ("plungebeak", 10, {}), ("dolphlet", 8, {"time": ["day"]}),
                 ("orcaird", 6, {"time": ["dawn", "dusk"]}), ("skaldling", 6, {"weather": ["gale", "fog"]})], "water")
    z.d["edges"] = {"north": {"to": "lerwick", "offset": 0}}
    z.d["spawn"] = [35, 6]
    check(z)
    finish(z)
    z.save(OUT + "/" + zid + ".json")


def memory_coach(OUT):
    import json
    path = OUT + "/lerwick_sanctuary.json"
    z = json.load(open(path))
    if not any(n.get("id") == "memory_coach" for n in z["npcs"]):
        z["npcs"].append({"id": "memory_coach", "sprite": "poet", "x": 8, "y": 4, "facing": "down", "move": "still",
                          "script": "memory_coach", "name": "Retired Keeper"})
        json.dump(z, open(path, "w"), indent=1, ensure_ascii=False)


if __name__ == "__main__":
    OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
    lerwick(OUT)
    mainland(OUT)
    memory_coach(OUT)
    write_all(OUT)
    print("shetland: written")
