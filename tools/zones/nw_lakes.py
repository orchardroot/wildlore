# plan 6 group B, part 2: lake_district (landmark route, big fells, tarns, Herdwicks, scree) and keswick (town on Derwentwater).
from nw_common import *


def build(OUT):
    lakes(OUT)
    keswick(OUT)


def lakes(OUT):
    W, H = 72, 60
    z = Z("lake_district", "Lake District", W, H, kind="route", region="cumbria", music="route_mountain", weather=WX_FELL)
    z.d["stage"] = "mountain"
    z.legend["r"] = {"tile": "path", "colour": "#8c897f"}                 # bare fell rock
    z.legend["b"] = {"tile": "tall_grass", "colour": "#8d7c46"}           # bracken
    z.border("T", 2, gaps=[(30, 58, 3, 2), (30, 0, 3, 2)])
    z.scatter(0, 0, W, H, "P", 26, 4, only="T")
    # the fells: smooth slopes so every height step is one level
    mound(z, 12, 16, 11, 10, 6)
    mound(z, 60, 34, 11, 11, 6)
    mound(z, 50, 53, 8, 6, 3)
    mound(z, 62, 8, 7, 5, 3)
    rnd = random.Random(61)
    for y in range(2, H - 2):
        for x in range(2, W - 2):
            hv = z.hg[y][x]
            if hv >= 5:
                z.g[y][x] = "r"
            elif hv >= 2 and rnd.random() < 0.35:
                z.g[y][x] = "b"
            elif hv == 1 and rnd.random() < 0.2:
                z.g[y][x] = ","
    # the way through: south gap to the farm, past the tarn, over the pass to Keswick
    z.rect(30, 50, 3, 8, "#")
    path(z, [(31, 50), (44, 50), (44, 37), (27, 37), (27, 22), (46, 22), (46, 12), (31, 12)], "#", 2)
    z.rect(30, 12, 3, 2, "#"); z.rect(30, 0, 3, 13, "#")
    path(z, [(10, 52), (30, 52)], "#", 2)
    path(z, [(14, 40), (27, 40)], "#", 2)
    # tarn below Scafell and a smaller one in the pass
    z.rect(12, 34, 12, 8, "w"); z.rect(13, 35, 10, 6, "~")
    z.rect(33, 6, 8, 5, "w"); z.rect(34, 7, 6, 3, "~")
    # a beck from the pass down to the south, with two pack-horse bridges
    z.rect(36, 30, 4, 28, "w"); z.rect(37, 30, 2, 28, "~")
    z.rect(36, 37, 4, 2, "|"); z.rect(36, 50, 4, 2, "|")
    # Red Tarn pocket on the big eastern fell: a ring of crag, entered over scree
    z.rect(55, 26, 11, 7, "^")
    z.rect(56, 27, 9, 5, ","); z.rect(58, 28, 5, 2, "w"); z.rect(59, 28, 3, 1, "~")
    z.rect(56, 31, 9, 1, "f"); z.rect(56, 27, 2, 1, "f")
    z.rect(59, 32, 3, 2, "/")
    z.sign(60, 31, "RED TARN. A tarn is a mountain pond left behind by a glacier, and this one sits in a bowl of crag with one way in. Whoever came up the scree: well done. The view is better than the walk.")
    # Scafell summit pocket: bare rock, a cairn, and one very surprised sheep
    z.rect(5, 8, 9, 5, "^")
    z.rect(6, 9, 7, 3, "r")
    z.rect(8, 12, 3, 2, "/")
    for i, (x, y) in enumerate([(8, 10), (10, 10), (9, 9)]):
        z.prop("standing_stone", x, y, variant=i)
    z.prop("rock", 9, 10); z.prop("rock", 7, 11, variant=1)
    z.sign(11, 11, "SCAFELL PIKE. At 978 metres, the highest point in England. The cairn is a pile of stones with a lot of opinions. A good walker adds a stone, takes a photo, and leaves before the cloud decides to stay.")
    # the farm: a respectful nod to a famous author who left her farms to the nation
    wall_h(z, 44, 3, 27, gaps=[8, 9, 10, 11, 29])
    wall_v(z, 27, 44, 56, gaps=[52, 53])
    z.rect(4, 45, 22, 12, ".")
    z.rect(6, 51, 15, 3, "f"); z.rect(6, 51, 15, 1, "F"); z.rect(6, 53, 15, 1, "F")
    z.rect(6, 52, 1, 1, "F"); z.rect(20, 52, 1, 1, "F")
    z.building(6, 46, 7, 4, "slate_cottage", "Farmhouse")
    z.building(16, 46, 7, 4, "stone", "Barn")
    z.rect(9, 50, 2, 1, ":")
    z.prop("planter", 8, 50); z.prop("planter", 12, 50); z.prop("bench", 14, 50); z.prop("lamp_post", 5, 50)
    z.rect(8, 54, 3, 2, "f"); z.rect(18, 54, 4, 2, ","); z.rect(5, 54, 2, 2, ",")
    z.sign(13, 50, "A HILL FARM. The woman who lived here wrote little books about animals in waistcoats, bred Herdwick sheep, and left four thousand acres to the nation so nobody could build on them. The sheep are still here, and still unimpressed with the whole business.")
    z.sign(28, 51, "HERDWICK COUNTRY. These grey, woolly sheep have been on the Cumbrian fells since the Vikings. A Herdwick lamb is born black and goes grey, like a good wizard. They remember their own patch of hill and teach it to their lambs. No fences needed.")
    # the slate mine in the north-east
    z.rect(56, 3, 13, 7, ".")
    z.building(58, 4, 6, 3, "slate_cottage", "Slate Mine")
    for (x, y) in [(57, 8), (60, 8), (63, 8), (66, 7), (55, 6), (66, 4)]:
        z.prop("slate_heap", x, y, variant=(x + y) % 3)
    z.sign(52, 11, "THE SLATE MINE. Green slate has been cut from this fell for centuries, and the mountain is full of tunnels. The rock is dressed by hand, split with a chisel, and used to roof half the Lakes. The other half is under cloud.")
    z.sign(46, 24, "THE PASS. One of the oldest packhorse routes in the Lakes, and a very good place for the fog to hold a meeting. If the cloud comes down, stop, wait and have your sandwich.")
    z.sign(25, 36, "THE TARN. A glacier scooped this out and left it to fill with rain, which the Lakes have supplied ever since. The nearby beck is full of small fish, who have never seen a bad day because they live in the wet.")
    # walls, rocks, trees
    wall_h(z, 18, 4, 28, gaps=[27, 28], ch="W")
    scatter_props(z, "rock", 3, 3, 66, 54, 70, 62, avoid=(".", "b", "r", ","))
    scatter_props(z, "oak", 3, 20, 28, 36, 14, 63, avoid=(".",))
    scatter_props(z, "pine", 40, 36, 28, 20, 12, 64, avoid=(".",))
    scatter_props(z, "birch", 3, 30, 12, 12, 8, 65, avoid=(".",))
    # Herdwicks on the fells
    for i, (x, y) in enumerate([(8, 20), (18, 26), (34, 42), (52, 48), (42, 16), (24, 52), (14, 54)]):
        sheep(z, "herdwick_%d" % (i + 1), x, y, "herdwick",
              ["Baa. It's a large, calm baa, from an animal that has seen several generations of walkers and is not impressed by any of them.",
               "It chews. It looks at your boots. It chews again.",
               "Herdwick lambs are born dark and slowly go grey. They're also born knowing which bit of the fell is theirs. It's called hefting. They teach it to the lambs, and no fences are needed."][i % 3])
    sheep(z, "herdwick_summit", 9, 11, "herdwick", "How did YOU get up here? I came for the grass. The cairn is an accident.", move="still")
    # people
    chat(z, "ld_shepherd", "villager_5", 13, 47, "Shepherdess",
         ["The Herdwicks 'heft' to the hill: each ewe knows her own bit of fell without a fence, and she passes it to her lambs. If a flock's lost, you can't just replace it. You have to wait three generations.",
          "My dog's name is Fly. She knows more about the sheep than I do, and she's polite about it."], "down", "wander")
    chat(z, "ld_walker", "hillwalker", 29, 31, "Fell Walker",
         ["Eight hundred metres up and the weather's changed four times. Waterproofs on, waterproofs off, and now a hat with a bobble. The Lakes make you a layer person.",
          "There's a rule: Wainwright's guides list 214 fells. People try to climb them all. They're called Wainwright-baggers. It's a hobby and also a punishment."], "right", "wander")
    chat(z, "ld_slater", "tin_miner", 61, 8, "Slate Miner",
         ["Green slate: the colour of rain on a good day. We split it by hand, one layer at a time. You can tell the good bit by the ring when you tap it.",
          "Roofs in the Lakes last a century. Roofing slate's the only thing here that doesn't mind the wet."], "down", "still")
    chat(z, "ld_poet", "poet", 44, 40, "Fell Poet",
         ["I wandered lonely as a cloud, but the cloud was quite crowded. Mind you, daffodils do take the day off from the weather.",
          "A famous poet lived near here and walked about 175,000 miles in his life. He wrote his verses in his head as he went. He never once brought a map."], "left", "wander")
    chat(z, "ld_ranger", "birdwatcher", 41, 14, "Ranger",
         ["I'm told off for walking off the path, and then I tell off the walkers for walking off the path. It's a very circular job.",
          "Look at the pass in front of you. See the cairn of stones? Please leave them stacked. If you must add one, add a little one."], "down", "still")
    # trainers
    trainer(z, "ld_fellrunner", "Fell Runner Aled", "Fell Runner", "jogger", [("kitelet", 86), ("kidgruff", 86), ("ptarmlet", 87)],
            26, 30, "right", ["Bob Graham Round: forty-two fells in twenty-four hours. I did it in twenty-three. Fifty-nine minutes. I'm told that's 'close'."],
            "You're faster than the weather, and that's a rare thing here.", "Fell running is simple: go up, then try not to fall down.", 3500)
    trainer(z, "ld_angler", "Angler Cecily", "Angler", "angler", [("volet", 86), ("stalklet", 86), ("holtling", 87)],
            25, 37, "right", ["Char in the tarn! Ice Age relics, they are. I fish with a very light line and a very heavy sigh."],
            "The one that got away was a better fighter than you.", "Charr only live in the cold, deep Lakes. They don't like the heat. I sympathise.", 3500)
    trainer(z, "ld_birder", "Birdwatcher Rosamund", "Birdwatcher", "birdwatcher", [("ospret", 87), ("eaglet", 86), ("cranelet", 86)],
            40, 36, "down", ["Ospreys came back to the Lakes in 2001 after a very long gap. I've been waiting for them with a flask since breakfast."],
            "You have a keener eye than I do, and I've been told off by a heron.", "The osprey dives feet first. It's the only bird that fishes with a trapdoor.", 3450)
    trainer(z, "ld_warden", "Warden Peregrine", "Warden", "warden_grunt", [("binfox", 87), ("sootwing", 87), ("raidtail", 86)],
            44, 11, "down", ["Welcome to the Lakes Heritage Experience! We've curated the mountains for your comfort. They didn't ask to be curated, but they're coming round."],
            "Not a single mountain moved. I'll put that in my report.", "The Enclosure wants a handrail up the whole of Scafell. I've said the fell won't take kindly to it.", 3500)
    trainer(z, "ld_climber", "Climber Annika", "Climber", "hillwalker", [("slatelet", 88), ("eaglet", 87), ("tapknock", 87)],
            60, 30, "down", ["You got up the scree! Respect. I came for the quiet. The quiet had other ideas."],
            "Well climbed. Both the scree and me.", "A climber never says 'it's easy'. A climber says 'it goes'.", 3700)
    z.d["edges"] = {"south": {"to": "lancaster", "offset": 0}, "north": {"to": "keswick", "offset": 0}}
    z.d["spawn"] = [31, 55]
    wild(z, [("herdlet", 86, 88, 18, {}), ("kidgruff", 86, 88, 10, {}), ("slatelet", 86, 87, 10, {}), ("eaglet", 86, 88, 8, {}),
             ("ospret", 86, 87, 8, {"time": ["day", "dawn"]}), ("ptarmlet", 87, 88, 8, {"weather": ["fog", "frost", "downpour"]}),
             ("midgie", 86, 87, 12, {"time": ["dusk", "dawn"]}), ("stoatlet", 86, 87, 8, {}), ("kitelet", 86, 88, 8, {"time": ["day"]}),
             ("tapknock", 87, 88, 6, {"weather": ["fog"]}), ("brockling", 86, 87, 6, {}), ("flittermouse", 86, 87, 6, {"time": ["night"]})])
    wild(z, [("volet", 86, 88, 26, {}), ("stalklet", 86, 87, 14, {}), ("cranelet", 86, 87, 12, {}), ("ospret", 87, 88, 10, {}),
             ("holtling", 86, 87, 12, {}), ("dipling", 86, 87, 12, {}), ("elverlet", 86, 87, 8, {"weather": ["drizzle", "downpour"]})], "water")
    tidy(z)
    z.save(OUT + "/lake_district.json")


def keswick(OUT):
    W, H = 56, 44
    z = Z("keswick", "Keswick", W, H, kind="town", region="cumbria", music="town_cheshire", weather=WX_FELL)
    z.d["stage"] = "valley"; z.d["town_id"] = "keswick"
    z.border("T", 2, gaps=[(30, 42, 3, 2)])
    z.scatter(0, 0, W, H, "P", 14, 9, only="T")
    # Derwentwater with its islands, boats and a jetty
    z.rect(3, 2, 50, 15, "~"); z.rect(3, 17, 50, 1, "w")
    z.rect(16, 6, 5, 3, "."); z.rect(38, 8, 4, 3, ".")
    z.prop("oak", 17, 6); z.prop("oak", 19, 7, variant=1); z.prop("pine", 39, 8); z.prop("pine", 40, 9, variant=1)
    z.prop("boat", 10, 8, variant=1); z.prop("boat", 36, 5, variant=1); z.prop("boat", 44, 12, variant=1); z.prop("boat", 24, 12, variant=1)
    z.prop("boat", 33, 13, variant=0)
    for (x, y) in [(14, 11), (47, 7), (21, 14), (6, 5), (51, 13)]:
        z.prop("buoy", x, y)
    z.rect(28, 11, 3, 7, "|")
    z.prop("bollard", 27, 12); z.prop("bollard", 31, 12); z.prop("bollard", 27, 15); z.prop("bollard", 31, 15)
    z.rect(3, 18, 50, 2, ":")
    for x in range(6, 50, 6):
        z.prop("lamp_post", x, 19)
    for x in (9, 15, 21, 36, 42, 48):
        z.prop("bench", x, 18)
    z.sign(33, 18, "DERWENTWATER. 'Queen of the Lakes', three miles long, with islands, a famous floating island of weed in late summer, and boats that go round it every hour. It is not the largest lake in the district. It is, we're told, the prettiest.")
    # the Market Place with the Moot Hall in the middle
    z.rect(3, 20, 44, 11, ":")
    z.building(28, 23, 7, 4, "stone", "Moot Hall")
    z.building(35, 22, 3, 4, "chapel", show_label=False)
    z.sign(32, 27, "THE MOOT HALL. Built in 1813 on the site of earlier halls, with a clock tower and a very pleasant way of standing in the middle of the road. 'Moot' is the old word for a meeting. It's now the tourist information centre, which is its own kind of meeting.")
    z.building(16, 22, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(19, 25, "keswick_sanctuary", 5, 6, "up")
    z.building(40, 22, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(42, 25, "keswick_shop", 4, 5, "up")
    z.building(4, 22, 8, 4, "red_brick", "Cumberland Pencil Museum")
    z.sign(8, 26, "CUMBERLAND PENCIL MUSEUM. Pencils have been made in Keswick since 1832, after graphite was found in the nearby hills. Inside is the world's largest coloured pencil, nearly eight metres long. Exit through the gift shop. The gift shop is, of course, a pencil.")
    z.sign(11, 26, "NOW SHARPENING. Please queue. It's a long queue and all points. (We are sorry. We have been told to leave it in.)")
    for (x, y) in [(24, 29), (26, 29), (38, 29), (40, 29)]:
        z.prop("market_stall", x, y)
    z.prop("planter", 15, 22); z.prop("planter", 22, 22); z.prop("planter", 39, 22); z.prop("planter", 45, 22)
    z.prop("lamp_post", 27, 23); z.prop("lamp_post", 38, 23); z.prop("lamp_post", 27, 28); z.prop("lamp_post", 37, 28)
    z.prop("phone_box", 14, 21); z.prop("post_box", 46, 21)
    # the road in and the houses
    z.rect(30, 31, 3, 11, "="); z.rect(29, 31, 1, 11, ":"); z.rect(33, 31, 1, 11, ":")
    for (x, y, st, lab) in [(14, 33, "slate_cottage", None), (21, 33, "white_render", "Tea Shop"), (35, 33, "slate_cottage", None),
                            (42, 33, "red_brick", "Outdoor Shop"), (14, 38, "terrace", None), (21, 38, "slate_cottage", "Guest House"),
                            (36, 38, "terrace", None), (43, 38, "slate_cottage", None)]:
        z.building(x, y, 6, 3, st, lab) if lab else z.building(x, y, 6, 3, st)
    z.rect(13, 36, 16, 1, ":")
    z.rect(13, 31, 1, 11, ":"); z.rect(49, 31, 1, 11, ":")
    station(z, 4, 34, 9, 4, "Keswick Station")
    rail_guard(z, 5, 36, ["Keswick Station. The old line closed in 1972, but the Wildlore rail has the good sense to keep the platform. Trains for every station you have visited. Mind the gap, the sheep and the weather."], facing="right")
    z.rect(3, 39, 9, 3, ","); z.rect(34, 31, 1, 1, "f")
    z.rect(14, 42, 14, 1, ","); z.rect(34, 42, 14, 1, ",")
    # Castlerigg on its hill, with a path out of the Market Place
    hill(z, 49, 28, 5, 5, 2)
    z.rect(47, 25, 4, 1, "#"); z.rect(50, 25, 2, 3, "#")
    for i in range(8):
        a = i * math.pi / 4
        z.prop("standing_stone", 51 + round(2.6 * math.cos(a)), 30 + round(2.4 * math.sin(a)), variant=i % 3)
    z.sign(51, 27, "CASTLERIGG STONE CIRCLE. About forty stones in a ring on a hilltop, over five thousand years old, with fells in every direction. Nobody knows quite what it was for. A good guess is a very early meeting. Some things never change.")
    z.rect(50, 35, 4, 6, ",")
    scatter_props(z, "oak", 3, 31, 10, 11, 5, 91, avoid=(".",))
    scatter_props(z, "bush", 3, 31, 50, 12, 10, 92, avoid=(".",))
    scatter_props(z, "pine", 46, 36, 8, 6, 4, 93, avoid=(".", ","))
    for i, (x, y) in enumerate([(48, 35), (52, 33), (50, 40)]):
        sheep(z, "kes_herdwick_%d" % (i + 1), x, y, "herdwick", "A Herdwick, up on the hill. It has been here for a thousand years, give or take a lamb.")
    # people
    chat(z, "kes_boatman", "fisher", 29, 17, "Launch Skipper",
         ["The launches go round the lake every hour, stopping at jetties for walkers. We're the buses of Derwentwater, and the passengers are usually damp.",
          "The lake has a floating island. In hot summers a mat of weed rises from the bottom, and it can carry a dog. Please don't test that."], "right", "still")
    chat(z, "kes_pencil", "villager_6", 8, 28, "Pencil Museum Clerk",
         ["A pencil isn't lead, of course. It's graphite, and there's a very good story about how a storm in Borrowdale found it in the 1500s, when the roots of a fallen tree exposed the seam.",
          "For years, graphite was so valuable that guards watched the mine. It was used for casting cannonballs, and for the very first pencils. I'm told the cannonballs are less common now."], "down", "wander")
    chat(z, "kes_walker", "hillwalker", 24, 20, "Walker",
         ["Catbells, Skiddaw, Latrigg. All walkable from here, and all with a view of Derwentwater. I'm doing the three before lunch. I mean the three before tea.",
          "Keswick has more outdoor shops than anywhere I've ever seen. They're all slightly different shades of green."], "down", "wander")
    chat(z, "kes_hotelier", "shopkeeper", 22, 31, "Guest House Owner",
         ["Welcome! Breakfast is at eight, which includes black pudding, because it's the Lakes. The washing line is for socks. If the weather is dry, which it's not, you may use it.",
          "We get four hundred days of rain a year here. I'm told that's mathematically impossible. Come and tell the clouds."], "down", "wander")
    chat(z, "kes_ice", "villager_2", 36, 20, "Ice Cream Seller",
         ["Rum and raisin, or Kendal mint cake in cone form. Kendal mint cake has been taken up Everest. It was in the pocket of a man who got to the top. I'm not saying it's the reason.",
          "Cumberland sausage: a coil, never a link. Cumberland people are very particular. Ask them."], "left", "still")
    trainer(z, "kes_angler", "Angler Barnaby", "Angler", "angler", [("holtling", 87), ("cranelet", 87), ("volet", 87)],
            25, 19, "right", ["Perch, pike, and the odd brown trout. I fish the lake from the jetty because it's the one place in Keswick that's both dry and open."],
            "A first-class landing. I'll spend the afternoon pondering it.", "Pike are called water wolves. They're not very sociable. Neither am I, before tea.", 3500)
    trainer(z, "kes_climber", "Climber Hamish", "Climber", "hillwalker", [("kidgruff", 87), ("tapknock", 87), ("herdlet", 87)],
            49, 26, "down", ["I do the Lakeland crags with a pair of boots and a flask. The flask is more reliable."],
            "I have not climbed that one before. I'll make a note of the route.", "Latrigg, Catbells, Skiddaw. Keswick's an easy place to be a wee bit lost, and a very good place to be found.", 3500)
    z.d["edges"] = {"south": {"to": "lake_district", "offset": 0}}
    z.d["spawn"] = [31, 32]
    wild(z, [("herdlet", 87, 88, 16, {}), ("ospret", 87, 88, 8, {"time": ["day"]}), ("midgie", 87, 87, 12, {"time": ["dusk", "dawn"]}),
             ("slatelet", 87, 88, 8, {}), ("pipkin", 87, 87, 12, {}), ("kidgruff", 87, 88, 8, {}), ("starlet", 87, 87, 10, {}),
             ("stalklet", 87, 88, 6, {})])
    wild(z, [("stalklet", 87, 88, 20, {}), ("cranelet", 87, 88, 16, {}), ("ospret", 87, 88, 12, {}), ("dipling", 87, 88, 14, {}),
             ("holtling", 87, 88, 14, {}), ("elverlet", 87, 88, 8, {"weather": ["drizzle", "downpour"]})], "water")
    tidy(z)
    z.save(OUT + "/keswick.json")
    sanctuary(OUT, "keswick", "Keswick", (19, 26))
    shop(OUT, "keswick", "Keswick", (42, 26))
    nurse("keswick", ["Hello, my love! Welcome to the Keswick Sanctuary. Sit by the radiator, it's the only thing in town that's warm and dry.",
                      "Rest awhile. There's tea in the pot and a rock cake that has, I'm afraid, lived up to its name. Your team is in good hands.",
                      "They're good as new. Off you go now, and take a waterproof. Take two. Take the hat with the bobble.",
                      "The Ark? It's through there, by the kettle. If it starts to hum, that's the tea; if it starts to hiss, that's the computer.",
                      "No bother. Pop in whenever you're soaked. Which is whenever."])
    shopkeeper("keswick", "Welcome in! Mint cake, thermals, and a pencil with your name on it. The pencil is optional. The thermals are advisable.",
               "Off you go, then. Mind the fells. They'll look after you if you look after them.")
