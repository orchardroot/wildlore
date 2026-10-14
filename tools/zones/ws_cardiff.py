# cardiff (city), cardiff_arena (Keeper Rhys), Sanctuary and Corner Shop.
from wcommon import *


def build(OUT):
    z = Z("cardiff", "Cardiff", 64, 48, kind="town", region="south_wales", music="town_city",
          weather={"drizzle": 35, "downpour": 18, "clear": 14, "gale": 10, "fog": 5, "sunshine": 18})
    z.d["stage"] = "city"; z.d["town_id"] = "cardiff"
    z.border("T", 2, gaps=[(0, 18, 2, 3)])
    z.scatter(0, 0, 64, 48, "P", 30, 2, only="T")
    # streets: Queen Street east-west, St Mary Street north-south
    z.rect(0, 18, 54, 3, "="); z.rect(2, 17, 52, 1, ":"); z.rect(2, 21, 52, 1, ":")
    z.rect(30, 15, 3, 19, "="); z.rect(29, 14, 1, 20, ":"); z.rect(33, 14, 1, 20, ":")
    z.rect(30, 14, 3, 1, ":")
    for x in (6, 14, 22, 38, 46):
        z.prop("lamp_post", x, 17)
    for x in (10, 26, 42):
        z.prop("lamp_post", x, 21)
    z.prop("phone_box", 28, 17); z.prop("post_box", 34, 21); z.prop("bench", 24, 17); z.prop("bench", 36, 21)
    for x in (18, 20, 40):
        z.prop("planter", x, 21)
    # Cardiff Castle: grounds on a motte, wall, keep and towers
    z.height(18, 3, 25, 11, 1)
    z.rect(18, 3, 25, 11, ".")
    z.rect(18, 14, 12, 1, "W"); z.rect(33, 14, 10, 1, "W"); z.rect(18, 3, 25, 1, "W")
    z.rect(18, 3, 1, 12, "W"); z.rect(42, 3, 1, 12, "W")
    z.rect(30, 14, 3, 1, ":")
    z.building(24, 5, 10, 6, "castle", "Cardiff Castle")
    z.building(19, 4, 4, 4, "castle", show_label=False)
    z.building(37, 4, 5, 5, "castle", show_label=False)
    z.rect(30, 11, 3, 3, "#"); z.rect(31, 11, 1, 3, "#")
    z.rect(20, 11, 8, 2, "f"); z.rect(35, 11, 6, 2, "f")
    z.prop("oak", 20, 12); z.prop("oak", 40, 12, variant=1); z.prop("oak", 26, 12); z.prop("statue", 29, 11)
    z.prop("bench", 22, 12); z.prop("bench", 36, 12)
    z.sign(29, 14, "CARDIFF CASTLE. Roman fort, then Norman keep, then Victorian fantasy. The Marquess of Bute spent a fortune on towers.")
    # Bute Park, east of the castle
    z.rect(44, 3, 18, 13, "."); z.rect(45, 5, 5, 6, ","); z.rect(54, 9, 6, 5, ",")
    z.rect(43, 3, 1, 14, "~"); z.rect(43, 17, 1, 1, "w")
    z.rect(43, 11, 1, 2, "w")
    z.scatter(44, 3, 18, 13, "T", 22, 5, only=".")
    z.rect(44, 11, 12, 1, "#"); z.rect(52, 6, 1, 6, "#")
    z.prop("bench", 51, 12); z.prop("lamp_post", 48, 12); z.prop("lamp_post", 56, 12)
    z.sign(53, 12, "BUTE PARK. 56 hectares, the River Taff, and a lot of cricket. Please do not feed the gulls. They have learnt to ask.")
    # Sanctuary and Corner Shop, north side of Queen Street, west
    z.building(4, 13, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.building(11, 13, 5, 4, "shop", "Corner Shop", door=2)
    z.building(2, 5, 7, 4, "terrace", "Castle Arcade"); z.building(10, 5, 6, 4, "red_brick", "Grange Chippy")
    z.warp(7, 16, "cardiff_sanctuary", 5, 6, "up"); z.warp(13, 16, "cardiff_shop", 4, 5, "up")
    z.rect(2, 9, 14, 1, ":"); z.rect(10, 9, 1, 8, ":")
    # Central station (west of St Mary Street, south of Queen Street)
    pf = station(z, 3, 23, 9, 4, "Cardiff Central")
    z.rect(2, 25, 1, 1, "#"); z.rect(12, 25, 1, 1, "#"); z.rect(3, 22, 9, 1, ":"); z.rect(2, 22, 1, 4, "#")
    z.prop("bench", 6, 25); z.prop("lamp_post", 11, 25)
    rail_guard(z, 8, 25, ["Cardiff Central. Rugby fans on the left, shoppers on the right, everybody in the way.",
                          "Hop aboard. The Wildlore rail runs to any town you have visited. Where to?"])
    # the Arena (stadium-ish), with its plaza to the south
    z.building(15, 23, 13, 7, "stone", "Cardiff Arena", door=6)
    z.rect(13, 30, 17, 3, ":")
    z.rect(21, 30, 1, 1, ":")
    z.warp(21, 29, "cardiff_arena", 8, 11, "up")
    z.prop("statue", 14, 31); z.prop("lamp_post", 16, 30); z.prop("lamp_post", 26, 30); z.prop("planter", 18, 31); z.prop("planter", 24, 31)
    z.sign(22, 31, "CARDIFF ARENA. Home of rugby, concerts and the roof that rains inside. Entry through the big door. Dry feet not guaranteed.")
    # Cardiff Bay waterfront
    z.rect(18, 36, 46, 12, "~"); z.rect(12, 33, 52, 3, ":"); z.rect(29, 33, 5, 3, ":")
    z.rect(18, 36, 1, 12, "s")
    z.rect(2, 33, 10, 14, ".")
    z.rect(17, 30, 3, 3, ".")
    z.rect(35, 22, 25, 4, ":"); z.rect(34, 22, 1, 10, ":"); z.rect(48, 22, 12, 9, ":"); z.rect(35, 32, 12, 1, ":")
    z.building(36, 26, 11, 6, "stone", "Wales Millennium Centre")
    z.building(48, 26, 6, 5, "red_brick", "Pierhead Building")
    z.building(55, 27, 5, 4, "white_render", "Norwegian Church")
    z.prop("statue", 41, 23); z.prop("bench", 38, 24); z.prop("bench", 44, 24); z.prop("planter", 36, 23); z.prop("planter", 46, 23)
    z.prop("lamp_post", 34, 30); z.prop("lamp_post", 47, 24); z.prop("bollard", 24, 33); z.prop("bollard", 42, 33)
    z.prop("bollard", 52, 33); z.prop("bollard", 58, 33); z.prop("bollard", 20, 33)
    for (x, y, v) in [(24, 39, 0), (34, 42, 1), (44, 38, 1), (52, 41, 0), (58, 37, 1), (28, 44, 1)]:
        z.prop("boat", x, y, variant=v)
    for (x, y, v) in [(30, 38, 0), (40, 40, 1), (50, 45, 0), (22, 41, 1)]:
        z.prop("buoy", x, y, variant=v)
    z.rect(57, 41, 3, 2, "s"); z.prop("lighthouse", 58, 41)
    z.sign(35, 22, "WALES MILLENNIUM CENTRE. The poem on the front reads, in Welsh: 'Creu gwir fel gwydr o ffwrnais awen'. Creating truth like glass from the furnace of inspiration.")
    z.sign(29, 32, "CARDIFF BAY. Once the biggest coal port in the world. Now, the biggest puddle with a view.")
    z.sign(23, 33, "PIERHEAD BUILDING. 1897, red terracotta. The Senedd is next door. They're very polite to each other.")
    z.sign(50, 32, "NORWEGIAN CHURCH. Roald Dahl was christened here. He didn't write about the font, but he did write about the giants.")
    # west park by the bay
    z.rect(3, 35, 8, 3, ","); z.rect(4, 40, 6, 4, ","); z.rect(12, 44, 5, 2, ",")
    z.prop("oak", 4, 34, variant=0); z.prop("oak", 10, 36, variant=2); z.prop("oak", 6, 39, variant=1); z.prop("bench", 8, 38)
    z.prop("lamp_post", 6, 34)
    # NPCs
    chat(z, "rugby_fan", "rugby_player", 24, 22, "Rugby Fan",
         ["I'd tell you the score but it changes every time I get a hot dog.",
          "The Principality Stadium holds seventy-four thousand and they all sing at once. Hearing it from outside is free."], "down", "wander")
    chat(z, "castle_guide2", "tour_guide", 29, 12, "Castle Guide",
         ["Cardiff Castle has a Roman wall at its foot and a Victorian fairy-tale on top. A thousand years in one view.",
          "The peacocks on the lawn are not decorative. They're managers."], "down", "still")
    chat(z, "bay_sailor", "sailor", 31, 34, "Bay Skipper",
         ["Cardiff Bay used to be the biggest coal port on the planet. In 1913 more coal left here than any other port in the world.",
          "Now it's mostly ferries, ice creams and people photographing the same bollard."], "left", "still")
    chat(z, "dahl_fan", "student", 20, 19, "Reader",
         ["Roald Dahl was born in Cardiff. He's the reason I check every sweet shop for a golden ticket.",
          "They've named a plaza after him. No giant peaches, but the water tower is quite tall."], "right", "wander")
    chat(z, "shopper", "villager_4", 40, 19, "Shopper",
         ["Cardiff's Victorian arcades are the best shopping you can do in the rain. Which is to say, all of it.",
          "I came in for a coat. I left with three hats and a bag of Welsh cakes. A win."], "down", "wander")
    # story placeholders
    z.npc(id="kit", sprite="kit", x=37, y=34, facing="down", move="still", script="kit_bay")
    script("cardiff", "kit_bay", say("Kit", "Placeholder: the story agent writes the fourth Kit battle here."))
    z.npc(id="pryce", sprite="pryce", x=26, y=32, facing="down", move="still", script="pryce_cardiff")
    script("cardiff", "pryce_cardiff", say("Pryce", "Placeholder: the story agent writes Pryce's last stand here."))
    z.d["edges"] = {"west": {"to": "beacons", "offset": 0}}
    z.d["spawn"] = [31, 19]
    wild(z, [("chipgull", 36, 38, 100, {})])
    z.save(OUT + "/cardiff.json")
    sanctuary(OUT, "cardiff", "Cardiff", (7, 17))
    shop(OUT, "cardiff", "Cardiff", (13, 17))
    nurse("cardiff", ["Welcome to the Cardiff Sanctuary. We have a roof. Today, that's the main selling point. Pop your team on the counter.",
                      "In a jiffy. Sit by the radiator, you look like you've walked over a mountain.",
                      "All better! Don't be a stranger, and do watch the puddle by the door.",
                      "The Ark terminal's just here. It runs on tea and optimism.",
                      "Right you are. Shout if anyone needs a plaster."])
    shopkeeper("cardiff", "Croeso i Gaerdydd! Snares, tea and one umbrella. It's already been taken.",
               "Hwyl fawr! Mind the wind off the Bay, it takes hats.")

    # ------------------------------------------------------------ the arena
    a = Z("cardiff_arena", "Cardiff Arena", 17, 14, fill="|", kind="interior", region="", music="battle_keeper",
          weather={"downpour": 100})
    a.d["stage"] = "city"
    a.border("x", 1)
    a.rect(2, 2, 13, 9, ".")
    a.rect(2, 2, 13, 1, "+"); a.rect(2, 10, 13, 1, "+")
    a.rect(1, 1, 15, 1, "|"); a.rect(7, 11, 3, 1, "|")
    a.set(8, 12, "D"); a.rect(8, 11, 1, 1, "|")
    a.warp(8, 12, "cardiff", 21, 30, "down")
    a.prop("lamp_post", 6, 2); a.prop("lamp_post", 10, 2)       # the posts
    a.prop("bench", 3, 11); a.prop("bench", 13, 11); a.prop("bench", 3, 3); a.prop("bench", 13, 3)
    a.prop("planter", 2, 7); a.prop("planter", 14, 7); a.prop("bollard", 1, 12); a.prop("bollard", 15, 12)
    a.npc(id="keeper_rhys", sprite="keeper_rhys", x=8, y=3, facing="down", move="still", script="keeper_rhys")
    script("cardiff_arena", "keeper_rhys", say("Keeper Rhys", "Placeholder: the story agent rewrites this Keeper battle script."))
    trainer(a, "dai_arena", "Rugby Player Dewi", "Rugby Player", "rugby_player", [("swiftlet", 33), ("elverlet", 34), ("natterjack", 34)],
            12, 7, "left",
            ["Right, lad! Fancy a warm-up? Keeper Rhys likes us to run a few plays on the visitors."],
            "You're through. The Keeper's at the far end. Mind the mud.",
            "I'll tell Rhys you looked tough. And a bit damp.", 640)
    trainer(a, "cerys_arena", "Student Cerys", "Student", "student", [("petrelash", 34), ("severnshock", 35)],
            4, 5, "right",
            ["Studying meteorology! This stadium has its own weather. It's a thesis, not a design flaw."],
            "A fair front. Passing through, then.",
            "The cloud cover over the pitch is real. I've measured it. Twice.", 660)
    a.d["spawn"] = [8, 11]
    a.save(OUT + "/cardiff_arena.json")
