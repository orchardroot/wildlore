from zlib import Z, sanctuary, shop
from nwlib import *


def dee_valley(OUT):
    z = Z("dee_valley", "Dee Valley", 64, 30, kind="route", region="north_wales", music="route_forest",
          weather={"drizzle": 38, "clear": 24, "fog": 14, "sunshine": 16, "downpour": 8})
    z.d["stage"] = "valley"
    z.border("P", 3, gaps=[(0, 18, 3, 3), (61, 18, 3, 3)])
    z.scatter(0, 0, 64, 30, "T", 55, 201, only="P")
    # woods in clumps, not a carpet
    for (x, y, w, h, n, s) in [(3, 3, 20, 4, 55, 1), (43, 3, 18, 4, 50, 2), (3, 10, 6, 8, 20, 3), (55, 10, 6, 8, 22, 4), (38, 10, 8, 7, 22, 5), (22, 21, 8, 6, 24, 6), (38, 22, 8, 5, 12, 7)]:
        z.scatter(x, y, w, h, "P", n, 100 + s)
    z.scatter(3, 3, 58, 20, "T", 40, 210)
    # the River Dee
    z.rect(30, 3, 6, 24, "~")
    z.rect(29, 9, 1, 18, "w"); z.rect(36, 9, 1, 18, "w")
    z.rect(27, 22, 12, 5, "~"); z.rect(26, 22, 1, 5, "s"); z.rect(39, 22, 1, 5, "s")
    # the Llangollen Canal, over the river on the aqueduct
    z.rect(3, 7, 58, 2, "~")
    z.legend["r"] = {"tile": "shallow", "prop": "reeds"}
    z.building(24, 7, 18, 2, "aqueduct", "Pontcysyllte Aqueduct", show_label=True)
    z.rect(3, 6, 21, 1, "H"); z.rect(42, 6, 19, 1, "H")
    z.rect(3, 9, 21, 1, "#"); z.rect(42, 9, 19, 1, "#")
    for (x, v) in [(8, 1), (15, 0), (49, 1), (55, 0)]:
        z.prop("canal_boat", x, 7, variant=v)
    z.prop("canal_boat", 20, 8, variant=2)
    z.prop("bollard", 6, 9); z.prop("bollard", 18, 9); z.prop("bollard", 45, 9); z.prop("bollard", 57, 9)
    # the road, with a stone bridge over the Dee
    pth(z, [(0, 19), (63, 19)], "#")
    z.rect(0, 18, 4, 3, "#"); z.rect(60, 18, 4, 3, "#")
    z.rect(30, 19, 6, 1, "="); z.rect(30, 18, 6, 1, "W"); z.rect(30, 20, 6, 1, "W")
    z.prop("lamp_post", 29, 18); z.prop("lamp_post", 36, 18)
    # towpath access, either side of the aqueduct
    pth(z, [(22, 9), (22, 19)], "#"); pth(z, [(43, 9), (43, 19)], "#")
    # Trevor Basin tea rooms and the lock keeper's cottage
    z.building(46, 11, 6, 3, "stone", "Trevor Basin Tea Rooms")
    z.rect(48, 14, 1, 5, "#"); z.prop("bench", 47, 14); z.prop("bench", 50, 14)
    z.building(14, 11, 4, 3, "slate_cottage", "Lock Keeper's Cottage")
    z.rect(15, 14, 1, 5, "#")
    z.prop("planter", 14, 14); z.prop("planter", 17, 14)
    # tall grass: meadows either side of the river
    for (x, y, w, h) in [(5, 11, 8, 5), (18, 13, 4, 4), (37, 12, 5, 5), (53, 15, 6, 3), (4, 21, 4, 5), (46, 21, 12, 4), (24, 12, 4, 5)]:
        z.rect(x, y, w, h, ",")
    z.rect(18, 11, 3, 1, "f"); z.rect(52, 11, 1, 3, "f"); z.rect(36, 13, 1, 1, "f")
    z.scatter(4, 10, 56, 8, "f", 22, 33, only=".")
    # hills in the south-east
    cones(z, [(51, 25, 3, 1.5, 1.5)])
    z.rect(44, 21, 15, 1, "R")
    z.scatter(44, 21, 15, 7, "R", 14, 8, only=".")
    pth(z, [(43, 19), (43, 23), (56, 23)], "#")
    # the grove behind the bramble: hedge_lay
    z.rect(5, 21, 15, 1, "T"); z.rect(5, 22, 1, 5, "T"); z.rect(19, 22, 1, 5, "T")
    z.rect(11, 21, 3, 1, "%"); z.rect(11, 20, 3, 1, "#")
    z.rect(6, 22, 13, 5, ","); z.rect(10, 23, 5, 3, "f")
    z.rect(11, 22, 3, 1, "."); z.rect(12, 24, 1, 1, ".")
    for i, (x, y) in enumerate([(10, 23), (14, 23), (10, 25), (14, 25), (12, 26)]):
        z.prop("standing_stone", x, y, variant=i % 3)
    z.prop("oak", 12, 23, variant=1); z.prop("bench", 8, 24); z.prop("bush", 17, 23); z.prop("bush", 7, 26)
    z.sign(12, 19, "GROVE (behind the brambles). Private. By which we mean, the brambles are private. Bring secateurs.")
    # props
    sprinkle(z, ["oak", "birch", "bush", "rock"], 4, 10, 56, 8, 30, 41)
    sprinkle(z, ["bush", "rock", "birch"], 38, 21, 22, 6, 6, 42)
    # signs
    z.sign(23, 11, "PONTCYSYLLTE AQUEDUCT. 1805. Eighteen arches, 38 metres up. Boats cross in the sky and nobody bats an eyelid.")
    z.sign(44, 11, "TREFOR / TREVOR BASIN. Canal boats this way, tea rooms that way. Priorities.")
    z.sign(3, 17, "WEST: Llangollen, 4 miles. DWYRAIN: Caer. Mind the geese.")
    z.sign(61, 17, "EAST: Chester. Welcome to Cymru, or goodbye, depending which way you're facing. Croeso / Hwyl.")
    z.sign(37, 21, "RIVER DEE (Afon Dyfrdwy). Pronounced 'Dee'. Spelled like it's been in a fight with a keyboard.")
    # encounters (curve 22-25)
    z.d["encounters"] = {
        "grass": [
            {"species": "brockling", "min": 22, "max": 24, "weight": 24, "time": ["dawn", "day", "dusk"]},
            {"species": "martling", "min": 23, "max": 25, "weight": 20, "time": ["dusk", "night"]},
            {"species": "tylwyth", "min": 22, "max": 24, "weight": 14, "time": ["dawn", "dusk"]},
            {"species": "flittermouse", "min": 23, "max": 25, "weight": 16, "time": ["night"]},
            {"species": "elverlet", "min": 22, "max": 25, "weight": 12, "weather": ["drizzle", "downpour", "fog"]},
            {"species": "minkshade", "min": 23, "max": 25, "weight": 10, "time": ["dusk", "night"]},
            {"species": "pipkin", "min": 22, "max": 23, "weight": 14, "time": ["day"]},
            {"species": "wispet", "min": 24, "max": 25, "weight": 10, "weather": ["fog"]}],
        "water": [
            {"species": "afanc", "min": 23, "max": 25, "weight": 25},
            {"species": "elverlet", "min": 22, "max": 25, "weight": 30},
            {"species": "minkshade", "min": 23, "max": 25, "weight": 20, "time": ["dusk", "night"]},
            {"species": "holtling", "min": 22, "max": 24, "weight": 25, "time": ["dawn", "day"]}]}
    z.d["edges"] = {"west": {"to": "llangollen", "offset": 0}, "east": {"to": "chester", "offset": 0}}
    z.d["spawn"] = [58, 19]
    # trainers
    trainer(z, "dee_angler", "Angler Meirion", "Angler", "angler", 37, 16, "down",
            [("holtling", 22), ("elverlet", 23)],
            ["Shh! You'll frighten the salmon.", "Not that anything's biting. I think the Dee has my number."],
            "Well. That's the first thing to bite me all day.", "Salmon, trout, grayling. Mostly I catch weeds and opinions.")
    trainer(z, "dee_walker", "Dog Walker Bethan", "Dog Walker", "jogger", 26, 16, "down",
            [("brockling", 22), ("minkshade", 23), ("pupplash", 22)],
            ["My dog's not allowed on the aqueduct. Neither's anyone, in the middle, by the way.", "So we battle instead!"],
            "Walkies are over. I blame you.", "He's called Telford. He builds things. Mostly holes.")
    trainer(z, "dee_birder", "Birdwatcher Gareth", "Birdwatcher", "birdwatcher", 50, 16, "down",
            [("swiftlet", 24), ("martling", 24)],
            ["Dipper! There's a dipper on that rock! ...No. It's a crisp packet.", "Battle, then. To calm me down."],
            "Even my notebook is shaking.", "Dippers walk under the water. Show-offs, frankly.")
    trainer(z, "dee_rambler", "Hiker Nerys", "Hiker", "hiker", 41, 22, "up",
            [("gritling", 24), ("roachroo", 24), ("brockling", 25)],
            ["Offa's Dyke Path, Glyndwr's Way, and now this. My knees file complaints.", "Fancy a scrap before my sandwich?"],
            "Good heavens. Fine stuff. Cheese and pickle for you.", "You can see three counties from the top of that hill. Four if you jump.")
    # chatty folk
    chat(z, "skipper", "villager_3", 10, 10, "Narrowboat Skipper",
         ["Pontcysyllte Aqueduct: 1805, Thomas Telford. Eighteen arches, 38 metres above the Dee.",
          "The boat goes at walking pace. The river's a long way down, so I just look at the tea."], "right")
    chat(z, "unesco_walker", "villager_5", 25, 10, "Walker",
         ["It's a World Heritage Site, you know. UNESCO, 2009.", "The trough is iron, held up by stone pillars. Brave of a canal, really."], "down", "wander")
    chat(z, "lock_keeper", "villager_2", 14, 15, "Lock Keeper",
         ["The canal's only about a metre and a half deep. Takes the fear out of it.",
          "Water comes in at Horseshoe Falls, up river. A weir built by Telford. It's shaped like a horseshoe, naturally."], "up")
    chat(z, "tea_lady", "villager_4", 49, 14, "Tea Room Lady",
         ["Cuppa? We do tea, cake, and a view of a very tall bridge for water.", "Bara brith's on the house. Well, on the table. You'd still pay."], "up")
    chat(z, "welsh_lad", "villager_1", 44, 17, "Boy with a Bucket",
         ["Mae'n bwrw glaw. That's 'it's raining'. You'll need it.", "Also 'diolch' is thanks. Say it to the narrowboat people. They like it."], "left", "wander")
    chat(z, "farmer_dai", "farmer", 38, 16, "Farmer Dai",
         ["My sheep think the aqueduct's rude. Won't cross it.", "Smart sheep. I wouldn't either."], "down")
    z.save(OUT + "/dee_valley.json")


def llangollen(OUT):
    z = Z("llangollen", "Llangollen", 64, 36, kind="town", region="north_wales", music="town_wales",
          weather={"drizzle": 40, "clear": 25, "fog": 8, "sunshine": 20, "downpour": 7})
    z.d["stage"] = "town"; z.d["town_id"] = "llangollen"
    z.border("P", 3, gaps=[(0, 18, 3, 3), (61, 18, 3, 3)])
    z.scatter(0, 0, 64, 36, "T", 50, 301, only="P")
    # river Dee across the north, chain bridge over it
    z.rect(3, 4, 58, 5, "~"); z.rect(3, 9, 58, 1, "w"); z.rect(3, 3, 58, 1, "s")
    z.rect(24, 4, 4, 6, "="); z.rect(23, 4, 1, 5, "W"); z.rect(28, 4, 1, 5, "W")
    z.prop("lamp_post", 24, 3); z.prop("lamp_post", 27, 3); z.prop("lamp_post", 24, 10); z.prop("lamp_post", 27, 10)
    z.prop("bollard", 25, 3); z.prop("bollard", 26, 3)
    z.prop("buoy", 12, 6); z.prop("buoy", 42, 7, variant=1)
    z.prop("boat", 50, 6, variant=1)
    z.rect(3, 10, 58, 1, "#")  # north bank path
    # main street (row 19 road, 18/20 cobbles)
    z.rect(3, 18, 58, 1, ":"); z.rect(0, 19, 64, 1, "="); z.rect(3, 20, 58, 1, ":")
    z.rect(0, 18, 4, 3, "="); z.rect(60, 18, 4, 3, "=")
    pth(z, [(25, 10), (25, 18)], ":", 2)
    # north side of the street
    z.building(5, 13, 5, 4, "slate_cottage", "Cartref")
    z.building(11, 13, 5, 4, "chapel", "Capel Bethel")
    z.building(17, 13, 5, 4, "sanctuary", "Sanctuary", door=2)
    z.building(30, 13, 5, 4, "shop", "Corner Shop", door=2)
    z.building(36, 13, 5, 4, "tudor", "Plas Newydd Tea Rooms")
    for x in (7, 13, 19, 32, 38):
        z.rect(x, 17, 1, 1, ":")
    z.rect(5, 17, 17, 1, ":"); z.rect(30, 17, 11, 1, ":")
    z.warp(19, 16, "llangollen_sanctuary", 5, 6, "up")
    z.warp(32, 16, "llangollen_shop", 4, 5, "up")
    z.rect(3, 11, 22, 2, "."); z.rect(29, 11, 12, 2, ".")
    z.rect(5, 11, 12, 1, "f")
    z.rect(3, 12, 22, 1, "H"); z.rect(29, 12, 12, 1, "H")
    z.rect(25, 12, 2, 1, ":")
    # Eisteddfod field, north-east, with the pavilion and a stage
    z.rect(43, 11, 17, 6, "."); z.rect(42, 10, 19, 1, "#")
    z.rect(42, 17, 18, 1, "F"); z.rect(42, 11, 1, 6, "F"); z.rect(42, 17, 18, 1, "F")
    z.rect(42, 17, 1, 1, "F"); z.rect(46, 17, 2, 1, ":")  # gate in the fence
    z.rect(47, 17, 2, 1, ":")
    z.building(47, 11, 9, 3, "cream_render", "Eisteddfod Pavilion", show_label=True)
    z.rect(47, 14, 9, 1, "_")
    z.rect(44, 14, 2, 2, "f"); z.rect(57, 14, 2, 2, "f")
    z.rect(46, 15, 11, 1, ":")
    z.prop("harp", 51, 14)
    for x in (44, 49, 54, 58):
        z.prop("lamp_post", x, 16)
    z.prop("market_stall", 44, 12, variant=0); z.prop("market_stall", 58, 12, variant=2)
    z.prop("bench", 49, 16); z.prop("bench", 54, 16)
    # the heritage railway station, south-east
    z.building(46, 24, 6, 2, "station", "Llangollen Railway", door=2)
    z.rect(45, 26, 10, 1, "_"); z.rect(43, 27, 14, 1, "!")
    pth(z, [(43, 21), (43, 26)], "#")
    z.rect(44, 26, 1, 1, "_")
    z.d["station"] = {"x": 48, "y": 26}
    z.npc(id="rail_guard", sprite="rail_guard", x=51, y=26, facing="left", move="still", script="rail_guard", name="Rail Guard")
    DLG.setdefault("llangollen", {})["rail_guard"] = say("Rail Guard", "All aboard the heritage line! Steam, whistles and a cup of tea on the platform.") + [{"do": "rail"}]
    z.prop("lamp_post", 46, 26); z.prop("lamp_post", 53, 26); z.prop("bench", 54, 26)
    z.rect(40, 28, 20, 2, ".")
    # Dinas Bran on its hill, south-west
    cones(z, [(14, 30, 5, 1.2, 2)])
    pth(z, [(26, 21), (26, 25), (14, 25), (14, 31)], "#")
    z.building(11, 28, 7, 3, "castle", "Castell Dinas Bran")
    z.rect(9, 26, 11, 1, "R")
    z.scatter(5, 23, 20, 10, "R", 22, 4, only=".")
    z.scatter(5, 22, 16, 10, "P", 24, 5, only=".")
    # a few cottages south of the street
    z.building(29, 22, 4, 3, "slate_cottage", "Tŷ Gwyn")
    z.building(34, 22, 4, 3, "terrace", "Bryn Teg")
    z.building(5, 22, 4, 3, "slate_cottage", show_label=False)
    z.rect(30, 25, 1, 1, ":"); z.rect(35, 25, 1, 1, ":"); z.rect(6, 25, 1, 1, ":")
    pth(z, [(30, 21), (30, 25)], ":"); pth(z, [(35, 21), (35, 25)], ":"); pth(z, [(6, 21), (6, 25)], ":")
    # tall grass by the river and on the hill
    for (x, y, w, h) in [(30, 10, 9, 1), (4, 11, 5, 1), (36, 27, 6, 3), (20, 33, 6, 2), (44, 31, 12, 2)]:
        z.rect(x, y, w, h, ",")
    z.rect(30, 10, 10, 1, "#")
    z.building(54, 22, 5, 3, "terrace", "Station Terrace")
    z.building(39, 22, 3, 3, "slate_cottage", show_label=False)
    z.building(17, 22, 4, 3, "chapel", "Capel Seion")
    z.rect(55, 25, 3, 1, ":"); z.rect(19, 25, 1, 1, ":")
    z.rect(45, 29, 14, 4, ","); z.rect(30, 31, 7, 3, ".")
    z.rect(36, 28, 1, 6, "H"); z.rect(36, 28, 9, 1, "H") 
    for i, x in enumerate([22, 23, 28, 29]):
        z.rect(x, 14, 1, 3, "f")
    z.prop("statue", 28, 15); z.prop("bench", 23, 15); z.prop("planter", 22, 17); z.prop("planter", 29, 17)
    sprinkle(z, ["oak", "birch", "bush", "planter", "rock"], 3, 10, 58, 24, 46, 31)
    z.prop("phone_box", 29, 21); z.prop("post_box", 41, 21)
    z.prop("bench", 22, 21); z.prop("bench", 45, 21)
    for x in (8, 14, 28, 34, 40, 46, 52, 58):
        z.prop("lamp_post", x, 21)
    z.sign(26, 11, "CHAIN BRIDGE. Wobble gently. It's been doing it since 1814, and the River Dee has tried to remove it more than once.")
    z.sign(53, 17, "EISTEDDFOD FIELD. Choirs from fifty countries every July. Do not shush the sopranos.")
    z.sign(3, 17, "LLANGOLLEN. Croeso i Langollen. Welcome to the town where everyone sings and nobody admits it.")
    z.sign(44, 23, "RAILWAY. Steam trains up the valley. Tickets from the man in the hat.")
    z.sign(15, 33, "DINAS BRAN. The castle on the hill. 'Fortress of the crow'. Crows have the lease.")
    z.sign(61, 17, "EAST: Dee Valley and the Aqueduct. Bring a head for heights, or a boat.")
    z.d["encounters"] = {"grass": [
        {"species": "tylwyth", "min": 25, "max": 25, "weight": 25, "time": ["dawn", "dusk"]},
        {"species": "gwyllgi", "min": 25, "max": 26, "weight": 18, "time": ["dusk", "night"]},
        {"species": "martling", "min": 25, "max": 25, "weight": 20, "time": ["night"]},
        {"species": "brockling", "min": 25, "max": 25, "weight": 20, "time": ["dawn", "day"]},
        {"species": "elverlet", "min": 25, "max": 25, "weight": 15, "weather": ["drizzle", "downpour"]},
        {"species": "wispet", "min": 25, "max": 26, "weight": 10, "weather": ["fog"]}],
        "water": [{"species": "elverlet", "min": 25, "max": 25, "weight": 40}, {"species": "afanc", "min": 25, "max": 26, "weight": 20},
                  {"species": "holtling", "min": 25, "max": 25, "weight": 40}]}
    z.d["edges"] = {"east": {"to": "dee_valley", "offset": 0}, "west": {"to": "ogwen", "offset": 0}}
    z.d["spawn"] = [58, 19]
    # the harpist: story placeholder
    z.npc(id="harpist", sprite="harpist", x=51, y=15, facing="down", move="still", script="harpist", name="Harpist")
    talk("llangollen", "harpist", "Harpist", "...placeholder harpist. Story agent, replace me.")
    chat(z, "choir_boss", "choir_singer", 47, 16, "Choir Singer",
         ["Llangollen's International Musical Eisteddfod started in 1947, to heal the world with songs.",
          "Fifty-odd countries turn up. We warm up by arguing over the sheet music. Perfect harmony."], "right")
    chat(z, "bridge_keeper", "villager_2", 28, 11, "Bridge Keeper",
         ["That's the Chain Bridge. Not very chainy these days, mind. Cars use the newer one.",
          "The Dee floods and the town puts the bridge back. We're a patient lot."], "down")
    chat(z, "castle_climber", "hiker", 22, 24, "Climber",
         ["Dinas Bran. Medieval castle on top of an Iron Age hillfort. The crows were first.",
          "Two hundred and thirty metres up. Sixty seconds of views per hundred of puff."], "right", "wander")
    chat(z, "steam_fan", "villager_6", 49, 23, "Steam Fan",
         ["The Llangollen Railway runs steam trains along the Dee. Proper ones, with whistles.",
          "I don't ride. I just stand here and smell the coal. Bliss."], "up")
    chat(z, "ladies_tour", "tour_guide", 38, 18, "Tour Guide",
         ["Plas Newydd, up the hill, was home to the Ladies of Llangollen. Two friends, 1780s, famous for good taste.",
          "Wordsworth and the Duke of Wellington dropped in for tea. They gave very high marks."], "down", "wander")
    chat(z, "canal_kid", "villager_1", 33, 11, "Kid on the Bank",
         ["Pob lwc, that's good luck. Lots of it needed when the harpist tunes up.", "Hwyl fawr, that's goodbye. I use it a lot at bedtime."], "down", "wander")
    z.save(OUT + "/llangollen.json")
    town_interiors(OUT, "llangollen", "Llangollen", (19, 17), (32, 17),
                   ["Croeso! Welcome to the Sanctuary. Everyone here hums. Do not ask us to stop.",
                    "Pop your team on the counter. We'll have them harmonising again in a jiffy.",
                    "All better! Mind the harp, it's on loan from the Eisteddfod.",
                    "The Ark terminal's by the music stand. Do try not to put a crochet in it.",
                    "Right you are. Shout if anyone needs a plaster or a tuning fork."],
                   ["Croeso! Snares, tea, bara brith and one cough sweet shaped like a harp.",
                    "Hwyl! Mind how you go. The pavement sings if you step wrong."])
