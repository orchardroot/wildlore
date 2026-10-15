# burren (landmark route) and galway (city) with its docks arena, Sanctuary and Corner Shop.
from ie_common import *


def build(OUT):
    burren(OUT)
    galway(OUT)
    docks(OUT)


def burren(OUT):
    W, H = 72, 44
    zid = "burren"
    z = Z(zid, "The Burren", W, H, kind="route", region="ireland_west", music="route_ireland",
          weather={"clear": 22, "sunshine": 18, "drizzle": 22, "fog": 12, "gale": 14, "downpour": 6, "frost": 6})
    z.d["stage"] = "coast"
    z.legend["k"] = {"tile": "grass", "colour": "#9a9b92", "prop": "rock"}       # limestone pavement
    z.legend["j"] = {"tile": "grass", "colour": "#a7a89d"}                        # bare pale pavement
    z.legend["g"] = {"tile": "tall_grass", "colour": "#8f9183", "prop": "none"}   # grey tall grass, encounters
    z.legend["n"] = {"tile": "flowers"}                                           # spring gentian meadow
    z.rect(0, 0, W, H, "k")
    for (x, y, w, h) in [(4, 19, 30, 9), (42, 28, 26, 14), (4, 30, 14, 12), (40, 10, 24, 8)]:
        z.rect(x, y, w, h, "j")
    z.border("R", 2, gaps=[(0, 16, 2, 3), (70, 24, 2, 3)])
    # the Atlantic and the Cliffs of Moher along the north edge
    z.rect(0, 0, W, 7, "$")
    z.rect(2, 7, 68, 1, "^")
    z.rect(0, 7, 2, 1, "R"); z.rect(70, 7, 2, 1, "R")
    z.height(2, 8, 68, 6, 2); z.height(2, 14, 68, 2, 1)
    for (x, y) in [(10, 3), (26, 2), (44, 4), (58, 2), (66, 5)]:
        z.prop("rock", x, y, variant=2)
    # paths: west gate to the dolmen road, down to the east gate, north to the cliffs, then along the cliff top
    z.rect(0, 16, 38, 3, "#")
    z.rect(36, 11, 3, 15, "#")
    z.rect(36, 24, 36, 3, "#")
    z.rect(4, 9, 64, 2, "#")
    z.rect(21, 19, 2, 4, "#")
    z.rect(52, 18, 1, 6, "#")
    # wild flowers: banks and meadows between the stones
    for (x, y, w, h) in [(6, 22, 12, 4), (26, 22, 8, 4), (4, 12, 10, 3), (20, 12, 14, 3), (40, 12, 14, 3), (56, 12, 10, 3), (10, 36, 10, 4), (24, 31, 12, 5),
                         (44, 20, 6, 4), (56, 28, 8, 4)]:
        z.rect(x, y, w, h, "f")
    for (x, y, w, h) in [(8, 23, 5, 2), (28, 23, 4, 2), (6, 13, 4, 1), (44, 12, 6, 1), (12, 37, 5, 2), (26, 32, 6, 2), (58, 29, 4, 2)]:
        z.rect(x, y, w, h, "n")
    # grey tall grass in the grykes
    for (x, y, w, h) in [(40, 20, 8, 4), (56, 19, 9, 4), (4, 28, 10, 3), (30, 29, 8, 5), (46, 34, 10, 5), (60, 34, 8, 6), (18, 28, 8, 3)]:
        z.rect(x, y, w, h, "g")
    # limestone clints: scattered boulders
    r = random.Random(11)
    for y in range(16, 42):
        for x in range(3, 69):
            if z.g[y][x] in "kj" and r.random() < 0.17:
                z.set(x, y, "R")
    # dry-stone field walls with stiles
    for (x, y, w, h) in [(44, 28, 20, 1), (44, 28, 1, 12), (44, 39, 20, 1), (63, 28, 1, 12), (4, 36, 14, 1), (18, 30, 1, 7)]:
        z.rect(x, y, w, h, "W")
    z.rect(52, 28, 2, 1, "k"); z.rect(44, 33, 1, 2, "k"); z.rect(53, 39, 2, 1, "k"); z.rect(18, 33, 1, 2, "k"); z.rect(10, 36, 2, 1, "k")
    # a turlough (seasonal lake) in the south-east field
    blob(z, 54, 34, 5, 2.4, "~", seed=3)
    # Poulnabrone portal tomb
    for (x, y) in [(19, 23), (19, 24), (23, 23), (23, 24), (20, 25), (21, 25), (22, 25)]:
        z.set(x, y, "k"); z.prop("standing_stone", x, y, variant=(x + y) % 3)
    for x in (20, 21, 22):
        z.prop("rock", x, 24, variant=2)
    z.rect(16, 22, 10, 5, "f"); z.rect(20, 23, 3, 1, "k"); z.set(21, 22, "#"); z.set(21, 21, "#")
    z.sign(17, 22, "POULNABRONE. A portal tomb of around 3800 BC, so older than the pyramids. The name means 'hole of the quern stones' in Irish. Remains of more than thirty people were found under it. A handsome roof, in its way.")
    # O'Brien's Tower and a visitor centre built into the hill
    z.building(58, 10, 3, 3, "stone", "O'Brien's Tower")
    z.building(8, 11, 10, 3, "stone", "Cliffs of Moher Visitor Centre")
    z.rect(8, 14, 10, 1, "#")
    z.sign(40, 8, "CLIFFS OF MOHER. Eight kilometres of sea cliff, up to 214 metres high at the tallest. Nobody has ever been disappointed. A fair few have been blown sideways.")
    z.sign(57, 9, "O'BRIEN'S TOWER. Built in 1835 by Cornelius O'Brien, so that visitors would have somewhere to get out of the wind. They still do.")
    z.sign(35, 18, "THE BURREN, AN BHOIRINN. 'The rocky place' in Irish. A Cromwellian officer wrote: 'not a tree to hang a man, nor water to drown him, nor soil enough to bury him.' He'd missed the flowers entirely.")
    z.sign(53, 23, "ARCTIC AND ALPINE FLOWERS. On the Burren, spring gentian, mountain avens and Mediterranean orchids all bloom in the same cracks. Seeds were carried here after the Ice Age and nobody had the heart to leave.")
    z.sign(3, 22, "CLINTS AND GRYKES. The blocks of limestone are clints and the cracks between them are grykes. The Burren has a lot of both. Mind your ankles.")
    for (x, y) in [(10, 14), (16, 14), (30, 9), (50, 8)]:
        z.prop("bench", x, y)
    z.prop("lamp_post", 38, 12); z.prop("lamp_post", 34, 10)
    scatter_props(z, "bush", 3, 9, 66, 33, 14, 5, avoid=("k", "j"))
    for (sp, x, y, mv, who, line) in [("clownbill", 24, 8, "wander", "Puffin", "It's a puffin. It's carrying eleven small fish and an expression of enormous importance."),
                                       ("clownbill", 48, 8, "wander", "Puffin", "It's a puffin. It has seen the cliffs, the sea and you, and has decided you are the least interesting."),
                                       ("plungebeak", 33, 8, "still", "Gannet", "A gannet dive-bombs a shoal below the cliff and comes up looking smug."),
                                       ("billgruff", 12, 31, "wander", "Feral Goat", "Burren goats have lived wild on the limestone since the Bronze Age. This one wants your sandwich. This one is not going to ask nicely."),
                                       ("kidgruff", 36, 36, "wander", "Feral Goat", "A kid goat bounces off the boulder, lands neatly on the next one, and refuses to say how."),
                                       ("gentlet", 28, 24, "still", "Gentian", "A deep blue spring gentian, one of the bluest things in nature. It's about the size of your thumbnail and entirely unbothered.")]:
        creature(z, zid, sp, x, y, mv, line, who)
    # chat
    chat(z, "burren_botanist", "student", 12, 24, "Botanist",
         ["Of Ireland's twenty-eight native orchid species, twenty-four grow on the Burren, give or take. I count them in the rain.",
          "Spring gentian, mountain avens, bloody cranesbill. They're all up at once in May. It's like a traffic jam of confetti."], "down", "wander")
    chat(z, "dolmen_guide", "tour_guide", 24, 21, "Dolmen Guide",
         ["This is Poulnabrone. Two portal stones, a thin slab on top and a lot of questions. About 3800 BC. It's older than the pyramids at Giza, which is a lovely thing to say to an Egyptian.",
          "It's a tomb, not an altar. No sacrifices. Just ancestors and a rather excellent view."], "left", "still")
    chat(z, "cliff_guide", "hiker", 31, 12, "Cliff Walker",
         ["The Cliffs of Moher go up two hundred and fourteen metres at the highest, and the sea at the bottom always looks like it's a long way off. It is.",
          "Don't climb the wall. I've seen what the wind does to hats, and I've seen hats do things to people."], "right", "still")
    z.set(49, 31, "j")  # open the rock ring so the cheesemaker can be talked to
    chat(z, "cheese_farmer", "farmer", 50, 31, "Cheesemaker",
         ["Burren farmers winter their cattle on the hills, not in the valleys, so the limestone stays warm. It's called winterage. It's thousands of years old.",
          "The cattle graze the flowers, which keeps the rare ones from being swamped. It's the one place where a cow is a conservationist."], "down", "still")
    chat(z, "cave_guide", "tour_guide", 6, 26, "Cave Guide",
         ["Under the Burren there are miles of caves. In Doolin there's a stalactite that's over seven metres long, hanging from the ceiling like a very slow icicle.",
          "I do the tours. You wear a helmet. If you hear dripping, it's not a leak. It's a million years of progress."], "right", "wander")
    # trainers
    trainer(z, "burren_birder", "Birdwatcher Sinead", "Birdwatcher", "birdwatcher", [("plungebeak", 56), ("polartern", 56), ("clownbill", 55)],
            24, 9, "down", ["There! A peregrine, on the face of the cliff. They are the fastest living thing on earth. Don't blink."],
            "You blinked, and so did I. Good battle.", "The cliffs have puffins, razorbills and guillemots. They're like a very cold bus queue.", 2310)
    trainer(z, "burren_fiddler", "Fiddler Brid", "Fiddler", "harpist", [("gealhare", 56), ("bansheen", 56), ("burrenbloom", 56)],
            12, 19, "up", ["Clare's the home of the concertina. I play the fiddle, which is, I'm told, the wrong instrument for the hour."],
            "A beautiful loss. I'll write a slow air about it.", "A slow air is the sound of a tune with nowhere to be.", 2330)
    trainer(z, "burren_hurler", "Hurler Padraig", "Hurler", "rugby_player", [("stagmor", 57), ("dextera", 56), ("billgruff", 56)],
            30, 21, "down", ["Clare's won All-Ireland hurling titles in living memory, and I'm trying to join the list. Come on."],
            "A fair puck. I can't see the sliotar for the grykes.", "Clare's a hurling county. Even the cattle have a good wrist.", 2340)
    trainer(z, "burren_warden", "Warden Barnaby", "Warden", "warden_grunt", [("gentlet", 55), ("bansheen", 56), ("kidgruff", 55)],
            34, 30, "up", ["Welcome to the Burren Heritage Experience! The limestone is curated, the flowers are numbered, the goats are on a leash."],
            "I'll note it in the visitor feedback. 'Too good for the goats.'", "Director Kerrigan wants to put turnstiles on the cliffs. I told her the wind would get them.", 2280)
    z.npc(id="burren_twin_a", sprite="villager_5", x=58, y=22, facing="down", move="still", trainer="burren_twins")
    z.npc(id="burren_twin_b", sprite="villager_5", x=59, y=22, facing="down", move="still", trainer="burren_twins")
    TRN["burren_twins"] = {"id": "burren_twins", "name": "Aoife and Orla", "class": "Fiddler", "sprite": "villager_5", "double": True,
                           "party": [{"species": s, "level": l} for s, l in [("gealhare", 56), ("burrenbloom", 57), ("bansheen", 57), ("selkie", 56)]],
                           "ai": "trainer", "money": 2420,
                           "intro": say("Aoife and Orla", "AOIFE: We're the twins. We finish each other's...", "ORLA: ...reels. And battles. Two against one is only fair, in a place this big."),
                           "win": "AOIFE: Beaten! ORLA: By a fiddle-lessly strong team. Sorry, we couldn't stop.",
                           "after": "We play the Doolin sessions on Fridays. Come along. Bring a tune and a thick skin."}
    z.d["edges"] = {"west": {"to": "dingle", "offset": 0}, "east": {"to": "galway", "offset": 0}}
    z.d["spawn"] = [3, 17]
    wild(z, [("gentlet", 55, 57, 16, {}), ("burrenbloom", 56, 57, 10, {"time": ["day", "dawn"]}),
             ("bansheen", 56, 57, 5, {"time": ["night"], "weather": ["fog", "drizzle"]}),
             ("corncrake", 55, 56, 10, {"time": ["dawn", "day"], "weather": ["clear", "sunshine"]}),
             ("gealhare", 55, 57, 10, {"time": ["dawn", "dusk"]}), ("kidgruff", 55, 56, 10, {}), ("billgruff", 56, 57, 8, {}),
             ("plungebeak", 56, 57, 8, {"weather": ["gale"]}), ("polartern", 56, 57, 6, {"weather": ["frost", "gale"]}),
             ("horseshoe", 56, 57, 8, {"time": ["night", "dusk"]}), ("crexling", 55, 56, 6, {"time": ["dawn"]})])
    wild(z, [("heronarch", 56, 57, 20, {}), ("rillotter", 56, 57, 20, {}), ("bradan", 56, 57, 15, {"weather": ["drizzle", "downpour"]}),
             ("spatelord", 56, 57, 15, {"time": ["night"]}), ("parrlet", 55, 56, 10, {})], "water")
    finish(z)
    z.save(OUT + "/burren.json")


def galway(OUT):
    W, H = 72, 56
    zid = "galway"
    z = Z(zid, "Galway", W, H, kind="town", region="ireland_west", music="town_ireland",
          weather={"drizzle": 30, "clear": 20, "sunshine": 12, "gale": 14, "fog": 8, "downpour": 16})
    z.d["stage"] = "docks"; z.d["town_id"] = "galway"
    z.border("T", 2, gaps=[(0, 24, 2, 3), (34, 0, 3, 2)])
    z.scatter(0, 0, W, H, "P", 20, 2, only="T")
    # the bay and docks (south) and the Corrib
    z.rect(0, 46, W, 10, "$")
    z.rect(2, 41, 68, 5, "~")
    z.rect(52, 2, 4, 40, "~")
    z.rect(2, 40, 68, 1, ":")
    # roads
    z.rect(2, 24, 50, 3, "="); z.rect(2, 23, 50, 1, ":"); z.rect(2, 27, 50, 1, ":")
    z.rect(52, 24, 4, 3, "|"); z.rect(56, 24, 14, 3, "="); z.rect(56, 23, 14, 1, ":"); z.rect(56, 27, 14, 1, ":")
    z.rect(34, 0, 3, 40, "="); z.rect(33, 2, 1, 38, ":"); z.rect(37, 2, 1, 38, ":")
    z.rect(34, 24, 3, 3, "=")
    # Eyre Square
    z.rect(17, 4, 16, 15, ":"); z.rect(18, 5, 14, 13, ".")
    z.rect(24, 5, 2, 13, "#"); z.rect(18, 11, 14, 2, "#")
    z.rect(19, 6, 4, 4, ","); z.rect(27, 14, 4, 3, ","); z.rect(27, 6, 4, 3, "f"); z.rect(19, 14, 4, 3, "f")
    z.rect(25, 18, 1, 5, ":")
    for (x, y) in [(20, 5), (22, 5), (28, 5), (30, 5), (18, 11), (31, 11), (21, 17), (29, 17), (19, 8), (30, 13)]:
        z.prop("oak", x, y, variant=(x + y) % 3)
    for (x, y) in [(22, 12), (28, 12), (23, 7), (27, 15)]:
        z.prop("bench", x, y)
    for (x, y) in [(18, 4), (32, 4), (18, 18), (32, 18), (25, 4)]:
        z.prop("lamp_post", x, y)
    z.prop("statue", 25, 10)
    z.building(26, 8, 3, 2, "stone", "Browne Doorway")
    z.sign(24, 10, "EYRE SQUARE. Eight acres of green in the middle of Galway, given to the city in 1710 and now officially the John F. Kennedy Memorial Park. Kennedy visited in 1963 and the town's never stopped telling people.")
    z.sign(29, 10, "BROWNE DOORWAY. A carved stone doorway of 1627 from a merchant's house. It's one of the Fourteen Tribes of Galway, and it's been rehomed in a park, which is a very Galway thing to do.")
    # north-west: terraces and a cathedral
    z.building(3, 6, 6, 4, "terrace", "The Quays Bar")
    z.building(10, 6, 6, 4, "cream_render", "Latin Quarter Books")
    z.building(3, 12, 6, 4, "red_brick", "Druid Theatre")
    z.building(10, 12, 6, 4, "white_render", "Crann Cafe")
    z.rect(2, 10, 15, 1, ":"); z.rect(2, 16, 15, 1, ":"); z.rect(9, 10, 1, 14, ":"); z.rect(2, 17, 15, 5, ".")
    z.building(40, 5, 10, 9, "cathedral", "Galway Cathedral")
    z.rect(40, 14, 10, 2, ":"); z.rect(45, 14, 1, 9, ":")
    z.rect(38, 16, 14, 1, ":"); z.prop("statue", 41, 16); z.prop("planter", 48, 15)
    z.sign(44, 15, "GALWAY CATHEDRAL. Finished in 1965 on the site of the old city jail. A big stone dome, a lot of Connemara marble and a rose window you could lose a day in.")
    # Sanctuary and Corner Shop
    z.building(40, 19, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.building(47, 19, 4, 4, "shop", "Corner Shop", door=2)
    z.warp(43, 22, "galway_sanctuary", 5, 6, "up"); z.warp(49, 22, "galway_shop", 4, 5, "up")
    z.building(3, 19, 5, 4, "slate_cottage", show_label=False)
    z.building(9, 19, 6, 4, "tudor", "Tigh Neachtain")
    z.building(16, 19, 6, 4, "terrace", "Spanish Arch Books")
    z.building(26, 19, 6, 4, "cream_render", "Salthill Gifts")
    # the station, south of Shop Street
    pf = station(z, 4, 29, 9, 4, "Ceannt Station")
    z.rect(3, 27, 1, 5, ":"); z.rect(13, 27, 1, 5, ":"); z.rect(4, 28, 9, 1, ":")
    z.prop("bench", 6, 31); z.prop("lamp_post", 12, 31)
    rail_guard(z, 10, 31, ["Ceannt Station, named for Eamonn Ceannt, who signed the 1916 Proclamation. It's an Irish Rail station, not a Wildlore one, but the rail's the same.",
                           "Hop aboard. The Wildlore rail runs to any town you have visited on this island. Where to?"])
    # the Claddagh and the Spanish Arch
    z.rect(36, 34, 17, 1, ":"); z.rect(36, 39, 17, 1, ":")
    for (x, y) in [(38, 30), (43, 30), (48, 30), (38, 36), (43, 36)]:
        z.building(x, y, 4, 3, "slate_cottage", show_label=False)
    z.building(47, 36, 5, 3, "aqueduct", "Spanish Arch")
    z.rect(38, 33, 14, 1, ":"); z.rect(37, 30, 1, 10, ":")
    z.prop("bollard", 44, 40); z.prop("bollard", 50, 40); z.prop("bollard", 38, 40); z.prop("lamp_post", 42, 34); z.prop("lamp_post", 46, 34)
    z.sign(36, 33, "THE CLADDAGH. A fishing village of thatched cottages outside the old walls, with its own king, who was the fishermen's chosen mayor. It's also the home of the Claddagh ring: two hands holding a heart under a crown, for love, loyalty and friendship.")
    z.sign(46, 39, "THE SPANISH ARCH. Built in 1584 as part of the city walls to guard the quay where Spanish merchants unloaded wine. Galway's been trading with Spain for ages. The arch now guards a lot of ice-cream.")
    # the docks, east of the Corrib: the Keeper's arena
    z.rect(56, 28, 14, 12, ".")
    z.building(58, 29, 11, 5, "stone", "Galway Docks Arena", door=5)
    z.rect(56, 34, 14, 5, ":");
    z.warp(63, 33, "galway_docks", 8, 12, "up")
    z.sign(61, 35, "GALWAY DOCKS. A working harbour since the Middle Ages. The Galway hooker, a sturdy black-hulled sailing boat with red-brown sails, still races in Cruinniu na mBad in summer. They're slower than the gossip.")
    for (x, y, v) in [(8, 43, 1), (16, 44, 1), (24, 42, 1), (32, 44, 0), (62, 43, 1), (67, 44, 1), (46, 44, 1), (56, 44, 1), (40, 42, 1)]:
        z.prop("boat", x, y, variant=v)
    for (x, y) in [(12, 44), (28, 43), (36, 43), (50, 42), (64, 42)]:
        z.prop("buoy", x, y)
    for x in range(4, 70, 6):
        if x != 46:  # keep the Spanish Arch quay open to the busker
            z.prop("bollard", x, 40)
    z.prop("lighthouse", 69, 44)
    z.prop("lamp_post", 58, 35); z.prop("lamp_post", 68, 35); z.prop("bench", 60, 38); z.prop("bench", 66, 38)
    # signage and props
    z.prop("phone_box", 3, 23); z.prop("post_box", 31, 27); z.prop("bench", 8, 27)
    for x in (6, 14, 22, 30, 44, 60, 66):
        z.prop("lamp_post", x, 23)
    # swans on the Corrib and tall grass for encounters
    z.rect(3, 33, 10, 4, ","); z.rect(16, 34, 8, 4, ","); z.rect(58, 41, 0, 0, ",")
    z.rect(2, 34, 1, 1, ".")
    scatter_props(z, "bush", 3, 3, 66, 36, 14, 4, avoid=(".",))
    # NPCs
    chat(z, "ring_maker", "shopkeeper", 22, 25, "Jeweller",
         ["The Claddagh ring: two hands for friendship, a heart for love, a crown for loyalty. Worn heart outwards, it says 'free'. Heart inwards, it says 'spoken for'.",
          "It began in the Claddagh village, a fishing community outside the city walls. Legend says a fisherman, taken by pirates, came back for his love. Whether or not that's true, I sell a lot of them."], "down", "still")
    chat(z, "hooker_skipper", "sailor", 62, 38, "Hooker Skipper",
         ["A Galway hooker is a traditional working boat: black hull, red-brown sails, built for hauling turf and fish across Galway Bay.",
          "Four sizes: the Bad Mor, the Halfdecker, the Gleoiteog and the Pucan. I can name them all. I can't sail any of them."], "down", "still")
    chat(z, "square_student", "student", 22, 13, "University Student",
         ["Galway's one of the Fourteen Tribes' towns. The tribes were merchant families, and they ran the place for centuries. They had their own street names. One of them's called Lynch Lane. The word 'lynch' is theirs, they say. It might not be true. I'd have to check.",
          "The Eyre Square park is the only place I know where a Kennedy statue gets less attention than a pigeon."], "right", "wander")
    chat(z, "busker_swan", "villager_2", 49, 39, "Swan Fan",
         ["The swans on the Corrib are always the same swans, I'm convinced. They're on a rota. They've got the whole river organised.",
          "The Corrib's one of the shortest rivers in Europe. About six kilometres. It makes up for it in volume."], "left", "wander")
    chat(z, "oyster_man", "angler", 56, 38, "Oyster Man",
         ["Galway Bay oysters are the best on earth, and I'd take it to court. September's the Oyster Festival. People wear black tie and eat them with a stout.",
          "Nobody's ever asked me what the oyster thinks. It thinks, 'Why is it me?'"], "down", "wander")
    z.npc(id="kit", sprite="kit", x=25, y=21, facing="down", move="still", script="kit_galway")
    script(zid, "kit_galway", say("Kit", "Placeholder: the story agent writes the sixth Kit battle here."))
    trainer(z, "galway_fiddler", "Busker Fionn", "Fiddler", "harpist", [("cluricaun", 57), ("gealhare", 56), ("merrow", 57)],
            26, 28, "up", ["Shop Street's the best stage in Galway. And it's raining, so nobody can leave. A captive audience."],
            "That's me done. Passing the hat. Or the bucket.", "The best busker's the one who stops before the crowd does.", 2400)
    trainer(z, "galway_warden", "Warden Humphrey", "Warden", "warden_grunt", [("rookery", 56), ("selkie", 57), ("cluricaun", 56)],
            40, 28, "left", ["The Wild Atlantic Experience Centre opens here soon! It's an interpretive centre about interpreting. Booking essential."],
            "I see. Not a booking, then.", "Director Kerrigan's got a vision of tour buses. I've a vision of a tea break.", 2350)
    z.d["edges"] = {"west": {"to": "burren", "offset": 0}, "north": {"to": "connemara", "offset": 0}}
    z.d["spawn"] = [35, 25]
    wild(z, [("merrow", 56, 57, 4, {"time": ["night"], "weather": ["fog"]}), ("selkie", 56, 57, 10, {"time": ["dusk", "night"]}),
             ("moolet", 56, 57, 10, {}), ("dextera", 56, 57, 6, {"time": ["day"]}), ("chipgull", 56, 57, 14, {"time": ["day"]}),
             ("plungebeak", 56, 57, 10, {"weather": ["gale", "clear"]}), ("ternlet", 56, 57, 6, {"weather": ["frost"]}),
             ("cluricaun", 56, 57, 5, {"time": ["night"]}), ("polartern", 56, 57, 8, {"weather": ["sunshine"]}), ("pierlord", 56, 57, 8, {"time": ["day", "dusk"]})])
    wild(z, [("merrow", 56, 57, 12, {}), ("selkie", 56, 57, 18, {}), ("bayrunner", 56, 57, 15, {}), ("plungebeak", 56, 57, 15, {}), ("bradan", 56, 57, 12, {}), ("pierlord", 56, 57, 14, {})], "water")
    finish(z)
    z.save(OUT + "/galway.json")
    sanctuary(OUT, "galway", "Galway", (43, 23), music="sanctuary")
    shop(OUT, "galway", "Galway", (49, 23))
    nurse("galway", ["Welcome to Galway Sanctuary. Bhí tú ag siúl i bhfad! That's 'you've been walking a long time'. Pop your team on the counter.",
                     "Sit down by the radiator, you look like you've walked the whole bay. Not a bother on us.",
                     "All better! Beir bua, that's 'success go with you'. Mind the puddle by the door, it's tidal.",
                     "The Ark terminal's by the window. It gets better reception than the rest of the building.",
                     "That's grand. Nobody's rushing. We've got tea and the Atlantic's got all day."])
    shopkeeper("galway", "Dia duit! Snares, tea, one umbrella rented by the minute, and a very slightly damp scone.",
               "Slán go fóill! That's 'goodbye for now'. The Corrib's not going anywhere.")


def docks(OUT):
    a = Z("galway_docks", "Galway Docks", 19, 14, fill="|", kind="interior", region="", music="battle_keeper", weather={"drizzle": 100})
    a.d["stage"] = "docks"
    a.border("x", 1)
    a.rect(2, 2, 3, 8, "~"); a.rect(14, 2, 3, 8, "~")
    a.rect(2, 10, 15, 1, "+")
    a.set(9, 12, "D")
    a.warp(9, 12, "galway", 63, 34, "down")
    a.prop("boat", 3, 4, variant=1); a.prop("boat", 15, 7, variant=1); a.prop("buoy", 3, 8); a.prop("buoy", 15, 3)
    for (x, y) in [(5, 2), (13, 2), (5, 9), (13, 9)]:
        a.prop("bollard", x, y)
    a.prop("lamp_post", 7, 2); a.prop("lamp_post", 11, 2); a.prop("bench", 6, 11); a.prop("bench", 12, 11)
    a.prop("planter", 2, 11); a.prop("planter", 16, 11)
    a.npc(id="keeper_nuala", sprite="keeper_nuala", x=9, y=3, facing="down", move="still", script="keeper_nuala")
    script("galway_docks", "keeper_nuala", say("Keeper Nuala", "Placeholder: the story agent rewrites this Keeper battle script."))
    trainer(a, "galway_junior_1", "Currach Rower Aisling", "Currach Rower", "sailor", [("selkie", 56), ("bayrunner", 56), ("merrow", 56)],
            6, 7, "right", ["Keeper Nuala says you're not to pass the pier without a proper greeting. It's a battle. She's very traditional."],
            "A good row. You'll need your sea legs for the Keeper.", "Keep the oars flat and the chat polite. It's the Galway way.", 2200)
    trainer(a, "galway_junior_2", "Surfer Cian", "Surfer", "surfer", [("plungebeak", 57), ("selkie", 57), ("polartern", 57)],
            12, 5, "left", ["Lahinch has the best surf in Ireland. I'm here because it's raining and the dock's dry. Sort of."],
            "Wipeout. You were wicked.", "Nuala's the real thing. She's rowed from Inis Mor in a storm. And she won't mention it.", 2240)
    a.d["spawn"] = [9, 11]
    finish(a)
    a.save("%s/galway_docks.json" % OUT)
