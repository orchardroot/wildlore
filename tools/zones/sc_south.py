# plan 5 group B, part 1: cairnryan (port town), galloway (forest park route) and galloway_dark (dark sky side area).
from sc_common import *


def build(OUT):
    cairnryan(OUT)
    galloway(OUT)
    galloway_dark(OUT)


def cairnryan(OUT):
    W, H = 48, 40
    z = Z("cairnryan", "Cairnryan", W, H, kind="town", region=SCOT, music="town_scotland", weather=WX_WEST)
    z.d["stage"] = "docks"; z.d["town_id"] = "cairnryan"
    z.border("T", 2, gaps=[(22, 0, 3, 2)])
    z.scatter(0, 0, W, H, "P", 40, 3, only="T")
    # Loch Ryan to the west: open water, a shallow fringe, a strip of shingle
    z.rect(0, 0, 14, H, "$"); z.rect(14, 0, 1, H, "w"); z.rect(15, 0, 3, H, "s")
    z.rect(14, 0, 8, 2, "T"); z.rect(14, H - 2, 8, 2, "T")
    # roads: the A77 comes down from the north, the shore road runs east
    z.rect(22, 0, 3, 19, "="); z.rect(18, 18, 28, 3, "=")
    z.rect(18, 21, 3, 1, ":")
    # the quay, running out into the loch
    z.rect(8, 19, 10, 3, ":")
    z.d["ferry"] = {"x": 9, "y": 20, "route": "belfast_cairnryan"}
    z.prop("boat", 5, 20, variant=0)
    for (x, y) in [(10, 19), (10, 21), (13, 19), (13, 21), (16, 19), (16, 21)]:
        z.prop("bollard", x, y)
    for (x, y, v) in [(4, 14, 1), (6, 27, 1), (7, 8, 1), (3, 33, 1)]:
        z.prop("boat", x, y, variant=v)
    for (x, y) in [(5, 12), (7, 29), (4, 24), (9, 36), (6, 4)]:
        z.prop("buoy", x, y)
    # breakwater and lighthouse
    z.rect(8, 31, 8, 2, ":"); z.prop("lighthouse", 8, 32)
    z.sign(15, 31, "THE BREAKWATER. Loch Ryan is a sea loch, sheltered enough that the ferries come in almost on tiptoe. The lighthouse on the end does not pretend it is needed on a clear night. It likes to be asked.")
    # Sanctuary, Corner Shop, station
    z.building(26, 14, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(29, 17, "cairnryan_sanctuary", 5, 6, "up")
    z.building(34, 14, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(36, 17, "cairnryan_shop", 4, 5, "up")
    station(z, 30, 3, 9, 4, "Cairnryan Station")
    z.rect(28, 3, 1, 11, "#")
    z.prop("bench", 32, 5); z.prop("lamp_post", 38, 5); z.prop("lamp_post", 30, 5)
    rail_guard(z, 36, 5, ["Cairnryan Station: a platform, a bench, a very confident seagull and the whole Scottish rail network.",
                          "Hop aboard! The Wildlore rail runs to any station in Great Britain you have visited. Where to?"], facing="left")
    # the ferry terminal and houses
    z.building(19, 23, 10, 4, "cream_render", "Ferry Terminal")
    z.rect(19, 27, 10, 1, ":"); z.rect(23, 21, 1, 2, ":")
    z.building(34, 23, 6, 4, "white_render", "The Ryan Arms")
    z.building(42, 14, 5, 4, "slate_cottage"); z.building(42, 23, 5, 4, "white_render")
    z.building(20, 30, 5, 4, "stone", "Harbour Office")
    z.rect(27, 21, 1, 1, "="); z.rect(36, 21, 3, 2, ":"); z.rect(22, 27, 3, 3, "#")
    z.rect(27, 28, 16, 1, "#"); z.rect(40, 21, 2, 8, "#"); z.rect(42, 21, 2, 1, "#")
    lamps(z, [(19, 17), (27, 17), (33, 17), (40, 17), (19, 21), (30, 21), (38, 21)])
    z.prop("planter", 28, 17); z.prop("planter", 33, 17); z.prop("bench", 25, 21)
    z.prop("post_box", 31, 21); z.prop("phone_box", 45, 21)
    z.rect(36, 30, 10, 8, ","); z.rect(40, 8, 6, 5, ","); z.rect(22, 34, 8, 5, ",")
    z.sign(23, 19, "FÀILTE GU ALBA / WELCOME TO SCOTLAND. Mind the lorries: this little village sees more trucks than a village of its size really ought to. The Gaelic means exactly what it says, which is a rare thing in signs.")
    z.sign(11, 18, "AISEAG GU BEUL FEIRSTE / FERRY TO BELFAST. About two and a quarter hours across the North Channel. The ship has a cafe, a lounge and a gift shop that sells nothing you need and everything you want.")
    z.sign(19, 22, "LOCH RYAN. A sea loch, and home to Scotland's last big wild native oyster bed. The oysters have been here since long before the ferries, and they have never once been late.")
    scatter_props(z, "oak", 36, 28, 10, 10, 6, 5, avoid=(",", "."))
    scatter_props(z, "bush", 18, 3, 8, 12, 5, 6, avoid=("."))
    # NPCs
    z.npc(id="cai_sailor", sprite="sailor", x=11, y=20, facing="left", move="still", script="sailor")
    script("cairnryan", "sailor", say("Sailor", "Belfast, is it? Beul Feirste, as we say here. The Stena Selkie is warm, dry and only slightly judgemental about your bag. Aboard you come.") + [{"do": "ferry", "route": "belfast_cairnryan"}])
    chat(z, "cai_lorry", "farmer", 26, 21, "Lorry Driver",
         ["Cairnryan is basically a lorry car park with a lovely view. Hundreds of ferry lorries roll through every day. The seagulls know the timetable better than I do.",
          "In the war this was a big military port, and a railway line ran in just to feed it. The line's long gone, but the road remembers."], "down", "wander")
    chat(z, "cai_oyster", "angler", 17, 24, "Oyster Man",
         ["The wild oysters in Loch Ryan were here before the ferries and they'll be here after. They're patient. I admire that in a shellfish.",
          "Fàilte, by the way. That means welcome. Say it with a bit of cheek and you'll sound local."], "right", "still")
    chat(z, "cai_wife", "villager_3", 38, 20, "Terminal Cafe Owner",
         ["We do a bacon roll the size of a hat. The ferry folk swear by it, and the seagulls swear at it, because they can't get in.",
          "Mòran taing, that's 'many thanks'. I say it forty times a day. It never gets old, and neither does the roll."], "down", "wander")
    chat(z, "cai_kid", "villager_6", 31, 31, "Wee Lass",
         ["I'm going to be a ferry captain. Or a seagull. Mum says I'd have to choose by Friday.",
          "Did you know Scotland has nearly eight hundred islands? My nana says some of them are just big rocks with ambition."], "down", "wander")
    trainer(z, "cai_angler", "Angler Murdo", "Angler", "angler", [("plungebeak", 67), ("heronarch", 67), ("greyhaul", 67)],
            15, 26, "up", ["Away and bother somebody else's fish! Oh, you're a Keeper. Well. Let's see what's biting."],
            "Cracking cast. I'll have to teach that line a new trick.", "I've been fishing off this beach for thirty years. I caught a boot in 1998 and I still think it was a good one.", 2250)
    z.d["edges"] = {"north": {"to": "galloway", "offset": 0}}
    z.d["spawn"] = [23, 17]
    wild(z, [("chipgull", 67, 68, 14, {"time": ["dawn", "day"]}), ("pierlord", 67, 68, 12, {"time": ["day", "dusk"]}),
             ("plungebeak", 67, 68, 10, {}), ("gannetling", 67, 68, 10, {"weather": ["gale", "drizzle"]}),
             ("ternlet", 67, 68, 8, {"time": ["dawn", "day"]}), ("baskling", 67, 68, 6, {}), ("binfox", 67, 68, 8, {"time": ["night", "dusk"]}),
             ("hushwing", 67, 68, 6, {"time": ["night"]})])
    wild(z, [("greyhaul", 67, 68, 20, {}), ("plungebeak", 67, 68, 20, {}), ("dolphlet", 67, 68, 15, {}), ("selklet", 67, 68, 12, {}),
             ("chipgull", 67, 68, 15, {}), ("baskling", 67, 68, 8, {})], "water")
    z.save(OUT + "/cairnryan.json")
    sanctuary(OUT, "cairnryan", "Cairnryan", (29, 18))
    shop(OUT, "cairnryan", "Cairnryan", (36, 18))
    nurse("cairnryan", ["Feasgar math, and welcome to Cairnryan Sanctuary. That's 'good afternoon'. You've come off the ferry, so let me guess: stiff legs, salty hair, team a bit queasy.",
                        "Sit down, I'll put the kettle on. The kettle is always on. It is a legal requirement in Scotland. I may have made that up.",
                        "All done. Taing for your patience, that's 'thanks' in Gaelic. Off you go, the road north is long and lovely.",
                        "The Ark terminal, in the corner. It's sheltered from the weather, and so am I.",
                        "Right you are. Beannachd leibh, that's 'blessings with you', or just 'cheerio'."])
    shopkeeper("cairnryan", "Hullo there! Fresh off the boat, are we? We have snares, tablet and a very good selection of things you forgot to pack.",
               "Mòran taing! Mind the seagulls on the way out, they've learned to unzip bags.")


def galloway(OUT):
    W, H = 48, 56
    z = Z("galloway", "Galloway Forest Park", W, H, kind="route", region=SCOT, music="route_forest", weather=WX_WEST)
    z.d["stage"] = "forest"
    z.border("T", 2, gaps=[(22, 0, 3, 2), (22, 54, 3, 2)])
    z.scatter(0, 0, W, H, "P", 60, 4, only="T")
    # the forest track, winding up from Cairnryan
    path(z, [(22, 55), (22, 46), (14, 46), (14, 34), (30, 34), (30, 20), (22, 20), (22, 0)], "#", 3)
    # Loch Trool, west
    z.rect(3, 5, 12, 22, "w"); z.rect(4, 6, 10, 20, "~"); z.rect(14, 5, 1, 22, "w")
    z.rect(14, 14, 8, 1, "#"); z.rect(14, 13, 1, 3, "s")
    z.prop("standing_stone", 15, 12)
    z.sign(16, 15, "BRUCE'S STONE. A great boulder above Loch Trool, set up to remember the spring of 1307, when Robert the Bruce's small band ambushed an English force in the glen with rocks rolled down the hillside. Gravity has fought on Scotland's side before.")
    # a second wee loch, south-east
    z.rect(33, 40, 12, 10, "w"); z.rect(34, 41, 10, 8, "~")
    z.sign(32, 44, "LOCHAN. A lochan is a small loch, and this one is about the size of a football pitch and as busy as the pitch on a Sunday.")
    # drystone walls, hill-farm style
    z.rect(3, 38, 10, 1, "W"); z.rect(3, 38, 1, 9, "W"); z.rect(3, 46, 9, 1, "W")
    # the deer meadow
    z.rect(33, 22, 13, 11, "f"); z.rect(34, 24, 5, 3, ","); z.rect(40, 28, 5, 3, ",")
    z.sign(33, 21, "RED DEER RANGE. Red deer are Britain's largest wild land animal. The stags grow a fresh set of antlers every year and drop the old ones in spring, which is a better trick than most of us manage with a gym membership.")
    # tall grass along the track
    for (x, y, w, h) in [(16, 38, 6, 6), (25, 40, 6, 5), (24, 24, 4, 8), (15, 22, 6, 7), (18, 2, 4, 8), (26, 3, 7, 8), (34, 14, 8, 6), (6, 30, 6, 5), (25, 49, 8, 5), (14, 50, 7, 4)]:
        z.rect(x, y, w, h, ",")
    # the visitor centre and the observatory spur
    z.building(26, 36, 8, 4, "stone", "Glen Trool Visitor Centre")
    z.rect(26, 40, 8, 1, ":")
    z.prop("bench", 27, 41); z.prop("bench", 32, 41); z.prop("lamp_post", 25, 41); z.prop("lamp_post", 34, 41)
    z.sign(30, 41, "GALLOWAY FOREST PARK. About three hundred square miles of forest, hill and loch, the biggest forest park in Britain. The tallest hill, the Merrick, is 843 m and the highest in the whole of southern Scotland. The deer don't charge for the view.")
    z.rect(25, 12, 15, 1, "#")
    z.building(36, 8, 6, 4, "white_render", "Dark Sky Observatory", door=3)
    z.warp(39, 11, "galloway_dark", 12, 16, "up")
    z.sign(34, 13, "GALLOWAY DARK SKY PARK. In 2009 this became the first Dark Sky Park in the UK, which means the streetlights stay away and the stars come out in their thousands. Look up. No, further up. There.")
    z.prop("bench", 36, 13); z.prop("lamp_post", 41, 13)
    scatter_props(z, "bush", 3, 3, 42, 50, 24, 9, avoid=("."))
    scatter_props(z, "rock", 3, 3, 42, 50, 14, 10, avoid=("."))
    z.scatter(0, 0, W, H, "P", 640, 11, only=".")
    z.scatter(0, 0, W, H, "T", 90, 12, only=".")
    # NPCs
    chat(z, "gal_ranger", "villager_2", 20, 47, "Forest Ranger",
         ["Galloway Forest Park is about three hundred square miles. I've walked a good chunk of it. The rest is walked by sheep, who do not file reports.",
          "If you hear a rustle in the spruce, it's probably a red squirrel, a roe deer or a very quiet hillwalker eating a sandwich."], "right", "still")
    chat(z, "gal_stargazer", "student", 38, 13, "Stargazer",
         ["Come back at night with no torch. I mean it. After twenty minutes your eyes switch on, and the Milky Way comes out like a spilled sack of sugar.",
          "Fun fact: this park is a Dark Sky Park, and the dark is protected on purpose. It's the only time anyone has been fined for being too bright."], "left", "still")
    chat(z, "gal_deerwatcher", "birdwatcher", 33, 24, "Deer Watcher",
         ["Shh! Oh, hello. The stags are moody this time of year. Keep your voice low and your elbows lower.",
          "There are wild goats in Galloway too, and they've lived on these hills for a very long time. They give a very particular look. A very goat look."], "right", "still")
    chat(z, "gal_forester", "farmer", 26, 35, "Forester",
         ["Most of the trees here are Sitka spruce, planted for timber in the last century. They grow like they're being timed.",
          "A good forest takes about forty years to grow and about forty minutes to walk through. The maths is on the trees' side."], "right", "still")
    creature_npc(z, "gal_stag", "stagmor", 37, 25, "The stag lifts his head, regards you with magnificent boredom, and goes back to grazing.")
    creature_npc(z, "gal_fawn_a", "fawnlet", 41, 29, "A fawnlet stares at you. It is considering whether you are a snack or a friend.")
    creature_npc(z, "gal_fawn_b", "fawnlet", 36, 30, "The fawnlet bounces, wobbles, and bounces again. Everything is a new idea.")
    trainer(z, "gal_hillwalker", "Hillwalker Morven", "Hillwalker", "hiker", [("stagmor", 67), ("pinewraith", 68), ("brockling", 67)],
            22, 50, "right", ["Munros I've bagged: forty-one. Wee hills I've sulked up: dozens. Care to sulk with me?"],
            "A fair walk, a fair fight. My knees concede.", "The Merrick is not a Munro, but it's a proper hill, and I'll hear nothing against it.", 2300)
    trainer(z, "gal_ghillie", "Ghillie Calum", "Ghillie", "ghillie", [("fawnlet", 67), ("stagmor", 68), ("martling", 68), ("hootlet", 67)],
            14, 40, "right", ["A ghillie looks after the hill and the people on it. Mostly the people. They get lost more than the deer."],
            "Well fought. That was the hill's idea, I'm sure.", "If the mist comes down, stand still and wait. The hill will wait with you.", 2350)
    trainer(z, "gal_angler", "Angler Fenella", "Angler", "angler", [("rillotter", 67), ("heronarch", 68), ("spatelord", 68)],
            16, 14, "right", ["Quiet! You'll frighten the trout. Oh, you're a Keeper. You'll frighten the trout anyway."],
            "Fair play. My line is tangled and so is my pride.", "I'm after a salmon. I've been after the same salmon for eleven years. He's winning.", 2300)
    trainer(z, "gal_warden", "Warden Hepburn", "Warden", "warden_grunt", [("thornsow", 68), ("adderking", 68), ("zigzlet", 67), ("bramblehog", 67)],
            30, 28, "right", ["This forest is being curated, I'll have you know. Trees in rows, deer in order, everything managed. I do the managing."],
            "Not in the spreadsheet! Not in the spreadsheet at all.", "I'll file a note. Under 'nature, unfortunate, ongoing'.", 2400)
    z.d["edges"] = {"south": {"to": "cairnryan", "offset": 0}, "north": {"to": "glasgow", "offset": 0}}
    z.d["spawn"] = [23, 52]
    wild(z, [("fawnlet", 67, 69, 14, {"time": ["dawn", "dusk", "day"]}), ("stagmor", 68, 69, 8, {"time": ["dawn", "dusk"]}),
             ("pinewraith", 67, 69, 10, {"time": ["dusk", "night"]}), ("martling", 67, 69, 10, {}), ("brockling", 67, 69, 10, {"time": ["night", "dusk"]}),
             ("thornsow", 67, 69, 8, {}), ("hootlet", 67, 69, 8, {"time": ["night"]}), ("flittermouse", 67, 69, 8, {"time": ["night"]}),
             ("sphagnet", 67, 69, 6, {"weather": ["drizzle", "downpour"]}), ("zigzlet", 67, 69, 6, {})])
    wild(z, [("rillotter", 67, 69, 20, {}), ("heronarch", 68, 69, 8, {}), ("dipling", 67, 69, 20, {}), ("bradan", 67, 69, 14, {"weather": ["drizzle", "downpour"]}),
             ("minkshade", 67, 69, 10, {"time": ["dusk", "night"]}), ("spatelord", 68, 69, 8, {})], "water")
    z.save(OUT + "/galloway.json")


def galloway_dark(OUT):
    W, H = 24, 20
    z = Z("galloway_dark", "Galloway Dark Sky Hill", W, H, kind="route", region=SCOT, music="route_highlands", weather={"clear": 100})
    z.d["stage"] = "moor"; z.d["dark"] = True
    z.border("T", 1)
    z.rect(1, 1, 22, 18, ".")
    z.rect(11, 12, 3, 6, "#"); z.rect(8, 8, 9, 5, "#")
    z.rect(9, 9, 7, 3, ".")
    # a ring of standing stones for the stargazers
    for (x, y) in [(9, 9), (15, 9), (9, 11), (15, 11), (12, 8)]:
        z.prop("standing_stone", x, y)
    z.rect(3, 3, 7, 4, ","); z.rect(15, 3, 6, 4, ","); z.rect(3, 13, 6, 4, ","); z.rect(16, 13, 5, 4, ",")
    z.prop("bench", 11, 10); z.prop("bench", 13, 10)
    z.sign(12, 13, "DARK SKY HILL. Please keep torches off, or dim and red. A red light keeps your night eyes working. This is a sign you can read by starlight, if you're quick.")
    z.warp(12, 18, "galloway", 39, 12, "down")
    z.rect(11, 18, 3, 1, "#")
    for (nid, sp, x, y, t) in [("dk_flit", "flittermouse", 6, 5, "The flittermouse swoops past your ear and apologises in ultrasound."),
                               ("dk_glow", "glowmite", 18, 5, "The glowmite blinks, a tiny green lamp the size of a thumbnail. It seems pleased to see another light on."),
                               ("dk_hoot", "hootlet", 5, 15, "The hootlet turns its head all the way round and then, to be polite, a bit further.")]:
        creature_npc(z, nid, sp, x, y, t)
    z.d["spawn"] = [12, 16]
    wild(z, [("hootlet", 68, 69, 20, {}), ("flittermouse", 67, 69, 20, {}), ("glowmite", 67, 69, 18, {}), ("hushwing", 68, 69, 12, {}),
             ("wildkit", 68, 69, 6, {}), ("lanternis", 69, 69, 4, {}), ("martling", 67, 68, 10, {}), ("pooka", 68, 69, 6, {})])
    z.save(OUT + "/galloway_dark.json")
