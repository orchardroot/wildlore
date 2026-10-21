# Guernsey: St Peter Port (the harbour town with Castle Cornet and Hauteville House) and the island's west (the Little
# Chapel, Fort Grey, the German Occupation Museum, Cobo Bay), and a nod to Sark and Alderney.
from ci_common import *
from wcommon import _stand


def build():
    st_peter_port()
    guernsey_country()
    sark()


def st_peter_port():
    W, H = 64, 52
    zid = "st_peter_port"
    z = Z(zid, "St Peter Port", W, H, kind="town", region=REG, music="town_york",
          weather={"drizzle": 22, "clear": 30, "sunshine": 24, "fog": 8, "gale": 8, "downpour": 8})
    z.d["stage"] = "docks"; z.d["town_id"] = zid; z.d["scaled_floor"] = FLOOR
    z.rect(0, 0, W, H, ".")
    z.border("T", 2, gaps=[(0, 24, 2, 3)])
    z.scatter(0, 0, W, H, "P", 8, 7, only="T")
    # the harbour to the east: shallows, then open water
    z.rect(46, 0, 18, H, "$"); z.rect(45, 0, 1, H, "w")
    # the Esplanade down the waterfront, the streets above it
    z.rect(40, 3, 5, 44, ":")
    z.rect(0, 24, 5, 3, "="); z.rect(5, 20, 35, 7, ":")
    z.rect(5, 14, 35, 2, ":"); z.rect(5, 33, 35, 3, ":")
    z.rect(22, 8, 2, 38, ":"); z.rect(8, 8, 2, 38, ":")
    # Castle Cornet on its islet, joined to the Esplanade by the breakwater
    z.rect(50, 16, 12, 14, "s"); z.rect(51, 17, 10, 12, "."); z.rect(45, 24, 5, 3, ":")
    z.building(52, 19, 8, 5, "castle", "Castle Cornet", door=3)
    z.warp(55, 23, "st_peter_port_cornet", 7, 7, "up")
    # the ferry pier
    z.rect(45, 38, 10, 4, ":")
    z.d["ferry"] = {"x": 54, "y": 39, "route": "st_peter_port_sark"}
    z.prop("bollard", 47, 38); z.prop("bollard", 47, 41)
    # row N, facing the upper street
    z.building(10, 9, 6, 4, "sanctuary", "Sanctuary", door=3); z.warp(13, 12, "st_peter_port_sanctuary", 5, 6, "up")
    z.building(16, 9, 5, 4, "shop", "Corner Shop", door=2); z.warp(18, 12, "st_peter_port_shop", 4, 5, "up")
    z.building(24, 8, 7, 5, "white_render", "Hauteville House", door=3); z.warp(27, 12, "st_peter_port_hauteville", 6, 7, "up")
    z.building(33, 9, 6, 4, "guernsey_granite", "Guernsey Museum", door=3); z.warp(36, 12, "st_peter_port_museum", 6, 7, "up")
    z.building(3, 9, 5, 4, "guernsey_granite", show_label=False)
    # row M, facing the market square
    z.building(5, 16, 6, 4, "jersey_granite", "The Gâche and Donkey", door=3); z.warp(8, 19, "st_peter_port_pub", 5, 6, "up")
    z.building(12, 16, 10, 4, "market_hall", "The Market Halls", door=5); z.warp(17, 19, "st_peter_port_market", 6, 7, "up")
    z.building(25, 15, 8, 5, "chapel", "Town Church", door=4); z.warp(29, 19, "st_peter_port_church", 6, 7, "up")
    z.building(34, 16, 5, 4, "guernsey_granite", show_label=False)
    # row S, facing the lower street
    z.building(5, 29, 8, 4, "white_render", "Gâche Bakery", door=4); z.warp(9, 32, "st_peter_port_bakery", 5, 6, "up")
    z.building(14, 29, 6, 4, "guernsey_granite", show_label=False)
    z.building(26, 29, 8, 4, "harbour_row", "The Fish Quay Café", door=4); z.warp(30, 32, "st_peter_port_cafe", 5, 6, "up")
    z.building(35, 29, 4, 4, "guernsey_granite", show_label=False)
    z.building(5, 38, 9, 4, "guernsey_granite", show_label=False)
    z.building(24, 38, 8, 4, "guernsey_granite", show_label=False)
    z.rect(5, 37, 35, 1, ":")
    for (x, y) in [(10, 47), (28, 47), (14, 44), (36, 46)]:
        z.prop("oak", x, y, variant=(x + y) % 3)
    for (x, y) in [(52, 34), (56, 36), (50, 45), (58, 44), (54, 8), (58, 10)]:
        z.prop("boat", x, y, variant=(x + y) % 3)
    for (x, y) in [(48, 33), (56, 30), (52, 12)]:
        z.prop("buoy", x, y)
    for (x, y) in [(41, 10), (41, 18), (41, 30), (41, 44), (21, 22), (4, 25), (31, 22), (14, 23)]:
        z.prop("lamp_post", x, y)
    for (x, y) in [(43, 20), (43, 28), (43, 35)]:
        z.prop("bench", x, y)
    for x in (44,):
        for y in (6, 16, 32, 42):
            z.prop("bollard", x, y)
    z.prop("hanging_basket", 19, 22, walk=True, rot=0); z.prop("hanging_basket", 33, 22, walk=True, rot=0)
    z.prop("bunting", 22, 21, variant=1, walk=True); z.prop("bunting", 22, 34, variant=4, walk=True)
    z.prop("flagpole", 38, 23, variant=6); z.prop("post_box", 4, 22); z.prop("phone_box", 6, 22)
    # greenery up the hill: gardens and tall grass
    blob(z, 12, 5, 8, 2, ",", only=".", seed=71, jitter=0.3)
    blob(z, 30, 5, 4, 1, ",", only=".", seed=72, jitter=0.3)
    blob(z, 12, 46, 10, 2, ",", only=".", seed=73, jitter=0.3)
    scatter_props(z, "oak", 3, 3, 30, 4, 6, 74, avoid=("."))
    fingerpost(z, 4, 23, "WEST: the rest of Guernsey. The Little Chapel, Fort Grey, the Occupation Museum and the bays on the west coast.")
    fingerpost(z, 44, 36, "HARBOUR. Ferries from the pier: SARK and the other islands. And back to Jersey and Poole when you've seen enough.")
    # plaques
    plaque(z, 41, 24, "spp_harbour", "St Peter Port",
           "The capital of Guernsey, built up a steep hillside from a harbour sheltered by Castle Cornet. The tall granite houses and narrow cobbled streets are why a Guernseyman is nicknamed a donkey, some say. A very pretty town to arrive in, by sea.")
    plaque(z, 49, 28, "cornet", "Castle Cornet",
           "Begun in the thirteenth century on a rock at the harbour mouth, and joined to the shore today by a breakwater. In the Civil War the castle held out for the king against Parliament for eight years, till the end of 1651, among the longest sieges in British history. At noon each day the gunners fire the Noon Gun.")
    plaque(z, 25, 14, "hugo", "Victor Hugo in Exile",
           "The French writer Victor Hugo was banished from France after he opposed Napoleon III's seizure of power in 1851. He lived in exile in Jersey from 1852, then in Guernsey from 1855 until 1870. He called these islands 'pieces of France that fell into the sea and were picked up by England'.")
    plaque(z, 31, 14, "hauteville", "Hauteville House",
           "Hugo bought the house in 1856 with the money from his poems and designed the interior himself, from carved oak to blue porcelain. He wrote much of Les Misérables here, and Toilers of the Sea, set among Guernsey's fishermen. His family gave the house to the City of Paris in 1927, and it is now a museum.")
    plaque(z, 20, 22, "spp_market", "The Market Halls",
           "A covered market that has sold the island's produce for around two hundred years: Guernsey tomatoes, flowers, fish, local butter and golden-coloured cream. Locals queue at the dairy stall every Saturday. Bring a basket and a cheerful attitude.")
    plaque(z, 36, 22, "cows", "The Guernsey Cow",
           "Fawn and white, gentle and quick to make friends. Guernsey milk is a deep golden colour, because it is rich in carotene, the same pigment as in carrots. The island has kept its cattle pure for two centuries. Bringing in other cattle is banned.")
    plaque(z, 6, 21, "gache", "Gâche",
           "Gâche is the Guernsey word for a fruit loaf, a dense, buttery bread with raisins and peel, sliced thick and eaten with plenty of butter. Guernsey people make it for tea, for Christmas and for the beach. A related apple cake is called gâche mêlaïe.")
    plaque(z, 38, 34, "bean_jar", "The Guernsey Bean Jar",
           "A tall earthenware pot of haricot beans, pork and a pig's trotter, left to cook slowly for hours. It was a Sunday dish, put in the baker's oven on Saturday night and fetched home after church. Everybody's grandmother made the best one.")
    plaque(z, 41, 40, "spp_occupation", "The Occupation",
           "German forces occupied Guernsey from 30 June 1940 until 9 May 1945. Two days before, bombers hit St Peter Port harbour and killed 34 people. Thousands of children were evacuated to England, and many did not see their parents for five years. The people left behind endured shortages, curfews and deportations.")
    plaque(z, 31, 20, "church", "The Town Church",
           "The island's main parish church, with a spire that has guided sailors for centuries. Guernsey has ten parishes, each with its own church and its own Douzaine, a council of twelve elected parish officers. The Town Church has seen weddings, funerals and the Occupation, and it's still open.")
    plaque(z, 54, 31, "alderney", "A Nod to Alderney",
           "The third island of the Bailiwick lies north-east, a few miles off the French coast. Alderney has puffins on Burhou, a gannet colony on its offshore rocks and a little railway run by volunteers. Much of its population was evacuated in 1940. The island's cows, the original Alderneys, gave their name to a whole breed.")
    # people
    chat(z, "spp_donkey", "villager_2", 18, 24, "Local",
         ["Guernsey folk are called donkeys, ânes. Some say because the streets are steep, some say we're stubborn. I say it's both and it's a compliment.",
          "Jersey has the crapauds, the toads. Sark has the crows. Alderney has the rabbits. We've all got a name, and we've all pretended not to mind."], "right")
    chat(z, "spp_gache_lady", "villager_6", 8, 34, "Gâche Fan",
         ["Gâche. Not 'gash', not 'gosh', with a long a, as in 'gâch'. Fruit loaf with butter, made by the oven-load on Sunday and eaten by Wednesday.",
          "The Guernsey bean jar is a different thing entirely. Beans, pork, a trotter, hours in the baker's oven. If you can smell it at nine in the morning, someone's on the right track."], "up")
    chat(z, "spp_hugo_fan", "poet", 26, 14, "Hugo Admirer",
         ["Victor Hugo spent fifteen years here and wrote about Guernsey as if he owned it. Les Misérables came out in 1862, and he wrote much of it here. Toilers of the Sea followed in 1866, set round these very rocks.",
          "He gave a Christmas dinner every year for poor children, and he wrote standing up, at a desk in a glass room at the top of the house."], "down")
    z.npc(id="spp_sailor_sark", sprite="sailor", x=51, y=38, facing="right", move="still", script="spp_sailor_sark", name="Boatman")
    script(zid, "spp_sailor_sark", say("Boatman", "Sark? Pretty little island. No cars, no street lights, a very big sky. Hop aboard.") + [{"do": "ferry", "route": "st_peter_port_sark"}])
    z.npc(id="spp_sailor_poole", sprite="sailor", x=51, y=41, facing="right", move="still", script="spp_sailor_poole", name="Ferry Hand")
    script(zid, "spp_sailor_poole", say("Ferry Hand", "Back to Poole? The Bailiwick Belle leaves when the tide agrees. It's a good crossing, mostly. Hold your hat.") + [{"do": "ferry", "route": "poole_st_peter_port"}])
    z.npc(id="spp_sailor_jersey", sprite="sailor", x=51, y=40, facing="right", move="still", script="spp_sailor_jersey", name="Ferry Hand")
    script(zid, "spp_sailor_jersey", say("Ferry Hand", "St Helier? Jersey's just over the horizon, with the crapauds and the cows. They're good people, for a toad.") + [{"do": "ferry", "route": "st_helier_st_peter_port"}])
    # trainers
    trainer(z, "spp_fisher", "Fisherman Ozanne", "Fisherman", "fisherman_north",
            [("baskling", 40), ("selklet", 41), ("clownbill", 41)], 36, 38, "left",
            ["Ormers, lobsters, spider crab, bass. Take your pick, or take a battle. I have the day off and a very good net."],
            "Ah, you've hooked me. Have a mackerel.", "A good fisherman knows the tides, the rocks and the weather. I know two out of three. The weather doesn't count.", 780)
    trainer(z, "spp_douzaine", "Douzenier Le Page", "Parish Officer", "commuter",
            [("rivetling", 40), ("cooplet", 41), ("dextera", 41)], 22, 32, "right",
            ["I'm a douzenier, a member of the parish Douzaine, twelve of us, elected. We set the parish rates, and we'll thank you to stay off the verge."],
            "I'll note it in the minutes. Fair and square.", "The States of Guernsey run the island, but each parish still has its twelve. A very old system, and very good at making tea last through a meeting.", 880)
    trainer(z, "spp_herdsman", "Herdsman Falla", "Cattleman", "farmer",
            [("moolet", 40), ("herdlet", 41), ("brockling", 41)], 9, 25, "right",
            ["Golden Guernsey milk, from the cows I talk to every morning. They never talk back, which is why I like them."],
            "Oh well. The cows won't be pleased with me, but there it is.", "My great-grandfather kept Guernseys on this headland. We've never let any other cow through the gate, and we've been pestered about it.", 800)
    trainer(z, "spp_tomato", "Grower Bisson", "Glasshouse Grower", "jam_maker",
            [("pepperling", 40), ("thistlet", 41), ("gentlet", 41)], 33, 25, "left",
            ["Tomatoes, grapes, freesias. Guernsey was famous for what it grew under glass. A glasshouse in every field. Mine has a tractor in it now."],
            "Bruised, but not squashed.", "In the middle of the twentieth century Guernsey shipped tomatoes by the shipload. Then the cheap ones came from abroad. The glasshouses are quieter now.", 740)
    scale(["spp_fisher", "spp_douzaine", "spp_herdsman", "spp_tomato"])
    wild(z, [("chipgull", 40, 42, 14, {}), ("ternlet", 40, 41, 12, {}), ("starlet", 40, 41, 8, {"time": ["dawn", "day", "dusk"]}),
             ("moolet", 40, 42, 10, {}), ("herdlet", 40, 41, 8, {}), ("pinchkin", 40, 41, 10, {}),
             ("crockling", 40, 41, 6, {}), ("beancrock", 41, 42, 3, {"time": ["dusk", "night"]}),
             ("hootlet", 41, 42, 6, {"time": ["night"]}), ("binfox", 41, 42, 6, {"time": ["dusk", "night"]})])
    wild(z, [("pinchkin", 40, 41, 16, {}), ("baskling", 40, 42, 12, {}), ("selklet", 40, 42, 10, {}), ("dolphlet", 40, 42, 10, {}),
             ("puffling", 40, 41, 10, {"season": ["spring", "summer"]}), ("pupplash", 40, 42, 10, {}),
             ("vraicling", 41, 43, 6, {"weather": ["gale", "downpour", "drizzle"]})], "water")
    z.d["edges"] = {"west": {"to": "guernsey_country", "offset": 0}}
    z.d["spawn"] = [6, 25]
    seal(z, [(0, 24, 2, 3)])
    done(z)
    z.save(OUT + "/" + zid + ".json")

    sanctuary(OUT, zid, "St Peter Port", (13, 13))
    shop(OUT, zid, "St Peter Port", (18, 13))
    nurse(zid, ["Hello, my lover. That's how we say it in Guernsey, and it means nothing you'd blush at. Welcome to St Peter Port Sanctuary. Pop your team on the counter.",
                "Take a seat. There's tea and a slice of gâche, which is a fruit loaf, and there's butter and plenty of it.",
                "All done. Fitter than a Guernsey cow in clover, and that's saying something.",
                "The Ark's by the stairs. It's been up and down them so many times it says it's got donkey's legs.",
                "Right you are. Mind the steep steps on the way out, and the donkeys, they're proud."])
    shopkeeper(zid, "Hello! Tea, snares, and a good slab of gâche for the road. We've golden Guernsey milk, and a Guernsey gansey in the window if you're feeling the chill.",
               "Cheers, my lover. Come again, and bring a friend, or a cow.")
    room(z, "st_peter_port_hauteville", 24, 8, 7, 5, "white_render", "Hauteville House", 3, "home",
         [("spp_hugo_guide", "tour_guide", 8, 3, "left", "House Guide",
           ["Victor Hugo bought this house in 1856 and decorated every inch of it, with carved oak, old tiles, tapestries and furniture he had designed himself. The Hauteville House of today is a work of art made by a writer.",
            "At the top is the Look-Out, a glass room with a view over the harbour all the way to France. Hugo wrote standing up at a desk there, and gazed out across the sea to the country that had exiled him."]),
          ("spp_hugo_study", "poet", 4, 5, "right", "Hugo Scholar",
           ["Much of Les Misérables was written here, and it was published in 1862 while he still lived on Guernsey. He wrote Toilers of the Sea here, too. It features an octopus, which gave the French a whole new nightmare.",
            "Hugo's exile ended in 1870 when Napoleon III fell, and he went home to Paris a hero. He came back to Guernsey for a time, too. He loved these islands."])])
    room(z, "st_peter_port_museum", 33, 9, 6, 4, "guernsey_granite", "Guernsey Museum", 3, "museum",
         [("spp_museum_guide", "tour_guide", 9, 4, "left", "Museum Guide",
           ["The Guernsey Museum at Candie Gardens covers the island's history, from the Neolithic menhirs to the Occupation and the tomato boom. It's in a leafy park, Candie Gardens, with a statue of Victor Hugo in the garden.",
            "The island is called Guernsey, with the Norse ending 'ey' for island. The Vikings left a lot of names around the Channel Islands, then the Normans took them over."])])
    room(z, "st_peter_port_market", 12, 16, 10, 4, "market_hall", "The Market Halls", 5, "hall",
         [("spp_market_dairy", "shopkeeper", 4, 4, "right", "Dairy Stall",
           ["Guernsey butter, Guernsey cream, Guernsey cheese. The cows make the milk golden and the butter golden and, if I'm honest, the prices a bit golden.",
            "A Guernsey cow is a gentle, nosy girl who likes company. The island is small, and so is the herd. You'll hardly find a cow without a name."]),
          ("spp_market_grower", "farmer", 9, 4, "left", "Grower",
           ["Tomatoes, grapes, freesias and, if I tell the truth, a bit of everything. Guernsey was shipping thousands of tons of tomatoes by the middle of the last century.",
            "Now we grow flowers and eat the tomatoes ourselves. They taste better than the bought ones. It's the glass, and the Guernsey sun, and the bad language."])])
    room(z, "st_peter_port_church", 25, 15, 8, 5, "chapel", "Town Church", 4, "church",
         [("spp_verger", "villager_3", 6, 2, "down", "Verger",
           ["The Town Church of St Peter Port is the largest of Guernsey's ten parish churches. It has a spire, a peal of bells and a reputation for being the first thing sailors see on the way in.",
            "Each parish is run by its Douzaine, twelve elected officers. We've had that system since the Middle Ages, and nobody's thought of a better way to run a parish."])])
    room(z, "st_peter_port_pub", 5, 16, 6, 4, "jersey_granite", "The Gâche and Donkey", 3, "cafe",
         [("spp_landlord", "shopkeeper", 3, 1, "down", "Landlord",
           ["The Gâche and Donkey. Our sign has both. The gâche is a fruit loaf, and the donkey is you. Come in, sit down, and take your boots off if the steps were too much.",
            "We do a bean jar on the weekend. It's a slow-cooked stew of beans, pork and a trotter. The recipe's older than the pub, and the pub's been here since before Hugo."]),
          ("spp_quiz", "fiddler", 7, 4, "left", "Quizmaster", None)], rw=11, rh=9)
    pubquiz("st_peter_port_pub", "spp_quiz", "st_peter_port", "Warm-up: what do they call a Guernseyman? A donkey, an âne. No offence intended. You can ask what a Jerseyman gets called later.")
    room(z, "st_peter_port_bakery", 5, 29, 8, 4, "white_render", "Gâche Bakery", 4, "cafe",
         [("spp_baker", "shopkeeper", 3, 1, "down", "Baker",
           ["Gâche, hot out of the oven. Raisins, peel and a lot of butter. You cut it thick and spread it thicker. And if you want something to wash it down, we've a pot of tea going.",
            "The old bakers used to bake everyone's bean jar in the cooling oven on a Saturday night. We keep that spirit alive, at higher prices."])], rw=11, rh=9)
    room(z, "st_peter_port_cafe", 26, 29, 8, 4, "harbour_row", "The Fish Quay Café", 4, "cafe",
         [("spp_cafe_cook", "shopkeeper", 3, 1, "down", "Cook",
           ["Crab sandwiches, a mackerel supper and, if the tide's been kind, a plate of ormers. They're a sea snail with a lovely shell, and you can only gather them at certain tides. They taste like very good chicken that learnt to swim.",
            "It's a short walk to the boats. The Sark boat's the little one. Don't be fooled by the size, it's a tough little ferry."])], rw=11, rh=9)
    landmark(OUT, "st_peter_port_cornet", "Castle Cornet", zid, (55, 24), "castle",
             [dict(id="spp_cornet_gunner", sprite="ravenmaster", x=9, y=3, facing="left", move="still", script="spp_cornet_gunner", name="Castle Gunner")], w=15, h=10)
    script("st_peter_port_cornet", "spp_cornet_gunner", s("Castle Gunner",
        "Castle Cornet. In the Civil War we backed the king, and the rest of Guernsey backed Parliament. We sat out here for eight years, till the end of 1651, getting supplies by sea and shooting at the town. Awkward neighbours.",
        "We fire the Noon Gun every day at midday. It's the loudest thing in St Peter Port. Visitors jump and locals check their watches. I can tell you the exact moment the starling flies off the roof."))


def guernsey_country():
    W, H = 60, 48
    zid = "guernsey_country"
    z = Z(zid, "Guernsey Coast and Lanes", W, H, kind="route", region=REG, music="route_coast",
          weather={"drizzle": 22, "clear": 28, "sunshine": 24, "fog": 10, "gale": 8, "downpour": 8})
    z.d["stage"] = "coast"; z.d["scaled_floor"] = FLOOR
    z.legend["g"] = {"tile": "grass", "colour": "#6f9447"}
    z.rect(0, 0, W, H, ".")
    z.border("T", 2, gaps=[(58, 24, 2, 3)])
    z.scatter(0, 0, W, H, "P", 8, 81, only="T")
    # the west coast: Rocquaine and Cobo, sand and shallows and sea
    z.rect(0, 0, 4, H, "$"); z.rect(4, 0, 1, H, "w"); z.rect(5, 3, 3, 42, "s")
    # lanes
    path(z, [(58, 24), (14, 24)], "#", 3)
    path(z, [(30, 24), (30, 8)], "#", 2)
    path(z, [(30, 24), (30, 40)], "#", 2)
    path(z, [(10, 24), (10, 36)], "#", 2)
    # Little Chapel
    z.building(26, 9, 5, 4, "little_chapel", "The Little Chapel", door=2)
    z.warp(28, 12, "guernsey_chapel", 4, 5, "up")
    z.rect(26, 13, 5, 1, "#")
    plaque(z, 32, 13, "chapel", "The Little Chapel",
           "One of the smallest consecrated churches in the world, in the grounds of a Christian Brothers' school at Les Vauxbelets. Brother Déodat began it in 1914 as a model of the grotto at Lourdes, and decorated every surface with pebbles, seashells and bits of broken china that islanders brought him. Visitors still add to it.")
    # Occupation Museum
    z.building(10, 14, 10, 4, "stone", "German Occupation Museum", door=5)
    z.warp(15, 17, "guernsey_occupation", 7, 7, "up")
    z.rect(10, 18, 10, 1, "#")
    plaque(z, 21, 18, "gue_occupation_museum", "The Occupation Museum",
           "A private museum at Forest, founded from one man's collection of wartime objects: ration books, forged papers, a hidden radio, a reconstructed kitchen from 1944. Everything on show was used by islanders, or left by the soldiers who occupied the island between 1940 and 1945.")
    # Fort Grey, the Cup and Saucer
    z.building(8, 34, 5, 4, "jersey_tower", "Fort Grey", door=2)
    z.warp(10, 37, "guernsey_fortgrey", 5, 6, "up")
    z.rect(8, 38, 5, 1, "#")
    plaque(z, 14, 38, "fortgrey", "Fort Grey",
           "A round tower at Rocquaine Bay, built in 1804 against the threat of a French invasion, on a rock off the shore. It was called the Cup and Saucer for its shape. Today it is a museum of shipwrecks, and these shores have seen a great many, among the rockiest in the Channel.")
    # tomato glasshouses
    z.building(34, 30, 8, 3, "field_barn", "Glasshouses", show_label=False)
    z.building(44, 30, 8, 3, "field_barn", show_label=False)
    z.building(34, 35, 8, 3, "field_barn", show_label=False)
    plaque(z, 38, 33, "glasshouses", "The Glasshouses",
           "In the twentieth century Guernsey was covered in glasshouses, long low barns of glass called vineries, growing tomatoes and grapes and flowers for the mainland. The island's tomatoes were shipped out by the shipload. Many have gone, but their ghosts still sparkle in the sun.")
    plaque(z, 22, 30, "trepied", "Le Trépied",
           "A Neolithic passage tomb on the west coast, about 5,000 years old, called Le Trépied after its three-footed shape. Island folklore says witches met here for their sabbath on Friday nights, and in the sixteenth and seventeenth centuries some Guernsey women paid dearly for stories like that.")
    plaque(z, 8, 20, "cobo", "Cobo Bay",
           "A broad sandy bay on the west coast, famous for its sunsets. At low tide the sand runs out for hundreds of yards among rock pools. Islanders gather ormers here in the right season, at the lowest tides, and keep the rules to the letter.")
    plaque(z, 44, 26, "guernsey_lanes", "The Guernsey Lanes",
           "Guernsey's lanes are narrow and winding, and the cars crawl behind tractors. Some lanes are marked as Ruettes Tranquilles, quiet lanes where walkers, cyclists and riders have priority over drivers, with a speed limit of 15 miles an hour.")
    plaque(z, 44, 20, "sausmarez", "Sausmarez Manor",
           "A house in the south of the island, where the Sausmarez family have lived for centuries. The Queen Anne part dates from 1714. Its garden has subtropical plants, and a sculpture park, because Guernsey's mild climate lets palms and ferns thrive where you might expect only cabbages.")
    plaque(z, 36, 12, "sark", "A Nod to Sark",
           "Sark lies a few miles east of Guernsey, a rock island with no cars. In 2011 it was named the world's first Dark Sky Island, with no street lights and a sky full of stars. The boat from St Peter Port takes about an hour.")
    # people
    chat(z, "gue_beachcomber", "angler", 9, 28, "Beachcomber", ["..."], "right")
    chat(z, "gue_brother", "druid", 29, 14, "Chapel Keeper", ["..."], "down")
    chat(z, "gue_gannet", "birdwatcher", 15, 41, "Gannet Watcher",
         ["Alderney's gannets are the big draw for me. Thousands of pairs on the rocks of Les Etacs and Ortac, so thick the rocks look white. They dive from high above at more than fifty miles an hour.",
          "Guernsey's not bad for birds either. The cliffs are good for stonechats and fulmars. Alderney has puffins, too. Over on Burhou, with their little orange feet."], "down")
    chat(z, "gue_dgernesiais", "villager_4", 40, 24, "Lane Walker",
         ["In Dgèrnésiais, the Guernsey language, a fruit loaf is a gâche. Seaweed's vraic, same as in Jersey. And ormers are a shellfish that people stop their cars for.",
          "Very few people speak it now, but it's taught in schools and sung in choirs. Our own little language on our own little rock."], "left")
    trainer(z, "gue_ormer", "Ormer-Gatherer Mauger", "Ormer Gatherer", "fisherman_north",
            [("pinchkin", 40), ("baskling", 41), ("vraicling", 41)], 12, 31, "down",
            ["Ormers, it's a shell with a pearly inside. You can only gather them at the lowest spring tides, in season, and by hand. No diving. It's a good rule, and a lot of fun, and I'm not sharing my spots."],
            "That's me cleaned out. Have an ormer. Don't tell the warden.", "Ormers are a type of abalone and very slow to grow. They've been taken at certain tides since the old days. If the rules weren't strict, there'd be none left.", 780)
    trainer(z, "gue_cyclist", "Cyclist Renouf", "Cyclist", "jogger",
            [("kitelet", 40), ("zigzlet", 41), ("peregrin", 41)], 36, 25, "left",
            ["The lanes are 15 miles an hour and I'm doing 14. I'm quite fast, for Guernsey."],
            "Puncture. I've a flat tyre and a flat ego.", "Guernsey's lanes are narrow and walled with granite. Take a bike, take a basket, take a slice of gâche.", 740)
    trainer(z, "gue_monk", "Brother Michel", "Christian Brother", "pilgrim",
            [("beancrock", 41), ("heilan", 41), ("dextera", 41)], 30, 15, "up",
            ["Welcome to the Little Chapel. I help look after the gardens. We've a great many visitors and not nearly enough china to go round."],
            "Bless you. Come back and leave a shell.", "Brother Déodat began the chapel in 1914. He wanted it small, and he wanted it covered in other people's gifts.", 800)
    trainer(z, "gue_legend", "Dame Maud of the Vale", "Local Legend", "villager_3",
            [("moolet", 44), ("beancrock", 44), ("herdwick", 44), ("dextera", 44), ("vraicling", 44), ("connemarr", 45)], 52, 24, "left",
            ["I am Dame Maud of the Vale, champion of the Guernsey Show five years running and permanent thorn in the side of the Douzaine. I'll bake you a gâche or flatten you, whichever you've the stomach for."],
            "Well. You're a better trainer than my cows are milkmaids. Have a slice.", "I've seen occupation, rationing and tomato blight. A trainer from the mainland doesn't scare me. But I'll admit, you're good.", 3800)
    scale(["gue_ormer", "gue_cyclist", "gue_monk"])
    scale(["gue_legend"], FLOOR)
    wild(z, [("moolet", 40, 42, 14, {}), ("herdlet", 40, 41, 10, {}), ("fawnlet", 40, 42, 8, {"time": ["dawn", "dusk"]}),
             ("kitelet", 40, 41, 8, {"time": ["day"]}), ("leveret", 40, 41, 8, {"time": ["dawn", "dusk"]}),
             ("starlet", 40, 41, 8, {}), ("zigzlet", 40, 41, 6, {"time": ["day"]}), ("hootlet", 41, 42, 6, {"time": ["night"]}),
             ("brockling", 40, 42, 8, {"time": ["dawn", "dusk", "night"]}), ("pepperling", 40, 41, 6, {}),
             ("crockling", 40, 41, 6, {}), ("beancrock", 41, 42, 3, {"time": ["dusk", "night"]})])
    wild(z, [("pinchkin", 40, 41, 16, {}), ("puffling", 40, 41, 12, {"season": ["spring", "summer"]}), ("vraicling", 41, 43, 12, {}),
             ("pupplash", 40, 42, 10, {}), ("gannetling", 40, 42, 8, {}), ("baskling", 40, 42, 8, {})], "water")
    blob(z, 20, 10, 6, 3, ",", only=".", seed=82, jitter=0.3)
    blob(z, 46, 14, 5, 3, ",", only=".", seed=83, jitter=0.3)
    blob(z, 20, 32, 5, 3, ",", only=".", seed=84, jitter=0.3)
    blob(z, 50, 38, 5, 3, ",", only=".", seed=85, jitter=0.3)
    blob(z, 24, 44, 8, 2, ",", only=".", seed=86, jitter=0.3)
    scatter_props(z, "oak", 12, 6, 30, 10, 8, 87, avoid=("."))
    scatter_props(z, "oak", 14, 38, 40, 8, 6, 88, avoid=("."))
    for (x, y) in [(31, 26), (31, 22), (45, 23), (13, 26)]:
        z.prop("lamp_post", x, y)
    fingerpost(z, 55, 23, "EAST: St Peter Port. NORTH from the crossroads: the Little Chapel. SOUTH: the glasshouses and the south coast. WEST: the bays and Fort Grey.")
    z.d["edges"] = {"east": {"to": "st_peter_port", "offset": 0}}
    z.d["spawn"] = [56, 25]
    seal(z, [(58, 24, 2, 3)])
    done(z)
    z.save(OUT + "/" + zid + ".json")

    landmark(OUT, "guernsey_chapel", "The Little Chapel", zid, (28, 13), "church",
             [dict(id="gue_chapel_guide", sprite="villager_3", x=4, y=2, facing="down", move="still", script="gue_chapel_guide", name="Chapel Guide")], w=9, h=8)
    script("guernsey_chapel", "gue_chapel_guide", s("Chapel Guide",
        "The inside is as small as the outside. Seven or eight people make it full. The walls are covered with pebbles, shells and bits of china and glass, and the altar is built of the same. It's all lovingly cemented.",
        "Brother Déodat started it in 1914 and kept going for years. Islanders sent him china, and he'd happily accept a dinner plate from Aunt Doreen. Look for the bits of old china in the corner."))
    landmark(OUT, "guernsey_occupation", "German Occupation Museum", zid, (15, 18), "museum",
             [dict(id="gue_occ_curator", sprite="tour_guide", x=9, y=4, facing="left", move="still", script="gue_occ_curator", name="Curator")], w=15, h=10)
    script("guernsey_occupation", "gue_occ_curator", s("Curator",
        "Five years of the German Occupation, told through the everyday things: ration books, a fake ration stamp, a hidden radio, a child's toy made from scrap. Everything here is real and was used by people trying to get by.",
        "Thousands of children were evacuated before the occupation. Many families were parted for five years. The Germans built concrete fortifications round the island by forced labour. You'll still find the bunkers on every headland, and some are now holiday cottages."))
    landmark(OUT, "guernsey_fortgrey", "Fort Grey Shipwreck Museum", zid, (10, 38), "castle",
             [dict(id="gue_fortgrey_keeper", sprite="ravenmaster", x=5, y=3, facing="down", move="still", script="gue_fortgrey_keeper", name="Museum Keeper")], w=11, h=9)
    script("guernsey_fortgrey", "gue_fortgrey_keeper", s("Museum Keeper",
        "The Cup and Saucer, the locals call it. A round tower, built in 1804. The rocks round here have wrecked a great many ships, and the museum tells their stories: the Hanois lighthouse out on its reef, the lifeboats, and the ships that never made it round the corner.",
        "Pull up a seat. If the tide's right, the sea comes right up round the rocks, and you'd swear you were on a ship yourself. Mind your head on the way out. The door was built for people who ate less."))


def sark():
    W, H = 44, 46
    zid = "sark"
    z = Z(zid, "Sark", W, H, kind="town", region=REG, music="town_york",
          weather={"drizzle": 20, "clear": 32, "sunshine": 26, "fog": 8, "gale": 8, "downpour": 6})
    z.d["stage"] = "coast"; z.d["town_id"] = zid; z.d["scaled_floor"] = FLOOR
    z.rect(0, 0, W, H, "$")
    z.rect(2, 2, 40, 28, "w"); z.rect(3, 3, 38, 26, ".")
    # La Coupée: a narrow ridge to Little Sark, with sea either side
    z.rect(19, 29, 6, 6, "w"); z.rect(20, 29, 4, 6, "."); z.rect(21, 29, 2, 6, ":")
    z.rect(14, 34, 18, 10, "w"); z.rect(15, 35, 16, 8, ".")
    # the harbour at the south-east: a pier into the bay, Harbour Hill rising to the village
    z.rect(34, 24, 8, 4, "s")
    z.rect(38, 20, 5, 4, ":")
    z.d["ferry"] = {"x": 41, "y": 21, "route": "st_peter_port_sark"}
    z.rect(25, 12, 2, 12, "#"); z.rect(25, 22, 14, 2, "#")
    z.rect(5, 12, 32, 2, "#"); z.rect(8, 8, 28, 2, "#")
    z.rect(21, 14, 2, 15, "#")
    # the village at La Collinette crossroads: Seigneurie, mill, prison, tea room, sanctuary
    z.building(8, 4, 9, 5, "regency", "La Seigneurie", door=4); z.warp(12, 8, "sark_seigneurie", 6, 7, "up")
    z.building(19, 4, 4, 4, "windmill_white", "Sark Windmill")
    z.building(27, 4, 6, 4, "stone", "La Tour Prison", door=2); z.warp(29, 7, "sark_prison", 4, 5, "up")
    z.building(10, 15, 7, 4, "jersey_granite", "The Tea Garden", door=3); z.warp(13, 18, "sark_tearoom", 5, 6, "up")
    z.building(29, 15, 6, 4, "sanctuary", "Sanctuary", door=3); z.warp(32, 18, "sark_sanctuary", 5, 6, "up")
    z.building(4, 15, 5, 4, "jersey_granite", show_label=False)
    z.rect(27, 8, 7, 1, "#"); z.rect(8, 9, 9, 1, "#"); z.rect(10, 19, 7, 1, "#"); z.rect(29, 19, 6, 1, "#")
    z.prop("bench", 24, 13); z.prop("bench", 24, 19)
    z.prop("bunting", 25, 14, variant=2, walk=True)
    for (x, y) in [(6, 20), (36, 12), (30, 26), (15, 26), (6, 10)]:
        z.prop("oak", x, y, variant=(x + y) % 3)
    blob(z, 12, 24, 6, 3, ",", only=".", seed=91, jitter=0.3)
    blob(z, 30, 10, 3, 1, ",", only=".", seed=92)
    blob(z, 22, 38, 6, 3, ",", only=".", seed=93, jitter=0.3)
    plaque(z, 21, 23, "nocars", "No Cars on Sark",
           "There are no cars on Sark, the only island in Europe where nobody drives, apart from tractors, bikes and horse-drawn carriages. The ambulance is a tractor. The sensible way to get about is by bicycle or on foot, and the island's rule is that everybody waves.")
    plaque(z, 24, 9, "darksky", "A Dark Sky Island",
           "In January 2011 Sark was named the world's first Dark Sky Island by the International Dark-Sky Association. There are no street lights, so on a clear night the Milky Way is a brilliant band across the sky and you can see the stars as people did before electricity.")
    plaque(z, 14, 10, "seigneur", "The Seigneurie",
           "Queen Elizabeth I granted Sark in 1565 to Helier de Carteret of Jersey, who settled forty families here, and his successors held the island as seigneurs for centuries. The Seigneur ruled under feudal law until reforms in 2008 brought elected government. The Seigneurie's gardens are still a delight.")
    plaque(z, 28, 9, "prison", "The Prison",
           "A tiny two-cell prison of 1856, for the island's rare offenders. It was built from the island's granite and rarely used. The cells are about the size of a large cupboard, which is a very good reason to behave.")
    plaque(z, 20, 9, "mill", "Sark Windmill",
           "The windmill was built in 1571 and is the oldest on the island, and it belonged to the Seigneur, who made everyone grind their corn there. Sark has a wonderful legacy of old rules, some dating from that time. The mill has lost its sails but kept its dignity.")
    plaque(z, 22, 31, "coupee", "La Coupée",
           "A narrow isthmus, about eighty metres above the sea, joining Greater Sark to Little Sark. It was once a bare path with no rail on either side, and islanders crossed it with their eyes shut in a gale. Today it has railings. Do not walk it in a gale anyway.")
    plaque(z, 20, 40, "silver", "The Silver Mines",
           "In the 1830s and 1840s miners dug silver from Little Sark, tunnelling under the sea, and the mines were closed after a flood in 1847. The ruined engine house still stands on the cliffs. The mine promised a fortune and delivered a very large hole in the ground.")
    chat(z, "srk_cyclist", "hiker", 24, 17, "Cyclist",
         ["In Sark, everybody cycles. Bikes are hired at the harbour and ridden up the hill by anyone who thinks they'll manage. Mind the tractors, and the horses, and the cows. And the hill.",
          "There are a few hundred people living on the whole island, and every one of them knows exactly which cyclist you are. You'll be waving at all of them."], "right")
    chat(z, "srk_astronomer", "astronomer", 33, 10, "Stargazer",
         ["Sark has no street lights at all. On a clear night you can see the Milky Way from the harbour. There's a star party here every year, and the cloud always arrives on the night.",
          "The first Dark Sky Island in the world, we are. That sort of thing sticks in the islanders' throats. In a good way."], "left")
    chat(z, "srk_dame", "villager_3", 16, 12, "Gardener",
         ["Dame Sibyl Hathaway was Dame of Sark from 1927 to 1974. During the Occupation she ran the island's dealings with the Germans, as the Dame of the island, for five very long years. It is a more complicated story than most.",
          "Her roses are still in the garden. I tend them, with some fear."], "right")
    trainer(z, "srk_farmer", "Farmer Hamon", "Sark Farmer", "farmer",
            [("moolet", 40), ("herdlet", 41), ("kitelet", 41)], 32, 12, "left",
            ["No cars, no problem. I haul the milk by tractor and the post by bike. Come on, then."],
            "Aye, you've beaten me. Go on, then, wave.", "In Sark the tractors are the buses, the ambulance, the fire engine and the milk float. We call the passenger trailer a toast rack. You'll see why when you ride it.", 740)
    trainer(z, "srk_diver", "Diver Le Lievre", "Diver", "fisher",
            [("pinchkin", 40), ("baskling", 41), ("orcalet", 41)], 20, 36, "up",
            ["The caves at Gouliot are lined with sea anemones and sponges in every colour. Brilliant diving. Slightly less brilliant fighting, but I'll go."],
            "Well. I've lost my breath, and I'm not even underwater.", "Sark's caves and rock pools are among the best in the Channel. The anemones are nearly as colourful as the island's gossip.", 740)
    scale(["srk_farmer", "srk_diver"])
    wild(z, [("moolet", 40, 41, 10, {}), ("herdlet", 40, 41, 8, {}), ("leveret", 40, 41, 10, {"time": ["dawn", "dusk"]}),
             ("dozelet", 40, 41, 10, {}), ("puffling", 40, 41, 8, {}), ("glowmite", 40, 41, 8, {"time": ["night"]}),
             ("hootlet", 41, 42, 8, {"time": ["night"]}), ("kitelet", 40, 41, 8, {"time": ["day"]}), ("starlet", 40, 41, 8, {}),
             ("crockling", 40, 41, 4, {})])
    wild(z, [("pinchkin", 40, 41, 16, {}), ("puffling", 40, 41, 12, {"season": ["spring", "summer"]}), ("gannetling", 40, 42, 10, {}),
             ("baskling", 40, 42, 8, {}), ("vraicling", 41, 43, 8, {})], "water")
    z.npc(id="srk_sailor", sprite="sailor", x=40, y=20, facing="right", move="still", script="srk_sailor", name="Boatman")
    script(zid, "srk_sailor", say("Boatman", "Back to St Peter Port? Right you are. The tide's with us, and so is the sunset.") + [{"do": "ferry", "route": "st_peter_port_sark"}])
    z.d["edges"] = {}
    z.d["spawn"] = [41, 22]
    done(z)
    z.save(OUT + "/" + zid + ".json")
    sanctuary(OUT, zid, "Sark", (32, 19))
    nurse(zid, ["Hello, dear. Sark Sanctuary. We're the only clinic for three miles and the ambulance is a tractor. Pop your team on the counter.",
                "Sit down. There's tea, a scone and the best view of the sunset you'll ever get from a waiting room.",
                "All done. Good as new. Mind the hill on the way out, it's got ideas.",
                "The Ark's in the corner. It came on the boat and says never again, but that's what everybody says.",
                "Right you are. Don't forget to wave to everybody."])
    landmark(OUT, "sark_seigneurie", "La Seigneurie", zid, (12, 9), "hall",
             [dict(id="srk_gardener", sprite="villager_3", x=4, y=4, facing="right", move="still", script="srk_gardener", name="Head Gardener")])
    script("sark_seigneurie", "srk_gardener", s("Head Gardener",
        "The Seigneurie is the old manor, with its walled garden, its dovecote, its pigeon loft and its legendary roses. The Seigneur lived here, the Dame before him, and the island still looks to this place for its history.",
        "Sark was granted to Helier de Carteret in 1565. He brought forty families, and their descendants are still here. Sark's old feudal system lasted until 2008, and the island has since had an elected government. Everyone I know says it was the right call and still misses the pageantry."))
    landmark(OUT, "sark_prison", "La Tour Prison", zid, (29, 8), "cottage",
             [dict(id="srk_constable", sprite="warden_grunt", x=5, y=3, facing="down", move="still", script="srk_constable", name="Constable")], w=9, h=8)
    script("sark_prison", "srk_constable", s("Constable",
        "Two cells, no windows to speak of and a very small key. It was built in 1856 for the island's rare offenders, and it hasn't seen heavy use. We have an arrest every few years, and the arrested person generally finds their own way home.",
        "Sark's constable and the Chief Pleas keep order. You'd have to go some to get yourself arrested here. Perhaps park a car."))
    landmark(OUT, "sark_tearoom", "The Tea Garden", zid, (13, 19), "cafe",
             [dict(id="srk_tea", sprite="shopkeeper", x=3, y=1, facing="down", move="still", script="srk_tea", name="Tea Lady")], w=11, h=9)
    script("sark_tearoom", "srk_tea", s("Tea Lady",
        "Sark butter, Sark cream and a cream tea that will ruin you for all others. The scones come out at three, and everyone knows it, and every cyclist on the island arrives by ten past.",
        "We shut at dusk because there's no light on Sark. If you stay for the stars, I'll lend you a torch. A dim one. Please keep it low, the astronomers are very sensitive."))
