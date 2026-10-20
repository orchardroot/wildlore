from lib import *
from moor_content import IF, WHEN, SET

ST, ARM, ABBEY, THACK, DONE = ("q_pennines_bazaar_started", "q_pennines_bazaar_armouries", "q_pennines_bazaar_abbey",
                               "q_pennines_bazaar_thackray", "q_pennines_bazaar_done")
G = "{greeting}"

LEEDS_LEGEND = {
    "a": {"tile": "grass", "colour": "#3f7a34"},   # cricket outfield, striped
    "b": {"tile": "grass", "colour": "#4a8a3c"},
    "v": {"tile": "grass", "colour": "#5b7f3e"},   # parks
}


def build():
    z = Zone("leeds", "Leeds", 72, 56, fill="v", kind="town")
    z.extra = LEEDS_LEGEND
    W, H = z.w, z.h
    z.border("T", 2)
    # --- the Headrow, in from Saddleworth on the west, and Briggate crossing it
    z.rect(0, 24, W - 2, 3, ":")
    z.rect(0, 25, W - 2, 1, "=")
    z.rect(44, 4, 3, 33, ":")
    z.rect(45, 4, 1, 33, "=")
    z.rect(22, 0, 3, 24, ":")    # Otley Road north to Haworth
    z.rect(23, 0, 1, 24, "=")
    z.rect(2, 22, 20, 2, ":")
    z.rect(25, 22, 19, 2, ":")   # Town Hall forecourt
    z.rect(47, 22, W - 49, 2, ":")
    # --- Headingley, north-west: the cricket ground
    z.rect(3, 3, 17, 12, "a")
    for y in range(3, 15, 2):
        z.rect(3, y, 17, 1, "b")
    for x in range(3, 20):
        z.prop("stadium_stand", x, 3, variant=2 + 3 * (x % 5))
    for (x, y) in [(3, 4), (19, 4), (3, 14), (19, 14)]:
        z.prop("floodlight", x, y)
    z.prop("pitch_line", 6, 9, variant=10, walk=True)
    z.prop("rugby_posts", 10, 5, variant=0)
    z.prop("rugby_posts", 12, 5, variant=1)
    z.rect(9, 8, 5, 3, "b")
    z.building(6, 16, 9, 4, "red_brick", "Headingley Pavilion", "hall", door=10, to="leeds_headingley", tx=6, ty=6)
    z.rect(2, 20, 20, 2, "v")
    z.rect(10, 20, 1, 2, "#")
    z.rect(15, 16, 6, 4, "v")
    # --- civic centre: the Town Hall on the Headrow
    z.building(27, 11, 13, 10, "leeds_town_hall", "Leeds Town Hall", "hall", door=33, to="leeds_townhall", tx=7, ty=7)
    z.rect(25, 21, 19, 1, ":")
    z.rect(25, 4, 19, 6, "v")
    z.building(26, 4, 7, 4, "red_brick", "Leeds Art Gallery", "museum")
    z.building(35, 4, 8, 4, "stone", "Central Library", "library")
    z.rect(25, 8, 19, 2, ":")
    z.rect(25, 10, 2, 11, ":")
    z.rect(40, 10, 4, 11, ":")
    # --- Briggate and the Victoria Quarter, the curry house and Whitelock's
    z.building(47, 5, 6, 4, "red_brick", "Curry House", "cafe", door=49, to="leeds_curry", tx=5, ty=6)
    z.building(54, 5, 4, 4, "red_brick", "Whitelock's Ale House", "pub", door=55, to="leeds_whitelocks", tx=6, ty=7)
    z.building(59, 3, 10, 6, "red_brick", "Thackray Museum of Medicine", "museum", door=63, to="leeds_thackray", tx=6, ty=7)
    z.rect(47, 9, W - 49, 1, ":")
    z.rect(47, 10, W - 49, 4, "v")
    z.building(47, 11, 9, 3, "terrace", show_label=False)
    z.rect(47, 14, W - 49, 1, ":")
    # Corn Exchange and Kirkgate Market
    z.building(48, 15, 8, 6, "corn_exchange", "Corn Exchange", "hall", door=51, to="leeds_cornexchange", tx=6, ty=7)
    z.building(58, 15, 11, 6, "market_hall", "Kirkgate Market", "hall", door=63, to="leeds_kirkgate", tx=7, ty=8)
    z.rect(47, 21, W - 49, 1, ":")
    for x in (59, 61, 65, 67):
        z.prop("market_stall", x, 22, variant=x % 3)
    # --- west end, south of the Headrow: Sanctuary and shop, the way in from Saddleworth
    z.rect(2, 27, 20, 1, ":")
    z.building(3, 28, 6, 4, "sanctuary", "Sanctuary", door=5, to="leeds_sanctuary", tx=5, ty=6)
    z.building(10, 28, 5, 4, "shop", "Corner Shop", door=12, to="leeds_shop", tx=4, ty=5)
    z.building(16, 28, 6, 3, "terrace", show_label=False)
    z.rect(2, 32, 20, 1, ":")
    # parks and back streets
    z.rect(25, 27, 19, 6, "v")
    z.building(26, 28, 8, 3, "terrace", show_label=False)
    z.building(35, 28, 8, 3, "red_brick", show_label=False)
    z.rect(25, 31, 19, 2, ":")
    z.rect(47, 27, W - 49, 6, "v")
    z.building(48, 28, 9, 3, "stone", "Temple Works", "mill")
    z.building(59, 28, 10, 3, "terrace", show_label=False)
    z.rect(47, 31, W - 49, 2, ":")
    # --- the station, and the railway east-west
    z.rect(2, 33, W - 4, 2, ":")
    z.building(28, 33, 10, 2, "station", "Leeds Station", door=32)
    z.rect(26, 35, 14, 1, "_")
    z.rect(0, 36, W, 1, "!")
    for x in (23, 45):
        z.put(x, 36, "&")
    z.rect(2, 35, 24, 1, "v")
    z.rect(40, 35, W - 42, 1, "v")
    z.rect(22, 35, 3, 1, ":")
    z.rect(44, 35, 3, 1, ":")
    # --- south of the tracks: the river Aire and the canal basin
    z.rect(2, 37, W - 4, 2, "v")
    z.rect(2, 39, W - 4, 1, ":")
    z.rect(2, 40, W - 4, 2, "~")
    z.rect(44, 39, 3, 4, ":")    # Leeds Bridge
    z.rect(45, 39, 1, 4, "=")
    z.rect(22, 40, 3, 2, ":")    # a footbridge
    z.rect(2, 42, W - 4, 1, ":")
    for (x, v) in [(6, 0), (14, 1), (30, 0), (38, 1), (54, 0), (62, 1)]:
        z.prop("canal_boat", x, 40 + (x % 2), variant=v)
    # Kirkstall Abbey, Elland Road and the Royal Armouries
    z.rect(2, 43, W - 4, 11, "v")
    z.building(4, 45, 12, 6, "stone", "Elland Road", "hall", door=9, to="leeds_ellandroad", tx=8, ty=11)
    for (x, y) in [(3, 44), (16, 44), (3, 51), (16, 51)]:
        z.prop("floodlight", x, y)
    z.building(21, 44, 11, 7, "abbey_ruin", "Kirkstall Abbey", "church", door=26, to="leeds_kirkstall", tx=6, ty=8)
    z.building(52, 44, 12, 7, "glass_tower", "Royal Armouries", "museum", door=57, to="leeds_armouries", tx=7, ty=8)
    z.rect(65, 43, 5, 9, "~")    # Clarence Dock
    z.rect(64, 43, 1, 9, ":")
    z.rect(2, 51, W - 4, 1, ":")
    z.rect(9, 46, 1, 0, ":")
    for x in (9, 26, 57):
        z.rect(x, 43, 1, 1, ":")
    for (x, y) in [(18, 46), (19, 49), (34, 45), (36, 49), (40, 46), (46, 48), (48, 45), (33, 52), (12, 53), (60, 53)]:
        z.prop("oak", x, y, variant=(x + y) % 3)
    z.prop("boat", 67, 46, variant=1)
    z.rect(34, 44, 8, 5, ",")
    z.rect(3, 37, 18, 2, ",")
    z.rect(48, 37, 20, 2, ",")
    # street furniture
    for x in range(4, W - 4, 6):
        if z.get(x, 23) == ":":
            z.prop("lamp_post", x, 23)
        if z.get(x, 27) == ":" or z.get(x, 27) == "v":
            pass
    for (x, y) in [(42, 22), (25, 22), (21, 26), (47, 26), (60, 26), (8, 26), (30, 26), (36, 26)]:
        if z.get(x, y) == ":" and not any(p["x"] == x and p["y"] == y for p in z.props):
            z.prop("lamp_post", x, y)
    for (x, y, t) in [(27, 26, "bench"), (38, 26, "bench"), (52, 26, "post_box"), (16, 26, "phone_box"),
                      (43, 23, "planter"), (26, 23, "planter"), (24, 32, "bench"), (35, 32, "lamp_post"),
                      (50, 32, "lamp_post"), (66, 32, "bench"), (20, 39, "lamp_post"), (49, 39, "lamp_post"),
                      (14, 42, "bench"), (35, 42, "bench"), (60, 42, "lamp_post")]:
        z.prop(t, x, y)
    for (x, y) in [(29, 23), (31, 23), (35, 23), (37, 23)]:
        pass  # the Town Hall's lions are part of its steps
    z.prop("noticeboard", 20, 27)
    z.prop("flagpole", 41, 10, variant=0)

    # --- people
    z.npc("rail_guard", "rail_guard", 31, 35, "down", script="rail_guard")
    z.npc("leeds_lions", "villager_5", 30, 22, "down", script="leeds_lions", name="Night Owl", times=["night"])
    z.npc("leeds_loiner", "villager_1", 21, 25, "left", script="leeds_loiner", name="Loiner")
    z.npc("leeds_cricket", "villager_2", 16, 19, "up", script="leeds_cricket", name="Cricket Fan")
    z.npc("leeds_rhubarb", "farmer", 66, 23, "left", script="leeds_rhubarb", name="Rhubarb Grower")
    z.npc("leeds_temple", "steelworker", 53, 32, "up", script="leeds_temple", name="Old Millhand")
    z.npc("leeds_prince", "astronomer", 47, 39, "left", script="leeds_prince", name="Film Buff", times=["day", "dusk"])
    z.npc("leeds_student", "student", 34, 27, "down", script="leeds_student", name="Student",
          times=["day", "dusk", "night"])
    z.npc("leeds_fan", "rugby_player", 13, 43, "down", script="leeds_utd_fan", name="Leeds Fan")
    # trainers
    z.npc("leeds_t_shopper", "villager_6", 57, 25, "down", trainer="pennines_shopper")
    z.npc("leeds_t_student", "student", 43, 31, "left", trainer="pennines_medic")
    z.npc("leeds_t_canal", "canal_boater", 30, 39, "down", trainer="pennines_lockkeeper")
    z.npc("leeds_t_cricketer", "villager_3", 7, 12, "right", trainer="pennines_cricketer")

    # --- signs and plaques
    z.sign(2, 23, "LEEDS. Welcome to Yorkshire's biggest city. Please wipe your feet, there's a Town Hall.")
    z.sign(21, 23, "NORTH: Headingley, then the Aire valley to Haworth and the Brontë moors.")
    z.sign(3, 27, "WEST: Saddleworth Moor, Standedge and Manchester. Uphill. Very uphill.")
    z.sign(41, 21, "Leeds Town Hall was designed by Cuthbert Brodrick, a young architect from Hull, and opened by Queen "
                   "Victoria in 1858. Its clock tower made it the proudest building in the North. The four stone lions on "
                   "the steps were added in 1867, and legend says that when the clock strikes midnight they come down for a walk.",
           plaque="pennines_leeds_town_hall", title="Leeds Town Hall")
    z.sign(47, 20, "Brodrick won the Corn Exchange too, an oval hall under a great domed roof of glass and iron, opened in "
                   "the 1860s so corn merchants could judge their samples by daylight. The traders have gone, and shops fill "
                   "the floor and galleries now.",
           plaque="pennines_corn_exchange", title="The Corn Exchange")
    z.sign(57, 21, "In 1884 Michael Marks, a refugee from the Russian Empire, set up a stall at Kirkgate Market with a "
                   "sign reading 'Don't ask the price, it's a penny'. Ten years later he went into partnership with Thomas "
                   "Spencer, and Marks & Spencer was born. The market hall is one of the largest covered markets in Europe.",
           plaque="pennines_kirkgate_market", title="The Penny Bazaar")
    z.sign(20, 50, "Kirkstall Abbey was founded in 1152 by Cistercian monks who came from Fountains Abbey. They farmed sheep "
                   "and traded wool until Henry VIII closed the abbey in 1539. Its roofless church still stands nearly "
                   "whole, which is rare for a monastery in England.",
           plaque="pennines_kirkstall", title="Kirkstall Abbey")
    z.sign(51, 50, "The Royal Armouries is the national museum of arms and armour, the oldest museum in Britain. Much of "
                   "the collection moved here from the Tower of London in 1996. Its glass Hall of Steel holds about 2,500 "
                   "pieces of arms and armour, arranged in great patterns up the walls.",
           plaque="pennines_royal_armouries", title="The Royal Armouries")
    z.sign(43, 42, "In 1888 the French inventor Louis Le Prince filmed traffic crossing Leeds Bridge from a window nearby, "
                   "some of the earliest moving pictures ever made. Two years later he boarded a train in France and was "
                   "never seen again, and nobody knows what became of him.",
           plaque="pennines_le_prince", title="Leeds Bridge on Film")
    z.sign(23, 42, "The Leeds and Liverpool Canal runs 127 miles over the Pennines to the Mersey, the longest canal in "
                   "Britain built as a single waterway. It took nearly fifty years to finish, and opened end to end in 1816.",
           plaque="pennines_leeds_liverpool_canal", title="The Leeds and Liverpool Canal")
    z.sign(57, 32, "Temple Works was a flax mill built in the 1830s for John Marshall in the style of an ancient Egyptian "
                   "temple. Its huge single-storey roof was covered in grass, and sheep were grazed up there to keep it "
                   "trimmed.",
           plaque="pennines_temple_works", title="Sheep on the Roof")
    z.sign(15, 21, "Headingley is home to Yorkshire's cricketers and to the Leeds rugby league team, one ground beside the "
                   "other. In 1981 England were made to follow on against Australia here and still won, one of the most "
                   "famous turnarounds in Test cricket.",
           plaque="pennines_headingley", title="Headingley")
    z.sign(17, 52, "Leeds United play at Elland Road. The club was formed in 1919, and under the manager Don Revie in the "
                   "1960s and 70s it won the league twice and became one of the most feared sides in Europe.",
           plaque="pennines_elland_road", title="Elland Road")
    z.sign(63, 26, "Forced rhubarb is grown in the Rhubarb Triangle between Wakefield, Morley and Rothwell. The roots are "
                   "moved into warm, dark sheds in winter, where the stalks shoot up so fast you can hear them creak, and "
                   "they are picked by candlelight so the light doesn't stop them growing.",
           plaque="pennines_rhubarb_triangle", title="The Rhubarb Triangle")
    z.sign(56, 9, "Whitelock's is the oldest pub in Leeds, first licensed in 1715 and tucked down a narrow yard off "
                  "Briggate. Its long bar, brass and mirrors have barely changed in a century.",
           plaque="pennines_whitelocks", title="Whitelock's Ale House")

    d = z.to_dict(
        music="town_city",
        weather={"drizzle": 38, "clear": 22, "fog": 8, "gale": 7, "sunshine": 15, "downpour": 10},
        edges={"west": {"to": "saddleworth_moor", "offset": 0}, "north": {"to": "haworth", "offset": HAWORTH_OFFSET}},
        encounters={
            "grass": [
                {"species": "starlet", "min": 14, "max": 16, "weight": 18, "time": ["dawn", "day", "dusk"]},
                {"species": "cooplet", "min": 14, "max": 16, "weight": 18},
                {"species": "grizzlet", "min": 14, "max": 16, "weight": 14, "time": ["dawn", "day", "dusk"]},
                {"species": "binfox", "min": 15, "max": 16, "weight": 14, "time": ["dusk", "night"]},
                {"species": "pepperling", "min": 14, "max": 16, "weight": 12, "time": ["dusk", "night"]},
                {"species": "bobbin", "min": 14, "max": 16, "weight": 10},
                {"species": "swiftlet", "min": 14, "max": 16, "weight": 10, "time": ["day"], "season": ["spring", "summer"]},
                {"species": "flittermouse", "min": 14, "max": 16, "weight": 8, "time": ["night"]},
                {"species": "forcelet", "min": 14, "max": 16, "weight": 8, "time": ["dusk", "night"], "season": ["winter", "spring"]},
                {"species": "forcelet", "min": 14, "max": 16, "weight": 3},
                {"species": "tootlet", "min": 14, "max": 16, "weight": 6, "time": ["day", "dusk"]},
            ],
            "water": [
                {"species": "volet", "min": 14, "max": 16, "weight": 30},
                {"species": "minkshade", "min": 14, "max": 16, "weight": 20, "time": ["dusk", "night"]},
                {"species": "elverlet", "min": 14, "max": 16, "weight": 20},
                {"species": "dipling", "min": 14, "max": 16, "weight": 30},
            ],
        },
        spawn=[4, 25], stage="city", town_id="leeds", station={"x": 32, "y": 35}, scaled_floor=FLOOR)
    write_json("data/zones/leeds.json", d)
    return z


HAWORTH_OFFSET = 0


def rooms():
    L = "leeds"
    # Sanctuary and shop, copying the house pattern
    write_json("data/zones/leeds_sanctuary.json", interior(
        "leeds_sanctuary", "Leeds Sanctuary", 11, 9, 5, L, 5, 32, music="sanctuary",
        counters=[(x, 3) for x in range(3, 8)],
        props=[P("potted_plant", 1, 1), P("potted_plant", 9, 1), P("bookshelf", 1, 4), P("table", 9, 4)],
        npcs=[N("nurse", "sanctuary_nurse", 5, 2, script="nurse"),
              N("memory_coach", "poet", 8, 4, script="memory_coach", name="Retired Keeper")]))
    sanct = json.load(open(ROOT + "/data/zones/leeds_sanctuary.json"))
    sanct["rows"][6] = "x++|||||++x"
    write_json("data/zones/leeds_sanctuary.json", sanct)
    write_json("data/zones/leeds_shop.json", interior(
        "leeds_shop", "Leeds Corner Shop", 9, 8, 4, L, 12, 32,
        counters=[(2, 2), (3, 2), (4, 2), (6, 2), (7, 2), (6, 3), (7, 3), (6, 4), (7, 4)],
        props=[P("bookshelf", 1, 1), P("potted_plant", 7, 5)],
        npcs=[N("shopkeeper", "shopkeeper", 3, 1, script="shopkeeper")]))
    write_json("data/shops/leeds_corner_shop.json", {"id": "leeds_corner_shop", "name": "Leeds Corner Shop", "stock": [
        "cup_of_tea", "flask_of_tea", "bakewell_tart", "buxton_water", "smelling_salts", "kendal_mint_cake", "wicker_snare",
        "iron_snare", "night_snare", "water_snare", "yorkshire_pudding", "parkin", "curd_tart", "havercake", "forced_rhubarb",
        "lavender_sachet"]})

    # Town Hall: Victoria Hall with its organ
    write_json("data/zones/leeds_townhall.json", interior(
        "leeds_townhall", "Leeds Town Hall", 15, 10, 7, L, 33, 21, floor="+",
        props=[P("hall_stage", 6, 1, variant=0), P("hall_stage", 7, 1, variant=1), P("hall_stage", 8, 1, variant=2),
               P("piano", 4, 1), P("candelabra", 2, 2), P("candelabra", 12, 2), P("stacked_chairs", 1, 6),
               P("stacked_chairs", 13, 6, variant=1), P("rug", 5, 4, w=5, h=3, walk=True, variant=2),
               P("wall_picture", 10, 1, walk=True, variant=1), P("clock", 12, 1, walk=True), P("bench", 3, 5), P("bench", 11, 5)],
        npcs=[N("townhall_organist", "poet", 7, 3, script="townhall_organist", name="Organist")],
        signs=[{"x": 2, "y": 4, "text": "The Victoria Hall's great organ, built in the 1850s, was one of the largest in Europe when it was new. The hall has hosted concerts ever since, and the Leeds International Piano Competition, founded in 1961, is held in the city.",
                "plaque": "pennines_town_hall_organ", "title": "The Victoria Hall Organ"}]))
    write_json("data/zones/leeds_cornexchange.json", interior(
        "leeds_cornexchange", "Corn Exchange", 13, 10, 6, L, 51, 21, floor="+",
        props=[P("market_stall", 3, 3, variant=0), P("market_stall", 9, 3, variant=1), P("market_stall", 3, 6, variant=2),
               P("market_stall", 9, 6, variant=0), P("display_case", 6, 2), P("potted_plant", 1, 1), P("potted_plant", 11, 1),
               P("clock", 6, 1, walk=True)],
        npcs=[N("corn_vintage", "villager_5", 5, 4, script="corn_vintage", name="Vintage Trader"),
              N("corn_record", "festival_goer", 8, 5, script="corn_record", name="Record Seller")]))
    write_json("data/zones/leeds_kirkgate.json", interior(
        "leeds_kirkgate", "Kirkgate Market", 15, 11, 7, L, 63, 21,
        props=[P("market_stall", 2, 2, variant=0), P("market_stall", 4, 2, variant=1), P("market_stall", 10, 2, variant=2),
               P("market_stall", 12, 2, variant=0), P("market_stall", 2, 6, variant=1), P("market_stall", 12, 6, variant=2),
               P("fryer", 4, 6), P("menu_board", 4, 5, walk=True), P("tea_urn", 10, 6), P("clock", 7, 1, walk=True),
               P("display_case", 7, 3)],
        npcs=[N("bazaar_trader", "shopkeeper", 7, 4, script="bazaar_trader", name="Market Trader", facing="down"),
              N("kirkgate_butcher", "villager_2", 3, 4, script="kirkgate_butcher", name="Butcher"),
              N("kirkgate_fish", "fisherman_north", 11, 4, script="kirkgate_fish", name="Fishmonger")],
        signs=[{"x": 6, "y": 2, "text": "Kirkgate's market hall opened in 1904, all iron, glass and fancy ironwork. A clock still marks the spot where the original Marks & Spencer stall stood.",
                "plaque": "pennines_kirkgate_hall", "title": "The 1904 Market Hall"}]))
    write_json("data/zones/leeds_armouries.json", interior(
        "leeds_armouries", "Royal Armouries", 15, 11, 7, L, 57, 51, floor="+",
        props=[P("display_case", 2, 2), P("display_case", 4, 2), P("display_case", 10, 2), P("display_case", 12, 2),
               P("statue", 2, 6, variant=1), P("statue", 12, 6, variant=1), P("wall_picture", 7, 1, walk=True, variant=3),
               P("brazier", 1, 8), P("brazier", 13, 8), P("rug", 5, 4, w=5, h=4, walk=True, variant=0)],
        npcs=[N("armouries_curator", "tour_guide", 9, 3, script="armouries_curator", name="Curator"),
              N("armouries_armourer", "steelworker", 7, 3, trainer="pennines_armourer")],
        signs=[{"x": 5, "y": 2, "text": "The elephant armour here, made in India around 1600, is thought to be the only near-complete armour for an elephant anywhere in the world, thousands of small steel plates riveted together. Try not to imagine the fitting.",
                "plaque": "pennines_elephant_armour", "title": "The Elephant Armour"}]))
    write_json("data/zones/leeds_kirkstall.json", interior(
        "leeds_kirkstall", "Kirkstall Abbey", 13, 11, 6, L, 26, 51, floor="+",
        props=[P("crypt_arch", 2, 1, variant=0), P("crypt_arch", 10, 1, variant=1), P("tomb_chest", 6, 3),
               P("candelabra", 3, 5), P("candelabra", 9, 5), P("oak", 1, 8), P("bush", 11, 8), P("bench", 6, 7)],
        npcs=[N("abbey_volunteer", "poet", 4, 3, script="abbey_volunteer", name="Abbey Volunteer")],
        signs=[{"x": 9, "y": 3, "text": "The Cistercians were known as the white monks, from their undyed wool habits. They built in remote valleys, ran great sheep farms, and their lay brothers did much of the farm work.",
                "plaque": "pennines_white_monks", "title": "The White Monks"}]))
    write_json("data/zones/leeds_thackray.json", interior(
        "leeds_thackray", "Thackray Museum of Medicine", 13, 10, 6, L, 63, 9,
        props=[P("specimen_shelf", 1, 1), P("display_case", 4, 2), P("display_case", 8, 2), P("bed", 11, 2),
               P("kitchen_dresser", 11, 6), P("wall_picture", 6, 1, walk=True, variant=0), P("table", 2, 6)],
        npcs=[N("thackray_guide", "night_nurse", 6, 4, script="thackray_guide", name="Museum Guide")],
        signs=[{"x": 2, "y": 3, "text": "The museum stands in the old Leeds Union Workhouse of 1861. One gallery rebuilds a Victorian Leeds street, smells and all, to show how cholera spread before the city had proper sewers.",
                "plaque": "pennines_thackray", "title": "The Workhouse Museum"}]))
    write_json("data/zones/leeds_whitelocks.json", interior(
        "leeds_whitelocks", "Whitelock's Ale House", 13, 10, 6, L, 55, 9,
        counters=[(x, 2) for x in range(2, 10)],
        props=[P("fireplace", 11, 1), P("table", 3, 5), P("table", 9, 5), P("bench", 3, 6), P("bench", 9, 6),
               P("wall_picture", 11, 4, walk=True, variant=2), P("clock", 1, 1, walk=True), P("kitchen_dresser", 1, 4)],
        npcs=[N("whitelocks_landlord", "shopkeeper", 5, 1, script="whitelocks_quiz", name="Landlord"),
              N("whitelocks_regular", "villager_1", 10, 6, script="whitelocks_regular", name="Regular")]))
    write_json("data/zones/leeds_curry.json", interior(
        "leeds_curry", "Curry House", 11, 9, 5, L, 49, 9,
        counters=[(2, 2), (3, 2), (4, 2)],
        props=[P("table", 6, 3), P("table", 8, 3), P("table", 6, 5), P("table", 8, 5), P("menu_board", 3, 1, walk=True),
               P("potted_plant", 1, 6), P("wall_picture", 9, 1, walk=True, variant=1)],
        npcs=[N("curry_chef", "shopkeeper", 3, 1, script="curry_chef", name="Chef")]))
    write_json("data/zones/leeds_headingley.json", interior(
        "leeds_headingley", "Headingley Pavilion", 13, 9, 6, L, 10, 20,
        props=[P("wall_picture", 3, 1, walk=True, variant=0), P("wall_picture", 9, 1, walk=True, variant=3),
               P("display_case", 2, 3), P("display_case", 10, 3), P("tea_urn", 1, 6), P("bench", 4, 5), P("bench", 8, 5),
               P("clock", 6, 1, walk=True)],
        npcs=[N("headingley_legend", "rugby_player", 6, 3, trainer="pennines_legend"),
              N("headingley_scorer", "poet", 11, 6, script="headingley_scorer", name="Scorer")]))
    # Elland Road: the stands round the pitch, like the Arms Park
    rows = ["x" * 17] + ["x" + "|" * 15 + "x"] + ["x|" + ("b" if i % 2 == 0 else "a") * 13 + "|x" for i in range(8)] + \
           ["x|" + "+" * 13 + "|x", "x" + "|" * 15 + "x", "x|||||||D|||||||x", "x" * 17]
    ell = interior("leeds_ellandroad", "Elland Road", 17, 14, 8, L, 9, 51, rows_override=rows,
                   props=[P("stadium_stand", x, 1, variant=2 + 3 * (x % 4)) for x in range(1, 16)] +
                         [P("floodlight", 2, 2), P("floodlight", 14, 2), P("pitch_line", 2, 5, variant=13, walk=True),
                          P("pitch_line", 2, 9, variant=13, walk=True), P("bench", 3, 11), P("bench", 13, 11),
                          P("flagpole", 1, 10, variant=0), P("flagpole", 15, 10, variant=0)],
                   npcs=[N("elland_steward", "villager_4", 12, 11, script="elland_steward", name="Steward", facing="left"),
                         N("elland_ultra", "rugby_player", 5, 6, trainer="pennines_ultra")])
    ell["legend_extra"] = {"a": {"tile": "grass", "colour": "#335a2c"}, "b": {"tile": "grass", "colour": "#3b6332"}}
    write_json("data/zones/leeds_ellandroad.json", ell)

    # ------------------------------------------------------------------ dialogue
    write_json("data/dialogue/leeds.json", {
        "rail_guard": [say("Rail Guard", G + " Leeds Station. One of the busiest in the North, and we've the queues to prove it."),
                       say("Rail Guard", "All aboard for wherever you've been before. Mind the gap and the pigeon."), {"do": "rail"}],
        "leeds_lions": chat("Night Owl",
            "Shh. It's nearly midnight. They say when the Town Hall clock strikes twelve, the lions get up and go for a walk.",
            "I've waited three nights now. I did see one blink. Or I blinked. One of us blinked."),
        "leeds_loiner": chat("Loiner",
            G + " A Loiner, that's what you call someone from Leeds. Nobody's sure why. Something about loins, or loaning, or loitering. I'm loitering, so it fits.",
            "Leeds got rich on wool. Cloth halls, mills, merchants. Then tailoring: at one time Burton's in Leeds was the biggest clothing factory in the world."),
        "leeds_cricket": chat("Cricket Fan",
            G + " Yorkshire cricket. We take it seriously. We take tea seriously too, and that's half a cricket match, tea.",
            "Rugby league's next door. Same ground, different shaped ball, more mud."),
        "leeds_rhubarb": chat("Rhubarb Grower",
            G + " Forced rhubarb, fresh from the sheds. We grow it in the dark and pick it by candlelight. If you stand still in the shed you can hear it creak as it grows.",
            "It's got protected status now, like champagne. Yorkshire forced rhubarb. Say it with respect."),
        "leeds_temple": chat("Old Millhand",
            G + " Temple Works. A flax mill dressed up as an Egyptian temple. Daft, beautiful, and they kept sheep on the roof.",
            "Proper sheep. Grass roof. The idea was the turf kept the air damp for the linen thread. And the sheep kept the turf down. Everyone wins, especially the sheep."),
        "leeds_prince": chat("Film Buff",
            "This is where it all started, you know. Louis Le Prince stood in a window up there in 1888 and filmed carts going over Leeds Bridge.",
            "Before the famous names in Paris and America. Then he vanished off a train in France in 1890. Biggest mystery in cinema."),
        "leeds_student": chat("Student",
            G + " Otley Run tonight. Fancy dress, a pub crawl up the Otley Road, and a lot of people dressed as bananas.",
            "I've an essay due on the Brontës. I'm going to Haworth to soak up the atmosphere. Also the pub."),
        "leeds_utd_fan": chat("Leeds Fan",
            G + " Marching on Together! That's our song. Leeds United, Elland Road, through thick and thin. Mostly thin.",
            "We won the league in 1969, 1974 and 1992. I could tell you about every goal. Pull up a bench."),
    })
    write_json("data/dialogue/leeds_shop.json", {"shopkeeper": [
        say("Shopkeeper", G + " Tea, snares, curd tart and a bit of forced rhubarb for them as likes a sharp start. What'll it be?"),
        {"do": "shop", "id": "leeds_corner_shop"},
        say("Shopkeeper", "Ta-ra, love. Mind how you go on the Headrow, the buses don't.")]})
    write_json("data/dialogue/leeds_townhall.json", {"townhall_organist": chat("Organist",
        G + " Victorian Leeds wanted to show Manchester and Bradford who was boss. So: the grandest town hall in the land, the tallest clock tower, and an organ to rattle your fillings.",
        "Queen Victoria came to open it in 1858. The whole town turned out. Some say they're still clearing up the bunting.")})
    write_json("data/dialogue/leeds_cornexchange.json", {
        "corn_vintage": chat("Vintage Trader", G + " Merchants used to stand here judging corn by the light from the roof. Now it's me judging your jacket. It's... brave.",
                             "Look up at the dome. That's the whole point of the building, that light."),
        "corn_record": chat("Record Seller", "Leeds has always had a music scene. Students, clubs, bands in back rooms. Flick through, find something loud."),
    })
    bazaar = [IF(DONE, [
        say("Market Trader", G + " The display's up by the clock. People come and look, then buy a penny chew. History in action."),
    ], [IF(ST, [IF(ARM, [IF(ABBEY, [IF(THACK, [
        say("Market Trader", "A toy knight from the Armouries, a fleece from Kirkstall and a pill tin from the Thackray. That's Leeds in a box, that."),
        say("Market Trader", "Marks started with a tray round his neck and a penny sign. This'll go by the clock where his stall stood. Here, something for your trouble."),
        {"do": "give_item", "item": "penny_bazaar_tin"},
        {"do": "give_item", "item": "forced_rhubarb", "n": 3},
        {"do": "give_creature", "species": "bobbin", "level": 15},
        say("Market Trader", "That Bobbin's been living in the old wool stall since the 1970s. It wants to see the world. Or at least Bradford."),
        {"do": "standing", "nation": "england", "amount": 3},
        SET(DONE),
    ], [say("Market Trader", "Still need summat from the Thackray Museum, up the top end past Briggate. Something medical. Nothing squelchy.")])],
        [say("Market Trader", "Still need summat from Kirkstall Abbey, over the river. The monks were wool men, like this market.")])],
        [say("Market Trader", "Still need summat from the Royal Armouries down by the dock. Mind the armourer, he likes a scrap.")]),
    ], [
        say("Market Trader", G + " You're stood near where Marks and Spencer began. Michael Marks, 1884, a stall and a sign: Don't ask the price, it's a penny."),
        say("Market Trader", "We're doing a display for the market's birthday. Leeds in a box. I need three things: something from the Royal Armouries, something from Kirkstall Abbey, and something from the Thackray Museum."),
        SET(ST),
        say("Market Trader", "Off you pop. And don't ask the price. It's a favour."),
    ])])]
    write_json("data/dialogue/leeds_kirkgate.json", {
        "bazaar_trader": bazaar,
        "kirkgate_butcher": chat("Butcher", G + " Butchers' Row used to be all one long line of us. Tripe, pies, black pudding. Now try saying 'no thanks' to a pork pie in a Leeds accent."),
        "kirkgate_fish": chat("Fishmonger", G + " Haddock, not cod, round here. And chips in beef dripping if you go to the right chippy. Don't tell the vegetarians."),
    })
    write_json("data/dialogue/leeds_armouries.json", {"armouries_curator": [IF(ARM, [
        say("Curator", G + " Did the armourer give you the toy knight? He's been polishing it all week. Don't tell him it's tin."),
    ], [
        say("Curator", G + " The Hall of Steel's a staircase tower lined with swords, pikes and breastplates, set out in patterns like a Victorian trophy wall."),
        IF(ST, [IF("trainer_pennines_armourer", [
            say("Curator", "You beat our armourer? Then this is yours for the market. A little tin knight from the shop. Very historically inaccurate. Very popular."),
            SET(ARM),
        ], [say("Curator", "For Kirkgate? You'll have to get past the armourer first. He gives nothing away without a bout.")])]),
    ])]})
    write_json("data/dialogue/leeds_kirkstall.json", {"abbey_volunteer": [IF(ST, [IF(ABBEY, [
        say("Abbey Volunteer", "The fleece is for the market display? Lovely. The monks would approve. They'd have sold it to Florence, mind."),
    ], [
        say("Abbey Volunteer", "Kirkstall's wool went as far as Italy. Merchants bought it years ahead. The monks ran up debts doing deals on wool they hadn't sheared yet."),
        say("Abbey Volunteer", "Here, take this fleece from the farm shop for the market. Kirkstall to Kirkgate, wool all the way."),
        SET(ABBEY),
    ])], [
        say("Abbey Volunteer", G + " White monks, grey stone, eight hundred years. The roof went in Henry's time, but the walls are tough as old boots."),
        say("Abbey Volunteer", "Painters loved this place. Turner came and sketched it. So did a lot of people with less talent and bigger hats."),
    ])]})
    write_json("data/dialogue/leeds_thackray.json", {"thackray_guide": [IF(ST, [IF(THACK, [
        say("Museum Guide", "Enjoy the pill tin. It's empty. Please don't fill it with anything from the Victorian street gallery."),
    ], [
        say("Museum Guide", "This was a workhouse. Then a hospital. Now a museum of how we stopped dying of everything. Progress!"),
        say("Museum Guide", "For the market? Have an old pill tin. Leeds was famous for surgical instruments, you know. Very sharp people."),
        SET(THACK),
    ])], [
        say("Museum Guide", G + " Before sewers, cholera swept through Leeds in 1832 and again later. Doctors worked out it was the water, not bad smells, and the city built proper drains."),
        say("Museum Guide", "Try the gallery where you're the patient. Nobody comes out without wincing."),
    ])]})
    write_json("data/dialogue/leeds_whitelocks.json", {
        "whitelocks_quiz": [say("Landlord", G + " Oldest pub in Leeds, 1715. Quiz night every night if you ask nicely."),
                            {"do": "quiz", "pub": "leeds_whitelocks", "region": "england_north", "who": "Landlord"}],
        "whitelocks_regular": chat("Regular", G + " Pull up a stool. Them mirrors are older than my granddad. So's the beer, if you believe the landlord."),
    })
    write_json("data/dialogue/leeds_curry.json", {"curry_chef": chat("Chef",
        G + " Leeds and Bradford do a cracking curry. Families came from Pakistan, India and Bangladesh to work in the mills in the 1950s and 60s, and brought the cooking with them.",
        "Now a curry's as Yorkshire as a pudding. Some say Bradford's the curry capital of Britain. Don't say that too loud in Leeds.")})
    write_json("data/dialogue/leeds_headingley.json", {"headingley_scorer": chat("Scorer",
        G + " Headingley's had cricket since 1890. Yorkshire play here, and England in the summer Tests.",
        "Rugby league was born just down the road. In 1895 the northern clubs met at the George Hotel in Huddersfield and broke away from the rugby union. Broken-time payments, love. Workers couldn't afford to miss a Saturday shift.")})
    write_json("data/dialogue/leeds_ellandroad.json", {"elland_steward": chat("Steward",
        G + " Elland Road, home of Leeds United since 1919. The Kop's that way. You'll hear it before you see it.",
        "There's a statue of Billy Bremner outside, the little Scottish captain. Big heart, red hair, never stopped running.")})

    # ------------------------------------------------------------------ trainers
    trainer("pennines_shopper", "Shopper Bev", "Shopper", "villager_6", [("cooplet", 15), ("starlet", 15), ("binfox", 16)],
            "I've done Briggate, the Victoria Quarter and the market, and I've still got energy for you.",
            "Right. I'm going for a sit down in the Corn Exchange.", "The arcades were done up by the bloke who did theatres. That's why shopping here feels like a show.")
    trainer("pennines_medic", "Medical Student Priya", "Student", "student", [("pepperling", 15), ("bobbin", 16)],
            "Third year medicine. I've revised all night and I'm feeling invincible, which is a known symptom of no sleep.",
            "I'll diagnose that as a thrashing.", "Leeds has trained doctors since 1831. I'm trying not to be the one they remember.")
    trainer("pennines_lockkeeper", "Lock-keeper Arthur", "Lock-keeper", "canal_boater", [("volet", 15), ("minkshade", 16), ("dipling", 16)],
            "Hundred and twenty-seven miles of cut from here to Liverpool, and every lock's got a keeper with opinions.",
            "Well, that's me left high and dry.", "Bingley Five Rise is up the line. Five locks in a staircase, steepest in Britain.")
    trainer("pennines_cricketer", "Cricketer Dickie", "Cricketer", "villager_3", [("starlet", 15), ("swiftlet", 16), ("grizzlet", 16)],
            ["Fancy a net? I'll bowl. You battle. Same thing, really, only with more shouting.",
             "Howzat!"],
            "Out. Clean bowled. I'll walk.", "Yorkshire cricket has a long memory. We're still on about 1981, and we won that one.")
    trainer("pennines_armourer", "Armourer Godfrey", "Armourer", "steelworker", [("bobbin", 15), ("cutlet", 16), ("gritling", 16)],
            ["Steel, leather and rivets. Every piece in this hall was made to be used. Let's see if you were.",
             "En garde, as they say. Then they usually fall over in the armour."],
            "A palpable hit. Fair's fair.", "Jousting armour was so heavy the knights were hoisted on to their horses. Well, sometimes. The rest is films.")
    trainer("pennines_ultra", "Leeds Fan Shaz", "Football Fan", "rugby_player", [("binfox", 16), ("grizzlet", 16), ("cooplet", 16)],
            ["We're Leeds, and we're proud of it! Marching on Together!",
             "You're in our end now, love."],
            "Ah, we'll win next week. We always say that.", "Supporting Leeds is good training for life. Highs, lows, and a lot of rain.")
    trainer("pennines_legend", "Big Mal of Headingley", "Rugby League Legend", "rugby_player",
            [("bufomire", 17), ("brockling", 17), ("swiftlet", 17), ("bobbin", 18), ("snowhare", 18), ("cutlet", 18)],
            ["Forty years in the pack. Two knees, one nose, and a medal for every bone I've broken.",
             "They call me a legend in this pavilion. Let's see if you can tackle one."],
            "That's a try for you, and a pint for me. Fair result.",
            "Rugby league's thirteen a side, union's fifteen. We left the extra two at the bar.", money=1400)


if __name__ == "__main__":
    build()
    rooms()
