# plan 4 group B, part 3: wicklow (route), kilkenny (town), comeraghs (route), cork (city), with Sanctuary and Corner Shop.
from wcommon import *
import math


def build(OUT):
    wicklow(OUT)
    kilkenny(OUT)
    comeraghs(OUT)
    cork(OUT)


def creature(z, sprite, x, y, nid, script_id):
    import wcommon
    wcommon._stand(z, x, y)
    z.npc(id=nid, sprite="creature:" + sprite, x=x, y=y, facing="down", move="wander", script=script_id)


def hills(z, peaks, sc=2.3, y_lo=0, y_hi=None):
    """smooth hills: height = peak - distance / sc. Adjacent tiles never differ by more than 1."""
    for y in range(z.h):
        for x in range(z.w):
            z.hg[y][x] = max([0] + [max(0, hm - int(math.hypot(x - cx, y - cy) / sc)) for (cx, cy, hm) in peaks])


def wicklow(OUT):
    W, H = 64, 56
    z = Z("wicklow", "Wicklow Mountains", W, H, kind="route", region="ireland", music="route_ireland",
          weather={"drizzle": 30, "fog": 22, "clear": 16, "downpour": 12, "sunshine": 10, "gale": 6, "frost": 4})
    z.d["stage"] = "valley"
    z.legend["h"] = {"tile": "tall_grass", "colour": "#7a5c6a", "prop": "heather"}
    z.legend["k"] = {"tile": "grass", "colour": "#8a8a4d"}
    hills(z, [(54, 10, 4), (8, 10, 4), (54, 48, 4), (8, 46, 4)])
    z.border("P", 2, gaps=[(30, 0, 3, 2), (0, 30, 2, 3)])
    z.scatter(0, 0, W, H, "T", 14, 2, only="P")
    z.scatter(2, 2, W - 4, H - 4, "P", 80, 3, only=".")
    # heather and upland grass on the mountains
    for (x, y, w, h) in [(46, 3, 12, 8), (4, 4, 12, 8), (46, 42, 14, 8), (4, 40, 12, 9), (44, 14, 8, 4), (10, 18, 8, 5), (48, 32, 8, 4)]:
        z.rect(x, y, w, h, "h")
    for (x, y, w, h) in [(40, 4, 6, 5), (16, 6, 6, 4), (40, 44, 6, 6), (16, 44, 6, 6)]:
        z.rect(x, y, w, h, "k")
    # roads: the road down from Dublin, the monastic site, the road west
    z.rect(30, 0, 3, 22, "#")
    z.rect(24, 22, 16, 5, ":")
    z.rect(30, 22, 3, 11, "#"); z.rect(0, 30, 33, 3, "#")
    z.rect(30, 27, 3, 3, "#")
    z.rect(35, 12, 21, 2, "#"); z.rect(35, 12, 2, 10, "#")
    z.rect(48, 14, 2, 8, "#")
    z.rect(14, 18, 16, 1, "#"); z.rect(14, 18, 1, 12, "#")
    # Glendalough: cathedral ruins, St Kevin's church, the round tower
    z.rect(24, 22, 1, 5, "W"); z.rect(24, 22, 7, 1, "W"); z.rect(24, 26, 7, 1, "W"); z.rect(29, 24, 1, 2, "W")
    z.rect(25, 23, 5, 3, ".")
    z.building(25, 23, 4, 3, "chapel", "Cathedral Ruins")
    z.rect(30, 22, 3, 5, ":")
    z.building(34, 22, 2, 5, "stone", "Round Tower")
    z.building(37, 23, 3, 3, "chapel", "St Kevin's Church")
    z.prop("standing_stone", 26, 27, variant=0); z.prop("standing_stone", 38, 27, variant=2); z.prop("statue", 33, 27)
    z.sign(31, 20, "GLENDALOUGH. In Irish, Gleann Da Loch, 'the valley of the two lakes'. St Kevin settled here in the 6th century to be alone. A thousand monks promptly arrived to be alone near him.")
    z.sign(33, 21, "THE ROUND TOWER. About 30 m tall, with a door three metres off the ground. A bell tower and a lookout and, if the Vikings were about, a very tall panic room. The ladder came up with the monks.")
    # visitor centre and the lakes
    z.rect(16, 28, 9, 1, ":"); z.rect(19, 28, 1, 2, ":")
    z.building(16, 24, 8, 4, "white_render", "Visitor Centre", door=3)
    z.rect(34, 28, 12, 6, "w"); z.rect(35, 29, 10, 4, "~")
    z.rect(47, 24, 10, 6, "w"); z.rect(48, 25, 8, 4, "~")
    z.rect(57, 26, 1, 1, "w")
    z.sign(33, 29, "THE LOWER LAKE. Glacier-carved, 15,000 years ago, and still waiting for someone to say thank you. The sika deer often come to drink at dusk, and go through your sandwiches at dawn.")
    z.sign(46, 23, "THE UPPER LAKE. St Kevin's bed is a cave in the cliffs above it. He is said to have slept on rock, which is how you know he was a saint, or an extremely committed camper.")
    z.prop("bench", 33, 31); z.prop("bench", 46, 31); z.prop("bollard", 15, 30); z.prop("bollard", 15, 32)
    # trails, posts and a ruin in the hills
    for (x, y) in [(36, 11), (50, 13), (36, 18), (14, 20), (14, 26)]:
        z.prop("bollard", x, y)
    z.rect(52, 3, 4, 4, "R"); z.rect(53, 4, 2, 2, "k")
    z.rect(9, 8, 4, 3, "R"); z.rect(10, 9, 2, 1, "k")
    z.sign(34, 13, "THE WICKLOW WAY. 130 km of trail across the mountains, Ireland's oldest waymarked walk. The yellow walker on the posts is not a ghost. It's a signpost.")
    z.sign(12, 17, "SALLY GAP, THIS WAY. A road over the top of the mountains, famous for its views and its fog. You will see one of them.")
    scatter_props(z, "rock", 3, 3, 58, 50, 24, 5, avoid=("k", "h"))
    scatter_props(z, "bush", 3, 3, 58, 50, 14, 6, avoid=(".",))
    # sika deer and red deer on the hills
    for (sp, x, y) in [("sikawhistle", 38, 8), ("sikawhistle", 44, 34), ("sikawhistle", 20, 38), ("fawnlet", 22, 14), ("fawnlet", 42, 18), ("sikawhistle", 12, 24)]:
        creature(z, sp, x, y, "deer_%s_%d" % (sp, x), "deer")
    script("wicklow", "deer", say("Deer", "It stares at you, chewing. It has a very Wicklow look, one that says it has seen worse weather and better hikers."))
    # NPCs and trainers
    chat(z, "ranger", "hiker", 31, 18, "National Park Ranger",
         ["Wicklow Mountains National Park is the largest in Ireland, with peat bogs, heather, lakes and loads of sheep. We call this 'the Garden of Ireland'.",
          "The sika deer are from Japan, originally. A few escaped a Powerscourt estate in the 1860s, and they've been enjoying themselves ever since."], "down", "still")
    chat(z, "monk_guide", "tour_guide", 28, 27, "Monastery Guide",
         ["St Kevin founded the monastery in the 6th century. It became one of the great schools of early Ireland. Monks came from all over Europe.",
          "The Vikings raided it many times. The monks said 'ah, here we go again' and rebuilt it. That's resilience."], "left", "still")
    chat(z, "lake_watcher", "birdwatcher", 49, 22, "Bird Watcher",
         ["Red grouse, peregrines, ravens. And, once a year, a very confused kayaker.",
          "Ravens are the clever ones. I once watched one open my rucksack zip. It took my sandwich and left the banana. Serves me right."], "down", "wander")
    chat(z, "sheep_farmer", "farmer", 14, 28, "Hill Farmer",
         ["The sheep are Blackface. They're hardy, they're woolly, and they've decided the road is theirs.",
          "I let them through at the cattle grid. They look at me like I'm the one who's late."], "right", "still")
    trainer(z, "wic_hiker", "Hiker Deirdre", "Hiker", "hiker", [("tormane", 49), ("sikawhistle", 50), ("pinewraith", 49)],
            14, 31, "right", ["Ah, a fellow walker. I've done the Wicklow Way four times. The fog's the same every time. It's a very reliable fog."],
            "You've got a lovely stride. And a lovely team. I'll have a rest.", "Never trust a ridge in fog. The ridge doesn't trust you either.", 1480)
    trainer(z, "wic_warden", "Warden Cormac", "Warden", "warden_grunt", [("gealhare", 50), ("stagmor", 50), ("hushwing", 49)],
            31, 12, "up", ["Welcome to the Glendalough Heritage Experience! Monk costume hire: ten euro. Vow of silence: free."],
            "I'll have to write this up in triplicate. In silence.", "Sir Rupert says the monks were 'early adopters' of branding. He's got a very strange idea of monks.", 1520)
    trainer(z, "wic_angler", "Angler Eoin", "Angler", "angler", [("parrlet", 49), ("bradan", 50), ("stalklet", 49)],
            33, 30, "left", ["The lake's full of brown trout and quiet. I'm after the trout, and the quiet. You're not helping with either."],
            "Ah, you've given me a bite. I'll call that a catch.", "The Salmon of Knowledge, in the old story, gave wisdom to whoever ate it. I'd settle for supper.", 1500)
    trainer(z, "wic_student", "Student Aoife", "Student", "student", [("wispet", 50), ("pooka", 51), ("leveret", 49)],
            36, 17, "left", ["I'm writing up a field study on the deer. It's mostly me, a flask, and a very patient fawn."],
            "A solid result. I'll note it for peer review.", "Deer are shy, but they can smell sandwiches from a kilometre. Be warned.", 1460)
    trainer(z, "wic_singer", "Sean-nos Singer Máire", "Sean-nos Singer", "sean_nos_singer", [("bansheen", 50), ("gealhare", 51), ("cluricaun", 50)],
            30, 24, "right", ["Sean-nós is old-style singing, unaccompanied, slow and wild. I sing in the round tower. The echo does the harmony."],
            "Well sung. And well fought. Two things I rarely say together.", "Sean-nós means 'old style'. It's the oldest way of singing in Ireland, and it can raise the hairs on your neck.", 1540)
    z.d["edges"] = {"north": {"to": "dublin", "offset": 0}, "west": {"to": "kilkenny", "offset": 0}}
    z.d["spawn"] = [31, 3]
    wild(z, [("fawnlet", 49, 50, 12, {"time": ["dawn", "dusk"]}), ("stagmor", 50, 51, 6, {"time": ["dawn", "dusk"]}),
             ("leveret", 49, 50, 12, {}), ("gealhare", 50, 51, 6, {"weather": ["fog", "drizzle"]}),
             ("sikawhistle", 50, 51, 12, {}), ("pooka", 50, 51, 8, {"time": ["night"]}), ("tormane", 49, 51, 10, {}),
             ("hazeldoze", 49, 50, 10, {}), ("pinewraith", 50, 51, 8, {"time": ["dusk", "night"]}), ("wispet", 50, 51, 5, {"weather": ["fog"]}),
             ("hushwing", 50, 51, 8, {"time": ["night"]}), ("polartern", 50, 51, 5, {"weather": ["frost", "gale"]})])
    wild(z, [("parrlet", 49, 50, 25, {}), ("bradan", 50, 51, 15, {"weather": ["drizzle", "downpour"]}), ("stalklet", 49, 50, 20, {}),
             ("dipling", 49, 51, 20, {}), ("rillotter", 49, 51, 15, {}), ("minkshade", 50, 51, 10, {"time": ["night"]})], "water")
    z.save(OUT + "/wicklow.json")


def kilkenny(OUT):
    W, H = 60, 46
    z = Z("kilkenny", "Kilkenny", W, H, kind="town", region="ireland", music="town_ireland",
          weather={"drizzle": 28, "clear": 22, "sunshine": 18, "fog": 10, "downpour": 12, "gale": 10})
    z.d["stage"] = "castle"; z.d["town_id"] = "kilkenny"
    z.border("T", 2, gaps=[(58, 30, 2, 3), (26, 44, 3, 2)])
    z.scatter(0, 0, W, H, "P", 24, 2, only="T")
    # the River Nore, on the west edge
    z.rect(2, 0, 5, H, "~"); z.rect(7, 2, 1, H - 4, "s")
    z.prop("buoy", 4, 10); z.prop("boat", 4, 30, variant=1)
    # the Medieval Mile: a cobbled street from the castle to the cathedral
    z.rect(8, 21, 44, 3, ":"); z.rect(8, 20, 44, 1, ":")
    z.rect(26, 24, 3, 20, "#"); z.rect(26, 24, 3, 6, ":")
    z.rect(29, 30, 31, 3, "#")
    for x in (12, 20, 30, 38, 46):
        z.prop("lamp_post", x, 24)
    for x in (16, 24, 34, 42):
        z.prop("lamp_post", x, 20)
    z.prop("bench", 32, 24); z.prop("post_box", 18, 24); z.prop("phone_box", 44, 24)
    z.sign(9, 22, "THE MEDIEVAL MILE. A kilometre of cobbles between the castle at one end and St Canice's Cathedral at the other. In the 1300s it was the busiest street in Ireland. Now it sells sweaters.")
    # Kilkenny Castle and its park
    z.height(8, 3, 36, 8, 1)
    z.rect(8, 3, 36, 8, ".")
    z.rect(8, 11, 36, 1, "W"); z.rect(14, 11, 6, 1, ":"); z.rect(8, 3, 1, 9, "W")
    z.height(14, 11, 6, 1, 0)
    z.rect(14, 12, 6, 8, ":")
    z.building(13, 4, 11, 6, "castle", "Kilkenny Castle")
    z.building(9, 5, 4, 5, "castle", show_label=False)
    z.building(24, 5, 4, 5, "castle", show_label=False)
    z.rect(17, 10, 3, 1, ":"); z.rect(17, 10, 3, 1, ":")
    z.rect(28, 4, 15, 6, "f"); z.rect(30, 6, 11, 2, ",")
    z.rect(35, 11, 3, 1, ":")
    z.rect(35, 12, 3, 8, ":")
    z.prop("statue", 32, 8); z.prop("bench", 35, 5); z.prop("bench", 40, 8); z.prop("lamp_post", 28, 11); z.prop("lamp_post", 43, 11)
    z.rect(9, 11, 3, 9, ".")
    z.sign(16, 12, "KILKENNY CASTLE. Built by the Normans in 1195, home to the Butler family for nearly 600 years, and rebuilt in the 1800s with some grand ideas. The long gallery has 22 paintings of Butlers looking smug. The park has none.")
    z.sign(36, 12, "THE ROSE GARDEN. Kilkenny's castle park is a lovely place to sit. The Butlers had gardeners for it. You have a bench.")
    # north side: Sanctuary, shop, tudor houses, then St Canice's
    z.building(20, 16, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.building(27, 16, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(23, 19, "kilkenny_sanctuary", 5, 6, "up"); z.warp(29, 19, "kilkenny_shop", 4, 5, "up")
    z.building(8, 15, 5, 5, "terrace", "Tourist Office")
    z.building(33, 15, 8, 5, "tudor", "Rothe House")
    z.building(42, 15, 5, 5, "red_brick", "Kyteler's Inn")
    z.building(46, 3, 12, 10, "cathedral", "St Canice's Cathedral")
    z.building(41, 4, 2, 7, "stone", "Round Tower")
    z.rect(47, 13, 4, 7, ":"); z.rect(48, 14, 1, 6, ":")
    z.sign(48, 20, "ST CANICE'S. A 13th-century cathedral with a 9th-century round tower beside it. If you climb the tower's 121 steps you can see five counties. If you stay up there you can see six.")
    z.sign(40, 20, "ROTHE HOUSE. A Tudor merchant's home from 1594, with three courtyards, a hidden garden and very proud beams.")
    z.sign(45, 20, "KYTELER'S INN. Named for Dame Alice Kyteler, who was accused of witchcraft in 1324. She left town in a hurry. Her maid wasn't so lucky. The pub is now much nicer than the history.")
    # south side: shops, the Tholsel, the station
    z.building(9, 25, 7, 4, "cream_render", "The Tholsel")
    z.building(18, 25, 7, 4, "slate_cottage", "Butter Slip Cafe")
    z.building(30, 25, 6, 4, "terrace", "Craft Shop")
    z.building(37, 25, 7, 4, "red_brick", "Hurling Museum")
    z.building(46, 25, 7, 4, "terrace", show_label=False)
    z.rect(8, 29, 45, 1, ":")
    z.rect(25, 24, 1, 6, ":"); z.rect(29, 24, 1, 6, ":")
    z.rect(16, 25, 2, 4, ":"); z.rect(44, 25, 2, 4, ":")
    z.sign(17, 29, "THE BUTTER SLIP. A narrow medieval passage down from the High Street, where butter was sold, and slipped about. Please don't slip.")
    station(z, 34, 34, 9, 4, "Kilkenny Station")
    z.rect(33, 33, 1, 5, "#"); z.rect(43, 33, 1, 5, "#")
    z.rect(30, 33, 14, 1, ":")
    z.prop("bench", 36, 36); z.prop("lamp_post", 41, 36)
    rail_guard(z, 40, 36, ["Kilkenny Station. Trains for every Irish station you've visited. A nice station, with a nice view of a car park.",
                           "Hop aboard. The Wildlore rail runs to any town you have visited on this island. Where to?"])
    z.rect(30, 38, 12, 5, ","); z.rect(8, 33, 14, 9, ","); z.rect(44, 38, 12, 4, ",")
    z.rect(10, 35, 3, 4, "."); z.rect(16, 38, 4, 3, ".")
    scatter_props(z, "oak", 8, 3, 50, 40, 10, 6, avoid=(".",))
    scatter_props(z, "bush", 8, 33, 50, 10, 10, 5, avoid=(".",))
    # NPCs and story
    z.npc(id="kerrigan", sprite="kerrigan", x=17, y=14, facing="down", move="still", script="kerrigan_kilkenny")
    script("kilkenny", "kerrigan_kilkenny", say("Director Kerrigan", "Placeholder: the story agent writes Kerrigan's first battle here."))
    chat(z, "castle_guide3", "tour_guide", 19, 12, "Castle Guide",
         ["Kilkenny's 'marble city' name comes from the black limestone that's cut and polished in the quarries nearby. The pavement's the proof.",
          "The castle's been rebuilt a few times. The ghost on the stairs, I'm told, stays out of all the fights."], "down", "still")
    chat(z, "cat_fan", "rugby_player", 22, 22, "Hurling Fan",
         ["Kilkenny hurling team is called 'the Cats', and they play in black and amber stripes. We've won more All-Irelands than anybody.",
          "If you see a cat statue, salute. If you see a cat in a Dublin jersey, move along."], "right", "wander")
    chat(z, "pub_singer", "villager_5", 44, 22, "Local",
         ["The Medieval Mile's a good walk. Every shop has a long story, and a longer queue.",
          "Mind the Butter Slip. The name's a very honest warning."], "left", "wander")
    chat(z, "marble_worker", "farmer", 12, 31, "Stone Cutter",
         ["Kilkenny limestone is dark, hard and full of fossils. It polishes up black as ink. We call it 'marble', and nobody argues.",
          "Look closely at the pavement. There are shells in it, 340 million years old. Walk over them gently."], "right", "still")
    trainer(z, "kk_hurler", "Hurler Tadhg", "Hurler", "hurler", [("dextera", 51), ("raidtail", 51), ("moolet", 50)],
            37, 22, "left", ["Black and amber, born and bred! I've a hurley in the boot of the car, and a point to prove."],
            "A great puck! The Cats salute you.", "Hurling's older than the Normans. Same stick, bigger ball, smaller helmets.", 1560)
    trainer(z, "kk_fiddler", "Fiddler Róisín", "Fiddler", "fiddler", [("rookery", 51), ("cluricaun", 51), ("gealhare", 51)],
            14, 17, "down", ["I'll play you a jig, and you can pay me in biscuits. Or a battle. I'm flexible."],
            "I'm out of tune with that result. But well played.", "A fiddle is a violin that's learned to enjoy itself.", 1540)
    z.d["edges"] = {"east": {"to": "wicklow", "offset": 0}, "south": {"to": "comeraghs", "offset": 0}}
    z.d["spawn"] = [27, 22]
    wild(z, [("leveret", 50, 51, 12, {}), ("moolet", 50, 51, 12, {}), ("rooklet", 50, 51, 14, {"time": ["day", "dawn", "dusk"]}),
             ("rookery", 51, 52, 6, {"time": ["dusk", "night"]}), ("dextera", 51, 52, 5, {}), ("gealhare", 51, 52, 5, {"weather": ["fog", "drizzle"]}),
             ("strutcoo", 50, 51, 8, {"time": ["day"]}), ("binfox", 51, 52, 6, {"time": ["night"]}), ("hushwing", 51, 52, 6, {"time": ["night"]}),
             ("raidtail", 50, 51, 8, {}), ("chipgull", 50, 51, 8, {"time": ["day"]}), ("barnling", 50, 51, 6, {"time": ["dusk"]})])
    wild(z, [("stalklet", 50, 51, 20, {}), ("bradan", 51, 52, 15, {}), ("rillotter", 50, 51, 20, {}), ("pierlord", 50, 51, 15, {})], "water")
    z.save(OUT + "/kilkenny.json")
    sanctuary(OUT, "kilkenny", "Kilkenny", (23, 20))
    shop(OUT, "kilkenny", "Kilkenny", (29, 20))
    nurse("kilkenny", ["Welcome to the Kilkenny Sanctuary. Fáilte, that's welcome. Pop your team on the counter, and don't sit on the cat.",
                       "Right, let's have a look. Sit by the fire, and have a biscuit. They're good for morale and crumbs.",
                       "All set. Slán, that's goodbye. And mind the cobbles, they're a thousand years old and still tripping people.",
                       "The Ark terminal. It runs on turf, tea, and some very solid Kilkenny limestone.",
                       "Sure look. You know where we are if you need us."])
    shopkeeper("kilkenny", "Fáilte! Snares, soda bread and a hurley that nobody's claimed since 1998.",
               "Slán agus beannacht! That's 'goodbye and blessings'. Mind the cats, they run the place.")


def comeraghs(OUT):
    W, H = 54, 58
    z = Z("comeraghs", "The Comeraghs", W, H, kind="route", region="ireland", music="route_ireland",
          weather={"fog": 26, "drizzle": 26, "clear": 14, "downpour": 12, "gale": 10, "frost": 8, "sunshine": 4})
    z.d["stage"] = "mountain"
    z.legend["h"] = {"tile": "tall_grass", "colour": "#7a5c6a", "prop": "heather"}
    z.legend["k"] = {"tile": "grass", "colour": "#8a8a4d"}
    hills(z, [(8, 8, 3), (46, 14, 4), (8, 46, 3)], sc=2.4)
    z.border("R", 2, gaps=[(26, 0, 3, 2), (0, 24, 2, 3)])
    z.scatter(0, 0, W, H, "P", 40, 2, only="R")
    z.rect(2, 2, W - 4, H - 4, "k")
    for (x, y, w, h) in [(3, 3, 12, 9), (38, 4, 12, 10), (3, 40, 12, 12), (32, 20, 8, 5), (10, 14, 8, 5), (40, 28, 8, 6)]:
        z.rect(x, y, w, h, "h")
    # the paths: north gap to the junction, west gap, the track down to the corrie
    z.rect(26, 0, 3, 28, "#"); z.rect(0, 24, 29, 3, "#")
    z.rect(26, 27, 3, 12, "#")
    z.rect(29, 14, 12, 1, "#"); z.rect(40, 14, 1, 10, "#")
    # drystone walls round a sheepfold and a mountain bothy
    for (x, y, w, h) in [(10, 28, 10, 7), (32, 6, 8, 6)]:
        z.rect(x, y, w, 1, "W"); z.rect(x, y + h - 1, w, 1, "W"); z.rect(x, y, 1, h, "W"); z.rect(x + w - 1, y, 1, h, "W")
    z.rect(14, 28, 2, 1, "k"); z.rect(10, 31, 1, 2, "k"); z.rect(35, 11, 2, 1, "k"); z.rect(39, 8, 1, 2, "k")
    z.building(12, 20, 5, 4, "slate_cottage", "Mountain Bothy")
    z.rect(11, 24, 7, 1, ":"); z.rect(14, 24, 1, 1, ":")
    # the corrie: a glacial bowl with a lake, walled by cliffs
    z.rect(32, 36, 16, 18, ".")
    z.rect(30, 36, 2, 18, "^"); z.rect(30, 52, 18, 3, "^"); z.rect(46, 36, 3, 18, "^")
    z.rect(30, 36, 18, 2, "^")
    z.rect(30, 38, 2, 3, "k")
    z.rect(32, 38, 14, 14, "k")
    z.rect(34, 42, 10, 7, "w"); z.rect(35, 43, 8, 5, "~")
    z.rect(35, 40, 8, 1, "h")
    z.rect(34, 50, 10, 1, ","); z.rect(32, 46, 2, 3, ","); z.rect(44, 46, 2, 3, ",")
    z.rect(29, 38, 3, 3, "#")
    z.rect(28, 38, 3, 3, "#")
    z.prop("rock", 33, 40); z.prop("rock", 44, 41); z.prop("rock", 33, 50); z.prop("rock", 45, 50)
    z.sign(32, 41, "COUMSHINGAUN. A glacial corrie, a deep armchair of rock scooped out by ice, with a lake at the bottom. In Irish, Com Seangan, 'hollow of the ants'. The ants are long gone, but the view is not.")
    z.sign(27, 40, "THE CORRIE WALK. Steep, wet, and spectacular. Don't go up in fog. The cliffs don't announce themselves.")
    # a waterfall: Mahon Falls
    z.rect(44, 21, 3, 5, "R"); z.rect(45, 21, 1, 5, "~")
    z.sign(42, 24, "MAHON FALLS. An 80 m cascade down the mountainside, which after rain looks like the mountain has had a good cry. On a dry day it's a sulk.")
    scatter_props(z, "rock", 3, 3, 48, 50, 34, 6, avoid=("k", "h"))
    scatter_props(z, "bush", 3, 3, 48, 50, 14, 7, avoid=("k",))
    z.prop("standing_stone", 20, 12, variant=1); z.prop("standing_stone", 21, 14, variant=2)
    z.sign(22, 13, "A STANDING STONE. The Comeraghs are full of old stones, tombs and field walls. Some of the walls were built last week. It's hard to tell.")
    # sheep, as is only right
    for (x, y) in [(8, 20), (12, 33), (36, 8), (20, 30), (34, 18), (6, 30), (44, 32), (22, 6)]:
        creature(z, "loaghtan", x, y, "sheep_%d_%d" % (x, y), "sheep")
    script("comeraghs", "sheep", say("Sheep", "It looks at you with one sideways eye. Then it looks at your lunch. Then it looks pointedly at the exit."))
    # NPCs and trainers
    chat(z, "mountain_farmer", "farmer", 28, 8, "Hill Farmer",
         ["The Comeraghs are all sheep country. We bring them down for the winter. They bring themselves back up for the summer, and the view.",
          "The mountains here are old red sandstone, laid down 370 million years ago. The sheep, I'm told, are slightly younger."], "left", "still")
    chat(z, "geologist", "student", 33, 37, "Geology Student",
         ["Ice scooped out the corrie. It's a bowl cut into the mountain, with a steep backwall and a lip of rock at the front, where the lake sits.",
          "Corries are called cwms in Wales and cirques in France. In Ireland, we call it a very good spot for a flask."], "right", "wander")
    chat(z, "bothy_walker", "hiker", 15, 25, "Bothy Walker",
         ["A bothy is a basic mountain hut that anyone can shelter in. You leave it tidy, and leave a bit of kindling for the next person.",
          "The Comeragh Mountains are best seen on a clear day. I've seen five of those. Four were in my imagination."], "down", "still")
    chat(z, "pooka_teller", "villager_4", 24, 14, "Old Storyteller",
         ["There's a púca in these hills, they say. A shape-shifter. It might be a horse, a hare, or a very black goat. It'll offer you a lift.",
          "I wouldn't take it. But I wouldn't be rude to it either. The púca's never done me any harm, and I've been polite for seventy years."], "right", "still")
    trainer(z, "com_hiker", "Hiker Fionnuala", "Hiker", "hiker", [("tormane", 51), ("brockmoor", 52), ("sikawhistle", 52)],
            27, 12, "down", ["I'm doing the Comeragh Mountain Challenge! It's not a race. It's a long walk, with people shouting 'well done' at me."],
            "Well done! That's what they say, right? Well done.", "The ridge walk takes seven hours. The tea at the end takes seven minutes.", 1620)
    trainer(z, "com_student", "Student Brendan", "Student", "student", [("gritling", 51), ("billgruff", 52), ("wispet", 51)],
            36, 40, "down", ["My thesis is on glaciation. I've got a slide of this very corrie. I'd like to present it to you, with notes."],
            "Fair enough. I'll put 'defeated' in the discussion section.", "A corrie is a glacier's armchair. Don't sit in it. It's still cold.", 1580)
    trainer(z, "com_warden", "Warden Declan", "Warden", "warden_grunt", [("gealhare", 52), ("pooka", 52), ("hushwing", 52)],
            28, 20, "left", ["Welcome to the Comeragh Heritage Experience! Hard hat: free. Stunning view: extra. Tunnelling: pending."],
            "I'm to say it was a 'learning opportunity'. I did not enjoy learning it.", "Sir Rupert says a gift shop at the corrie would 'elevate the experience'. It's already elevated. It's a mountain.", 1640)
    trainer(z, "com_singer", "Sean-nos Singer Pádraig", "Sean-nos Singer", "sean_nos_singer", [("bansheen", 52), ("pooka", 53), ("merrow", 52)],
            9, 25, "right", ["I sing on the mountain, for the sheep. They've never once told me to stop. It's the best audience in Ireland."],
            "A wonderful performance. And a wonderful lesson.", "The old songs belong to the mountains. I'm just minding them.", 1660)
    z.d["edges"] = {"north": {"to": "kilkenny", "offset": 0}, "west": {"to": "cork", "offset": 0}}
    z.d["spawn"] = [27, 3]
    wild(z, [("pooka", 51, 53, 12, {"time": ["night"]}), ("gealhare", 51, 52, 8, {"weather": ["fog", "drizzle"]}), ("loaghtan", 51, 52, 12, {}),
             ("tormane", 51, 52, 10, {}), ("brockmoor", 52, 53, 8, {}), ("billgruff", 52, 53, 6, {"time": ["day", "dusk"]}),
             ("sikawhistle", 51, 53, 10, {}), ("wispet", 51, 52, 6, {"weather": ["fog"]}), ("hushwing", 52, 53, 8, {"time": ["night"]}),
             ("snowhare", 52, 53, 6, {"weather": ["frost"]}), ("polartern", 52, 53, 5, {"weather": ["gale", "frost"]}),
             ("gritling", 51, 52, 8, {}), ("leveret", 51, 52, 8, {"time": ["dawn", "day"]})])
    wild(z, [("bradan", 52, 53, 20, {}), ("parrlet", 51, 52, 20, {}), ("heronarch", 52, 53, 15, {}), ("dipling", 51, 53, 20, {}), ("rillotter", 51, 52, 15, {})], "water")
    z.save(OUT + "/comeraghs.json")


def cork(OUT):
    W, H = 66, 52
    z = Z("cork", "Cork", W, H, kind="town", region="ireland", music="town_ireland",
          weather={"drizzle": 34, "clear": 18, "downpour": 14, "sunshine": 14, "fog": 10, "gale": 10})
    z.d["stage"] = "city"; z.d["town_id"] = "cork"
    z.border("T", 2, gaps=[(0, 20, 2, 3), (64, 24, 2, 3)])
    z.scatter(0, 0, W, H, "P", 30, 2, only="T")
    # the Lee splits round the city centre: two channels, an island between them
    z.rect(2, 15, 62, 3, "~"); z.rect(2, 34, 62, 3, "~")
    z.rect(0, 15, 2, 3, "~"); z.rect(64, 15, 2, 3, "~"); z.rect(0, 34, 2, 3, "~"); z.rect(64, 34, 2, 3, "~")
    # Shandon hill, north bank
    for y in range(H):
        for x in range(W):
            z.hg[y][x] = max(0, 3 - int(math.hypot(x - 20, y - 6) / 3.0)) if y < 14 else 0
    # bridges and the main streets
    for bx in (30, 52, 12):
        z.rect(bx, 15, 3, 3, "=")
        z.rect(bx - 1, 15, 1, 3, "W"); z.rect(bx + 3, 15, 1, 3, "W")
    for bx in (30, 14):
        z.rect(bx, 34, 3, 3, "=")
        z.rect(bx - 1, 34, 1, 3, "W"); z.rect(bx + 3, 34, 1, 3, "W")
    z.rect(30, 0, 3, 15, "="); z.rect(30, 37, 3, 15, "=")
    z.rect(30, 18, 3, 16, "=")
    z.rect(2, 24, 62, 3, "="); z.rect(2, 23, 62, 1, ":"); z.rect(2, 27, 62, 1, ":")
    z.rect(0, 20, 30, 3, ":")
    z.rect(12, 0, 3, 15, ":"); z.rect(52, 0, 3, 15, ":")
    z.rect(12, 18, 3, 16, ":"); z.rect(52, 18, 3, 6, ":")
    z.rect(14, 37, 3, 8, ":")
    for x in (6, 18, 26, 36, 44, 58):
        z.prop("lamp_post", x, 23)
    for x in (10, 22, 40, 48, 56):
        z.prop("lamp_post", x, 27)
    z.prop("phone_box", 20, 27); z.prop("post_box", 8, 23); z.prop("bench", 28, 27); z.prop("bench", 35, 23)
    # Shandon: the bells and the four-faced liar
    z.rect(18, 2, 14, 12, ".")
    z.building(21, 4, 6, 5, "chapel", "St Anne's Shandon")
    z.rect(22, 9, 3, 6, ":"); z.rect(23, 9, 1, 5, ":")
    z.building(8, 4, 8, 5, "red_brick", "The Butter Exchange")
    z.building(34, 4, 6, 5, "terrace", show_label=False)
    z.building(41, 4, 8, 5, "slate_cottage", "Páirc Café")
    z.rect(8, 9, 40, 1, ":")
    z.rect(34, 9, 15, 1, ":")
    z.rect(30, 9, 3, 1, ":")
    z.rect(26, 9, 4, 1, ":")
    z.prop("bench", 20, 9); z.prop("planter", 28, 9); z.prop("lamp_post", 26, 10)
    z.sign(25, 10, "SHANDON BELLS. The tower of St Anne's has eight bells you can ring yourself, and a clock with four faces that for years each told a different time. Corkonians call it 'the four-faced liar'. They say it with love.")
    z.rect(20, 11, 10, 3, ",")
    # Kent Station, north bank east
    z.rect(34, 10, 20, 4, ":")
    station(z, 38, 11, 9, 4, "Kent Station")
    z.rect(34, 13, 4, 1, ":"); z.rect(47, 13, 4, 1, ":")
    # ... station rail takes row 14; the quay is the channel's north bank at row 14
    z.prop("bench", 40, 13); z.prop("lamp_post", 45, 13)
    rail_guard(z, 44, 13, ["Kent Station. Trains to every Irish station you have visited. Cork people call themselves the real capital. The trains, with a straight face, go along with it.",
                           "Hop aboard. The Wildlore rail runs to any town you have visited on this island. Where to?"])
    # the island: Sanctuary, Corner Shop, the English Market, Grand Parade
    z.building(6, 28, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.building(13, 28, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(9, 31, "cork_sanctuary", 5, 6, "up"); z.warp(15, 31, "cork_shop", 4, 5, "up")
    z.rect(4, 32, 20, 1, ":")
    z.building(20, 28, 7, 4, "terrace", "Patrick Street Shops")
    z.building(34, 28, 12, 4, "cream_render", "The English Market")
    z.rect(34, 32, 12, 1, ":")
    for x in range(35, 46, 2):
        z.prop("market_stall", x, 27, variant=(x // 2) % 3)
    z.building(48, 28, 8, 4, "red_brick", "The Oliver Plunkett Pub")
    z.building(58, 28, 5, 4, "terrace", show_label=False)
    z.rect(48, 32, 15, 1, ":")
    z.building(5, 18, 6, 4, "stone", "City Hall")
    z.building(16, 19, 7, 3, "red_brick", "Opera Lane Books")
    z.building(34, 19, 8, 4, "white_render", "Grand Parade Cafe")
    z.building(44, 19, 6, 4, "terrace", show_label=False)
    z.rect(5, 22, 6, 1, ":"); z.rect(16, 22, 7, 1, ":"); z.rect(34, 23, 8, 1, ":"); z.rect(44, 23, 6, 1, ":")
    z.prop("statue", 33, 20); z.prop("bench", 28, 20); z.prop("planter", 28, 22)
    z.sign(34, 27, "THE ENGLISH MARKET. A covered market since 1788, with fish, fruit, spices and the best tripe in Ireland, if you like that sort of thing. Queen Elizabeth II stopped to chat to a fishmonger here in 2011, and the fish said nothing.")
    z.sign(11, 22, "CORK. In Irish, Corcaigh, 'the marsh'. The city is built on an island in the River Lee. Corkonians say Cork is the real capital of Ireland, and have said so since 1920 at least.")
    z.sign(13, 38, "THE LEE. It splits in two to flow round the city, then joins up again to head for Cork Harbour. It's the sort of river that's a bit of a tease.")
    # south bank: St Fin Barre's, lawns, the quays
    z.rect(2, 37, 62, 1, ":")
    z.building(16, 39, 14, 9, "cathedral", "St Fin Barre's Cathedral")
    z.rect(16, 48, 14, 1, ":")
    z.rect(34, 38, 28, 10, ".")
    z.rect(36, 40, 10, 6, ","); z.rect(50, 41, 10, 5, ","); z.rect(3, 40, 10, 8, ",")
    z.rect(34, 38, 28, 1, ":")
    z.rect(30, 37, 3, 15, "=")
    z.sign(33, 38, "ST FIN BARRE'S. A neo-Gothic cathedral from 1879 with three spires, a golden angel and plenty of stone beasts on the roof. It stands on the spot where the city's patron saint founded a monastery in the 7th century. Fin Barre, naturally, would have preferred something cosier.")
    z.prop("bench", 40, 39); z.prop("bench", 56, 39); z.prop("lamp_post", 34, 42); z.prop("lamp_post", 60, 42)
    z.prop("boat", 38, 35, variant=1); z.prop("buoy", 46, 35); z.prop("boat", 58, 16, variant=1)
    scatter_props(z, "oak", 3, 38, 58, 12, 12, 6, avoid=(".",))
    scatter_props(z, "bush", 3, 38, 58, 12, 10, 7, avoid=(".",))
    scatter_props(z, "oak", 3, 3, 15, 10, 4, 8, avoid=(".",))
    # NPCs
    chat(z, "market_fishmonger", "shopkeeper", 41, 26, "Fishmonger",
         ["Fresh off the boat this morning. Which boat? The boat. Don't ask for details, it's a trade secret.",
          "The English Market's got a fountain with fish in it. That's the only place in the building where the fish are free."], "down", "still")
    chat(z, "bell_ringer", "tour_guide", 24, 12, "Bell Ringer",
         ["You can ring the Shandon bells yourself. There's a tune sheet, and a lot of enthusiasm. The tune will be recognisable. Possibly.",
          "There's a golden salmon on top of the tower, as the weathervane. Cork's had a long relationship with fish."], "down", "still")
    chat(z, "rebel_local", "villager_5", 34, 25, "Local",
         ["We call ourselves 'Rebels', in Cork. It's the Rebel County. It's not a very dangerous thing. Mostly we rebel against other counties' accents.",
          "Cork has its own sing-song accent, its own words, and a lot of pride in both. It's very affectionate. You'll find yourself copying it by teatime."], "down", "wander")
    chat(z, "lee_swimmer", "villager_1", 28, 33, "Lee Walker",
         ["The Lee runs both sides of the city, and the people go on both. It's quite the commute. Mind the swans, they know where the bread is.",
          "Cork Harbour, at the end of the river, is one of the biggest natural harbours in the world. A sailor's dream. A swimmer's disagreement."], "down", "wander")
    chat(z, "kent_stationman", "student", 49, 12, "Train Spotter",
         ["Kent Station's named for Thomas Kent, a Cork man executed after the 1916 Rising. It used to be called Glanmire Road. People still call it that, to be safe.",
          "I'm collecting every train that comes through. So far it's been thirteen. I'm told that's a low number for a day."], "left", "still")
    trainer(z, "cork_hurler", "Hurler Eoghan", "Hurler", "hurler", [("dextera", 53), ("stagmor", 53), ("raidtail", 53)],
            45, 25, "left", ["Rebel hurler, here! Red jersey, blue sky, sore knees. Come on, now."],
            "Good puck. A nice one. We'll say no more about it.", "I've the red of Cork in my blood, and half of it's tomato soup.", 1760)
    trainer(z, "cork_singer", "Sean-nos Singer Éilis", "Sean-nos Singer", "sean_nos_singer", [("bansheen", 53), ("merrow", 53), ("cluricaun", 53)],
            24, 11, "down", ["I sing at Shandon. It's the best acoustic in town. It's also the only one with a bell."],
            "Beautifully done. I'll sing a little lament, and then a little celebration.", "You can hear a song in the wind off the Lee. If it's not a song, it's a seagull.", 1780)
    trainer(z, "cork_student", "Student Colm", "Student", "student", [("hushwing", 53), ("rookery", 53), ("cluricaun", 53)],
            34, 26, "up", ["I'm doing a project on the English Market. The kids call it 'the smelly bit'. I call it 'primary research'."],
            "Hm. A strong conclusion. I'm adding you to the bibliography.", "Always buy the fish on a Friday. Ask for the one that's still looking at you.", 1740)
    trainer(z, "cork_angler", "Angler Pádraig", "Angler", "angler", [("bradan", 53), ("pierlord", 53), ("heronarch", 53)],
            40, 38, "left", ["Salmon! In the middle of Cork city! You'd not believe it. And neither would the salmon."],
            "Right, you caught me out. I'll bait my hook with humility.", "The Lee's one of the best salmon rivers in the south. Fish at dawn, argue at dusk.", 1720)
    z.d["edges"] = {"east": {"to": "comeraghs", "offset": 0}, "west": {"to": "ring_of_kerry", "offset": 0}}
    z.d["spawn"] = [31, 25]
    wild(z, [("cluricaun", 53, 54, 12, {"time": ["dusk", "night"]}), ("barnling", 53, 54, 8, {"time": ["dusk", "night"]}),
             ("rooklet", 53, 54, 12, {"time": ["day", "dawn"]}), ("rookery", 53, 55, 8, {"time": ["dusk", "night"]}),
             ("raidtail", 53, 54, 10, {}), ("binfox", 53, 54, 8, {"time": ["night"]}), ("strutcoo", 53, 54, 10, {"time": ["day"]}),
             ("chipgull", 53, 54, 12, {"time": ["day"]}), ("pierlord", 53, 55, 8, {"weather": ["drizzle", "downpour"]}),
             ("hushwing", 53, 55, 8, {"time": ["night"]}), ("flittermouse", 54, 55, 6, {"time": ["night"]}),
             ("sootwing", 53, 54, 6, {"weather": ["fog", "drizzle"]})])
    wild(z, [("bradan", 53, 55, 25, {}), ("pierlord", 53, 54, 20, {}), ("dipling", 53, 54, 20, {}), ("heronarch", 53, 55, 15, {}),
             ("stalklet", 53, 54, 10, {})], "water")
    z.save(OUT + "/cork.json")
    sanctuary(OUT, "cork", "Cork", (9, 32))
    shop(OUT, "cork", "Cork", (15, 32))
    nurse("cork", ["Welcome to the Cork Sanctuary. Fáilte, and sit down. Pop your team on the counter. And no, we're not Dublin.",
                   "Right so. Have a look at the state of them. I'll have them fixed in the time it takes to say 'Rebel County'.",
                   "All set. Go and see the market, and mind the Shandon bells, they're loud at noon.",
                   "The Ark terminal. It's the only thing in Cork that's quiet. Take advantage of it.",
                   "No bother. The kettle's on, and the door's open."])
    shopkeeper("cork", "Fáilte! Snares, soda bread and Cork's finest butter, and I'll thank you not to ask about Kerry.",
               "Slán! Mind the hills, they're steeper than they look. Like the prices.")
