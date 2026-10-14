# Part of england_north.py (exec'd in its namespace): the Wirral Way.

# ====================================================================
# WIRRAL WAY  60 x 72, coast route: Liverpool (north) to Chester (south)
# ====================================================================
w = Z("wirral_way", "Wirral Way", 60, 72, kind="route", region="cheshire", music="route_coast", fill=".",
      weather={"gale": 24, "sunshine": 26, "clear": 24, "drizzle": 14, "fog": 6, "downpour": 6})
w.d["stage"] = "coast"
w.legend["d"] = {"tile": "tall_grass", "colour": "#c9b96d", "prop": "none"}
w.legend["q"] = {"tile": "tall_grass", "colour": "#8a9487", "prop": "none"}
w.legend["r"] = REEDS; w.legend["b"] = BIRCH
w.border("T", 3, gaps=[(26, 0, 3, 3), (26, 69, 3, 3)])
SEA = {}
for y in range(72):
    sw = 8 + int(2.6 * math.sin(y / 5.0)) + int(1.5 * math.sin(y / 2.3))
    SEA[y] = sw
    for x in range(0, sw): w.g[y][x] = "$"
    for x in range(sw, sw + 3):
        if w.g[y][x] in ".T": w.g[y][x] = "s"
# dune ridge with marram grass
hill(w, 17, 14, 8, 10, 2); hill(w, 18, 40, 8, 12, 2); hill(w, 17, 62, 7, 7, 2)
for (cx, cy, rx, ry) in [(16, 12, 4, 6), (19, 30, 4, 4), (18, 42, 4, 6), (15, 56, 3, 4), (20, 22, 2, 3), (17, 64, 3, 3)]:
    ell(w, cx, cy, rx, ry, "d", only=".s")
# Hilbre Island: a sandy islet and a causeway at low tide
for y in range(21, 31):
    for x in range(0, 9): w.g[y][x] = "$"
ell(w, 4, 25, 3.5, 3.2, "s", only="$"); ell(w, 4, 25, 2.2, 2.0, "q", only="s")
w.rect(5, 25, 4, 1, "w")
w.rect(9, 25, 2, 1, "s")
for (x, y) in [(2, 23), (6, 23), (2, 27), (6, 27), (1, 25)]: w.prop("rock", x, y)
w.sign(10, 24, "HILBRE ISLAND. Walk out at low tide, seals say hello, the tide says 'you've got two hours'.")
# the seal cove (Brook-wade): rocky ring, deep channel
for y in range(46, 62):
    for x in range(0, 12): w.g[y][x] = "$"
w.rect(2, 48, 9, 13, "s"); w.rect(1, 47, 11, 1, "R"); w.rect(1, 61, 11, 1, "R"); w.rect(1, 48, 1, 13, "R"); w.rect(11, 48, 1, 13, "R")
w.rect(2, 61, 9, 1, "R")
ell(w, 6, 54, 3, 4, "q", only="s")
w.rect(11, 53, 1, 3, "o"); w.rect(12, 53, 1, 3, "o")
w.rect(13, 47, 3, 15, "s"); w.rect(13, 53, 3, 3, "s")
for (x, y) in [(3, 50), (9, 58), (4, 59), (8, 49)]: w.prop("rock", x, y)
w.sign(12, 52, "SEAL COVE. Very deep, very private, very much not for your socks.")
# the old railway line, now a path: winding route south
ROUTE = [(27, 0), (27, 8), (34, 8), (34, 22), (26, 22), (26, 36), (34, 36), (34, 50), (27, 50), (27, 71)]
path(w, ROUTE, ".", 3); w.border("T", 3, gaps=[(26, 0, 3, 3), (26, 69, 3, 3)]); path(w, ROUTE, "#", 1)
# hedges: Wirral Way cutting
for (x, y0, y1) in [(35, 9, 21), (33, 9, 21), (25, 23, 35), (27, 23, 35), (35, 37, 49), (33, 37, 49)]:
    for y in range(y0, y1 + 1):
        if (y - y0) % 7 not in (3, 4): w.set(x, y, "H")
w.rect(35, 15, 1, 1, "."); w.rect(25, 29, 1, 1, ".")
# inland farmland
for (x, y, ww, hh) in [(38, 5, 18, 12), (38, 20, 18, 10), (38, 33, 18, 11), (38, 47, 18, 18)]:
    w.rect(x, y, ww, hh, "."); w.rect(x, y, ww, 1, "H"); w.rect(x, y + hh - 1, ww, 1, "H"); w.rect(x, y, 1, hh, "H")
    w.rect(x, y + hh // 2, 1, 2, ".")
w.building(43, 8, 6, 3, "white_render", "Hill Farm")
w.building(42, 36, 5, 3, "chapel", "St Bartholomew's")
w.building(42, 50, 7, 3, "white_render", "The Boathouse, Parkgate")
w.building(50, 50, 4, 3, "slate_cottage", show_label=False)
w.building(42, 56, 5, 3, "cream_render", show_label=False); w.building(49, 56, 5, 3, "red_brick", show_label=False)
w.rect(40, 53, 16, 1, ":"); w.rect(40, 59, 16, 1, ":")
ell(w, 47, 25, 3, 2, "d", only="."); ell(w, 52, 40, 3, 2, "d", only="."); ell(w, 45, 14, 3, 1, "d", only=".")
w.rect(47, 20, 1, 12, "."); w.rect(38, 26, 1, 2, ".")
# Old station on the Wirral Way
w.building(28, 26, 6, 2, "station", "Heswall Halt (disused)", door=2)
w.rect(28, 28, 6, 1, "_"); w.rect(28, 29, 6, 1, "#")
w.rect(27, 26, 1, 3, "#"); w.rect(34, 26, 1, 3, "#")
# Leasowe-ish lighthouse on the north dunes
w.prop("lighthouse", 16, 4)
w.sign(14, 6, "LEASOWE LIGHTHOUSE. Built 1763, the oldest brick lighthouse in Britain. It has seen things, mostly weather.")
# pools and reeds on the Dee marsh at Parkgate
ell(w, 20, 52, 3, 2, "~", only=".s"); ell(w, 21, 66, 3, 2, "~", only=".sd"); ell(w, 22, 8, 2, 2, "~", only=".sd")
w.rect(18, 49, 6, 1, "r"); w.rect(19, 68, 5, 1, "r")
# woods and scrub
w.scatter(3, 3, 54, 66, "T", 140, 501, only="."); w.scatter(3, 3, 54, 66, "b", 70, 502, only="."); w.scatter(3, 3, 54, 66, "P", 30, 503, only=".")
path(w, ROUTE, ".", 3); w.border("T", 3, gaps=[(26, 0, 3, 3), (26, 69, 3, 3)]); path(w, ROUTE, "#", 1)
w.rect(28, 28, 6, 1, "_"); w.rect(28, 29, 6, 1, "#")
# signs
w.sign(29, 3, "WIRRAL WAY. Twelve miles of old railway, sixty years of bicycle. North: Liverpool.")
w.sign(28, 67, "SOUTH: Chester. Roman walls, shops on top of shops. Start walking, stop at the Rows.")
w.sign(35, 23, "THE DEE ESTUARY. Used to be a port. The sea moved out and left the sand behind. Rude.")
w.sign(25, 45, "PARKGATE. Famous for ice cream, marshes and an incredibly hostile swan.")
w.sign(33, 7, "THURSTASTON COMMON. Gorse, heather and a famous sandstone hill that 'looks a bit like a lump'.")
# NPCs
w.npc(id="wirral_keeper", sprite="villager_4", x=25, y=5, facing="right", move="still", script="lighthouse_fan", name="Lighthouse Fan")
w.npc(id="wirral_tide", sprite="villager_2", x=11, y=27, facing="up", move="wander", script="tide_walker", name="Tide Walker")
w.npc(id="wirral_cyclist", sprite="jogger", x=27, y=14, facing="down", move="pace", script="cyclist", name="Cyclist")
w.npc(id="wirral_icecream", sprite="villager_3", x=45, y=54, facing="down", move="still", script="icecream", name="Ice Cream Seller")
w.npc(id="wirral_seal", sprite="villager_5", x=6, y=51, facing="down", move="still", script="seal_whisperer", name="Seal Whisperer")
for t in [("wirral_surfer", "Kitesurfer Tash", "Surfer", "surfer", [("pupplash", 20), ("chipgull", 21)], 680, 24, 12, "right",
           ["The wind's brilliant today! Gale-force and glorious!", "Fancy a go? On the board or in a fight?"],
           "I'm blown away. By the wind, mostly.", "I once got dragged halfway to Anglesey. Best day of my life."),
          ("wirral_birder", "Birdwatcher Moira", "Birdwatcher", "birdwatcher", [("starlet", 21), ("swiftlet", 21), ("chipgull", 22)], 740, 36, 15, "left",
           ["Eighty thousand waders on the Dee in winter. Do you see one now? No. Shh.", "Exactly. Binoculars up."],
           "That scared the knot off the flock. Never mind.", "I counted three hundred oystercatchers and then lost count. Typical."),
          ("wirral_angler", "Angler Colm", "Angler", "angler", [("pinchkin", 21), ("pupplash", 21), ("minkshade", 22)], 760, 24, 31, "right",
           ["Bass, flounder, the odd old boot. What I'd really like is a rematch with that crab.", "Yes, that one."],
           "Crabbed by a person. Not the same.", "The tide here comes in faster than a horse. I speak from experience."),
          ("wirral_dog", "Dog Walker Brenda", "Dog Walker", "villager_6", [("duneskink", 20), ("natterjack", 21)], 680, 32, 45, "left",
           ["Biscuit! Come here! Biscuit's found a toad. Biscuit always does.", "Let's settle this."],
           "Biscuit's judging me. Fair.", "We do the Wirral Way twice a day. Well, I do. Biscuit does it four times.")]:
    tid, nm, cls, spr, party, money, x, y, facing, intro, win, after = t
    trainer(tid, nm, cls, spr, party, money, intro, win, after)
    w.npc(id=tid, sprite=spr, x=x, y=y, facing=facing, move="still", trainer=tid)
say("wirral_way", "lighthouse_fan", "Lighthouse Fan", "That's Leasowe Lighthouse, built in 1763. The oldest brick-built lighthouse in Britain.", "It shone out over the Mersey long before anyone had heard of satnav. Honestly, it's better than satnav.")
say("wirral_way", "tide_walker", "Tide Walker", "Hilbre Island! You can walk out at low tide, two hours either side. Miss it and you wait for the next tide. Twelve hours.", "There's a colony of grey seals out there. Hundreds. They pretend not to notice you.")
say("wirral_way", "cyclist", "Cyclist", "This path was the Hooton to West Kirby railway until 1962. Now it's twelve miles of flat, tree-lined cycling.", "I do it every Sunday. I'd say it's relaxing if the geese would stop heckling.")
say("wirral_way", "icecream", "Ice Cream Seller", "Parkgate used to be a port. Ships sailed from here to Ireland. Then the River Dee silted up and left us a marsh.", "Now we sell ice cream to people looking at where the sea used to be. It's good business.")
DLG["wirral_way"]["seal_whisperer"] = [
    {"do": "say", "who": "Seal Whisperer", "text": "Shh. Not so loud. You waded through the channel? Brave. Or silly. Possibly both."},
    {"do": "if", "flag": "seal_cove_gift",
     "then": [{"do": "say", "who": "Seal Whisperer", "text": "The seals like you. That's all I'll say. They're very judgemental."}],
     "else": [{"do": "say", "who": "Seal Whisperer", "text": "Here, take these. The seals insist. They don't know what a snare is, but they know a good bag when they see one."},
              {"do": "give_item", "item": "water_snare", "n": 5},
              {"do": "set", "flag": "seal_cove_gift"}]}]
w.d["encounters"] = {"grass": [
    {"species": "pupplash", "min": 20, "max": 22, "weight": 22},
    {"species": "duneskink", "min": 20, "max": 22, "weight": 18, "weather": ["clear", "sunshine", "gale"]},
    {"species": "natterjack", "min": 20, "max": 22, "weight": 16, "weather": ["drizzle", "downpour", "gale", "fog"]},
    {"species": "pinchkin", "min": 20, "max": 22, "weight": 18},
    {"species": "chipgull", "min": 20, "max": 22, "weight": 16},
    {"species": "starlet", "min": 20, "max": 22, "weight": 12, "time": ["dawn", "day", "dusk"]},
    {"species": "minkshade", "min": 21, "max": 22, "weight": 10, "time": ["dusk", "night"]},
    {"species": "cooplet", "min": 20, "max": 21, "weight": 8},
    {"species": "hootlet", "min": 20, "max": 22, "weight": 10, "time": ["dusk", "night"]}],
    "water": [
    {"species": "pupplash", "min": 21, "max": 23, "weight": 40},
    {"species": "pinchkin", "min": 21, "max": 22, "weight": 25},
    {"species": "chipgull", "min": 20, "max": 22, "weight": 20},
    {"species": "minkshade", "min": 21, "max": 22, "weight": 15}]}
w.d["edges"] = {"north": {"to": "liverpool", "offset": 0}, "south": {"to": "chester", "offset": 0}}
w.d["spawn"] = [27, 4]
deco(w, 14, 3, 42, 66, ["bush", "rock", "birch"], 70, 511, on=".d")
reedify(w, 0.5, 523)
deco(w, 0, 0, 12, 72, ["buoy", "rock"], 8, 521, on="$")
for (x, y, v) in [(4, 8, 1), (3, 38, 1), (5, 66, 1), (2, 15, 0)]:
    w.prop("boat", x, y, variant=v) if w.g[y][x] == "$" else None
deco(w, 8, 3, 8, 66, ["rock", "bollard", "bench"], 10, 522, on="s")
w.save(OUT + "/wirral_way.json")
