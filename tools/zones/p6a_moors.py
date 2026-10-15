# plan 6 group A, part 2: penshaw (the Lambton Worm's hill) and north_york_moors (heather, the steam railway, standing stones).
from p6a_common import *
from wcommon import _stand


def build(OUT):
    penshaw(OUT)
    moors(OUT)


def penshaw(OUT):
    W, H = 44, 36
    zid = "penshaw"
    z = Z(zid, "Penshaw Hill", W, H, kind="route", region=NE, music="route_moor",
          weather={"clear": 26, "sunshine": 14, "drizzle": 22, "fog": 18, "gale": 12, "downpour": 8})
    z.d["stage"] = "grass"
    z.legend["g"] = {"tile": "grass", "colour": "#76934f"}
    z.rect(0, 0, W, H, "g")
    z.border("T", 2, gaps=[(42, 20, 2, 3)])
    z.scatter(0, 0, W, H, "P", 14, 51, only="T")
    hills(z, [(21, 14, 5, 15)])
    z.height(14, 9, 14, 6, 4)
    smooth(z)
    # the road in from the east, then a track that winds up the hill
    z.rect(34, 20, 10, 3, "#")
    z.rect(19, 20, 18, 3, "#")
    z.rect(19, 17, 3, 6, "#")
    z.rect(11, 17, 11, 3, "#")
    z.rect(11, 14, 3, 6, "#")
    z.rect(11, 14, 12, 1, "#")
    z.rect(21, 12, 3, 3, "#")
    z.rect(22, 9, 1, 4, "#")
    # Penshaw Monument: a half-size Greek temple, built 1844 for the Earl of Durham
    z.rect(14, 5, 14, 4, "g")
    z.building(16, 5, 11, 3, "aqueduct", "Penshaw Monument")
    z.rect(16, 8, 11, 1, ":")
    z.prop("lamp_post", 15, 9); z.prop("lamp_post", 27, 9); z.prop("bench", 19, 9); z.prop("bench", 24, 9)
    # the Worm's coils: a ring of boulders round the hill, and the old well
    for (x, y) in [(12, 19), (13, 22), (15, 25), (20, 26), (26, 26), (31, 24), (33, 17), (31, 12), (9, 15), (9, 20)]:
        z.prop("rock", x, y, variant=(x + y) % 3)
    z.prop("planter", 29, 20); z.prop("planter", 29, 22)
    z.rect(30, 17, 2, 2, "R")
    # tall grass for wild encounters on the slopes
    for (cx, cy, rx, ry, sd) in [(8, 10, 5, 3, 1), (32, 8, 5, 3, 2), (10, 28, 6, 3, 3), (30, 29, 7, 3, 4), (24, 31, 4, 2, 5)]:
        blob(z, cx, cy, rx, ry, ",", only="g", seed=sd, jitter=0.4)
    scatter_props(z, "oak", 3, 3, 38, 30, 9, 52, avoid=("g",))
    scatter_props(z, "bush", 3, 3, 38, 30, 9, 53, avoid=("g",))
    z.sign(23, 20, "PENSHAW MONUMENT. Built in 1844 in honour of John Lambton, first Earl of Durham, and modelled on the Temple of Hephaestus in Athens, though 'Greek' temples do not generally sit on a Wearside hill. It has 18 columns, 70 feet high. It was meant to have a roof. It has been a pleasingly unfinished temple ever since.")
    z.sign(20, 9, "WORM HILL. Local tradition says the Lambton Worm coiled round this hill seven times and ate sheep, milk and the odd cow. The knight John Lambton killed it, in armour studded with blades, and then there was the small matter of a vow about his father. The song 'The Lambton Worm' is still sung in Sunderland pubs, with feeling.")
    # the legend: Lambton Worm's spot (the story agent rewrites the script)
    _stand(z, 22, 12)
    z.npc(id="lambton_spot", sprite="creature:lambton", x=22, y=12, facing="down", move="still", script="lambton", hide_if="caught_lambton")
    script(zid, "lambton", say("Lambton Worm", "Placeholder: the story agent rewrites this legend script."))
    # NPCs
    chat(z, "pen_singer", "villager_1", 26, 21, "Pub Singer",
         ["Whisht, lads, haad yer gobs, and Aa'll tell ye all an aaful story! That's how the Lambton Worm song starts. It means: be quiet, and listen.",
          "John Lambton goes fishing on a Sunday, catches a weird little worm, tosses it down a well, and then goes off to the Crusades. This is the story's idea of a plan."], "left", "still")
    chat(z, "pen_walker", "hiker", 14, 22, "Dog Walker",
         ["You can see the monument for miles. On a clear day you see the sea from the top, and on a foggy day you see the inside of your own hat.",
          "Sundays here are busy. Everyone brings a dog. The dogs bring one another."], "down", "wander")
    chat(z, "pen_kid", "villager_6", 30, 14, "Local Kid",
         ["Seven coils round the hill! And then Sir John cut it in pieces and the bits could not join up. That's the clever part.",
          "I counted the hill's terraces once and got seven. Mum says it's bracken. She is wrong."], "left", "wander")
    chat(z, "pen_volunteer", "tour_guide", 20, 10, "Monument Volunteer",
         ["It was meant to be roofed. Nobody had the money, and the roof was dropped, and the columns have stood in the weather since 1844.",
          "I like it better like this. A temple with the sky for a roof can't leak."], "down", "still")
    trainer(z, "pen_historian", "Historian Dr Raine", "Historian", "poet",
            [("jetwhitby", 81), ("peatmonarch", 81), ("centurion", 81)], 17, 18, "right",
            ["A worm, a knight, a vow, and a family curse that lasted nine generations. A very full legend, with excellent pacing. Let's see yours."],
            "Fine. I shall record your battle in verse, with extra worms.", "The curse said no Lambton would die in his bed for nine generations. They say it worked. They also say nobody checked.", 3340)
    wild(z, [("thistlet", 81, 81, 12, {}), ("bufomire", 81, 81, 10, {"weather": ["drizzle", "downpour"]}), ("sphagnet", 81, 81, 10, {}),
             ("croakle", 81, 81, 10, {"weather": ["drizzle", "downpour"]}), ("kitelet", 81, 81, 8, {"time": ["day"]}), ("brockling", 81, 81, 10, {"time": ["dusk", "night"]}),
             ("rooklet", 81, 81, 8, {}), ("leveret", 81, 81, 8, {}), ("stoatlet", 81, 81, 6, {}), ("peregrin", 81, 81, 6, {"time": ["day"]})])
    z.d["edges"] = {"east": {"to": "newcastle", "offset": 0}}
    z.d["spawn"] = [40, 21]
    done(z)
    z.save(OUT + "/" + zid + ".json")


def moors(OUT):
    W, H = 80, 60
    zid = "north_york_moors"
    z = Z(zid, "North York Moors", W, H, kind="route", region=YK, music="route_moor",
          weather={"fog": 24, "drizzle": 24, "clear": 18, "gale": 12, "sunshine": 12, "downpour": 6, "frost": 4})
    z.d["stage"] = "moor"
    z.legend["h"] = {"tile": "tall_grass", "colour": "#6e5a5c", "prop": "heather"}
    z.legend["m"] = {"tile": "grass", "colour": "#7d7a45"}
    z.legend["k"] = {"tile": "tall_grass", "colour": "#7a7444", "prop": "none"}
    z.rect(0, 0, W, H, "m")
    z.border("T", 2, gaps=[(52, 0, 3, 2), (78, 30, 2, 3)])
    z.scatter(0, 0, W, H, "P", 24, 61, only="T")
    hills(z, [(18, 14, 3, 14), (66, 12, 3, 14), (14, 48, 2, 12), (70, 48, 3, 14), (36, 20, 2, 10)])
    # Hole of Horcum: a great bowl
    for y in range(H):
        for x in range(W):
            d = ((x - 36) / 9.0) ** 2 + ((y - 18) / 6.0) ** 2
            if d < 1:
                z.hg[y][x] = max(0, z.hg[y][x] - 2)
    smooth(z)
    # heather and rough grass
    for (cx, cy, rx, ry, sd) in [(12, 8, 8, 4, 1), (30, 8, 7, 3, 2), (60, 6, 8, 3, 3), (72, 20, 6, 4, 4), (8, 26, 6, 4, 5),
                                 (28, 30, 8, 4, 6), (46, 22, 6, 3, 7), (64, 36, 8, 4, 8), (10, 54, 8, 3, 9), (30, 56, 6, 2, 10),
                                 (66, 54, 8, 3, 11), (42, 8, 5, 3, 12), (22, 44, 6, 3, 13)]:
        blob(z, cx, cy, rx, ry, "h", only="m", seed=sd, jitter=0.5)
    for (cx, cy, rx, ry, sd) in [(40, 36, 6, 3, 21), (58, 24, 5, 3, 22), (18, 36, 4, 3, 23)]:
        blob(z, cx, cy, rx, ry, "k", only="m", seed=sd, jitter=0.4)
    # the moor road: down from Newcastle, east to Whitby, a spur south to the stones
    z.rect(52, 2, 3, 31, "#")
    z.rect(52, 30, 28, 3, "#")
    z.rect(52, 33, 3, 24, "#")
    z.rect(40, 47, 14, 3, "#")
    # the beck
    z.rect(4, 22, 40, 1, "w"); z.rect(44, 21, 8, 2, "w")
    z.rect(20, 22, 4, 1, "o")
    # the steam railway: a line across the moor with a level crossing for the road
    z.rect(3, 40, 74, 1, "!")
    z.rect(52, 40, 3, 1, "#")
    z.prop("lamp_post", 51, 39); z.prop("lamp_post", 55, 41)
    z.building(26, 37, 7, 2, "station", "Goathland Halt", door=3)
    z.rect(26, 39, 7, 1, "_")
    z.rect(25, 39, 1, 1, "#"); z.rect(33, 39, 1, 1, "#")
    z.rect(34, 36, 18, 4, "m"); z.rect(34, 39, 18, 1, "#"); z.rect(33, 39, 1, 1, "#")
    z.prop("bench", 28, 41); z.prop("bench", 31, 39); z.prop("planter", 25, 36)
    z.building(40, 36, 4, 2, "slate_cottage", "Signal Box")
    z.sign(46, 39, "NORTH YORK MOORS RAILWAY. Eighteen miles from Pickering to Whitby, opened in 1836, shut by the Beeching cuts in 1965 and brought back to life by volunteers who clearly enjoy being sooty. The line has appeared in dramas and in a film about a school for wizards, whose station was this one, painted for the camera.")
    z.sign(53, 36, "LEVEL CROSSING. Look both ways. Then look both ways again. Then, if you hear a whistle, look at the sky, because the steam train has a plume that you will see first.")
    # standing stones on the southern spur
    cx, cy = 35, 48
    for (dx, dy) in [(-4, -2), (-4, 2), (-2, -4), (2, -4), (-2, 4), (2, 4), (4, -2), (4, 2)]:
        z.prop("standing_stone", cx + dx, cy + dy, variant=(dx + dy) % 3)
    z.prop("standing_stone", cx, cy, variant=2)
    z.sign(cx, cy + 6, "THE STONES. A ring of weathered stones on the moor top, put there by people who never wrote down why. The moors have more burial mounds and cairns than almost anywhere in England, with views from every one. You may sit, and listen to the wind do its stone-flavoured whistling.")
    z.prop("bench", 49, 46)
    # farms and a pub
    z.building(8, 30, 6, 3, "slate_cottage", "Moor Farm"); z.building(66, 22, 6, 3, "slate_cottage", "Rosedale Farm")
    z.building(60, 48, 9, 3, "stone", "The Moorcock Inn")
    z.rect(56, 49, 4, 1, "#"); z.rect(55, 49, 1, 1, "#")
    z.prop("bench", 64, 51); z.prop("lamp_post", 62, 51)
    for (x, y, w, h) in [(4, 4, 1, 10), (4, 14, 10, 1), (60, 14, 14, 1), (74, 14, 1, 10), (16, 44, 14, 1), (16, 50, 14, 1)]:
        z.rect(x, y, w, h, "W")
    z.sign(36, 24, "THE HOLE OF HORCUM. A bowl in the moor a mile across and four hundred feet deep. The legend says a giant called Wade scooped up a handful of earth to throw at his wife, and the handful became Blakey Topping across the way. It is a very unfair legend about Mrs Wade, who by every account had a good arm.")
    scatter_props(z, "rock", 3, 3, 74, 54, 24, 62, avoid=("m", "h"))
    scatter_props(z, "pine", 3, 3, 74, 54, 12, 63, avoid=("m",))
    scatter_props(z, "bush", 3, 3, 74, 54, 12, 64, avoid=("m",))
    # NPCs
    chat(z, "moor_stationmaster", "rail_guard", 30, 39, "Halt Master",
         ["Welcome to the halt. The line runs from Pickering to Whitby: steam, brass, polish, and a whistle that makes everybody on the platform turn their head.",
          "It's run by volunteers. The best job is the fireman's. The second best is the fireman's tea."], "down", "still")
    chat(z, "moor_shepherd", "farmer", 12, 34, "Hill Farmer",
         ["Swaledale and Blackface, tough as old boots. They're grazing the heather, which keeps it low and flowering. In August the whole moor goes purple.",
          "You'll notice the heather smell. It's honey and rain. Bees come from miles about, and so do the tourists with cameras."], "right", "still")
    chat(z, "moor_walker", "hiker", 56, 12, "Cleveland Way Walker",
         ["The Cleveland Way is a hundred and nine miles, horseshoe-shaped, from Helmsley to Filey. Moors, then coast. The best of both.",
          "Mind the grouse. They go off from the heather like small, angry fireworks. 'Go-back, go-back,' they say. They mean it."], "down", "wander")
    chat(z, "moor_cook", "shopkeeper", 63, 47, "Inn Cook",
         ["Yorkshire puddings the size of a bin lid, with the gravy poured in. If the gravy does not reach the edges, I start again.",
          "A Yorkshire pudding should rise like a rumour. The secret is the hot fat, the cold batter, and keeping the oven door shut. We don't let the guests in either."], "down", "still")
    chat(z, "moor_sheep", "farmer", 45, 6, "Sheep Counter",
         ["I counted the sheep, and there were four hundred and one. I've counted them again. Four hundred and one. It's one more than I started with, and that is, I think, how the sheep like it.",
          "Always count from the dog end."], "left", "wander")
    # trainers
    trainer(z, "nym_runner", "Fell Runner Imogen", "Fell Runner", "jogger",
            [("ptarmigan", 81), ("heilan", 81), ("highlynx", 82)], 50, 14, "right",
            ["The Lyke Wake Walk: forty miles across the moor in a single day. Only the brave, the foolish and the very well-organised."],
            "That's a proper pace. I yield, and I stagger.", "They call it 'the Lyke Wake' after an old funeral dirge. A walk across the whole moor in a day. Take a flask.", 3340)
    trainer(z, "nym_birder", "Birdwatcher Colin", "Birdwatcher", "birdwatcher",
            [("goldeneyrie", 82), ("capercaillie", 82), ("stoopfalcon", 82)], 56, 28, "left",
            ["Merlin. Golden plover. Red grouse. If you hear a cough in the heather, that is a grouse, and it is annoyed."],
            "Ah, that was something. My notebook has smudged. Another time.", "The moors have one of the best breeding populations of merlin in England. They're tiny and quick. Unlike me.", 3360)
    trainer(z, "nym_ghost", "Ghost Walker Hilda", "Ghost Walker", "tour_guide",
            [("hushwing", 82), ("pinewraith", 82), ("legionette", 83)], 50, 36, "right",
            ["Legend says the Roman Ninth Legion marched into the mist near here and was never seen again. Some folk say they still march. I say that's a lovely story and a poor excuse for being late."],
            "Oh, you're spirited. I'll put you in the tour.", "The Ninth Legion is a mystery. The ghost tour is a business.", 3380)
    trainer(z, "nym_angler", "Angler Dennis", "Angler", "angler",
            [("heronarch", 82), ("levelcrane", 82), ("bradan", 82)], 18, 20, "down",
            ["The beck is good for brown trout. And for philosophy. Mostly the second."],
            "The one that got away was you. Congratulations.", "A trout will rise to a fly and ignore a worm. Every trout is a poet.", 3300)
    trainer(z, "nym_warden", "Warden Piers", "Warden", "warden_grunt",
            [("shuttlecog", 82), ("sootwing", 82), ("adderking", 83)], 40, 31, "down",
            ["The Enclosure thinks a purple moor is untidy. We're rolling out a nice, tasteful grey. I have a swatch."],
            "My swatch! You've spilled tea on my swatch!", "Heather is a protected habitat. Our boss does not care for protected. He prefers 'owned'.", 3320)
    wild(z, [("jetling", 81, 83, 16, {}), ("ptarmlet", 81, 83, 12, {"weather": ["fog", "frost", "gale"]}), ("thistlet", 81, 83, 10, {}),
             ("kitelet", 81, 83, 10, {"time": ["day"]}), ("brockling", 81, 83, 8, {"time": ["dusk", "night"]}), ("fawnlet", 81, 83, 10, {"time": ["dawn", "dusk"]}),
             ("zigzlet", 81, 83, 8, {"time": ["night"]}), ("stoatlet", 81, 83, 8, {}), ("hootlet", 81, 83, 6, {"time": ["night"]}),
             ("leveret", 81, 83, 8, {}), ("horselet", 81, 83, 6, {"time": ["night"]}), ("sphagnet", 81, 83, 8, {"weather": ["fog", "drizzle"]})])
    wild(z, [("stalklet", 81, 83, 20, {}), ("dipling", 81, 83, 20, {}), ("cranelet", 81, 83, 16, {}), ("parrlet", 81, 83, 14, {}),
             ("holtling", 81, 83, 14, {}), ("elverlet", 81, 83, 10, {"weather": ["drizzle", "downpour"]})], "water")
    z.d["edges"] = {"north": {"to": "newcastle", "offset": 0}, "east": {"to": "whitby", "offset": 0}}
    z.rect(52, 0, 3, 2, "#"); z.rect(78, 30, 2, 3, "#")
    z.d["spawn"] = [53, 4]
    done(z)
    z.save(OUT + "/" + zid + ".json")
