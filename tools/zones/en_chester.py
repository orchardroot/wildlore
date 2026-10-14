# Part of england_north.py (exec'd in its namespace): Chester and the Dee Valley stub.

# ====================================================================
# CHESTER  64 x 54, walled city: north gap to the Wirral, west gap to Dee Valley
# ====================================================================
ch = Z("chester", "Chester", 64, 54, kind="town", region="cheshire", music="town_cheshire", fill=".",
       weather={"drizzle": 34, "clear": 30, "sunshine": 18, "fog": 8, "gale": 5, "downpour": 5})
ch.d["stage"] = "castle"; ch.d["town_id"] = "chester"
ch.legend["S"] = {"tile": "drystone_wall", "colour": "#9c4f3e"}
ch.legend["r"] = REEDS
ch.border("T", 3, gaps=[(26, 0, 3, 3), (0, 18, 3, 3)])
# walls: x 12..48, y 6..34; walkway on top, one tile inside the wall
WX0, WX1, WY0, WY1 = 12, 48, 6, 34
ch.rect(WX0, WY0, WX1 - WX0 + 1, WY1 - WY0 + 1, "S")
ch.rect(WX0 + 1, WY0 + 1, WX1 - WX0 - 1, WY1 - WY0 - 1, ".")
ch.rect(WX0 + 1, WY0 + 1, WX1 - WX0 - 1, 1, "_"); ch.rect(WX0 + 1, WY1 - 1, WX1 - WX0 - 1, 1, "_")
ch.rect(WX0 + 1, WY0 + 1, 1, WY1 - WY0 - 1, "_"); ch.rect(WX1 - 1, WY0 + 1, 1, WY1 - WY0 - 1, "_")
ch.height(WX0, WY0, WX1 - WX0 + 1, WY1 - WY0 + 1, 2); ch.height(WX0 + 1, WY0 + 1, WX1 - WX0 - 1, WY1 - WY0 - 1, 0)
for (x, y, w_, h_) in [(WX0 + 1, WY0 + 1, WX1 - WX0 - 1, 1), (WX0 + 1, WY1 - 1, WX1 - WX0 - 1, 1), (WX0 + 1, WY0 + 1, 1, WY1 - WY0 - 1), (WX1 - 1, WY0 + 1, 1, WY1 - WY0 - 1)]:
    ch.height(x, y, w_, h_, 2)
# the four gates (road tiles at ground level, walkway ends)
for (x, y, w_, h_) in [(26, WY0, 3, 2), (26, WY1 - 1, 3, 2), (WX0, 18, 2, 3), (WX1 - 1, 18, 2, 3)]:
    ch.rect(x, y, w_, h_, ":"); ch.height(x, y, w_, h_, 0)
# steps up to the walls, inside near each corner
for (sx, sy, tx, ty) in [(20, WY0 + 2, 20, WY0 + 1), (40, WY0 + 2, 40, WY0 + 1), (20, WY1 - 2, 20, WY1 - 1), (40, WY1 - 2, 40, WY1 - 1),
                         (WX0 + 2, 12, WX0 + 1, 12), (WX0 + 2, 28, WX0 + 1, 28), (WX1 - 2, 12, WX1 - 1, 12), (WX1 - 2, 28, WX1 - 1, 28)]:
    ch.set(sx, sy, "#"); ch.height(sx, sy, 1, 1, 1)
# streets inside: Watergate/Eastgate (E-W) and Northgate/Bridge Street (N-S), meeting at the Cross
ch.rect(0, 18, 64, 3, ":"); ch.rect(0, 19, 64, 1, "=")
ch.rect(26, 3, 3, 50, ":"); ch.rect(27, 3, 1, 50, "=")
ch.rect(26, 18, 3, 3, ":")
# the Rows: Tudor frontages along both streets, north side facing the street
ch.rect(13, 14, 34, 1, ":"); ch.rect(13, 25, 34, 1, ":")
for x in (14, 19, 33, 38, 43):
    ch.building(x, 15, 5, 3, "tudor", "The Rows" if x == 33 else None, door=2)
for x in (14, 20, 33, 38):
    ch.building(x, 22, 5, 3, "tudor", show_label=False)
ch.sign(31, 17, "THE ROWS. Shops on top of shops, gantries and galleries. Unique in the world. Also unreasonable for prams.")
# Eastgate with its clock
ch.prop("lamp_post", 46, 17); ch.prop("lamp_post", 46, 21); ch.prop("lamp_post", 14, 17); ch.prop("lamp_post", 14, 21)
ch.sign(44, 17, "EASTGATE CLOCK. Built 1899 for Queen Victoria's Diamond Jubilee. The second most photographed clock in Britain, after Big Ben.")
# the cathedral, red sandstone
ch.rect(30, 8, 15, 6, ":")
ch.building(32, 8, 9, 4, "cathedral", "Chester Cathedral", door=4)
ch.prop("bench", 31, 13); ch.prop("bench", 41, 13); ch.prop("planter", 34, 13); ch.prop("planter", 38, 13)
ch.sign(36, 14, "CHESTER CATHEDRAL. Eleven hundred years of worship, one hundred of scaffolding.")
# Sanctuary and the Corner Shop
ch.rect(14, 9, 14, 5, ":")
town_services(ch, "chester", "Chester", (15, 9), (21, 9))
ch.prop("lamp_post", 14, 13); ch.prop("post_box", 25, 13); ch.prop("phone_box", 24, 12)
# Roman gardens, south-west inside the walls
ch.rect(14, 26, 11, 6, "."); ch.rect(14, 26, 11, 1, "#")
for x in (16, 19, 22): ch.prop("standing_stone", x, 28, variant=x % 3)
ch.prop("statue", 19, 30); ch.prop("bench", 15, 31)
ch.rect(15, 29, 3, 2, "f"); ch.rect(21, 29, 3, 2, "f")
ch.sign(18, 27, "ROMAN GARDENS. Deva Victrix, founded AD 79. The Romans came for the lead, stayed for the drainage.")
ell(ch, 22, 30, 2, 1, ",", only=".")
# south-east: gardens and quiet lanes
ch.rect(30, 26, 17, 6, "."); ch.rect(30, 25, 17, 1, "#")
ch.rect(32, 28, 5, 2, "f"); ell(ch, 41, 29, 3, 2, ",", only="."); ell(ch, 45, 28, 1, 2, ",", only=".")
ch.building(44, 22, 3, 3, "red_brick", show_label=False)
for (x, y) in [(31, 31), (36, 30), (43, 31), (30, 28)]: ch.prop("oak", x, y)
ch.sign(33, 27, "NEWGATE. The wall's newest gate. It was built in 1938, so, quite old. By Chester standards, newborn.")
# outside the walls, east: station and plaza, Roman amphitheatre
ch.rect(49, 12, 14, 14, ":"); ch.rect(49, 18, 13, 3, ":")
ch.building(50, 8, 8, 2, "station", "Chester Station", door=3)
ch.rect(49, 10, 11, 1, "_"); ch.rect(49, 11, 15, 1, "!"); ch.rect(60, 10, 1, 1, ":"); ch.rect(60, 11, 1, 1, "#")
ch.rect(49, 12, 14, 1, ":")
ch.d["station"] = {"x": 53, "y": 10}
ch.prop("lamp_post", 50, 13); ch.prop("lamp_post", 58, 13); ch.prop("bench", 56, 13)
ch.sign(49, 13, "CHESTER STATION. Trains for Wales leave from the platform where the rain does.")
ch.rect(50, 26, 12, 9, ".")
for ang in range(0, 360, 30):
    ch.prop("rock", 56 + int(round(4.5 * math.cos(math.radians(ang)))), 30 + int(round(3.4 * math.sin(math.radians(ang)))))
ell(ch, 56, 30, 3, 2, ",", only=".")
ch.sign(52, 27, "ROMAN AMPHITHEATRE. The biggest in Britain. Seated 8,000 for gladiators. Now seats nobody and hosts the occasional picnic.")
for (x, y) in [(51, 33), (60, 27), (52, 32), (61, 33)]: ch.prop("oak", x, y)
# the Roodee racecourse, south-west
ch.rect(3, 36, 20, 8, ".")
ch.rect(4, 37, 18, 1, "F"); ch.rect(4, 42, 18, 1, "F"); ch.rect(4, 37, 1, 6, "F"); ch.rect(21, 37, 1, 6, "F")
ch.rect(5, 38, 16, 1, "#"); ch.rect(5, 41, 16, 1, "#"); ch.rect(5, 38, 1, 4, "#"); ch.rect(20, 38, 1, 4, "#")
ch.rect(7, 39, 12, 2, "."); ch.rect(4, 40, 1, 1, "#"); ch.rect(21, 40, 1, 1, "#"); ch.rect(22, 40, 4, 1, "#")
ch.rect(13, 37, 1, 1, "#"); ch.rect(13, 36, 1, 1, "#")
ch.prop("lamp_post", 10, 36); ch.prop("lamp_post", 16, 36); ch.prop("bench", 9, 43); ch.prop("bench", 15, 43)
ch.sign(23, 41, "THE ROODEE. England's oldest racecourse, racing since 1539. The only sprint here is the ice-cream queue.")
# the River Dee, the Old Dee Bridge and the Groves
ch.rect(0, 45, 64, 6, "~"); ch.rect(3, 44, 58, 1, "s"); ch.rect(3, 51, 58, 1, "s")
ch.rect(26, 44, 3, 8, "=")
for (x, y, v) in [(10, 47, 1), (20, 49, 0), (40, 47, 1), (50, 49, 0)]: ch.prop("canal_boat", x, y, variant=v)
ch.prop("boat", 36, 48, variant=1); ch.prop("buoy", 14, 46); ch.prop("buoy", 46, 50, variant=1)
ch.rect(30, 36, 32, 8, "."); ch.rect(30, 42, 32, 1, ":"); ch.rect(30, 36, 32, 1, ":")
ch.rect(32, 38, 6, 3, "f"); ch.rect(46, 38, 8, 3, ",")
for (x, y) in [(31, 37), (40, 38), (44, 40), (58, 37), (55, 41), (35, 41), (60, 40)]: ch.prop("oak", x, y)
ch.prop("bench", 34, 42); ch.prop("bench", 48, 42); ch.prop("lamp_post", 30, 43); ch.prop("lamp_post", 44, 43)
ch.sign(31, 43, "THE GROVES. River cruises, ice cream and a swan with an attitude. Do not argue.")
ch.sign(29, 46, "OLD DEE BRIDGE. Medieval, narrow, still carrying traffic. The queue is also medieval.")
# signs at gates
ch.sign(25, 5, "CHESTER. Roman walls, medieval Rows, Victorian clocks. Come in. Mind the history. It bites.")
ch.sign(2, 20, "WEST: Wales, the Dee Valley and a surprising number of sheep.")
ch.sign(29, 2, "NORTH: the Wirral Way. And the sea. Remember the sea.")
for x in (5, 9): ch.prop("lamp_post", x, 17)
# NPCs
ch.npc(id="pryce", sprite="pryce", x=30, y=22, facing="up", move="still", script="pryce_chester", name="Regional Director Pryce")
ch.npc(id="chest_guide", sprite="tour_guide", x=29, y=16, facing="down", move="wander", script="wall_guide", name="Tour Guide")
ch.npc(id="chest_legionary", sprite="villager_4", x=36, y=19, facing="down", move="wander", script="legionary", name="Roman Re-enactor")
ch.npc(id="chest_verger", sprite="villager_3", x=35, y=13, facing="up", move="still", script="chester_verger", name="Verger")
ch.npc(id="chest_racegoer", sprite="villager_2", x=12 + 5, y=44, facing="up", move="wander", script="racegoer", name="Racegoer")
ch.npc(id="chest_boatman", sprite="angler", x=32, y=43, facing="down", move="wander", script="boatman", name="Boatman")
ch.npc(id="chest_student", sprite="student", x=60, y=14, facing="left", move="wander", script="chester_student", name="Student")
ch.npc(id="rail_guard", sprite="rail_guard", x=51, y=10, facing="down", move="still", script="rail_guard", name="Rail Guard")
say("chester", "pryce_chester", "Pryce", "...")
say("chester", "rail_guard", "Rail Guard", "Chester. Trains to Wales, the north and anywhere with a nice view.")
DLG["chester"]["rail_guard"].append({"do": "rail"})
say("chester", "wall_guide", "Tour Guide", "These are the city walls. Nearly two miles, and the most complete Roman-and-medieval circuit in Britain.", "Walk the whole thing. It takes ninety minutes, or four hours if you stop for scones.")
say("chester", "legionary", "Roman Re-enactor", "Ave! I am Marcus. Well, Brian. But Marcus on weekdays.", "Chester was Deva Victrix, home of the Twentieth Legion. We built the amphitheatre. It's the biggest in Britain. You're welcome.")
say("chester", "chester_verger", "Verger", "The cathedral was an abbey for Benedictine monks. Red sandstone, like the walls.", "Look up at the ceiling. The monks knew how to pick a ceiling.")
say("chester", "racegoer", "Racegoer", "The Roodee has hosted races since 1539. England's oldest racecourse still in use.", "I've lost money here for twenty years. It's the finest losing experience in England.")
say("chester", "boatman", "Boatman", "The River Dee. The Romans used it as a port. Legionaries marched up from the quay.", "It's a Celtic name, Dyfrdwy, 'goddess river'. She's not always friendly after a downpour.")
say("chester", "chester_student", "Student", "Eastgate Clock. 1899. Everyone photographs it. I've seen exactly one person look at the time.", "The Rows are two storeys of shops. Nobody agrees why. Chester just likes to be awkward.")
ch.d["encounters"] = {"grass": [
    {"species": "elverlet", "min": 21, "max": 23, "weight": 16, "weather": ["drizzle", "downpour", "fog"]},
    {"species": "brockling", "min": 21, "max": 23, "weight": 16, "time": ["dawn", "dusk", "night"]},
    {"species": "starlet", "min": 21, "max": 23, "weight": 20, "time": ["dawn", "day", "dusk"]},
    {"species": "swiftlet", "min": 21, "max": 23, "weight": 14, "weather": ["clear", "sunshine", "gale"]},
    {"species": "grizzlet", "min": 21, "max": 22, "weight": 14, "time": ["dawn", "dusk"]},
    {"species": "binfox", "min": 21, "max": 23, "weight": 14, "time": ["dusk", "night"]},
    {"species": "hootlet", "min": 21, "max": 23, "weight": 12, "time": ["dusk", "night"]},
    {"species": "cooplet", "min": 21, "max": 22, "weight": 12},
    {"species": "minkshade", "min": 22, "max": 23, "weight": 10, "time": ["night"]}],
    "water": [
    {"species": "elverlet", "min": 21, "max": 23, "weight": 30},
    {"species": "minkshade", "min": 22, "max": 23, "weight": 20},
    {"species": "dipling", "min": 21, "max": 22, "weight": 25},
    {"species": "holtling", "min": 21, "max": 23, "weight": 25}]}
ch.d["edges"] = {"north": {"to": "wirral_way", "offset": 0}, "west": {"to": "dee_valley", "offset": 0}}
ch.d["spawn"] = [27, 12]
deco(ch, 49, 12, 13, 14, ["market_stall", "planter", "bench", "bollard", "phone_box", "oak"], 14, 311, on=":")
deco(ch, 14, 8, 33, 6, ["planter", "bench"], 3, 312, on=":.")
deco(ch, 3, 3, 9, 15, ["oak", "bush", "rock"], 8, 313, on=".")
deco(ch, 3, 22, 9, 13, ["oak", "bush", "rock"], 9, 314, on=".")
deco(ch, 49, 3, 12, 5, ["oak", "bush"], 5, 315, on=".")
ch.save(OUT + "/chester.json")
nurse_and_shop("chester",
    ["Hello, dear. Come in, mind the step. We're Roman, we have excellent heating.",
     "Pop them over here. We'll have them right as a legion in no time.",
     "All set. Off you march.",
     "The Ark's by the wall. Keep your pets off the Roman mosaic.",
     "No bother. We've been here nearly two thousand years. We're not in a hurry."],
    ["Good day! Chester rock, flasks, brollies and a very small replica of the Eastgate clock.", "Thank you. Mind the Rows, they're steep on the second floor."])

# ---- Dee Valley stub (the other agent replaces it; kept so the validator is green) ----
dv = Z("dee_valley", "Dee Valley", 30, 30, kind="route", region="north_wales", music="route_mountain", fill=".")
dv.d["stage"] = "valley"
dv.border("T", 3, gaps=[(27, 18, 3, 3)])
dv.d["edges"] = {"east": {"to": "chester", "offset": 0}}
dv.d["spawn"] = [26, 19]
if not os.path.exists(OUT + "/dee_valley.json") or json.load(open(OUT + "/dee_valley.json")).get("stub", True):
    dv.d["stub"] = True
    dv.save(OUT + "/dee_valley.json")
