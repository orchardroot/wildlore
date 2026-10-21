# Jersey: St Helier (the town, harbour, Elizabeth Castle on its tidal islet) and the island's countryside to the north
# and east (Gorey and Mont Orgueil, La Hougue Bie, the War Tunnels, Durrell, the Royal fields and Bouley Bay).
from ci_common import *
from wcommon import _stand


def build():
    st_helier()
    jersey_country()


def st_helier():
    W, H = 64, 52
    zid = "st_helier"
    z = Z(zid, "St Helier", W, H, kind="town", region=REG, music="town_cornwall",
          weather={"drizzle": 22, "clear": 30, "sunshine": 24, "fog": 8, "gale": 8, "downpour": 8})
    z.d["stage"] = "coast"; z.d["town_id"] = zid; z.d["scaled_floor"] = FLOOR
    z.legend["g"] = {"tile": "tall_grass", "colour": "#8aa550", "prop": "short"}
    z.rect(0, 0, W, H, ".")
    z.border("T", 2, gaps=[(30, 0, 3, 2)])
    z.scatter(0, 0, W, H, "P", 8, 6, only="T")
    # St Aubin's Bay: sand, shallows, open water
    z.rect(0, 38, W, 3, "s"); z.rect(0, 41, W, 1, "w"); z.rect(0, 42, W, 10, "$")
    # roads: the way north, Queen Street, the paved block between it and the promenade
    z.rect(30, 0, 3, 16, "="); z.rect(3, 16, 58, 14, ":"); z.rect(3, 34, 58, 4, ":")
    # Elizabeth Castle on its tidal islet, and the causeway across the sand
    z.rect(6, 43, 17, 8, "s"); z.rect(7, 44, 15, 5, "."); z.rect(12, 38, 3, 5, "s")
    z.building(9, 44, 9, 4, "castle", "Elizabeth Castle", door=4)
    z.warp(13, 47, "st_helier_castle", 7, 7, "up")
    # Fort Regent on its hill, the Royal Court, the Parish Church
    z.building(37, 4, 14, 6, "castle", "Fort Regent")
    # row A, facing Queen Street
    z.building(4, 12, 6, 4, "sanctuary", "Sanctuary", door=3); z.warp(7, 15, "st_helier_sanctuary", 5, 6, "up")
    z.building(11, 12, 5, 4, "shop", "Corner Shop", door=2); z.warp(13, 15, "st_helier_shop", 4, 5, "up")
    z.building(18, 11, 9, 5, "chapel", "Parish Church of St Helier", door=4); z.warp(22, 15, "st_helier_church", 6, 7, "up")
    z.building(35, 12, 8, 4, "georgian_brick", "The Royal Court", door=4); z.warp(39, 15, "st_helier_court", 6, 7, "up")
    z.building(46, 12, 8, 4, "jersey_granite", "The Crapaud Arms", door=4); z.warp(50, 15, "st_helier_pub", 5, 6, "up")
    z.building(55, 12, 5, 4, "jersey_granite", show_label=False)
    # row B, facing the Rue
    z.building(4, 18, 10, 4, "market_hall", "Central Market", door=5); z.warp(9, 21, "st_helier_market", 6, 7, "up")
    z.building(16, 18, 9, 4, "jersey_granite", "Jersey Museum", door=4); z.warp(20, 21, "st_helier_museum", 6, 7, "up")
    z.building(36, 18, 9, 4, "waterfront_museum", "Maritime Museum", door=4); z.warp(40, 21, "st_helier_maritime", 6, 7, "up")
    z.building(47, 18, 6, 4, "jersey_granite", show_label=False)
    z.building(54, 18, 6, 4, "guest_house", show_label=False)
    z.building(26, 18, 4, 4, "jersey_granite", show_label=False)
    # row D, facing the promenade
    z.building(4, 30, 8, 4, "jersey_granite", show_label=False)
    z.building(13, 30, 8, 4, "guest_house", show_label=False)
    z.building(26, 30, 7, 4, "harbour_row", "The Crab Shack", door=3); z.warp(29, 33, "st_helier_crab", 5, 6, "up")
    z.building(35, 30, 6, 4, "jersey_granite", show_label=False)
    z.building(46, 30, 8, 4, "jersey_granite", show_label=False)
    z.building(55, 30, 5, 4, "guest_house", show_label=False)
    # the harbour pier and its ferry
    z.rect(41, 36, 4, 11, ":")
    z.d["ferry"] = {"x": 43, "y": 45, "route": "st_helier_st_peter_port"}
    z.prop("bollard", 41, 40); z.prop("bollard", 44, 40)
    # the Square: statues, stalls, benches, lamps, bunting
    z.prop("statue", 24, 26, variant=1)
    z.prop("statue", 50, 26, variant=2)
    for x in (8, 10, 12):
        z.prop("market_stall", x, 26)
    for (x, y) in [(18, 27), (31, 27), (38, 27), (57, 27), (6, 35), (24, 35), (50, 35)]:
        z.prop("bench", x, y)
    for (x, y) in [(3, 17), (15, 22), (28, 22), (34, 22), (45, 22), (60, 17), (3, 29), (22, 29), (46, 29), (58, 29), (9, 36), (36, 36)]:
        z.prop("lamp_post", x, y)
    z.prop("bunting", 30, 17, variant=1, walk=True); z.prop("bunting", 30, 23, variant=3, walk=True)
    z.prop("flagpole", 34, 27, variant=6)
    z.prop("post_box", 3, 22); z.prop("phone_box", 59, 22)
    for (x, y) in [(26, 44), (36, 45), (52, 44), (58, 46)]:
        z.prop("boat", x, y, variant=(x + y) % 3)
    for (x, y) in [(28, 43), (48, 43)]:
        z.prop("buoy", x, y)
    # a green: tall grass in the parks north-west and north-east
    blob(z, 14, 6, 9, 2, ",", only=".", seed=51, jitter=0.3)
    blob(z, 56, 7, 4, 2, ",", only=".", seed=52, jitter=0.3)
    scatter_props(z, "oak", 3, 3, 26, 6, 8, 54, avoid=("."))
    scatter_props(z, "oak", 52, 3, 8, 8, 3, 55, avoid=("."))
    fingerpost(z, 29, 3, "NORTH: the rest of Jersey. Gorey and Mont Orgueil, the War Tunnels, Durrell and the cliffs of the north coast.")
    fingerpost(z, 12, 37, "ELIZABETH CASTLE. The causeway is open for walkers at low tide only. If the sea is over the sand, it is not open. Believe the sea.")
    fingerpost(z, 40, 37, "HARBOUR. Ferries for Guernsey and Poole from the pier. The Jersey Lily and the Bailiwick Belle, weather permitting.")
    # plaques
    plaque(z, 21, 17, "helier", "St Helier",
           "The town is named for a hermit. Helier, a missionary from the Low Countries, lived on a rock in the bay in the 6th century, and was killed by pirate raiders about the year 555, so the story goes. The rock is by Elizabeth Castle and is called the Hermitage. In Jèrriais the town is St Hélyi.")
    plaque(z, 14, 40, "elizabeth", "Elizabeth Castle",
           "Begun in the 1590s on a tidal islet, when Spain's Armada was a recent memory. Sir Walter Raleigh, Governor of Jersey from 1600, named it Fort Isabella Bellissima for Elizabeth I. Charles II sheltered here as a boy in 1646 and again in 1649 and 1650. The Germans fortified it, too. At low tide you can walk across the sand to the castle gate.")
    plaque(z, 25, 24, "square", "The Royal Square",
           "On 6 January 1781 a French force under Baron de Rullecourt landed at night, captured the lieutenant governor and marched into this square. Major Francis Peirson, aged 24, led the British counter-attack and won within the hour. He was killed in the fighting. John Singleton Copley painted The Death of Major Peirson, which hangs in Tate Britain.")
    plaque(z, 33, 25, "george", "King George II",
           "The gilded statue in the square shows George II as a Roman emperor, in the dress of the old Caesars. It was put up in 1751, and a loyal Jersey has kept it polished ever since. The islands owe loyalty to the Crown as the successor to the old Dukes of Normandy.")
    plaque(z, 49, 25, "liberation", "Liberation Square",
           "Jersey was occupied by German forces from 1 July 1940 until 9 May 1945. On Liberation Day crowds filled the harbour front to welcome the British troops ashore. The bronze sculpture of 1995 shows islanders raising the Union Flag, and 9 May is a public holiday in Jersey and Guernsey every year.")
    plaque(z, 8, 25, "sth_market", "The Central Market",
           "A Victorian covered market, opened in 1882, with a cast-iron and glass roof, a fountain in the middle and stalls of fish, flowers, fruit and cheese. A pavement full of locals shopping for dinner is the best sign it works. The fish hall is at one end, and the potatoes in spring are at the other.")
    plaque(z, 44, 11, "fort_regent", "Fort Regent",
           "A granite fortress built on the hill above the town between 1806 and 1814, when the island feared invasion by Napoleon's France. It was named for the Prince Regent, later George IV. It has been a leisure centre since the 1970s, with swimming pools where the cannon used to be.")
    plaque(z, 58, 22, "jerriais", "Jèrriais",
           "The Norman-French language of Jersey, spoken here since the island belonged to the Duchy of Normandy. Normandy was lost to the English crown in 1204, but the islands stayed loyal. They still toast the king as 'our Duke'. A handful of islanders speak Jèrriais today, and schools teach it. Bouônjour means good day.")
    plaque(z, 30, 35, "vraic", "Vraic",
           "Vraic is the Jersey word for seaweed, which islanders once gathered off the shore in carts and spread on the fields as fertiliser, or dried and burned. A day set aside for gathering it was called vraicing. It is still used on the Jersey Royal potato fields.")
    # people
    chat(z, "sth_hermit_fan", "pilgrim", 20, 40, "Walker",
         ["Helier the hermit lived out on that rock and is said to have prayed all day while the pirates were coming. They put him to the sword, but not before he'd finished.",
          "Check the tide table before you cross. Folk have been caught out on the causeway. The sea doesn't come in, it just stops going out and you suddenly realise."], "right")
    chat(z, "sth_crapaud", "villager_2", 20, 26, "Local",
         ["Jerseymen are called crapauds, which means toads. Nobody can quite agree why. There are plenty of toads, and plenty of theories.",
          "Guernsey folk are called donkeys, ânes, some say for their steep streets and some say for their stubbornness. Sark's lot are crows. We've all got a name, and we've all been quietly insulted."], "right")
    chat(z, "sth_langtry", "villager_6", 38, 24, "Jersey Lily Fan",
         ["Lillie Langtry was born at St Saviour in 1853, the Dean's daughter. She became one of the most photographed women in England, an actress, a friend of the Prince of Wales and, I'm told, the owner of a racehorse called Merman.",
          "Millais painted her holding a lily in 1878 and called it 'A Jersey Lily'. A lily, that is, not an actual lily. The name stuck to her for life."], "left")
    # trainers
    trainer(z, "sth_fishmonger", "Fishmonger Vibert", "Fishmonger", "fisherman_north",
            [("pinchkin", 40), ("baskling", 41), ("selklet", 41)], 22, 30, "down",
            ["Spider crab, lobster, scallops and ormers, if you're lucky and licensed. I'd rather sell you a fish than fight you, but I'll do either."],
            "Oh, you've netted me. Have a scallop on the house.", "Ormers are a kind of abalone, a shell like a mother-of-pearl ear. You may only gather them on a few days a year, at the very lowest spring tides. Don't ask me where I get mine.", 780)
    trainer(z, "sth_centenier", "Centenier Mauger", "Honorary Police", "warden_grunt",
            [("barkdeer", 41), ("ratty", 41), ("hazeldoze", 42)], 38, 29, "left",
            ["Honorary Police, that is. I'm elected by the parish and I'm not paid a penny, and I have the power to charge you. Don't tempt me."],
            "Fair do's. I'll not take you in.", "Every parish elects its own Honorary Police, a unique system the islands have kept for hundreds of years. We're volunteers, and we're nosy.", 800)
    trainer(z, "sth_banker", "Financier Le Poidevin", "Financier", "commuter",
            [("rivetling", 40), ("cooplet", 41), ("binfox", 42)], 57, 25, "left",
            ["I work in finance. Don't ask what I do, I'd have to charge you. The islands do very nicely on trust, funds and good lawyers."],
            "Dear me. A loss. I'll write that off against something.", "Jersey sets its own taxes and has done for centuries. We're not part of the UK and not part of the EU, but we're awfully good at paperwork.", 960)
    trainer(z, "sth_swimmer", "Swimmer Gwen", "Sea Swimmer", "jogger",
            [("dolphlet", 41), ("orcalet", 41), ("puffling", 40)], 36, 38, "right",
            ["I swim in the bay every day of the year. It's eight degrees in January and I feel marvellous. That's the cold talking."],
            "Fair play. I'm off for a hot chocolate and a lie down.", "The tides here are some of the biggest in Europe, up to twelve metres between low and high. Sandy beaches turn into a mile of rock pools twice a day.", 740)
    scale(["sth_fishmonger", "sth_centenier", "sth_banker", "sth_swimmer"])
    wild(z, [("chipgull", 40, 42, 14, {}), ("ternlet", 40, 41, 12, {}), ("starlet", 40, 41, 8, {"time": ["dawn", "day", "dusk"]}),
             ("moolet", 40, 42, 10, {}), ("herdlet", 40, 41, 8, {}), ("pinchkin", 40, 41, 10, {}),
             ("crockling", 40, 41, 6, {}), ("beancrock", 41, 42, 3, {"time": ["dusk", "night"]}),
             ("hootlet", 41, 42, 6, {"time": ["night"]}), ("binfox", 41, 42, 6, {"time": ["dusk", "night"]})])
    wild(z, [("pinchkin", 40, 41, 16, {}), ("baskling", 40, 42, 12, {}), ("selklet", 40, 42, 10, {}), ("dolphlet", 40, 42, 10, {}),
             ("puffling", 40, 41, 10, {"season": ["spring", "summer"]}), ("pupplash", 40, 42, 10, {}), ("vraicling", 41, 43, 6, {"weather": ["gale", "downpour", "drizzle"]}),
             ("orcalet", 41, 42, 3, {})], "water")
    z.d["edges"] = {"north": {"to": "jersey_country", "offset": 0}}
    z.d["spawn"] = [31, 20]
    seal(z, [(30, 0, 3, 2)])
    done(z)
    z.save(OUT + "/" + zid + ".json")

    sanctuary(OUT, zid, "St Helier", (7, 16))
    shop(OUT, zid, "St Helier", (13, 16))
    nurse(zid, ["Bouônjour, my dear. That's good day in Jèrriais, and I've about all of it left. Welcome to St Helier Sanctuary. Pop your team on the counter.",
                "Sit yourself down. There's tea and a Jersey wonder, which is a doughnut that's lost its middle and found a better one.",
                "There we are. Right as rain, and rain's what we get most days.",
                "The Ark's in the corner. It came over on the ferry and spent three days saying it felt a bit green.",
                "Mèrcie. That's thank you. Say it to the next person you meet and you'll make their day."])
    shopkeeper(zid, "Bouônjour! Tea, snares, and the first Jersey Royals of the season, if you're early enough. Local butter, local milk. The cows are very smug about it.",
               "Mèrcie, and mind the causeway.")
    room(z, "st_helier_church", 18, 11, 9, 5, "chapel", "Parish Church of St Helier", 4, "church",
         [("sth_verger", "villager_3", 6, 2, "down", "Verger",
           ["There's been a church here for about a thousand years, and some of the stones are older than the building. The church is called the Town Church, as if there were competition.",
            "Jersey has twelve parishes, each with its own church, its own elected Connétable and its own Honorary Police. They take it very seriously and always have."])])
    room(z, "st_helier_court", 35, 12, 8, 4, "georgian_brick", "The Royal Court", 4, "hall",
         [("sth_clerk", "poet", 4, 4, "right", "Court Clerk",
           ["Jersey law is a mix of old Norman custom and its own statutes. The Bailiff presides, and twelve elected Jurats sit beside the judge. It's not like anywhere else in the British Isles.",
            "Here's my favourite. If someone wrongs you, you can kneel and cry 'Haro! Haro! Haro! À l'aide, mon Prince, on me fait tort!' That's 'Help, my Prince, I am being wronged!' It's the Clameur de Haro. It stops them in their tracks until the court has heard the case."])])
    room(z, "st_helier_pub", 46, 12, 8, 4, "jersey_granite", "The Crapaud Arms", 4, "cafe",
         [("sth_landlord", "shopkeeper", 3, 1, "down", "Landlord",
           ["Welcome to the Crapaud Arms. Toads: Jerseymen. We took the name and put it on the sign, which is the right way to deal with an insult.",
            "We do a bean crock on Saturdays. It's a stew of beans, pork and a pig's trotter that cooks slowly for hours. It was taken to the baker's oven on a Saturday night and fetched after church on Sunday."]),
          ("sth_quiz", "fiddler", 7, 4, "left", "Quizmaster", None)], rw=11, rh=9)
    pubquiz("st_helier_pub", "sth_quiz", "st_helier", "Tonight's warm-up: what does a Jerseyman get called, and why? A crapaud, a toad. Nobody knows why. That's an easy point.")
    room(z, "st_helier_market", 4, 18, 10, 4, "market_hall", "Central Market", 5, "hall",
         [("sth_royal_stall", "shopkeeper", 4, 4, "right", "Potato Stall", None),
          ("sth_fishhall", "fisherman_north", 9, 4, "left", "Fish Hall",
           ["Spider crabs, lobsters, mussels, and a conger that's been eyeing me up since Tuesday. The Fish Hall's at this end, the flowers and potatoes are at the other.",
            "Jersey gets some of the biggest tides in Europe. When the sea goes out you can walk a mile on the sand, and I can pick up dinner for a quid."])])
    room(z, "st_helier_museum", 16, 18, 9, 4, "jersey_granite", "Jersey Museum", 4, "museum",
         [("sth_museum_guide", "tour_guide", 9, 4, "left", "Museum Guide",
           ["The Jersey Museum tells the island's story, from the Neolithic builders of La Hougue Bie to the Normans, the cod trade, the Occupation and the cows. It's in a handsome old merchant house on the harbour.",
            "There's a Lillie Langtry gallery. She's Jersey's most famous daughter, and the museum has her dresses, her jewellery and a very good portrait of the lily itself."]),
          ("sth_jerriais", "poet", 3, 4, "right", "Jèrriais Teacher",
           ["Jèrriais is a language, not a dialect. It's a Norman French cousin of the French of Normandy, with its own words, like 'vraic' for seaweed and 'tchian' for dog. Say 'Bouônjour' to start.",
            "'Mèrcie bein des fais', thank you very much. It's a wonder anyone ever manages to say it with a straight face. Most speakers are elderly, but classes are growing. It's our own tongue, and we'd like to keep it."])])
    room(z, "st_helier_maritime", 36, 18, 9, 4, "waterfront_museum", "Maritime Museum", 4, "museum",
         [("sth_tapestry", "tour_guide", 9, 4, "left", "Tapestry Guide", None),
          ("sth_shipwright", "shipwright", 3, 4, "right", "Shipwright",
           ["Jersey was a great shipbuilding island in the nineteenth century, with yards all round the coast. Hundreds of ships were launched, many of them fast schooners that carried the island's apples and cod across the Atlantic.",
            "The tide still sets the rhythm of the harbour, as it always has. Ships here have been waiting on it for centuries."])], rw=15, rh=10)
    room(z, "st_helier_crab", 26, 30, 7, 4, "harbour_row", "The Crab Shack", 3, "cafe",
         [("sth_crab_cook", "shopkeeper", 3, 1, "down", "Crab Cook",
           ["Jersey crab, picked this morning, with a squeeze of lemon and a slice of brown bread. We've a Jersey royals and butter on the side, if the season's right.",
            "Don't let the crab pinch you. It can't help it. Neither can the spider crab, which looks like a Halloween decoration."])], rw=11, rh=9)
    # the castle on the islet: a walk-in castle with a guide
    room_castle = landmark(OUT, "st_helier_castle", "Elizabeth Castle", zid, (13, 48), "castle",
                           [dict(id="sth_castle_guide", sprite="ravenmaster", x=9, y=3, facing="left", move="still", script="sth_castle_guide", name="Castle Guide")], w=15, h=10)
    script("st_helier_castle", "sth_castle_guide", s("Castle Guide",
        "Welcome to Elizabeth Castle. Sir Walter Raleigh was Governor when it was new, and named it after the queen. He'd have called it Fort Isabella Bellissima; the guidebook says it was 'in her honour', which is kind of him.",
        "Charles II stayed here as a prince, twice, in the Civil War. The island stayed loyal to the king longer than most of England. Then the Germans put guns here too. It's seen everyone, and the tide still shuts the door twice a day."))
    # Quest NPCs (St Helier part): the Maritime Museum's Tapestry Guide and the market's Potato Stall (ci_story.py)


def jersey_country():
    W, H = 64, 56
    zid = "jersey_country"
    z = Z(zid, "Jersey Countryside", W, H, kind="route", region=REG, music="route_coast",
          weather={"drizzle": 22, "clear": 28, "sunshine": 24, "fog": 10, "gale": 8, "downpour": 8})
    z.d["stage"] = "coast"; z.d["scaled_floor"] = FLOOR
    z.legend["p"] = {"tile": "grass", "colour": "#5f8f3a"}
    z.legend["q"] = {"tile": "grass", "colour": "#7ba548"}
    z.legend["g"] = {"tile": "grass", "colour": "#6f9447"}
    z.rect(0, 0, W, H, ".")
    z.border("T", 2, gaps=[(30, 54, 3, 2)])
    z.scatter(0, 0, W, H, "P", 8, 61, only="T")
    # north coast: cliff path and sea, with Bouley Bay a notch in it
    z.rect(0, 0, W, 4, "$"); z.rect(0, 4, W, 1, "w"); z.rect(0, 5, W, 2, "s")
    z.rect(12, 7, 14, 2, "s"); z.rect(14, 4, 10, 1, "w")
    # east coast: the Royal Bay of Grouville, sand and shallows and sea
    z.rect(59, 0, 5, H, "$"); z.rect(58, 5, 1, 50, "w"); z.rect(55, 7, 3, 47, "s")
    # lanes
    path(z, [(30, 54), (30, 7)], "#", 3)
    path(z, [(8, 24), (30, 24)], "#", 2)
    path(z, [(30, 36), (55, 36)], "#", 2)
    path(z, [(30, 12), (50, 12)], "#", 2)
    path(z, [(6, 7), (55, 7)], "#", 1)
    # the potato fields: stripes on the south-west slopes
    for y in range(38, 52):
        z.rect(5, y, 21, 1, "p" if y % 2 == 0 else "q")
    # Jersey War Tunnels
    z.building(8, 19, 10, 4, "stone", "Jersey War Tunnels", door=5)
    z.warp(13, 22, "jersey_tunnels", 7, 7, "up")
    z.rect(8, 23, 10, 1, "#")
    plaque(z, 19, 23, "tunnels", "The War Tunnels",
           "Begun in 1941 as an artillery barracks and workshop, a maze of tunnels dug into the hill at St Lawrence by forced labourers brought from across occupied Europe, many of them starved and badly treated. Late in the war the tunnels became an emergency hospital. Today they are a museum of the Occupation, and a memorial to the workers who died.")
    # La Hougue Bie
    z.building(36, 25, 9, 5, "passage_tomb", "La Hougue Bie", door=4)
    z.warp(40, 29, "jersey_hougue", 6, 7, "up")
    z.rect(36, 30, 9, 1, "#")
    plaque(z, 35, 30, "hougue", "La Hougue Bie",
           "A great Neolithic passage tomb under a grassy mound, built about 6,000 years ago, among the largest in Europe. At the spring and autumn equinox the sunrise lights the passage right to the back. A medieval chapel stands on top, and the Germans built a bunker beside it.")
    # Mont Orgueil above Gorey harbour
    z.building(46, 40, 11, 7, "castle", "Mont Orgueil Castle", door=5)
    z.warp(51, 46, "jersey_orgueil", 7, 7, "up")
    z.rect(46, 47, 12, 1, "#")
    plaque(z, 45, 47, "orgueil", "Mont Orgueil",
           "Built after 1204, when King John lost Normandy and the Channel Islands became England's front line, to guard Gorey harbour and the French coast just fifteen miles away. Mont Orgueil means Mount Pride. It stood for four centuries until cannon made it out of date, and Elizabeth Castle replaced it.")
    z.building(46, 30, 9, 4, "harbour_row", show_label=False)
    # Durrell Wildlife Park
    z.building(44, 9, 10, 4, "stone", "Durrell Wildlife Park", door=5)
    z.warp(49, 12, "jersey_durrell", 7, 7, "up")
    z.rect(44, 13, 10, 1, "#")
    z.prop("statue", 54, 14, variant=3)
    plaque(z, 53, 14, "durrell", "Durrell Wildlife Park",
           "Gerald Durrell, the writer of My Family and Other Animals, founded the zoo at Les Augrès Manor in 1959 to breed endangered species and save them from extinction. The Durrell Trust's logo is a dodo, as a reminder of what happens when nobody tries. It has helped save the pink pigeon, the mountain chicken frog and golden lion tamarins.")
    # Jersey farm and the cows
    z.building(9, 28, 9, 4, "jersey_granite", "Le Brocq's Farm", door=4)
    z.warp(13, 31, "jersey_farm", 5, 6, "up")
    z.building(20, 28, 6, 3, "field_barn", show_label=False)
    z.rect(9, 32, 10, 1, "#")
    plaque(z, 7, 33, "cow", "The Jersey Cow",
           "Small, fawn-coloured, with huge dark eyes, and a milk so rich in cream it makes the best butter in the world. The island has kept the breed pure for more than two centuries: bringing in cattle of any other kind has been banned since 1789.")
    # a martello-style round tower on the shore
    z.building(52, 20, 3, 3, "jersey_tower", show_label=False)
    plaque(z, 51, 23, "towers", "The Round Towers",
           "Jersey is ringed with granite round towers, built from the 1780s to guard against the French. Some stand on the shore, some on the tidal flats, and at low water you can walk to Seymour Tower across a mile of sand, if you check the tide first.")
    # potato plaque
    plaque(z, 27, 43, "royals", "Jersey Royals",
           "The island's first potatoes of the season, grown in steep, south-facing fields and picked by hand from April, long before anywhere else. The seaweed called vraic is traditionally spread on the fields as fertiliser. The Jersey Royal has protected status, like champagne or Stilton.")
    plaque(z, 17, 8, "bouley", "Bouley Bay",
           "A steep bay on the north coast, where old Jersey stories put a ghostly black dog that walks the cliff path after dark. In Jèrriais, tchian means dog. The hillclimb road above the bay is also used for motor racing, which is quite loud for a ghost to compete with.")
    plaque(z, 56, 14, "grouville", "Royal Bay of Grouville",
           "The long sweep of sand on the east coast, where the tide goes out a mile or more on the biggest days. The shore is also home to oyster beds. Oysters have been farmed in Gorey since the nineteenth century, and Jersey ones are sold fresh on the harbour.")
    plaque(z, 38, 36, "jersey_lanes", "Green Lanes",
           "Jersey has a network of narrow green lanes, signed with a speed limit of 15 miles an hour, where walkers, cyclists and horses have priority over cars. The lanes were traced by farmers' carts and hardly any have a straight line.")
    # the Black Dog of Bouley Bay (a legend encounter) on the cliff path
    _stand(z, 20, 7)
    z.npc(id="jer_tchian", sprite="creature:tchian", x=20, y=7, facing="down", move="still", script="tchian_spot", hide_if="caught_tchian")
    # cows in the fields
    for (x, y) in [(23, 33), (26, 34), (28, 28)]:
        z.npc(id="jer_cow_%d" % x, sprite="creature:moolet", x=x, y=y, facing="down", move="wander", script="jer_cow")
    script(zid, "jer_cow", say("Jersey Cow", "Moo. It's a Jersey moo, a creamy, deeply contented moo. It looks at you with enormous eyes and does not appear to see why you've interrupted dinner."))
    # people
    chat(z, "jer_farmer_old", "farmer", 16, 35, "Old Farmer",
         ["Bouônjour. That's good day. We've farmed this land since before the Normans. Our fields are small, because we split them between all the sons for hundreds of years. Hence a lot of small fields and a lot of old arguments.",
          "My grandmother spoke nothing but Jèrriais. She'd say 'Mèrcie' when she meant thanks, and 'Tchian' if you meant the dog. I have a few words left myself."], "right")
    chat(z, "jer_guide", "tour_guide", 36, 31, "Hougue Guide",
         ["Six thousand years old, give or take, and it was a tomb. Imagine moving those stones, and with no cranes. They hauled granite on log rollers.",
          "On the equinox, the rising sun shines down the passage to the chamber at the end. Stone Age people understood the sky better than we do. Our satnavs would've been very confused."], "left")
    chat(z, "jer_keeper", "explorer", 52, 15, "Zoo Keeper",
         ["Durrell's the world's first zoo built just to save species. He was a naturalist, and he wrote very funny books about his childhood in Corfu and chasing animals. I read them all before I was twelve.",
          "The dodo on the logo reminds us what's lost for ever, and what we can still save. It's a big, silly, wonderful bird, and it turned out not to be so silly after all."], "left")
    # trainers
    trainer(z, "jer_dairyman", "Dairyman Le Quesne", "Dairy Farmer", "farmer",
            [("moolet", 40), ("herdlet", 41), ("fawnlet", 41)], 20, 34, "right",
            ["My Jersey cows give the richest milk you'll ever taste. And the nastiest looks, when they decide you're in the wrong field."],
            "Fair. You can have a pint of cream for that.", "A Jersey will give about a hundred pints of milk a day, and the cream rises on it so thick you could stand a spoon in it.", 800)
    trainer(z, "jer_surfer", "Surfer Ellie", "Surfer", "surfer",
            [("dolphlet", 40), ("gannetling", 41), ("selklet", 41)], 55, 18, "left",
            ["St Ouen's Bay on the west has proper Atlantic swell. I'm over here because it's flat today. It's flat everywhere today. I'm devastated."],
            "Wipeout. Mine, not yours.", "Surf, sand yachts, kite-buggies and sea-kayaks, the island does it all. We can do a day at the beach in any weather, and we do.", 740)
    trainer(z, "jer_keeper_t", "Keeper Aimee", "Zookeeper", "explorer",
            [("glisglis", 41), ("ratty", 41), ("tunneller", 42)], 46, 14, "up",
            ["I look after animals all day and one of them has bitten me twice this week. It wasn't even a tiger. You're next."],
            "Hmph. You're a natural handler. Have you thought about the job?", "We have a breeding programme for dozens of rare species. Some can only live in places where the rainforest is half gone. We do what we can.", 800)
    trainer(z, "jer_walker", "Walker Dennis", "Cliff Walker", "hillwalker",
            [("duneskink", 41), ("petrelash", 41), ("kitelet", 41)], 24, 8, "down",
            ["The cliff path goes all round the north coast. Best views in the Channel, and the worst bit is the stairs. A great many of them, and my knees have counted."],
            "Aye, you've beaten the cliffs and me. I'll sit down.", "Keep to the path after dark. There's a story about a black dog on this stretch. I don't believe it. I've just never been out here at night to check.", 740)
    trainer(z, "jer_legend", "Old Josué Le Brocq", "Local Legend", "farmer",
            [("moolet", 44), ("beancrock", 44), ("vraicling", 44), ("herdwick", 45), ("dextera", 44), ("crockling", 43)], 13, 34, "down",
            ["Bouônjour. Seventy years I've farmed these steep fields. I won the Battle of Flowers with a float made entirely of hydrangeas. I once told the Bailiff he was in the wrong field, and he agreed."],
            "Well. The old man's been put in his place. Mèrcie bein des fais, my friend. That's thanks, and it's meant.", "Come back in April and I'll give you the first Royals of the year. Boiled, with butter, nothing else. A man could cry.", 3800)
    scale(["jer_dairyman", "jer_surfer", "jer_keeper_t", "jer_walker"])
    scale(["jer_legend"], FLOOR)
    z.d["props"] = [p for p in z.d["props"] if p]
    wild(z, [("moolet", 40, 42, 14, {}), ("herdlet", 40, 41, 10, {}), ("fawnlet", 40, 42, 8, {"time": ["dawn", "dusk"]}),
             ("tchian", 41, 42, 1, {"time": ["night"], "weather": ["fog"]}),
             ("kitelet", 40, 41, 8, {"time": ["day"]}), ("leveret", 40, 41, 8, {"time": ["dawn", "dusk"]}),
             ("dozelet", 40, 41, 8, {}), ("starlet", 40, 41, 8, {}), ("martling", 41, 42, 6, {"time": ["dusk", "night"]}),
             ("hootlet", 41, 42, 6, {"time": ["night"]}), ("brockling", 40, 42, 8, {"time": ["dawn", "dusk", "night"]}),
             ("crockling", 40, 41, 5, {}), ("beancrock", 41, 42, 2, {"time": ["night"]})])
    wild(z, [("pinchkin", 40, 41, 16, {}), ("puffling", 40, 41, 12, {"season": ["spring", "summer"]}), ("vraicling", 41, 43, 10, {}),
             ("pupplash", 40, 42, 10, {}), ("gannetling", 40, 42, 8, {}), ("baskling", 40, 42, 8, {})], "water")
    blob(z, 24, 12, 7, 3, ",", only=".", seed=62, jitter=0.3)
    blob(z, 14, 30, 4, 3, ",", only=".", seed=63, jitter=0.3)
    blob(z, 40, 20, 6, 3, ",", only=".", seed=64, jitter=0.3)
    blob(z, 38, 46, 5, 3, ",", only=".", seed=65, jitter=0.3)
    blob(z, 7, 15, 4, 3, ",", only=".", seed=66, jitter=0.3)
    scatter_props(z, "oak", 3, 10, 24, 10, 6, 67, avoid=("."))
    scatter_props(z, "oak", 33, 38, 20, 14, 5, 68, avoid=("."))
    for (x, y) in [(29, 40), (29, 28), (33, 8), (47, 35)]:
        z.prop("lamp_post", x, y)
    fingerpost(z, 29, 52, "SOUTH: St Helier. EAST at the crossroads: Gorey and Mont Orgueil. NORTH: Durrell, and the cliff path along the north coast.")
    fingerpost(z, 29, 24, "WEST: the Jersey War Tunnels at St Lawrence. EAST: La Hougue Bie, the great mound.")
    z.d["edges"] = {"south": {"to": "st_helier", "offset": 0}}
    z.d["spawn"] = [31, 52]
    seal(z, [(30, 54, 3, 2)])
    done(z)
    z.save(OUT + "/" + zid + ".json")

    landmark(OUT, "jersey_tunnels", "Jersey War Tunnels", zid, (13, 23), "museum",
             [dict(id="jer_tunnel_guide", sprite="tour_guide", x=9, y=4, facing="left", move="still", script="jer_tunnel_guide", name="Tunnels Guide"),
              dict(id="jer_tunnel_keeper", sprite="poet", x=3, y=4, facing="right", move="still", script="jer_tunnel_keeper", name="Archivist")], w=15, h=10)
    landmark(OUT, "jersey_hougue", "La Hougue Bie", zid, (40, 30), "castle",
             [dict(id="jer_hougue_curator", sprite="druid", x=9, y=3, facing="left", move="still", script="jer_hougue_curator", name="Curator")])
    landmark(OUT, "jersey_orgueil", "Mont Orgueil Castle", zid, (51, 47), "castle",
             [dict(id="jer_orgueil_warder", sprite="ravenmaster", x=9, y=3, facing="left", move="still", script="jer_orgueil_warder", name="Castle Warder")], w=15, h=10)
    landmark(OUT, "jersey_durrell", "Durrell Wildlife Park", zid, (49, 13), "museum",
             [dict(id="jer_durrell_curator", sprite="tour_guide", x=9, y=4, facing="left", move="still", script="jer_durrell_curator", name="Visitor Centre")], w=15, h=10)
    landmark(OUT, "jersey_farm", "Le Brocq's Farm", zid, (13, 32), "cottage",
             [dict(id="jer_farmwife", sprite="villager_3", x=8, y=3, facing="left", move="still", script="jer_farmwife", name="Farmer's Wife")], w=11, h=9)
    script("jersey_tunnels", "jer_tunnel_guide", s("Tunnels Guide",
        "These tunnels were dug by the Germans from 1941 into the hill at St Lawrence. The work was done by forced labourers brought from across Europe, among them Russians, Poles, Spaniards and North Africans. Many were underfed, overworked and cruelly treated, and some died here.",
        "The tunnels were meant to shelter troops and guns. At the end of the war they were an emergency hospital. Some of what's on show was left lying where it fell. Please walk quietly. It's a place to learn, not a place to be loud."))
    script("jersey_tunnels", "jer_tunnel_keeper", s("Archivist",
        "Jersey was occupied for five years, from 1 July 1940. Islanders were short of food and fuel by the end. In December 1944 the Red Cross ship Vega brought parcels, and everyone remembers what was in them.",
        "Wireless sets were confiscated in 1942. Many were hidden, and people listened in secret to the BBC. Every little wireless set under the floorboards was a small act of faith in the news. Liberation Day was 9 May 1945. We keep it as a public holiday still."))
    script("jersey_hougue", "jer_hougue_curator", s("Curator",
        "La Hougue Bie is a passage tomb, built about 3500 BC. It's a long passage, and at the equinox the sun's first beams reach right to the back. Inside, you crouch, and you can imagine them gathering to honour their dead.",
        "A medieval chapel and then a Jersey legend were added on top. And a German bunker, because every hill had one in the war. The Occupation Museum shares the site. Thousands of years in one little mound."))
    script("jersey_orgueil", "jer_orgueil_warder", s("Castle Warder",
        "Mont Orgueil, Mount Pride. It's got everything: towers, tunnels, a great hall, and a view over Gorey and out to France. On a clear day you can see Normandy. The Normans can see us. Nobody's said hello yet.",
        "The castle was the main fortress of the island until the cannon age. William Prynne, a Puritan writer who annoyed Charles I, was locked up here in the 1630s. He wrote a book. Hence we have a very good example of a prison with a view."))
    script("jersey_durrell", "jer_durrell_curator", s("Visitor Centre",
        "Welcome to Durrell. Gerald Durrell started the zoo here in 1959 and set up the Trust to save species from extinction. He wrote lots of books, and funded the zoo with them. Every animal here is part of a breeding programme.",
        "The dodo on our logo is for the bird that nobody saved. Our job is to make sure the next one gets a better deal. We've pulled species back from the brink: the pink pigeon, the Mauritius kestrel, the Montserrat mountain chicken frog."))
    script("jersey_farm", "jer_farmwife", s("Farmer's Wife",
        "I've a bean crock in the oven since last night. Beans, a bit of pork, the trotter, and onions. You put it in with the bread and forget about it. It's the best Sunday dinner there is.",
        "Jersey Royals, black butter, bean crock and ormers. That's an island dinner. Just don't ask what's in the black butter. It's apples, cider and spice, stirred for days, and it tastes like Christmas."))
