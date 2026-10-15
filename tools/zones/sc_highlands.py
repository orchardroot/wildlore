# plan 5 group B, part 4: glencoe (landmark route), fort_william (town), great_glen (route along the loch) and the loch_ness stub.
from sc_common import *


def build(OUT):
    glencoe(OUT)
    fort_william(OUT)
    great_glen(OUT)
    loch_ness_stub(OUT)


def peaks(z, tiles=((2, "^"), (1, "R"))):
    """turn every raised tile into rock: >=2 cliff, 1 rock (never touches paths, which are drawn afterwards)."""
    for y in range(z.h):
        for x in range(z.w):
            hv = z.hg[y][x]
            if hv >= 2:
                z.g[y][x] = "^"
            elif hv == 1:
                z.g[y][x] = "R"


def flatten(z, x, y, w, h, ch):
    for yy in range(y, y + h):
        for xx in range(x, x + w):
            z.hg[yy][xx] = 0
            z.g[yy][xx] = ch


def glencoe(OUT):
    W, H = 48, 64
    z = Z("glencoe", "Glencoe", W, H, kind="route", region=SCOT, music="route_highlands", weather=WX_HIGH)
    z.d["stage"] = "mountain"
    z.legend["h"] = {"tile": "tall_grass", "colour": "#6e5a5c", "prop": "heather"}
    z.border("T", 2, gaps=[(30, 62, 3, 2), (22, 0, 3, 2)])
    z.scatter(0, 0, W, H, "P", 60, 51, only="T")
    # the Three Sisters along the south side of the glen, and the long ridge opposite
    for cy in (12, 26, 40):
        mound(z, 39, cy, 7, 6, 6)
    mound(z, 3, 30, 10, 28, 6)
    peaks(z)
    # the loch and the River Coe
    z.rect(19, 19, 2, 31, "w")
    z.rect(15, 5, 7, 14, "w"); z.rect(16, 6, 5, 12, "~")
    # the track through the glen
    path(z, [(30, 63), (30, 48), (14, 48), (14, 32), (26, 32), (26, 20), (22, 20), (22, 0)], "#", 3)
    # scree side paths into two hidden hollows (Fell-scramble)
    z.rect(29, 33, 12, 1, "/"); flatten(z, 41, 32, 5, 3, "h")
    z.rect(25, 19, 16, 1, "/"); flatten(z, 41, 18, 5, 3, "h")
    z.sign(42, 33, "COIRE GABHAIL, the LOST VALLEY. A secret hollow between two of the Sisters. The MacDonalds are said to have hidden stolen cattle here, since you couldn't see it from the glen below. A hidden valley, a great hiding place and a very steep walk. You're in good company.")
    z.sign(42, 19, "A HIDDEN COIRE. The hill folk call a hollow like this a coire, 'a cauldron'. This one fills with mist at the drop of a hat, so tread softly. If you hear an eagle, say hello. If an eagle says hello, say it back.")
    # heather and bog cotton on the glen floor
    for (x, y, w, h) in [(30, 55, 6, 6), (17, 53, 9, 6), (4, 58, 8, 4), (17, 36, 8, 10), (29, 36, 3, 8), (28, 22, 3, 9), (23, 6, 4, 12), (24, 25, 2, 6), (29, 7, 3, 12), (14, 22, 6, 8)]:
        z.rect(x, y, w, h, "h")
    z.rect(30, 49, 2, 5, "h")
    # the memorial and signs
    z.prop("standing_stone", 32, 59)
    z.sign(32, 60, "GLENCOE MEMORIAL. In February 1692, soldiers who had been guests of the MacDonalds turned on them in the snow, and about thirty people died, many more fleeing into the hills. It's remembered here quietly. Walk gently, and stay a while.")
    z.sign(29, 44, "GLEANN COMHANN, GLENCOE. A glen made by ice, with sides so steep that the mist sits in the bowl like milk in a cup. Bidean nam Bian, at 1,150 m, is the highest hill in Argyll. The glen is a place to look up at.")
    z.sign(28, 30, "THE THREE SISTERS. Beinn Fhada, Gearr Aonach and Aonach Dubh: three great spurs of rock standing shoulder to shoulder. Walkers love them. Film crews love them. Bond came here, and so did a boy wizard, and neither of them could get a signal.")
    scatter_props(z, "rock", 3, 3, 42, 58, 14, 52, avoid=(".",))
    scatter_props(z, "bush", 3, 3, 42, 58, 14, 53, avoid=(".",))
    z.scatter(0, 0, W, H, "P", 140, 54, only=".")
    # NPCs
    z.npc(id="strachan", sprite="strachan", x=27, y=29, facing="left", move="still", script="strachan_glencoe")
    script("glencoe", "strachan_glencoe", say("Director Strachan", "Placeholder: the story agent writes Strachan's first mist battle in Glencoe here."))
    chat(z, "glc_walker", "hiker", 24, 14, "Munro Bagger",
         ["I've bagged a hundred and twelve Munros. A Munro's a Scottish hill over three thousand feet. There are two hundred and eighty-two. I've another hundred and seventy to go. And the weather's getting worse.",
          "If the mist comes down, stop and look at the map. Don't just keep walking and hope. Hope doesn't have an Ordnance Survey grid reference."], "right", "still")
    chat(z, "glc_photographer", "birdwatcher", 24, 56, "Eagle Watcher",
         ["Golden eagles nest on those crags. They're big: a wingspan of two metres. You'll hear them before you see them, or you'll see them and decide not to wave.",
          "Look for a big dark shape with 'fingers' on its wing tips. If it flaps like it's embarrassed, it's a buzzard."], "down", "still")
    chat(z, "glc_historian", "villager_4", 29, 50, "Local Historian",
         ["The glen's quiet because it's remembered. We tell the story gently, and honestly, and then we put the kettle on.",
          "The name Glencoe comes from Gleann Comhann, the glen of the River Coe. The river's a wee thing. The glen is the giant."], "left", "still")
    chat(z, "glc_cyclist", "jogger", 27, 12, "Fell Runner",
         ["I run these hills for fun. That is a lie. I run them because I forgot where the car was.",
          "Mind the scree. It's slippery stuff, little stones that slide. A Fell-scramble is the right way across it: slow, low, and with respect."], "down", "wander")
    trainer(z, "glc_hillwalker", "Hillwalker Ishbel", "Hillwalker", "hiker", [("kidgruff", 70), ("stagmor", 71), ("eaglet", 71)],
            14, 40, "right", ["There are two kinds of weather in Glencoe: mist, and about to be mist. Care for a tussle in it?"],
            "Marvellous. I'll never see the summit now. I can't see anything.", "Always pack a whistle, a map and a flask. I packed two flasks. One's for emergencies. The other's for tea.", 2900)
    trainer(z, "glc_piper", "Piper Alasdair", "Piper", "piper", [("murmurant", 71), ("wildkit", 71), ("eaglet", 72)],
            26, 23, "right", ["I play to the glen. The echo gives me a second opinion, and it's kinder than the critics."],
            "A grand dispute. The glen will hold that note a while.", "The pipes are not an instrument of war so much as an instrument of announcement. 'We are here, and we brought sandwiches.'", 2950)
    trainer(z, "glc_ghillie", "Ghillie Torquil", "Ghillie", "ghillie", [("stagmor", 71), ("fawnlet", 70), ("midgie", 70), ("martling", 71)],
            22, 11, "right", ["I look after the stalking on the estate. That's the deer and the guests. The deer are usually better behaved."],
            "Well fought. I'd offer you a dram, but you're driving a team.", "The midges are worst on a still, damp evening in summer. They don't bite. They just rudely assemble.", 2900)
    trainer(z, "glc_warden", "Warden Rattray", "Warden", "warden_grunt", [("thornsow", 71), ("adderking", 72), ("midgeswarm", 71)],
            20, 49, "right", ["I curate this glen, you know. The mist? Part of the display. Please don't touch the rain."],
            "That was not part of the display! I shall be speaking to Management.", "I've filed a note. In the mist. It will take a while to find.", 3000)
    z.d["edges"] = {"south": {"to": "glasgow", "offset": 0}, "north": {"to": "fort_william", "offset": 0}}
    z.d["spawn"] = [31, 58]
    wild(z, [("wildkit", 70, 72, 12, {"time": ["night", "dusk", "dawn"]}), ("eaglet", 70, 72, 12, {"time": ["day", "dawn"]}), ("midgie", 70, 72, 14, {"weather": ["drizzle", "fog", "clear"]}),
             ("stagmor", 70, 72, 8, {"time": ["dawn", "dusk"]}), ("fawnlet", 70, 72, 10, {}), ("snowhare", 70, 72, 8, {"weather": ["frost", "fog"]}),
             ("kidgruff", 70, 72, 10, {}), ("martling", 70, 72, 8, {"time": ["dusk", "night"]}), ("hootlet", 70, 72, 8, {"time": ["night"]}),
             ("sphagnet", 70, 72, 6, {"weather": ["drizzle", "downpour", "fog"]})])
    wild(z, [("dipling", 70, 72, 20, {}), ("rillotter", 70, 72, 20, {}), ("bradan", 70, 72, 14, {}), ("heronarch", 70, 72, 10, {}),
             ("spatelord", 70, 72, 10, {"time": ["dusk", "night"]}), ("stalklet", 70, 72, 12, {})], "water")
    z.save(OUT + "/glencoe.json")


def fort_william(OUT):
    W, H = 56, 50
    z = Z("fort_william", "Fort William", W, H, kind="town", region=SCOT, music="town_scotland",
          weather={"drizzle": 34, "fog": 18, "clear": 18, "downpour": 14, "gale": 8, "sunshine": 8})
    z.d["stage"] = "town"; z.d["town_id"] = "fort_william"
    z.border("T", 2, gaps=[(22, 48, 3, 2), (41, 0, 3, 2)])
    z.scatter(0, 0, W, H, "P", 40, 61, only="T")
    # Loch Linnhe along the west edge
    z.rect(0, 0, 7, H, "~"); z.rect(7, 0, 1, H, "w"); z.rect(8, 0, 2, H, "s")
    z.rect(7, H - 2, 15, 2, "T")
    # Ben Nevis behind the town, with the Pony Track climbing it
    mound(z, 16, 6, 17, 9, 6)
    peaks(z)
    z.rect(16, 7, 1, 10, "#")
    z.prop("standing_stone", 17, 6)
    z.sign(15, 8, "THE PONY TRACK. Ben Nevis, Beinn Nibheis in Gaelic, stands 1,345 m: the highest mountain in the whole of the British Isles. A weather observatory stood on the summit from 1883 to 1904, with staff living up there all year. Visibility was often nil. The tea, apparently, was good.")
    # streets
    z.rect(14, 20, 32, 4, ":")
    z.rect(22, 24, 3, 24, "=")
    z.rect(41, 2, 3, 18, "#")
    z.rect(34, 24, 2, 7, ":")
    # the town
    z.building(14, 16, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(17, 19, "fort_william_sanctuary", 5, 6, "up")
    z.building(22, 16, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(24, 19, "fort_william_shop", 4, 5, "up")
    z.building(28, 16, 7, 4, "stone", "West Highland Museum")
    z.building(36, 16, 4, 4, "white_render"); z.building(44, 16, 6, 4, "slate_cottage")
    z.building(14, 24, 7, 4, "white_render", "The Nevis Inn"); z.building(26, 24, 6, 4, "red_brick")
    # station: the West Highland Line
    station(z, 36, 28, 10, 5, "Fort William Station")
    z.prop("bench", 40, 30); z.prop("lamp_post", 44, 30)
    rail_guard(z, 43, 30, ["Fort William Station, where the West Highland Line starts its scenic nonsense. It's been voted among the most beautiful railway journeys in the world, and the trains are very nearly on time.",
                           "Hop aboard! The Wildlore rail runs to every station you've visited in Great Britain. Where to?"], facing="left")
    # pier on Loch Linnhe
    z.rect(8, 33, 8, 3, ":")
    z.prop("boat", 4, 34, variant=1); z.prop("boat", 3, 14, variant=1); z.prop("buoy", 5, 22); z.prop("buoy", 4, 44)
    z.prop("bollard", 9, 33); z.prop("bollard", 9, 35); z.prop("bollard", 13, 33); z.prop("bollard", 13, 35)
    z.sign(14, 34, "LOCH LINNHE. A long sea loch running from the open Atlantic almost to the foot of Ben Nevis, with seals, otters and the odd porpoise. The town stands where it ends. The Gaelic name for Fort William is An Gearasdan: 'the Garrison'.")
    z.sign(33, 22, "THE HIGH STREET. Pedestrians only, with pubs, outdoor shops and a hundred ways to buy a mug with a stag on it. It was once next to a fort, named for King William III, long gone. The street's still here. The mugs have multiplied.")
    z.sign(35, 29, "THE WEST HIGHLAND LINE. Opened in 1894, it runs through moors, lochs and mountains to Mallaig. The famous Jacobite steam train, the one that gets filmed on the Glenfinnan Viaduct, starts right here. The ticket office does not, sadly, do dragons.")
    lamps(z, [(15, 21), (21, 21), (28, 21), (35, 21), (44, 21), (23, 30), (23, 38)])
    z.prop("planter", 19, 20); z.prop("planter", 27, 20); z.prop("bench", 30, 22); z.prop("phone_box", 12, 22); z.prop("post_box", 31, 22)
    for (x, y, w, h) in [(12, 40, 9, 7), (28, 36, 6, 8), (38, 34, 14, 12), (47, 24, 5, 9)]:
        z.rect(x, y, w, h, ",")
    scatter_props(z, "oak", 10, 24, 44, 24, 12, 62, avoid=(".",))
    scatter_props(z, "rock", 10, 24, 44, 24, 6, 63, avoid=(".",))
    # NPCs
    chat(z, "fw_rescue", "hiker", 20, 18, "Mountain Rescue Volunteer",
         ["Ben Nevis is a big, kind hill with a bad temper in the mist. We go up in all weathers, so you don't have to.",
          "The summit's covered in cloud about three days in four, and there's a cliff off the north side. Take a map, a torch and a plan. In that order."], "down", "still")
    chat(z, "fw_spotter", "birdwatcher", 41, 30, "Train Spotter",
         ["The Jacobite leaves here for Mallaig, a steam train that puffs along the viaduct at Glenfinnan, the one in the films. I've seen it go by seventy-three times.",
          "I've never been on it. It's about the looking, you see. I look. The train does the rest."], "up", "still")
    chat(z, "fw_piper", "villager_5", 30, 23, "Busker",
         ["I play the whistle in front of the shop. The pipers all have their own pitch and I don't argue with a piper.",
          "The Ben Nevis Race is held every September. They run up and back down in about two hours. I'd take a bus. It's the same view, only drier."], "down", "wander")
    chat(z, "fw_kid", "villager_6", 24, 32, "Wee Lad",
         ["I've climbed Ben Nevis, you know. Well, I've climbed the Pony Track a bit. It's very big. My legs said no.",
          "My gran says on a clear day you can see Ireland from the top. She says that a lot. I think she just likes the idea."], "down", "wander")
    trainer(z, "fw_hillwalker", "Hillwalker Fergus", "Hillwalker", "hiker", [("ptarmlet", 72), ("eaglet", 72), ("kidgruff", 72)],
            41, 10, "right", ["I'm training for the Ben. It's an eight-hour walk and I've got two flasks of tea. Care for a warm-up?"],
            "A grand wee tussle. Back to the hill.", "The trick to the Ben is to start early, go steady and keep the tea hot.", 3000)
    trainer(z, "fw_shinty", "Shinty Player Eilidh", "Shinty Player", "shinty_player", [("warrender", 72), ("raidtail", 72), ("stagmor", 72)],
            30, 21, "right", ["Shinty's big round here. The Camanachd Cup's a big day. You can hear the sticks from here."],
            "A clatter of caman and a clean hit. Well played.", "The caman's a wooden stick with a curved end. It's very good for hitting. Also for gesturing.", 3000)
    z.d["edges"] = {"south": {"to": "glencoe", "offset": 0}, "north": {"to": "great_glen", "offset": 0}}
    z.d["spawn"] = [23, 21]
    wild(z, [("ptarmlet", 72, 72, 18, {"weather": ["frost", "fog", "drizzle"]}), ("eaglet", 72, 72, 10, {"time": ["day", "dawn"]}), ("wildkit", 72, 72, 8, {"time": ["night", "dusk"]}),
             ("midgie", 72, 72, 10, {"weather": ["drizzle", "fog"]}), ("stagmor", 72, 72, 8, {"time": ["dawn", "dusk"]}), ("fawnlet", 72, 72, 8, {}),
             ("snowhare", 72, 72, 8, {"weather": ["frost", "fog"]}), ("kidgruff", 72, 72, 10, {}), ("hootlet", 72, 72, 8, {"time": ["night"]}),
             ("martling", 72, 72, 8, {"time": ["dusk", "night"]}), ("binfox", 72, 72, 6, {"time": ["night"]})])
    wild(z, [("plungebeak", 72, 72, 20, {}), ("dolphlet", 72, 72, 15, {}), ("selklet", 72, 72, 15, {}), ("greyhaul", 72, 72, 15, {}),
             ("chipgull", 72, 72, 15, {}), ("baskling", 72, 72, 8, {})], "water")
    z.save(OUT + "/fort_william.json")
    sanctuary(OUT, "fort_william", "Fort William", (17, 20))
    shop(OUT, "fort_william", "Fort William", (24, 20))
    nurse("fort_william", ["Fàilte, and welcome to Fort William Sanctuary. It sits at the foot of the Ben, so we see a lot of tired teams. Pop yours on the counter.",
                           "Have a seat. The kettle's on, the shortbread's out and the radiator is, miraculously, working. Don't mind the rain. It's a local.",
                           "All better! Mòran taing for waiting. The Great Glen's next: all lochs and long views. Pack a coat. And another coat.",
                           "The Ark terminal. It's behind the boot rack. The boot rack is the most important thing in the building.",
                           "No bother. Beannachd leibh. If you see the summit, send a postcard."])
    shopkeeper("fort_william", "Fàilte! Snares, tablet, flasks of tea and enough sandwiches to feed a rescue team. What'll it be?",
               "Cheers! Mind the Ben, and take a hat. It's not for the weather. It's for the principle.")


def great_glen(OUT):
    W, H = 56, 74
    z = Z("great_glen", "The Great Glen", W, H, kind="route", region=SCOT, music="route_highlands",
          weather={"drizzle": 30, "fog": 24, "clear": 20, "downpour": 10, "sunshine": 8, "gale": 8})
    z.d["stage"] = "forest"
    z.legend["h"] = {"tile": "tall_grass", "colour": "#6e5a5c", "prop": "heather"}
    z.border("T", 2, gaps=[(41, 72, 3, 2), (20, 0, 3, 2)])
    z.scatter(0, 0, W, H, "P", 60, 71, only="T")
    # the loch, down the west side
    z.rect(2, 6, 17, 41, "w"); z.rect(3, 7, 15, 39, "~"); z.rect(18, 6, 2, 41, "s")
    # the towpath and the road along the glen
    path(z, [(41, 73), (41, 38), (20, 38), (20, 0)], "#", 3)
    # Neptune's Staircase: eight locks, each a step higher, with the towpath climbing beside them
    hs = [0, 1, 1, 2, 3, 3, 4, 4]
    for i, h in enumerate(hs):
        top = 67 - 3 * i
        z.height(34, top, 10, 3, h)
        z.rect(34, top, 1, 3, "W"); z.rect(35, top, 5, 3, "~"); z.rect(40, top, 1, 3, ":")
        z.rect(35, top, 5, 1, "W")
        z.rect(41, top, 3, 3, "#")
        z.rect(44, top, 1, 3, "W")
    z.rect(35, 70, 5, 2, "~"); z.rect(34, 70, 1, 2, "W"); z.rect(40, 70, 1, 2, ":"); z.rect(44, 70, 1, 2, "W")
    for y in range(38, 46):
        z.height(34, y, 11, 1, (y - 38) // 2)
    for (x, y) in [(37, 68), (37, 62), (37, 56), (37, 50)]:
        z.prop("canal_boat", x, y)
    z.sign(40, 66, "NEPTUNE'S STAIRCASE. Eight locks in a row, like a staircase for boats, lifting a vessel about 20 metres in under two hours. Thomas Telford designed it as part of the Caledonian Canal, which opened in 1822 to link the lochs of the Great Glen into one ship road. The boats wait. The swans don't.")
    z.sign(23, 36, "THE GREAT GLEN. A scar across Scotland about 100 km long, running from Fort William to Inverness, with a chain of lochs along its floor. Walkers call it the Great Glen Way: seventy-nine miles of loch, canal and forest. Take sandwiches. The glen's very long.")
    z.sign(21, 20, "AN GLEANN MÒR. The Gaelic name of the Great Glen, 'the big glen', as plain a name as you'll find. Plain names are the best ones. Nobody ever lost a loch because the sign was too clear.")
    # a lochside bothy and a ruined castle
    z.building(24, 44, 5, 4, "slate_cottage", "Lochside Bothy")
    z.rect(26, 48, 1, 6, "#"); z.rect(26, 52, 8, 1, "#")
    z.building(24, 56, 9, 6, "castle", "Invergarry Castle")
    z.rect(24, 62, 9, 1, ":")
    z.prop("boat", 8, 20, variant=1); z.prop("boat", 12, 33, variant=1); z.prop("boat", 6, 42, variant=1)
    z.prop("buoy", 10, 12); z.prop("buoy", 14, 27)
    # the meadow, forest edge and heather
    z.rect(24, 8, 12, 22, "f"); z.rect(24, 12, 5, 5, "h"); z.rect(30, 20, 5, 6, "h"); z.rect(26, 22, 3, 5, ",")
    for (x, y, w, h) in [(24, 10, 4, 6), (46, 40, 8, 10), (24, 42, 6, 2), (46, 56, 8, 10), (3, 52, 10, 10), (24, 63, 8, 7), (46, 8, 8, 10)]:
        z.rect(x, y, w, h, "h" if (x + y) % 2 else ",")
    scatter_props(z, "pine", 24, 30, 32, 42, 10, 72, avoid=(".",))
    scatter_props(z, "rock", 24, 3, 28, 68, 12, 73, avoid=(".",))
    scatter_props(z, "bush", 24, 3, 28, 68, 12, 74, avoid=(".",))
    z.scatter(0, 0, W, H, "P", 360, 75, only=".")
    z.scatter(0, 0, W, H, "T", 60, 76, only=".")
    # NPCs and creatures
    creature_npc(z, "gg_coo_a", "coolet", 28, 14, "The coolet gives you a long, fringed look, chews, and returns to the matter of the grass.")
    creature_npc(z, "gg_coo_b", "coolet", 32, 24, "The coolet's fringe is so long it's a miracle it can see. It seems to manage fine.")
    creature_npc(z, "gg_kelpie", "kelpie", 17, 30, "The kelpie stands in the shallows, perfectly still. It is looking at you, and you are quite sure the water is looking too.", move="still")
    chat(z, "gg_lockkeeper", "farmer", 40, 60, "Lock Keeper",
         ["Eight locks, one after the other. We call it Neptune's Staircase. A boat takes about ninety minutes to climb it, and about nine minutes to feel smug about it.",
          "The Caledonian Canal opened in 1822. Thomas Telford planned it so that ships needn't round the north of Scotland. Many still don't know it's here."], "down", "still")
    chat(z, "gg_cyclist", "jogger", 22, 24, "Great Glen Way Walker",
         ["Seventy-nine miles, Fort William to Inverness. I'm on day three. My feet have introduced themselves.",
          "It's mostly canal towpath and forest track. It's flat, they said. Then they showed me the hills."], "right", "wander")
    chat(z, "gg_monsterwatcher", "birdwatcher", 19, 44, "Monster Watcher",
         ["I've been watching this loch for ten years. I've seen sixty-two swans, nine seals, and one very suspicious log.",
          "The big one's up at Loch Ness, further along. I come down here for the practice."], "left", "still")
    chat(z, "gg_boatman", "villager_2", 40, 53, "Skipper",
         ["The canal's a short cut for yachts, fishing boats, and the odd kayaker who's lost faith in the sea.",
          "At the top of the staircase the water's about twenty metres higher than at the bottom, which is just how Telford wanted it. The boats find it quite a view."], "down", "still")
    trainer(z, "gg_angler", "Angler Rory", "Angler", "angler", [("ospret", 72), ("heronarch", 73), ("rillotter", 73), ("spatelord", 72)],
            19, 30, "right", ["Quiet! The loch's got a thing about noise. And I've got a thing about the loch. We understand each other."],
            "Ach, that's the one that got away. Not the fish, you.", "I tell people it's about patience. Really it's about not going home to the washing.", 3200)
    trainer(z, "gg_ghillie", "Ghillie Murdo", "Ghillie", "ghillie", [("stagmor", 73), ("coolet", 72), ("eaglet", 73)],
            22, 14, "left", ["I look after the glen. Mostly the glen looks after itself. I look after the people it hasn't met yet."],
            "Fair fought. The glen approves. It hasn't said so, but I can tell.", "If you hear a stag roar in autumn, it's a love song. It's also a warning. They're like a lot of us.", 3150)
    trainer(z, "gg_hillwalker", "Hillwalker Isobel", "Hillwalker", "hiker", [("kidgruff", 73), ("ptarmlet", 73), ("wildkit", 73)],
            28, 38, "right", ["I'm walking the whole Way, with a pack the size of a cow. It's character-building. My character's built."],
            "Well fought. Nothing for me but a sit-down and a piece of tablet.", "Pack light, they say. They never say what to leave out. It's always the tea.", 3150)
    trainer(z, "gg_piper", "Piper Eachann", "Piper", "piper", [("murmurant", 73), ("polartern", 74), ("coolet", 72)],
            41, 44, "right", ["I pipe at the locks. The boats love it. Probably. They've never complained, in any case."],
            "A fine lament for my team. Very moving.", "Pipes were once outlawed in parts of the Highlands. They came back louder.", 3200)
    trainer(z, "gg_warden", "Warden Ferrier", "Warden", "warden_grunt", [("thornsow", 73), ("adderking", 73), ("bramblehog", 72), ("midgeswarm", 72)],
            41, 53, "right", ["The Great Glen is an asset, you understand, and I'm its manager. I have a spreadsheet of the lochs."],
            "That wasn't in the spreadsheet either. Nothing is, today.", "I'm putting in a request to rename Loch Lochy. It's too confusing. I'll let you know.", 3300)
    z.d["edges"] = {"south": {"to": "fort_william", "offset": 0}, "east": {"to": "loch_ness", "offset": 0}  # NOTE: data/zones/great_glen.json opens the east border at rows 20-22 by hand (seam fix)}
    z.d["spawn"] = [42, 70]
    wild(z, [("kelpie", 72, 74, 8, {"weather": ["fog", "drizzle", "downpour"]}), ("coolet", 72, 74, 14, {}), ("ospret", 72, 74, 12, {"time": ["dawn", "day"]}),
             ("stagmor", 72, 74, 8, {"time": ["dawn", "dusk"]}), ("fawnlet", 72, 74, 8, {}), ("wildkit", 72, 74, 8, {"time": ["night", "dusk"]}),
             ("midgie", 72, 74, 10, {"weather": ["drizzle", "fog"]}), ("eaglet", 72, 74, 6, {"time": ["day"]}), ("kidgruff", 72, 74, 8, {}),
             ("martling", 72, 74, 8, {"time": ["dusk", "night"]}), ("hootlet", 72, 74, 8, {"time": ["night"]}), ("sphagnet", 72, 74, 6, {"weather": ["drizzle", "downpour"]})])
    wild(z, [("kelpie", 72, 74, 12, {"weather": ["fog", "drizzle", "downpour"]}), ("ospret", 72, 74, 14, {}), ("dipling", 72, 74, 20, {}),
             ("rillotter", 72, 74, 16, {}), ("bradan", 72, 74, 12, {}), ("heronarch", 72, 74, 10, {}), ("spatelord", 72, 74, 8, {"time": ["dusk", "night"]})], "water")
    z.save(OUT + "/great_glen.json")


def loch_ness_stub(OUT):
    """stub so the validator stays green until the Scotland-north agent builds the real loch_ness."""
    import os
    path_ = OUT + "/loch_ness.json"
    if os.path.exists(path_):
        return
    z = Z("loch_ness", "Loch Ness", 40, 40, kind="route", region=SCOT, music="route_highlands")
    z.d["stub"] = True; z.d["stage"] = "grass"
    z.border("T", 2, gaps=[(20, 38, 3, 2)])
    z.d["edges"] = {"south": {"to": "great_glen", "offset": 0}}
    z.d["spawn"] = [21, 36]
    z.save(path_)
