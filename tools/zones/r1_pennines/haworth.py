from lib import *
from moor_content import IF, WHEN, SET
from moor import MOOR_LEGEND

ST, WITHENS, BULL, VAULT, DONE = ("q_pennines_bronte_started", "q_pennines_bronte_withens", "q_pennines_bronte_bull",
                                  "q_pennines_bronte_vault", "q_pennines_bronte_done")
G = "{greeting}"


def band(y):
    return 3 if y <= 19 else (2 if y <= 26 else (1 if y <= 33 else 0))


def build():
    z = Zone("haworth", "Haworth", 60, 48, fill="m", kind="town")
    z.extra = dict(MOOR_LEGEND)
    z.extra["s"] = {"tile": "cobbles", "colour": "#8a8072"}  # the setts of Main Street
    W, H = z.w, z.h
    import random
    rnd = random.Random(1847)
    for y in range(H):
        for x in range(W):
            r = rnd.random()
            z.g[y][x] = "m" if r < 0.6 else ("." if r < 0.85 else ("n" if r < 0.95 else "e"))
    z.border("T", 2)
    for y in range(H):
        for x in range(W):
            z.hts[y][x] = band(y) if x < 44 else 0
    # the valley side: town up on the hill, the railway down in the bottom
    z.rect(43, 0, 2, 34, "T")
    # --- the lane in from Leeds and Keighley, then Main Street climbing the hill
    z.rect(22, 11, 3, H - 11, "s")
    z.rect(22, 42, 3, H - 42, ":")
    z.rect(23, 42, 1, H - 42, "=")
    z.rect(12, 9, 24, 3, "s")      # Church Street, along the top
    # the top of the town: Parsonage, church, Black Bull, apothecary
    z.rect(3, 3, 9, 8, "v")
    z.building(3, 3, 8, 4, "parsonage", "Brontë Parsonage", "museum", door=7, to="haworth_parsonage", tx=6, ty=7)
    z.building(13, 3, 8, 6, "pennine_church", "St Michael and All Angels", "church", door=15, to="haworth_church", tx=6, ty=7)
    z.building(25, 5, 6, 4, "gritstone", "The Black Bull", "pub", door=27, to="haworth_blackbull", tx=6, ty=7)
    z.building(32, 5, 5, 4, "gritstone", "Apothecary", "cafe", door=34, to="haworth_apothecary", tx=5, ty=6)
    z.rect(3, 7, 9, 2, "v")
    z.rect(3, 9, 9, 1, "#")
    z.rect(7, 7, 1, 2, "#")
    for (x, y, v) in [(4, 8, 0), (6, 8, 1), (9, 8, 2), (10, 7, 0), (4, 10, 1), (9, 10, 2)]:
        z.prop("tomb_chest", x, y, variant=v)
    z.rect(21, 3, 4, 6, "v")
    z.prop("oak", 22, 4)
    z.prop("oak", 37, 6)
    z.rect(37, 3, 6, 6, "v")
    # Main Street's cottages and shops, stepping down the hill
    for (y, h) in [(13, 4), (21, 4), (28, 4), (35, 4)]:
        z.building(15, y, 6, h, "weavers_cottage", show_label=False)
        z.building(26, y, 6, h, "weavers_cottage", show_label=False)
    z.rect(15, 21, 6, 4, "m")
    z.rect(26, 21, 6, 4, "m")
    z.building(15, 21, 6, 4, "shop", "Corner Shop", door=17, to="haworth_shop", tx=4, ty=5)
    z.building(26, 21, 6, 4, "sanctuary", "Sanctuary", door=28, to="haworth_sanctuary", tx=5, ty=6)
    z.rect(14, 25, 8, 1, "s")
    z.rect(25, 25, 8, 1, "s")
    for (x, y) in [(21, 14), (25, 14), (21, 22), (25, 22), (21, 30), (25, 30), (21, 37), (25, 37)]:
        z.prop("lamp_post", x, y)
    for (x, y) in [(15, 12), (27, 12), (31, 20), (14, 33)]:
        z.prop("hanging_basket", x, y, walk=True)
    z.prop("bunting", 23, 18, walk=True)
    z.prop("bunting", 23, 27, walk=True)
    z.prop("bench", 33, 26)
    z.prop("post_box", 21, 26)
    # the park, and Station Road down to the Worth Valley line
    z.rect(34, 12, 9, 22, "v")
    for (x, y) in [(36, 14), (40, 16), (37, 20), (41, 23), (35, 30), (40, 31)]:
        z.prop("oak", x, y, variant=(x + y) % 3)
    z.rect(25, 40, 26, 1, "s")
    z.rect(44, 34, 15, 13, "v")
    z.rect(52, 0, 1, 42, "!")
    z.prop("buffer_stop", 52, 42)
    z.rect(50, 28, 2, 12, "_")
    z.building(45, 32, 5, 3, "station", "Haworth Station (KWVR)", door=47, to="haworth_station", tx=5, ty=6)
    z.rect(45, 35, 5, 6, "v")
    z.rect(47, 35, 1, 5, "s")
    z.rect(53, 2, 5, 40, "m")
    z.prop("bench", 51, 30) if False else None
    for y in (30, 36):
        z.prop("lamp_post", 49, y + 1) if False else None
    z.prop("lamp_post", 49, 37)
    z.prop("flagpole", 46, 37, variant=0)
    for (x, y) in [(55, 10), (56, 20), (54, 33), (57, 40)]:
        z.prop("birch", x, y)
    # --- the moor west of town: the Brontë Way to the waterfall and Top Withens
    z.rect(2, 12, 11, H - 14, "h")
    z.rect(2, 12, 11, 2, "m")
    z.rect(9, 12, 13, 1, "#")   # from Main Street, west on to the moor
    z.rect(9, 12, 1, 26, "#")
    z.rect(3, 37, 7, 1, "#")
    z.building(3, 16, 5, 3, "field_barn", "Top Withens (ruin)", "ruin")
    z.rect(3, 19, 6, 1, "#")
    z.rect(8, 16, 1, 3, "#") if False else None
    z.prop("oak", 8, 15, variant=2)
    # Sladen Beck, the Brontë waterfall and the bridge
    z.rect(4, 22, 2, 14, "~")
    z.rect(3, 26, 1, 3, "o")
    z.prop("cascade", 4, 23, variant=0)
    z.rect(4, 31, 2, 1, ":")
    z.rect(6, 31, 3, 1, "#")
    z.rect(2, 31, 2, 1, "#")
    z.prop("rock", 7, 25)
    z.prop("rock", 2, 29)
    for (x, y) in [(10, 15), (11, 20), (12, 27), (10, 33), (6, 40), (11, 41)]:
        z.put(x, y, "G")

    # --- people
    z.npc("bronte_walker", "hillwalker", 9, 20, "left", script="bronte_walker", name="Brontë Walker")
    z.npc("bronte_keeper", "villager_6", 7, 10, "down", script="bronte_keeper_tale", name="Dog Walker")
    z.npc("haworth_setts", "villager_1", 24, 16, "left", script="haworth_setts", name="Local")
    z.npc("haworth_steam", "rail_guard", 50, 33, "right", script="haworth_steam", name="Volunteer Porter")
    z.npc("haworth_ghost", "lamplighter", 23, 34, "up", script="haworth_ghost", name="Ghost Walk Guide", times=["dusk", "night"])
    z.npc("haworth_victorian", "mum", 36, 25, "down", script="haworth_victorian", name="Victorian Weekend Fan", times=["day"])
    z.npc("withens_heathcliff", "poet", 6, 19, "up", trainer="pennines_heathcliff")
    z.npc("haworth_t_steam", "steelworker", 50, 29, "down", trainer="pennines_fireman")
    z.npc("haworth_t_rambler", "hiker", 8, 31, "down", trainer="pennines_bronteway")
    z.npc("haworth_t_ghost", "tour_guide", 33, 11, "left", trainer="pennines_ghosthunter")

    # --- signs and plaques
    z.sign(25, 44, "HAWORTH. Up the hill for the Parsonage, down the hill for the steam trains. Either way, it's a hill.")
    z.sign(21, 44, "SOUTH: Keighley, the Aire valley and Leeds.")
    z.sign(10, 13, "THE BRONTË WAY. To the waterfall and Top Withens, over the moor. Proper boots, please. And a book.")
    z.sign(11, 10, "Patrick Brontë came here as perpetual curate in 1820, and his children grew up in this house above "
                   "the churchyard. Charlotte, Emily and Anne wrote their novels at the dining table, walking round and "
                   "round it as they talked. The Brontë Society opened it as a museum in 1928.",
           plaque="pennines_parsonage", title="The Brontë Parsonage")
    z.sign(12, 4, "In 1847 three novels came out under the names Currer, Ellis and Acton Bell: Jane Eyre, Wuthering Heights "
                  "and Agnes Grey. The authors were Charlotte, Emily and Anne Brontë, who chose names that would not give "
                  "away that they were women.",
           plaque="pennines_bells", title="Currer, Ellis and Acton Bell")
    z.sign(9, 17, "Top Withens is a ruined farmhouse often said to have given Emily the setting for Wuthering Heights. A "
                  "plaque on the ruin itself is more careful: the buildings, it says, bear no resemblance to the house she "
                  "described. The view, everyone agrees, is the right one.",
           plaque="pennines_top_withens", title="Top Withens")
    z.sign(31, 9, "The Black Bull stands at the top of Main Street, beside the church. Branwell Brontë, the sisters' "
                  "brother, a painter and poet of great promise, spent too many evenings here, and his decline darkened the "
                  "family's last years.",
           plaque="pennines_black_bull", title="The Black Bull")
    z.sign(37, 9, "Across from the Black Bull was the village druggist. Branwell bought laudanum, a medicine made from "
                  "opium, which you could buy over the counter in the 1840s. The old shop is still an apothecary today.",
           plaque="pennines_apothecary", title="The Apothecary")
    z.sign(21, 20, "Main Street is paved with stone setts laid on end so horses could grip on the slope. In 1850 a "
                   "government inspector found Haworth's water fouled by the crowded churchyard, and the average age at "
                   "death in the village was about twenty-five.",
           plaque="pennines_main_street", title="Main Street")
    z.sign(21, 7, "All the Brontës except Anne lie in the family vault beneath the church. Anne died in Scarborough in "
                  "1849 and is buried there, by the sea. The church was rebuilt in the 1870s, and only the tower is the "
                  "one the family knew.",
           plaque="pennines_bronte_vault", title="The Family Vault")
    z.sign(50, 41, "The Keighley and Worth Valley Railway opened in 1867. British Railways closed it at the end of 1961, and "
                   "volunteers bought it and reopened it in 1968, one of the first heritage railways in Britain. The film "
                   "The Railway Children was made along the line in 1970.",
           plaque="pennines_kwvr", title="The Worth Valley Line")
    z.sign(6, 32, "The sisters loved this walk to the waterfall on Sladen Beck. A stone by the beck shaped like a seat is "
                  "still called the Brontë Chair, and the little clapper bridge is the Brontë Bridge.",
           plaque="pennines_bronte_falls", title="The Brontë Waterfall")

    d = z.to_dict(
        music="town_north",
        weather={"drizzle": 34, "fog": 20, "clear": 18, "gale": 14, "sunshine": 8, "downpour": 6},
        edges={"south": {"to": "leeds", "offset": 0}},
        encounters={
            "grass": [
                {"species": "sphagnet", "min": 14, "max": 16, "weight": 14, "weather": ["drizzle", "downpour", "fog"]},
                {"species": "pipkin", "min": 14, "max": 16, "weight": 14, "time": ["dawn", "day"]},
                {"species": "scuttlet", "min": 14, "max": 16, "weight": 16, "time": ["dawn", "day", "dusk"]},
                {"species": "hootlet", "min": 14, "max": 16, "weight": 10, "time": ["dusk", "night"]},
                {"species": "barnling", "min": 14, "max": 16, "weight": 8, "time": ["night"]},
                {"species": "wispet", "min": 14, "max": 16, "weight": 10, "weather": ["fog"]},
                {"species": "gritling", "min": 14, "max": 16, "weight": 12},
                {"species": "rooklet", "min": 14, "max": 16, "weight": 10, "time": ["dawn", "day", "dusk"]},
                {"species": "flittermouse", "min": 14, "max": 16, "weight": 8, "time": ["night"]},
                {"species": "bogglet", "min": 14, "max": 16, "weight": 8, "time": ["dusk", "night"]},
                {"species": "boggart", "min": 15, "max": 16, "weight": 3, "time": ["night"], "weather": ["fog"]},
            ],
            "water": [
                {"species": "dipling", "min": 14, "max": 16, "weight": 40},
                {"species": "volet", "min": 14, "max": 16, "weight": 30},
                {"species": "croakle", "min": 14, "max": 16, "weight": 30},
            ],
        },
        spawn=[23, 45], stage="moor", town_id="haworth", scaled_floor=FLOOR)
    write_json("data/zones/haworth.json", d)
    return z


def rooms():
    Hw = "haworth"
    write_json("data/zones/haworth_sanctuary.json", interior(
        "haworth_sanctuary", "Haworth Sanctuary", 11, 9, 5, Hw, 28, 25, music="sanctuary",
        counters=[(x, 3) for x in range(3, 8)],
        props=[P("potted_plant", 1, 1), P("potted_plant", 9, 1), P("bookshelf", 1, 4), P("table", 9, 4)],
        npcs=[N("nurse", "sanctuary_nurse", 5, 2, script="nurse"),
              N("memory_coach", "poet", 8, 4, script="memory_coach", name="Retired Keeper")]))
    s = json.load(open(ROOT + "/data/zones/haworth_sanctuary.json"))
    s["rows"][6] = "x++|||||++x"
    write_json("data/zones/haworth_sanctuary.json", s)
    write_json("data/zones/haworth_shop.json", interior(
        "haworth_shop", "Haworth Corner Shop", 9, 8, 4, Hw, 17, 25,
        counters=[(2, 2), (3, 2), (4, 2), (6, 2), (7, 2), (6, 3), (7, 3), (6, 4), (7, 4)],
        props=[P("bookshelf", 1, 1), P("potted_plant", 7, 5)],
        npcs=[N("shopkeeper", "shopkeeper", 3, 1, script="shopkeeper")]))
    write_json("data/shops/haworth_corner_shop.json", {"id": "haworth_corner_shop", "name": "Haworth Corner Shop", "stock": [
        "cup_of_tea", "flask_of_tea", "bakewell_tart", "buxton_water", "smelling_salts", "kendal_mint_cake", "wicker_snare",
        "iron_snare", "night_snare", "water_snare", "parkin", "havercake", "curd_tart", "lavender_sachet"]})
    write_json("data/zones/haworth_parsonage.json", interior(
        "haworth_parsonage", "Brontë Parsonage", 13, 10, 6, Hw, 7, 7,
        props=[P("table", 5, 4), P("table", 7, 4), P("fireplace", 2, 1), P("bookshelf", 10, 1), P("piano", 11, 4),
               P("display_case", 1, 5), P("clock", 6, 1, walk=True), P("wall_picture", 4, 1, walk=True, variant=2),
               P("wall_picture", 8, 1, walk=True, variant=0), P("rug", 4, 3, w=5, h=3, walk=True, variant=1), P("sofa", 11, 6, rot=270)],
        npcs=[N("parsonage_curator", "tour_guide", 6, 6, script="parsonage_curator", name="Curator", facing="down")],
        signs=[{"x": 1, "y": 3, "text": "As children the Brontës wrote tiny books, some no bigger than a matchbox, in minute handwriting, full of the imaginary kingdoms of Angria and Gondal. A few are on show here.",
                "plaque": "pennines_little_books", "title": "The Little Books"},
               {"x": 9, "y": 3, "text": "Emily's dog Keeper, a big mastiff cross, walked behind her coffin to the church in 1848 and lay outside her bedroom door for weeks afterwards. His brass collar is kept here.",
                "plaque": "pennines_keeper", "title": "Keeper"}]))
    write_json("data/zones/haworth_church.json", interior(
        "haworth_church", "St Michael and All Angels", 13, 10, 6, Hw, 15, 9, floor="+",
        props=[P("bench", 3, 4), P("bench", 4, 4), P("bench", 8, 4), P("bench", 9, 4), P("bench", 3, 6), P("bench", 4, 6),
               P("bench", 8, 6), P("bench", 9, 6), P("candelabra", 2, 2), P("candelabra", 10, 2), P("tomb_chest", 6, 2),
               P("crypt_arch", 11, 1, variant=1)],
        npcs=[N("church_verger", "poet", 6, 3, script="church_verger", name="Verger", facing="down")]))
    write_json("data/zones/haworth_blackbull.json", interior(
        "haworth_blackbull", "The Black Bull", 13, 10, 6, Hw, 27, 9,
        counters=[(x, 2) for x in range(2, 9)],
        props=[P("fireplace", 11, 1), P("table", 3, 5), P("table", 9, 5), P("bench", 3, 6), P("bench", 9, 6),
               P("sofa", 11, 4, rot=270), P("clock", 1, 1, walk=True), P("wall_picture", 10, 1, walk=True, variant=1)],
        npcs=[N("bull_landlord", "shopkeeper", 5, 1, script="bull_landlord", name="Landlord"),
              N("bull_regular", "villager_2", 9, 7, script="bull_regular", name="Regular")]))
    write_json("data/zones/haworth_apothecary.json", interior(
        "haworth_apothecary", "Apothecary", 11, 9, 5, Hw, 34, 9,
        counters=[(2, 2), (3, 2), (4, 2), (5, 2), (6, 2)],
        props=[P("specimen_shelf", 1, 1), P("specimen_shelf", 8, 1), P("kitchen_dresser", 9, 4), P("display_case", 2, 5),
               P("potted_plant", 9, 6), P("menu_board", 4, 1, walk=True)],
        npcs=[N("apothecary", "shopkeeper", 4, 1, script="apothecary", name="Apothecary")]))
    write_json("data/zones/haworth_station.json", interior(
        "haworth_station", "Haworth Station Booking Office", 11, 9, 5, Hw, 47, 35,
        counters=[(2, 2), (3, 2), (4, 2)],
        props=[P("clock", 5, 1, walk=True), P("wall_map", 8, 1, walk=True), P("bench", 7, 4), P("bench", 8, 4),
               P("fireplace", 9, 1), P("potted_plant", 1, 6), P("display_case", 9, 6)],
        npcs=[N("station_clerk", "rail_guard", 3, 1, script="station_clerk", name="Booking Clerk")]))

    # ------------------------------------------------------------------ dialogue
    write_json("data/dialogue/haworth.json", {
        "bronte_walker": [
            say("Brontë Walker", G + " Top Withens is just there. Emily walked these moors in every weather. You can see why she wrote about wild, windy places."),
            IF(ST, [IF(WITHENS, [say("Brontë Walker", "Off back to the Parsonage? Tell the curator the wind was in fine voice.")],
                       [IF("trainer_pennines_heathcliff", [
                            say("Brontë Walker", "You saw off our Heathcliff? Good. He's been howling at me since Tuesday. Stand here a minute. Listen. That roar in the wind is what 'wuthering' means."),
                            say("Brontë Walker", "Now you've stood where Emily stood. Tell the curator you've done Withens."),
                            SET(WITHENS)],
                           [say("Brontë Walker", "Doing the Parsonage trail? You'll want to get past the brooding lad by the ruin first. He won't let anyone enjoy the view in peace.")])])],
               [say("Brontë Walker", "There are signposts up here in Japanese as well as English. Visitors come from all over the world for the Brontës.")]),
        ],
        "bronte_keeper_tale": chat("Dog Walker",
            G + " This one's called Keeper, after Emily's dog. He's a terrier, mind, not a mastiff. He has the attitude of a mastiff.",
            "Emily once punished the real Keeper for lying on the beds, and he went for her. She beat him with her bare fists. They were best friends after. Different times."),
        "haworth_setts": chat("Local",
            G + " Steepest Main Street in Yorkshire, I reckon. The setts are lovely on a dry day. On a wet day, hold on to summat.",
            "There's a Victorian weekend every winter where everyone dresses up. Our postman did it in a top hat. He's kept the top hat."),
        "haworth_steam": chat("Volunteer Porter",
            G + " Everyone on this railway is a volunteer, from the porters to the drivers. We do it for love. And the smell of coal smoke.",
            "Oakworth station's down the line. They filmed The Railway Children there. People still turn up waving red petticoats."),
        "haworth_ghost": chat("Ghost Walk Guide",
            "They say Haworth's one of the most haunted villages in England. Grey ladies, headless horsemen, a monk on the church steps.",
            "Most nights I see nothing. Some nights the fog comes down Main Street and I see quite a lot of nothing very clearly."),
        "haworth_victorian": chat("Victorian Weekend Fan",
            G + " Do you like my bonnet? I made it. It's historically accurate apart from the fleece lining. The Brontës would have killed for fleece."),
    })
    write_json("data/dialogue/haworth_shop.json", {"shopkeeper": [
        say("Shopkeeper", G + " Havercakes, curd tart and a cup of tea strong enough to stand a spoon in. What can I get you?"),
        {"do": "shop", "id": "haworth_corner_shop"},
        say("Shopkeeper", "Mind the setts going down. They're slippy, and they know it.")]})
    curator = [IF(DONE, [
        say("Curator", G + " The display's up: Withens, the Bull and the vault. The Bells would be proud. Well, Charlotte would. Emily would pretend not to care."),
    ], [IF(ST, [IF(WITHENS, [IF(BULL, [IF(VAULT, [
        say("Curator", "Withens, the Black Bull and the family vault. You've walked the whole story: the moor that made the books, the brother who lost his way, and the grave that keeps them all."),
        say("Curator", "Take this. It's a copy of Keeper's collar. Emily's dog was the most loyal soul in Haworth."),
        {"do": "give_item", "item": "keepers_collar"},
        {"do": "give_item", "item": "havercake", "n": 3},
        {"do": "standing", "nation": "england", "amount": 3},
        SET(DONE),
    ], [say("Curator", "Now the church. Ask the verger about the family vault, and who isn't in it.")])],
        [say("Curator", "Next, the Black Bull at the top of Main Street. The landlord knows Branwell's story better than anyone.")])],
        [say("Curator", "First, Top Withens, out on the moor along the Brontë Way. Go and stand where Emily stood. And mind the moody chap.")]),
    ], [
        say("Curator", G + " Welcome to the Parsonage. Three sisters wrote some of the greatest novels in English at that table. In a damp house. Next to a graveyard. With a brother in the pub."),
        say("Curator", "I'm building a little trail for visitors. Will you walk it for me first? Top Withens on the moor, the Black Bull, and the family vault in the church."),
        SET(ST),
        say("Curator", "Come back and tell me what you learn. Bring your own umbrella. Haworth never lends one."),
    ])])]
    write_json("data/dialogue/haworth_parsonage.json", {"parsonage_curator": curator})
    write_json("data/dialogue/haworth_church.json", {"church_verger": [
        say("Verger", G + " The Brontë family vault is under the church floor, near the pillar there. Patrick outlived all six of his children."),
        IF(ST, [IF(VAULT, [say("Verger", "Anne's grave is in Scarborough, by St Mary's Church. She wanted to see the sea once more, and she did.")],
                   [say("Verger", "You're on the Parsonage trail? Then remember this: everyone's here except Anne. She died in Scarborough in 1849 and they buried her where she died, by the sea."),
                    SET(VAULT)])]),
    ]})
    write_json("data/dialogue/haworth_blackbull.json", {
        "bull_landlord": [
            say("Landlord", G + " That chair by the stairs? Branwell's, they say. He'd sit there and entertain the whole room, and the room would buy the drinks."),
            IF(ST, [IF(BULL, [say("Landlord", "Raise a glass to Branwell if you like. Just the one, though. He never managed just the one.")],
                       [say("Landlord", "Branwell was the clever one, they thought. Painter, poet. He painted his sisters, then painted himself out of the picture. You can still see the ghost of him where he was."),
                        say("Landlord", "He lost his job as a tutor, then his way. Drink and laudanum. He died at thirty-one, a few months before Emily."),
                        SET(BULL)])]),
        ],
        "bull_regular": chat("Regular", G + " Locals sit here, visitors sit there, and Branwell's ghost sits wherever there's a free stool."),
    })
    write_json("data/dialogue/haworth_apothecary.json", {"apothecary": chat("Apothecary",
        G + " Soaps, salves, and liquorice for the tickly cough you'll get walking up to Withens.",
        "In the 1840s you could buy laudanum over this counter, no questions asked. Branwell asked no questions and bought a great deal. We stick to lavender now.")})
    write_json("data/dialogue/haworth_station.json", {"station_clerk": chat("Booking Clerk",
        G + " Keighley to Oxenhope, five miles of the Worth Valley, steam most weekends. This isn't one of your national trains, mind. We run on volunteers and coal.",
        "When British Railways shut the line at the end of 1961, local folk formed a society and bought it. It reopened in 1968. Proper Yorkshire stubbornness, that.")})

    # ------------------------------------------------------------------ trainers
    trainer("pennines_heathcliff", "Brooding Lad Heathcliff", "Brooder", "poet", [("hootlet", 15), ("wispet", 16), ("gritling", 16)],
            ["I am Heathcliff! Well, I'm Kevin. But I've been brooding on this moor since Tuesday and it's going brilliantly.",
             "Battle me, and the wind shall howl!"],
            "Cathy! Oh. No. Just the wind.",
            "Wuthering means the roaring of the wind on high ground. Emily used a Yorkshire word and the whole world learnt it.")
    trainer("pennines_fireman", "Fireman Stan", "Steam Fireman", "steelworker", [("cutlet", 15), ("bobbin", 16), ("swiftlet", 16)],
            "Fire's in, steam's up, and I've shovelled half a tonne of coal before breakfast. Let's go!",
            "Out of puff. Need a brew and a fill of water.", "A fireman feeds the fire and keeps the water up. The driver just gets to wave.")
    trainer("pennines_bronteway", "Rambler Constance", "Rambler", "hiker", [("scuttlet", 15), ("sphagnet", 16)],
            "I've done the Brontë Way from Oakworth to the waterfall and I'm full of fresh air and opinions.",
            "Oh, well done. Very Jane Eyre of you.", "Reader, I lost.")
    trainer("pennines_ghosthunter", "Ghost Hunter Mabel", "Ghost Hunter", "tour_guide", [("wispet", 15), ("flittermouse", 16), ("barnling", 16)],
            ["My meter's going wild! Oh. It's your phone. Never mind. Battle me anyway.",
             "The spirits demand it!"],
            "The spirits are very disappointed in me.", "The churchyard has more graves than the village has people. Thousands. It's why the water was so bad.")


if __name__ == "__main__":
    build()
    rooms()
