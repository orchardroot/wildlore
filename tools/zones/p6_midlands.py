# Plan 6 group C: birmingham, salisbury_plain, stonehenge (the Moot), london, underground, vane_tower_*,
# Sanctuary and Corner Shop interiors for birmingham and london, plus a nottingham stub.
#   python3 tools/zones/p6_midlands.py tools/zones data/zones
import sys, os, math
sys.path.insert(0, sys.argv[1])
from wcommon import *
from wcommon import _stand
from sc_common import mound

OUT = sys.argv[2]
ENG = "midlands"
WX_CITY = {"drizzle": 38, "clear": 28, "sunshine": 14, "fog": 8, "downpour": 8, "gale": 4}
WX_DOWN = {"clear": 30, "sunshine": 22, "drizzle": 20, "gale": 12, "fog": 10, "frost": 6}


def lamps(z, pts):
    for (x, y) in pts:
        z.prop("lamp_post", x, y)


def station2(z, x, y, w, door, label):
    """station() plus a cobbled way off the platform's west end (x-1)."""
    t = station(z, x, y, w, door, label)
    z.set(x - 1, y + 2, ":"); z.set(x - 1, y + 3, ":")
    return t


# ======================================================================= nottingham stub
def nottingham_stub():
    p = OUT + "/nottingham.json"
    if os.path.exists(p):
        return
    z = Z("nottingham", "Nottingham", 40, 40, kind="town", region=ENG, music="town_city")
    z.d["stage"] = "town"; z.d["stub"] = True; z.d["town_id"] = "nottingham"
    z.border("T", 2, gaps=[(30, 38, 3, 2)])
    z.d["edges"] = {"south": {"to": "birmingham", "offset": 0}}
    z.d["spawn"] = [31, 30]
    z.save(p)


# ======================================================================= birmingham
def birmingham():
    W, H = 64, 56
    z = Z("birmingham", "Birmingham", W, H, kind="town", region=ENG, music="town_city", weather=WX_CITY)
    z.d["stage"] = "city"; z.d["town_id"] = "birmingham"
    z.border("T", 2, gaps=[(30, 0, 3, 2), (30, 54, 3, 2)])
    z.scatter(0, 0, W, H, "P", 30, 61, only="T")
    z.rect(30, 0, 3, H, "=")
    # Centenary Square and the Library of Birmingham
    z.rect(4, 11, 26, 7, ":")
    z.building(6, 5, 14, 6, "stone", "Library of Birmingham", door=7)
    z.rect(21, 3, 8, 8, ".")
    scatter_props(z, "oak", 21, 3, 8, 8, 4, 62, avoid=(".",))
    z.rect(21, 11, 8, 1, ":")
    for (x, y) in [(8, 13), (24, 13)]:
        z.prop("statue", x, y)
    lamps(z, [(6, 12), (11, 12), (16, 12), (21, 12), (27, 12), (9, 16), (18, 16), (26, 16)])
    z.prop("bench", 10, 14); z.prop("bench", 17, 14); z.prop("planter", 5, 17); z.prop("planter", 28, 17)
    z.sign(12, 12, "LIBRARY OF BIRMINGHAM. Opened in 2013, wrapped in thousands of metal rings like a gigantic piece of jewellery, which suits the city's Jewellery Quarter. It has a rooftop garden, a Shakespeare Memorial Room, and more books than a person could read in several lifetimes of trying.")
    z.sign(26, 14, "CENTENARY SQUARE. The city's big public living room, with fountains, statues, and a very fine view of the library. Brummies will argue about what the statues are called. They will also offer you tea during the argument.")
    # New Street station
    station2(z, 40, 5, 12, 5, "New Street Station")
    z.rect(39, 7, 1, 6, ":"); z.rect(33, 4, 8, 1, ":"); z.rect(33, 4, 1, 8, ":")
    z.prop("lamp_post", 50, 7)
    rail_guard(z, 47, 7, ["New Street. Trains for every station you have visited in England, plus a few you have only heard of. Mind the gap, mind the step, mind the pigeon wearing a high-vis.",
                          "Hop aboard! Where to?"])
    # Bullring
    z.rect(33, 12, 28, 9, ":")
    z.building(41, 13, 12, 3, "cream_render", "Selfridges")
    z.building(55, 13, 6, 4, "chapel", "St Martin's", door=3)
    z.prop("statue", 36, 16)
    z.sign(37, 16, "THE BULL. A giant bronze bull has stood outside the Bullring since 2003. The Bullring has been a market since 1166, so the bull is, if anything, a bit late. Please do not ride it. People have tried.")
    z.sign(57, 19, "ST MARTIN IN THE BULLRING. A church has stood here for around 800 years, and the market has been bustling round it ever since. Choirs, bells, and a very patient vicar.")
    z.sign(42, 19, "SELFRIDGES. A building covered in 15,000 shiny aluminium discs, which look like a very expensive sequinned armadillo. It is the most photographed building in the city, and it has never once complained.")
    for (x, y) in [(34, 19), (36, 19), (38, 19), (50, 19), (53, 19)]:
        z.prop("market_stall", x, y)
    lamps(z, [(34, 14), (40, 14), (54, 14), (60, 14), (40, 20), (54, 20)])
    z.prop("bench", 45, 19); z.prop("bench", 47, 19); z.prop("phone_box", 33, 20)
    # high street, Sanctuary and Corner Shop
    z.rect(2, 25, 60, 3, "=")
    z.building(10, 21, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(13, 24, "birmingham_sanctuary", 5, 6, "up")
    z.building(17, 21, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(19, 24, "birmingham_shop", 4, 5, "up")
    z.building(4, 21, 5, 4, "terrace", show_label=False)
    z.building(23, 21, 6, 4, "red_brick", "The Anchor")
    z.building(34, 21, 7, 4, "terrace", show_label=False)
    z.building(42, 21, 6, 4, "stone", "The Rotunda")
    z.building(49, 21, 6, 4, "terrace", show_label=False)
    z.building(56, 21, 6, 4, "red_brick", "Mailbox")
    for x in (6, 24, 38, 46, 54, 58):
        z.prop("lamp_post", x, 28)
    z.prop("post_box", 3, 28); z.prop("phone_box", 28, 28)
    z.sign(44, 20, "THE ROTUNDA. A round 1960s office tower, saved from demolition and turned into flats. Birmingham has more canal mileage than Venice, and a surprising number of round buildings.")
    # the canal
    z.rect(2, 30, 60, 4, "~")
    z.rect(2, 29, 60, 1, ":"); z.rect(2, 34, 60, 1, ":")
    z.rect(30, 30, 3, 4, "=")
    z.rect(14, 30, 1, 4, "|"); z.rect(13, 30, 1, 4, "F"); z.rect(15, 30, 1, 4, "F")
    z.rect(48, 30, 1, 4, "|"); z.rect(47, 30, 1, 4, "F"); z.rect(49, 30, 1, 4, "F")
    z.rect(29, 30, 1, 4, "W"); z.rect(33, 30, 1, 4, "W")
    for (x, y) in [(5, 31), (9, 32), (19, 31), (24, 32), (38, 31), (42, 32), (54, 31), (58, 32)]:
        z.prop("canal_boat", x, y, variant=(x + y) % 3)
    for x in (4, 10, 20, 26, 36, 44, 52, 60):
        z.prop("bollard", x, 29)
    z.sign(27, 29, "BIRMINGHAM'S CANALS. The city has about 35 miles of canal, which is more than Venice. Narrowboats still drift through the heart of town. They have right of way. They also have tea.")
    # an arm of the canal, running south
    z.rect(44, 35, 3, 17, "~"); z.rect(43, 35, 1, 17, ":"); z.rect(47, 35, 1, 17, ":")
    z.rect(43, 44, 5, 1, "|")
    for (x, y) in [(45, 38), (45, 41), (45, 48), (45, 50)]:
        z.prop("canal_boat", x, y, variant=y % 3)
    z.prop("bollard", 43, 40); z.prop("bollard", 47, 46); z.prop("bench", 43, 48); z.prop("bench", 47, 38)
    # south bank: the Custard Factory, back-to-backs, a park
    z.rect(33, 35, 10, 1, ":")
    z.building(34, 37, 8, 4, "mill", "Custard Factory")
    z.building(34, 44, 8, 4, "terrace", "Jewellery Quarter")
    z.building(34, 50, 8, 3, "red_brick", show_label=False)
    z.rect(34, 41, 8, 3, ":"); z.rect(34, 48, 8, 2, ":")
    z.building(49, 37, 6, 4, "terrace", show_label=False); z.building(56, 37, 5, 4, "red_brick", show_label=False)
    z.building(49, 46, 6, 4, "red_brick", "Back-to-Backs"); z.building(56, 46, 5, 4, "terrace", show_label=False)
    z.rect(48, 41, 14, 3, ":"); z.rect(48, 50, 14, 2, ":")
    z.sign(40, 36, "THE CUSTARD FACTORY. Once the Bird's Custard works, where the yellow stuff for crumbles was made. Custard was invented in Birmingham in 1837 by Alfred Bird, so his wife, who couldn't eat eggs, could join in the pudding. A kind idea, in a bowl.")
    z.sign(51, 44, "BACK-TO-BACK HOUSES. Birmingham once had thousands of homes built in rows, sharing walls on three sides. A few survive as a museum. They are small, snug, and rather harder to get a sofa into than they look.")
    z.sign(39, 43, "THE JEWELLERY QUARTER. About 40% of all the jewellery made in Britain still comes from this one square mile. The clock tower is a memorial and a great place to say 'meet you under the clock'.")
    z.rect(3, 36, 27, 17, ".")
    z.rect(4, 38, 12, 6, ","); z.rect(8, 47, 16, 5, ",")
    z.rect(24, 38, 5, 4, "~")
    z.rect(23, 37, 7, 1, "w"); z.rect(23, 42, 7, 1, "w")
    z.rect(5, 45, 24, 1, "#"); z.rect(17, 35, 1, 18, "#")
    scatter_props(z, "oak", 3, 36, 27, 17, 14, 63, avoid=(".",))
    scatter_props(z, "bush", 3, 36, 27, 17, 10, 64, avoid=(".",))
    z.prop("bench", 19, 46); z.prop("bench", 15, 44); z.prop("lamp_post", 18, 45); z.prop("lamp_post", 16, 51)
    z.rect(49, 52, 13, 2, ",")
    # NPCs
    chat(z, "brum_boater_chat", "fisher", 12, 29, "Narrowboat Captain",
         ["Eleven miles an hour on a canal is a speed crime. We do three, and we overtake no one, and we are all very happy.",
          "Lots of Birmingham's canals were built in the 1700s to carry coal and pottery. Now they carry tea and tourists. The tea is the better cargo."], "down", "still")
    chat(z, "brum_student", "student", 20, 15, "Library Student",
         ["The Library of Birmingham is the biggest public library in Britain. The shelves go on forever. I got lost looking for the exit and found a better book.",
          "There's a rooftop garden with a view over the whole city. You can see the Bullring, the canals, and, on a clear day, my overdue fines."], "left", "wander")
    chat(z, "brum_bull", "villager_4", 38, 17, "Bullring Local",
         ["Brummies say 'bab' when they mean 'love' and 'bostin' when they mean 'brilliant'. You'll hear 'tara-a-bit' when someone leaves. It means they'll miss you.",
          "Oh, and 'Brummie' is the word for a person from Birmingham. 'Brum' for the city. 'Brumagem' if you're older than the Rotunda."], "right", "wander")
    chat(z, "brum_baker", "shopkeeper", 22, 28, "Balti Cook",
         ["The Balti was born in Birmingham, in a wok-like pan, in the 1970s. It arrives sizzling and you eat it with naan instead of cutlery. The Balti Triangle has more curry houses per square foot than anywhere sane.",
          "Mild, medium, or hot. Do not say 'hot' to impress anyone. I will remember."], "down", "still")
    chat(z, "brum_traveller", "villager_2", 35, 6, "Waiting Traveller",
         ["Birmingham New Street is the busiest station in Britain outside London. I'm told it has a great deal of rail and a great deal of pigeons.",
          "My train's late. It's alright. I've brought a book. And a pasty. And a tent."], "down", "still")
    trainer(z, "brum_boater", "Canal Boater Ezra", "Canal Boater", "fisher",
            [("heronarch", 89), ("spatelord", 89), ("levelcrane", 89)], 22, 34, "right",
            ["Mind the lock gates! And mind me, I'm in a mood. A boat's not a boat if there's no Birmingham drizzle on the roof."],
            "Fair play. You've got the touch. I'll tie up for a brew.", "I've been going between Birmingham and Worcester for a lifetime. Three miles an hour. I'll see you there in the spring.", 2400)
    trainer(z, "brum_busker", "Busker Callum", "Busker", "harpist",
            [("murmurant", 89), ("strutcoo", 89), ("sootwing", 90)], 26, 18, "down",
            ["This is a lovely acoustic version of a song you've heard four hundred times. Now with a battle."],
            "Right. No tip for me, then. Tough crowd.", "Birmingham's the second-biggest city in Britain, and it has the best busking pitch. It's next to a pasty shop.", 2350)
    trainer(z, "brum_commuter", "Commuter Priya", "Commuter", "student",
            [("raidtail", 90), ("binfox", 89), ("shuttlecog", 89)], 44, 11, "down",
            ["I've got a seven-minute window before my train, a lukewarm coffee, and a grudge against the delay. Go."],
            "That was sharper than my timetable.", "I commute to Wolverhampton. It's twelve minutes. It feels like a pilgrimage.", 2380)
    trainer(z, "brum_warden", "Warden Hollis", "Warden", "warden_grunt",
            [("samsonian", 90), ("steelheart", 89), ("rookery", 89)], 38, 27, "left",
            ["The Enclosure is curating Birmingham's canals. We shall be adding a gift shop. Every towpath needs a gift shop."],
            "Ugh. That will be in my incident report. Spelt wrong, probably.", "The Enclosure says it only wants things 'preserved'. Preserved in what, they don't say. Jam, I assume.", 2450)
    z.d["edges"] = {"north": {"to": "nottingham", "offset": 0}, "south": {"to": "salisbury_plain", "offset": 0}}
    z.d["spawn"] = [31, 28]
    wild(z, [("barkdeer", 89, 90, 12, {"time": ["dusk", "night", "dawn"]}), ("binfox", 89, 90, 14, {}), ("strutcoo", 89, 90, 12, {"time": ["day"]}),
             ("raidtail", 89, 90, 10, {}), ("murmurant", 89, 90, 10, {"time": ["day", "dawn"]}), ("stormswift", 89, 91, 6, {"weather": ["gale", "downpour"]}),
             ("sootwing", 89, 90, 8, {"time": ["night", "dusk"]}), ("rookery", 89, 90, 8, {}), ("shuttlecog", 89, 91, 6, {}), ("flittermouse", 89, 90, 8, {"time": ["night"]})])
    wild(z, [("spatelord", 89, 90, 14, {}), ("heronarch", 89, 91, 10, {}), ("rillotter", 89, 90, 16, {}), ("levelcrane", 89, 90, 10, {}), ("pierlord", 89, 90, 12, {}), ("minkshade", 89, 90, 10, {})], "water")
    z.save(OUT + "/birmingham.json")
    sanctuary(OUT, "birmingham", "Birmingham", (13, 25))
    shop(OUT, "birmingham", "Birmingham", (19, 25))
    nurse("birmingham", ["Welcome to the Birmingham Sanctuary. You are in the right place, bab. Pop your team on the counter, I'll put the kettle on while we're at it.",
                         "Right, let's have a look. Bostin little team you've got here.",
                         "All done, good as new. Tara-a-bit! And mind the canal, it's wetter than it looks.",
                         "The Ark terminal. It was built in a repurposed custard factory. The terminal is fine. The custard is only a rumour.",
                         "No bother. Come in and put your feet up. There's tea in the pot, and it's still warm. Probably."])
    shopkeeper("birmingham", "Welcome in! Snares, pork pies and a big bottle of HP sauce, which, I'll have you know, was invented a stone's throw from here.",
               "Ta-ra, then. Mind how you go over the bridges.")


# ======================================================================= salisbury plain
HORSE = [
    "..............hhh....",
    ".............hhhhh...",
    "..hh........hhhhhhh..",
    "..hhhhhhhhhhhhhhhh...",
    ".hhhhhhhhhhhhhhhhh...",
    "hhhhhhhhhhhhhhhhh....",
    ".hhhhhhhhhhhhhhhh....",
    "..hhhhhhhhhhhhhh.....",
    "..hhh..hhh.hhh.......",
    "..hh...hhh.hhh.......",
    "..hh....hh.hh........",
    "..h.....hh.h.........",
]


def salisbury():
    W, H = 60, 72
    z = Z("salisbury_plain", "Salisbury Plain", W, H, fill="c", kind="route", region=ENG, music="route_mountain", weather=WX_DOWN)
    z.d["stage"] = "grass"
    z.legend["c"] = {"tile": "grass", "colour": "#aab46c"}                       # chalk downland
    z.legend["g"] = {"tile": "tall_grass", "colour": "#98a35a", "prop": "none"}  # long chalk grass: encounters
    z.legend["h"] = {"tile": "grass", "colour": "#f6f5ec"}                       # the white horse (cut chalk)
    z.border("T", 2, gaps=[(30, 0, 3, 2), (29, 70, 3, 2)])
    z.scatter(0, 0, W, H, "P", 24, 71, only="T")
    # the great hill and its white horse (a figure of white tiles on the slope)
    mound(z, 43, 25, 14, 9, 3)
    ox, oy = 33, 22
    for j, row in enumerate(HORSE):
        for i, ch in enumerate(row):
            if ch == "h":
                z.set(ox + i, oy + j, "h")
    # the route: a chalk track winding south
    path(z, [(30, 0), (30, 12), (20, 12), (20, 40), (36, 40), (36, 58), (29, 58), (29, 69)], "#", 3)
    # barrows: small round humps
    for (cx, cy) in [(10, 8), (14, 10), (12, 13), (46, 52), (50, 49), (8, 52), (11, 55), (50, 62), (46, 6), (6, 30), (44, 40)]:
        mound(z, cx, cy, 2, 1, 1)
    # long grass patches
    for (x, y, w, h) in [(4, 18, 10, 8), (24, 4, 5, 6), (6, 42, 11, 8), (40, 42, 12, 8), (40, 62, 12, 7), (6, 62, 14, 6), (24, 28, 5, 8), (3, 3, 6, 6), (50, 8, 6, 8)]:
        z.rect(x, y, w, h, "g")
    path(z, [(30, 0), (30, 12), (20, 12), (20, 40), (36, 40), (36, 58), (29, 58), (29, 69)], "#", 3)
    # field fences
    z.rect(40, 36, 17, 1, "F"); z.rect(56, 36, 1, 4, "F")
    z.rect(4, 36, 9, 1, "F"); z.rect(4, 36, 1, 4, "F")
    scatter_props(z, "bush", 3, 3, 54, 66, 24, 72, avoid=("c",))
    scatter_props(z, "rock", 3, 3, 54, 66, 10, 73, avoid=("c",))
    scatter_props(z, "oak", 3, 3, 54, 30, 4, 74, avoid=("c",))
    z.sign(33, 18, "WESTBURY WHITE HORSE. Look right! A horse 180 feet long is cut into the chalk of the hill, with a pale body and a very good tail. An older horse is said to celebrate King Alfred's victory at Edington; the present one dates from 1778 and is a good deal more elegant.")
    z.sign(34, 38, "SALISBURY PLAIN. 300 square miles of chalk downland, mostly used by the army for training. The red flags mean 'no walking'. The white flags mean 'perhaps walking'. The pale blue flags mean 'we have given up and gone for tea'.")
    z.sign(12, 15, "BARROWS. Bronze Age burial mounds, 4,000 years old, dotted across the downs. Please do not dig. The Archaeological Society will be along shortly with trowels and very strong opinions.")
    z.sign(28, 57, "STONEHENGE: 5 MILES. Follow the track. If you hear a deep, distant humming, that is the stones, or a tractor, or the army. Probably the army.")
    # NPCs
    chat(z, "plain_birdwatcher", "birdwatcher", 25, 22, "Skylark Spotter",
         ["Listen up. That's a skylark. It rises straight up and sings without stopping for several minutes. It sings the whole time it's going up, and the whole time it's coming down. Show-off.",
          "Salisbury Plain is a key bird place: skylarks, stone-curlews, and, since recently, great bustards, huge birds brought back after a century away. They are very heavy and rather embarrassed about it."], "right", "still")
    chat(z, "plain_shepherd", "farmer", 40, 52, "Downland Shepherd",
         ["These downs have been grazed for thousands of years. The sheep make the short turf that the wildflowers love. Sheep: the original gardeners.",
          "Don't climb the fence near the red flags. The army aren't interested in sheep, but the sheep aren't interested in the army either. It's a truce."], "down", "wander")
    chat(z, "plain_hillwalker", "hillwalker", 22, 28, "Ridgeway Walker",
         ["I'm walking the whole chalk spine of England. It starts at Avebury, near here, and runs for 87 miles on tracks older than Rome.",
          "The Wiltshire downs hold more ancient monuments than anywhere in Britain. You can't throw a flint without hitting a barrow. I've stopped trying."], "down", "wander")
    chat(z, "plain_horse_kid", "villager_5", 42, 34, "Local Child",
         ["From down here the horse looks like a horse. From up there it looks like a bunch of white patches. Nobody knows what to make of that, so we don't mention it.",
          "They have to scrub the horse every few years or it goes green. The county gets very cross if it goes green."], "up", "still")
    trainer(z, "plain_archaeologist", "Archaeologist Dr Lowe", "Archaeologist", "student",
            [("tunneller", 89), ("sarsenite", 90), ("megalorn", 89)], 26, 20, "left",
            ["Fascinating! A live specimen, on an actual dig site. Hold still while I measure your shoes. And your team."],
            "Remarkable. Typical! Another theory with a hole in it.", "Everyone says Stonehenge is a calendar. Or an observatory. Or a temple. I say it's a really good place to put stones.", 2500)
    trainer(z, "plain_druid", "Druid Elowen", "Druid", "druid",
            [("pinewraith", 90), ("wispet", 89), ("hazeldoze", 90)], 25, 34, "left",
            ["Greetings, traveller. I'm on my way to the solstice. It's October. We're early. It's good to be early. It's very fashionable."],
            "A fair outcome. The stones will remember this. They remember everything. They never say.", "I've been a druid for twelve years. The robes are warm, the hours are flexible, and the oak is excellent company.", 2480)
    trainer(z, "plain_warden", "Warden Strand", "Warden", "warden_grunt",
            [("quarrion", 90), ("stoopfalcon", 89), ("samsonian", 90)], 32, 48, "right",
            ["This landscape is unmanaged. By which I mean it isn't managed by us. The Enclosure will 'curate' it. With a ticket booth."],
            "Hm. Not what the brochure said would happen.", "We could put a gate on the chalk horse, you know. A little gate. With a fee. Why does everybody get so upset?", 2550)
    trainer(z, "plain_birdwatch_tr", "Birdwatcher Maud", "Birdwatcher", "birdwatcher",
            [("stoopfalcon", 91), ("goldeneyrie", 90), ("forkwing", 90)], 43, 56, "left",
            ["Shh! I'm waiting for a stone-curlew. It's eleven inches tall, brown, and an absolute master of standing still. You'll scare it. Battle quietly."],
            "Bother! There goes the curlew.", "A curlew has the saddest call in the world, and the most beautiful. They're always together in that one.", 2560)
    z.d["edges"] = {"north": {"to": "birmingham", "offset": 0}, "south": {"to": "stonehenge", "offset": 0}}
    z.d["spawn"] = [31, 8]
    wild(z, [("churrjar", 89, 91, 14, {"time": ["dusk", "night"]}), ("moldiwarp", 89, 90, 14, {}), ("tunneller", 90, 91, 8, {}), ("hazeldoze", 89, 90, 10, {}),
             ("stoopfalcon", 90, 91, 6, {"time": ["day"]}), ("goldeneyrie", 90, 91, 5, {"weather": ["gale", "clear"]}), ("loaghtan", 89, 90, 10, {"time": ["day", "dawn"]}),
             ("barkdeer", 89, 90, 8, {"time": ["dawn", "dusk"]}), ("snowhare", 89, 90, 4, {"weather": ["frost"]}), ("gealhare", 90, 91, 8, {"time": ["dawn", "dusk"]}),
             ("hootlet", 89, 90, 8, {"time": ["night"]}), ("quarrion", 90, 91, 5, {})])
    z.save(OUT + "/salisbury_plain.json")


# ======================================================================= stonehenge
def ring_pts(cx, cy, r, n, phase=0.0):
    pts = []
    for k in range(n):
        a = phase + 2 * math.pi * k / n
        pts.append((cx + round(r * math.cos(a)), cy + round(r * math.sin(a))))
    return pts


def stonehenge():
    W, H = 60, 58
    cx, cy = 30, 29
    z = Z("stonehenge", "Stonehenge", W, H, fill="c", kind="route", region=ENG, music="legend",
          weather={"clear": 34, "sunshine": 28, "fog": 12, "drizzle": 10, "gale": 10, "frost": 6})
    z.d["stage"] = "grass"
    z.legend["c"] = {"tile": "grass", "colour": "#a5b068"}
    z.legend["g"] = {"tile": "tall_grass", "colour": "#919c55", "prop": "none"}
    z.legend["p"] = {"tile": "path", "colour": "#c9bf94"}                        # trampled chalk
    z.legend["m"] = {"tile": "grass", "colour": "#b4ba74"}
    z.border("T", 2, gaps=[(29, 0, 3, 2), (58, 28, 2, 3)])
    z.scatter(0, 0, W, H, "P", 14, 81, only="T")
    # the great sward and the chalk circle
    for y in range(H):
        for x in range(W):
            d = math.hypot(x - cx, y - cy)
            if d < 11.5 and z.g[y][x] == "c":
                z.g[y][x] = "m"
            if d < 4.5 and z.g[y][x] in "cm":
                z.g[y][x] = "p"
    # the Avenue from the north gate, the way out east, the visitor path
    z.rect(29, 0, 3, 19, "p")
    z.rect(40, 28, 20, 3, "p")
    z.rect(29, 40, 3, 11, "p")
    # gates: a fence with a wide gap, gate stones, Kit stands beside the gap
    z.rect(3, 9, 26, 1, "F"); z.rect(32, 9, 25, 1, "F")
    z.prop("standing_stone", 28, 9, variant=1); z.prop("standing_stone", 32, 9, variant=1)
    z.sign(33, 8, "THE MOOT. All ten Spirit Stones are sworn to sit here, one midsummer in every generation. The Four Winds keep the gates and the Champion keeps the centre. Please wipe your boots on the chalk. The chalk does not mind.")
    # the outer circle: 30 sarsens, ten inner stones, the heel stone out on the avenue
    for i, (x, y) in enumerate(ring_pts(cx, cy, 10, 36)):
        z.prop("standing_stone", x, y, variant=i % 3)
    for i, (x, y) in enumerate(ring_pts(cx, cy, 6, 10, phase=math.pi / 10)):
        z.prop("standing_stone", x, y, variant=(i + 1) % 3)
    z.prop("standing_stone", 33, 14, variant=2)
    z.sign(34, 14, "THE HEEL STONE. On midsummer morning the sun rises just beside this stone, line-straight with the centre of the circle. The builders of 4,500 years ago did the sums with sticks, string and an exceptional patience.")
    for (x, y) in [(cx, cy - 7), (cx, cy + 7), (cx - 7, cy), (cx + 7, cy), (cx, cy)]:
        clear_prop(z, x, y)
        z.set(x, y, "p")
    # the low earth bank round the circle (one step up, easy to walk over), and wildflowers on the sward
    for y in range(H):
        for x in range(W):
            d = math.hypot(x - cx, y - cy)
            if 14 <= d < 15.6 and not z.g[y][x] in "F":
                z.hg[y][x] = 1
    r = random.Random(84)
    for _ in range(90):
        fx, fy = r.randrange(3, W - 3), r.randrange(3, H - 3)
        if z.g[fy][fx] in "cm" and math.hypot(fx - cx, fy - cy) > 11.5:
            z.g[fy][fx] = "f"
    # barrows in the distance
    for (bx, by) in [(8, 20), (12, 24), (50, 18), (48, 52), (10, 46), (6, 36)]:
        mound(z, bx, by, 2, 1, 1)
    # visitor centre, car park, path
    z.rect(40, 43, 17, 12, "=")
    z.building(43, 44, 12, 5, "cream_render", "Visitor Centre")
    z.rect(43, 49, 12, 1, ":")
    z.rect(36, 46, 7, 1, "p"); z.rect(36, 36, 1, 11, "p")
    z.prop("bench", 45, 50); z.prop("lamp_post", 42, 50); z.prop("lamp_post", 55, 50)
    z.prop("bench", 28, 41); z.prop("bench", 32, 41)
    z.sign(39, 47, "VISITOR CENTRE. Pop in for the tea, the exhibition, and the full-size model of a Neolithic house. The shuttle bus is the only way to arrive that does not involve three hours of walking and a small crisis.")
    z.sign(31, 42, "PLEASE DO NOT TOUCH THE STONES. They are 4,500 years old, and they have been touched by far too many cows already. If a stone touches you, that is a spiritual matter.")
    z.sign(56, 27, "LONDON. About 90 miles by road. The Ministry of Plot Convenience has compressed this to a short path, and the cartographer wishes it noted she was not consulted. Keep walking.")
    for (x, y, w, h) in [(3, 11, 11, 8), (46, 11, 11, 8), (3, 48, 12, 8), (3, 28, 7, 6), (46, 33, 10, 6)]:
        z.rect(x, y, w, h, "g")
    scatter_props(z, "bush", 3, 3, 54, 52, 14, 82, avoid=("c",))
    scatter_props(z, "oak", 3, 3, 54, 52, 5, 83, avoid=("c",))
    # story NPCs (placeholders: the story agent rewrites the scripts)
    for nid, x, y, f in [("wind_aelwen", cx - 7, cy, "right"), ("wind_fergus", cx, cy - 7, "down"),
                         ("wind_aoife", cx, cy + 7, "up"), ("wind_wilf", cx + 7, cy, "left")]:
        _stand(z, x, y)
        z.npc(id=nid, sprite=nid, x=x, y=y, facing=f, move="still", script="moot_wind")
    _stand(z, cx, cy)
    z.npc(id="champion_garside", sprite="prof_garside", x=cx, y=cy, facing="down", move="still", script="moot_centre")
    _stand(z, 28, 8)
    z.npc(id="kit", sprite="kit", x=28, y=8, facing="right", move="still", script="kit_moot")
    script("stonehenge", "moot_wind", say("Wind", "(placeholder) One of the Four Winds. The story agent writes the Moot gauntlet here."))
    script("stonehenge", "moot_centre", say("Professor Garside", "(placeholder) The Champion of the Moot waits in the centre of the circle."))
    script("stonehenge", "kit_moot", say("Kit", "(placeholder) Kit, at the gates of the Moot."))
    chat(z, "moot_visitor", "tour_guide", 36, 40, "Stonehenge Guide",
         ["The big stones here are sarsens, and they came from about 25 miles away. The smaller bluestones came from Wales, 150 miles off. How? Nobody's quite sure, which makes it one of the best mysteries in Britain.",
          "The Moot gathers here. I'm not supposed to say that. It's what the inside of the Visitor Centre says. Quietly."], "right", "wander")
    chat(z, "moot_picnic", "villager_3", 20, 45, "Picnicker",
         ["I sat down for a sandwich and the stones hummed. I'm a scientist, so I'm calling it 'acoustics'.",
          "On midsummer morning the sun comes up right through the Avenue, and everyone cheers. It's the best sunrise party in Britain, and the dress code is 'wrapped up warm'."], "up", "still")
    trainer(z, "stone_druid", "Druid Brenin", "Druid", "druid",
            [("sarsenite", 92), ("tapknock", 92), ("megalorn", 92)], 21, 15, "right",
            ["Another traveller for the Moot! We're early. We're always early. We've been early for four thousand years."],
            "The stones are impressed. They'll probably say so in a thousand years.", "Druids hold their ceremonies here at the solstice. I just come for the weather. The weather is on my side.", 3000)
    trainer(z, "stone_archaeologist", "Archaeologist Dr Reyes", "Archaeologist", "student",
            [("tunneller", 92), ("coblynn", 93), ("sarsenite", 92)], 46, 23, "left",
            ["The key question about Stonehenge is: how did they move them? My theory involves ropes, logs, and a thoroughly patient village."],
            "My theory just fell over. Like a very polite stone.", "They've found a ring of enormous pits near here. Prehistoric Britain was bigger than we thought. Smarter, too.", 3050)
    trainer(z, "stone_warden", "Warden Ashby", "Warden", "warden_grunt",
            [("quarrion", 93), ("stoopfalcon", 92), ("samsonian", 93)], 44, 29, "left",
            ["This site is fully curated. I'm told I must charge for the view. Forty pounds. Cash. Or a battle, to be discussed."],
            "You didn't have to be so good at it. It's embarrassing.", "I said the Moot would be a tough crowd. Nobody listened. I'm just a Warden.", 3100)
    z.d["edges"] = {"north": {"to": "salisbury_plain", "offset": 0}, "east": {"to": "london", "offset": 0}}
    z.d["spawn"] = [30, 6]
    wild(z, [("sarsenite", 92, 94, 10, {}), ("churrjar", 92, 93, 12, {"time": ["dusk", "night"]}), ("tunneller", 92, 93, 10, {}), ("barkdeer", 92, 93, 8, {"time": ["dawn", "dusk"]}),
             ("wispet", 92, 93, 8, {"time": ["night", "dusk"]}), ("megalorn", 92, 94, 6, {"weather": ["fog"]}), ("tapknock", 92, 93, 8, {}),
             ("hushwing", 92, 93, 8, {"time": ["night"]}), ("stoopfalcon", 92, 93, 6, {"time": ["day"]})])
    z.save(OUT + "/stonehenge.json")


# ======================================================================= london
def london():
    W, H = 80, 66
    z = Z("london", "London", W, H, kind="town", region=ENG, music="town_london", weather=WX_CITY)
    z.d["stage"] = "city"; z.d["town_id"] = "london"
    z.border("T", 2, gaps=[(0, 28, 2, 3)])
    z.scatter(0, 0, W, H, "P", 30, 91, only="T")
    # the Thames
    z.rect(2, 31, 76, 10, "~")
    z.rect(2, 29, 76, 2, ":"); z.rect(2, 41, 76, 4, ":")
    z.rect(2, 26, 76, 3, "=")
    z.rect(0, 28, 2, 3, "=")
    # Westminster Bridge
    z.rect(15, 29, 3, 14, "="); z.rect(14, 31, 1, 10, "W"); z.rect(18, 31, 1, 10, "W")
    # Millennium footbridge
    z.rect(30, 31, 2, 10, "|"); z.rect(29, 31, 1, 10, "F"); z.rect(32, 31, 1, 10, "F")
    # Tower Bridge: two castle towers with the road between
    z.rect(51, 29, 3, 16, "=")
    z.rect(50, 31, 1, 2, "W"); z.rect(54, 31, 1, 2, "W"); z.rect(50, 36, 1, 5, "W"); z.rect(54, 36, 1, 5, "W")
    z.building(47, 33, 4, 3, "castle", "Tower Bridge")
    z.building(54, 33, 4, 3, "castle", show_label=False)
    z.sign(52, 30, "TOWER BRIDGE. Not London Bridge! That is a different, plainer bridge. This one has two towers, a bascule that lifts for tall ships, and a glass walkway for people who like to feel brave. Someone once drove a double-decker over the gap while it was opening. The bus is fine.")
    for (x, y, v) in [(8, 35, 0), (23, 33, 1), (38, 38, 0), (44, 34, 1), (64, 36, 0), (70, 33, 1), (59, 39, 1)]:
        z.prop("boat", x, y, variant=v)
    for (x, y) in [(10, 38), (26, 37), (40, 33), (62, 32), (72, 38)]:
        z.prop("buoy", x, y)
    z.sign(25, 29, "THE THAMES. Britain's most famous river, with 50-odd bridges in the capital alone. Once so smelly that Parliament hung wet curtains at the windows, now clean enough for seals, cormorants and the occasional confused porpoise.")
    # Westminster
    z.building(3, 6, 15, 8, "cathedral", "Westminster")
    z.prop("lighthouse", 19, 13)
    z.rect(3, 14, 22, 6, ":"); z.rect(18, 14, 4, 12, ":")
    for (x, y) in [(5, 15), (11, 15), (17, 15)]:
        z.prop("statue", x, y)
    lamps(z, [(4, 18), (9, 18), (14, 18), (21, 19), (24, 17)])
    z.prop("phone_box", 6, 18); z.prop("phone_box", 7, 18); z.prop("bench", 12, 17); z.prop("bench", 24, 19)
    z.sign(10, 17, "PALACE OF WESTMINSTER. Where the nation argues about the nation. The clock tower is called the Elizabeth Tower. The bell inside is Big Ben, which was named after either Sir Benjamin Hall or a boxer called Ben Caunt. Everybody agrees the bell is loud.")
    z.sign(23, 19, "BIG BEN CLOCK. The clock keeps time by a pile of old pennies on the pendulum. To speed it up, add a penny. London has its priorities.")
    # Sanctuary, Corner Shop, Underground entrance
    z.building(3, 21, 6, 5, "sanctuary", "Sanctuary", door=3)
    z.warp(6, 25, "london_sanctuary", 5, 6, "up")
    z.building(10, 21, 5, 5, "shop", "Corner Shop", door=2)
    z.warp(12, 25, "london_shop", 4, 5, "up")
    z.building(22, 21, 5, 5, "stone", "Underground", door=2)
    z.warp(24, 25, "underground", 48, 47, "up")
    z.prop("phone_box", 21, 25); z.prop("post_box", 29, 25)
    z.sign(28, 24, "THE UNDERGROUND. The oldest metro in the world, opened 1863. The map is a diagram, not a map, because Harry Beck knew nobody cares where anything really is. They care about where to change. The mice are unionised.")
    # Vane Tower, the Enclosure's glass tower
    z.rect(30, 20, 16, 6, ":"); z.rect(30, 14, 3, 6, ":"); z.rect(43, 14, 3, 6, ":")
    z.building(33, 12, 9, 8, "liver_building", "Vane Tower", door=4)
    z.warp(37, 19, "vane_tower_lobby", 15, 21, "up")
    z.prop("statue", 31, 22); z.prop("statue", 44, 22)
    z.prop("planter", 34, 21); z.prop("planter", 40, 21); z.prop("lamp_post", 36, 21); z.prop("lamp_post", 38, 21)
    z.sign(35, 22, "THE VANE TOWER. Lord Vane's glass headquarters: 'a monument to a more orderly countryside'. The revolving door has never once let anyone in. It does, in fairness, rotate with great enthusiasm.")
    # King's Cross
    station2(z, 47, 21, 9, 4, "King's Cross Station")
    z.rect(46, 23, 1, 3, ":")
    z.prop("lamp_post", 55, 23)
    rail_guard(z, 53, 23, ["King's Cross. Platform nine and three-quarters is that wall over there. Don't run at it. I've seen what it does to shins.",
                           "All aboard for any station you've visited. Where to?"])
    # the Tower of London and the raven lawn
    z.rect(58, 12, 20, 1, ":"); z.rect(57, 12, 1, 14, ":")
    z.rect(58, 13, 20, 12, ".")
    z.rect(58, 13, 20, 1, "F"); z.rect(58, 13, 1, 12, "F"); z.rect(77, 13, 1, 12, "F"); z.rect(58, 24, 20, 1, "F")
    z.rect(66, 13, 3, 1, ":"); z.rect(66, 24, 3, 2, ":")
    z.rect(66, 14, 3, 10, "#")
    z.building(60, 5, 17, 7, "castle", "Tower of London")
    scatter_props(z, "oak", 59, 14, 18, 10, 4, 92, avoid=(".",))
    scatter_props(z, "bush", 59, 14, 18, 10, 6, 93, avoid=(".",))
    z.prop("bench", 63, 20); z.prop("bench", 72, 20); z.prop("lamp_post", 65, 15); z.prop("lamp_post", 69, 15)
    z.sign(70, 12, "THE TOWER OF LONDON. A palace, a fortress, a prison and a treasury, all in one. It has the Crown Jewels and a lot of stairs. The Yeoman Warders, nicknamed Beefeaters, still live inside and give excellent tours. One of them will tell you the whole history, then tell you off for trying to pet a raven.")
    z.sign(73, 22, "THE RAVENS. If the ravens leave the Tower, it is said, the kingdom will fall. So there are always at least six, their wings are gently trimmed, and they are very well fed. They are also rather smug about all of it.")
    # south bank
    z.rect(3, 45, 28, 17, ".")
    z.rect(5, 47, 12, 6, ","); z.rect(5, 55, 18, 5, ","); z.rect(22, 47, 7, 5, ",")
    z.rect(16, 45, 1, 17, "#"); z.rect(3, 54, 28, 1, "#")
    scatter_props(z, "oak", 3, 45, 28, 17, 14, 94, avoid=(".",))
    scatter_props(z, "bush", 3, 45, 28, 17, 8, 95, avoid=(".",))
    z.prop("bench", 18, 53); z.prop("bench", 14, 53); z.prop("lamp_post", 17, 46)
    z.building(33, 45, 10, 5, "tudor", "Shakespeare's Globe")
    z.rect(33, 50, 10, 1, ":")
    z.prop("lighthouse", 47, 50)
    z.rect(51, 43, 3, 18, "=")
    z.rect(55, 57, 21, 4, ":"); z.rect(55, 46, 3, 12, ":"); z.rect(70, 47, 6, 10, ":")
    z.building(58, 47, 12, 9, "aqueduct", "London Eye")
    for x in (56, 58, 60, 62):
        z.prop("market_stall", x, 59)
    lamps(z, [(35, 51), (41, 51), (56, 45), (71, 45), (71, 55), (52, 61)])
    z.sign(38, 51, "SHAKESPEARE'S GLOBE. A faithful rebuild of the 1599 theatre, with a thatched roof (fire-safe, now) and a yard where the 'groundlings' stand for a few quid and shout. The original burned down during a play, after a cannon went off a bit enthusiastically.")
    z.sign(48, 51, "THE SHARD. The tallest building in Western Europe when it opened in 2012: 310 metres of glass, shaped like a shard of glass, which is nicely honest. Please do not throw anything at it, you will be on camera.")
    z.sign(62, 57, "THE LONDON EYE. A big wheel by the Thames. A ride takes 30 minutes and rises 135 metres. You can see Windsor Castle on a clear day, and your own breath on a cold one.")
    z.sign(57, 60, "BOROUGH MARKET. A market has stood near here for a thousand years. You can buy cheese, bread, oysters, and a sausage roll bigger than your head. London food has come a very long way since the pie.")
    z.prop("phone_box", 49, 43); z.prop("post_box", 31, 43)
    # NPCs
    chat(z, "lon_beefeater", "tour_guide", 64, 26, "Yeoman Warder",
         ["Good day! Welcome to His Majesty's Royal Palace and Fortress. Or Her Majesty's. We update the signs. Beefeater is a nickname, from when we were allowed all the beef we wanted.",
          "Our ravens are the finest in the land. Please don't feed them, annoy them, or ask them to say 'nevermore'. They're wise, and they're touchy."], "down", "still")
    chat(z, "lon_ravenmaster", "farmer", 62, 17, "Ravenmaster",
         ["I look after the ravens. They arrive each morning for breakfast. They check the weather, steal a biscuit, and leave a review.",
          "Every raven has a name and a personality. Merlina is cheeky, Jubilee is sulky, and Poppy would sell you out for a sausage. There is also one raven who's not mine. I'm not sure whose she is."], "right", "still")
    chat(z, "lon_cabbie", "villager_1", 43, 27, "Cabbie",
         ["Black cab drivers do 'the Knowledge': twenty-five thousand streets and every landmark, in their heads. It takes about three years. I did not have a social life. I did, however, learn every street.",
          "Where to, guv? Oh, you've got a Wildlore rail ticket. Good luck to you."], "down", "wander")
    chat(z, "lon_local", "villager_6", 20, 28, "Westminster Local",
         ["The Palace of Westminster has 1,100 rooms, 100 staircases and 3 miles of passages. If it's good enough to get lost in, it's good enough to get lost in.",
          "London's a city of villages, my gran says. Soho is one. Chelsea is one. Peckham is one. I live in one called 'Where did I park?'."], "right", "wander")
    chat(z, "lon_tourist", "student", 40, 52, "Tourist",
         ["I was told there'd be a fog, a bus, and a man with a red coat. So far I've had three buses and a man in a sandwich board. I'll take it.",
          "Is that glass tower open to the public? The door keeps spinning me round. I've gone round eleven times."], "down", "wander")
    _stand(z, 70, 19)
    z.npc(id="bran_spot", sprite="creature:bran", x=70, y=19, facing="down", move="still", script="bran", hide_if="caught_bran")
    script("london", "bran", say("Bran's Raven", "(placeholder) A huge raven watches you from the lawn.", "Kraa."))
    trainer(z, "lon_busker", "Busker Odessa", "Busker", "harpist",
            [("squawkster", 94), ("stoopfalcon", 94), ("raidtail", 94)], 36, 28, "up",
            ["London's the best busking city in the world, and the worst. The tip jar is a love letter and an insult at once. Here we go."],
            "I'll put that in the busking diary: 'Was beaten. Played anyway.'", "I've been busking on this bridge since I was nineteen. The pigeons know my set list. Some request it.", 3300)
    trainer(z, "lon_beefeater_tr", "Beefeater Marlowe", "Beefeater", "tour_guide",
            [("stagmajor", 95), ("squawkster", 94), ("tubemole", 94)], 67, 27, "up",
            ["Good morning! I am a Yeoman Warder of the Royal Palace. I should say, this is a friendly bout. We have a long tradition of those. And of tea."],
            "Splendid. Very good form. Mind the cobbles on your way out.", "In our tradition a Beefeater lives inside the Tower, and has to be home by 9:30pm for the Ceremony of the Keys. It's a very strict curfew.", 3400)
    trainer(z, "lon_commuter", "Commuter Rafferty", "Commuter", "villager_2",
            [("tubemole", 94), ("raidtail", 94), ("murmurant", 95)], 49, 27, "left",
            ["Sorry, excuse me, sorry. Mind the... oh, you're blocking the escalator. Stand right, walk left! Battle left!"],
            "Terrible. I'll have to take the next one.", "I once travelled the whole Circle Line, with a sandwich, for pleasure. It took an hour. Nobody believes me.", 3350)
    trainer(z, "lon_warden_a", "Warden Fitzgerald", "Warden", "warden_grunt",
            [("samsonian", 95), ("steelheart", 94), ("stoopfalcon", 95)], 32, 24, "right",
            ["Welcome to the Vane Tower plaza. You may admire the building from the pavement. Do not admire it from inside. You are not insured."],
            "That was not in the training manual.", "Lord Vane's up top. If you're thinking of going in, I have a clipboard that says you shouldn't.", 3450)
    trainer(z, "lon_warden_b", "Warden Okonkwo", "Warden", "warden_grunt",
            [("quarrion", 95), ("stagmajor", 94), ("shuttlecog", 95)], 44, 24, "left",
            ["Access to the tower is restricted to Enclosure staff and persons with a really compelling excuse."],
            "Hm. That was a compelling excuse.", "I actually like the countryside. I'm just in a bad job.", 3450)
    z.d["edges"] = {"west": {"to": "stonehenge", "offset": 0}}
    z.d["spawn"] = [30, 27]
    wild(z, [("parakit", 94, 95, 14, {}), ("squawkster", 94, 96, 10, {"time": ["day", "dusk"]}), ("stagbeet", 94, 95, 12, {}), ("stagmajor", 95, 96, 6, {"time": ["night", "dusk"]}),
             ("tubemole", 94, 95, 10, {}), ("binfox", 94, 95, 12, {"time": ["night", "dusk"]}), ("raidtail", 94, 95, 10, {}), ("strutcoo", 94, 95, 10, {"time": ["day"]}),
             ("stoopfalcon", 94, 96, 5, {"time": ["day"]}), ("flittermouse", 94, 95, 8, {"time": ["night"]}), ("rookery", 94, 95, 8, {})])
    wild(z, [("spatelord", 94, 95, 14, {}), ("pierlord", 94, 95, 14, {}), ("rillotter", 94, 95, 12, {}), ("heronarch", 94, 96, 10, {}), ("chipgull", 94, 95, 14, {})], "water")
    z.save(OUT + "/london.json")
    sanctuary(OUT, "london", "London", (6, 26))
    shop(OUT, "london", "London", (12, 26))
    nurse("london", ["Welcome to the London Sanctuary. Mind the gap between the counter and the floor. Pop your team down, dear.",
                     "Let me have a look. Busy day. Busy city. Busy everything.",
                     "All done. Good as new. And that's a tourist-grade promise, not a Tube-grade one.",
                     "The Ark terminal. It's wired to the Underground. If it goes quiet, it's a signal failure.",
                     "No problem. Have a sit. The kettle's on. It's always on. There's a rota."])
    shopkeeper("london", "Welcome in! Snares, a scone, and last month's travelcard. I'll throw in an umbrella. It has been sold twice already.",
               "Mind how you go. And remember: stand on the right.")


# ======================================================================= underground
def underground():
    W, H = 64, 52
    z = Z("underground", "The Underground", W, H, fill="x", kind="interior", region="", music="dungeon_underground", weather={})
    z.d["stage"] = "city"
    z.legend["k"] = {"tile": "path", "colour": "#5a5c66"}                          # concrete passage
    z.legend["g"] = {"tile": "tall_grass", "colour": "#6c6f66", "prop": "none"}    # litter and rubble: encounters
    z.legend["v"] = {"tile": "floor_tile", "colour": "#c9c3a8"}                    # old cream tile
    # entrance hall with ticket barriers
    z.rect(42, 42, 14, 6, "+")
    z.rect(42, 44, 14, 1, "C")
    for gx in (45, 48, 51):
        z.set(gx, 44, "+")
    z.set(48, 48, "D")
    z.warp(48, 48, "london", 24, 26, "down")
    z.rect(47, 38, 2, 4, "k")
    # platform 1 (Central): north platform, tracks, south platform, cross-over at the east end
    z.rect(30, 32, 31, 2, "_"); z.rect(30, 36, 31, 2, "_")
    z.rect(61, 32, 2, 6, "k")
    z.rect(24, 34, 37, 2, "!")
    # corridors west, a litter room south, the long way up
    z.rect(14, 32, 16, 2, "k")
    z.rect(14, 20, 1, 12, "k")
    z.rect(18, 34, 2, 10, "k"); z.rect(6, 42, 26, 8, "k")
    # platform 2 (Northern)
    z.rect(9, 14, 32, 2, "_"); z.rect(9, 18, 32, 2, "_")
    z.rect(11, 16, 34, 2, "!")
    z.rect(5, 14, 4, 6, "k")
    # up to the lift lobby
    z.rect(24, 6, 1, 8, "k")
    z.rect(17, 2, 16, 4, "+")
    z.set(25, 1, "D")
    # the disused station
    z.rect(41, 14, 6, 2, "k")
    z.rect(47, 8, 13, 14, "k")
    z.rect(53, 18, 6, 4, "v")
    for (x, y, w, h) in [(8, 44, 8, 5), (22, 44, 8, 4), (49, 12, 8, 6), (50, 9, 6, 2), (47, 19, 5, 3)]:
        z.rect(x, y, w, h, "g")
    # trains
    for tx in (36, 37, 38, 39):
        z.prop("canal_boat", tx, 34, variant=0)
    for tx in (46, 47, 48, 49, 50):
        z.prop("canal_boat", tx, 35, variant=1)
    for tx in (20, 21, 22, 23):
        z.prop("canal_boat", tx, 16, variant=2)
    for tx in (30, 31, 32, 33, 34):
        z.prop("canal_boat", tx, 17, variant=0)
    for (x, y) in [(33, 32), (45, 32), (55, 37), (33, 37), (15, 14), (28, 19), (38, 18), (12, 19)]:
        z.prop("lamp_post", x, y)
    for (x, y) in [(40, 33), (52, 36), (26, 18), (31, 15)]:
        z.prop("bench", x, y)
    for (x, y) in [(44, 43), (53, 43), (18, 3), (31, 3)]:
        z.prop("potted_plant", x, y)
    for (x, y) in [(16, 33), (52, 14), (50, 20)]:
        z.prop("bollard", x, y)
    z.sign(47, 43, "MIND THE GAP. The phrase was first recorded in 1969, between a train and a platform on the Northern line. The voice you hear at one station belongs to an actor whose widow still visits to hear it. A very London love story.")
    z.sign(44, 36, "CENTRAL LINE. Opened 1900 as the 'Twopenny Tube', because every ride cost twopence. Today you can't buy a Tube sandwich for twopence, or twopence for a Tube sandwich.")
    z.sign(36, 32, "THE DEEP TUNNELS. The London Underground runs for 250 miles, and some of it is much deeper than it looks. Down here is less 'sky' and more 'maze'.")
    z.sign(19, 14, "NORTHERN LINE. The deepest station in the system is Hampstead, 58.5 metres down. Its lift ride is a good chance to look at your shoes.")
    z.sign(55, 11, "DISUSED STATION. London has about 40 ghost stations, closed for decades and left like time capsules. Their old posters still advertise toothpaste, Bovril, and a variety show of 1938.")
    z.sign(20, 5, "TO THE VANE TOWER. Staff only. Persons without a lanyard will be asked to take a seat. There are no seats. This is the Enclosure's idea of a joke.")
    z.warp(25, 1, "vane_tower_lobby", 2, 12, "right")
    # blockers (placeholder story NPCs)
    _stand(z, 14, 24)
    z.npc(id="reunion_a", sprite="pryce", x=14, y=24, facing="down", move="still", script="reunion_a")
    _stand(z, 24, 8)
    z.npc(id="reunion_b", sprite="kerrigan", x=24, y=8, facing="down", move="still", script="reunion_b")
    script("underground", "reunion_a", say("Pryce", "(placeholder) Directors Pryce and Ashcombe, half-heartedly blocking a tunnel."))
    script("underground", "reunion_b", say("Kerrigan", "(placeholder) Directors Kerrigan and Strachan, half-heartedly blocking a tunnel."))
    chat(z, "ug_station_guard", "rail_guard", 48, 40, "Station Supervisor",
         ["Please keep behind the yellow line. Please keep behind the yellow line. Please keep behind... oh. Hello. You're in the wrong tunnel. Everyone is.",
          "There are 272 stations on the Tube. Some people try to visit them all in a day. It's called the Tube Challenge, and it's one of those things that sounds bad but is secretly delightful."], "left", "still")
    chat(z, "ug_cleaner", "villager_3", 32, 33, "Night Cleaner",
         ["The mice here are famous. They ride the escalators. I've seen one with a ticket. Clearly an annual pass.",
          "Rumour is something big lives in the old tunnels. Every time I look, it's just a mole in a hi-vis jacket. I'm choosing to believe it's a mole."], "down", "wander")
    trainer(z, "ug_commuter", "Commuter Delphine", "Commuter", "villager_2",
            [("tubemole", 94), ("shuttlecog", 94), ("raidtail", 95)], 54, 33, "left",
            ["Eight-forty-five. I am NOT missing this one. You and your team are in the doorway. Excuse me. Battle excuse me."],
            "Doors closing! Oh, I'm too late.", "I use the Tube every day. I know every platform draught. I know where you stand to get a seat. I won't tell.", 3600)
    trainer(z, "ug_warden_a", "Warden Pemberton", "Warden", "warden_grunt",
            [("samsonian", 95), ("tubemole", 95), ("steelheart", 95)], 56, 37, "left",
            ["Welcome to the Enclosure Underground Heritage Experience. All tickets are for the one-way experience. Please queue here, quietly, forever."],
            "I did not train for this. I trained for clipboards.", "You'll need a lanyard to go further. Just kidding. We lost the key in 1998.", 3650)
    trainer(z, "ug_busker", "Busker Tamsin", "Busker", "harpist",
            [("squawkster", 95), ("railspark", 95), ("murmurant", 96)], 28, 19, "left",
            ["The acoustics down here are incredible. I can hear the echo of a thousand commuters. Mind the guitar, mind the case, mind the busking licence."],
            "Wow. You've got great timing. Better than the Northern line.", "Official Tube buskers have a licence and a pitch. Mine's the best one. It has a draught.", 3600)
    trainer(z, "ug_warden_b", "Warden Hargreave", "Warden", "warden_grunt",
            [("quarrion", 96), ("stagmajor", 95), ("stoopfalcon", 96)], 14, 29, "down",
            ["Nobody is to go north of this junction without authorisation. I am the authorisation. I have a badge."],
            "The badge fell off. That's embarrassing.", "Lord Vane's tower stands right above this tunnel. I try not to think about it. It's a lot of glass.", 3700)
    trainer(z, "ug_archaeologist", "Archaeologist Dr Bellamy", "Archaeologist", "student",
            [("tunneller", 95), ("tubemole", 96), ("sarsenite", 95)], 24, 11, "down",
            ["London is built on layers: Roman, medieval, Victorian, and now this lot. I dig for a living. A tunnel is basically a very long dig with a train in it."],
            "Fascinating! You've just uncovered a new level of my disappointment.", "They found a Roman amphitheatre under the Guildhall. Roman Londinium is all down there. They had good drainage, too.", 3700)
    z.d["spawn"] = [48, 46]
    wild(z, [("tubemole", 94, 96, 18, {}), ("moldiwarp", 94, 95, 8, {}), ("tunneller", 95, 96, 8, {}), ("flittermouse", 94, 95, 12, {}), ("hushwing", 94, 96, 8, {"time": ["night"]}),
             ("railspark", 94, 95, 10, {}), ("rivetling", 94, 95, 8, {}), ("shuttlecog", 94, 96, 8, {}), ("binfox", 94, 95, 10, {}), ("raidtail", 94, 95, 10, {}),
             ("sootwing", 94, 95, 8, {}), ("squawkster", 94, 95, 4, {})])
    z.save(OUT + "/underground.json")


# ======================================================================= the Vane Tower
def tower_base(zid, name, music):
    z = Z(zid, name, 30, 24, fill="+", kind="interior", region="", music=music, weather={})
    z.d["stage"] = "city"
    z.legend["g"] = {"tile": "floor_tile", "colour": "#a9d2ea"}                  # glass floor
    z.legend["v"] = {"tile": "floor_tile", "colour": "#34465a"}                  # corporate navy carpet
    z.legend["m"] = {"tile": "floor_tile", "colour": "#e6e2d6"}                  # marble
    z.border("x", 2)
    return z


def tower():
    # ---- lobby
    z = tower_base("vane_tower_lobby", "Vane Tower: Lobby", "town_london")
    z.rect(2, 2, 26, 20, "m")
    z.rect(10, 4, 11, 7, "g")
    z.rect(4, 12, 4, 8, "v"); z.rect(22, 12, 4, 8, "v")
    z.rect(11, 15, 3, 1, "C"); z.rect(16, 15, 3, 1, "C")        # reception desk with a gap
    z.rect(5, 4, 1, 6, "x"); z.rect(24, 4, 1, 6, "x")
    z.set(8, 8, "x"); z.set(21, 8, "x")
    z.set(15, 22, "D"); z.warp(15, 22, "london", 37, 20, "down")
    z.set(24, 1, "D"); z.warp(24, 1, "vane_tower_mid", 3, 21, "up")
    z.set(1, 12, "D"); z.warp(1, 12, "underground", 25, 3, "down")
    for (x, y) in [(3, 3), (26, 3), (3, 20), (26, 20), (9, 12), (20, 12), (9, 18), (20, 18)]:
        z.prop("potted_plant", x, y)
    z.prop("bookshelf", 13, 3); z.prop("bookshelf", 17, 3); z.prop("table", 6, 14); z.prop("table", 24, 14)
    z.sign(2, 14, "STAFF ONLY: UNDERGROUND LINK. A discreet door, down to the Enclosure's tunnels. Lanyards are not checked. This is the weak point of the security.")
    z.sign(23, 3, "LIFT TO FLOORS 2 TO 40. The lift has a 40-floor button and an extremely smug chime. Floor 40 is Lord Vane's. It has a view.")
    chat(z, "vt_receptionist", "shopkeeper", 15, 14, "Receptionist",
         ["Welcome to the Vane Tower. Do you have an appointment? Do you have a lanyard? Do you have the right sort of shoes?",
          "The Enclosure's mission is to curate the countryside for everyone. To be fair, nobody asked for it. It's very efficient."], "down", "still")
    trainer(z, "vt_warden_1", "Warden Prentice", "Warden", "warden_grunt",
            [("samsonian", 96), ("steelheart", 96), ("tubemole", 95)], 15, 8, "down",
            ["Reception is closed to the public. The lobby is, however, open to the public. This is a contradiction I have been told not to resolve."],
            "I'll have to ring facilities. And then HR.", "The lift is on your right. I did not say that.", 3800)
    trainer(z, "vt_warden_2", "Warden Lockhart", "Warden", "warden_grunt",
            [("quarrion", 96), ("stoopfalcon", 96), ("stagmajor", 96)], 23, 18, "left",
            ["The corridors are one-way. You are going the wrong way. This is the sort of thing I enjoy."],
            "I've been bested by a child. I'll file it under 'weather'.", "Rumour is Lord Vane hasn't left the top floor in a month. He has his lunch brought up. By a Warden.", 3850)
    z.d["spawn"] = [15, 21]
    z.save(OUT + "/vane_tower_lobby.json")
    # ---- mid
    z = tower_base("vane_tower_mid", "Vane Tower: Offices", "dungeon_underground")
    z.rect(2, 2, 26, 20, "v")
    z.rect(2, 10, 26, 3, "g")
    for y in (5, 16):
        for x0 in (5, 12, 19):
            z.rect(x0, y, 4, 1, "C")
    z.rect(14, 2, 2, 8, "x"); z.rect(14, 14, 2, 8, "x")
    z.set(24, 1, "D"); z.warp(24, 1, "vane_tower_top", 3, 21, "up")
    z.set(3, 22, "D"); z.warp(3, 22, "vane_tower_lobby", 24, 2, "down")
    for (x, y) in [(3, 3), (11, 3), (26, 3), (3, 20), (26, 20), (11, 20), (17, 11)]:
        z.prop("potted_plant", x, y)
    for (x, y) in [(5, 7), (20, 7), (5, 18), (20, 18)]:
        z.prop("table", x, y)
    z.prop("bookshelf", 8, 3); z.prop("bookshelf", 19, 3); z.prop("bookshelf", 8, 20)
    z.sign(4, 11, "THE OPEN-PLAN OFFICE. 'Open-plan' means everyone can hear everything. Nobody has said anything interesting in this room since 2014.")
    z.sign(23, 3, "TO THE EXECUTIVE FLOOR. Lord Vane's office. If you are going up, please wipe your feet on the carpet. It is the carpet of a man who minds.")
    chat(z, "vt_intern", "student", 4, 8, "Intern",
         ["I've been in this building for six weeks. I've never seen the sun. They told me the glass was 'so the countryside could see in'. It's a 'vision'.",
          "My job is to move a stapler from one desk to another. Then move it back. I think the stapler is the real intern."], "right", "still")
    trainer(z, "vt_warden_3", "Warden Ashcombe-Reid", "Warden", "warden_grunt",
            [("samsonian", 97), ("steelheart", 96), ("stagmajor", 96)], 8, 12, "right",
            ["Hold it! This floor is the 'Curation Department'. We curate the nation. It is a lot of paper."],
            "I'll have to redo the minutes.", "We have four directors. Two used to be good. Two are Pryce and Kerrigan.", 3900)
    trainer(z, "vt_warden_4", "Warden Cathcart", "Warden", "warden_grunt",
            [("quarrion", 97), ("stoopfalcon", 96), ("tubemole", 96)], 23, 11, "left",
            ["Per my last email, you are not allowed on this floor. I did not send the email, but I am sure it exists."],
            "Right. I'll bin the email.", "Go on up. I won't tell. I never saw you. I'm on a break.", 3950)
    z.d["spawn"] = [3, 21]
    z.save(OUT + "/vane_tower_mid.json")
    # ---- top
    z = tower_base("vane_tower_top", "Vane Tower: Summit", "battle_final")
    z.rect(2, 2, 26, 20, "g")
    z.rect(2, 2, 26, 2, "v")
    z.rect(8, 6, 14, 14, "m")
    z.rect(13, 6, 4, 14, "v")
    z.rect(9, 6, 5, 1, "C"); z.rect(16, 6, 6, 1, "C")
    z.set(3, 22, "D"); z.warp(3, 22, "vane_tower_mid", 24, 2, "down")
    for (x, y) in [(3, 5), (26, 5), (26, 20), (9, 19), (21, 19), (9, 10), (21, 10)]:
        z.prop("potted_plant", x, y)
    z.prop("bookshelf", 6, 3); z.prop("bookshelf", 22, 3)
    z.sign(4, 19, "THE SUMMIT. A glass floor with the whole of London beneath it. Lord Vane likes to look down. Nothing about this seems healthy.")
    _stand(z, 15, 5)
    z.npc(id="vane", sprite="vane", x=15, y=5, facing="down", move="still", script="vane_final")
    script("vane_tower_top", "vane_final", say("Lord Vane", "(placeholder) The final battle with Lord Vane."))
    trainer(z, "vt_warden_5", "Warden Brightwell", "Warden", "warden_grunt",
            [("samsonian", 97), ("steelheart", 97), ("stoopfalcon", 97), ("quarrion", 97)], 15, 14, "down",
            ["Last line of defence! Between you and the Chairman there's me. And a very short carpet."],
            "Right. That's my pension.", "He's in a mood today. Mind the coat. It's a good coat.", 4200)
    trainer(z, "vt_warden_6", "Warden Delamere", "Warden", "warden_grunt",
            [("tubemole", 96), ("stagmajor", 97), ("shuttlecog", 97)], 11, 17, "right",
            ["The summit is closed for important thinking. Please stay in the queue. There is no queue. Stay in it."],
            "I'll stand here quietly and rethink my career.", "The view is good, but the views are worse.", 4150)
    z.d["spawn"] = [3, 21]
    z.save(OUT + "/vane_tower_top.json")


if __name__ == "__main__":
    nottingham_stub()
    birmingham()
    salisbury()
    stonehenge()
    london()
    underground()
    tower()
    write_all(OUT)
