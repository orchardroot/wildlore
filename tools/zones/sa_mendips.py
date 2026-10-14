# mendips (route) + wookey_hole (gated cave), glastonbury (town) + glastonbury_tor (Keeper arena and orchard),
# Glastonbury Sanctuary and Corner Shop.
from wcommon import *
import math


def build(OUT):
    mendips(OUT)
    wookey(OUT)
    glastonbury(OUT)
    tor(OUT)


def mendips(OUT):
    W, H = 72, 44
    z = Z("mendips", "Mendip Hills", W, H, kind="route", region="south_england", music="route_mountain",
          weather={"clear": 28, "sunshine": 14, "drizzle": 24, "fog": 14, "gale": 12, "downpour": 8})
    z.d["stage"] = "mountain"

    def hp(y):
        if y <= 18:
            return min(6, (19 - y + 1) // 2)
        if y >= 24:
            return min(6, (y - 23 + 1) // 2)
        return 0

    def wx(x):
        if 24 <= x <= 48:
            return 6
        return max(0, 6 - (24 - x) // 2) if x < 24 else max(0, 6 - (x - 48) // 2)

    for y in range(H):
        for x in range(W):
            z.hg[y][x] = min(hp(y), wx(x))
    z.border("T", 2, gaps=[(0, 20, 2, 3), (70, 20, 2, 3)])
    z.scatter(0, 0, W, H, "P", 40, 2, only="T")
    z.rect(0, 20, W, 3, "=")
    # Cheddar Gorge: limestone cliffs both sides of the road
    z.rect(27, 15, 21, 4, "^"); z.rect(27, 24, 21, 4, "^")
    z.rect(26, 17, 1, 2, "R"); z.rect(48, 17, 1, 2, "R"); z.rect(26, 24, 1, 2, "R"); z.rect(48, 24, 1, 2, "R")
    r = random.Random(11)
    for x in range(27, 48):
        if r.random() < 0.3:
            z.set(x, 18, "R"); z.set(x, 24, "R")
    for y in (15, 16, 17, 18):
        z.set(37, y, "#")
    for y in (24, 25, 26, 27):
        z.set(41, y, "#")
    z.set(37, 19, "#"); z.set(41, 23, "#")
    # cave mouths (void) in the cliff foot
    for (x, y) in [(31, 18), (31, 17), (44, 24), (44, 25), (33, 18), (33, 17)]:
        z.set(x, y, "x")
    for (x, y) in [(30, 19), (34, 19), (43, 23), (45, 23)]:
        z.prop("rock", x, y, variant=(x + y) % 3)
    z.sign(32, 19, "COX'S CAVE AND GOUGH'S CAVE. Stalactites, a very chilly 11 degrees, and the 10,000-year-old Cheddar Man. Mind your head. The roof is older than your gran.")
    z.sign(36, 19, "CHEDDAR GORGE. Britain's biggest gorge, cliffs up to 137 m. Jacob's Ladder climbs it in 274 steps. The view at the top is free. The wheeze is extra.")
    # top plateau: grass, bracken, rocks, the lookout
    z.rect(30, 2, 16, 11, ".")
    z.rect(28, 3, 4, 5, ","); z.rect(41, 4, 5, 6, ","); z.rect(33, 10, 7, 3, ","); z.rect(28, 28, 4, 4, ","); z.rect(44, 29, 6, 5, ",")
    z.rect(36, 5, 3, 3, "f")
    z.prop("bench", 37, 5); z.prop("statue", 38, 6); z.prop("bench", 36, 8)
    z.sign(37, 9, "THE TOP OF THE GORGE. Peregrine falcons nest on these cliffs, and feral goats graze them. The goats are not impressed by you. The peregrines are.")
    z.sign(42, 29, "THE STRAWBERRY LINE. The old railway carried Cheddar strawberries to the cities. The trains are gone. The strawberries are not.")
    scatter_props(z, "rock", 28, 2, 20, 12, 12, 3, avoid=(".", ","))
    scatter_props(z, "rock", 28, 28, 20, 13, 14, 4, avoid=(".", ","))
    scatter_props(z, "bush", 26, 2, 22, 13, 8, 5, avoid=(".",))
    scatter_props(z, "bush", 26, 28, 22, 13, 8, 6, avoid=(".",))
    # west: Cheddar village (flat ground) with its cheese company
    z.building(4, 14, 7, 4, "white_render", "Cheddar Cheese Company")
    z.building(4, 25, 5, 4, "stone", "Gorge Cafe"); z.building(10, 25, 5, 4, "cream_render", "Cave Tours")
    z.rect(4, 18, 7, 1, ":"); z.rect(4, 19, 12, 1, ":"); z.rect(4, 23, 12, 1, ":")
    z.prop("lamp_post", 5, 19); z.prop("lamp_post", 12, 19); z.prop("bench", 8, 23); z.prop("post_box", 3, 23)
    z.prop("planter", 6, 18); z.prop("planter", 9, 18)
    z.sign(3, 19, "CHEDDAR. The cheese is named after this village. West Country Farmhouse Cheddar was once matured in these caves, where it's always cool.")
    z.rect(5, 31, 8, 6, ","); z.rect(6, 3, 12, 5, ","); z.rect(3, 9, 8, 3, "f")
    scatter_props(z, "oak", 3, 3, 21, 11, 14, 7, avoid=(".",))
    scatter_props(z, "oak", 3, 30, 21, 11, 14, 8, avoid=(".",))
    for y in range(10, 14):
        z.set(14, y, "F")
    z.rect(14, 10, 10, 1, "F"); z.rect(14, 31, 10, 1, "F")
    # east: farmland and strawberry polytunnels
    z.rect(52, 3, 10, 8, ","); z.rect(54, 14, 8, 3, ",")
    z.building(56, 15, 6, 3, "white_render", "Strawberry Barn")
    z.rect(56, 18, 6, 1, ":")
    z.prop("bench", 54, 19); z.prop("lamp_post", 63, 19)
    scatter_props(z, "oak", 50, 2, 18, 14, 8, 9, avoid=(".",))
    scatter_props(z, "bush", 50, 2, 18, 38, 14, 10, avoid=(".",))
    # underground river resurgence pocket (south-east), reached by Brook-wade across deep water
    z.height(56, 23, 14, 21, 0)
    z.rect(56, 24, 2, 20, "T"); z.rect(68, 24, 2, 20, "T")
    z.rect(58, 24, 10, 5, "."); z.rect(61, 23, 3, 1, "#"); z.rect(61, 24, 3, 5, "#")
    z.rect(58, 29, 10, 1, "s")
    z.rect(58, 30, 10, 9, "o")
    z.rect(58, 39, 10, 5, "^"); z.rect(61, 39, 3, 2, "s")
    z.set(61, 40, "R"); z.set(63, 40, "R"); z.set(62, 40, "#")
    z.d["warps"].append({"x": 62, "y": 40, "to": "wookey_hole", "tx": 15, "ty": 20, "facing": "up", "gate": "brook_wade"})
    z.prop("bench", 59, 27); z.prop("oak", 66, 26); z.prop("oak", 59, 25, variant=1); z.prop("bush", 66, 28)
    z.sign(62, 29, "WOOKEY HOLE. The River Axe wells up from deep inside the Mendips. You'll want to wade. The witch under the arch doesn't mind, but her stalagmite does.")
    # NPCs
    chat(z, "cheese_maker", "farmer", 7, 19, "Cheese Maker",
         ["Cheddar is the world's most popular cheese for a reason. It comes from this village and it's always sold out.",
          "Tradition says to turn the cheese by hand every day. After thirty years, my wrists have opinions."], "down", "still")
    chat(z, "caver", "hiker", 12, 22, "Caver",
         ["Cheddar Man was found in Gough's Cave in 1903. About 10,000 years old, and Britain's oldest complete skeleton.",
          "In 1997 a local history teacher turned out to share his DNA. Very distant cousin. Not a bad ancestry quiz."], "down", "wander")
    chat(z, "climber", "jogger", 35, 20, "Gorge Climber",
         ["Jacob's Ladder: 274 steps up to the clifftop. I do them twice every morning. Then I eat an entire cheese roll.",
          "The gorge is up to 137 metres deep. Don't look down. I'm joking. Look down. It's brilliant."], "right", "wander")
    chat(z, "goat_watcher", "birdwatcher", 44, 21, "Cliff Watcher",
         ["Peregrines, ravens and, if you're very lucky, a feral goat in an impossible spot.",
          "Soay sheep live up there too. They're an ancient breed. The oldest thing on the cliffs, apart from the cliffs."], "left", "still")
    chat(z, "berry_picker", "villager_2", 60, 20, "Strawberry Picker",
         ["The Cheddar Valley was famous for strawberries. They rode out on the 'Strawberry Line', a railway built for them.",
          "Now it's a walking and cycling path. You can still smell the jam on a warm day."], "down", "wander")
    for (x, y) in [(33, 6), (43, 11), (35, 31)]:
        z.npc(id="goat_%d" % x, sprite="creature:kidgruff", x=x, y=y, facing="down", move="wander", script="goat")
    script("mendips", "goat", say("Feral Goat", "It chews. It stares. It has decided you are not a threat, and not a snack either."))
    trainer(z, "mendip_hiker", "Hiker Barnaby", "Hiker", "hiker", [("billgruff", 39), ("hazeldoze", 39), ("lanternis", 40)],
            37, 13, "down", ["Jacob's Ladder: two hundred and seventy-four steps. I'm on my fourth go. You're on my route."],
            "My legs are jelly. Cheese-flavoured jelly. Well fought.", "I'll recover on the cheese roll. Possibly the whole wheel.", 1040)
    trainer(z, "mendip_birder", "Birdwatcher Henrietta", "Birdwatcher", "birdwatcher", [("forkwing", 39), ("hushwing", 40), ("murmurant", 39)],
            41, 31, "up", ["Peregrines nest in the gorge. The fastest animals on Earth, diving at over two hundred miles an hour."],
            "Oh! I blinked, and you won. It's the peregrine effect.", "If you hear a whoosh, don't look up. Duck.", 1020)
    trainer(z, "mendip_warden", "Warden Quentin", "Warden", "warden_grunt", [("brockmoor", 39), ("thornsow", 39), ("hazeldoze", 38)],
            62, 21, "left", ["Welcome to the Cheddar Gorge Experience(tm)! Cliff view, guide fee, mandatory fudge."],
            "That's not in the brochure. Cut it.", "I'm told the goats are not signed up. I've offered them lanyards.", 980)
    trainer(z, "mendip_caver", "Hiker Delyth", "Hiker", "hiker", [("horseshoe", 40), ("lanternis", 41), ("flittermouse", 39)],
            17, 21, "right", ["Headtorch, spare headtorch, third spare headtorch. And you, in the dark with no light."],
            "Right. You've got more nerve than a bat in a bell tower.", "Bats: the best cave neighbours. Terrible at rent.", 1060)
    z.d["edges"] = {"west": {"to": "bath", "offset": 0}, "east": {"to": "glastonbury", "offset": 0}}
    z.d["spawn"] = [4, 21]
    wild(z, [("hazeldoze", 38, 40, 18, {}), ("dozelet", 38, 39, 5, {"time": ["dawn", "dusk"]}),
             ("lanternis", 39, 41, 14, {"time": ["night", "dusk"]}), ("glowmite", 38, 40, 5, {"time": ["night"], "weather": ["fog"]}),
             ("horseshoe", 40, 41, 12, {"time": ["night"]}), ("horselet", 38, 40, 5, {"time": ["dusk", "night"]}),
             ("billgruff", 39, 41, 14, {"time": ["day", "dawn"]}), ("forkwing", 38, 40, 12, {"weather": ["gale", "clear", "sunshine"]}),
             ("brockmoor", 39, 41, 12, {"weather": ["drizzle", "downpour"]}), ("thornsow", 39, 41, 10, {"weather": ["fog", "drizzle"]}),
             ("flittermouse", 38, 40, 12, {"time": ["night"]})])
    wild(z, [("rillotter", 39, 41, 30, {}), ("pincray", 39, 41, 30, {}), ("parrlet", 38, 40, 20, {}), ("elverlet", 38, 40, 20, {})], "water")
    z.save(OUT + "/mendips.json")


def wookey(OUT):
    W, H = 32, 24
    c = Z("wookey_hole", "Wookey Hole", W, H, fill="x", kind="interior", region="", music="route_mountain", weather={})
    c.d["stage"] = "cave"
    c.legend["k"] = {"tile": "path", "colour": "#5a5650"}
    c.legend["g"] = {"tile": "tall_grass", "colour": "#4f6a45", "prop": "none"}
    c.rect(4, 3, 24, 18, "k")
    for (x, y, w, h) in [(2, 8, 2, 8), (28, 6, 2, 9), (8, 1, 12, 2), (12, 21, 8, 2)]:
        c.rect(x, y, w, h, "k")
    c.rect(4, 6, 24, 8, "o")                               # the river chamber
    c.rect(10, 5, 12, 1, "w"); c.rect(10, 14, 12, 1, "w")
    c.rect(14, 2, 4, 4, "s")
    c.rect(4, 15, 8, 5, "g"); c.rect(20, 15, 8, 5, "g"); c.rect(5, 4, 4, 4, "g")
    c.rect(13, 14, 6, 7, "k")
    c.rect(15, 20, 2, 2, "k")
    c.set(15, 22, "D")
    c.d["warps"].append({"x": 15, "y": 22, "to": "mendips", "tx": 62, "ty": 39, "facing": "up"})
    for (x, y, v) in [(5, 10, 0), (27, 10, 1), (8, 20, 2), (25, 4, 0), (12, 3, 1), (20, 18, 2), (6, 14, 1)]:
        c.prop("rock", x, y, variant=v)
    c.prop("standing_stone", 16, 3, variant=0); c.prop("standing_stone", 17, 3, variant=2)
    c.prop("statue", 15, 4); c.prop("lamp_post", 13, 17); c.prop("lamp_post", 18, 17)
    c.sign(17, 4, "THE WITCH OF WOOKEY HOLE. A stalagmite said to be a witch turned to stone by a monk. A local legend. The monk is not named. The witch is a minor celebrity.")
    c.sign(14, 19, "THE RIVER AXE. Rain that fell on the Mendips seeps for days through limestone before emerging here, at a constant 11 degrees. Paper mills used the water from 1610.")
    c.npc(id="cave_guide", sprite="tour_guide", x=16, y=19, facing="down", move="still", script="cave_guide")
    script("wookey_hole", "cave_guide", say("Cave Guide",
           "Wookey Hole is one of the oldest tourist caves in Britain. People have lived in the entrance for 45,000 years. Mind the drips.",
           "The Witch is a rock. The legend says a monk turned her to stone with holy water. I say the damp did it."))
    c.npc(id="cave_diver", sprite="angler", x=6, y=16, facing="right", move="still", script="cave_diver")
    script("wookey_hole", "cave_diver", say("Cave Diver", "Cave divers have explored Wookey Hole more than 50 chambers deep. I stay in the shallow end, thanks."))
    trainer(c, "wookey_witch", "Druid Morgana", "Druid", "villager_6", [("lanternis", 41), ("pooka", 40), ("sulisa", 41)],
            22, 18, "left", ["I'm the Witch of Wookey, today. The hat's a prop. The grudge is real."],
            "You've broken the spell. I'll be in the gift shop.", "I curse you with exceptionally good luck and mild damp.", 1100)
    c.d["spawn"] = [15, 20]
    wild(c, [("lanternis", 39, 41, 20, {}), ("glowmite", 38, 40, 14, {}), ("horseshoe", 40, 41, 18, {}), ("horselet", 38, 40, 8, {}),
             ("pincray", 39, 41, 16, {}), ("parrlet", 38, 40, 14, {}), ("pooka", 40, 41, 6, {"time": ["night"]})])
    wild(c, [("pincray", 39, 41, 30, {}), ("parrlet", 39, 41, 30, {}), ("rillotter", 39, 41, 30, {}), ("sulisa", 40, 41, 8, {})], "water")
    c.save(OUT + "/wookey_hole.json")


def glastonbury(OUT):
    W, H = 60, 48
    z = Z("glastonbury", "Glastonbury", W, H, kind="town", region="south_england", music="town_cheshire",
          weather={"clear": 22, "sunshine": 20, "drizzle": 22, "fog": 22, "downpour": 6, "gale": 8})
    z.d["stage"] = "castle"; z.d["town_id"] = "glastonbury"
    z.legend["r"] = {"tile": "water", "colour": "#a8453f"}          # the Red Spring
    # the Tor: a big smooth hill
    for y in range(H):
        for x in range(W):
            d = math.hypot(x - 46, y - 8)
            z.hg[y][x] = max(0, 6 - int(d / 2.0))
    z.border("T", 2, gaps=[(0, 20, 2, 3), (28, 46, 3, 2)])
    z.scatter(0, 0, W, H, "P", 25, 2, only="T")
    # High Street and the road south
    z.rect(0, 20, 60, 3, "="); z.rect(2, 19, 56, 1, ":"); z.rect(2, 23, 56, 1, ":")
    z.rect(28, 23, 3, 25, "="); z.rect(27, 24, 1, 22, ":"); z.rect(31, 24, 1, 22, ":")
    for x in (6, 14, 22, 36, 44, 52):
        z.prop("lamp_post", x, 19)
    for x in (10, 18, 40, 48):
        z.prop("lamp_post", x, 23)
    z.prop("phone_box", 4, 19); z.prop("post_box", 56, 23); z.prop("bench", 24, 23); z.prop("bench", 34, 19)
    # Sanctuary, Corner Shop, shops
    z.building(8, 14, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.building(15, 14, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(11, 17, "glastonbury_sanctuary", 5, 6, "up"); z.warp(17, 17, "glastonbury_shop", 4, 5, "up")
    z.rect(8, 18, 12, 1, ":")
    z.building(3, 14, 4, 4, "tudor", "Crystal Emporium"); z.building(35, 15, 5, 4, "terrace", "Cauldron Cafe")
    z.building(36, 24, 7, 4, "tudor", "The George and Pilgrims"); z.building(44, 24, 7, 4, "cream_render", "Wizard Wardrobe")
    z.rect(36, 28, 15, 1, ":")
    # Chalice Well gardens (Red Spring) under the Tor, west of it
    z.rect(22, 5, 12, 12, ".")
    z.rect(26, 8, 5, 3, "r"); z.rect(23, 6, 2, 2, "r"); z.rect(25, 7, 1, 1, ":")
    z.rect(24, 12, 9, 1, ":"); z.rect(28, 13, 2, 6, ":"); z.rect(24, 8, 1, 5, ":"); z.rect(26, 11, 1, 1, ":")
    z.rect(22, 14, 12, 2, "f"); z.rect(22, 5, 12, 1, "f"); z.rect(31, 6, 3, 6, "f")
    z.prop("statue", 28, 11); z.prop("bench", 25, 13); z.prop("bench", 32, 13); z.prop("lamp_post", 24, 5)
    for (x, y) in [(22, 6), (33, 5), (22, 11), (34, 14), (32, 16)]:
        z.prop("pine", x, y)
    z.sign(29, 17, "CHALICE WELL. A spring that has never failed, running at about 25,000 gallons a day at the same cool temperature all year. The water runs red from the iron. Legend says the Holy Grail lies beneath it.")
    z.sign(29, 19, "THE TOR 158 m. Isle of Avalon in the legends. St Michael's Tower on the top is all that's left of a medieval church. Wear good boots.")
    # the Tor path and tower
    path(z, [(46, 20), (46, 16), (40, 16), (40, 12), (51, 12), (51, 9), (46, 9)], "#", 1)
    z.building(45, 5, 3, 3, "castle", "St Michael's Tower", door=1)
    z.set(46, 8, "#")
    z.warp(46, 7, "glastonbury_tor", 20, 28, "up")
    z.rect(43, 17, 7, 1, "f"); z.rect(36, 9, 3, 5, ","); z.rect(53, 15, 4, 4, ","); z.rect(42, 3, 3, 4, ",")
    scatter_props(z, "bush", 34, 0, 24, 19, 14, 3, avoid=(".",))
    scatter_props(z, "rock", 34, 0, 24, 19, 8, 4, avoid=(".",))
    z.prop("bench", 47, 9); z.prop("standing_stone", 44, 9, variant=1); z.prop("standing_stone", 49, 10, variant=2)
    z.sign(47, 10, "TO THE TOWER. Seven terraces wrap the hill, some say a medieval maze, some say farming. Either way, your calves will find out.")
    # station
    z.building(4, 26, 9, 2, "station", "Glastonbury Station", door=4)
    z.rect(4, 28, 9, 1, "_"); z.rect(3, 29, 11, 1, "!")
    z.d["station"] = {"x": 8, "y": 28}
    z.rect(3, 24, 1, 5, "#"); z.rect(3, 28, 1, 1, "#"); z.rect(13, 28, 1, 1, "#"); z.rect(13, 24, 1, 5, ":")
    z.rect(3, 24, 11, 1, ":")
    z.prop("bench", 6, 28); z.prop("lamp_post", 12, 28)
    rail_guard(z, 10, 28, ["Glastonbury Station. Closed in 1966, reopened by something nobody will admit.",
                           "Hop aboard. The Wildlore rail runs to any town you have visited. Where to?"])
    # the Abbey ruins, south-east, behind a wall
    z.rect(34, 30, 22, 15, ".")
    z.rect(34, 30, 22, 1, "W"); z.rect(34, 44, 22, 1, "W"); z.rect(55, 30, 1, 15, "W"); z.rect(34, 30, 1, 15, "W")
    z.rect(34, 34, 1, 3, ":"); z.rect(31, 34, 4, 3, ":")
    z.building(38, 31, 7, 5, "castle", "Glastonbury Abbey Ruins")
    z.building(46, 31, 4, 5, "castle", show_label=False)
    z.building(38, 38, 6, 4, "chapel", "Lady Chapel")
    z.building(50, 38, 4, 4, "stone", "Abbot's Kitchen")
    z.rect(35, 36, 20, 1, ":")
    z.rect(51, 31, 4, 3, "f"); z.rect(36, 40, 1, 3, "f")
    z.prop("bush", 48, 37, variant=1)
    z.prop("bench", 36, 38); z.prop("bench", 52, 37); z.prop("lamp_post", 36, 35); z.prop("lamp_post", 54, 35)
    scatter_props(z, "pine", 35, 31, 20, 13, 5, 6, avoid=(".",))
    z.sign(36, 34, "GLASTONBURY ABBEY. A monastery for 1,000 years, said to be the oldest in England. In 1191 the monks announced they'd found King Arthur's grave. A convenient discovery.")
    z.sign(49, 37, "THE GLASTONBURY THORN. Said to grow from Joseph of Arimathea's staff. This one flowers twice a year, in spring and at Christmas. It's a plant with excellent timing.")
    z.sign(47, 40, "THE ABBOT'S KITCHEN. Four fireplaces, a lantern roof, and a medieval workplace still standing. The abbot, famously, didn't wash up.")
    # festival field, south-west
    z.rect(3, 31, 24, 14, ",")
    z.rect(4, 31, 22, 1, "."); z.rect(3, 31, 2, 14, "."); z.rect(3, 43, 24, 2, ".")
    z.rect(6, 33, 6, 8, "."); z.rect(13, 36, 10, 6, ".")
    z.building(6, 33, 9, 5, "white_render", "Pyramid Stage")
    for (x, y) in [(8, 40), (10, 40), (14, 40), (18, 41), (6, 43), (22, 41), (24, 40)]:
        z.prop("market_stall", x, y, variant=(x + y) % 3)
    for i, a in enumerate(range(0, 360, 60)):
        z.prop("standing_stone", int(21 + 3 * math.cos(math.radians(a))), int(36 + 2.6 * math.sin(math.radians(a))), variant=i % 3)
    for x in (4, 9, 14, 20, 25):
        z.prop("lamp_post", x, 32)
    z.rect(15, 33, 1, 8, "#"); z.rect(6, 38, 10, 1, "#"); z.rect(25, 24, 2, 8, "#"); z.rect(25, 30, 2, 1, "#")
    z.rect(27, 24, 1, 22, ":")
    z.sign(15, 32, "THE FIELD. Glastonbury Festival, held at nearby Worthy Farm since 1970, when a ticket was a pound and included free milk. Today the milk is extra. The mud is still free.")
    z.sign(23, 38, "THE STONE CIRCLE. Modern, built for the festival, and still impressive. The real ones are at Avebury and Stonehenge. They won't be mentioned until later.")
    # NPCs
    chat(z, "druid_lady", "villager_6", 25, 21, "Druid",
         ["Glastonbury has been a pilgrimage place for thousands of years. Pagans, Christians, Arthurians, all queuing politely for the same hill.",
          "I'm a druid, by the way. I have a lovely robe. It's mostly pockets."], "down", "wander")
    chat(z, "crystal_seller", "shopkeeper", 5, 19, "Crystal Seller",
         ["Rose quartz for love, amethyst for calm, and tiger's eye if you're about to run a bath for a cat.",
          "Glastonbury has more crystal shops per street than anywhere I know. We're all friends. We're also all in competition."], "down", "still")
    chat(z, "steward", "villager_3", 14, 32, "Festival Steward",
         ["The Glastonbury Festival started in 1970 with 1,500 people and free milk. Now it's about 200,000 and a very long queue for chips.",
          "The festival has a Green Field, a Stone Circle and a Pyramid Stage. They don't tell you that the pyramid is a dome."], "right", "still")
    chat(z, "cider_seller", "farmer", 20, 41, "Cider Seller",
         ["Somerset is cider country. We press apples from old orchards, and some of them are older than I am.",
          "I'll let you try some. Not too much! You've got a Tor to climb. Gravity is not on your side."], "up", "still")
    chat(z, "abbey_guide", "tour_guide", 42, 37, "Abbey Guide",
         ["The Abbey was destroyed in 1539 by Henry VIII, and the last abbot was hanged on top of the Tor. Not the day out we promised.",
          "What's left are the ruins of the Lady Chapel and some very lovely grass. The grass is Grade I listed. Not literally."], "down", "still")
    chat(z, "chalice_gardener", "villager_5", 27, 16, "Chalice Gardener",
         ["The Chalice Well runs continuously. They say it's never failed, even in the 1976 drought.",
          "The Red Spring is red because of iron. The White Spring is next door and runs white because of limestone. They're like a married couple."], "right", "still")
    trainer(z, "glaston_busker", "Busker Wren", "Busker", "harpist", [("hazeldoze", 40), ("pixiedell", 40), ("thornwyn", 41)],
            38, 21, "left", ["Spare change, or a duel? I'm told both are more frequent in this town than rain."],
            "Applause. Or rubbish. Hard to tell in this light.", "I'll do requests. Not 'Wonderwall'. Never 'Wonderwall'.", 1000)
    trainer(z, "glaston_festie", "Festival-goer Jago", "Festival-goer", "student", [("pixling", 40), ("wispet", 40), ("prismite", 40)],
            17, 38, "up", ["Wellies on, wristband on, and I haven't slept since Thursday. I'm in perfect condition to battle."],
            "I'm going to lie down in the mud. Briefly. Don't judge.", "Best bit of the festival: the sunrise at the Stone Circle.", 960)
    z.d["edges"] = {"west": {"to": "mendips", "offset": 0}, "south": {"to": "somerset_levels", "offset": 0}}
    z.d["spawn"] = [30, 21]
    wild(z, [("thornwyn", 40, 41, 10, {}), ("hazeldoze", 40, 41, 16, {}), ("pixling", 40, 41, 8, {"time": ["dusk", "night"]}),
             ("pixiedell", 40, 41, 12, {}), ("wispet", 40, 41, 10, {"weather": ["fog"]}), ("prismite", 40, 41, 12, {"time": ["day"]}),
             ("tylwyth", 40, 41, 10, {"time": ["night"]})])
    z.save(OUT + "/glastonbury.json")
    sanctuary(OUT, "glastonbury", "Glastonbury", (11, 18))
    shop(OUT, "glastonbury", "Glastonbury", (17, 18))
    nurse("glastonbury", ["Blessings. This is the Glastonbury Sanctuary. We do scones, crystals and creature care, in that order. Pop your team on the counter.",
                          "Right. Hold this rose quartz, it'll keep you calm. It also keeps the door open.",
                          "All done. They've had the rest. You've had the crystal. Fair trade.",
                          "The Ark terminal. It hums. We think that's the ley lines. The engineers think it's the fridge.",
                          "Peace and light. And a biscuit, if you're passing."])
    shopkeeper("glastonbury", "Welcome! Snares, scones and the one crystal that's actually a glass paperweight.",
               "Go in peace. And buy a bun, it's apple.")


def tor(OUT):
    W, H = 40, 32
    t = Z("glastonbury_tor", "Glastonbury Tor", W, H, kind="interior", region="south_england", music="battle_keeper",
          weather={"clear": 35, "sunshine": 20, "fog": 25, "drizzle": 20})
    t.d["stage"] = "castle"
    t.border("T", 2)
    t.scatter(0, 0, W, H, "P", 18, 2, only="T")
    # terraces: stepped heights, row by row
    for y in range(H):
        t.hg[y] = [3 if y <= 10 else 2 if y <= 16 else 1 if y <= 22 else 0] * W
    # the summit arena
    t.rect(6, 2, 28, 9, ".")
    t.rect(11, 5, 18, 5, ":")
    t.rect(10, 3, 20, 1, "W"); t.rect(10, 3, 5, 1, "H"); t.rect(25, 3, 5, 1, "H")
    t.building(17, 1, 6, 3, "castle", "St Michael's Tower")
    for x in (11, 28):
        t.prop("lamp_post", x, 5); t.prop("lamp_post", x, 9)
    t.prop("bench", 8, 4); t.prop("bench", 31, 4); t.prop("planter", 8, 8); t.prop("planter", 31, 8)
    t.prop("standing_stone", 7, 6, variant=1); t.prop("standing_stone", 32, 6, variant=2)
    t.rect(7, 10, 26, 1, "f")
    # the corridor of path up the hill, with hedges
    t.rect(19, 11, 3, 18, "#")
    t.rect(17, 11, 2, 18, "H"); t.rect(22, 11, 2, 18, "H")
    t.rect(17, 24, 2, 3, "."); t.rect(22, 24, 2, 3, ".")        # gaps: orchard west, standing stones east
    t.rect(17, 24, 2, 3, "#"); t.rect(22, 24, 2, 3, "#")
    # orchard on the west terraces
    t.rect(3, 12, 14, 17, ".")
    t.rect(3, 12, 14, 1, "F"); t.rect(3, 12, 1, 17, "F"); t.rect(3, 28, 14, 1, "F")
    t.rect(4, 14, 12, 12, ".")
    for yy in range(15, 27, 3):
        for xx in range(5, 15, 3):
            t.prop("oak", xx, yy, variant=(xx + yy) % 3)
    t.rect(5, 16, 9, 1, ","); t.rect(5, 22, 9, 1, ",")
    t.rect(8, 19, 3, 2, "f"); t.rect(5, 24, 1, 1, "f")
    t.rect(13, 25, 4, 1, "."); t.rect(13, 25, 4, 1, "#")
    t.prop("bench", 6, 18); t.prop("bench", 13, 18)
    t.sign(13, 26, "THE ORCHARD. Old apple trees, older cider, and a feeling that something is watching. It's just the trees. Probably.")
    # east terrace: standing stones and a view
    t.rect(24, 12, 13, 16, ".")
    t.rect(24, 12, 13, 1, "F"); t.rect(36, 12, 1, 16, "F"); t.rect(24, 28, 13, 1, "F")
    t.rect(24, 24, 3, 3, "#"); t.rect(27, 25, 4, 1, "#")
    for (x, y) in [(30, 18), (32, 17), (34, 19), (33, 21), (31, 22), (29, 20)]:
        t.prop("standing_stone", x, y, variant=(x + y) % 3)
    t.rect(28, 14, 7, 2, "f"); t.rect(26, 22, 3, 3, ",")
    t.prop("bench", 28, 25); t.prop("rock", 26, 15); t.prop("rock", 35, 25)
    t.sign(30, 25, "THE TOR LOOKS OUT OVER THE LEVELS. In winter the fields flood and the hill becomes an island. That's Avalon. The word means 'apple island'.")
    # exit
    t.rect(19, 29, 3, 1, "#")
    t.d["warps"].append({"x": 20, "y": 29, "to": "glastonbury", "tx": 46, "ty": 9, "facing": "down"})
    # story placeholders and trainers
    t.npc(id="keeper_morwen", sprite="keeper_morwen", x=20, y=6, facing="down", move="still", script="keeper_morwen")
    script("glastonbury_tor", "keeper_morwen", say("Keeper Morwen", "Placeholder: the story agent rewrites this Keeper battle script."))
    t.npc(id="greenman_spot", sprite="creature:greenman", x=9, y=20, facing="down", move="still", script="greenman")
    script("glastonbury_tor", "greenman", say("The Green Man", "Placeholder: the story agent writes the Green Man here."))
    # the juniors are one double battle; data/trainers/tor_druid.json is maintained by hand (story task)
    t.npc(id="tor_druid", sprite="villager_6", x=19, y=20, facing="right", move="still", trainer="tor_druid")
    t.npc(id="tor_festival", sprite="student", x=19, y=21, facing="right", move="still", trainer="tor_druid")
    t.d["spawn"] = [20, 28]
    t.save(OUT + "/glastonbury_tor.json")
