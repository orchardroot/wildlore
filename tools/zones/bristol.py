"""Wave 21, region R4: Bristol, off Bath's north side. The Avon Gorge route (Leigh Woods, the Clifton Suspension
Bridge, the Observatory and Giant's Cave, Ashton Court's balloon field) and the city of Bristol (the Floating
Harbour, the SS Great Britain, the Matthew, M Shed, St Nicholas Market, Stokes Croft's street art, Temple Meads).
Usage: python3 tools/zones/bristol.py data/zones
Writes both zones, their interiors, dialogue and trainers, and opens Bath's north wall (idempotent).
Everything off the main line is scaled: "scaled_floor" 40, the band of Bath, the anchor."""
import sys, os, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from p6a_common import *
from wcommon import _stand, DLG, TRN
from zlib import landmark

OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
FLOOR = 40
REGION = "south_england"
SPAN = 15  # Landmarks.CLIFTON_SPAN

# ---------------------------------------------------------------------------------------------------------
# small helpers on top of wcommon

def chat_npc(z, nid, sprite, x, y, who, lines, facing="down", move="still", **kw):
    chat(z, nid, sprite, x, y, who, lines, facing, move)
    z.d["npcs"][-1].update(kw)


def plaque(z, x, y, pid, title, text):
    assert "—" not in text and len(text) < 420, pid
    z.d["signs"].append({"x": x, "y": y, "text": text, "plaque": pid, "title": title})


def sign(z, x, y, text):
    assert "—" not in text
    z.d["signs"].append({"x": x, "y": y, "text": text})


def S(who, *lines):
    for t in lines:
        assert "—" not in t and len(t) <= 170, (who, len(t), t)
    return say(who, *lines)


def door_warp(z, door, to, w, h):
    z.warp(door[0], door[1], to, w // 2, h - 3, "up")


INTERIORS = []  # (zid, name, town, door, kind, w, h, npcs [(id, sprite, x, y, facing, script_cmds)], extra)


def room(zid, name, town, door, kind, w, h, npcs, extra=None):
    INTERIORS.append((zid, name, town, door, kind, w, h, npcs, extra or {}))


def trainer_scaled(z, *a, **kw):
    trainer(z, *a, **kw)
    TRN[a[0]]["scaled_floor"] = FLOOR


def scaled_trainer_def(tid, name, cls, sprite, party, intro, win, after, money):
    """a trainer fought from a script (no NPC of its own)."""
    TRN[tid] = {"id": tid, "name": name, "class": cls, "sprite": sprite,
                "party": [{"species": s, "level": l} for s, l in party], "ai": "trainer", "money": money,
                "intro": S(name, *intro), "win": win, "after": after, "scaled_floor": FLOOR}


# ---------------------------------------------------------------------------------------------------------
# the Avon Gorge

def avon_gorge():
    W, H = 60, 64
    zid = "avon_gorge"
    z = Z(zid, "Avon Gorge", W, H, kind="route", region=REGION, music="route_forest",
          weather={"clear": 26, "drizzle": 28, "fog": 14, "sunshine": 20, "gale": 8, "downpour": 4})
    z.d["stage"] = "valley"
    z.d["scaled_floor"] = FLOOR
    z.legend["m"] = {"tile": "bog", "colour": "#5b4a3a", "prop": "none"}          # the Avon's tidal mud
    z.legend["k"] = {"tile": "path", "deck": 0, "colour": "#6a655e"}              # the bridge deck
    z.legend["q"] = {"tile": "rock", "prop": "none", "colour": "#8b8172"}         # tower legs on the rims
    z.legend["g"] = {"tile": "grass", "colour": "#6f8f45"}                         # limestone downland turf
    z.rect(0, 0, W, H, ".")
    z.border("T", 2, gaps=[(20, H - 2, 3, 2), (46, 0, 3, 2)])
    z.scatter(0, 0, W, H, "P", 18, 7, only="T")

    # the river: in from the east (from Bath), north up the gorge, then west out toward the Severn
    water = set()
    for y in range(46, 51):
        for x in range(31, W):
            water.add((x, y))
    for y in range(4, 51):
        for x in range(31, 37):
            water.add((x, y))
    for y in range(4, 10):
        for x in range(0, 37):
            water.add((x, y))
    mud = set()
    for (x, y) in water:
        for dx in (-1, 0, 1):
            for dy in (-1, 0, 1):
                q = (x + dx, y + dy)
                if q not in water and 0 <= q[0] < W and 0 <= q[1] < H:
                    mud.add(q)

    def dist(x, y):
        best = 99
        for (wx, wy) in mud | water:
            best = min(best, max(abs(wx - x), abs(wy - y)))
        return best

    def base(x, y):
        if y > 50:
            return 0
        if x <= 30:  # Leigh Woods and Ashton Court
            return 6 if y <= 40 else max(0, 6 - ((y - 40) * 3) // 5)
        if y <= 8:   # down off the Downs to the city
            return max(0, y - 2)
        return 6

    dcache = {}
    for y in range(H):
        for x in range(W):
            if (x, y) in water:
                deep = (31 + 2 <= x <= 31 + 3 and 4 <= y <= 50) or (6 <= y <= 7 and x < 31) or (48 <= y <= 48 and x > 36)
                z.set(x, y, "o" if deep else "~")
                continue
            if (x, y) in mud:
                z.set(x, y, "m")
                continue
            b = base(x, y)
            d = dist(x, y) if b >= 4 else 9
            if d <= 3:
                z.set(x, y, "^")
                z.hg[y][x] = min(b, 2 * d - 1)
            else:
                z.hg[y][x] = b
    # border trees stand back where the river runs out under them
    for y in range(0, H):
        for x in range(0, W):
            if (x < 2 or x >= W - 2 or y < 2 or y >= H - 2) and z.g[y][x] in ".^":
                if (20 <= x <= 22 and y >= H - 2) or (46 <= x <= 48 and y < 2):
                    continue
                z.g[y][x] = "T"

    # the Clifton Suspension Bridge: towers on the rims at x 26 and 41, deck between
    BY = 24
    for x in range(26, 42):
        z.hg[BY][x] = 6
        z.set(x, BY, "k" if 26 < x < 41 else "#")
    for (x, y) in [(26, BY + 1), (41, BY - 1), (41, BY + 1)]:
        z.set(x, y, "q"); z.hg[y][x] = 6
    z.building(26, BY - 1, 1, 1, "suspension_bridge", "Clifton Suspension Bridge")
    z.hg[BY - 1][26] = 6
    plaque(z, 24, BY - 1, "avon_gorge_clifton_bridge", "Clifton Suspension Bridge",
           "In 1831 a 24-year-old Isambard Kingdom Brunel won the competition to bridge the Avon Gorge. Money ran out, "
           "Brunel died in 1859, and his fellow engineers finished it in 1864 as his memorial, using chains from his "
           "old Hungerford Bridge in London. The deck hangs about 75 metres above the river.")
    sign(z, 43, BY - 1, "CLIFTON SUSPENSION BRIDGE. Pedestrians free. Please do not lean over the rail to see how far down it is. It is a long way.")

    # Leigh Woods (west plateau) and Ashton Court: the Fiesta field, then the paths, then the woods round them
    for y in range(31, 44):
        for x in range(3, 16):
            if z.g[y][x] == ".":
                z.set(x, y, "g")
    path(z, [(21, H - 3), (21, 44), (17, 44), (17, 30), (21, 30), (21, BY), (25, BY)])
    path(z, [(17, 36), (8, 36)])
    for y in range(14, 41):
        for x in range(3, 26):
            if z.g[y][x] == "." and (x * 7 + y * 3) % 5 == 0:
                z.set(x, y, ",")
    scatter_props(z, "oak", 3, 14, 23, 17, 46, 11, avoid=(".", ","))
    scatter_props(z, "birch", 3, 14, 23, 17, 18, 12, avoid=(".", ","))
    for (x, y) in [(5, 33), (9, 32), (13, 34), (6, 39), (12, 40)]:
        z.building(x, y, 1, 1, "hot_air_balloon", "Fiesta balloon", show_label=False)
    plaque(z, 23, 27, "avon_gorge_whitebeams", "The Gorge's Own Trees",
           "The Avon Gorge has whitebeams found nowhere else on Earth, among them the Bristol whitebeam and Wilmott's "
           "whitebeam, clinging to the limestone. Rare plants grow here too, like Bristol rock-cress and the round-headed "
           "leek, called the Bristol onion. Look, but leave them be.")
    sign(z, 16, 29, "LEIGH WOODS. Ancient woodland on the Somerset side of the gorge, with an Iron Age hillfort, Stokeleigh Camp, hidden in the trees.")
    plaque(z, 10, 35, "avon_gorge_balloon_fiesta", "Bristol International Balloon Fiesta",
           "Every August since 1979, hundreds of hot-air balloons gather on the Ashton Court estate here and take off "
           "together at dawn and dusk in mass ascents. It is one of the biggest balloon events in Europe, and at the "
           "Night Glow the tethered balloons light up in time to music.")
    sign(z, 14, 42, "ASHTON COURT ESTATE. Deer park, golf, mountain bikes and, one weekend a year, half the sky.")

    # Clifton Down (east plateau): the Observatory over Giant's Cave, the viewpoint, the goats
    for y in range(9, 46):
        for x in range(41, 58):
            if z.g[y][x] == ".":
                z.set(x, y, "g")
    obs_door = z.building(43, 12, 5, 3, "round_tower", "Clifton Observatory", door=2)
    door_warp(z, (obs_door[0], obs_door[1]), "avon_gorge_observatory", 13, 10)
    plaque(z, 42, 16, "avon_gorge_giants_cave", "Giant's Cave and the Observatory",
           "Legend says two giant brothers, Goram and Vincent, dug the gorge, and Vincent's cave is in the cliff below. "
           "The Observatory began as a windmill that burned down in 1777; William West rebuilt it and put a camera "
           "obscura on top in 1829, and dug the tunnel down to the cave.")
    path(z, [(47, 1), (47, 10), (49, 10), (49, 15), (45, 15), (45, BY), (42, BY)])
    path(z, [(45, BY), (45, 30), (43, 30)])
    z.prop("telescope", 42, 31)
    z.prop("bench", 44, 32); z.prop("bench", 48, 20)
    plaque(z, 44, 29, "avon_gorge_peregrines", "Peregrines of the Gorge",
           "Peregrine falcons nest on the cliff ledges here, as they have done on and off for centuries. A peregrine "
           "folds its wings and dives on pigeons at well over 300 kilometres an hour, the fastest animal on the planet. "
           "Watch the ledges below the Observatory in spring.")
    plaque(z, 48, 6, "avon_gorge_rocks_railway", "Clifton Rocks Railway",
           "From 1893 to 1934 a funicular railway ran up a tunnel inside this cliff, from Hotwells to Clifton, its cars "
           "worked by water ballast. In the Second World War the tunnel sheltered the BBC, ready to keep broadcasting "
           "if London was bombed.")
    plaque(z, 42, 41, "avon_gorge_tides", "A Tidal River",
           "The Avon here rises and falls with the Severn Estuary, which has one of the biggest tidal ranges in the "
           "world, over 14 metres at the biggest spring tides. At low tide the river shrinks to a trickle between steep, "
           "shining mudbanks. Do not go down on to the mud.")
    sign(z, 50, 26, "THE DOWNS. Four hundred acres of open grass where Bristol walks its dogs. The goats on the cliffs are on scrub duty: they eat the brambles that would smother the rare flowers.")
    scatter_props(z, "bush", 41, 9, 16, 36, 12, 13, avoid=("g",))
    for (x, y) in [(52, 12), (54, 16), (50, 36), (55, 40), (53, 33)]:
        blob(z, x, y, 2.6, 1.6, ",", only="g", seed=x * y, jitter=0.4)

    # the farmland between Bath and the gorge
    z.rect(2, 55, 18, 1, "H"); z.rect(24, 55, 32, 1, "H")
    blob(z, 10, 58, 5, 2, ",", only=".", seed=3, jitter=0.3)
    blob(z, 40, 53, 7, 2, ",", only=".", seed=4, jitter=0.3)
    scatter_props(z, "oak", 28, 57, 26, 4, 8, 21, avoid=("."))
    sign(z, 23, 60, "PUBLIC FOOTPATH. Bristol and the Avon Gorge, north. Bath, behind you, with its buns.")
    sign(z, 30, 52, "CIDER ORCHARD. Somerset apples. The trees are wassailed every January: songs, toast in the branches and a lot of noise to wake them up and scare off bad spirits.")
    for (x, y) in [(28, 52), (34, 53), (37, 52), (44, 52), (48, 53)]:
        z.prop("oak", x, y, variant=2)

    # people
    chat_npc(z, "toll_keeper", "rail_guard", 24, BY + 1, "Toll Keeper",
             ["The deck's 214 metres from tower to tower. Folk walking over pay nothing. Cars pay a toll, as they have since 1864.",
              "Brunel wanted sphinxes on top of the towers. Egyptian style was all the rage. Money ran out. The towers have been waiting for their sphinxes ever since."],
             "up")
    DLG[zid]["toll_keeper"] = brunel_toll_keeper()
    chat_npc(z, "fiesta_pilot", "festival_goer", 9, 37, "Pilot Gwen", ["(set below)"], "down")
    DLG[zid]["fiesta_pilot"] = fiesta_pilot()
    chat_npc(z, "watch_leader", "birdwatcher", 43, 31, "Watch Leader Hal", ["(set below)"], "left")
    DLG[zid]["watch_leader"] = peregrine_leader()
    chat_npc(z, "pigeon_fancier", "villager_4", 52, 22, "Pigeon Fancier", ["(set below)"], "down", "wander")
    DLG[zid]["pigeon_fancier"] = peregrine_fancier()
    chat_npc(z, "gorge_goatherd", "farmer", 49, 40, "Downs Ranger",
             ["Those goats are feral, from a herd brought in to graze the cliffs. They nibble the scrub off the rocks so the little rare plants get the light.",
              "Best workers we've got. No breaks, no complaints, and they do the bits a person would need a rope for."], "left", "wander")
    chat_npc(z, "orchard_farmer", "farmer", 33, 54, "Cider Farmer",
             ["Proper West Country cider's just apples, pressed and left to get on with it. Kingston Black, Yarlington Mill, Dabinett. Lovely names, lovely trees.",
              "Scrumpy's the rough stuff, cloudy, from the farm. It's like a pasty: there's a right way, and there's the way the tourists have it."], "down", "wander")
    chat_npc(z, "leigh_forager", "hiker", 12, 22, "Woodland Volunteer",
             ["Leigh Woods belongs to the National Trust now. It was given to the nation in 1909 so Bristol could never build over it.",
              "In autumn the woods fill with fungi. Look, don't pick. That one there could have you, and it knows it."], "right", "wander")
    # trainers (all scaled)
    trainer_scaled(z, "gorge_climber", "Climber Morwenna", "Rock Climber", "hillwalker",
                   [("billgruff", 40), ("stoopfalcon", 40), ("quarrion", 41)], 47, 27, "left",
                   ["I've been up the Main Wall twice this morning. The limestone's polished like glass from a hundred years of climbers. Let's see if you've got grip."],
                   "Ah, I slipped. Not off the cliff, thankfully. Just off the pace.", "Climbers have been on these walls since the 1890s. The goats have been on them longer.", 2200)
    trainer_scaled(z, "gorge_forager", "Forager Tamsin", "Forager", "hiker",
                   [("sulphurhen", 40), ("grandpuff", 39), ("pinewraith", 40)], 9, 25, "right",
                   ["Mind your step! You're standing on lunch. Probably. Possibly. Let's battle while I work it out."],
                   "Fair enough. I'll stick to blackberries.", "Never eat anything you can't name, and never name anything you've just eaten.", 2100)
    trainer_scaled(z, "gorge_dogwalker", "Dog Walker Clive", "Dog Walker", "villager_2",
                   [("binfox", 40), ("brockmoor", 40), ("warrender", 39)], 51, 30, "down",
                   ["Alright, my lover? Three dogs, two leads, one tennis ball. And now a battle. Lovely."],
                   "Gert lush, that was. Means very good. You'll pick it up.", "Every dog on the Downs knows me. None of them listens to me.", 2000)
    trainer_scaled(z, "gorge_birder", "Birder Priya", "Birdwatcher", "birdwatcher",
                   [("stoopfalcon", 41), ("heronarch", 40), ("murmurant", 40)], 19, 45, "up",
                   ["Shh. There's a peregrine on the ledge, a heron on the mud and a challenger on the path. Only one of them is any use to me."],
                   "Ticked off. In both senses.", "On a still evening the starlings come in over the city in their thousands. Worth missing your tea for.", 2100)

    wild(z, [("peregrin", 39, 40, 12, {"time": ["dawn", "day"]}), ("kidgruff", 39, 40, 16, {}), ("pepperling", 39, 40, 8, {}),
             ("zigzlet", 38, 40, 8, {"time": ["day", "dusk"]}), ("hootlet", 39, 40, 8, {"time": ["night"]}),
             ("brockling", 39, 40, 8, {"time": ["night"]}), ("flittermouse", 38, 40, 8, {"time": ["dusk", "night"]}),
             ("grizzlet", 38, 40, 10, {}), ("starlet", 39, 40, 8, {"time": ["dusk"]}), ("scuttlet", 38, 40, 8, {}),
             ("sulphurhen", 39, 40, 4, {"season": ["autumn"]}), ("wickerling", 39, 40, 4, {"time": ["dawn", "dusk"]}),
             ("gaugelet", 39, 40, 3, {})])
    wild(z, [("elverlet", 39, 40, 30, {}), ("pincray", 39, 40, 25, {}), ("stalklet", 39, 40, 20, {}), ("minkshade", 39, 40, 12, {"time": ["dusk", "night"]}),
             ("dipling", 39, 40, 13, {})], "water")
    z.d["edges"] = {"south": {"to": "bath", "offset": 0}, "north": {"to": "bristol", "offset": BRISTOL_GAP - 46}}
    z.d["spawn"] = [21, H - 4]
    done(z)
    z.save(OUT + "/" + zid + ".json")

    room("avon_gorge_observatory", "Clifton Observatory", zid, obs_door, "museum", 13, 10, [
        ("camera_keeper", "astronomer", 6, 2, "down", S("Camera Obscura Keeper",
            "Welcome to the camera obscura! A lens and a mirror up in the roof throw the view outside on to this white table, live, in colour.",
            "No electricity, no screen. It's how people saw moving pictures before there were any. Victorians queued round the block for it.",
            "The stair down the far side goes through the rock to Giant's Cave, out on the cliff face. Hold the rail. Mind your head."))],
        {"cave_door": True})
    room("avon_gorge_giants_cave", "Giant's Cave", "avon_gorge_observatory", None, "castle", 11, 9, [
        ("cave_guide", "tour_guide", 5, 1, "down", S("Cave Guide",
            "St Vincent's Cave, the old name. A little chapel to St Vincent stood up here once, they say. Now it's just us, and the wind.",
            "The giants Goram and Vincent both loved the same woman, Avona. She'd marry whoever drained the lake. Vincent dug the gorge; Goram fell asleep.",
            "Step out on the balcony and look down. That's 75 metres to the river, and the bridge right there. Brunel would have liked this view."))],
        {"dark": True})


def brunel_toll_keeper():
    g = "Toll Keeper"
    return [{"do": "if", "flag": "q_bristol_brunel_started",
             "then": [{"do": "if", "flag": "q_bristol_brunel_1",
                       "then": S(g, "Off to the SS Great Britain next, is it? Down at the harbour, in the very dock she was built in. Give her my regards."),
                       "else": S(g, "Brunel's notebook! Well I never. Page one: 'Clifton. Span: 702 feet.' That's 214 metres, give or take.",
                                 "He was only 24 when he won it. He called the bridge 'my first child, my darling'. His words, not mine.",
                                 "There. I've put the toll booth's stamp on the page. Next stop, the ship.") +
                       [{"do": "set", "flag": "q_bristol_brunel_1"}, {"do": "sfx", "id": "item"}]}],
             "else": S(g, "The deck's 214 metres from tower to tower. Folk on foot pay nothing; cars pay a toll, as they have since 1864.",
                       "Brunel wanted sphinxes on top of the towers. Egyptian style was all the rage. The money ran out. The towers are still waiting.")}]


def fiesta_pilot():
    g = "Pilot Gwen"
    done_lines = S(g, "There she goes! Up over the gorge on the evening breeze. You can see right down the Avon to the Severn from up there.",
                   "Fiesta's in August, but between you and me, the best flights are any still morning with a flask.")
    launch = ([{"do": "fade_out"}, {"do": "sfx", "id": "heal"}, {"do": "fade_in"}] +
              S(g, "Burner on... a long roar... and she's filling! Look at her stand up! Crew, hands on the basket!",
                "We're off! Light as a feather. Wave to Clifton! Wave to the goats!",
                "Down we come in a field by the orchard, gentle as you like. Champagne for the farmer: an old balloonists' custom.",
                "You've earned this. A little wicker sprite has been living in my spare basket all summer. It likes you. Take it.") +
              [{"do": "give_creature", "species": "wickerling", "level": FLOOR},
               {"do": "give_item", "item": "bristol_cider", "n": 3},
               {"do": "standing", "nation": "england", "amount": 2},
               {"do": "set", "flag": "q_bristol_fiesta_done"}])
    ready = {"do": "if", "flag": "q_bristol_fiesta_3", "then": launch,
             "else": S(g, "Envelope? Got it. Burner? Got it. Now I need a ground crew, and the best one in Bristol hangs about the Harbourside.",
                       "Their crew chief only takes orders from someone who's beaten her. Off you go!")}
    burner = {"do": "if", "flag": "q_bristol_fiesta_2", "then": [ready],
              "else": S(g, "Lovely envelope! Next, my burner's valve is shot. The engineers at Aerospace Bristol, out at Filton, owe me one. Ask for a spare.")}
    env = {"do": "if", "flag": "q_bristol_fiesta_1", "then": [burner],
           "else": S(g, "Still waiting on my envelope from the Balloon Works in Bristol. South of the harbour, by the Sanctuary.")}
    start = (S(g, "Oh, thank goodness, a pair of hands! I'm Gwen. I fly balloons. Well, I fly them when they're not in bits.",
               "Hot air's lighter than cold air, so you heat the air in the envelope and up you go. It's been working since 1783.",
               "But my envelope's torn, my burner's sulking and my crew have gone to the pub. Can you help me get airborne?") +
             [{"do": "choice", "text": "Help Gwen get airborne?", "options": ["Of course!", "Not just now"], "set": "_bristol_fiesta_yes"},
              {"do": "if", "flag": "_bristol_fiesta_yes", "eq": 0,
               "then": S(g, "Brilliant! First, the Balloon Works in Bristol are patching my envelope. Fetch it for me?") +
                       [{"do": "set", "flag": "q_bristol_fiesta_started"}],
               "else": S(g, "Fair enough. I'll be here, staring at the sky.")}])
    return [{"do": "if", "flag": "q_bristol_fiesta_done", "then": done_lines,
             "else": [{"do": "if", "flag": "q_bristol_fiesta_started", "then": [env], "else": start}]}]


def peregrine_leader():
    g = "Watch Leader Hal"
    reward = (S(g, "That's a peregrine! Look at that moustache stripe, those yellow feet. Beautiful. Thank you for showing me.",
                "Here, take this. A moulted feather from the ledge, found fair and square. It's said to make a creature quick off the mark.") +
              [{"do": "give_item", "item": "peregrine_feather"}, {"do": "give_item", "item": "flask_of_tea", "n": 2},
               {"do": "standing", "nation": "england", "amount": 1}, {"do": "set", "flag": "q_bristol_peregrine_done"}])
    show = {"do": "when", "cond": "has_peregrin", "then": reward,
            "else": [{"do": "when", "cond": "has_stoopfalcon", "then": reward,
                      "else": S(g, "Last task: catch a peregrine yourself. They hunt over the gorge at dawn and by day. Bring one to show me.")}]}
    step2 = {"do": "if", "flag": "q_bristol_peregrine_2", "then": [show],
             "else": S(g, "Ask the pigeon fancier on the Downs what peregrines eat. He'll have opinions. Loud ones.")}
    look = (S(g, "Here, have a look through the scope. Left of the bridge, two-thirds down the cliff. See the ledge with the white splashes?",
              "There she is! The falcon. The female's bigger than the male, by about a third. The male's called a tiercel, from the Latin for a third.",
              "They've raised chicks here most springs. Some years we get three or four. Now, a bit of homework for you.") +
            [{"do": "set", "flag": "q_bristol_peregrine_1"}])
    start = (S(g, "Peregrine watch! Every spring we set up the scopes here so anybody can see the falcons on the cliff.",
               "They were nearly wiped out in the 1960s by pesticides that made their eggshells thin. They've come back. Want to help with today's watch?") +
             [{"do": "choice", "text": "Join the peregrine watch?", "options": ["Yes, please", "Maybe later"], "set": "_bristol_peregrine_yes"},
              {"do": "if", "flag": "_bristol_peregrine_yes", "eq": 0,
               "then": [{"do": "set", "flag": "q_bristol_peregrine_started"}] + look,
               "else": S(g, "The falcons aren't going anywhere. Well, they are, at 300 kilometres an hour, but they'll come back.")}])
    return [{"do": "if", "flag": "q_bristol_peregrine_done",
             "then": S(g, "The tiercel brought her a pigeon this morning, mid-air. Passed it claw to claw. Romance isn't dead."),
             "else": [{"do": "if", "flag": "q_bristol_peregrine_1", "then": [step2],
                       "else": [{"do": "if", "flag": "q_bristol_peregrine_started", "then": look, "else": start}]}]}]


def peregrine_fancier():
    g = "Pigeon Fancier"
    return [{"do": "if", "flag": "q_bristol_peregrine_1",
             "then": [{"do": "if", "flag": "q_bristol_peregrine_2",
                       "then": S(g, "Still here. Still counting my birds. Still one short."),
                       "else": S(g, "What do peregrines eat? Pigeons! My pigeons! Racing pigeons worth more than my car!",
                                 "Well, pigeons mostly, and starlings, and the odd duck. They catch them in the air, in a dive. Clean as you like.",
                                 "Townie pigeons, mind, are why falcons do so well in cities. Cliffs, cathedrals, tower blocks: it's all ledges to a peregrine.") +
                               [{"do": "set", "flag": "q_bristol_peregrine_2"}]}],
             "else": S(g, "Alright my lover. Racing pigeons, me. They can find their way home from France. I can't find my way home from the pub.")}]


# ---------------------------------------------------------------------------------------------------------
# Bristol

BRISTOL_GAP = 8  # the south edge gap in Bristol (x 8 to 10), where the gorge's north gap (x 46 to 48) lands


def bristol():
    W, H = 76, 60
    zid = "bristol"
    z = Z(zid, "Bristol", W, H, kind="town", region=REGION, music="town_city",
          weather={"clear": 26, "drizzle": 32, "fog": 10, "sunshine": 22, "downpour": 6, "gale": 4})
    z.d["stage"] = "city"
    z.d["town_id"] = "bristol"
    z.d["scaled_floor"] = FLOOR
    z.legend["M"] = {"tile": "building", "colour": "#3d5a66"}  # the Matthew's berth: she floats
    z.rect(0, 0, W, H, ".")
    z.border("T", 2, gaps=[(BRISTOL_GAP, H - 2, 3, 2)])
    z.scatter(0, 0, W, H, "P", 10, 17, only="T")

    # the Floating Harbour, west to east, quays either side
    z.rect(2, 30, 72, 5, "~")
    z.rect(2, 32, 72, 1, "o")
    z.rect(2, 29, 72, 1, ":")
    z.rect(2, 35, 72, 1, ":")
    for x in range(4, 74, 5):
        z.prop("bollard", x, 29) if x not in (40, 41, 62, 63, 64) else None
    # Pero's Bridge (footbridge) and Redcliffe Bridge (road)
    z.rect(40, 30, 2, 5, "|"); z.rect(39, 30, 1, 5, "F"); z.rect(42, 30, 1, 5, "F")
    z.rect(62, 30, 3, 5, "="); z.rect(61, 30, 1, 5, "W"); z.rect(65, 30, 1, 5, "W")
    plaque(z, 38, 28, "bristol_peros_bridge", "Pero's Bridge",
           "This footbridge, opened in 1999, is named after Pero Jones, an enslaved man brought to Bristol from the "
           "Caribbean island of Nevis in 1783 by the merchant John Pinney. He lived the rest of his life in the city. "
           "The horns on the bridge are counterweights that let it lift for boats.")
    # the Matthew, moored by the Harbourside
    z.rect(47, 30, 6, 2, "M")
    z.building(47, 30, 6, 2, "caravel", "The Matthew")
    plaque(z, 50, 28, "bristol_matthew", "The Matthew",
           "In 1497 John Cabot, an Italian navigator sailing for Henry VII, left Bristol in a little ship called the "
           "Matthew and reached North America, probably Newfoundland. This is a replica built for the 500th "
           "anniversary, which sailed the Atlantic again in 1997. She still takes passengers round the harbour.")
    for (x, y) in [(10, 31), (24, 33), (57, 31), (70, 33), (34, 31)]:
        z.prop("boat", x, y, variant=(x % 2))
    z.prop("canal_boat", 15, 33)

    # north side: Clifton (west, painted terraces on the hill), Brandon Hill and Cabot Tower, the Cathedral,
    # the Centre and the Old City, King Street, Stokes Croft (north-east)
    hills(z, [(9, 10, 3, 14), (28, 9, 3, 9)])
    for y in range(29, 36):
        for x in range(W):
            z.hg[y][x] = 0
    smooth(z)
    # Clifton
    z.building(3, 4, 6, 3, "painted_terrace", "Clifton Terrace")
    z.building(10, 4, 7, 3, "painted_terrace", "Royal York Crescent")
    z.building(3, 10, 7, 3, "painted_terrace", "Cliftonwood")
    zoo = z.building(12, 11, 7, 4, "stone", "Bristol Zoo Gardens", door=3)
    z.building(3, 17, 6, 3, "painted_terrace", "Hotwells Row")
    z.building(11, 19, 7, 3, "painted_terrace", "Clifton Village")
    path(z, [(2, 8), (20, 8)], ":"); path(z, [(2, 15), (22, 15)], ":"); path(z, [(2, 23), (20, 23)], ":")
    path(z, [(20, 3), (20, 28)], ":")
    path(z, [(BRISTOL_GAP + 1, 36), (BRISTOL_GAP + 1, H - 1)], "#")
    plaque(z, 11, 16, "bristol_zoo", "Bristol Zoo Gardens",
           "Opened in 1836, Bristol Zoo in Clifton was one of the oldest zoos in the world. Alfred the gorilla, who "
           "arrived in 1930, became the city's favourite and is still on show, stuffed, in the city museum. The zoo "
           "closed here in 2022 and moved out to a bigger site north of the city.")
    chat_npc(z, "bristol_l", "poet", 7, 9, "Clifton Linguist",
             ["Listen for the Bristol L. Bristolians add an L to words that end in a vowel. An idea becomes an ideal; the area is an areal.",
              "Some say the city's own name caught it. Bristol was once Brycgstow, Old English for the place at the bridge. Then Bristow. Then, well, Bristol."],
             "down")
    # Brandon Hill and Cabot Tower
    for y in range(4, 15):
        for x in range(23, 34):
            if z.g[y][x] == "." and (x + y) % 3 != 0:
                z.set(x, y, ",")
    cab = z.building(27, 7, 3, 3, "round_tower", "Cabot Tower", door=1)
    path(z, [(28, 10), (28, 16), (20, 16)], "#")
    plaque(z, 30, 11, "bristol_cabot_tower", "Cabot Tower",
           "Built in 1897 on Brandon Hill to mark 400 years since John Cabot sailed from Bristol to North America. "
           "Brandon Hill is said to be the oldest public park in Bristol, given to the city in 1174. Climb the tower's "
           "narrow stair for the best view of the harbour.")
    # the Cathedral on College Green
    cat = z.building(34, 18, 8, 5, "cathedral", "Bristol Cathedral", door=5)
    sign(z, 33, 23, "COLLEGE GREEN. Bristol Cathedral was an abbey church founded in 1140. Its choir is a hall church, the vaults all one height, rare in Britain.")
    # the Centre and the Old City
    path(z, [(21, 28), (74, 28)], ":")
    path(z, [(44, 4), (44, 28)], ":")
    path(z, [(21, 24), (74, 24)], ":")
    z.prop("statue", 43, 26)
    z.d["props"][-1]["variant"] = 0
    plaque(z, 45, 26, "bristol_colston_plinth", "The Empty Plinth",
           "A statue of Edward Colston stood here from 1895. Colston was an official of the Royal African Company, "
           "which shipped tens of thousands of enslaved Africans across the Atlantic; Bristol's ships made over 2,000 "
           "slaving voyages. In June 2020 protesters pulled the statue down and rolled it into the harbour. It is now in M Shed.")
    sign(z, 42, 27, "THE CENTRE. Once the river ran right through here; the Frome was covered over in stages, and boats used to moor where the fountains are.")
    market = z.building(48, 18, 8, 5, "stone", "St Nicholas Market", door=3)
    for x in (48, 53, 55):
        z.prop("market_stall", x, 23, variant=x % 3)
    plaque(z, 57, 23, "bristol_nails", "The Nails",
           "The four bronze pillars outside the Corn Exchange are the Nails, where merchants once counted out their "
           "money. Bristolians will tell you this is where 'paying on the nail' comes from; the phrase may be older, "
           "but the Nails are real. The Exchange clock has two minute hands: Bristol once kept its own time, about ten minutes behind London.")
    trow = z.building(58, 18, 7, 5, "tudor", "Llandoger Trow", door=3)
    z.building(66, 18, 7, 5, "bristol_byzantine", "The Granary")
    plaque(z, 66, 23, "bristol_byzantine", "Bristol Byzantine",
           "Victorian Bristol put up its warehouses in a style all its own: red brick with round arches picked out in "
           "yellow and black brick, borrowed from Moorish and Italian buildings. The Granary on Welsh Back, built in "
           "1869, is the finest example. It later became a famous music club.")
    # Millennium Square, Cary Grant
    z.prop("statue", 33, 27)
    plaque(z, 31, 27, "bristol_cary_grant", "Cary Grant",
           "Archibald Leach was born in Horfield, Bristol, in 1904. He ran away to join a troupe of acrobats, went to "
           "America, and became the film star Cary Grant. His bronze statue in Millennium Square, unveiled in 2001, "
           "shows him walking, as if just passing through.")
    # Stokes Croft: street art
    z.building(47, 4, 6, 3, "painted_terrace", "Stokes Croft")
    rec = z.building(55, 4, 6, 3, "red_brick", "Record Shop", door=2)
    z.building(63, 4, 7, 3, "painted_terrace", "Picton Street")
    z.building(47, 10, 7, 3, "red_brick", "Gallery Workshop")
    gal = (50, 12)
    z.building(57, 10, 6, 3, "terrace", "Jamaica Street")
    z.building(65, 10, 7, 3, "painted_terrace", "St Pauls")
    path(z, [(46, 8), (73, 8)], ":")
    path(z, [(46, 14), (73, 14)], ":")
    plaque(z, 62, 15, "bristol_street_art", "Bristol's Street Art",
           "Bristol's walls became famous in the 1980s and 1990s, when local graffiti writers turned whole streets into "
           "galleries, and an anonymous Bristol artist went on to become world famous. Today murals are painted by "
           "permission here, and Upfest in Bedminster is one of Europe's biggest street art festivals.")
    plaque(z, 54, 15, "bristol_trip_hop", "The Bristol Sound",
           "In the 1980s sound systems like the Wild Bunch played at parties across St Pauls, mixing reggae, hip hop and "
           "soul. Out of them came Massive Attack, Portishead and Tricky, and a slow, moody sound the music press called "
           "trip-hop. St Pauls Carnival has filled these streets every summer since 1968.")
    plaque(z, 70, 16, "bristol_bus_boycott", "The Bristol Bus Boycott",
           "In 1963 the Bristol Omnibus Company refused to employ Black and Asian bus crews. Led by Roy Hackett, Paul "
           "Stephenson and others, people boycotted the buses for four months, until the company gave in on 28 August "
           "1963. It helped bring in Britain's first laws against racial discrimination.")

    # south side: the SS Great Britain in her dock, the Dockyard Museum, M Shed, St Mary Redcliffe, Temple Meads
    z.rect(13, 36, 16, 1, ":")
    z.building(13, 37, 16, 4, "ss_great_britain", "SS Great Britain", show_label=False)
    ss_door = z.building(15, 42, 6, 3, "stone", "Brunel's SS Great Britain", door=3)
    plaque(z, 12, 41, "bristol_ss_great_britain", "SS Great Britain",
           "Designed by Isambard Kingdom Brunel and launched here in 1843, she was the first ship to bring together an "
           "iron hull and a screw propeller, and the biggest ship in the world. She carried emigrants to Australia for "
           "decades, ended up abandoned in the Falkland Islands, and was floated home to this very dock in 1970.")
    msh = z.building(33, 37, 9, 4, "mill", "M Shed", door=4)
    for x in (31, 43):
        z.prop("statue", x, 36, variant=1)
    sign(z, 30, 41, "M SHED. A 1950s dockside transit shed, now Bristol's museum of Bristol. The cranes outside are the real thing and still work on special days.")
    balloon_works = z.building(23, 47, 6, 3, "red_brick", "Balloon Works", door=3)
    aero = z.building(33, 46, 10, 4, "glass_tower", "Aerospace Bristol", door=5)
    plaque(z, 44, 49, "bristol_concorde", "Concorde at Filton",
           "Britain's Concordes were built at Filton, just north of Bristol, and the first British one flew from there in "
           "1969. Concorde crossed the Atlantic at twice the speed of sound. The very last Concorde ever to fly, Alpha "
           "Foxtrot, landed at Filton on 26 November 2003 and now lives in the Aerospace Bristol museum.")
    redcliffe = z.building(50, 38, 9, 5, "cathedral", "St Mary Redcliffe", door=4)
    plaque(z, 49, 43, "bristol_st_mary_redcliffe", "St Mary Redcliffe",
           "Queen Elizabeth I is said to have called this 'the fairest, goodliest and most famous parish church in "
           "England'. It was built by Bristol's merchants, whose fortunes came in over the quays right below it. Its "
           "spire, broken by lightning in 1446, was only finished again in 1872.")
    # Temple Meads
    tm = station(z, 63, 46, 10, 5, "Bristol Temple Meads")
    z.rect(73, 49, 3, 1, "!")
    z.prop("buffer_stop", 62, 49)
    rail_guard(z, 61, 47, ["Bristol Temple Meads! Brunel's station for his Great Western Railway, from London to Bristol, opened in 1840 and 1841.",
                            "All aboard! Trains to everywhere you've been. Mind the gap, and mind the man with the bike."], facing="right")
    plaque(z, 66, 44, "bristol_temple_meads", "Temple Meads",
           "Brunel's Great Western Railway reached here from London in 1841. He built it on a broad gauge, seven feet "
           "wide, for smooth, fast trains; the rest of the country chose narrower track, and the last broad gauge train "
           "ran in 1892. His original station, with its mock-Tudor front, still stands beside the newer one.")
    # Sanctuary and shop (south-west, by the road up from the gorge)
    z.building(2, 44, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(5, 47, "bristol_sanctuary", 5, 6, "up")
    z.building(11, 47, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(13, 50, "bristol_shop", 4, 5, "up")
    path(z, [(2, 51), (60, 51)], ":")
    path(z, [(2, 37), (12, 37)], ":")
    path(z, [(30, 36), (30, 51)], ":")
    path(z, [(46, 36), (46, 51)], ":")
    path(z, [(60, 36), (60, 51)], ":")
    z.rect(2, 52, 72, 1, "H")
    for x in (BRISTOL_GAP, BRISTOL_GAP + 1, BRISTOL_GAP + 2):
        z.set(x, 52, "#")
    blob(z, 25, 56, 9, 2, ",", only=".", seed=11, jitter=0.4)
    blob(z, 52, 56, 9, 2, ",", only=".", seed=12, jitter=0.4)
    sign(z, BRISTOL_GAP + 3, 56, "To CLIFTON DOWN and the AVON GORGE. Mind the goats.")
    # lamps along the quays
    for x in range(6, 74, 8):
        z.prop("lamp_post", x, 28) if z.g[28][x] == ":" else None
        z.prop("lamp_post", x, 36) if z.g[36][x] in ".:" else None

    # people
    chat_npc(z, "brs_dockhand", "sailor", 25, 36, "Harbour Hand",
             ["They call it the Floating Harbour because the water's kept in behind lock gates, so the ships float even when the tide's out.",
              "Before 1809 ships here sat on the mud twice a day at low tide. Built 'shipshape and Bristol fashion', they had to be, to take it."],
             "up")
    chat_npc(z, "brs_cider", "villager_1", 61, 26, "Cider Drinker",
             ["Ooh arr! No, nobody says that. Not really. Well, I do, but only after my second cider.",
              "Where's it to? That's Bristolian for 'where is it?'. And when you get off the bus you say 'cheers, drive'. Manners, see."],
             "down", "wander")
    chat_npc(z, "brs_student", "student", 37, 16, "Student",
             ["The Wills Memorial Building up Park Street is the university. Built with tobacco money, by the Wills family, in the 1920s.",
              "Bristol's chocolate too: J. S. Fry and Sons made the first chocolate bar you could eat, here, in 1847. Science, that is."],
             "down", "wander")
    chat_npc(z, "brs_market", "shopkeeper", 52, 24, "Market Trader",
             ["St Nick's! Pies, falafel, vintage records, a man who'll fix your watch and a woman who'll read your palm. Sometimes it's the same stall.",
              "The Corn Exchange was built in 1743. Them bronze pillars outside are the Nails. Pay on the nail, my lover."],
             "up")
    chat_npc(z, "brs_fox", "fox_watcher", 26, 22, "Fox Watcher",
             ["Bristol's famous for its urban foxes. Scientists at the university have studied them for decades, garden by garden.",
              "They curl up on shed roofs in the sun. Absolute bin-raiding menaces. I love them."], "right", "wander", times=["dusk", "night"])
    chat_npc(z, "brs_gromit", "villager_6", 44, 50, "Animator",
             ["I work at one of the animation studios. Bristol's a big place for wildlife films and stop-motion. Plasticine everywhere.",
              "Twenty-four frames a second. A week's work for a few seconds of a dog raising an eyebrow. Worth it."], "up", "wander")
    # quest givers
    chat_npc(z, "brunel_fan", "commuter", 70, 48, "Engineer Prudence", ["(set below)"], "down")
    DLG[zid]["brunel_fan"] = brunel_giver()
    chat_npc(z, "gallery_keeper", "poet", 51, 13, "Gallery Keeper Saffron", ["(set below)"], "down")
    DLG[zid]["gallery_keeper"] = art_giver()
    chat_npc(z, "crew_chief_npc", "festival_goer", 55, 27, "Crew Chief Bex", ["(set below)"], "down")
    DLG[zid]["crew_chief_npc"] = crew_chief()
    # the four pieces of street art, each a painted figure on a wall
    ART = [
        ("art_gull", 58, 7, "a huge herring gull in a flat cap, sneaking a chip off a sleeping pigeon",
         "Underneath, in neat little letters: 'BRISTOL FASHION'.", 1),
        ("art_falcon", 66, 13, "a peregrine in a top hat and tails, diving on a startled pigeon over a tiny bridge",
         "Someone's tagged it 'IKB WOZ ERE'. Brunel would have been delighted.", 2),
        ("art_tide", 47, 7, "a giant tide gauge with sea creatures climbing it, the numbers going up to 14 metres",
         "A note says the Severn's tide is one of the highest in the world. Art, with a fact attached.", 3),
        ("art_balloon", 69, 7, "a hot-air balloon made of apples, carrying a cow, a goat and a very surprised vicar",
         "It's signed with a little stencil of a spray can. Nobody knows whose.", 4),
    ]
    for aid, x, y, what, extra, n in ART:
        _stand(z, x, y)
        z.npc(id=aid, sprite="creature:stencilette", x=x, y=y, facing="down", move="still", script=aid)
        DLG[zid][aid] = art_piece(what, extra, n)
    # trainers
    trainer_scaled(z, "brs_skater", "Skater Jojo", "Skater", "student",
                   [("raidtail", 40), ("strutcoo", 40), ("squawkster", 40)], 40, 26, "left",
                   ["Watch this kickflip! No, wait, watch this battle. The kickflip was rubbish."],
                   "Proper slammed. Fair play.", "Bristol's been a skate city since the eighties. The harbourside's all smooth slabs. Heaven.", 2200)
    trainer_scaled(z, "brs_dj", "DJ Marlon", "DJ", "festival_goer",
                   [("murmurant", 40), ("severnshock", 41), ("sootwing", 40)], 59, 13, "left",
                   ["Slow it down. Ninety beats a minute. Bass you feel in your teeth. That's the Bristol sound. Now drop it."],
                   "Respect. You found the groove.", "Sound systems in St Pauls, 1980s. Reggae, hip hop, soul, all mashed up. Everything came out of that.", 2300)
    trainer_scaled(z, "brs_sailor", "Sailor Ennis", "Sailor", "sailor",
                   [("greyhaul", 40), ("clawcastle", 40), ("plungebeak", 40)], 21, 36, "left",
                   ["Shipshape and Bristol fashion! That means everything stowed tight. Let's see if your team is."],
                   "Holed below the waterline. Well fought.", "Bristol ships sailed to Newfoundland, the Caribbean and Africa. Not all of that history is happy, mind. M Shed tells it straight.", 2200)
    trainer_scaled(z, "brs_student_t", "Student Ffion", "Student", "student",
                   [("tunneller", 40), ("centurion", 40), ("lanternis", 40)], 36, 13, "down",
                   ["I'm doing a PhD on Victorian engineering. Ask me anything about bolts. Actually, don't. Battle me instead."],
                   "I'll put that in my thesis. Under 'setbacks'.", "Brunel had a cigar habit and a portable bed he took everywhere so he could work all night. Not a role model.", 2200)
    trainer_scaled(z, "brs_harbourmaster", "Harbourmaster Absalom", "Local Legend", "shipwright",
                   [("pierlord", 42), ("greyhaul", 42), ("samsonian", 43), ("heronarch", 42), ("severnshock", 43), ("stoopfalcon", 44)],
                   70, 36, "left",
                   ["Forty years I've run this harbour. I've seen the tall ships come in, the Matthew sail out and a statue go in. I've never seen you beat me.",
                    "Full team, mind. Six. Bristol fashion."],
                   "Well. You'll do. You'll do very nicely.", "Come back when the tall ships are in. You'll never see the harbour so full.", 4800)

    wild(z, [("binfox", 39, 40, 14, {"time": ["dusk", "night"]}), ("cooplet", 38, 40, 16, {}), ("chipgull", 39, 40, 14, {}),
             ("starlet", 39, 40, 10, {"time": ["dusk"]}), ("grizzlet", 38, 40, 12, {}), ("swiftlet", 39, 40, 8, {"season": ["spring", "summer"]}),
             ("peregrin", 40, 40, 4, {"time": ["day"]}), ("flittermouse", 38, 40, 8, {"time": ["night"]}), ("pipkin", 38, 40, 8, {}),
             ("gaugelet", 39, 40, 6, {}), ("stencilette", 40, 40, 3, {"time": ["night"]})])
    wild(z, [("chipgull", 39, 40, 30, {}), ("elverlet", 39, 40, 25, {}), ("stalklet", 39, 40, 20, {}), ("pincray", 39, 40, 25, {})], "water")
    z.d["edges"] = {"south": {"to": "avon_gorge", "offset": 46 - BRISTOL_GAP}}
    z.d["spawn"] = [BRISTOL_GAP + 1, 54]
    done(z)
    z.save(OUT + "/" + zid + ".json")
    sanctuary(OUT, zid, "Bristol", (5, 48), music="sanctuary")
    shop(OUT, zid, "Bristol", (13, 51))
    nurse(zid, ["Alright, my lover? Welcome to Bristol Sanctuary. Pop them on the counter, I'll sort them right out.",
                "There's tea in the pot and a slice of lardy cake if the seagulls haven't had it. Make yourself at home.",
                "There you go, gert lush! Fit as a fiddle, the lot of them. Cheers, drive. Sorry, habit.",
                "The Ark's in the corner, my love. Someone's stuck a little stencil of a gull on it. Nobody owns up.",
                "No bother at all. Mind how you go on the cobbles, they're lethal in the drizzle."])
    shopkeeper(zid, "Alright, my lover! Snares, tea, Somerset cider and a chocolate bar made the old Bristol way. What'll it be?",
               "Cheers, my lover. Mind the gulls on the Harbourside, they've no shame.")

    # interiors
    room("bristol_ssgb", "SS Great Britain: Dining Saloon", zid, ss_door, "museum", 15, 10, [
        ("ssgb_guide", "tour_guide", 7, 2, "down", ssgb_guide())])
    room("bristol_mshed", "M Shed", zid, msh, "museum", 15, 10, [
        ("mshed_curator", "poet", 4, 2, "down", S("Curator",
            "This is Bristol's museum of itself. Trams, buses, Wallace's old shop sign, wartime posters, a whole city in one shed.",
            "That statue lying on its back, covered in paint, is Edward Colston. It was pulled down in June 2020 and fished out of the harbour four days later.",
            "We show it as it was found, with the protest placards, so people can talk about the slave trade and who a city chooses to honour.")),
        ("mshed_historian", "student", 10, 2, "down", S("Historian",
            "Between about 1698 and 1807 Bristol merchants sent ships to West Africa to buy enslaved people, carry them across the Atlantic and sell them.",
            "The ships came home with sugar, tobacco and rum. Much of Georgian Bristol was built on that money. It's a hard history, and it's ours.",
            "Britain abolished the trade in 1807 and slavery in most of its colonies in 1833. Bristolians campaigned on both sides."))])
    room("bristol_market", "St Nicholas Market", zid, market, "cafe", 15, 10, [
        ("market_pieman", "shopkeeper", 3, 3, "up", market_pieman()),
        ("market_cidershop", "villager_5", 11, 3, "down", S("Cider Stall",
            "Cider's been made round here for centuries. Farm workers were once paid partly in cider. Bet that made the afternoons interesting.",
            "Wassailing's in January: you sing to the apple trees, dip toast in cider and hang it in the branches for the robins. Good luck for the harvest."))],
        {"stalls": True})
    room("bristol_trow", "The Llandoger Trow", zid, trow, "cafe", 13, 10, [
        ("trow_landlord", "shopkeeper", 3, 3, "up", trow_landlord())])
    room("bristol_aerospace", "Aerospace Bristol", zid, aero, "museum", 17, 10, [
        ("aero_engineer", "steelworker", 8, 2, "down", aero_engineer())])
    room("bristol_cabot", "Cabot Tower", zid, cab, "castle", 11, 9, [
        ("cabot_keeper", "ravenmaster", 5, 1, "down", S("Tower Keeper",
            "Up you come! Mind the stair, it's narrow. From the top you can see the harbour, the cathedral, and on a clear day the Welsh hills.",
            "John Cabot's real name was Giovanni Caboto. He was from Italy, sailing for the English king. Bristol's always been a port of all sorts."))])
    room("bristol_records", "Record Shop", zid, rec, "library", 13, 10, [
        ("record_seller", "festival_goer", 6, 3, "down", S("Record Seller",
            "Trip-hop, drum and bass, dubstep, punk: they all found a home in Bristol. Something about the hills, the rain and the cheap warehouses.",
            "Massive Attack started out in the Wild Bunch sound system round St Pauls. Portishead named themselves after a town just down the road."))])
    room("bristol_balloonworks", "Balloon Works", zid, balloon_works, "workshop", 13, 9, [
        ("balloon_maker", "shipwright", 6, 3, "down", balloon_maker())])
    room("bristol_cathedral", "Bristol Cathedral", zid, cat, "church", 13, 10, [
        ("cathedral_verger", "choir_singer", 6, 2, "down", S("Verger",
            "Founded as an Augustinian abbey in 1140. The east end is a hall church: aisles as tall as the middle, so the light floods in.",
            "Look for the little stone carvings on the misericords, the choir seats. A man pushing his wife in a wheelbarrow. Medieval humour."))])
    room("bristol_zoo", "Zoo Gardens Lodge", zid, zoo, "museum", 13, 10, [
        ("zoo_keeper", "fox_watcher", 6, 2, "down", S("Retired Keeper",
            "I worked here forty years. Alfred the gorilla came in 1930 and became the most famous resident in Bristol. People sent him birthday cards.",
            "The zoo's moved out now, to a bigger home where the animals have room. These gardens stay open. I still say good morning to the old enclosures."))])
    room("bristol_redcliffe", "St Mary Redcliffe", zid, redcliffe, "church", 13, 10, [
        ("redcliffe_guide", "choir_singer", 6, 2, "down", S("Church Guide",
            "Look up at the roof bosses: over a thousand of them, carved and gilded. One is a maze you could trace with your finger.",
            "There's a whale bone in the church, said to have been brought back by John Cabot. Nobody can prove it. Nobody wants to stop saying it."))])


def ssgb_guide():
    g = "Ship Guide"
    q = {"do": "if", "flag": "q_bristol_brunel_started",
         "then": [{"do": "if", "flag": "q_bristol_brunel_2",
                   "then": S(g, "Back to Temple Meads with that notebook! Prudence will want to hear all about it."),
                   "else": [{"do": "if", "flag": "q_bristol_brunel_1",
                             "then": S(g, "Brunel's notebook? Page two: 'Great Britain. Iron hull. Screw propeller.' He changed his mind from paddle wheels halfway through building her.",
                                       "Paddles were the old way. A screw propeller sits under the water, out of harm's way. The navy took note, I can tell you.",
                                       "There, the ship's stamp. Off to Temple Meads to finish the trail.") +
                                     [{"do": "set", "flag": "q_bristol_brunel_2"}, {"do": "sfx", "id": "item"}],
                             "else": S(g, "Brunel's notebook! But you've skipped a page. Start at the bridge, up the gorge. Brunel would want it done in order.")}]}],
         "else": []}
    return S(g, "Welcome aboard the SS Great Britain! This is the first-class dining saloon. White and gold, pillars, mirrors: very swish.",
             "When she was launched in 1843 she was the longest ship in the world, and the first big iron ship with a propeller to cross the Atlantic.",
             "Down below, the dry dock's sealed under a glass 'sea' so you can walk under her hull. Dry air keeps the old iron from rusting away.") + [q]


def market_pieman():
    g = "Pie Seller"
    return S(g, "Hot pies! Steak and cider, cheese and onion, mushroom! Built for the drizzle.") + [
        {"do": "daily", "key": "bristol_pie_day",
         "then": S(g, "First time today? Have one on the house. Go on, you look peaky.") + [{"do": "give_item", "item": "market_pie"}],
         "else": S(g, "You've had your free one. The stall's got bills to pay, my lover.")}]


def trow_landlord():
    g = "Landlord"
    return S(g, "Welcome to the Llandoger Trow, built 1664. A trow's a flat-bottomed barge from the Severn; a Welsh captain from Llandogo kept this pub.",
             "Legend says Daniel Defoe met Alexander Selkirk here, the castaway who gave him Robinson Crusoe. And it's said to be Stevenson's Spyglass Inn.",
             "Nobody can prove either. We keep the story anyway. Fancy the quiz?") + [
        {"do": "quiz", "pub": "bristol_trow", "region": "england_south", "who": g}]


def aero_engineer():
    g = "Aerospace Engineer"
    fiesta = {"do": "if", "flag": "q_bristol_fiesta_1",
              "then": [{"do": "if", "flag": "q_bristol_fiesta_2",
                        "then": S(g, "Burner valve all right? Tell Gwen she owes me a flight. A slow one."),
                        "else": S(g, "A burner valve for Gwen's balloon? We've built wings for jumbo jets here. I think we can manage a valve.",
                                  "Propane burns at about 2,000 degrees. Heats the air inside the envelope to about 100. Mind your eyebrows.") +
                                [{"do": "set", "flag": "q_bristol_fiesta_2"}, {"do": "sfx", "id": "item"}]}],
              "else": []}
    return S(g, "That's Alpha Foxtrot, the last Concorde ever to fly. She landed at Filton in 2003, right where she was built.",
             "Concorde cruised at Mach 2, twice the speed of sound. The skin got so hot the plane stretched by about 20 centimetres in flight.",
             "Bristol's built aircraft since 1910, when the Bristol Boxkite first flew. Biplanes, airliners, Concorde. Wings still get made round here.") + [fiesta]


def balloon_maker():
    g = "Balloon Maker"
    fiesta = {"do": "if", "flag": "q_bristol_fiesta_started",
              "then": [{"do": "if", "flag": "q_bristol_fiesta_1",
                        "then": S(g, "Envelope's with Gwen? Good. Tell her to stop landing in hawthorn hedges."),
                        "else": S(g, "Gwen's envelope! All patched. Two thousand square metres of rip-stop nylon, and she put a hole in it with a hedge.",
                                  "Quick question before I hand it over: why does a hot-air balloon go up?") +
                                [{"do": "choice", "text": "Why does a hot-air balloon rise?",
                                  "options": ["Hot air is less dense", "The burner pushes it", "The basket is light"], "set": "_bristol_balloon_q"},
                                 {"do": "if", "flag": "_bristol_balloon_q", "eq": 0,
                                  "then": S(g, "Spot on! Hot air spreads out, so the envelope's full of air lighter than the air around it. It floats, like a cork in water.") +
                                          [{"do": "set", "flag": "q_bristol_fiesta_1"}, {"do": "sfx", "id": "item"},
                                           {"do": "say", "who": "", "text": "You received Gwen's balloon envelope. It's enormous, and somehow fits in the bag."}],
                                  "else": S(g, "Not quite! Think about what happens when you heat air. Try me again.")}]}],
              "else": []}
    return S(g, "Bristol's been making hot-air balloons since the 1960s. A lot of the world's balloons were stitched round here.",
             "The first people to fly in one went up over Paris in 1783, in a balloon made by the Montgolfier brothers. Paper and silk, and a straw fire.") + [fiesta]


def brunel_giver():
    g = "Engineer Prudence"
    quiz = ([{"do": "choice", "text": "Prudence's question: why did Brunel use a broad gauge?",
              "options": ["Faster, smoother trains", "It was cheaper", "The Queen asked him"], "set": "_bristol_brunel_q"},
             {"do": "if", "flag": "_bristol_brunel_q", "eq": 0,
              "then": S(g, "Exactly! Seven feet and a quarter of an inch between the rails. Wider track, steadier carriages, higher speeds.",
                        "He was right, too. It just lost the argument: most lines were already narrower. In 1892 the whole Great Western was changed over in one weekend.",
                        "Here. You've earned the notebook, and a little friend from the engine sheds who's been following me about all week.") +
                      [{"do": "give_item", "item": "brunels_top_hat"},
                       {"do": "give_creature", "species": "gaugelet", "level": FLOOR},
                       {"do": "standing", "nation": "england", "amount": 2},
                       {"do": "set", "flag": "q_bristol_brunel_3"}, {"do": "set", "flag": "q_bristol_brunel_done"}],
              "else": S(g, "Not quite. Think of the trains themselves. Have another go.")}])
    return [{"do": "if", "flag": "q_bristol_brunel_done",
             "then": S(g, "Isambard Kingdom Brunel: bridges, tunnels, railways, ships. Died at 53. Did more than most would in three lifetimes."),
             "else": [{"do": "if", "flag": "q_bristol_brunel_2",
                       "then": S(g, "Two stamps! The bridge and the ship. Last page is right here: Temple Meads, his station.",
                                 "He designed the whole line from London, the Great Western Railway, with this old station at the Bristol end. One last question.") + quiz,
                       "else": [{"do": "if", "flag": "q_bristol_brunel_started",
                                 "then": S(g, "First page: the Clifton Suspension Bridge, up the Avon Gorge. Then the SS Great Britain, at the harbour. Then back here."),
                                 "else": S(g, "Brunel! Isambard Kingdom Brunel! Greatest engineer Britain ever had. I've found a copy of his notebook. Well, a facsimile.",
                                           "Fancy following his trail? The bridge, the ship and this very station. Get each page stamped and come back.") +
                                         [{"do": "set", "flag": "q_bristol_brunel_started"},
                                          {"do": "say", "who": "", "text": "Prudence hands you a battered copy of Brunel's notebook."}]}]}]}]


def art_giver():
    g = "Gallery Keeper Saffron"
    all4 = {"do": "if", "flag": "q_bristol_art_4", "then": [
        {"do": "if", "flag": "q_bristol_art_3", "then": [
            {"do": "if", "flag": "q_bristol_art_2", "then": [
                {"do": "if", "flag": "q_bristol_art_1", "then": [
                    {"do": "if", "flag": "q_bristol_art_5",
                     "then": S(g, "You found all four AND met the painter? Nobody meets the painter! Here, from the gallery. Keep it quiet.") +
                             [{"do": "give_item", "item": "bristol_chocolate", "n": 3}, {"do": "give_item", "item": "silver_snare", "n": 5},
                              {"do": "standing", "nation": "england", "amount": 2}, {"do": "set", "flag": "q_bristol_art_done"}],
                     "else": S(g, "All four! Brilliant. Now, the painter always comes back to check on new work. Tonight, round the back of Jamaica Street.",
                               "Don't ask their name. Just... say hello. They like a challenge.")}],
                 "else": []}], "else": []}], "else": []}], "else": []}
    return [{"do": "if", "flag": "q_bristol_art_done",
             "then": S(g, "Another new piece went up on Picton Street last night. Nobody saw a thing. They never do."),
             "else": [{"do": "if", "flag": "q_bristol_art_started",
                       "then": S(g, "Four new pieces round Stokes Croft and St Pauls. Find them all and come back to me.") + [all4],
                       "else": S(g, "Someone's been painting again. Four new pieces overnight, all signed with a little spray can. Nobody knows who.",
                                 "Fancy a treasure hunt? Find all four round Stokes Croft and Picton Street, take a good look, and come and tell me.") +
                               [{"do": "set", "flag": "q_bristol_art_started"}]}]}]


def art_piece(what, extra, n):
    return ([{"do": "say", "who": "", "text": "Painted on the wall: " + what + "."},
             {"do": "say", "who": "", "text": extra}] +
            [{"do": "if", "flag": "q_bristol_art_started",
              "then": [{"do": "if", "flag": "q_bristol_art_%d" % n, "then": [],
                        "else": [{"do": "set", "flag": "q_bristol_art_%d" % n}, {"do": "sfx", "id": "item"},
                                 {"do": "say", "who": "", "text": "You make a note of it for Saffron. (Piece %d of 4.)" % n}]}],
              "else": []}])


def crew_chief():
    g = "Crew Chief Bex"
    return [{"do": "if", "flag": "q_bristol_fiesta_3",
             "then": S(g, "Crew's ready when Gwen is. Gloves on, hats on, and nobody hold on to the rope when she lifts."),
             "else": [{"do": "if", "flag": "q_bristol_fiesta_2",
                       "then": S(g, "Gwen wants a ground crew? We're the best in Bristol. But we only work for someone who can beat me. Ready?") +
                               [{"do": "battle", "trainer": "brs_crew_chief", "intro": True},
                                {"do": "set", "flag": "q_bristol_fiesta_3"}] +
                               S(g, "Right, crew! Up to Ashton Court! We'll meet you at Gwen's basket."),
                       "else": S(g, "Balloon crew, us. We hold the ropes, fill the envelope with a big fan and chase the balloon across Somerset in a van.",
                                 "Best job in the world. Worst job in a hedge.")}]}]


def night_painter():
    pass


def build():
    avon_gorge()
    bristol()
    scaled_trainer_def("brs_crew_chief", "Crew Chief Bex", "Balloon Crew", "festival_goer",
                       [("forkwing", 40), ("stormswift", 40), ("emberdrey", 41)],
                       ["Ropes, gloves, flask. Let's see what you're made of."],
                       "Fair's fair. We'll crew for Gwen.", "Up, up and away. Then down, down and in a field.", 2400)
    # the night painter: only out once the hunt's four pieces are found, at night
    painter = {"id": "night_painter", "sprite": "festival_goer", "x": 60, "y": 9, "facing": "down", "move": "still",
               "script": "night_painter", "show_if": "q_bristol_art_4", "hide_if": "q_bristol_art_5"}
    z = json.load(open(OUT + "/bristol.json"))
    z["npcs"].append(painter)
    json.dump(z, open(OUT + "/bristol.json", "w"), indent=1)
    scaled_trainer_def("brs_night_painter", "The Night Painter", "Street Artist", "festival_goer",
                       [("hushwing", 41), ("binfox", 41), ("stencilette", 42)],
                       ["...", "You found them all. Nobody finds them all. Fine. One battle, then you never saw me."],
                       "Good. Now look the other way for ten seconds.", "Gone.", 3000)
    DLG["bristol"]["night_painter"] = ([{"do": "when", "cond": "night",
                                        "then": [{"do": "battle", "trainer": "brs_night_painter", "intro": True},
                                                 {"do": "set", "flag": "q_bristol_art_5"},
                                                 {"do": "say", "who": "", "text": "When you look back, there's only a fresh stencil of a spray can on the wall, still wet."}],
                                        "else": S("Hooded Figure", "Not now. Come back after dark.")}])
    # interiors
    for zid, name, town, door, kind, w, h, npcs, extra in INTERIORS:
        if door is None:  # Giant's Cave: down the Observatory's tunnel
            continue
        ret = (door[0], door[1] + 1)
        nl = []
        for nid, spr, x, y, facing, cmds in npcs:
            nl.append(dict(id=nid, sprite=spr, x=x, y=y, facing=facing, move="still", script=nid))
            DLG.setdefault(zid, {})[nid] = cmds
        zz = landmark(OUT, zid, name, town, ret, kind, nl, w=w, h=h, write=False)
        if extra.get("stalls"):
            for (x, y) in [(2, 5), (4, 5), (10, 5), (12, 5)]:
                if zz.g[y][x] == "|" and not any(p["x"] == x and p["y"] == y for p in zz.d["props"]):
                    zz.prop("market_stall", x, y, variant=x % 3)
        if extra.get("cave_door"):
            zz.set(w - 2, 3, "D")
            zz.warp(w - 2, 3, "avon_gorge_giants_cave", 5, 6, "right")
            zz.d["props"] = [p for p in zz.d["props"] if not (p["x"] in (w - 2, w - 3) and p["y"] in (3, 4))]
        zz.save(OUT + "/" + zid + ".json")
        door_warp_json(town, door, zid, w, h)
    # Giant's Cave: a dark room off the Observatory, exit back up the tunnel
    for zid, name, town, door, kind, w, h, npcs, extra in INTERIORS:
        if door is not None:
            continue
        nl = []
        for nid, spr, x, y, facing, cmds in npcs:
            nl.append(dict(id=nid, sprite=spr, x=x, y=y, facing=facing, move="still", script=nid))
            DLG.setdefault(zid, {})[nid] = cmds
        zz = landmark(OUT, zid, name, "avon_gorge_observatory", (13 - 3, 3), kind, nl, w=w, h=h, write=False)
        zz.d["dark"] = True
        zz.save(OUT + "/" + zid + ".json")
    for t in TRN.values():
        t["scaled_floor"] = FLOOR
    write_all(OUT)
    open_bath()
    import add_memory_coach
    add_memory_coach.main(OUT)


def door_warp_json(town, door, zid, w, h):
    path_ = OUT + "/" + town + ".json"
    d = json.load(open(path_))
    d["warps"] = [p for p in d["warps"] if not (p["x"] == door[0] and p["y"] == door[1])]
    d["warps"].append({"x": door[0], "y": door[1], "to": zid, "tx": w // 2, "ty": h - 3, "facing": "up"})
    json.dump(d, open(path_, "w"), indent=1, ensure_ascii=False)


def open_bath():
    """a lane north out of Bath, past the Royal Crescent, to the gorge (x 20 to 22), and a fingerpost."""
    p = OUT + "/bath.json"
    d = json.load(open(p))
    rows = [list(r) for r in d["rows"]]
    for y in (0, 1):
        for x in (20, 21, 22):
            rows[y][x] = "."
        rows[y][21] = "#"
    rows[2][21] = "#"
    d["rows"] = ["".join(r) for r in rows]
    hs = [list(r) for r in d["heights"]]
    for y in (0, 1):
        for x in (20, 21, 22):
            hs[y][x] = hs[2][x]  # level with the lane, the Crescent's terrace
    d["heights"] = ["".join(r) for r in hs]
    d["edges"]["north"] = {"to": "avon_gorge", "offset": 0}
    if not any(s.get("x") == 23 and s.get("y") == 2 for s in d["signs"]):
        d["signs"].append({"x": 23, "y": 2, "text": "FOOTPATH. North to the Avon Gorge, Clifton and Bristol. Twelve miles, give or take a goat."})
    json.dump(d, open(p, "w"), indent=1, ensure_ascii=False)


build()
