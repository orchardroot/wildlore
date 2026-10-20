# 3.3 "Overseas", wave 33 agent 2: St Helena.
#   st_helena_jamestown (town): the valley town between the cliffs, the Castle, St James', the Museum, the Consulate Hotel,
#                               Jacob's Ladder and the wharf
#   st_helena_plantation (route): Plantation House and Jonathan, Longwood House, Napoleon's empty tomb in Sane Valley,
#                                 Deadwood Plain and the wirebirds
# Usage: python3 tools/zones/os_sthelena.py data/zones
import sys
from os_common import *
from sc_common import creature_npc

TERR = "st_helena"
REGION = "overseas_st_helena"
WX = {"clear": 24, "sunshine": 22, "drizzle": 18, "fog": 8, "gale": 14, "downpour": 6, "frost": 0}
WX_HIGH = {"fog": 34, "drizzle": 26, "clear": 14, "downpour": 10, "gale": 12, "sunshine": 4}
Q = "q_overseas_st_helena_"


def jamestown(OUT):
    W, H = 60, 54
    zid = "st_helena_jamestown"
    z = Z(zid, "Jamestown, St Helena", W, H, kind="town", region=REGION, music="town_cornwall", weather=WX)
    z.d["stage"] = "coast"; z.d["town_id"] = zid; z.d["scaled_floor"] = FLOOR
    z.legend["k"] = {"tile": "grass", "colour": "#7e8a54"}
    z.legend["g"] = {"tile": "grass", "colour": "#98a060"}
    z.legend["a"] = {"tile": "path", "colour": "#a89478"}
    z.legend["h"] = {"tile": "tall_grass", "colour": "#8e8a4a"}
    z.legend["c"] = {"tile": "cliff", "colour": "#5a4e46", "side": "#4a3e38"}
    z.rect(0, 0, W, H, "k")
    # the sea to the north, the cliffs to either side of a narrow valley
    z.rect(0, 0, W, 6, "$"); z.rect(0, 6, W, 1, "w"); z.rect(0, 7, W, 2, "s")
    z.rect(0, 9, 13, H - 9, "c"); z.rect(49, 9, 11, H - 9, "c")
    z.rect(0, 7, 8, 2, "c"); z.rect(52, 7, 8, 2, "c")
    for y in range(9, H):
        z.set(13, y, "c" if y % 3 else "R"); z.set(48, y, "c" if y % 3 else "R")
    z.height(0, 9, 13, H - 9, 3); z.height(49, 9, 11, H - 9, 3)
    z.d["edges"]["south"] = {"to": "st_helena_plantation", "offset": 0}
    # Main Street runs up the valley from the wharf; a lane crosses it
    z.rect(13, H - 2, 36, 2, "c")
    z.rect(29, 7, 3, H - 7, "=")
    z.rect(14, 24, 34, 2, "=")
    z.rect(14, 38, 34, 2, "#")
    # the wharf and a few boats
    z.building(27, 3, 7, 4, "pier", "Jamestown Wharf", show_label=False)
    for (bx, by) in [(18, 3), (40, 2), (46, 4)]:
        z.prop("boat", bx, by, variant=0)
    z.prop("bollard", 28, 8); z.prop("bollard", 33, 8); z.prop("lobster_pots", 24, 8); z.prop("buoy", 36, 6)
    # row A: the Castle (government offices) and St James'
    ret_castle = door_to(z, 16, 11, 11, 5, 5, "sa_colonial", "The Castle", "st_helena_castle", 13, 10)
    ret_church = door_to(z, 34, 11, 7, 4, 3, "chapel", "St James' Church", "st_helena_church", 13, 10)
    # row B
    ret_s, ret_h = town_buildings(z, zid, (15, 18, "sanctuary"), (22, 18, "shop"))
    ret_museum = door_to(z, 34, 18, 7, 4, 3, "sa_colonial", "Museum of St Helena", "st_helena_museum", 13, 10)
    ret_hotel = door_to(z, 42, 18, 6, 4, 2, "sa_colonial", "Consulate Hotel", "st_helena_hotel", 13, 10)
    # row C: homes, a bakery, the market
    z.building(15, 27, 6, 4, "sa_colonial", "Main Street")
    z.building(22, 27, 6, 4, "sa_colonial", "Main Street")
    z.building(34, 27, 6, 4, "sa_colonial", "Main Street")
    z.building(41, 27, 6, 4, "sa_colonial", "Main Street")
    # Jacob's Ladder, up the cliff on the west side
    z.building(14, 41, 3, 10, "jacobs_ladder", "Jacob's Ladder", show_label=True)
    z.d["spawn"] = [30, 22]
    # the Castle Gardens: trees and benches
    scatter_props(z, "oak", 14, 9, 30, 16, 14, 21, avoid=("k",))
    for (bx, by) in [(24, 17), (36, 23), (44, 23)]:
        z.prop("bench", bx, by)
    for (lx, ly) in [(28, 12), (33, 12), (28, 30), (33, 30), (28, 44), (33, 44)]:
        z.prop("lamp_post", lx, ly)
    scatter_props(z, "bush", 14, 32, 34, 20, 18, 22, avoid=("k",))
    scatter_props(z, "rock", 14, 40, 34, 12, 8, 23, avoid=("k", "h"))
    blob(z, 40, 46, 5, 3, "h", only="k", seed=3, jitter=0.5)
    blob(z, 22, 48, 5, 2, "h", only="k", seed=4, jitter=0.5)
    # ---- plaques ----
    plaque(z, 30, 9, "sthelena_island", "St Helena",
           "One of the most remote inhabited islands on Earth, about 1,950 kilometres from the coast of Africa and 3,300 from South America. The Portuguese found it in 1502 and it was uninhabited. The East India Company settled it in 1659, which makes it Britain's second-oldest overseas territory, after Bermuda.")
    plaque(z, 24, 16, "sthelena_castle", "The Castle",
           "The oldest building in Jamestown still in use, built by the East India Company as its headquarters in the 1700s, and still full of government offices. It has a quiet garden at the back, and a wall with a very old well. Governors have come and gone over it for three centuries.")
    plaque(z, 37, 16, "sthelena_stjames", "St James' Church",
           "St James' Church, built in 1774, is said to be the oldest Anglican church in the southern hemisphere. It stands at the foot of the valley where the Saints, as the islanders call themselves, have been christened, married and buried for over two hundred years.")
    plaque(z, 15, 40, "sthelena_ladder", "Jacob's Ladder",
           "A flight of 699 steps straight up the cliff of Ladder Hill, built in 1829 to haul goods up to the fort on a cable railway, with a tramway of rails and a donkey, and workers to carry the rest. Today people race up it for fun. The record is in minutes, and in pain.")
    plaque(z, 36, 22, "sthelena_museum", "The Museum of St Helena",
           "A small museum in a former warehouse by the wharf, with maps, shipwreck finds and objects from the 1800s. One section is the Napoleon room. Another, more sobering, is about the thousands of enslaved Africans freed here by the Royal Navy in the 1800s.")
    plaque(z, 47, 22, "sthelena_consulate", "The Consulate Hotel",
           "Named for the Consul the Americans once had here, to support the ships that called in for water. The hotel in Jamestown remembers the days when a hundred ships a month came into the roads. It is also the place to eat a St Helena fishcake.")
    plaque(z, 25, 32, "sthelena_liberated", "Liberated Africans",
           "From 1840 to 1872 the Royal Navy's West Africa Squadron brought around 26,000 people freed from slave ships to St Helena, many of them in a terrible state. Rupert's Valley, just outside Jamestown, was their holding place, and many are buried there. Several became Saints, and their descendants are part of the island.")
    plaque(z, 38, 32, "sthelena_boats", "Ships' Call",
           "For three hundred years St Helena was a refuelling stop for ships heading round the Cape. Sailors called in for water, fresh vegetables and gossip. In 1815, with Napoleon on the island, it was guarded by a squadron of the Royal Navy, and nobody was allowed to land without a pass.")
    plaque(z, 30, 40, "sthelena_saints", "The Saints",
           "The islanders call themselves Saints. They are descended from English settlers, Africans, Indians, Chinese labourers and many others who ended up on the island. For most of its history the only way here was a ship from Cape Town, about five days away. The airport finally opened in 2016.")
    # ---- folk ----
    chat(z, "sth_fishwife", "villager_4", 36, 32, "Saint Fishwife",
         ["You want the fishcake. Tuna, potato, a little onion and a lot of pepper, fried in a pan. Every family has its own version, and every family says its version is the only one.",
          "Plo, now, is a rice dish, and it's on every table. Nobody will tell you how to spell it. Plo, plow, plough, whatever the sailors wrote."], "down", "still")
    chat(z, "sth_wharf", "fisherman_north", 32, 8, "Wharfinger",
         ["Everything comes in here by ship. Sugar, tea, tyres. The RMS St Helena, the old mail ship, did the run to Cape Town for years. Now it's the Saint Helena, a smaller and sturdier lady.",
          "To land at Jamestown you used to hold a rope and be swung ashore from the boat. People still talk about the ones who missed."], "right", "still")
    chat(z, "sth_runner", "jogger", 18, 39, "Ladder Racer",
         ["Seven hundred steps, give or take the landing. I did it in under ten minutes, which is the island record for anyone with legs. I'm told the donkey could have done better.",
          "The steps are steep. That's the point. If you can walk up them in your good shoes with a cake, you're a Saint."], "down", "still")
    chat(z, "sth_coffee", "farmer", 44, 36, "Coffee Grower",
         ["Green Tipped Bourbon Arabica, grown on the hills up top. The East India Company brought the first beans in 1733. A few hundred bushes at first, and now people pay a lot for our small crop.",
          "Napoleon, they say, took coffee at Longwood. Whether it was ours or a good cup I can't swear."], "left", "still")
    chat(z, "sth_boy", "villager_5", 38, 44, "Saint Schoolkid",
         ["We learn about Napoleon at school, and the Boer prisoners, and the ships. I was bored of it for years and then somebody said, you live on the most interesting rock in the world, and I thought, oh.",
          "My granny can say 'one place, one people' in six ways and not one of them means anything bad."], "up", "wander")
    return_npc(z, zid, 30, 7, "rail_guard", "Airport Rep",
               "The flight home goes from the new airport at Prosperous Bay, about a drive up and over the hill. They run a minibus. I'll sort you a seat.",
               "Minibus is waiting. Mind the sheep on the road.")
    # ---- trainers ----
    wild_set(z, [("plodlet", 14, {}), ("kidgruff", 8, {}), ("flaxling", 12, {}), ("duneskink", 8, {}), ("legionette", 6, {"time": ["night"]}),
                 ("hootlet", 6, {"time": ["night"]}), ("gentlet", 10, {}), ("pixling", 8, {"weather": ["fog", "drizzle"]}), ("wirefoot", 8, {})])
    wild_set(z, [("pinchkin", 14, {}), ("dolphlet", 10, {}), ("baskling", 8, {}), ("plungebeak", 10, {}), ("greyhaul", 8, {})], "water")
    trainer(z, "sth_fisher", "Fisherman Lionel", "Fisherman", "fisherman_north",
            [("greyhaul", 95), ("baskling", 96), ("dolphlet", 96), ("clawcastle", 96)], 38, 7, "left",
            ["Tuna on a line, one at a time, from a small boat. No nets, no drift. That's how it's done here. Same for the battles."],
            "Fair fight. The tuna agrees.",
            "St Helena fishermen still catch tuna one at a time, by pole and line, which is gentler on the sea than a net.", 5600)
    trainer(z, "sth_ladder", "Ladder Racer Mia", "Racer", "jogger",
            [("stormswift", 96), ("peregrin", 95), ("kitelet", 96), ("goldeneyrie", 96)], 16, 38, "right",
            ["Seven hundred steps, then a battle. If you beat me, I'll let you have the next step. Down."],
            "Well run. Next time I'll bring a flask.",
            "The race up Jacob's Ladder is a fixture of the island's calendar. The steps have been counted more than any others on Earth, and there are always 699.", 5600)
    trainer(z, "sth_clerk", "Castle Clerk Winifred", "Civil Servant", "gown_student",
            [("workhive", 95), ("ironwatch", 95), ("tickhopper", 96), ("shuttlecog", 96)], 22, 17, "up",
            ["The Castle's records go back to the East India Company. It would take a lifetime to read them. I've been reading them for most of one."],
            "Very good. I'll file that under 'unexpected'.",
            "The island's archives hold the Company's day books, with weather, shipping and complaints. St Helena has a long, careful memory.", 5700)
    trainer(z, "sth_boer", "Historian Ruth", "Historian", "explorer",
            [("legionette", 96), ("centurion", 96), ("shieldbiter", 95), ("ironwatch", 96)], 20, 33, "up",
            ["About five thousand Boer prisoners were held on this island in 1900 and 1901. They built things, played cricket and wrote letters. Let me tell you about it on the way. Shall we?"],
            "That was brief. History usually isn't.",
            "The Boer prisoners made carvings and furniture and even a small theatre. Some of what they built is still in use on the island.", 5700)
    scaled(["sth_fisher", "sth_ladder", "sth_clerk", "sth_boer"])
    finish_zone(z)
    z.save(OUT + "/" + zid + ".json")
    return ret_s, ret_h, (ret_castle, ret_church, ret_museum, ret_hotel)


def plantation(OUT):
    W, H = 60, 58
    zid = "st_helena_plantation"
    z = Z(zid, "Plantation and Longwood", W, H, kind="route", region=REGION, music="route_moor", weather=WX_HIGH)
    z.d["stage"] = "moor"; z.d["scaled_floor"] = FLOOR
    z.legend["k"] = {"tile": "grass", "colour": "#8a9a52"}
    z.legend["g"] = {"tile": "grass", "colour": "#6a9a44"}
    z.legend["h"] = {"tile": "tall_grass", "colour": "#9a9a4a"}
    z.legend["a"] = {"tile": "path", "colour": "#a89478"}
    z.legend["c"] = {"tile": "cliff", "colour": "#5a4e46", "side": "#4a3e38"}
    z.rect(0, 0, W, H, "k")
    z.border("T", 2)
    mound(z, 46, 48, 12, 9, 5)          # Diana's Peak
    mound(z, 14, 44, 10, 8, 3)          # Sane Valley's rim
    smooth(z)
    path(z, [(29, 0), (29, 4)], "a", 3)
    path(z, [(29, 4), (29, 36), (46, 36), (46, 31)], "a", 2)     # the road in from Jamestown, then up to Longwood
    path(z, [(29, 22), (14, 22)], "a", 2)                         # the road to Plantation House
    path(z, [(14, 22), (14, 46)], "a", 2)                         # the track down to Sane Valley
    z.d["edges"]["north"] = {"to": "st_helena_jamestown", "offset": 0}
    blob(z, 32, 30, 11, 6, "h", only="kg", seed=2, jitter=0.5)   # Deadwood Plain: wirebird pasture
    blob(z, 44, 48, 8, 6, "g", only="k", seed=3, jitter=0.4)     # the cloud forest on Diana's Peak
    blob(z, 12, 12, 7, 5, "h", only="k", seed=4, jitter=0.5)
    blob(z, 28, 50, 9, 4, "h", only="k", seed=5, jitter=0.5)
    scatter_props(z, "oak", 3, 3, 54, 52, 50, 31, avoid=("g",))
    scatter_props(z, "bush", 3, 3, 54, 52, 40, 32, avoid=("k", "g"))
    scatter_props(z, "sheep", 20, 26, 22, 10, 6, 33, avoid=("k", "h"))
    # Plantation House (the Governor's residence) with its lawn, where Jonathan lives
    z.rect(6, 10, 18, 11, "g")
    ret_ph = door_to(z, 10, 12, 10, 5, 4, "sa_colonial", "Plantation House", "st_helena_plantation_house", 13, 10)
    # Longwood House, Napoleon's last home
    z.rect(40, 25, 14, 13, "g")
    z.rect(46, 31, 2, 7, "a")
    ret_lw = door_to(z, 42, 26, 9, 5, 4, "sa_colonial", "Longwood House", "st_helena_longwood", 13, 10)
    # Napoleon's Tomb in Sane Valley: willows and a fence
    z.rect(8, 46, 10, 7, "g"); z.rect(10, 47, 6, 4, "F"); z.rect(11, 48, 4, 2, "g"); z.rect(14, 47, 2, 1, "g")
    z.prop("tomb_chest", 12, 48)
    z.d["spawn"] = [30, 3]
    plaque(z, 27, 3, "sthelena_up", "Up the Hill",
           "From Jamestown the road climbs the cliff in loops to the cool, green interior. It is cooler up here by several degrees. The island's highest point, Diana's Peak, is 823 metres, and from it you can see most of St Helena, and a very great deal of sea.")
    plaque(z, 15, 18, "sthelena_plantation", "Plantation House",
           "The Governor's official residence since the 1790s, a Georgian house with a long lawn. It is also home to Jonathan, a Seychelles giant tortoise who arrived in 1882, already fully grown. He is thought to be the oldest living land animal on Earth, which has been his only career.")
    plaque(z, 44, 33, "sthelena_longwood", "Longwood House",
           "Napoleon Bonaparte was exiled to St Helena in 1815 after Waterloo, and lived at Longwood House until he died there on 5 May 1821. The house and its grounds, and his tomb, have been French property since 1858, and a French honorary consul looks after them. The French flag flies above them.")
    plaque(z, 13, 44, "sthelena_tomb", "Napoleon's Tomb",
           "In a quiet valley under willow trees, Napoleon was buried in 1821, in a grave with no name, because the British and French could not agree on how to inscribe it. His remains were taken to Paris in 1840 and now lie in Les Invalides. The empty tomb remains, and so do the willows.")
    plaque(z, 38, 24, "sthelena_wirebird", "The Wirebird",
           "The St Helena plover, called the wirebird because of its thin legs, lives nowhere else in the world. It is the island's national bird. It nests on open pasture and so is easily disturbed by dogs, cats and people. The conservation team asks everyone to keep to the paths.")
    plaque(z, 46, 44, "sthelena_dianas", "Diana's Peak",
           "The island's highest point, wrapped in a thin remnant of the tree-fern forest that once covered the interior. The tree ferns and the other endemic plants are kept alive by the conservation team's work, with goats and invasive plants cleared to give them a chance.")
    plaque(z, 30, 34, "sthelena_deadwood", "Deadwood Plain",
           "In 1900 and 1901 about five thousand Boer prisoners of war were held on the plain at Deadwood. The grass here had been a Napoleon-era military camp too. Today it is open farmland and the best place on the island to spot a wirebird.")
    plaque(z, 21, 32, "sthelena_flax", "The Flax Years",
           "Between about 1907 and 1965 the island's main industry was New Zealand flax, grown for rope and fibre and processed in mills. When plastic rope arrived, the market collapsed and the island lost its main income. The remaining flax now grows wild on the hills.")
    plaque(z, 26, 14, "sthelena_gumwood", "The Gumwood Forest",
           "Before goats, felling and ships, St Helena was covered in gumwood and ebony forest, found nowhere else. By the 1700s most had gone, and several kinds of plant were lost for ever. The St Helena olive was declared extinct in the 1990s. A small number of gumwoods are now being planted again.")
    # ---- folk ----
    creature_npc(z, "sth_jonathan", "elderplod", 17, 19,
                 "Jonathan chews a leaf at a speed that makes a very good argument for patience. He has outlived every Governor, every head gardener and a world war or two, and is not tempted to speed up.")
    z.d["npcs"][-1]["name"] = "Jonathan"
    chat(z, "sth_gardener", "farmer", 9, 22, "Head Gardener",
         ["Jonathan eats the lawn, and a fair number of cabbages, and the occasional hat. He's a hundred and ninety, near enough. He's lost his sense of smell and some of his sight, but he knows when it's lunch.",
          "We feed him a mix of lettuce, cucumber and bananas. He gets a sunny spot, and in the evenings he is brought in. The vet visits and says he is in great health for his age, which is not a lot of use as a figure."], "right", "still")
    chat(z, "sth_warden", "birdwatcher", 33, 31, "Wirebird Warden",
         ["The wirebird runs, rather than flies. A fast skitter across the grass, then a stop to look at you. Keep your dog on a lead and your steps on the path and we've a chance.",
          "There are fewer than a thousand of them, and every chick counts. We count every nest. The good news is that there are more than there were."], "down", "still")
    chat(z, "sth_consul", "gown_student", 43, 34, "Longwood Guide",
         ["Longwood House has the rooms as Napoleon left them, as near as we can. The billiard room, the study, the bedroom where he died. The damp was terrible. The place was thought a miserable spot even in his day.",
          "People ask if he was a prisoner. The island's records say so. The wallpaper says he was bored. Both are probably right."], "up", "still")
    chat(z, "sth_walker", "hillwalker", 44, 18, "Hill Walker",
         ["The Diana's Peak walk is the one. Up through the tree-fern forest, cool and green, past the endemic whitewood and the dogwood. Wear a coat. The cloud comes down suddenly.",
          "The tree ferns look like they walked out of a Jurassic picture book, and they've been here a lot longer than the Saints."], "down", "still")
    wild_set(z, [("wirefoot", 14, {}), ("plodlet", 10, {}), ("herdwick", 10, {}), ("flaxling", 10, {}), ("pixling", 10, {"weather": ["fog", "drizzle"]}),
                 ("hootlet", 8, {"time": ["night"]}), ("legionette", 6, {"time": ["night"]}), ("ratty", 6, {}), ("holtling", 6, {})])
    wild_set(z, [("holtling", 12, {}), ("ratty", 10, {}), ("rillotter", 10, {})], "water")
    trainer(z, "sth_vet", "Vet Henrietta", "Vet", "keeper_hester",
            [("elderplod", 96), ("herdwick", 96), ("plodlet", 95), ("heilan", 96)], 18, 26, "right",
            ["Jonathan has had every ailment you can imagine, and several no one can. I'm told by the gardener that you were seen nearby. Care to show me how you handle your team?"],
            "Healthy as a tortoise. That's the highest compliment I give.",
            "A Seychelles giant tortoise can live for 150 years or more, and weigh over 200 kilograms. Jonathan has been checked, wormed and scolded by many vets.", 5700)
    trainer(z, "sth_farmer", "Farmer Bertie", "Farmer", "farmer",
            [("herdwick", 95), ("tormane", 96), ("loaghtan", 96), ("flaxling", 96)], 36, 27, "left",
            ["Cattle, a few sheep, flax on the old fields. Come to think of it, the battle's easier than the coffee."],
            "That's the kind of luck I only get once a year.",
            "St Helena farmers grow vegetables, keep cattle and sheep, and a few grow coffee, at the hardest altitude and in the wettest air.", 5600)
    trainer(z, "sth_legend", "Consul Lucien", "French Honorary Consul", "poet",
            [("centurion", 97), ("legionette", 96), ("megalorn", 97), ("ironwatch", 96), ("steelheart", 97), ("elderplod", 97)], 47, 32, "left",
            ["I keep a French house on a British island, which is to say a flag in a garden. It is not a small responsibility. You will excuse me if I treat this as a point of honour."],
            "Magnifique! Napoleon himself would have written a very long and very cross letter about that.",
            "Longwood is French territory, a small piece of France on St Helena. The wallpaper has been restored to what Napoleon's was. He thought it terrible.", 9500)
    for n in z.d["npcs"]:
        if n["id"] == "sth_legend":
            del n["trainer"]; n["script"] = "sth_legend_talk"; n["name"] = "Consul Lucien"
    scaled(["sth_vet", "sth_farmer", "sth_legend"])
    # the tomb: stepping up to the fence and bowing (a flag for the quest)
    z.sign(11, 49, "NAPOLEON'S TOMB. The empty grave of the Emperor, under willow trees. His body was taken to Paris in 1840. The willows have stayed.")
    chat(z, "sth_mourner", "villager_3", 13, 49, "Mourner", ["The grave is empty and the willows are not."], "left", "still")
    finish_zone(z)
    z.save(OUT + "/" + zid + ".json")
    return ret_ph, ret_lw


def interiors(OUT, ret_ph, ret_lw, rets):
    ret_castle, ret_church, ret_museum, ret_hotel = rets
    zid = "st_helena_jamestown"
    interior(OUT, "st_helena_castle", "The Castle", zid, ret_castle, "hall",
             [npc("sth_secretary", "gown_student", 6, 3, "sth_secretary", name="Island Secretary")])
    script("st_helena_castle", "sth_secretary", say("Island Secretary",
           "Welcome to the Castle. It isn't a castle. It was the East India Company's headquarters, and the name stuck. The Governor comes down from Plantation House, and the rest of us stay and do the paperwork.",
           "St Helena's government is small. We pay for roads, doctors and teachers with money from Britain and a good deal of ingenuity. If you want to know how a place the size of a town runs a whole country, ask here.",
           "There are fewer than five thousand Saints living on the island, and about the same number overseas, in Britain, Ascension and the Falklands. Many families have members on all three."))
    interior(OUT, "st_helena_church", "St James' Church", zid, ret_church, "church",
             [npc("sth_vicar", "choir_singer", 6, 2, "sth_vicar", name="Vicar")])
    script("st_helena_church", "sth_vicar", say("Vicar",
           "St James' is the oldest Anglican church in the southern hemisphere, or so they say, and on a quiet day I believe it. The bell came from a ship, I'm told, and the bell does not mind where it has ended up.",
           "On Sunday we are always full, and the hymns are in four parts. Saints sing like they mean it. Come in and sit. There are no bad seats."))
    interior(OUT, "st_helena_museum", "Museum of St Helena", zid, ret_museum, "museum",
             [npc("sth_curator", "gown_student", 6, 3, "sth_curator", name="Museum Curator"),
              npc("sth_guide", "tour_guide", 9, 5, "sth_guide", name="Napoleon Room Guide", facing="left")],
             signs=[(3, 6, "THE NAPOLEON ROOM. A death mask, a few letters, a snuffbox and a very long list of complaints about the wallpaper.")])
    script("st_helena_museum", "sth_guide", say("Napoleon Room Guide",
           "The Emperor arrived on HMS Northumberland in October 1815, and stayed at the Briars first, in a pavilion with a garden, and then at Longwood. He called the damp 'the climate of a swamp'. The British called it 'lodgings'.",
           "He died in 1821, aged fifty-one. The cause is still argued about: the autopsy said stomach cancer and a thousand books since have said otherwise."))
    interior(OUT, "st_helena_hotel", "Consulate Hotel", zid, ret_hotel, "cafe",
             [npc("sth_innkeeper", "villager_2", 3, 1, "sth_innkeeper", name="Innkeeper"),
              npc("sth_regular", "fisherman_north", 9, 3, "sth_regular", name="Regular", facing="left")],
             props=[("fireplace", 6, 1, {"walk": True})])
    script("st_helena_hotel", "sth_innkeeper", say("Innkeeper",
           "Welcome to the Consulate. We've had presidents' envoys, naval captains and, once, a man who walked up Jacob's Ladder carrying a fridge. A quiz tonight, and the coffee is local.") +
           [{"do": "quiz", "pub": "st_helena_hotel", "region": "overseas", "who": "Innkeeper"}])
    script("st_helena_hotel", "sth_regular", say("Regular",
           "In the old days a hundred ships at once could be in the roads, all wanting water. The Governor had a bell for it. Rings once for a visitor, twice for a ship of the line. It's been quiet for years, and people like it.",
           "I tell my grandkids Napoleon is the island's most famous tourist. They tell me he didn't have a choice, and I say that's what makes him so memorable."))
    zid = "st_helena_plantation"
    interior(OUT, "st_helena_plantation_house", "Plantation House", zid, ret_ph, "home",
             [npc("sth_aide", "villager_6", 6, 3, "sth_aide", name="Governor's Aide")], w=13, h=10)
    script("st_helena_plantation_house", "sth_aide", say("Governor's Aide",
           "The Governor lives here, with an office on the ground floor, a garden, and the finest lawn on the island. Jonathan comes in for the hot afternoons. Mind the tortoise, he has right of way.",
           "The house was built in the 1790s for the Company's governors. The first lodgers were an uncomfortable mixture of officials and servants. Napoleon's jailer, Sir Hudson Lowe, lived here too, and was not loved."))
    interior(OUT, "st_helena_longwood", "Longwood House", zid, ret_lw, "museum",
             [npc("sth_longwood_curator", "gown_student", 6, 3, "sth_longwood_curator", name="Curator"),
              npc("sth_longwood_valet", "tour_guide", 9, 5, "sth_longwood_valet", name="Guide", facing="left")],
             signs=[(3, 6, "THE BILLIARD ROOM. Napoleon had a table here, and used it for maps as much as games."),
                    (10, 3, "THE STUDY. He dictated his memoirs here, mostly to Count Las Cases.")])
    script("st_helena_longwood", "sth_longwood_curator", say("Curator",
           "The rooms are small and low, and Napoleon hated them. The house was rat-infested and damp when he arrived. The British added a room for his billiards and he refused to use it for years in protest.",
           "France bought the house in 1858. The French consul is the official guardian. In a way, you are standing in France."))
    script("st_helena_longwood", "sth_longwood_valet", say("Guide",
           "His bedroom is as it was. The camp bed he took on campaigns. A bath. A clock stopped at the time he died, which is a sad little touch and also entirely true.",
           "People ask if he was poisoned. A great many books have been written. Most doctors now think it was stomach cancer, like his father."))


def quest_data(OUT):
    z = "st_helena_jamestown"
    # the quest giver is the Museum Curator inside the museum
    d = DLG.setdefault("st_helena_museum", {})
    d["sth_curator"] = [cmd_if(Q + "done",
        say("Museum Curator", "Your notes about the island are in the visitors' book, and the Napoleon room has a new photograph of Jonathan. I put it up myself."),
        [cmd_if(Q + "4",
                say("Museum Curator", "You've seen all of it: the tomb, the tortoise and the wirebird. You're an honorary Saint. Here is a sprig of willow from Sane Valley, and a packet of the island's own coffee. Don't spend them on one cup.") +
                [give("willow_sprig"), give("st_helena_coffee")] + standing(3) + [setf(Q + "done")],
                [cmd_if(Q + "started",
                        say("Museum Curator", "Three things first. Show a Wirefoot to the Warden up at Deadwood. Greet Jonathan on the lawn at Plantation House. And pay your respects at Napoleon's tomb in Sane Valley. Then come back and I'll make it official."),
                        say("Museum Curator", "Welcome to the museum. People come to St Helena for Napoleon and stay for the tortoise. Would you like a real Saint's tour? Three places: the Wirebird Warden at Deadwood, Jonathan at Plantation House, and the tomb in Sane Valley.") + [setf(Q + "started")])])])]
    # step flags: the Warden after a Wirefoot, Jonathan on the lawn, the tomb sign (read via a tomb keeper)
    DLG["st_helena_plantation"]["sth_warden"] = [cmd_if(Q + "1",
        say("Wirebird Warden", "Our wirebird is yours to remember. Keep to the paths."),
        [cmd_if(Q + "started",
                [when("has_wirefoot",
                      say("Wirebird Warden", "A Wirefoot! One of ours, and you've got it in your Fieldbook. The curator will be pleased. You're on the list of friends.") + [setf(Q + "1")],
                      say("Wirebird Warden", "Not yet. Look in the long grass on Deadwood Plain. Quiet feet, quiet voice."))],
                say("Wirebird Warden", "The wirebird runs, rather than flies, and the island has fewer than a thousand. Keep your dog on a lead and your steps on the path, and we've a chance."))])]
    DLG["st_helena_plantation"]["sth_jonathan"] = say("Jonathan",
        "Jonathan raises his head, weighs you up with great seriousness, and goes back to the grass. He is about 190. He has seen everything and has chosen not to comment.") + \
        [cmd_if(Q + "started", [setf(Q + "2")] + say("", "You have said hello to Jonathan. He has not said hello back, which is how he says it."))]
    DLG["st_helena_plantation"]["sth_tomb"] = []
    # the tomb: the Longwood guide at the gate asks you to visit; a mourner at the fence sets the flag
    DLG["st_helena_plantation"]["sth_mourner"] = [cmd_if(Q + "started", [setf(Q + "3")], [])] + say("Mourner",
        "The grave is empty and the willows are not. A great many people come to stand here, and say nothing. It is the most peaceful place on the island, which is quite an achievement for a ruined Emperor.")
    hint = say("Consul Lucien", "Bonjour. I keep the keys to Longwood, and I only fight those who have done the whole tour. Greet the tortoise, meet the wirebird, and bow at the empty tomb in Sane Valley. Then come back to me.")
    fight = say("Consul Lucien", "Bonjour. I am the French Honorary Consul, and I keep the keys. Our flag is the only one on the island that is not British, and I defend it. You have done the tour: a fight, then, in the French manner, with elegance and a little arrogance.") + \
        [battle("sth_legend")] + say("Consul Lucien", "Bravo. You have the spirit of a marshal. Tell the curator the Consul says you may call yourself a Saint.") + [setf(Q + "4")]
    DLG["st_helena_plantation"]["sth_legend_talk"] = [cmd_if(Q + "4", say("Consul Lucien", "You came back for more! Monsieur or Madame is welcome at Longwood any time."),
        [cmd_if(Q + "started", [cmd_if(Q + "1", [cmd_if(Q + "2", [cmd_if(Q + "3", fight, hint)], hint)], hint)],
                say("Consul Lucien", "Bonjour. This is Longwood, a little piece of France on a British island. If you wish to be shown the island, the curator at the museum in Jamestown will begin the tour."))])]
    quests = [{"id": "st_helena_saint", "title": "A Saint's Tour", "region": "overseas_st_helena", "town": "st_helena_jamestown", "giver": "Museum Curator",
               "summary": "Prove you know St Helena: meet the wirebird, Jonathan the tortoise and Napoleon's empty tomb, then beat the French Consul.",
               "start_flag": Q + "started",
               "steps": [{"flag": Q + "1", "text": "Show a Wirefoot to the Wirebird Warden on Deadwood Plain.", "zone": "st_helena_plantation"},
                         {"flag": Q + "2", "text": "Say hello to Jonathan the tortoise on the lawn at Plantation House.", "zone": "st_helena_plantation"},
                         {"flag": Q + "3", "text": "Pay your respects at Napoleon's tomb in Sane Valley.", "zone": "st_helena_plantation"},
                         {"flag": Q + "4", "text": "Beat the French Consul at Longwood, then report to the Museum Curator.", "zone": "st_helena_plantation"}],
               "done_flag": Q + "done", "reward": "A Willow Sprig charm, a packet of St Helena Coffee and standing in the Overseas Territories."}]
    write_quests(TERR, quests)


def items_and_registry():
    return [heal_item("st_helena_fishcake", "St Helena Fishcake", 380, 140, "A flat, crisp-edged patty of tuna, potato and onion, pan-fried and served hot: the dish the Saints eat on every occasion, in at least a hundred slightly different versions. Restores 140 HP."),
            {"id": "st_helena_coffee", "name": "St Helena Coffee", "kind": "meal", "price": 600, "battle": False, "field": True, "amount": 60, "meal": {"buff": "lure", "steps": 60},
             "desc": "Green Tipped Bourbon Arabica, grown on the island's hills since the East India Company brought the first plants in 1733. A small harvest, picked and dried by hand. Restores 60 HP.",
             "effect_text": "The smell carries: for 60 steps, wild creatures turn up more often."},
            charm_item("willow_sprig", "Willow Sprig", "A cutting from the willow trees that shade Napoleon's empty tomb in Sane Valley. Napoleon was buried here in 1821 and taken to Paris in 1840, and the willows stayed.",
                       "Spirit moves hurt it 25% less.", {"effect": "resist", "type": "spirit", "mult": 0.75}, "{name} felt the calm of the willows!")]


def main(OUT):
    ret_s, ret_h, rets = jamestown(OUT)
    ret_ph, ret_lw = plantation(OUT)
    z = json.load(open(OUT + "/st_helena_plantation.json"))
    interiors(OUT, ret_ph, ret_lw, rets)
    sanctuary_and_shop(OUT, "st_helena_jamestown", "Jamestown", ret_s, ret_h,
        ["Hello, my love. Jamestown Hospital, which here we call the Sanctuary for creatures. You're a long way from home, but they're not. Pop them down.",
         "A cup of tea and a sit, and a look at the sea over the rooftops. The whole of Jamestown has been doing that for three hundred years.",
         "All done. They're stronger than a wirebird at dawn.",
         "The Ark's by the window, with a view of the wharf.",
         "No trouble, love. Mind the steps on the way out."],
        ("Hello! Fishcakes, coffee, and everything the ship brought. There's a queue on ship day, and nobody minds.", "Take care, love. You're one of ours now."),
        ["cup_of_tea", "flask_of_tea", "smelling_salts", "wicker_snare", "iron_snare", "water_snare", "night_snare", "st_helena_fishcake", "st_helena_coffee"])
    quest_data(OUT)
    write_items("overseas_st_helena", items_and_registry())
    write_registry("st_helena", "St Helena", "st_helena_jamestown", 30, 22, "raf",
                   "Napoleon's last home, Jonathan the tortoise and 699 steps up a cliff.",
                   "The aircraft banks over a lump of green rock in a very large sea. The pilot says: St Helena, ladies and gentlemen. The wind will decide how you arrive.")
    append_quiz("overseas", [
        ("history", "Where was Napoleon exiled in 1815?", "St Helena", ["Elba", "Corsica", "Ascension"], "He lived at Longwood House until he died in 1821."),
        ("creatures", "Which animal on St Helena is thought to be the oldest living land animal?", "Jonathan the tortoise", ["A parrot", "A goat", "A donkey"], "Jonathan was born about 1832 and lives on the lawn at Plantation House."),
        ("geography", "How many steps does Jacob's Ladder in Jamestown have?", "699", ["199", "365", "1,000"], "It was built in 1829 to haul goods up to the fort on Ladder Hill."),
        ("nature", "What is the St Helena plover better known as?", "The wirebird", ["The pinkbird", "The fairy tern", "The ladybird"], "It is found only on St Helena, and is the island's national bird."),
        ("food", "Which hot drink is St Helena famous for growing?", "Coffee", ["Tea", "Cocoa", "Mate"], "Green Tipped Bourbon Arabica has grown there since 1733."),
    ])


if __name__ == "__main__":
    OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
    main(OUT)
    write_all(OUT)
    print("st helena: written")
