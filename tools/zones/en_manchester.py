# Part of england_north.py (exec'd in its namespace): Manchester and Bev's Bikes.

# ====================================================================
# MANCHESTER  64 x 60, city: south gap to Goyt, west gap to Chat Moss
# ====================================================================
m = Z("manchester", "Manchester", 64, 60, kind="town", region="manchester", music="town_city", fill=".",
      weather={"drizzle": 45, "downpour": 12, "clear": 14, "fog": 8, "gale": 6, "sunshine": 5})
m.d["stage"] = "city"; m.d["town_id"] = "manchester"
m.legend["r"] = REEDS
m.border("T", 3, gaps=[(26, 57, 3, 3), (0, 24, 3, 3)])
# streets: Oxford Road (north-south) and Deansgate (east-west)
m.rect(26, 3, 3, 57, ":"); m.rect(27, 3, 1, 57, "=")
m.rect(0, 24, 61, 3, ":"); m.rect(0, 25, 61, 1, "=")
# the Rochdale Canal with three bridges
m.rect(3, 14, 58, 2, "~"); m.rect(3, 13, 58, 1, ":"); m.rect(3, 16, 58, 1, ":")
m.rect(12, 14, 2, 2, ":"); m.rect(26, 14, 3, 2, "="); m.rect(46, 14, 2, 2, ":")
for (x, y, v) in [(7, 14, 0), (18, 15, 1), (35, 14, 1), (40, 15, 0), (54, 14, 1)]: m.prop("canal_boat", x, y, variant=v)
for x in (5, 9, 17, 22, 32, 38, 44, 52, 57): m.prop("bollard", x, 13)
for x in (6, 15, 20, 33, 42, 50, 56): m.prop("bollard", x, 16)
# north strip: mills, Town Hall and the Rylands
m.rect(3, 12, 58, 1, ":")
m.building(4, 8, 8, 4, "mill", "Murrays' Mill", door=3)
m.building(14, 8, 8, 4, "mill", "Royal Mills", door=3)
m.building(34, 4, 10, 8, "castle", "Town Hall", door=4)
m.rect(31, 12, 20, 1, ":"); m.rect(46, 11, 13, 1, ":")
m.building(46, 8, 6, 3, "stone", "John Rylands Library", door=2)
m.building(54, 8, 5, 3, "red_brick", show_label=False)
m.building(4, 3, 8, 4, "terrace", show_label=False); m.building(14, 3, 8, 4, "terrace", show_label=False)
m.building(46, 3, 6, 3, "red_brick", show_label=False); m.building(54, 3, 5, 3, "terrace", show_label=False)
m.prop("statue", 40, 12); m.prop("lamp_post", 34, 12); m.prop("lamp_post", 44, 12); m.prop("bench", 36, 12)
m.prop("bench", 47, 12); m.prop("planter", 51, 12)
m.sign(41, 13, "ALBERT SQUARE. The Town Hall clock keeps perfect time. The trams, less so.")
m.sign(15, 12, "ANCOATS. The first industrial suburb on Earth. Please admire from the pavement. And bring a brolly.")
# Ancoats terraces between canal and Deansgate
for x in (4, 14): m.building(x, 18, 8, 3, "terrace", show_label=False)
m.rect(3, 21, 23, 3, "."); m.rect(3, 21, 23, 1, "#"); m.rect(7, 22, 1, 2, "#"); m.rect(18, 22, 1, 2, "#")
m.rect(4, 22, 3, 2, "f"); m.rect(13, 22, 4, 2, "f")
m.rect(23, 17, 3, 4, ".")
# east of Oxford Road: the gardens
m.rect(30, 17, 30, 7, "."); m.rect(30, 17, 30, 1, ":"); m.rect(30, 23, 30, 1, ":")
m.rect(36, 19, 7, 3, "f"); m.rect(48, 19, 7, 3, ",")
path(m, [(30, 20), (58, 20)], "#"); path(m, [(45, 17), (45, 23)], "#")
m.rect(44, 19, 3, 3, "w"); m.rect(45, 20, 1, 1, "~")
for (x, y) in [(33, 18), (34, 22), (42, 18), (56, 18), (57, 22), (50, 22), (52, 18)]: m.prop("oak", x, y)
m.prop("bench", 40, 19); m.prop("bench", 40, 21); m.prop("bench", 49, 21); m.prop("lamp_post", 44, 18); m.prop("lamp_post", 47, 18)
m.sign(31, 19, "PICCADILLY GARDENS. Pigeons, pop-ups and, on Thursdays, a man who plays one note on a trumpet.")
# Sanctuary, Shop, Bev's Bikes (south-west of the crossroads)
m.rect(4, 31, 21, 2, ":")
town_services(m, "manchester", "Manchester", (5, 28), (13, 28))
bk = m.building(19, 28, 6, 3, "red_brick", "Bev's Bikes", door=2)
bkf = door_to(m, bk, "manc_bikes", 4, 5)
m.prop("lamp_post", 11, 32); m.prop("lamp_post", 18, 32); m.prop("lamp_post", 25, 32)
m.prop("planter", 17, 31); m.prop("bench", 23, 32); m.prop("post_box", 12, 31)
m.prop("phone_box", 3, 27)
m.sign(21, 32, "BEV'S BIKES. Repairs, rentals and strong opinions about gears. Bring a puncture.")
# Enclosure pop-up on the plaza south-east of the crossroads
m.rect(30, 27, 20, 8, ":")
for x in (33, 36, 39): m.prop("market_stall", x, 28, variant=x % 3)
m.prop("planter", 31, 28); m.prop("planter", 42, 28); m.prop("lamp_post", 30, 31); m.prop("lamp_post", 44, 31)
m.sign(36, 33, "THE ENCLOSURE HERITAGE EXPERIENCE. The countryside, curated for your convenience. Gift shop exit only.")
m.sign(45, 27, "FREE TOTE BAG WITH EVERY SIGNATURE. Terms and conditions apply to your soul.")
# Piccadilly station south-east
m.rect(30, 35, 31, 10, ":")
m.building(40, 38, 8, 2, "station", "Piccadilly Station", door=3)
m.rect(34, 40, 18, 1, "_"); m.rect(33, 41, 24, 1, "!")
m.d["station"] = {"x": 43, "y": 40}
m.prop("lamp_post", 38, 42); m.prop("lamp_post", 49, 42); m.prop("bench", 46, 42)
m.sign(35, 37, "PICCADILLY. Trains to everywhere, usually eventually.")
# south-west: terraces and back lanes
m.rect(3, 33, 22, 16, "."); m.rect(4, 33, 21, 1, "#")
for x in (4, 14): m.building(x, 36, 8, 3, "terrace", show_label=False)
m.rect(4, 39, 21, 1, "#")
for x in (4, 14): m.building(x, 42, 8, 3, "terrace", show_label=False)
m.rect(4, 45, 21, 1, "#")
for x in (7, 18): m.rect(x, 34, 1, 2, "#"); m.rect(x, 40, 1, 2, "#"); m.rect(x, 46, 1, 3, "#")
# south: Castlefield canal, viaduct, mills and the Roman fort
m.rect(3, 50, 58, 2, "~"); m.rect(3, 49, 58, 1, ":"); m.rect(3, 52, 58, 1, ":")
m.rect(26, 50, 3, 2, "=")
m.building(36, 50, 14, 2, "aqueduct", "Castlefield Viaduct", show_label=True)
for (x, y, v) in [(8, 50, 0), (16, 51, 1), (31, 50, 1), (54, 51, 0)]: m.prop("canal_boat", x, y, variant=v)
m.rect(3, 53, 58, 4, "."); m.rect(29, 53, 31, 1, "#")
m.building(4, 53, 8, 4, "mill", "Dukes Mill", door=3)
m.building(14, 53, 8, 3, "terrace", show_label=False)
m.building(31, 53, 8, 4, "mill", "Knott Mill", door=3)
m.building(41, 53, 6, 3, "red_brick", show_label=False)
m.rect(51, 44, 8, 1, "W"); m.rect(51, 48, 8, 1, "W"); m.rect(51, 44, 1, 5, "W"); m.rect(58, 44, 1, 5, "W")
m.rect(54, 44, 2, 1, "."); m.rect(54, 48, 2, 1, ".")
m.sign(53, 43, "MAMUCIUM. The Romans built a fort here in AD 79. They were not told about the drizzle.")
for x in range(52, 58, 2): m.prop("rock", x, 46)
for (x, y) in [(33, 46), (37, 47), (42, 46), (46, 47)]: m.prop("oak", x, y)
m.rect(31, 45, 17, 3, ".")
# street furniture
for x in (6, 14, 22, 32, 40, 48, 56): m.prop("lamp_post", x, 24)
for x in (10, 18, 36, 52): m.prop("lamp_post", x, 26)
for y in (8, 20, 38, 46):
    m.prop("lamp_post", 26, y); m.prop("lamp_post", 28, y)
m.prop("phone_box", 29, 24); m.prop("post_box", 25, 26)
m.sign(2, 28, "MANCHESTER. Welcome to the city that invented the rain. Don't say we didn't warn you. Wait, we just did.")
m.sign(29, 56, "SOUTH: the Goyt Valley and Buxton. Uphill the whole way. Eat first.")
m.sign(2, 22, "WEST: Chat Moss, the A57 and eventually Liverpool.")
# tall-grass tufts: gardens, canal bank, railway embankment
for (cx, cy, rx, ry) in [(35, 46, 2, 1), (56, 56, 3, 1), (7, 47, 3, 1), (22, 55, 2, 1), (10, 17, 2, 1), (52, 43, 3, 1)]:
    ell(m, cx, cy, rx, ry, ",", only=".")
# NPCs
m.npc(id="vane", sprite="vane", x=38, y=31, facing="down", move="still", script="vane", name="Lord Vane")
m.npc(id="manc_warden", sprite="warden_grunt", x=41, y=30, facing="left", move="still", script="warden_pop", name="Warden")
m.npc(id="manc_tram", sprite="villager_2", x=29, y=22, facing="down", move="wander", script="tram_fan", name="Tram Spotter")
m.npc(id="manc_boater", sprite="angler", x=16, y=12, facing="down", move="still", script="boater", name="Boater")
m.npc(id="manc_student", sprite="student", x=36, y=25, facing="left", move="wander", script="student", name="Student")
m.npc(id="manc_busker", sprite="villager_5", x=30, y=26, facing="right", move="still", script="busker", name="Busker")
m.npc(id="manc_guide", sprite="tour_guide", x=39, y=13, facing="up", move="still", script="town_hall_guide", name="Tour Guide")
m.npc(id="manc_bee", sprite="villager_3", x=45, y=24, facing="down", move="wander", script="bee_fan", name="Bee Fan")
rail_guard(m, 41, 40)
say("manchester", "vane", "Lord Ambrose Vane", "Do come in! Welcome to the Heritage Experience. Free tote bag with every signature.")
say("manchester", "rail_guard", "Rail Guard", "Piccadilly Station. Where do you fancy going?")
DLG["manchester"]["rail_guard"].append({"do": "rail"})
say("manchester", "warden_pop", "Warden", "We are not fencing anything. We are curating access.", "The tote bags are excellent, by the way. Very sturdy.")
say("manchester", "tram_fan", "Tram Spotter", "Manchester's Metrolink opened in 1992. I was there. I had a flask.", "It was the first modern tram system in the country. I know because I tell everybody.")
say("manchester", "boater", "Boater", "This is the Rochdale Canal. Opened 1804, closed in the 1950s, reopened in 2002. Nine lives, like a cat.", "The Bridgewater Canal, round the corner, was the first proper canal in Britain. Built in 1761 to carry coal.")
say("manchester", "student", "Student", "Rutherford split the atom here in 1917. And the first stored-program computer ran here in 1948. They called it the Baby.", "The Baby weighed about a tonne. Teething problems, you could say.")
say("manchester", "busker", "Busker", "Any requests? I know nine chords and a song about the rain.", "Everyone asks for the one about the rain.")
say("manchester", "town_hall_guide", "Tour Guide", "The Town Hall opened in 1877. Gothic revival, big clock, bigger bees.", "The worker bee is Manchester's emblem. It stands for hard work. The city did not invent the bee, but it did perfect the queue.")
say("manchester", "bee_fan", "Bee Fan", "Spot the bees on the lamp posts, the pavements, the bins. They're everywhere.", "The worker bee has been the city's symbol since the Victorians. Busy city, busy bees, busy brolly.")
m.d["encounters"] = {"grass": [
    {"species": "starlet", "min": 14, "max": 16, "weight": 22, "time": ["dawn", "day", "dusk"]},
    {"species": "swiftlet", "min": 14, "max": 16, "weight": 16, "time": ["day", "dusk"], "weather": ["clear", "sunshine", "gale"]},
    {"species": "cooplet", "min": 14, "max": 16, "weight": 20},
    {"species": "grizzlet", "min": 14, "max": 16, "weight": 14, "time": ["dawn", "dusk"]},
    {"species": "binfox", "min": 15, "max": 16, "weight": 16, "time": ["dusk", "night"]},
    {"species": "pepperling", "min": 14, "max": 16, "weight": 14, "time": ["dusk", "night"]},
    {"species": "flittermouse", "min": 14, "max": 16, "weight": 12, "time": ["night"]},
    {"species": "croakle", "min": 14, "max": 16, "weight": 10, "weather": ["drizzle", "downpour"]}],
    "water": [
    {"species": "holtling", "min": 14, "max": 16, "weight": 35},
    {"species": "dipling", "min": 14, "max": 16, "weight": 30},
    {"species": "croakle", "min": 14, "max": 16, "weight": 20}]}
m.d["edges"] = {"south": {"to": "goyt_valley", "offset": 0}, "west": {"to": "chat_moss", "offset": 0}}
m.d["spawn"] = [27, 29]
deco(m, 3, 17, 22, 5, ["bush"], 4, 201)
deco(m, 30, 27, 20, 8, ["bench", "planter", "bollard", "post_box"], 9, 211, on=":")
deco(m, 30, 35, 31, 10, ["planter", "bench", "lamp_post", "market_stall", "phone_box"], 12, 212, on=":")
deco(m, 3, 21, 22, 3, ["bush", "bench"], 5, 213, on=".")
deco(m, 3, 53, 58, 4, ["oak", "bush", "rock"], 14, 214, on=".")
deco(m, 3, 33, 22, 16, ["bush", "oak", "lamp_post"], 10, 215, on=".")
deco(m, 31, 45, 17, 3, ["oak", "bush"], 5, 216, on=".")
m.save(OUT + "/manchester.json")

# ---- Bev's Bikes (interior) ----
bi = interior("manc_bikes", "Bev's Bikes", 9, 8, 4, "manchester", bkf[0], bkf[1], music="town_city")
bi.rect(2, 2, 5, 1, "C")
bi.prop("bookshelf", 1, 1); bi.prop("bookshelf", 7, 1); bi.prop("table", 1, 5); bi.prop("table", 7, 4); bi.prop("potted_plant", 7, 6); bi.prop("potted_plant", 1, 6)
bi.npc(id="bev", sprite="bev", x=4, y=1, facing="down", move="still", script="bev", name="Bev")
bi.d["stage"] = "town"
bi.save(OUT + "/manc_bikes.json")
say("manc_bikes", "bev", "Bev", "Bike shop. If it has two wheels and a problem, I'll fix it.")
nurse_and_shop("manchester",
    ["Hello, love. Come in out of the drizzle. Manchester's weather is mostly a character reference.",
     "Right, pop them on the counter. We'll sort them out before the next shower.",
     "All done. Off you go. Keep your head up and your hood up.",
     "The Ark's just there. Please don't store anything that bites.",
     "No bother. The kettle's always on."],
    ["Welcome! Eccles cakes, brollies and a rather good pint of milk.", "Cheers, love. Mind the rain."])
