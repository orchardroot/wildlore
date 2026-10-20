# Wider Isles (3.0), region R3: the Lancashire coast, north of Liverpool.
#   sefton_coast: Crosby's iron men, Formby's pines, squirrels, dunes and asparagus, Southport's pier and Lord Street,
#                 Martin Mere's swans. Joins Liverpool's new north exit (the Dock Road) to Blackpool.
#   blackpool:    the Tower and its Ballroom, the Illuminations, three piers, the trams, the Pleasure Beach and the Big One,
#                 donkeys, rock, chips, the Winter Gardens and Bloomfield Road. A cul-de-sac with a station.
# Both are off the main line: encounters and trainers are scaled from par 18 (Liverpool's band).
#   python3 tools/zones/lancashire.py data/zones
import sys, os, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ie_common import *
from wcommon import _stand, DLG, TRN
from zlib import landmark

FLOOR = 18
MER = "merseyside"   # Sefton is a borough of Merseyside
LAN = "lancashire"
SHOPS = []


def plaque(z, x, y, pid, title, text):
    _stand(z, x, y)
    z.d["signs"].append({"x": x, "y": y, "text": text, "plaque": pid, "title": title})


def npc(z, **kw):
    _stand(z, kw["x"], kw["y"])
    kw.setdefault("facing", "down")
    kw.setdefault("move", "still")
    z.npc(**kw)


def lines(who, *ts):
    return say(who, *ts)


def setf(flag, value=True):
    return {"do": "set", "flag": flag, "value": value}


def iff(flag, then, other=None):
    c = {"do": "if", "flag": flag, "then": then}
    if other is not None:
        c["else"] = other
    return c


def give(item, n=1):
    return {"do": "give_item", "item": item, "n": n}


def standing(n):
    return {"do": "standing", "nation": "england", "amount": n}


def scaled_trainer(z, tid, name, cls, sprite, party, x, y, facing, intro, win, after, money, move="still", **extra):
    trainer(z, tid, name, cls, sprite, party, x, y, facing, intro, win, after, money, move)
    TRN[tid]["scaled_floor"] = FLOOR
    TRN[tid].update(extra)


def quest_trainer(tid, name, cls, sprite, party, intro, win, after, money, **extra):
    """a trainer fought from a quest script (no NPC of its own)."""
    TRN[tid] = {"id": tid, "name": name, "class": cls, "sprite": sprite,
                "party": [{"species": s, "level": l} for s, l in party], "ai": "trainer", "money": money,
                "intro": say(name, *intro), "win": win, "after": after, "scaled_floor": FLOOR}
    TRN[tid].update(extra)


def room(OUT, zid, name, town, ret, kind, npcs, w=13, h=10, extra_props=(), legend=None, rows=None, music="", drop=()):
    """a landmark() interior plus our own dressing; NPC dicts are passed straight through. `drop`: prop types of the
    kind's stock furniture to leave out."""
    z = landmark(OUT, zid, name, town, ret, kind, npcs, w, h, furnish=False, write=False)
    z.d["props"] = [q for q in z.d["props"] if q["type"] not in drop]
    if rows:
        for (x, y, ww, hh, ch) in rows:
            z.rect(x, y, ww, hh, ch)
    if legend:
        z.legend.update(legend)
    occupied = {(n["x"], n["y"]) for n in npcs}
    for p in extra_props:
        z.d["props"] = [q for q in z.d["props"] if not (q["x"] == p["x"] and q["y"] == p["y"] and not p.get("walk"))]
        if (p["x"], p["y"]) not in occupied or p.get("walk"):
            z.d["props"].append(p)
    import furnish as _furnish
    z.d["props"].extend(_furnish.furnish(kind, name, zid, ["".join(r) for r in z.g], z.d["props"], z.d["npcs"], z.d["warps"], z.d["spawn"]))
    if music:
        z.d["music"] = music
    z.save(OUT + "/" + zid + ".json")
    return z


def P(t, x, y, **kw):
    d = {"type": t, "x": x, "y": y}
    d.update(kw)
    return d


# =====================================================================================================
# Sefton coast
# =====================================================================================================
def sefton(OUT):
    W, H = 56, 104
    zid = "sefton_coast"
    z = Z(zid, "Sefton Coast", W, H, kind="route", region=MER, music="route_coast",
          weather={"clear": 26, "sunshine": 22, "drizzle": 22, "gale": 18, "fog": 8, "downpour": 4})
    z.d["stage"] = "coast"
    z.d["scaled_floor"] = FLOOR
    z.legend["d"] = {"tile": "tall_grass", "colour": "#c9b96d"}             # marram dunes
    z.legend["a"] = {"tile": "tall_grass", "colour": "#6f8f3a", "prop": "short"}  # asparagus rows
    z.legend["r"] = {"tile": "shallow", "prop": "reeds"}
    z.legend["k"] = {"tile": "grass", "colour": "#6d8048"}
    z.rect(0, 0, W, H, ".")
    z.border("T", 2)
    # the sea on the west: wide at Crosby, narrower going north
    def edge(y):
        return 14 if y >= 76 else (10 if y >= 40 else 8)
    for y in range(H):
        e = edge(y)
        for x in range(0, e):
            z.set(x, y, "$" if x < e - 2 else "w")
        for x in range(e, e + (14 if y >= 76 else 4)):
            z.set(x, y, "s")
    # ---------------- Crosby (south) ----------------
    z.rect(28, 76, 2, 26, "#")          # the coastal path
    z.rect(30, 98, 12, 2, "#")
    z.rect(38, 78, 3, 26, "=")          # the road up from Liverpool's Dock Road
    z.rect(30, 78, 9, 2, "#")
    z.rect(41, 80, 13, 22, "k")
    z.building(43, 84, 5, 3, "terrace", "Crosby Terrace", show_label=False)
    z.building(49, 84, 4, 3, "terrace", show_label=False)
    z.building(43, 92, 9, 3, "red_brick", "Crosby Coastguard Station", door=4)
    z.warp(47, 94, "crosby_coastguard", 6, 7, "up")
    z.prop("flagpole", 52, 95, variant=0)
    for y in range(80, 102, 4):
        z.prop("lamp_post", 30, y)
    z.prop("bench", 30, 86); z.prop("bench", 30, 94)
    # Another Place: iron men across the sand and into the shallows, all facing out to sea
    men = [(16, 78), (19, 81), (23, 83), (13, 85), (17, 87), (21, 89), (25, 91), (14, 92), (18, 95), (22, 97),
           (12, 99), (16, 101), (25, 86), (20, 93), (26, 99), (12, 80)]
    for (x, y) in men:
        z.prop("statue", x, y, variant=3, rot=-90)
    plaque(z, 27, 88, "lancashire_another_place", "Another Place",
           "ANOTHER PLACE. A hundred cast-iron men stand along about three kilometres of Crosby beach, every one cast from the artist's own body, "
           "all gazing out to sea. They came here in 2005 for a few months and the town liked them so much they stayed for good in 2007. "
           "The tide covers some of them twice a day, and the barnacles have given several a beard.")
    plaque(z, 31, 80, "lancashire_crosby_mersey", "The Mouth of the Mersey",
           "CROSBY AND THE MERSEY. From this beach you watch the big ships slide into the Mersey on the tide, and on a clear day you can see "
           "the hills of North Wales and the wind turbines out at sea. The sand here is fine and the mud is finer: keep to the firm stuff.")
    z.sign(36, 101, "SOUTH: Liverpool, along the Dock Road. NORTH: Formby's pinewoods and Southport. Much further north: Blackpool, and the lights.")
    # ---------------- Formby (middle) ----------------
    # dunes and their wet slacks, where the natterjacks call
    z.rect(14, 40, 12, 36, "d")
    for (cx, cy, rx, ry) in [(18, 48, 2, 1.5), (21, 58, 2.5, 1.5), (17, 67, 2, 1.5), (22, 72, 1.5, 1)]:
        blob(z, cx, cy, rx, ry, "w", only="d", seed=cx * 7 + cy, jitter=0.2)
    z.rect(14, 62, 12, 1, "s")
    # the pinewoods, with sandy paths and clearings
    z.rect(26, 40, 21, 36, "P")
    z.rect(28, 40, 2, 36, "#")
    z.rect(30, 52, 16, 2, "#"); z.rect(30, 66, 17, 2, "#")
    z.rect(38, 44, 2, 30, "#")
    for (cx, cy, rx, ry) in [(34, 47, 3, 2.5), (43, 58, 3, 3), (33, 60, 3, 2.5), (43, 71, 3, 2)]:
        blob(z, cx, cy, rx, ry, ",", only="P", seed=cx + cy, jitter=0.3)
    z.scatter(26, 40, 21, 36, "T", 25, 31, only="P")
    z.rect(30, 59, 1, 2, ",")   # a way into the western clearing
    # the asparagus fields east of the woods
    z.rect(47, 44, 7, 18, "#")
    for y in range(45, 61, 2):
        z.rect(48, y, 6, 1, "a")
    z.rect(47, 66, 7, 2, "#")
    z.prop("field_gate", 47, 62)
    z.building(48, 62, 5, 3, "field_barn", show_label=False)
    plaque(z, 27, 50, "lancashire_formby_pines", "Formby's Pinewoods",
           "FORMBY'S PINEWOODS. The pines were planted from the late 1800s to hold the shifting dunes still, and they became one of the last "
           "strongholds of the red squirrel in England. In 2008 squirrelpox, carried by grey squirrels, killed most of them. Rangers and "
           "volunteers kept the greys out, and the reds have been coming back ever since.")
    plaque(z, 13, 55, "lancashire_formby_footprints", "Prehistoric Footprints",
           "FOOTPRINTS IN THE MUD. When the sea scours the beach at Formby Point it uncovers layers of ancient mud printed with footprints "
           "thousands of years old: people, children, red deer, aurochs and wading birds, walking the shore of a world before farming. "
           "Each set is washed away again within days, so the beach keeps a diary nobody can keep.")
    plaque(z, 46, 63, "lancashire_formby_asparagus", "Formby Asparagus",
           "FORMBY ASPARAGUS. The light, sandy soil here once grew asparagus by the cartload, sent off on the railway to the dining cars "
           "and grand hotels. Most of the fields have gone back to dune and pine, but a few local growers still cut the spears each spring, "
           "in a season of only about eight weeks.")
    plaque(z, 25, 70, "lancashire_natterjack_slacks", "The Dune Slacks",
           "THE DUNE SLACKS. The hollows between the dunes flood in winter and dry out in summer: just right for natterjack toads, which "
           "need warm, shallow pools with no fish in them. On a spring night the males all call at once, a rattling chorus you can hear "
           "a kilometre away. They run, rather than hop, on short little legs.")
    z.sign(29, 77, "FORMBY. Red squirrels, please do not feed them crisps. National Trust rangers this way.")
    # ---------------- Southport (north) ----------------
    # the promenade and the long pier, with the sea a long way out
    z.rect(12, 0, 3, 40, ":")
    z.rect(12, 38, 34, 2, ":")
    z.rect(1, 14, 12, 2, ":")
    z.rect(5, 13, 8, 1, "F"); z.rect(5, 16, 8, 1, "F")
    z.building(1, 11, 4, 3, "pier_pavilion", "Southport Pier Pavilion", show_label=True)
    for y in range(2, 38, 6):
        z.prop("lamp_post", 15, y)
    plaque(z, 15, 13, "lancashire_southport_pier", "Southport Pier",
           "SOUTHPORT PIER. Opened in 1860, it is one of the oldest iron piers in Britain and, at over a kilometre, the second longest after "
           "Southend's. The joke is that the sea at Southport is shy: at low tide it goes out so far that the end of the pier stands over sand, "
           "and visitors have been known to ask where the sea has gone.")
    # Lord Street: a tree-lined boulevard, shops under iron-and-glass verandas
    z.rect(26, 0, 3, 38, "=")
    z.rect(18, 2, 8, 34, ":")
    z.rect(29, 2, 7, 34, ":")
    shops = [(19, 3, 6, 3, "Lord Street Arcade"), (19, 9, 6, 3, "Lord Street Tea Rooms"), (19, 15, 6, 3, "Wayfarers Books"),
             (19, 21, 6, 3, None), (19, 27, 6, 3, "Southport Gifts"), (30, 3, 6, 3, None), (30, 9, 6, 3, "Atkinson Gallery"),
             (30, 15, 6, 3, None), (30, 21, 6, 3, "Lord Street Bandstand Cafe"), (30, 27, 6, 3, None)]
    for (x, y, w, h, label) in shops:
        if label == "Lord Street Tea Rooms":
            z.building(x, y, w, h, "veranda_shop", label, door=3)
            z.warp(x + 3, y + h - 1, "southport_tearooms", 6, 7, "up")
        elif label == "Atkinson Gallery":
            z.building(x, y, w, h, "white_render", label, door=3)
            z.warp(x + 3, y + h - 1, "southport_atkinson", 6, 7, "up")
        elif label:
            z.building(x, y, w, h, "veranda_shop", label)
        else:
            z.building(x, y, w, h, "veranda_shop", show_label=False)
    for y in range(4, 36, 4):
        z.prop("oak", 25, y, variant=y % 3)
        z.prop("oak", 29, y + 2, variant=(y + 1) % 3)
    z.prop("lamp_post", 25, 34); z.prop("lamp_post", 29, 36)
    z.prop("flower_patch", 24, 37); z.prop("planter", 30, 37)
    plaque(z, 25, 6, "lancashire_lord_street", "Lord Street",
           "LORD STREET. Southport's grand boulevard, a mile of shops behind iron-and-glass verandas, with gardens and trees down the middle. "
           "Local legend says the future Emperor Napoleon III lodged near here in the 1840s and took the idea home for the boulevards of Paris. "
           "Historians shrug. Southport does not.")
    plaque(z, 29, 24, "lancashire_southport_flowers", "Southport Flower Show",
           "SOUTHPORT FLOWER SHOW. Every August since 1924, apart from the war years, Victoria Park fills with marquees for one of the "
           "biggest independent flower shows in Britain. Next door, Royal Birkdale's links have hosted golf's Open Championship many times.")
    # Martin Mere: wetland, reeds and the hide
    z.rect(37, 2, 17, 34, "k")
    blob(z, 46, 18, 7, 9, "w", only="k", seed=11, jitter=0.25)
    blob(z, 46, 18, 4, 6, "~", only="w", seed=12, jitter=0.25)
    blob(z, 40, 28, 3, 2.5, "r", only="kw", seed=13, jitter=0.3)
    blob(z, 51, 9, 2.5, 3, "r", only="kw", seed=14, jitter=0.3)
    z.rect(36, 6, 2, 33, "#")
    z.rect(38, 6, 3, 1, "#")
    z.building(39, 3, 6, 3, "field_barn", "Martin Mere Hide", door=3)
    z.warp(42, 5, "martin_mere_hide", 6, 7, "up")
    z.building(46, 3, 7, 3, "slate_cottage", "Wetland Visitor Centre", show_label=True)
    z.rect(41, 6, 1, 1, "#")
    plaque(z, 37, 20, "lancashire_martin_mere", "Martin Mere",
           "MARTIN MERE. This was once one of the largest lakes in England, until it was drained for farmland from the 1690s. Since 1975 it "
           "has been a wetland reserve again, and each autumn thousands of whooper swans fly in from Iceland, with tens of thousands of "
           "pink-footed geese, to spend the winter here. The swans are fed in front of the hide on winter afternoons, and they know the time.")
    # paths joining it all up
    z.rect(28, 38, 2, 2, "#")
    z.rect(14, 40, 16, 1, "#")
    # NPCs: locals who teach
    chat(z, "sef_crosby_walker", "villager_3", 31, 90, "Dog Walker",
         ["I walk Biscuit past the iron men every morning. He used to bark at them. Now he says hello to his favourite, third from the left.",
          "People dress them up, you know. Scarves, bobble hats, an Everton shirt, a Liverpool shirt the next day. The iron men stay neutral."],
         "left", "wander")
    chat(z, "sef_shipwatcher", "sailor", 30, 82, "Ship Spotter",
         ["That's the Belfast boat going out, and the big container ship's waiting for the tide. Liverpool's docks still handle more than "
          "most people think, just with fewer men and more cranes.",
          "Ships here wait on the tide. The Mersey has one of the biggest tidal ranges in Britain, near enough ten metres on a spring tide."],
         "left", "still")
    chat(z, "sef_asparagus", "farmer", 50, 66, "Asparagus Grower",
         ["Formby asparagus, best in the land. We cut it from late April to midsummer, then we stop and let the plants grow up into ferny bushes so they've strength for next year.",
          "My great-grandad sent his down the line to the Pullman cars. Now I sell it from a table at the gate with an honesty box. Mostly honest."],
         "down", "still")
    chat(z, "sef_sandgrounder", "villager_6", 33, 30, "Southport Local",
         ["Sandgrounder, me. That's what you call someone born in Southport. Blackpool has sandgrown'uns. We have sandgrounders. Completely different. Don't ask how.",
          "Lord Street's verandas were put up so the Victorian ladies could shop without getting their hats wet. It still rains. The verandas still work."],
         "left", "wander")
    chat(z, "sef_swan_warden", "birdwatcher", 38, 12, "Swan Warden",
         ["The whoopers come in October from Iceland, a thousand miles, some in a single flight. You hear them before you see them: they honk like a brass band tuning up.",
          "Whooper swans have a yellow wedge on the bill. Mute swans have orange, and they're the ones in the park that hiss at your sandwich."],
         "right", "still")
    # the squirrel survey: the ranger, four red squirrels to count, and a natterjack to catch
    npc(z, id="sef_ranger", sprite="ghillie", x=32, y=54, facing="down", script="sef_ranger", name="Ranger Hughes")
    for i, (x, y) in enumerate([(34, 47), (43, 57), (32, 61), (44, 71)]):
        k = "abcd"[i]
        npc(z, id="sef_squirrel_" + k, sprite="creature:kindlet", x=x, y=y, facing="down", move="still",
            script="sef_squirrel_" + k, name="Red Squirrel", show_if="q_lancashire_squirrels_started", hide_if="lancashire_sq_" + k)
        others = [f for f in "abcd" if f != k]
        script(zid, "sef_squirrel_" + k, [
            {"do": "say", "who": "", "text": [
                "A red squirrel freezes on a pine trunk, tufted ears up, then scolds you with a noise like a tiny wet engine.",
                "A red squirrel sits up with a pine cone, strips it scale by scale, and drops the core on your head. Counted.",
                "A red squirrel runs along a branch, stops, flicks its tail three times and vanishes into its drey. Counted.",
                "A red squirrel buries a hazelnut, looks at you, digs it up and buries it somewhere else. It doesn't trust you. Counted."][i]},
            setf("lancashire_sq_" + k),
            iff("lancashire_sq_" + others[0], [iff("lancashire_sq_" + others[1], [iff("lancashire_sq_" + others[2], [
                setf("q_lancashire_squirrels_1"),
                {"do": "say", "who": "", "text": "That's four red squirrels counted. Ranger Hughes will want the tally."}])])])])
    npc(z, id="sef_natterjack", sprite="creature:natterjack", x=21, y=58, facing="down", script="sef_natterjack", name="Natterjack",
        show_if="q_lancashire_squirrels_1", hide_if="q_lancashire_squirrels_2")
    script(zid, "sef_natterjack", [
        {"do": "say", "who": "", "text": "A natterjack sits in the warm shallows, yellow stripe down its back, throat swelling for a call. Catch it for the survey?"},
        {"do": "choice", "text": "Catch the natterjack for the survey?", "options": ["Go on then", "Leave it be"], "set": "_lancs_toad"},
        iff("_lancs_toad", [{"do": "say", "who": "", "text": "Off it runs. It's quicker than it looks."}],
            [{"do": "legend", "species": "natterjack", "level": 20, "flag": "q_lancashire_squirrels_2", "music": "battle_wild"},
             iff("q_lancashire_squirrels_2", [{"do": "say", "who": "", "text": "Got it. Ranger Hughes will want to see it before it goes back in the slack. Well, before you keep it, anyway."}],
                 [{"do": "say", "who": "", "text": "It's slipped off into the reeds. There'll be another chance: natterjacks don't go far from their slack."}])])])
    script(zid, "sef_ranger", [
        iff("q_lancashire_squirrels_done",
            say("Ranger Hughes", "Thanks again. Your squirrel count's gone into the national survey, and the toad's in the record book. You're an honorary ranger, near enough. No hat, though. Hats are earned."),
            [iff("q_lancashire_squirrels_2",
                 say("Ranger Hughes", "Four reds and a natterjack! That's a proper survey, that. Natterjacks are one of Britain's rarest amphibians, and this coast holds a big share of them.",
                     "Here, for your trouble. An acorn from the old oak by the car park, and a bit of my lunch.") +
                 [give("oak_acorn"), give("potted_shrimps", 2), standing(4), setf("q_lancashire_squirrels_done")],
                 [iff("q_lancashire_squirrels_1",
                      say("Ranger Hughes", "Four reds! Grand. Now the dunes. We need one natterjack checked for the survey: try the warm slack in the middle of the dunes, west of here. They run, they don't hop, so be quick."),
                      [iff("q_lancashire_squirrels_started",
                           say("Ranger Hughes", "Still counting? There are four reds out there today: try the clearings either side of the paths. Look up. They're always above you, judging."),
                           say("Ranger Hughes", "Afternoon! National Trust ranger. We're doing the red squirrel count, and I'm one pair of eyes short.",
                               "Formby's reds nearly vanished in 2008, when squirrelpox came through. Greys carry it without getting ill. Reds catch it and die. We've spent years since keeping the greys out.",
                               "Fancy helping? Count four reds in the pinewoods for me. Then there's a toad job. You'll love the toad job.") +
                           [setf("q_lancashire_squirrels_started")])])])])])
    # Southport pier keeper: the spare bulbs for the Illuminations
    npc(z, id="sef_pier_keeper", sprite="fisherman_north", x=3, y=15, facing="right", script="sef_pier_keeper", name="Pier Keeper")
    script(zid, "sef_pier_keeper", [
        iff("q_lancashire_lights_2",
            say("Pier Keeper", "Did Doreen get her bulbs? Tell her she owes me a fish supper. She's owed me one since 1997."),
            [iff("q_lancashire_lights_1",
                 say("Pier Keeper", "Doreen sent you? From the Illuminations depot? Of course she did. Here's her crate of spare bulbs. Every year they run short, every year she sends someone up the coast to me.",
                     "Mind how you carry it. Some of those bulbs are older than the trams. Not the 1885 trams. The other ones.") +
                 [setf("q_lancashire_lights_2"), {"do": "say", "who": "", "text": "You take the crate of spare bulbs. It clinks."}],
                 say("Pier Keeper", "Welcome to the end of Southport Pier. The sea's out. It's usually out. Give it an hour and it'll come rushing in faster than you'd believe, so don't go wandering on the sands.",
                     "There used to be a little train along the pier. Folk rode it to the end, looked at the sand, and rode back. Lovely day out."))])])
    # the lost donkey, if she has wandered this far: eating the asparagus
    npc(z, id="sef_donkey", sprite="creature:donkey", x=51, y=53, facing="left", move="wander", script="sef_donkey", name="Bramble",
        show_if="q_lancashire_donkey_1", hide_if="q_lancashire_donkey_2")
    script(zid, "sef_donkey", [
        {"do": "say", "who": "", "text": "A small grey donkey with a red brow-band stands in the asparagus rows, chewing with enormous satisfaction. The name stitched on the band says BRAMBLE."},
        {"do": "say", "who": "Asparagus Grower", "text": "Is she yours? She's had half a row. Go on, take her home. Tell Jack she owes me a fiver and a ride for my granddaughter."},
        {"do": "say", "who": "", "text": "You scratch Bramble behind her long ears. She decides you're acceptable and sets off north along the sands, back towards Blackpool, at a steady donkey pace."},
        setf("q_lancashire_donkey_2")])
    # trainers
    scaled_trainer(z, "sef_kitesurfer", "Kitesurfer Jade", "Kitesurfer", "surfer",
                   [("swiftlet", 18), ("chipgull", 19), ("pupplash", 19)], 27, 95, "left",
                   ["The wind's straight off the Irish Sea today. Perfect! For me. For you, it's a face full of sand. Let's go!"],
                   "Wiped out! Fair play. The sea always wins in the end, though.",
                   "I once got dragged a hundred metres past the iron men. They didn't even look round.", 820)
    scaled_trainer(z, "sef_jogger", "Jogger Callum", "Jogger", "jogger",
                   [("scuttlet", 18), ("duneskink", 19), ("starlet", 19)], 28, 72, "down",
                   ["Formby parkrun PB attempt! Out of my way! Or battle me, that counts as interval training."],
                   "Ah, that's my PB gone. Worth it.", "Running on sand is twice the effort for half the distance. I'm basically training for nothing.", 780, move="still")
    scaled_trainer(z, "sef_birder", "Birdwatcher Margaret", "Birdwatcher", "birdwatcher",
                   [("stalklet", 19), ("starlet", 18), ("cranelet", 20)], 37, 30, "right",
                   ["Shh! There's a whooper on the mere. Oh, it's flown. Well, now you'll have to battle me instead."],
                   "Goodness. I'll put you in my notebook: 'one trainer, uncommon, very strong'.", "Nine thousand swans one winter. I counted every one. Twice.", 840)
    scaled_trainer(z, "sef_angler", "Angler Ste", "Angler", "angler",
                   [("pinchkin", 19), ("pupplash", 18), ("chipgull", 20)], 9, 15, "left",
                   ["Fishing off the end of Southport Pier, me. I've caught three crabs and a sandwich bag. Fancy a battle while the tide thinks about it?"],
                   "Reeled in, me. Fair enough.", "The tide's coming in now. You'll want to be off the sands, mind. It comes in faster than a horse can gallop, they say.", 800)
    scaled_trainer(z, "sef_dunewalker", "Dune Walker Pat", "Hiker", "hiker",
                   [("natterjack", 19), ("zigzlet", 19), ("scuttlet", 18)], 22, 52, "right",
                   ["I'm walking the whole Sefton Coastal Path today, Crosby to Southport. That's about twenty miles. Or one battle, if you're quick."],
                   "Smashing. Right, that's my break done.", "The dunes here are some of the biggest in England, and they move. Slowly. Like me.", 800)
    # wild creatures
    wild(z, [("natterjack", 18, 20, 14, {"weather": ["drizzle", "downpour", "gale"]}), ("duneskink", 18, 20, 14, {"weather": ["clear", "sunshine"]}),
             ("scuttlet", 18, 20, 16, {}), ("starlet", 18, 20, 12, {"time": ["dawn", "day", "dusk"]}),
             ("chipgull", 18, 20, 12, {}), ("stalklet", 18, 20, 8, {}), ("volet", 18, 20, 6, {}),
             ("ternlet", 19, 20, 6, {"season": ["spring", "summer"]}), ("flittermouse", 18, 20, 8, {"time": ["night"]}),
             ("puffkin", 18, 20, 6, {"season": ["autumn"]}), ("weedjen", 18, 20, 8, {}),
             ("ironwatch", 20, 21, 2, {"time": ["dusk", "night"]})])
    wild(z, [("pupplash", 18, 20, 25, {}), ("pinchkin", 18, 20, 25, {}), ("chipgull", 18, 20, 20, {}),
             ("stalklet", 18, 20, 12, {}), ("weedjen", 18, 20, 10, {}), ("volet", 18, 20, 8, {})], "water")
    # only the Dock Road (south) and Lord Street (north) leave the zone
    z.rect(0, 102, 12, 2, "$"); z.rect(12, 102, 26, 2, "T"); z.rect(41, 102, 15, 2, "T")
    z.rect(0, 0, 8, 2, "$"); z.rect(8, 0, 18, 2, "T"); z.rect(29, 0, 27, 2, "T")
    z.d["edges"] = {"south": {"to": "liverpool", "offset": 22}, "north": {"to": "blackpool", "offset": 4}}
    z.d["spawn"] = [39, 100]
    finish(z)
    z.save(OUT + "/" + zid + ".json")
    # interiors on the route
    room(OUT, "crosby_coastguard", "Crosby Coastguard Station", zid, (47, 95), "hall",
         [{"id": "cg_officer", "sprite": "sailor", "x": 4, "y": 3, "facing": "down", "move": "still", "script": "cg_officer", "name": "Coastguard"},
          {"id": "cg_volunteer", "sprite": "villager_1", "x": 9, "y": 4, "facing": "left", "move": "still", "script": "cg_volunteer", "name": "Volunteer"}],
         extra_props=[P("telescope", 2, 1), P("wall_map", 6, 1, walk=True), P("display_case", 10, 2), P("lobster_pots", 1, 6)])
    script("crosby_coastguard", "cg_officer", say("Coastguard",
           "Crosby's sands look friendly, but the tide comes in fast across the flats and the mud's soft near the channel. We get called out to people stuck by the iron men, waiting to be rescued, looking very like an iron man themselves.",
           "If you see someone in trouble at the coast, it's 999 and ask for the Coastguard. Same number for the lifeboat."))
    script("crosby_coastguard", "cg_volunteer", say("Volunteer",
           "Each of the iron men weighs about 650 kilograms. The tide still moves them. We had one lean over like he'd had a long night. He's been straightened up since.",
           "They're numbered, you know. Some of the far ones only show at low tide. You see more of them in the morning, when it's quiet and the light's low."))
    room(OUT, "southport_tearooms", "Lord Street Tea Rooms", zid, (22, 12), "cafe",
         [{"id": "tea_owner", "sprite": "shopkeeper", "x": 3, "y": 3, "facing": "down", "move": "still", "script": "tea_owner", "name": "Tea Room Owner"},
          {"id": "tea_lady", "sprite": "villager_4", "x": 9, "y": 4, "facing": "left", "move": "still", "script": "tea_lady", "name": "Lady Who Lunches"}],
         extra_props=[P("kettle_table", 1, 3), P("plant_stand", 11, 1), P("piano", 11, 6, rot=270)])
    script("southport_tearooms", "tea_owner", say("Tea Room Owner",
           "Potted shrimps on brown toast, love? Little brown shrimps from the bay, cooked, packed in spiced butter. A Lancashire coast speciality for two hundred years and more.",
           "We do a full afternoon tea, too. Scones first, then cake. If you start with cake I'll have to ask you to leave. Politely.") +
           [{"do": "shop", "id": "southport_tearooms"}])
    script("southport_tearooms", "tea_lady", say("Lady Who Lunches",
           "Lord Street was built wide on purpose: the Victorians wanted somewhere grand to promenade. Carriages down the middle, ladies under the verandas, gentlemen pretending not to look.",
           "My grandmother always said Napoleon the Third got his ideas for Paris from Southport. She also said she'd danced with a duke. I believe one of those."))
    room(OUT, "southport_atkinson", "Atkinson Gallery", zid, (33, 12), "museum",
         [{"id": "atk_curator", "sprite": "tour_guide", "x": 6, "y": 4, "facing": "down", "move": "still", "script": "atk_curator", "name": "Curator"},
          {"id": "atk_child", "sprite": "student", "x": 10, "y": 5, "facing": "left", "move": "still", "text": "There's an Egyptian mummy upstairs. In Southport! It's been here longer than my nan."}],
         extra_props=[P("wall_picture", 3, 1, walk=True, variant=1), P("wall_picture", 9, 1, walk=True, variant=2), P("display_case", 2, 4), P("display_case", 10, 3)])
    script("southport_atkinson", "atk_curator", say("Curator",
           "The Atkinson is Southport's arts centre: a theatre, a library, a gallery and a museum, all under one roof on Lord Street. The building opened in the 1870s, paid for by a local mill owner.",
           "Our Egyptian collection came from local collectors who travelled in the 1800s. Everyone goes straight to the mummy. The paintings understand."))
    room(OUT, "martin_mere_hide", "Martin Mere Hide", zid, (42, 6), "museum",
         [{"id": "mm_warden", "sprite": "birdwatcher", "x": 6, "y": 2, "facing": "up", "move": "still", "script": "mm_warden", "name": "Hide Warden"},
          {"id": "mm_kid", "sprite": "student", "x": 9, "y": 3, "facing": "up", "move": "still", "text": "I've seen a pink-footed goose! Its feet are pink! Who'd have thought it."}],
         extra_props=[P("telescope", 3, 1), P("telescope", 9, 1), P("window", 5, 1, walk=True), P("window", 7, 1, walk=True), P("specimen_shelf", 1, 4), P("owl_perch", 11, 4)])
    script("martin_mere_hide", "mm_warden", say("Hide Warden",
           "Quietly does it. Out there: whooper swans, pink-footed geese, wigeon, pintail. In deep winter we can have over two thousand whoopers on the mere at once.",
           "Every winter afternoon the warden goes out with a barrow of grain and the swans come sailing in for their tea. People drive for hours to watch. The swans fly in from Iceland for it. Fair's fair."))
    DLG.setdefault(zid, {})


# =====================================================================================================
# Blackpool
# =====================================================================================================
def blackpool(OUT):
    W, H = 76, 66
    zid = "blackpool"
    z = Z(zid, "Blackpool", W, H, kind="town", region=LAN, music="town_north",
          weather={"clear": 24, "sunshine": 20, "drizzle": 22, "gale": 22, "fog": 6, "downpour": 6})
    z.d["stage"] = "coast"
    z.d["town_id"] = "blackpool"
    z.d["scaled_floor"] = FLOOR
    z.legend["k"] = {"tile": "grass", "colour": "#6d8a4c"}
    z.rect(0, 0, W, H, ":")
    z.border("T", 2)
    # sea, beach, promenade, tramway
    z.rect(0, 0, 7, H, "$")
    z.rect(7, 0, 1, H, "w")
    z.rect(8, 0, 6, H, "s")
    z.rect(14, 0, 4, H, ":")
    z.rect(18, 2, 2, H - 2, "=")
    z.rect(0, 0, W, 2, "T"); z.rect(0, 0, 18, 2, "$")
    z.rect(7, 0, 1, 2, "w"); z.rect(8, 0, 6, 2, "s"); z.rect(14, 0, 4, 2, "T")
    # the three piers: walkway with railings, pavilions at the end
    for (py, name, label) in [(9, "North Pier", "North Pier Pavilion"), (31, "Central Pier", "Central Pier Pavilion"), (54, "South Pier", "South Pier Pavilion")]:
        z.rect(1, py, 13, 2, ":")
        z.rect(5, py - 1, 9, 1, "F"); z.rect(5, py + 2, 9, 1, "F")
        z.building(1, py - 3, 4, 3, "pier_pavilion", label)
        z.prop("lamp_post", 6, py); z.prop("lamp_post", 11, py + 1)
    # the town: roads
    z.rect(20, 18, 54, 2, "=")       # Talbot Road / Church Street, east-west: the best view of the Tower
    z.rect(20, 39, 54, 2, "=")       # Central Drive, east-west
    z.rect(36, 2, 2, 37, "=")        # a north-south street
    z.rect(30, 41, 3, 25, "=")       # Lytham Road, south to St Annes and the coast road
    z.rect(62, 20, 2, 19, "=")
    # north end: Sanctuary, shop, rock factory, guest houses, the station
    z.building(22, 4, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(25, 7, "blackpool_sanctuary", 5, 6, "up")
    z.building(29, 5, 5, 3, "shop", "Corner Shop", door=2)
    z.warp(31, 7, "blackpool_shop", 4, 5, "up")
    z.building(39, 4, 8, 4, "red_brick", "Blackpool Rock Factory", door=4)
    z.warp(43, 7, "blackpool_rockfactory", 6, 7, "up")
    z.building(22, 11, 6, 4, "guest_house", "Sea View Guest House", show_label=True)
    z.building(29, 11, 6, 4, "guest_house", show_label=False)
    z.building(39, 11, 8, 4, "guest_house", "The Seaside Rest", show_label=True)
    station(z, 52, 4, 8, 3, "Blackpool North")
    z.rect(48, 7, 28, 1, "!")
    z.rect(48, 8, 28, 1, "T")
    z.rect(48, 2, 4, 5, "k"); z.rect(60, 2, 14, 5, "k")
    z.prop("buffer_stop", 48, 7)
    z.rect(52, 9, 9, 1, ":")
    rail_guard(z, 58, 6, ["Blackpool North. Trains to everywhere you've been, and on Fridays in summer, every hen do in the North West.",
                          "All aboard! Mind the gap and the inflatable flamingo."], facing="down")
    z.rect(48, 9, 4, 9, ":"); z.rect(61, 9, 13, 9, ":")
    z.building(50, 11, 10, 4, "mill", "Illuminations Depot", door=5)
    z.warp(55, 14, "blackpool_depot", 6, 7, "up")
    z.building(63, 11, 10, 4, "guest_house", "Hotel Imperial-ish", show_label=True)
    # the middle: the Tower, the Winter Gardens, chips and a pub
    z.building(23, 22, 10, 6, "blackpool_tower", "Blackpool Tower", door=5)
    z.warp(28, 27, "blackpool_ballroom", 8, 9, "up")
    z.building(40, 22, 9, 5, "red_brick", "Winter Gardens", door=4)
    z.warp(44, 26, "blackpool_wintergardens", 7, 8, "up")
    z.building(51, 23, 6, 4, "white_render", "Seaside Chippy", door=2)
    z.warp(53, 26, "blackpool_chippy", 6, 7, "up")
    z.building(65, 22, 7, 5, "tudor", "The Kiss Me Quick Inn", door=3)
    z.warp(68, 26, "blackpool_pub", 6, 7, "up")
    for (x, y) in [(23, 32), (27, 32), (31, 32)]:
        z.prop("planter", x, y)
    z.prop("bench", 25, 33); z.prop("bench", 29, 33)
    z.building(40, 31, 9, 5, "guest_house", "Ocean Breeze", show_label=True)
    z.building(51, 31, 9, 5, "guest_house", show_label=False)
    z.building(65, 31, 8, 5, "guest_house", "Dunroamin'", show_label=True)
    # the Comedy Carpet in front of the Tower, and the switch-on stage on the prom
    z.rect(21, 28, 13, 2, ":")
    z.prop("hall_stage", 16, 22)
    z.prop("stage_light", 15, 21); z.prop("stage_light", 17, 21)
    plaque(z, 34, 28, "lancashire_comedy_carpet", "The Comedy Carpet",
           "THE COMEDY CARPET. Laid at the foot of the Tower in 2011, it is a vast floor of granite and concrete set with the jokes, songs and "
           "catchphrases of more than a thousand comedians and writers who played Blackpool. You read it with your feet. People stop dead "
           "in the middle of it, laughing at the floor.")
    plaque(z, 29, 29, "lancashire_tower", "Blackpool Tower",
           "BLACKPOOL TOWER. Inspired by the Eiffel Tower in Paris, it opened on 14 May 1894 and stands 158 metres high. Between its four "
           "legs is the Tower Circus, which has run every year since the tower opened; at the grand finale the ring sinks and floods with "
           "water. Up top, a glass floor lets you look straight down at the prom. Brave people only.")
    plaque(z, 15, 26, "lancashire_illuminations", "The Illuminations",
           "THE ILLUMINATIONS. In 1879 eight arc lamps lit the promenade, and folk called it 'artificial sunshine'. The lights as we know "
           "them began in 1912, when Princess Louise opened the new Princess Parade. Today they run for about six miles, from Starr Gate "
           "to Bispham, every autumn. The switch-on is a big night: a famous face throws the switch and the whole prom goes 'ooh'.")
    plaque(z, 15, 34, "lancashire_three_piers", "Three Piers",
           "THREE PIERS. Blackpool is the only town in Britain with three: North Pier (1863), Central Pier (1868) and South Pier (1893). "
           "North was the genteel one, with concerts and a band. Central was where the working folk danced. You could tell the town's "
           "whole social order by which pier you walked along.")
    plaque(z, 20, 44, "lancashire_trams", "The Trams",
           "THE TRAMS. Blackpool's tramway opened in 1885, one of the first electric street tramways anywhere, and the oldest still "
           "running. The double-deck 'Balloon' trams date from the 1930s. For years, Blackpool kept its trams when almost every other "
           "British town scrapped theirs.")
    plaque(z, 13, 47, "lancashire_donkeys", "The Beach Donkeys",
           "THE DONKEYS. There have been donkey rides on Blackpool sands since Victorian times. The donkeys have long had their own rules: "
           "a day off each week, a weight limit for riders, and a proper lunch break. Better terms than most of the people leading them, "
           "the donkey men say.")
    plaque(z, 36, 20, "lancashire_wakes_weeks", "Wakes Weeks",
           "WAKES WEEKS. In the mill towns of Lancashire and Yorkshire each town shut its mills for its own holiday week. Whole towns, "
           "Bolton or Oldham or Burnley, would arrive in Blackpool on the same trains, stay in the same guest houses and go home together, "
           "pockets empty, sunburnt, happy.")
    # lamps and bunting up the prom: the lights
    for y in range(4, H - 2, 4):
        z.prop("lamp_post", 17, y)
        z.prop("lamp_post", 14, y + 2)
    for y in range(6, H - 2, 6):
        z.prop("bunting", 15, y)
        z.prop("bunting", 20, y + 3)
    # the parked tram at the stop
    z.building(18, 42, 1, 3, "blackpool_tram", show_label=False)
    z.sign(20, 41, "TRAM STOP: North Pier, the Tower, Pleasure Beach, Starr Gate. Next tram: when it gets here. Fares, please.")
    # donkeys on the sands, and the donkey man
    for (x, y) in [(10, 44), (11, 46), (9, 48), (12, 49)]:
        npc(z, id="bp_donkey_%d_%d" % (x, y), sprite="creature:donkey", x=x, y=y, facing="left", move="still",
            text="A beach donkey with a name on its brow-band. It looks at you as if you might be a carrot.", name="Donkey")
    npc(z, id="bp_bramble_home", sprite="creature:donkey", x=10, y=50, facing="right", move="still", name="Bramble",
        text="Bramble, home again, with a faint smell of asparagus and no regrets.", show_if="q_lancashire_donkey_2")
    # the south: Pleasure Beach, the Big One, Bloomfield Road
    z.building(34, 52, 16, 4, "big_one", show_label=False)
    z.building(34, 46, 7, 3, "white_render", "Pleasure Beach", show_label=True)
    for (x, y) in [(22, 51), (25, 51), (27, 53), (36, 58), (39, 59), (45, 58)]:
        z.prop("market_stall", x, y, variant=x % 3)
    for (x, y) in [(34, 50), (38, 50), (44, 50), (48, 57)]:
        z.prop("bunting", x, y)
    plaque(z, 33, 53, "lancashire_big_one", "The Big One",
           "THE BIG ONE. When it opened at the Pleasure Beach in 1994 it was the tallest rollercoaster in the world: a lift hill of "
           "65 metres and a first drop at about 74 miles an hour. The Pleasure Beach itself dates from 1896 and still runs wooden "
           "coasters from the 1920s and 30s. The queue for the front seat is a Blackpool tradition all of its own.")
    z.building(48, 44, 14, 5, "red_brick", "Bloomfield Road", door=7)
    z.warp(55, 48, "blackpool_bloomfield", 8, 10, "up")
    plaque(z, 54, 50, "lancashire_matthews", "Stanley Matthews",
           "SIR STANLEY MATTHEWS. The wizard of the dribble played for Blackpool from 1947 to 1961. In the 1953 FA Cup Final, the "
           "'Matthews Final', Blackpool were 3-1 down to Bolton and won 4-3. He was the first footballer to be knighted, and he played "
           "top-flight football until he was fifty.")
    z.building(64, 44, 8, 4, "guest_house", show_label=False)
    z.building(22, 56, 7, 4, "guest_house", "Pleasure Beach Hotel", show_label=True)
    z.building(64, 52, 8, 4, "guest_house", show_label=False)
    z.rect(45, 50, 30, 2, ":")
    for (x, y) in [(46, 58), (52, 60), (58, 57), (70, 60)]:
        z.prop("oak", x, y, variant=x % 3)
    blob(z, 56, 59, 5, 3, "k", only=":", seed=21)
    z.sign(31, 63, "SOUTH: Lytham St Annes and the coast road to Southport. Mind the donkey crossing.")
    # NPCs who teach
    chat(z, "bp_rock_seller", "shopkeeper", 21, 38, "Rock Seller",
         ["Rock! Real Blackpool rock, with BLACKPOOL all the way through. Snap it anywhere and it still says Blackpool. Unlike my ex.",
          "The letters are made by hand in a big fat slab, then the whole thing's rolled and pulled thin until the writing is tiny. Like a sugary sausage with a message."],
         "down", "still")
    chat(z, "bp_landlady", "villager_4", 26, 9, "Landlady",
         ["Sea View Guest House, love. No sea view, mind, but there's a picture of the sea in the hall.",
          "In the old days it was house rules: breakfast at eight, out by ten, not back till teatime whatever the weather. Wakes Week, the whole of Oldham stayed on this street."],
         "down", "still")
    chat(z, "bp_sandgrownun", "villager_2", 47, 20, "Local Lad",
         ["Sandgrown'un, me. Born and bred in Blackpool. Visitors come for a weekend. We have to live with the lights every autumn. Lovely, it is. You can read in bed with the curtains open.",
          "Get yourself a chippy tea: fish, chips and mushy peas, or a pea wet if you're proper. Then a barm cake. Then the Tower. In that order."],
         "left", "wander")
    chat(z, "bp_icecream", "villager_5", 11, 31, "Ice-Cream Seller",
         ["Ninety-nine with a flake, love? Strawberry sauce is extra and so is sympathy.",
          "That Bramble? The donkey? I saw her trotting south along the sands this morning, nose down, like she'd smelt summat green. She'll be halfway to Southport by now."],
         "down", "still")
    # hen and stag dos
    scaled_trainer(z, "bp_bride", "Bride-to-Be Kayleigh", "Hen Party", "festival_goer",
                   [("starlet", 19), ("chipgull", 19), ("cooplet", 18), ("binfox", 19)], 41, 37, "down",
                   ["I'm getting married on Saturday and this is my last night of freedom! Well, my fourth last night. Sash on, L-plates on, let's battle!"],
                   "Oh, I don't care, I'm getting MARRIED!", "The girls have gone to see the drag show at the Winter Gardens. I said I'd catch up. In a minute. After a sit down.", 900, move="still")
    scaled_trainer(z, "bp_bestman", "Best Man Gaz", "Stag Party", "rugby_player",
                   [("binfox", 19), ("strutcoo", 20), ("pupplash", 19)], 58, 37, "left",
                   ["Stag do! Dave's tied to the North Pier in a mankini. Don't worry, he volunteered. Sort of. Fancy a battle?"],
                   "Battered! Like a haddock. Like Dave will be.",
                   "Best man's speech is sorted. It's mostly about the time Dave fell in the boating lake. Twice. Same afternoon.", 900, move="still")
    scaled_trainer(z, "bp_fortune", "Gypsy Rosa-ish", "Fortune Teller", "druid",
                   [("hootlet", 19), ("wispet", 20), ("bulbkin", 19)], 16, 37, "right",
                   ["Cross my palm with silver and I'll tell your future. I see... a battle. Ooh, and a stick of rock. Possibly at once."],
                   "I didn't see that coming. Bit awkward in my line of work.", "Your future: chips. I'd put money on it. I'd put your money on it.", 880)
    scaled_trainer(z, "bp_lifeguard", "Lifeguard Shannon", "Lifeguard", "surfer",
                   [("pupplash", 19), ("pinchkin", 19), ("gannetling", 20)], 12, 24, "down",
                   ["Red flag's up, so nobody's swimming. That leaves me with plenty of time to battle you!"],
                   "Rescued! I mean, beaten. Same feeling.", "The Irish Sea's cold even in August. Locals call it bracing. Visitors call it a mistake.", 860)
    # the local legend at the Pleasure Beach: full party
    scaled_trainer(z, "bp_legend_brenda", "Big One Brenda", "Local Legend", "festival_goer",
                   [("pierlord", 22), ("murmurant", 22), ("bulbkin", 22), ("natterjack", 22), ("weedjen", 22), ("greyhaul", 23)],
                   42, 57, "up",
                   ["Ten thousand rides on the Big One, me. Front seat, hands up, every time. I've screamed at every speed there is.",
                    "They gave me a lifetime pass in 1999 to stop me queueing. Now let's see if you've got the stomach for a proper battle."],
                   "Ooh, that's better than the first drop. Go on, have a go on the Big One. Tell 'em Brenda sent you.",
                   "Seventy-four miles an hour, that drop. My hair's never recovered. Neither has my hairdresser.", 2400,
                   music="battle_champion")
    # quest folk on the prom: the tram driver and the switch-on stage compere
    npc(z, id="bp_alf", sprite="rail_guard", x=20, y=43, facing="left", script="bp_alf", name="Tram Driver Alf")
    script(zid, "bp_alf", [
        iff("q_lancashire_lights_1",
            say("Tram Driver Alf", "Fuses to Doreen, bulbs from Southport, then a celebrity. Doreen's got you running about like the last tram at midnight."),
            [iff("q_lancashire_lights_started",
                 say("Tram Driver Alf", "Doreen wants the spare fuses from my cab? She'll have to earn them. Well, you will. Beat me fair and square, like the old timetable, and they're yours.") +
                 [{"do": "battle", "trainer": "bp_tram_alf", "intro": True}] +
                 say("Tram Driver Alf", "Right. A deal's a deal. One box of fuses, bit greasy, and some advice: Doreen's short of bulbs too. Every year. Try Southport Pier, the keeper keeps a crate.") +
                 [setf("q_lancashire_lights_1")],
                 say("Tram Driver Alf", "Blackpool trams, since 1885. Older than the Tower! Electric from the start, too, from a conduit in the road at first, before the overhead wires.",
                     "I drive a Balloon on heritage days. Upstairs at the front, on the prom, with the lights on. Best seat in Lancashire."))])])
    quest_trainer("bp_tram_alf", "Tram Driver Alf", "Tram Driver", "rail_guard",
                  [("swiftlet", 19), ("bulbkin", 20), ("strutcoo", 20)],
                  ["Ding ding! All aboard the battle tram!"],
                  "Terminus! Fair enough, you've got the fuses.", "Mind the tram lines on your bike. Everyone falls off once. Once.", 1100)
    npc(z, id="bp_compere", sprite="ceilidh_caller", x=16, y=24, facing="down", script="bp_compere", name="Compère",
        hide_if="q_lancashire_lights_done")
    npc(z, id="bp_compere_after", sprite="ceilidh_caller", x=16, y=24, facing="down", name="Compère", show_if="q_lancashire_lights_done",
        text="Best switch-on in years, that. The papers have already called it 'Mr or Ms Nobody Lights Up Blackpool'. Very catchy.")
    script(zid, "bp_compere", [
        iff("q_lancashire_lights_3",
            [{"do": "when", "cond": "dusk", "then": [setf("_lancs_dark", True)], "else": [
                {"do": "when", "cond": "night", "then": [setf("_lancs_dark", True)], "else": [setf("_lancs_dark", False)]}]},
             iff("_lancs_dark", [
                 {"do": "say", "who": "Compère", "text": "Ladies and gentlemen, boys and girls, hen dos and stag dos! Our celebrity is stuck on the M55, so tonight, please welcome a very special stand-in..."},
                 {"do": "say", "who": "Compère", "text": "...{player}! Ten! Nine! Eight! Oh, they've done it early. Never mind!"},
                 {"do": "fade_out"}, {"do": "sfx", "id": "badge"},
                 {"do": "say", "who": "", "text": "You pull the big brass lever. Six miles of lights come on in a rush, the Tower blazes from top to toe, and the whole promenade goes 'ooooh'."},
                 {"do": "fade_in"},
                 {"do": "say", "who": "Doreen", "text": "Every bulb lit! Not one fuse gone! You're a star, {player}. Here, a little thank you from the depot."},
                 give("illuminations_bulb"), give("blackpool_rock", 5), give("chippy_tea", 2), standing(6),
                 setf("q_lancashire_lights_done")],
                 say("Compère", "Not yet, love! You can't switch on the Illuminations in broad daylight. Come back at dusk, when the sky goes purple over the Irish Sea."))],
            say("Compère", "Testing, testing. One, two. Is this thing on? It's the switch-on soon, and the celebrity's been held up on the motorway. Again.",
                "Doreen at the depot's running about like a headless chicken. You could do worse than ask her what she needs."))])
    npc(z, id="bp_crowd_a", sprite="festival_goer", x=21, y=24, facing="left", show_if="q_lancashire_lights_done", name="Lights Fan",
        text="Ooooh. Every year I say I won't cry at the switch-on, and every year I do.")
    npc(z, id="bp_crowd_b", sprite="villager_6", x=21, y=26, facing="left", show_if="q_lancashire_lights_done", name="Lights Fan",
        text="My nan brought me to the switch-on when I was six. I brought my kids. Now my kids bring me. I'm only forty.")
    # the donkey man
    npc(z, id="bp_donkey_jack", sprite="farmer", x=12, y=46, facing="right", script="bp_donkey_jack", name="Donkey Man Jack")
    script(zid, "bp_donkey_jack", [
        iff("q_lancashire_donkey_done",
            say("Donkey Man Jack", "Bramble's been as good as gold since. Well, she's eaten a hat. But it was a kiss-me-quick hat, so it's practically food."),
            [iff("q_lancashire_donkey_2",
                 say("Donkey Man Jack", "Bramble! You daft article! Where've you been? Eating asparagus in Formby? Twenty miles for a vegetable!",
                     "Thank you, love. Honestly. Here, take this. It's one of her old shoes, for luck, the right way up so the luck doesn't fall out.") +
                 [give("horseshoe"), give("blackpool_rock", 2), standing(3), setf("q_lancashire_donkey_done")],
                 [iff("q_lancashire_donkey_1",
                      say("Donkey Man Jack", "South, you reckon? Along the sands towards Southport? The tide's out, she could walk to Formby without getting her hooves wet. Could you go after her? She'll come to anyone with a carrot. Or anyone, frankly."),
                      [iff("q_lancashire_donkey_started",
                           say("Donkey Man Jack", "Have you asked along the beach? Somebody on Central Pier must've seen a donkey walk past. They're not easy to miss."),
                           say("Donkey Man Jack", "You haven't seen a donkey, have you? Grey, about this high, answers to Bramble. Well, she doesn't answer. But it's her name.",
                               "She slipped her halter at dinner time while I was counting the takings. Twenty-odd years on these sands and I've never lost one. Would you ask about for me?") +
                           [setf("q_lancashire_donkey_started")])])])])])
    # the ice-cream seller gives the clue (overrides the chat line above once the hunt is on)
    DLG[zid]["bp_icecream"] = [
        iff("q_lancashire_donkey_started",
            [iff("q_lancashire_donkey_1", say("Ice-Cream Seller", "South, love. Nose down, tail swishing. Follow the hoofprints."),
                 say("Ice-Cream Seller", "Bramble? Jack's donkey? I saw her trotting south along the sands this morning, nose down, like she'd smelt summat green.",
                     "She'll be halfway to Southport by now. Or Formby. Donkeys love a vegetable patch.") + [setf("q_lancashire_donkey_1")])],
            say("Ice-Cream Seller", "Ninety-nine with a flake, love? Strawberry sauce is extra and so is sympathy.",
                "Ice cream on Central Pier since before I was born. My dad sold it, his mum sold it. We've never once sold a hot one."))]
    # wild creatures: gulls, pigeons, starlings (the pier murmurations), shore life and the lights' own sparks
    wild(z, [("chipgull", 18, 20, 22, {}), ("cooplet", 18, 20, 18, {}), ("starlet", 18, 20, 14, {"time": ["dusk", "dawn"]}),
             ("binfox", 18, 20, 10, {"time": ["dusk", "night"]}), ("bulbkin", 18, 20, 14, {"time": ["dusk", "night"]}),
             ("bulbkin", 18, 20, 4, {"time": ["dawn", "day"]}), ("pinchkin", 18, 20, 8, {}), ("swiftlet", 18, 20, 6, {"weather": ["gale", "clear"]})])
    wild(z, [("chipgull", 18, 20, 30, {}), ("pupplash", 18, 20, 25, {}), ("pinchkin", 18, 20, 25, {}), ("gannetling", 19, 20, 10, {})], "water")
    # only Lytham Road leaves to the south
    z.rect(0, 64, 8, 2, "$"); z.rect(8, 64, 22, 2, "T")
    z.d["edges"] = {"south": {"to": "sefton_coast", "offset": -4}}
    z.d["spawn"] = [31, 62]
    finish(z)
    z.save(OUT + "/" + zid + ".json")

    # ---------------- interiors ----------------
    sanctuary(OUT, zid, "Blackpool", (25, 8), music="sanctuary")
    shop(OUT, zid, "Blackpool", (31, 8))
    nurse(zid, ["Hiya, chuck! Welcome to Blackpool Sanctuary. Pop your team on the counter. They look like they've been on the Big One twice.",
                "There we are. A nice cup of tea, a stick of rock for the shock, and a sit-down out of the wind.",
                "All better! Fit as a lop, as my nan used to say. Nobody knows what a lop is. Off you go, love.",
                "The Ark's in the corner, chuck. Somebody's stuck a kiss-me-quick sticker on the lid. It wasn't me.",
                "Ta-ra, love! Mind the trams, they don't stop for anyone."])
    shopkeeper(zid, "Now then! Rock, chips, a kiss-me-quick hat, and snares for the brave. What'll it be, love?",
               "Ta-ra! Enjoy the lights.")
    SHOPS.append({"id": "blackpool_corner_shop", "name": "Blackpool Corner Shop",
                  "stock": ["cup_of_tea", "flask_of_tea", "bakewell_tart", "buxton_water", "smelling_salts", "kendal_mint_cake",
                            "wicker_snare", "iron_snare", "night_snare", "water_snare", "eccles_cake", "lavender_sachet",
                            "blackpool_rock", "chippy_tea", "kiss_me_quick_hat"]})
    SHOPS.append({"id": "southport_tearooms", "name": "Lord Street Tea Rooms",
                  "stock": ["cup_of_tea", "flask_of_tea", "cream_tea", "eccles_cake", "potted_shrimps"]})
    SHOPS.append({"id": "blackpool_chippy", "name": "Seaside Chippy",
                  "stock": ["chippy_tea", "cup_of_tea", "blackpool_rock"]})
    # the Tower Ballroom: sprung parquet, gilt balconies, the Wurlitzer on its stage
    bw, bh = 17, 12
    ball = room(OUT, "blackpool_ballroom", "Tower Ballroom", zid, (28, 28), "hall", [
        {"id": "ball_mc", "sprite": "tour_guide", "x": 8, "y": 3, "facing": "down", "move": "still", "script": "ball_mc", "name": "Master of Ceremonies"},
        {"id": "ball_organist", "sprite": "harpist", "x": 3, "y": 2, "facing": "right", "move": "still", "script": "ball_organist", "name": "Organist"},
        {"id": "ball_couple", "sprite": "festival_goer", "x": 12, "y": 5, "facing": "left", "move": "still", "script": "ball_couple", "name": "Ballroom Dancer"},
        {"id": "ball_gran", "sprite": "villager_3", "x": 14, "y": 8, "facing": "left", "move": "still", "name": "Regular",
         "text": "I've danced here every Tuesday since 1962. The floor's been relaid since. I haven't."},
        {"id": "ball_teen", "sprite": "student", "x": 2, "y": 8, "facing": "right", "move": "still", "name": "Teenager",
         "text": "Me nan dragged me here. I'm not enjoying it. ...Okay, the organ's a bit good."}],
        w=bw, h=bh,
        legend={"p": {"tile": "floor_wood", "colour": "#9a6a3c"}, "q": {"tile": "floor_wood", "colour": "#7e5430"}},
        rows=[(3, 4, 11, 5, "p")] + [(x, y, 1, 1, "q") for y in range(4, 9) for x in range(3, 14) if (x + y) % 2 == 0],
        extra_props=[P("hall_stage", 8, 1), P("piano", 2, 1), P("stage_light", 5, 1), P("stage_light", 11, 1),
                     P("bench", 1, 4, rot=90), P("bench", 1, 6, rot=90), P("bench", 15, 4, rot=270), P("bench", 15, 6, rot=270),
                     P("candelabra", 1, 2), P("candelabra", 15, 2)], drop=("table",))
    script("blackpool_ballroom", "ball_organist", [
        iff("q_lancashire_ballroom_started",
            [iff("q_lancashire_ballroom_1", say("Organist", "Off you go and dance! I'll give you a quickstep. Everybody loves a quickstep."),
                 say("Organist", "A tune for the contest? Of course. This is the Mighty Wurlitzer: it rises up out of the stage on a lift, playing as it comes, and the whole room cheers.",
                     "Reginald Dixon played it from 1930 to 1970. Mr Blackpool, they called him. 'I Do Like To Be Beside The Seaside' was his signature tune. Every organist since has had to live up to him.",
                     "Right: a quickstep, I think, with a cheeky slow foxtrot in the middle. Off you go!") +
                 [{"do": "sfx", "id": "badge"}, setf("q_lancashire_ballroom_1")])],
            say("Organist", "The Wurlitzer's resting. So am I. The Ballroom's ceiling took longer to paint than the organ did to build, you know. Look up! Gold leaf everywhere."))])
    script("blackpool_ballroom", "ball_mc", [
        iff("q_lancashire_ballroom_done",
            say("Master of Ceremonies", "Our champions! Twirl for the people, darling. Lovely."),
            [iff("q_lancashire_ballroom_1",
                 say("Master of Ceremonies", "Music, maestro! Ladies and gentlemen, the final of the Tower Ballroom Creature Dance Contest!",
                     "Reigning champions, the Twinkletoes! And the challenger, {player}! Take your partners, two by two!") +
                 [{"do": "battle", "trainer": "bp_twinkletoes", "intro": True}] +
                 say("Master of Ceremonies", "The judges' scores: TEN! TEN! TEN! And a SEVEN from the grumpy one. The new champions!",
                     "Your prize: a box of the Tower's own rock, and the eternal gratitude of the sequin industry.") +
                 [give("blackpool_rock", 3), give("rowan_sprig"), standing(3), setf("q_lancashire_ballroom_done")],
                 [iff("q_lancashire_ballroom_started",
                      say("Master of Ceremonies", "You'll need music first, darling. Ask our organist for a tune, then come back and we'll begin."),
                      say("Master of Ceremonies", "Welcome to the Tower Ballroom! Opened in 1894, sprung floor, gold leaf, and the most famous organ in the land. People come from all over the world just to dance a waltz here.",
                          "Tonight's the Creature Dance Contest: two of yours against two of theirs, in step. The champions, the Twinkletoes, have never been beaten. Fancy it?",
                          "Marvellous! First, see the organist for a tune. You can't dance to silence. Well, you can, but it's called standing about.") +
                      [setf("q_lancashire_ballroom_started")])])])])
    script("blackpool_ballroom", "ball_couple", say("Ballroom Dancer",
           "We're the Twinkletoes. Forty years married, forty years champions. He treads on my feet, I tread on his, the judges call it 'a modern interpretation'.",
           "The floor's made of thousands of blocks of mahogany, oak and walnut. Sprung, too, so it gives a little under your feet. It's like dancing on a very polite trampoline."))
    quest_trainer("bp_twinkletoes", "The Twinkletoes", "Dance Champions", "festival_goer",
                  [("starlet", 20), ("murmurant", 20), ("cooplet", 20), ("bulbkin", 21)],
                  ["Shall we dance? Two at a time, darling. Keep your frame!"],
                  "Oh! Beaten on our own floor! Well danced. We'll be back next year, with sequins.",
                  "Remember: it's not the steps, it's the smile. Also the steps.", 1500, double=True, music="battle_double")
    # the Winter Gardens: the stand-in celebrity, and a quiz for the stand-in
    room(OUT, "blackpool_wintergardens", "Winter Gardens", zid, (44, 27), "theatre", [
        {"id": "wg_norman", "sprite": "poet", "x": 7, "y": 2, "facing": "down", "move": "still", "script": "wg_norman", "name": "Uncle Norman"},
        {"id": "wg_usher", "sprite": "villager_1", "x": 12, "y": 6, "facing": "left", "move": "still", "name": "Usher",
         "text": "The Winter Gardens opened in 1878. The Empress Ballroom's had everything: dances, wrestling, rock bands, and the political parties' conferences. Same seats for all of them."}],
        w=15, h=11, extra_props=[P("hall_stage", 7, 1), P("stage_light", 4, 1), P("stage_light", 10, 1), P("stacked_chairs", 1, 7), P("candelabra", 13, 1)])
    script("blackpool_wintergardens", "wg_norman", [
        iff("q_lancashire_lights_3",
            say("Uncle Norman", "Off you go to the stage on the prom, and wait for dusk! I've told the compère. I've told everyone. I'm very proud. I'll be at the back, crying into a barm cake."),
            [iff("q_lancashire_lights_2",
                 say("Uncle Norman", "Doreen needs a celebrity for the switch-on? Well, I was on the telly in 1983. Briefly. On the news. For the wrong reasons.",
                     "No, love. You do it. But a Blackpool celebrity has to know their Blackpool. Three questions. Ready?") +
                 [{"do": "choice", "text": "When did eight arc lamps first light the prom, the 'artificial sunshine'?", "options": ["1879", "1912", "1953"], "set": "_lancs_q1"},
                  {"do": "choice", "text": "Which tower inspired Blackpool's?", "options": ["Big Ben", "The Eiffel Tower", "The Leaning Tower of Pisa"], "set": "_lancs_q2"},
                  {"do": "choice", "text": "How many piers does Blackpool have?", "options": ["Two", "Three", "Seven"], "set": "_lancs_q3"},
                  {"do": "if", "flag": "_lancs_q1", "eq": 0, "then": [
                      {"do": "if", "flag": "_lancs_q2", "eq": 1, "then": [
                          {"do": "if", "flag": "_lancs_q3", "eq": 1, "then": say("Uncle Norman",
                              "Three out of three! You're a natural. Right: you're our stand-in. I'll ring the compère. Go to the stage on the prom by the Tower at dusk and throw that switch!") + [setf("q_lancashire_lights_3")],
                           "else": say("Uncle Norman", "Ooh, no. North, Central and South: three piers, the only town in Britain with three. Have another go when you're ready.")}],
                       "else": say("Uncle Norman", "No, love. It was the Eiffel Tower. Blackpool's mayor went to Paris in 1889 and came back with ideas. Try again.")}],
                   "else": say("Uncle Norman", "Not quite. 1879: eight arc lamps, 'artificial sunshine'. 1912 is when the Illuminations proper began. Try again.")}],
                 say("Uncle Norman", "Uncle Norman, comedian, Blackpool's finest, on in the second half. I've played the Winter Gardens, the piers, the Tower Circus once when the clown was ill.",
                     "Here's one. A man walks into the Tower Ballroom with a pork pie on his head. The organist says, 'You've got a pork pie on your head.' He says, 'Not usually, it's a cheese and onion one, but it's my day off.' Thank you, I'm here all week."))])])
    # the chippy
    room(OUT, "blackpool_chippy", "Seaside Chippy", zid, (53, 27), "cafe", [
        {"id": "chippy_fryer", "sprite": "shopkeeper", "x": 3, "y": 3, "facing": "up", "move": "still", "script": "chippy_fryer", "name": "Fryer"},
        {"id": "chippy_diner", "sprite": "villager_2", "x": 9, "y": 4, "facing": "left", "move": "still", "name": "Diner",
         "text": "Fish, chips, mushy peas and a buttered barm. If you put chips in the barm it's a chip butty. If you put the fish in too, it's showing off."}],
        extra_props=[P("fryer", 2, 1), P("menu_board", 3, 1, walk=True), P("kitchen_dresser", 1, 1)])
    script("blackpool_chippy", "chippy_fryer", say("Fryer",
           "Cod or haddock? In Lancashire it's cod, mostly, over the Pennines they'll swear by haddock. I fry in beef dripping, the old way. Vegetable oil on Fridays for the vegetarians.",
           "Salt and vinegar? Gravy? Curry sauce? A pea wet, that's the juice off the mushy peas, poured over? Go on.") +
           [{"do": "shop", "id": "blackpool_chippy"}])
    # the rock factory: the rock quest
    room(OUT, "blackpool_rockfactory", "Blackpool Rock Factory", zid, (43, 8), "workshop", [
        {"id": "rock_boss", "sprite": "shopkeeper", "x": 6, "y": 3, "facing": "down", "move": "still", "script": "rock_boss", "name": "Rock Boiler Maureen"},
        {"id": "rock_apprentice", "sprite": "student", "x": 10, "y": 4, "facing": "left", "move": "still", "script": "rock_apprentice", "name": "Apprentice Liam"}],
        extra_props=[P("kettle_table", 2, 4), P("table", 4, 5), P("table", 8, 5), P("specimen_shelf", 11, 2), P("menu_board", 9, 1, walk=True)])
    script("blackpool_rockfactory", "rock_boss", [
        iff("q_lancashire_rock_done",
            say("Rock Boiler Maureen", "You've a job here any time, love. Pay's terrible, but you can eat the mistakes."),
            [iff("q_lancashire_rock_1",
                 say("Rock Boiler Maureen", "You beat Liam at pulling? He's been here three summers! Right, that's your training done.",
                     "Here's how it goes: boil the sugar and glucose to a hard crack, pour it on the slab, then colour some red and pull the rest until it goes white and shiny.",
                     "The letters are built by hand, in red, each one as a long fat bar packed with white, set round the middle like a stick of seaside rock in cross-section. Then the whole lump's rolled and pulled out thin, and every inch says BLACKPOOL.",
                     "Here's your wages. In rock. Don't eat it all at once. You will, but don't.") +
                 [give("blackpool_rock", 6), give("eccles_cake", 2), standing(3), setf("q_lancashire_rock_done")],
                 [iff("q_lancashire_rock_started",
                      say("Rock Boiler Maureen", "Go on, take on Liam. He's over by the pulling hook, showing off."),
                      say("Rock Boiler Maureen", "Short-handed, I am! It's switch-on week and the whole town wants rock. Can you pull sugar?",
                          "No? You'll learn. First, see Liam, my apprentice. Beat him and you've earned your apron.") +
                      [setf("q_lancashire_rock_started")])])])])
    script("blackpool_rockfactory", "rock_apprentice", [
        iff("q_lancashire_rock_1",
            say("Apprentice Liam", "Fair play. I'll stick to wrapping. Wrapping can't beat you in a battle."),
            [iff("q_lancashire_rock_started",
                 say("Apprentice Liam", "Maureen says you're the new apprentice? Over my dead sugar. Rock-pulling battle! Loser does the washing up.") +
                 [{"do": "battle", "trainer": "bp_rock_liam", "intro": True}] +
                 say("Apprentice Liam", "Aw, man. Go on then, tell Maureen. I'll get the washing-up gloves.") + [setf("q_lancashire_rock_1")],
                 say("Apprentice Liam", "Mind the slab, it's hot. Boiled sugar sticks to everything. Especially eyebrows."))])])
    quest_trainer("bp_rock_liam", "Apprentice Liam", "Rock Maker", "student",
                  [("bulbkin", 19), ("chipgull", 20), ("duneskink", 20)],
                  ["Hands off my pulling hook!"],
                  "Sticky end, that.", "The red goes on the outside. The letters go in the middle. The sugar goes everywhere.", 1000)
    # the Illuminations depot: Doreen
    room(OUT, "blackpool_depot", "Illuminations Depot", zid, (55, 15), "workshop", [
        {"id": "depot_doreen", "sprite": "lamplighter", "x": 6, "y": 3, "facing": "down", "move": "still", "script": "depot_doreen", "name": "Doreen"},
        {"id": "depot_sparky", "sprite": "steelworker", "x": 10, "y": 5, "facing": "left", "move": "still", "name": "Electrician",
         "text": "We start building next year's lights the week after this year's go off. Rabbits, rockets, a forty-foot Dalek once. It's a strange job, but it's never boring."}],
        extra_props=[P("bunting", 2, 2), P("bunting", 10, 2), P("stage_light", 1, 5), P("slate_stack", 11, 6), P("wall_map", 5, 1, walk=True),
                     P("fae_lantern", 2, 6), P("fae_lantern", 9, 6)])
    script("blackpool_depot", "depot_doreen", [
        iff("q_lancashire_lights_done",
            say("Doreen", "Still glowing? So's the prom. Come back every autumn, the lights run till early November."),
            [iff("q_lancashire_lights_started",
                 say("Doreen", "Fuses from Alf's tram, spare bulbs from Southport Pier, then somebody famous for the switch. Try Uncle Norman at the Winter Gardens: he knows everybody, and he'll tell you so."),
                 say("Doreen", "Oh, thank goodness, a pair of hands! Doreen, Illuminations Depot. It's switch-on night and everything that can go wrong has gone wrong.",
                     "The fuse boxes have blown, I'm short of bulbs, and the celebrity's stuck on the M55 with a flat tyre and a film crew.",
                     "Tram Driver Alf keeps spare fuses in his cab: he's at the tram stop on the prom. Get those, then we'll talk bulbs.") +
                 [setf("q_lancashire_lights_started")])])])
    # the pub, with a pub quiz
    room(OUT, "blackpool_pub", "The Kiss Me Quick Inn", zid, (68, 27), "cafe", [
        {"id": "pub_quizmaster", "sprite": "ceilidh_caller", "x": 9, "y": 3, "facing": "down", "move": "still", "script": "pub_quizmaster", "name": "Quizmaster"},
        {"id": "pub_landlord", "sprite": "shopkeeper", "x": 3, "y": 3, "facing": "up", "move": "still", "name": "Landlord",
         "text": "Hotpot's on. Lancashire hotpot: lamb, onions, sliced potatoes on top, slow in the oven all afternoon. Red cabbage on the side. Don't let a Yorkshireman tell you otherwise."},
        {"id": "pub_hen", "sprite": "festival_goer", "x": 10, "y": 6, "facing": "left", "move": "still", "name": "Hen Party",
         "text": "We've lost the bride. She was last seen heading for the Big One in a veil and a tiara. That's the third time tonight."}],
        extra_props=[P("fireplace", 6, 1), P("wall_picture", 9, 1, walk=True, variant=1), P("band_kit", 11, 1, variant=1)])
    script("blackpool_pub", "pub_quizmaster", say("Quizmaster", "Quiz night at the Kiss Me Quick! Pens ready? No conferring. Well, a bit of conferring.") +
           [{"do": "quiz", "pub": "blackpool_pub", "region": "england_north", "who": "Quizmaster"}])
    # Bloomfield Road
    room(OUT, "blackpool_bloomfield", "Bloomfield Road", zid, (55, 49), "hall", [
        {"id": "bfr_fan", "sprite": "rugby_player", "x": 4, "y": 9, "facing": "up", "move": "still", "name": "Seasiders Fan",
         "text": "Tangerine, not orange. Never orange. Blackpool have played in tangerine since the 1920s, and we're called the Seasiders, obviously."},
        {"id": "bfr_steward", "sprite": "warden_grunt", "x": 12, "y": 9, "facing": "up", "move": "still", "name": "Steward",
         "text": "There's a statue of Sir Stanley Matthews outside. People touch his boot for luck. The boot's very shiny."}],
        w=17, h=13,
        legend={"a": {"tile": "grass", "colour": "#3d6a32"}, "b": {"tile": "grass", "colour": "#457538"}},
        rows=[(2, 2, 13, 7, "a")] + [(2, y, 13, 1, "b") for y in (2, 4, 6, 8)],
        extra_props=[P("stadium_stand", x, 1, variant=x * 3 % 27) for x in range(1, 16)] +
                    [P("pitch_line", 2, 2, variant=13, walk=True), P("pitch_line", 2, 5, variant=13, walk=True),
                     P("floodlight", 2, 2), P("floodlight", 14, 2), P("flagpole", 1, 10), P("flagpole", 15, 10)], drop=("table", "statue"))
    ZB = json.load(open(OUT + "/blackpool_bloomfield.json"))
    ZB["npcs"].append({"id": "bp_tangerine", "sprite": "rugby_player", "x": 8, "y": 6, "facing": "down", "move": "still", "trainer": "bp_tangerine"})
    json.dump(ZB, open(OUT + "/blackpool_bloomfield.json", "w"), indent=1)
    TRN["bp_tangerine"] = {"id": "bp_tangerine", "name": "Season Ticket Holder Dave", "class": "Football Fan", "sprite": "rugby_player",
                           "party": [{"species": s, "level": l} for s, l in [("chipgull", 20), ("binfox", 20), ("strutcoo", 21)]],
                           "ai": "trainer", "money": 1000, "scaled_floor": FLOOR,
                           "intro": say("Season Ticket Holder Dave", "Fifty years I've had this season ticket. My dad had it before me, and he saw Matthews play. Let's have a match!"),
                           "win": "Ah, the referee's blind. Fair result, though.",
                           "after": "1953, the Matthews Final, 4-3 against Bolton. My dad cried, and he never cried, not even at the price of a pint."}


def main(OUT):
    sefton(OUT)
    blackpool(OUT)
    write_all(OUT)
    root = os.path.dirname(os.path.dirname(os.path.abspath(OUT)))
    for s in SHOPS:
        json.dump(s, open(os.path.join(root, "data", "shops", s["id"] + ".json"), "w"))
    import add_memory_coach  # every Sanctuary has a memory coach
    add_memory_coach.main(OUT)


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "data/zones")
