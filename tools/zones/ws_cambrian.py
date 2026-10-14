# cambrian_coast: Llanberis south along Cardigan Bay to Aberystwyth. Harlech, Barmouth, Cadair Idris, a hermit's cove, Borth.
from wcommon import *


def seal_ns(z, g0, g1, north=True, south=True):
    """Make every border tile outside the gap columns unwalkable so edges land only where the neighbour is open."""
    for x in range(z.w):
        if g0 <= x <= g1:
            continue
        for y, on in ((0, north), (z.h - 1, south)):
            if on and z.g[y][x] in ".,#sf=:w":
                z.set(x, y, "P")


def build(OUT):
    z = Z("cambrian_coast", "Cambrian Coast", 44, 56, kind="route", region="mid_wales", music="route_coast",
          weather={"clear": 25, "drizzle": 25, "gale": 20, "sunshine": 15, "fog": 15})
    z.d["stage"] = "coast"
    edge = lambda y: 7 + int(round(2.2 * math.sin(y / 5.0)))
    # hills and conifers down the east side
    z.rect(33, 0, 11, 56, "P"); z.height(34, 0, 10, 56, 1); z.height(37, 6, 7, 44, 2)
    z.scatter(33, 0, 11, 56, "R", 40, 3, only="P")
    z.scatter(22, 0, 12, 56, "P", 50, 5)
    sea(z, edge, 0, 56)
    beach(z, edge, 0, 56, 3, 6)
    # the route: x 24-25 south to y 18, east to x 30-31, then south over the estuary to Borth and out
    path(z, [(24, 0), (24, 18), (30, 18), (30, 55)], "#", 2)
    z.rect(24, 0, 3, 3, "#"); z.rect(30, 53, 3, 3, "#")
    # Harlech Castle on its crag
    z.height(10, 2, 14, 10, 1); z.height(12, 3, 10, 7, 2)
    z.rect(10, 2, 14, 10, "."); z.rect(12, 3, 10, 7, ".")
    z.building(13, 3, 5, 4, "castle", "Harlech Castle")
    z.building(19, 3, 3, 3, "castle", show_label=False)
    z.rect(12, 9, 10, 1, "^"); z.rect(10, 2, 2, 8, "^"); z.rect(10, 10, 14, 2, ".")
    z.rect(10, 10, 12, 1, "^")
    path(z, [(12, 7), (23, 7)], "#", 1)
    z.rect(22, 8, 2, 1, ".")
    for (x, y) in [(15, 8), (20, 8), (12, 8)]:
        z.prop("rock", x, y)
    z.prop("standing_stone", 18, 8, variant=1); z.prop("bench", 16, 8)
    z.rect(12, 8, 10, 1, "f"); z.rect(14, 8, 1, 1, "f")
    z.sign(23, 6, "HARLECH CASTLE. Built 1283 to be unbeatable. Owain Glyndwr beat it anyway. 'Men of Harlech' is the song about a siege here.")
    z.sign(27, 5, "HARLECH. Castle up the crag, beach down the hill, tea in between. Croeso, welcome.")
    chat(z, "castle_guide", "tour_guide", 14, 8, "Castle Guide",
         ["Harlech Castle! King Edward's lot built it by the sea so supplies could arrive by boat.",
          "Then the sea went and moved a mile away. Medieval planning, folks."], facing="down", move="still")
    # beach life: dunes with tall grass, driftwood rocks, buoys, boats
    z.rect(13, 14, 6, 5, ","); z.rect(27, 3, 5, 8, ","); z.rect(26, 19, 4, 5, ","); z.rect(26, 44, 5, 8, ",")
    z.scatter(8, 12, 18, 14, "f", 14, 6, only=",")
    scatter_props(z, "rock", 6, 12, 14, 14, 5, 9, avoid=("s",))
    z.prop("buoy", 3, 14); z.prop("boat", 2, 19, variant=1); z.prop("buoy", 3, 22, variant=1)
    z.prop("bench", 12, 20); z.prop("lamp_post", 12, 13)
    z.sign(11, 17, "DOLPHIN WATCH. Look out to sea, count to twenty, then tell everyone you saw one. Bottlenose, nine times out of ten.")
    chat(z, "dolphin_spotter", "birdwatcher", 14, 21, "Dolphin Spotter",
         ["Cardigan Bay has the biggest bottlenose dolphin colony in the UK. They're a Special Area of Conservation.",
          "Which is lovely. Lasts until a gull lands on a buoy and I start shouting 'dolphin' for no reason."], facing="down", move="wander")
    # Barmouth: estuary with the viaduct and the walkway
    z.rect(edge(27) - 1, 25, 34 - edge(27) + 1, 7, "~")
    z.rect(30, 25, 2, 7, "#")
    z.building(10, 27, 19, 2, "aqueduct", "Barmouth Viaduct")
    for (x, y) in [(29, 25), (32, 25), (29, 31), (32, 31)]:
        z.prop("bollard", x, y)
    z.prop("boat", 33, 28, variant=1); z.prop("boat", 22, 30, variant=1); z.prop("buoy", 16, 25); z.prop("buoy", 26, 31, variant=1)
    z.sign(28, 24, "BARMOUTH BRIDGE (Pont y Bermo). Wooden, 1867, nearly half a mile. Walkers pay a small toll. Seagulls travel free, as ever.")
    z.sign(33, 32, "BARMOUTH (Abermaw). Chips, 99s and a steep staircase of regret.")
    chat(z, "toll_keeper", "villager_2", 28, 32, "Toll Keeper",
         ["Barmouth Bridge. The railway goes over it too, and the bridge swings open for tall boats.",
          "Used to. Mostly now it just swings open for my opinions."], facing="right", move="still")
    # the hermit's cove (Brook-wade): deep water, a sand island
    z.rect(8, 37, 12, 6, "o"); z.rect(8, 36, 14, 1, "^"); z.rect(8, 43, 14, 1, "^")
    z.rect(20, 37, 2, 2, "^"); z.rect(20, 41, 2, 2, "^"); z.rect(20, 39, 2, 2, "s")
    z.rect(13, 39, 3, 2, "s")
    z.height(8, 36, 14, 8, 0)
    z.prop("buoy", 10, 38); z.prop("boat", 17, 41, variant=1)
    chat(z, "hermit", "hiker", 14, 39, "Cove Hermit",
         ["Oh! A visitor. Brilliant swimming, or did you wade? Not many wade.",
          "I came here for peace and quiet. There's a lot of quiet. The peace has gone out for chips."], facing="down", move="still")
    z.sign(23, 40, "THE HERMIT'S COVE. Deep water, no ferry. Needs a bit of wade.")
    # Cadair Idris farm in the hills
    z.rect(22, 33, 8, 1, "W"); z.rect(22, 43, 8, 1, "W"); z.rect(22, 34, 1, 9, "W")
    z.building(23, 35, 5, 3, "slate_cottage", "Fferm y Bwlch", door=2)
    path(z, [(29, 38), (23, 38)], "#", 1); z.rect(22, 38, 2, 2, "#")
    z.rect(24, 40, 5, 2, "f"); z.prop("oak", 28, 36); z.prop("oak", 24, 42, variant=1)
    z.prop("planter", 22, 36)
    z.sign(29, 40, "CADAIR IDRIS (893 m). Legend: sleep on it and wake up a poet or mad. Take a flask instead.")
    chat(z, "farmer", "farmer", 26, 39, "Hill Farmer",
         ["Cadair Idris means 'the chair of Idris', a giant who liked a good view.",
          "My sheep call it Tuesday. Same hills, same weather. Lovely, mind."], facing="down", move="wander")
    # Borth and the submerged forest
    z.rect(18, 48, 3, 1, "s"); z.prop("bench", 19, 47); z.prop("lamp_post", 18, 52)
    scatter_props(z, "rock", 6, 45, 14, 10, 6, 8, avoid=("s",))
    z.sign(16, 47, "BORTH. Six thousand year old tree stumps lie under this beach and show at low tide. They do not do tours.")
    z.sign(28, 51, "ABERYSTWYTH 14 miles. Keep going south. Left is the sea.")
    chat(z, "borth_walker", "villager_5", 23, 50, "Beachcomber",
         ["Borth! The sea sometimes uncovers a whole drowned forest of oak and pine stumps. Proper ancient.",
          "People say it's the lost kingdom of Cantre'r Gwaelod. The bells still ring under the waves, apparently. I've never heard them. Bad ears."],
         facing="down", move="wander")
    z.prop("lamp_post", 23, 17); z.prop("post_box", 33, 19)
    # trainers
    trainer(z, "cai", "Surfer Cai", "Surfer", "surfer", [("petrelash", 30), ("bayrunner", 31)], 27, 15, "left",
            ["Gnarly swell out there! Well, Welsh gnarly. A bit damp and a bit sideways.",
             "Fancy a bout? Loser buys the chips."],
            "Wiped out! Lovely stuff. Mind the rip current on your way south.",
            "I'd show you my best trick. It's a very slow wave.", 600)
    trainer(z, "marged", "Birdwatcher Marged", "Birdwatcher", "birdwatcher", [("cragchough", 30), ("kitelet", 30), ("forkwing", 31)],
            28, 21, "right",
            ["Shh! There's a chough on that rock. Red legs, red beak, proper Welsh bird.",
             "You've flushed the lot. Right, battle!"],
            "Hm. Fair play. I'll put you down as 'rude but good'.", "Chough, not crow. Say it with me.", 640)
    trainer(z, "dilwyn", "Angler Dilwyn", "Angler", "angler", [("bayrunner", 31), ("petrelash", 31)], 29, 23, "right",
            ["Four hours and not a bite. You'll do instead."], "Ha! Fair catch.",
            "It was a good cast. The bridge just got in the way.", 620)
    trainer(z, "ffion", "Dog Walker Ffion", "Dog Walker", "villager_6", [("kitelet", 30), ("cragchough", 31), ("forkwing", 32)],
            28, 46, "right",
            ["The dogs are off the lead and so am I. Battle on the beach!"], "Down, boy. That's the Wildlore, not the stick.",
            "I walk eight miles a day. The dog walks me.", 660)
    trainer(z, "owain", "Student Owain", "Student", "student", [("kitelet", 31), ("petrelash", 32)], 32, 40, "left",
            ["I'm walking to Aber for Freshers' Week. Next year. I'm very prepared."], "Right. Revision it is.",
            "Aber has a very good reputation. For the bay. And the library.", 560)
    z.d["edges"] = {"north": {"to": "llanberis", "offset": 0}, "south": {"to": "aberystwyth", "offset": 0}}
    z.d["spawn"] = [25, 1]
    seal_ns(z, 24, 26, True, False); seal_ns(z, 30, 32, False, True)
    wild(z, [("cragchough", 30, 32, 24, {"time": ["dawn", "day", "dusk"]}), ("kitelet", 30, 32, 28, {"time": ["dawn", "day"]}),
             ("petrelash", 31, 32, 16, {"weather": ["drizzle", "downpour", "gale"]}), ("cragchough", 30, 32, 10, {"time": ["night"]}),
             ("kitelet", 30, 32, 12, {"weather": ["gale", "sunshine"]}), ("petrelash", 30, 31, 10, {"time": ["dusk", "night"]})])
    wild(z, [("dolphlet", 30, 32, 60, {}), ("petrelash", 31, 32, 20, {"weather": ["drizzle", "downpour", "gale"]}),
             ("dolphlet", 31, 32, 20, {"time": ["dawn", "dusk"]})], "water")
    z.save(OUT + "/cambrian_coast.json")
