# 3.0 "Wider Isles", region agent fife: north from Edinburgh over the Forth to the Kingdom of Fife and Dundee.
#   forth_bridges (route): South Queensferry, the three Forth bridges, Inchcolm, seals, the Fife Coastal Path, Culross
#   st_andrews (town): the Old Course, the cathedral and castle, the university, West Sands, the pier
#   dundee (town): RRS Discovery, V&A Dundee, the Tay bridges, jute, jam and journalism, McGonagall
# Usage: python3 tools/zones/sc_fife.py data/zones   (writes zones, their interiors, dialogue and trainers)
import sys
from p6a_common import *
from wcommon import _stand
from zlib import landmark

SCOT = "scotland"
FLOOR = 69          # Edinburgh's band: every zone and trainer here is scaled from it
WX_EAST = {"drizzle": 30, "clear": 22, "fog": 16, "gale": 12, "sunshine": 14, "downpour": 6}


def plaque(z, x, y, pid, title, text):
    """a heritage plaque (a sign the Gazetteer collects): unique id, short title, 2-3 true sentences."""
    _stand(z, x, y)
    z.d["signs"].append({"x": x, "y": y, "plaque": pid, "title": title, "text": text})


def enter(z, x, y, zid, w=13, h=10):
    """the warp on a door tile into a landmark interior built with landmark(..., w, h)."""
    z.warp(x, y, zid, w // 2, h - 3, "up")


def scaled(tids):
    for t in tids:
        TRN[t]["scaled_floor"] = FLOOR


def wild_set(z, rows, kind="grass"):
    wild(z, [(sp, FLOOR, FLOOR + 1, wt, extra) for (sp, wt, extra) in rows], kind)


def interior(OUT, zid, name, town, ret, kind, npcs, w=13, h=10, props=(), signs=(), rows=None):
    z = landmark(OUT, zid, name, town, ret, kind, npcs, w=w, h=h, write=False)
    for (t, x, y, kw) in props:
        clear_prop(z, x, y)
        z.prop(t, x, y, **kw)
    for (x, y, text) in signs:
        z.d["signs"].append({"x": x, "y": y, "text": text})
    if rows:
        for (x, y, w2, h2, ch) in rows:
            z.rect(x, y, w2, h2, ch)
    finish(z)
    z.save(OUT + "/" + zid + ".json")
    return z


def npc(id, sprite, x, y, script=None, facing="down", move="still", name=None, **kw):
    d = {"id": id, "sprite": sprite, "x": x, "y": y, "facing": facing, "move": move}
    if script:
        d["script"] = script
    if name:
        d["name"] = name
    d.update(kw)
    return d


def cmd_if(flag, then, els=None, eq=None):
    c = {"do": "if", "flag": flag, "then": then}
    if els is not None:
        c["else"] = els
    if eq is not None:
        c["eq"] = eq
    return c


def setf(flag, value=True):
    return {"do": "set", "flag": flag, "value": value}


def give(item, n=1):
    return {"do": "give_item", "item": item, "n": n}


def choice(text, options, flag):
    return {"do": "choice", "text": text, "options": options, "set": flag}


# =====================================================================================================
# forth_bridges
# =====================================================================================================

def forth_bridges(OUT):
    W, H = 64, 72
    zid = "forth_bridges"
    z = Z(zid, "The Forth Bridges", W, H, kind="route", region=SCOT, music="route_coast", weather=WX_EAST)
    z.d["stage"] = "coast"
    z.d["scaled_floor"] = FLOOR
    z.border("T", 2, gaps=[(25, 0, 3, 2), (25, 70, 3, 2)])
    z.scatter(0, 0, W, H, "P", 30, 71, only="T")
    # the Firth of Forth
    z.rect(0, 14, W, 32, "$")
    z.rect(0, 14, W, 1, "w"); z.rect(0, 45, W, 1, "w")
    z.rect(0, 14, 2, 1, "T"); z.rect(62, 14, 2, 1, "T"); z.rect(0, 45, 2, 1, "T"); z.rect(62, 45, 2, 1, "T")
    z.rect(2, 13, 60, 1, "s"); z.rect(2, 46, 60, 1, "s")
    # the road: straight over the Forth Road Bridge, Edinburgh to Fife
    z.rect(25, 0, 3, H, "=")
    z.building(24, 14, 1, 32, "road_bridge", show_label=False)
    z.building(28, 14, 1, 32, "bridge_girder", show_label=False)
    # the Forth Bridge: three cantilevers on piers, with approach viaducts on each shore
    for y in (16, 40):
        z.building(42, y, 4, 2, "forth_bridge", show_label=False)
    z.rect(40, 26, 8, 6, "s"); z.rect(40, 26, 1, 1, "R"); z.rect(47, 31, 1, 1, "R"); z.rect(47, 26, 1, 1, "R")
    z.building(42, 28, 4, 2, "forth_bridge", show_label=False)
    z.building(43, 3, 2, 8, "forth_approach", show_label=False)
    z.building(43, 47, 2, 4, "forth_approach", show_label=False)
    # the Queensferry Crossing, further up the firth
    for y in (18, 29, 40):
        z.building(17, y, 1, 1, "cable_stayed", show_label=False)
    # Inchcolm, its abbey, and the seals' rocks
    island(z, 52, 22, 10, 8)
    z.building(54, 23, 5, 3, "chapel", "Inchcolm Abbey")
    for (x, y) in [(50, 20), (51, 33), (60, 32), (49, 24)]:
        z.set(x, y, "R")
    # ---- the Fife shore: Culross to the west, the coastal path east ----
    z.rect(3, 8, 22, 2, ":")                       # Culross's causey
    z.building(4, 4, 8, 4, "culross_palace", "Culross Palace", door=3)
    enter(z, 7, 7, "forth_bridges_palace")
    z.building(13, 4, 4, 4, "crow_step", "The Study")
    z.building(18, 4, 5, 4, "crow_step", "Girdlesmith's Forge", door=2)
    enter(z, 20, 7, "forth_bridges_girdle", 11, 9)
    z.building(3, 10, 5, 3, "crow_step", "Mid Causeway")
    z.prop("statue", 11, 11, variant=2)
    z.prop("bench", 13, 11); z.prop("lamp_post", 9, 10); z.prop("lamp_post", 22, 10)
    z.rect(28, 11, 34, 1, "#")                     # the Fife Coastal Path
    blob(z, 34, 6, 6, 3, ",", only=".", seed=11, jitter=0.4)
    blob(z, 52, 7, 7, 3, ",", only=".", seed=12, jitter=0.4)
    z.rect(46, 12, 16, 1, "s")
    for (x, y) in [(48, 13), (55, 13), (60, 12)]:
        z.set(x, y, "R")
    scatter_props(z, "bush", 30, 2, 30, 8, 8, 13, avoid=(".",))
    # ---- South Queensferry ----
    z.rect(3, 52, 58, 2, ":")                      # the High Street
    z.building(36, 47, 7, 4, "crow_step", "The Hawes Inn", door=3)
    enter(z, 39, 50, "forth_bridges_hawes")
    z.rect(36, 51, 7, 1, ":")
    z.building(10, 47, 7, 4, "stone", "Queensferry Museum", door=3)
    enter(z, 13, 50, "forth_bridges_museum")
    z.rect(10, 51, 7, 1, ":")
    z.building(4, 55, 6, 4, "crow_step", "Hopetoun Road")
    z.building(30, 55, 7, 4, "crow_step", "Shore Road")
    z.building(46, 55, 6, 4, "crow_step", "East Terrace")
    z.building(53, 55, 6, 4, "crow_step", "Plewlands")
    for (x, y) in [(8, 51), (20, 51), (34, 51), (48, 51), (58, 51)]:
        z.prop("lamp_post", x, y)
    z.prop("bench", 22, 51); z.prop("bench", 46, 51)
    blob(z, 12, 64, 8, 3, ",", only=".", seed=13, jitter=0.4)
    blob(z, 46, 64, 9, 3, ",", only=".", seed=14, jitter=0.4)
    scatter_props(z, "oak", 3, 60, 58, 9, 10, 15, avoid=(".",))
    # ---- plaques ----
    plaque(z, 41, 46, "fife_forth_bridge", "The Forth Bridge",
           "Opened on 4 March 1890: a cantilever railway bridge about two and a half kilometres long, built from some 54,000 tonnes of steel. For years it had the longest spans in the world, and since 2015 it has been a UNESCO World Heritage Site.")
    plaque(z, 47, 46, "fife_painting_forth", "Painting the Forth Bridge",
           "A job that never ends, says the saying: by the time the painters reached one end, the other end needed doing again. A new coat finished in 2011 should last at least twenty-five years, so the saying is having a rest.")
    plaque(z, 29, 46, "fife_road_bridge", "The Forth Road Bridge",
           "A suspension bridge opened by the Queen in 1964, for a while the longest of its kind outside America. Since the Queensferry Crossing opened beside it in 2017 it carries buses, bikes and people on foot. Like you.")
    plaque(z, 19, 46, "fife_queensferry_crossing", "The Queensferry Crossing",
           "Opened in 2017, the longest three-tower cable-stayed bridge in the world. Stand here and you can see bridges from three different centuries, all doing the same job.")
    plaque(z, 59, 46, "fife_inchcolm", "Inchcolm",
           "The island out in the firth holds Inchcolm Abbey, sometimes called the Iona of the East, the best-preserved medieval monastery in Scotland. Grey seals haul out on the rocks round it.")
    plaque(z, 2, 9, "fife_culross", "Culross",
           "In the 1500s and 1600s Culross grew rich on coal and salt, then trade moved away and the little town went quiet, which is why its cobbled wynds and red-roofed houses survive. The National Trust for Scotland has cared for it since the 1930s.")
    plaque(z, 12, 10, "fife_crown_causey", "The Crown of the Causey",
           "The raised strip down the middle of Culross's cobbled street was kept for the gentry. Everyone else walked at the sides, nearer the gutter. Walk where you like; nobody is checking.")
    plaque(z, 29, 10, "fife_coastal_path", "The Fife Coastal Path",
           "Over a hundred miles of footpath round the Kingdom of Fife, from the Forth bridges to the Tay. Fife has called itself the Kingdom for centuries, and Robert the Bruce is buried in Dunfermline Abbey.")
    plaque(z, 24, 54, "fife_burry_man", "The Burry Man",
           "On the second Friday in August a South Queensferry man is covered head to toe in sticky burdock burrs and walks round the town all day, sipping whisky through a straw. Nobody knows quite why, which is the best kind of custom.")
    z.sign(28, 69, "NORTH: The Forth Road Bridge, Fife, St Andrews. SOUTH: Edinburgh.")
    z.sign(28, 2, "SOUTH: The Forth bridges, Edinburgh. NORTH: St Andrews, then over the Tay to Dundee.")
    # ---- folk ----
    chat(z, "fb_burryman", "villager_3", 23, 55, "Ferry Fair Fan",
         ["Every August a man walks round this town covered in burrs. Head to toe. They stick to him and he sticks to the route, nine hours of it, and folk give him a dram through a straw.",
          "Is it for luck? Is it to chase off bad spirits? Is it because it's August? Aye. All of those."], "down", "still")
    chat(z, "fb_seal_watcher", "birdwatcher", 51, 11, "Seal Watcher",
         ["Grey seals on the rocks there. Grey seal pups are born white and fluffy in the autumn, and they can't swim for weeks. Not my favourite fact. My favourite is that they sing.",
          "Puffins nest out on the Isle of May, further down the firth, and the gannets on the Bass Rock make it look snowy from the shore. The whole Forth is heaving with birds."], "right", "still")
    chat(z, "fb_culross_guide", "tour_guide", 15, 10, "Culross Guide",
         ["Culross's laird, Sir George Bruce, dug a coal mine that ran out under the Forth, with a shaft on an artificial island in the sea. King James VI came to visit, came up the shaft, saw water all round him and thought he'd been kidnapped.",
          "The palace is ochre because it's harled and limewashed. People call the colour Culross yellow. It glows on a dull day, and Fife has a lot of dull days to practise on."], "down", "still")
    for (sid, sp, x, y, line) in [("fb_seal_1", "greyhaul", 49, 12, "The seal opens one eye, decides you are not a fish, and closes it again."),
                                  ("fb_seal_2", "pupplash", 57, 12, "A seal pup flumps along the sand towards you, then thinks better of it and flumps back.")]:
        z.set(x, y, "s")
        z.npc(id=sid, sprite="creature:" + sp, x=x, y=y, facing="down", move="still", script=sid)
        script(zid, sid, say("Seal", line))
    trainer(z, "fb_painter", "Painter Morag", "Bridge Painter", "bridge_painter",
            [("railspark", 69), ("rivetling", 69), ("cassiterix", 70)], 40, 52, "up",
            ["You know the saying? 'Like painting the Forth Bridge.' Never finished. Well, I finished. 2011. Twenty-five years of guarantee. So now I have time on my hands, and a lot of red paint, and you."],
            "Fair enough. Mind, you've got a bit of red on your sleeve. That's tradition.",
            "Two hundred and forty thousand litres of paint, near enough, to do the whole bridge. I counted the tins. Somebody had to.", 2900)
    trainer(z, "fb_walker", "Walker Ishbel", "Coastal Walker", "hiker",
            [("ternlet", 69), ("plungebeak", 69), ("haarling", 70)], 40, 11, "left",
            ["I'm doing the whole Fife Coastal Path. It's a hundred and something miles. I'm on mile three. There was a very good cafe at mile two."],
            "Well walked. Away and get a scone, you've earned it.",
            "The haar rolls in off the North Sea on a warm day and you can't see your own boots. The locals call it the haar. The visitors call it 'what is happening'.", 2800)
    trainer(z, "fb_skipper", "Skipper Angus", "Boat Skipper", "fisher",
            [("greyhaul", 69), ("selkie", 70), ("puffling", 69)], 30, 49, "left",
            ["I run the boat out to Inchcolm. Abbey, seals, puffins if you're lucky, and me telling you about the abbey, the seals and the puffins whether you're lucky or not."],
            "Aye, you've got your sea legs right enough.",
            "Inchcolm Abbey was founded after a king was shipwrecked there and a hermit fed him on shellfish for three days. Alexander the First. He was very grateful. Or very full.", 2850)
    scaled(["fb_painter", "fb_walker", "fb_skipper"])
    wild_set(z, [("railspark", 10, {}), ("cooplet", 10, {}), ("ternlet", 12, {}), ("gannetling", 10, {}), ("chipgull", 10, {}),
                 ("starlet", 8, {"time": ["dusk", "dawn"]}), ("haarling", 10, {"weather": ["fog", "drizzle"]}),
                 ("flittermouse", 8, {"time": ["night"]}), ("thistlet", 8, {}), ("divotling", 4, {})])
    wild_set(z, [("pupplash", 22, {}), ("selklet", 12, {}), ("gannetling", 16, {}), ("puffling", 12, {}), ("dolphlet", 8, {"time": ["day"]}),
                 ("stalklet", 10, {})], "water")
    z.d["edges"] = {"south": {"to": "edinburgh", "offset": 7}, "north": {"to": "st_andrews", "offset": 5}}
    z.d["spawn"] = [26, 66]
    finish(z)
    z.save(OUT + "/" + zid + ".json")

    # ---- interiors ----
    interior(OUT, "forth_bridges_hawes", "The Hawes Inn", zid, (39, 51), "cafe",
             [npc("fb_landlord", "villager_2", 3, 1, "fb_landlord", name="Landlord"),
              npc("fb_drinker", "fisherman_north", 9, 3, "fb_drinker", name="Regular", facing="left")],
             props=[("fireplace", 6, 1, {"walk": True})])
    script("forth_bridges_hawes", "fb_landlord", say("Landlord",
           "Welcome to the Hawes. Robert Louis Stevenson sat in here and put the place in Kidnapped: young David Balfour is lured from this inn on to a ship bound for the Carolinas.",
           "Fancy a go at the quiz? Questions on the whole of Scotland. Losers buy the crisps.") +
           [{"do": "quiz", "pub": "forth_bridges_hawes", "region": "scotland", "who": "Landlord"}])
    script("forth_bridges_hawes", "fb_drinker", say("Regular",
           "Forty years I've watched that bridge out the window. Trains go over every few minutes. I wave. They don't wave back. Rude, trains.",
           "My granny said the rivets were counted on the day it opened: six and a half million. The last one was gold. They say. I've never found it. I've looked."))
    interior(OUT, "forth_bridges_museum", "Queensferry Museum", zid, (13, 51), "museum",
             [npc("fb_curator", "tour_guide", 6, 4, "fb_curator", name="Curator")])
    script("forth_bridges_museum", "fb_curator", say("Curator",
           "This is our Burry Man, or a model of him. Every second Friday in August a real one walks the town, so covered in burrs he can barely bend his arms.",
           "Before the bridges there was the Queen's Ferry, named for Queen Margaret, who paid for a ferry for pilgrims heading to St Andrews in the eleventh century. A ferry ran here for about nine hundred years.",
           "The last car ferry sailed the day the Road Bridge opened in 1964. The boats were sold off. One went to be a floating restaurant. Everyone has to retire somewhere."))
    interior(OUT, "forth_bridges_palace", "Culross Palace", zid, (7, 8), "hall",
             [npc("fb_palace_guide", "tour_guide", 9, 4, "fb_palace_guide", name="Palace Guide")])
    script("forth_bridges_palace", "fb_palace_guide", say("Palace Guide",
           "Sir George Bruce built this house round about 1600, with money from coal and salt. Look up: the wooden ceilings are painted with pictures and little moral sayings, so you could improve yourself while lying in bed.",
           "Out the back there's a terraced garden with herbs, vegetables and Scots Dumpy hens. The hens are not historical, but they are very committed."))
    interior(OUT, "forth_bridges_girdle", "Girdlesmith's Forge", zid, (20, 8), "workshop",
             [npc("fb_girdlesmith", "steelworker", 5, 1, "fb_girdlesmith", name="Girdlesmith")], w=11, h=9)
    script("forth_bridges_girdle", "fb_girdlesmith", [
        cmd_if("q_fife_discovery_started", [
            cmd_if("q_fife_discovery_3", say("Girdlesmith", "Mind and season that girdle before the Antarctic. A wee bit of fat, a good heat. Oatcakes on the ice! I'm jealous, and I don't even like the cold."),
                   say("Girdlesmith", "A girdle for the Discovery? For oatcakes at the bottom of the world? Oh, that's the best order I've had all year.",
                       "In 1599 King James the Sixth gave the hammermen of Culross the sole right to make girdles in Scotland. Every girdle in every kitchen came from this wee town.",
                       "Here. Hammered round, flat as the Forth on a good day. Take it to the Bosun with my compliments.") +
                   [give("culross_girdle"), setf("q_fife_discovery_3")])
        ], say("Girdlesmith", "A girdle is a flat iron plate you bake on over the fire: oatcakes, scones, drop scones, pancakes. Up here we say girdle. Down south they say griddle. They're wrong, nicely.",
               "Culross had the monopoly on them from 1599. A royal monopoly. On a frying pan. It was a big deal at the time."))])


# =====================================================================================================
# st_andrews
# =====================================================================================================

def st_andrews(OUT):
    W, H = 72, 64
    zid = "st_andrews"
    z = Z(zid, "St Andrews", W, H, kind="town", region=SCOT, music="town_scotland", weather=WX_EAST)
    z.d["stage"] = "coast"; z.d["town_id"] = "st_andrews"; z.d["scaled_floor"] = FLOOR
    z.legend["v"] = {"tile": "grass", "colour": "#7fae4a"}   # fairway
    z.legend["u"] = {"tile": "grass", "colour": "#98c860"}   # green
    z.border("T", 2, gaps=[(30, 62, 3, 2), (4, 0, 3, 2)])
    z.scatter(0, 0, W, H, "P", 30, 72, only="T")
    # the North Sea to the east and St Andrews Bay to the north, the West Sands between
    z.rect(10, 0, 62, 4, "$"); z.rect(10, 4, 50, 1, "w"); z.rect(10, 5, 42, 3, "s")
    z.rect(64, 0, 8, H, "$"); z.rect(63, 5, 1, H - 7, "w")
    z.rect(60, 5, 3, 32, "^")                      # the cliffs under the castle and the Scores
    # ---- the Old Course ----
    z.rect(8, 9, 40, 20, "v")
    blob(z, 12, 12, 4, 2, ",", only="v", seed=21, jitter=0.5)
    blob(z, 44, 11, 4, 2, ",", only="v", seed=22, jitter=0.5)
    blob(z, 30, 20, 5, 2, ",", only="v", seed=23, jitter=0.5)
    blob(z, 10, 22, 2, 4, ",", only="v", seed=24, jitter=0.5)
    blob(z, 24, 13, 2, 1.5, "s", only="v", seed=25)      # Hell Bunker
    blob(z, 14, 17, 1.5, 1, "s", only="v", seed=26)      # the Road Hole bunker
    blob(z, 38, 15, 1.2, 1, "s", only="v", seed=27)
    blob(z, 40, 24, 1.2, 1, "s", only="v", seed=28)
    for (cx, cy) in [(16, 15), (28, 11), (40, 19), (20, 23)]:
        blob(z, cx, cy, 2, 1.3, "u", only="v", seed=cx)
        z.prop("flag", cx, cy, variant=cx % 3)
    z.rect(10, 26, 30, 1, "~")                     # the Swilcan Burn
    z.rect(22, 26, 2, 1, ":")                      # and its bridge
    z.rect(28, 28, 8, 1, "u")                      # the first tee
    # ---- the R&A, the museum, the Jigger Inn ----
    z.building(18, 30, 9, 4, "stone", "Royal and Ancient Clubhouse")
    z.building(36, 30, 7, 4, "stone", "British Golf Museum", door=3)
    enter(z, 39, 33, "st_andrews_golf_museum")
    z.building(2, 18, 6, 4, "crow_step", "The Jigger Inn", door=3)
    enter(z, 5, 21, "st_andrews_jigger")
    z.rect(2, 22, 6, 1, "#"); z.rect(8, 22, 1, 1, "#")
    # ---- the road north, past the course to Guardbridge and the Tay ----
    z.rect(4, 0, 3, 9, "="); z.rect(4, 9, 3, 1, "#"); z.rect(2, 9, 2, 1, ".")
    # ---- streets ----
    z.rect(28, 29, 8, 1, "#")
    z.rect(30, 30, 3, 32, "=")                     # the road in from the south, up to the first tee
    z.rect(4, 36, 54, 2, ":")                      # North Street
    z.rect(4, 44, 40, 2, ":")                      # Market Street
    z.rect(4, 52, 54, 2, ":")                      # South Street
    z.rect(4, 34, 2, 20, ":")
    z.rect(56, 14, 2, 40, ":")                     # along the cliffs: the castle to the cathedral
    z.rect(36, 34, 22, 1, "#")                     # the Scores
    # ---- castle, monument, cathedral, harbour ----
    z.building(48, 9, 9, 5, "castle", "St Andrews Castle", door=4)
    enter(z, 52, 13, "st_andrews_castle", 15, 11)
    z.rect(52, 14, 4, 1, ":")
    z.building(46, 32, 1, 1, "obelisk", show_label=False)
    z.building(44, 39, 12, 7, "st_andrews_ruin", "St Andrews Cathedral", door=6)
    enter(z, 50, 45, "st_andrews_cathedral", 15, 11)
    z.rect(44, 46, 14, 1, ":")
    z.rect(58, 46, 6, 10, "$"); z.rect(58, 46, 1, 10, "w")
    z.rect(58, 49, 12, 2, ":")                     # the pier
    for x in (60, 64, 68):
        z.prop("bollard", x, 51)
    z.prop("lighthouse", 69, 48)
    z.prop("boat", 61, 47, variant=1); z.prop("boat", 62, 54, variant=1)
    # ---- town buildings ----
    z.building(8, 39, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(11, 42, "st_andrews_sanctuary", 5, 6, "up")
    z.building(15, 39, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(17, 42, "st_andrews_shop", 4, 5, "up")
    z.building(22, 39, 7, 4, "chapel", "St Salvator's Chapel", door=3)
    enter(z, 25, 42, "st_andrews_salvators")
    z.rect(8, 43, 22, 1, ":")
    for (x, y, w, lab) in [(34, 39, 6, "North Street"), (6, 47, 7, "Market Street"), (14, 47, 6, "Bell Street"), (21, 47, 8, "Church Street"),
                           (34, 47, 8, "College Street"), (6, 55, 8, "South Street"), (15, 55, 7, "Queen's Terrace"), (34, 55, 8, "Abbey Walk"), (44, 55, 8, "Pends Road")]:
        z.building(x, y, w, 4 if y != 55 else 4, "crow_step", lab)
    blob(z, 14, 59, 7, 2, ",", only=".", seed=29, jitter=0.4)
    blob(z, 48, 59, 7, 2, ",", only=".", seed=30, jitter=0.4)
    for (x, y) in [(7, 38), (20, 38), (36, 38), (50, 38), (7, 46), (20, 46), (36, 46), (7, 54), (24, 54), (42, 54)]:
        z.prop("lamp_post", x, y)
    z.prop("bench", 40, 35); z.prop("bench", 52, 35); z.prop("bench", 54, 48)
    # ---- plaques ----
    plaque(z, 34, 28, "fife_old_course", "The Old Course",
           "Golf has been played on these links since at least the early 1400s, which is why St Andrews is called the home of golf. In 1457 King James II banned golf and football because they kept men away from archery practice. It didn't take.")
    plaque(z, 21, 27, "fife_swilcan_bridge", "The Swilcan Bridge",
           "A little stone bridge over the Swilcan Burn on the 1st and 18th holes, hundreds of years old and built for shepherds and their flocks. Every golfer who plays the 18th stops on it for a photograph.")
    plaque(z, 17, 17, "fife_road_hole", "The Road Hole",
           "The 17th hole, named for the old road that runs beside its green. Its small, deep bunker in front of the green has wrecked the scores of champions. So has the road.")
    plaque(z, 26, 15, "fife_hell_bunker", "Hell Bunker",
           "The huge bunker on the 14th hole. Its steep face is built from stacked layers of turf, called revetting, rebuilt by hand. Golfers who go in are allowed to say what they like.")
    plaque(z, 27, 34, "fife_royal_ancient", "The Royal and Ancient",
           "The golf club was founded in 1754 as the Society of St Andrews Golfers, and became the Royal and Ancient in 1834. The clubhouse looks down the 1st and 18th fairways.")
    plaque(z, 43, 33, "fife_martyrs", "The Martyrs' Monument",
           "This obelisk on the Scores, put up in 1842, remembers the Protestant martyrs burned in St Andrews in the years before the Reformation of 1560.")
    plaque(z, 43, 46, "fife_cathedral", "St Andrews Cathedral",
           "Begun in 1158, it was the biggest church in medieval Scotland, the heart of the Scottish church. It fell into ruin after the Reformation, and townsfolk carried off its stones to build their houses.")
    plaque(z, 58, 15, "fife_castle", "St Andrews Castle",
           "The bishops' castle on the cliff. In 1546 Cardinal Beaton was murdered here and the castle besieged; the attackers dug a mine under it, the defenders dug a countermine to meet them, and you can still crawl through both. It also has a bottle dungeon.")
    plaque(z, 29, 43, "fife_ph_initials", "The PH in the Cobbles",
           "Outside St Salvator's the initials PH are set into the cobbles where Patrick Hamilton was burned for his Protestant beliefs in 1528. Students won't step on them: legend says if you do, you'll fail your degree.")
    plaque(z, 33, 35, "fife_university", "The University",
           "The University of St Andrews was founded in 1413, the oldest in Scotland and the third oldest in the English-speaking world, after Oxford and Cambridge.")
    plaque(z, 57, 48, "fife_pier_walk", "The Pier Walk",
           "On Sunday mornings in term, students in scarlet gowns walk out along the pier after chapel. On the way back, the way you wear your gown tells everybody which year you are in.")
    plaque(z, 36, 8, "fife_west_sands", "The West Sands",
           "Two miles of beach where the runners splash along in the opening scene of the 1981 film Chariots of Fire. Everyone who runs here hums the music. Everyone.")
    plaque(z, 2, 35, "fife_no_station", "No Station",
           "St Andrews lost its railway in 1969, so golfers, students and visitors come in by bus from Leuchars, a few miles away. The old station is a car park now. Ask a local to hum the departures.")
    z.sign(33, 61, "ST ANDREWS. NORTH: the Old Course, the castle, the cathedral. SOUTH: the Forth bridges.")
    z.sign(7, 2, "NORTH: Guardbridge, the Tay Road Bridge and Dundee.")
    # ---- folk ----
    chat(z, "sta_gown", "gown_student", 50, 50, "Student",
         ["The red gown is the undergraduate gown. First years wear it on the shoulders, second years a bit off, third years off one shoulder, fourth years off both. It's very complicated and we all pretend it isn't.",
          "Raisin Monday, in November, the first years get a receipt in Latin from their academic parents and have a foam fight in St Salvator's Quad. It's a great tradition. It's also a great deal of foam."], "left", "still")
    chat(z, "sta_runner", "jogger", 26, 7, "Beach Runner",
         ["Da-da-da-da-daa-da. Da-da-da-da-daaa. Sorry. Every time. The West Sands does it to you.",
          "Eric Liddell, the Flying Scotsman of the film, won gold in the 400 metres in Paris in 1924, after refusing to run his best race, the 100, because the heats were on a Sunday."], "left", "wander", )
    chat(z, "sta_greenkeeper", "farmer", 34, 22, "Greenkeeper",
         ["The Old Course is public, you know. Anybody can play it. And on Sundays it's closed to golf and open as a park, for walkers, dogs and picnics. Mind the greens.",
          "The course used to be played backwards, clockwise. They still do the reverse course a few days a year, in the spring. It's like reading a book from the end."], "down", "still")
    chat(z, "sta_fisher", "fisherman_north", 55, 50, "Harbour Fisher",
         ["The legend says Saint Rule was shipwrecked here bringing the bones of Saint Andrew from Greece. That's how a wee fishing town got Scotland's patron saint.",
          "The saltire, the white cross on blue, is Saint Andrew's cross. He was crucified on an X-shaped cross because he said he wasn't worthy of the same cross as Christ."], "up", "still")
    # the Starter at the first tee runs the round (see quest fife_golf)
    _stand(z, 36, 28)
    z.npc(id="sta_starter", sprite="golfer", x=36, y=28, facing="left", move="still", script="sta_starter", name="Starter")
    script(zid, "sta_starter", [
        cmd_if("q_fife_golf_done", say("Starter", "Back for another look at the first tee? You're on the honours board in my head, and that's more exclusive than the clubhouse."),
               [cmd_if("q_fife_golf_2", golf_reward(),
                       [cmd_if("q_fife_golf_1", say("Starter", "Old Tam says you know your way round. Good enough for me. Four players to beat, first tee to eighteenth green, no stopping at the Sanctuary.") +
                               [choice("Play the round on the Old Course?", ["On the tee", "Not yet"], "_fife_golf_go"),
                                cmd_if("_fife_golf_go", [
                                    {"do": "gauntlet", "trainers": ["sta_golf_1", "sta_golf_2", "sta_golf_3", "sta_golf_4"], "flag": "q_fife_golf_2",
                                     "exit": {"zone": "st_andrews", "x": 34, "y": 29},
                                     "lose_line": "You trudge back to the first tee with sand in your shoes. The Old Course has seen this before. It'll see you again.",
                                     "next_line": "On to the next hole. The wind gets up. The next player is already waiting on the tee.",
                                     "prize_from": "the Old Course"}] + golf_reward(),
                                    say("Starter", "No rush. The course has been here six hundred years."), eq=0)],
                               say("Starter", "Welcome to the first tee of the Old Course. Want a round? Well. It's not the clubs that matter here, it's the local knowledge.",
                                   "Go and see Old Tam, the caddie, at the British Golf Museum, just over there. If he says you know the course, I'll put you out. Four players. Every one of them thinks the course is theirs.") +
                               [setf("q_fife_golf_started")])])])])
    trainer(z, "sta_historian", "Dr Fiona", "Historian", "poet",
            [("legionette", 69), ("sarsenite", 69), ("coblynn", 70)], 41, 51, "down",
            ["The castle has a bottle dungeon: a pit cut into the rock, narrow at the neck, wide at the bottom. You were lowered in on a rope. There was no other way out. Shall we have a battle about it?"],
            "History is written by the winners. You can borrow my pen.",
            "John Knox was in the castle when it fell in 1547. The French took him away to row in their galleys. He came back to Scotland and changed it.", 2900)
    trainer(z, "sta_caddie_kid", "Caddie Rory", "Young Caddie", "student",
            [("divotling", 69), ("hellbunker", 69), ("swiftlet", 70)], 10, 24, "up",
            ["I carry bags round the Old Course in the summer. I know every bump. Want to know which way the putt breaks? Towards the sea. It always breaks towards the sea."],
            "Aye, you read that one well.",
            "Old Tom Morris was greenkeeper here for nearly forty years, and he won the Open four times. His son, Young Tom, won it four times too, and he was only twenty-four when he died.", 2850)
    scaled(["sta_historian", "sta_caddie_kid"])
    # the four players of the round (fought only through the Starter's gauntlet)
    golfers = [
        ("sta_golf_1", "Club Captain Hamish", [("murmurant", 69), ("stormswift", 70), ("hellbunker", 70)],
         "The first hole. The widest fairway in golf, shared with the eighteenth. Miss it and the whole town will know by lunchtime.",
         "A fine start. Mind the Swilcan on the way home.", 2600),
        ("sta_golf_2", "Mrs Agnes Laidlaw", [("ptarmigan", 70), ("goldeneyrie", 70), ("divotling", 70)],
         "Hell Bunker, on the fourteenth. I've been in it four times this year and I've named the stones.",
         "You stayed out of Hell. Well done. Not everybody can say that.", 2700),
        ("sta_golf_3", "Professor Alastair Ross", [("cragchough", 70), ("hellbunker", 71), ("quarrion", 70)],
         "The Road Hole. Seventeen. Over the hotel, if you're brave, then the road, the wall, the bunker. I teach physics. I still can't explain what this hole does to a ball.",
         "Perfectly calculated. I shall write a paper.", 2800),
        ("sta_golf_4", "Old Course Champion Jean", [("stoopfalcon", 71), ("severnshock", 71), ("hellbunker", 72), ("railspark", 71)],
         "The eighteenth. Over the Swilcan Bridge, up to the Valley of Sin in front of the green, and the whole town watching from the railings. Let's give them a show.",
         "That's the round. Off you go and stand on the bridge for your photograph. Everybody does.", 3200),
    ]
    for (tid, name, party, intro, win, money) in golfers:
        TRN[tid] = {"id": tid, "name": name, "class": "Golfer", "sprite": "golfer",
                    "party": [{"species": s, "level": l} for s, l in party], "ai": "trainer", "money": money,
                    "intro": say(name, intro), "win": win, "after": win, "scaled_floor": FLOOR}
    wild_set(z, [("divotling", 16, {}), ("cooplet", 10, {}), ("starlet", 8, {"time": ["dusk", "dawn"]}), ("ternlet", 10, {}), ("chipgull", 10, {}),
                 ("swiftlet", 8, {"weather": ["gale", "drizzle"]}), ("hootlet", 6, {"time": ["night"]}), ("flittermouse", 6, {"time": ["night"]}),
                 ("leveret", 8, {}), ("haarling", 8, {"weather": ["fog"]}), ("hellbunker", 4, {"weather": ["gale"]})])
    wild_set(z, [("pupplash", 18, {}), ("gannetling", 16, {}), ("puffling", 12, {}), ("pinchkin", 14, {}), ("dolphlet", 8, {"time": ["day"]}),
                 ("ternlet", 10, {})], "water")
    z.d["edges"] = {"south": {"to": "forth_bridges", "offset": -5}, "north": {"to": "dundee", "offset": 36}}
    z.d["spawn"] = [31, 58]
    finish(z)
    z.save(OUT + "/" + zid + ".json")

    sanctuary(OUT, zid, "St Andrews", (11, 43), music="sanctuary")
    shop(OUT, zid, "St Andrews", (17, 43))
    nurse(zid, ["Hiya! Welcome to St Andrews Sanctuary. Your team looks like it's been round the Old Course in a gale. Pop them on the counter.",
                "There's a pot of tea on, and a tin of shortbread that the students haven't found. Yet.",
                "All better. Off you go, and don't step on the PH in the cobbles. Everybody says it's just a superstition. Everybody walks round it.",
                "The Ark's in the corner. It's older than the university, nearly. Have a click.",
                "No bother. Enjoy the town, and mind the golf balls."])
    shopkeeper(zid, "Hiya! Snares, tea, Dundee cake and the finest Forfar bridies this side of Forfar. What can I get you?",
               "Cheerio! If you're on the West Sands, you'll be humming. Everybody hums.")
    interior(OUT, "st_andrews_golf_museum", "British Golf Museum", zid, (39, 34), "museum",
             [npc("sta_caddie", "golfer", 6, 4, "sta_caddie", name="Old Tam")],
             props=[("display_case", 2, 3, {"variant": 1}), ("display_case", 10, 3, {"variant": 2})])
    script("st_andrews_golf_museum", "sta_caddie", [
        cmd_if("q_fife_golf_started", [
            cmd_if("q_fife_golf_1", say("Old Tam", "You've my say-so already. Away to the first tee and give them a fright."),
                   say("Old Tam", "So the Starter sent you. Right. Three questions. Get them right and you've my say-so. Get them wrong and go and read the plaques on the course like everybody else.") +
                   [choice("Which hole is the Road Hole?", ["The 1st", "The 17th", "The 18th"], "_fife_tam_1"),
                    cmd_if("_fife_tam_1",
                           [choice("What crosses the Swilcan Burn on the 1st and 18th?", ["A ford", "The Swilcan Bridge", "A wee ferry"], "_fife_tam_2"),
                            cmd_if("_fife_tam_2",
                                   [choice("And Hell Bunker. Which hole?", ["The 14th", "The 9th", "The 3rd"], "_fife_tam_3"),
                                    cmd_if("_fife_tam_3",
                                           say("Old Tam", "Spot on, all three. You've been reading. Tell the Starter Old Tam says you'll do.") + [setf("q_fife_golf_1")],
                                           say("Old Tam", "No. Away and look at the plaque by the big bunker, then come back."), eq=0)],
                                   say("Old Tam", "No. The plaque by the burn will put you right."), eq=1)],
                           say("Old Tam", "No. Seventeen is the Road Hole. Go and read the plaque by its bunker and come back."), eq=1)])
        ], say("Old Tam", "In here you'll see featheries: leather balls stuffed with boiled goose feathers. A good ball maker managed a few a day. Then in the 1840s came the gutty, made of gutta-percha, and everybody could afford to lose a ball.",
               "And the old clubs had names, not numbers: the niblick, the mashie, the cleek, the spoon. A spoon! Imagine telling your mother you're off out with your spoon."))])
    interior(OUT, "st_andrews_jigger", "The Jigger Inn", zid, (5, 22), "cafe",
             [npc("sta_landlady", "villager_4", 3, 1, "sta_landlady", name="Landlady"),
              npc("sta_golfer_pub", "golfer", 9, 3, "sta_golfer_pub", name="Weary Golfer", facing="left")],
             props=[("fireplace", 6, 1, {"walk": True})])
    script("st_andrews_jigger", "sta_landlady", say("Landlady",
           "This was the stationmaster's lodge, back when St Andrews had a station by the course. Now it's the nineteenth hole for the seventeenth.",
           "Quiz? Scottish questions. The golfers always get the golf ones and nothing else.") +
           [{"do": "quiz", "pub": "st_andrews_jigger", "region": "scotland", "who": "Landlady"}])
    script("st_andrews_jigger", "sta_golfer_pub", say("Weary Golfer",
           "I was in the Road Hole bunker for three shots. Three. I've come in here to think about my choices.",
           "Mind, my grandad played with a gutty ball and a cleek. If he could get round, so can I. Eventually."))
    interior(OUT, "st_andrews_salvators", "St Salvator's Chapel", zid, (25, 43), "church",
             [npc("sta_chaplain", "choir_singer", 6, 2, "sta_chaplain", name="Chaplain")])
    script("st_andrews_salvators", "sta_chaplain", say("Chaplain",
           "Bishop James Kennedy founded St Salvator's College in 1450. His tomb is here, and the college mace, which is silver and has been carried at graduations for over five hundred years.",
           "The students' red gown goes back a long way. One story says it was made bright so students could be spotted in the town's taverns. I could not possibly comment."))
    interior(OUT, "st_andrews_cathedral", "St Andrews Cathedral", zid, (50, 46), "church",
             [npc("sta_custodian", "tour_guide", 7, 3, "sta_custodian", name="Custodian")], w=15, h=11,
             props=[("standing_stone", 2, 2, {"variant": 1}), ("standing_stone", 12, 2, {"variant": 1}), ("display_case", 3, 6, {"variant": 0})])
    script("st_andrews_cathedral", "sta_custodian", say("Custodian",
           "The story goes that Saint Rule, or Regulus, carried relics of Saint Andrew here from Greece, and that's why this was the great pilgrim church of Scotland. Pilgrims came from all over Europe.",
           "St Rule's Tower, outside, is even older than the cathedral. You can climb it, if you like narrow stairs, and from the top the whole town looks like a map of itself.",
           "In 1559 the reformers stripped it, and over the years the town quietly took the stones home. Half the old houses in St Andrews have a bit of cathedral in them somewhere."))
    castle = interior(OUT, "st_andrews_castle", "St Andrews Castle", zid, (52, 14), "castle",
                      [npc("sta_castle_guide", "tour_guide", 3, 3, "sta_castle_guide", name="Castle Guide"),
                       npc("sta_mine_digger", "tin_miner", 12, 2, "sta_mine_digger", name="Mine Guide")], w=15, h=11,
                      rows=[(9, 1, 1, 4, "x")],
                      signs=[(4, 6, "THE BOTTLE DUNGEON. A pit cut down into the rock, narrow at the neck and wide at the bottom, like a bottle. Prisoners were lowered in on a rope. Once in, you weren't climbing out.")])
    script("st_andrews_castle", "sta_castle_guide", say("Castle Guide",
           "That's the bottle dungeon. Twenty-four feet down into solid rock. Cardinal Beaton kept prisoners there, and after he was murdered in 1546, the story goes his body was kept down there too, in salt.",
           "Don't lean over. We've lost a lot of sunglasses."))
    script("st_andrews_castle", "sta_mine_digger", say("Mine Guide",
           "During the siege of 1546 the attackers dug a tunnel through the rock to get under the walls. The defenders heard them and dug a countermine to meet them. Both tunnels are still here.",
           "The countermine had a few false starts before they found the mine. You can crawl through it. Mind your head. Everybody bumps their head. Even me, and I work here."))
    _ = castle


def golf_reward():
    return [cmd_if("q_fife_golf_done", [],
                   say("Starter", "Round done, and you've beaten every one of them. I'd give you a trophy, but the good ones are in the museum. Have this instead. It's older than the trophies.") +
                   [give("featherie"), {"do": "standing", "nation": "scotland", "amount": 2}, setf("q_fife_golf_done")])]


# =====================================================================================================
# dundee
# =====================================================================================================

def dundee(OUT):
    W, H = 72, 64
    zid = "dundee"
    z = Z(zid, "Dundee", W, H, kind="town", region=SCOT, music="town_scotland", weather=WX_EAST)
    z.d["stage"] = "city"; z.d["town_id"] = "dundee"; z.d["scaled_floor"] = FLOOR
    z.border("T", 2, gaps=[(40, 62, 3, 2)])
    z.scatter(0, 0, W, H, "P", 24, 81, only="T")
    # the Firth of Tay along the south
    z.rect(0, 45, W, 19, "$")
    z.rect(2, 44, 68, 1, "w")
    # Dundee Law, the old volcano behind the town
    hills(z, [(12, 9, 4, 9)])
    smooth(z)
    z.rect(11, 3, 3, 3, "#")
    z.prop("statue", 12, 4, variant=1)
    path(z, [(12, 6), (12, 13), (22, 13)], "#")
    # the waterfront: the station and its line out to the Tay Bridge, the quay
    z.building(12, 39, 8, 2, "station", "Dundee Station", door=4)
    z.rect(12, 41, 8, 1, "_")
    z.rect(0, 42, 31, 1, "!")
    z.prop("buffer_stop", 31, 42)
    z.d["station"] = {"x": 16, "y": 41}
    z.rect(2, 43, 68, 1, ":")
    z.rect(0, 43, 2, 2, "T")
    z.building(0, 45, 18, 2, "tay_bridge", show_label=False)
    z.rect(32, 38, 38, 5, ":")
    # the Tay Road Bridge, the way in from Fife
    z.rect(40, 44, 3, 20, "=")
    z.building(39, 45, 1, 19, "bridge_girder", show_label=False)
    z.building(43, 45, 1, 19, "bridge_girder", show_label=False)
    z.rect(40, 30, 3, 8, "=")
    # V&A Dundee and the Discovery in her dock
    z.building(45, 39, 10, 4, "va_dundee", "V&A Dundee", door=5)
    enter(z, 50, 42, "dundee_vanda")
    z.rect(56, 34, 15, 4, "~"); z.rect(56, 38, 2, 3, "~"); z.rect(69, 38, 1, 3, "~")
    z.building(58, 38, 11, 3, "discovery_ship", "RRS Discovery", door=5)
    enter(z, 63, 40, "dundee_discovery", 15, 10)
    z.rect(70, 34, 2, 10, "T")
    # ---- the city ----
    z.rect(2, 31, 68, 2, "=")                      # the Nethergate and High Street
    z.rect(30, 22, 18, 8, ":")                     # City Square
    z.building(32, 16, 14, 5, "stone", "Caird Hall")
    z.prop("statue", 34, 27, variant=0)            # Desperate Dan, striding
    z.prop("bench", 38, 27); z.prop("bench", 44, 27)
    z.building(6, 20, 10, 5, "mill", "Verdant Works", door=4)
    enter(z, 10, 24, "dundee_verdant")
    z.building(18, 24, 8, 4, "red_brick", "Keiller's Jam Kitchen", door=3)
    enter(z, 21, 27, "dundee_keillers")
    z.building(52, 21, 10, 5, "cathedral", "The McManus", door=5)
    enter(z, 57, 25, "dundee_mcmanus", 15, 11)
    z.building(52, 14, 8, 5, "stone", "Courier Building", door=4)
    enter(z, 56, 18, "dundee_courier")
    z.rect(48, 19, 14, 1, ":"); z.rect(48, 26, 16, 1, ":"); z.rect(48, 19, 1, 8, ":")
    z.building(4, 34, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(7, 37, "dundee_sanctuary", 5, 6, "up")
    z.building(11, 34, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(13, 37, "dundee_shop", 4, 5, "up")
    z.building(22, 34, 7, 4, "crow_step", "The Silvery Tay", door=3)
    enter(z, 25, 37, "dundee_tay_inn")
    z.rect(2, 38, 30, 1, ":")
    for (x, y, w) in [(18, 13, 8), (2, 26, 7), (27, 24, 2), (62, 24, 6), (62, 14, 8), (48, 34, 6), (63, 27, 6)]:
        pass
    for (x, y, w, lab) in [(26, 13, 6, "Hilltown"), (2, 27, 5, "Lochee Road"), (62, 27, 7, "Seagate"), (63, 14, 7, "Murraygate"), (33, 34, 6, "Nethergate")]:
        z.building(x, y, w, 3, "tenement", lab)
    for (x, y) in [(5, 30), (18, 30), (29, 30), (49, 30), (60, 30), (34, 37), (46, 37), (24, 42)]:
        z.prop("lamp_post", x, y)
    blob(z, 24, 7, 7, 3, ",", only=".", seed=41, jitter=0.4)
    blob(z, 50, 7, 9, 3, ",", only=".", seed=42, jitter=0.4)
    scatter_props(z, "oak", 30, 3, 36, 8, 10, 43, avoid=(".",))
    # ---- plaques ----
    plaque(z, 56, 42, "fife_discovery", "RRS Discovery",
           "Built here in Dundee and launched in 1901 to carry Captain Scott and Ernest Shackleton on their first Antarctic expedition, with a hull nearly two feet thick to stand the ice. She came home to Dundee in 1986.")
    plaque(z, 44, 43, "fife_vanda", "V&A Dundee",
           "Scotland's design museum opened in 2018. The Japanese architect Kengo Kuma based it on the cliffs of the north-east coast. Inside is a whole tearoom by Charles Rennie Mackintosh, the Oak Room, rebuilt piece by piece.")
    plaque(z, 2, 41, "fife_tay_disaster", "The Tay Bridge Disaster",
           "On the stormy night of 28 December 1879 the middle of the first Tay Bridge blew down while a train was crossing. Nobody aboard survived. The stumps of its piers still stand in the water beside the second bridge.")
    plaque(z, 24, 41, "fife_tay_rail_bridge", "The Tay Bridge",
           "The second Tay Bridge opened in 1887, built much more strongly beside the line of the first. It's over three kilometres long, the longest railway bridge in Britain.")
    plaque(z, 44, 36, "fife_tay_road_bridge", "The Tay Road Bridge",
           "Opened in 1966, more than two kilometres of road from Fife into Dundee, with a footpath running down the middle between the two carriageways.")
    plaque(z, 30, 29, "fife_mcgonagall", "William McGonagall",
           "Dundee's own poet, often called the worst in the English language. His poem about the bridge disaster ends 'the strength of the bridge would not have been so frail'. He gave readings; audiences threw peas. He carried on.")
    plaque(z, 17, 25, "fife_jute", "Juteopolis",
           "Dundee spun jute from India, softened with whale oil from the town's own whaling ships, into sacks, sandbags and carpet backing. Most of the mill workers were women, and the town was nicknamed Juteopolis.")
    plaque(z, 26, 28, "fife_jam", "Jute, Jam and Journalism",
           "Keiller's of Dundee made marmalade famous across the world. With the jute and DC Thomson's papers and comics, it gave the city its old motto: jute, jam and journalism.")
    plaque(z, 36, 28, "fife_comics", "The Comics",
           "DC Thomson in Dundee has published The Dandy and The Beano since the 1930s. That's Desperate Dan in bronze, striding across the City Square since 2001, with his dog Dawg at his heels.")
    plaque(z, 14, 5, "fife_law", "Dundee Law",
           "The Law, 174 metres high, is the stump of an old volcano, with a war memorial on top and the best view of the Tay. 'Law' is the Scots word for a hill.")
    plaque(z, 47, 22, "fife_city_of_design", "City of Design",
           "In 2014 Dundee became the UK's first UNESCO City of Design. The city also gave the world a lot of video games: Lemmings and Grand Theft Auto both started here.")
    plaque(z, 50, 27, "fife_mary_shelley", "Mary Shelley",
           "As a teenager, Mary Shelley spent two summers in Dundee, round about 1812. She later wrote that it was here, by the Tay, that her imagination first ran free. A few years after, she wrote Frankenstein.")
    z.sign(44, 61, "DUNDEE. The City of Discovery. Over the bridge, south: St Andrews and Fife.")
    # ---- folk ----
    chat(z, "dun_dolphins", "birdwatcher", 66, 43, "Dolphin Watcher",
         ["There are bottlenose dolphins in the Tay. You see them off Broughty Ferry, along the coast there, leaping in the river mouth. Bring a flask. Bring patience.",
          "Grey seals and common seals too, on the sandbanks at Tentsmuir across the water. The Tay is busier than the bridge."], "down", "still")
    chat(z, "dun_comic_fan", "student", 42, 24, "Comics Fan",
         ["Dundee's been making comics for kids for nearly a hundred years. Cowboys who eat cow pie, menaces with catapults, bash street bands of rascals. Generations of British kids learnt to read from them.",
          "The statue's Desperate Dan. He's so strong he shaves with a blowtorch. My dad says I'm not allowed to try that."], "left", "wander")
    chat(z, "dun_millworker", "villager_5", 12, 28, "Retired Spinner",
         ["My granny was a spinner in a jute mill. She started at twelve. The men stayed home and minded the bairns, so they called them kettle bilers, kettle boilers. Dundee was a women's town.",
          "The mill chimneys were everywhere. Cox's Stack at Lochee is still standing, nearly three hundred feet tall, like a bell tower for jute."], "down", "still")
    chat(z, "dun_law_walker", "hillwalker", 15, 8, "Hill Walker",
         ["Up the Law every morning. You can see right over the Tay to Fife, and on a clear day out to the sea. Behind you, the Sidlaw Hills.",
          "Dundonians say 'eh' for 'I' and 'pehs' for 'pies'. A steak peh, please. Practise that. You'll need it at the football."], "down", "wander")
    # the ghost on the Tay (the poet's quest): only once the McManus curator has told you about the poem
    _stand(z, 8, 43)
    z.npc(id="taywraith_spot", sprite="creature:taywraith", x=8, y=43, facing="down", move="still", script="taywraith",
          show_if="q_fife_poet_1", hide_if="caught_taywraith")
    script(zid, "taywraith", [
        {"do": "when", "cond": "night", "then": [
            cmd_if("taywraith_met", say("", "The lamps hang over the water where the old girders stood. A whistle, very faint, from a long way off. It is waiting for you."),
                   say("", "The wind gets up off the Tay. Out on the water, between the old stumps, two lamps are moving, steady as a train. There are no rails there. There haven't been since 1879.",
                       "The lamps come closer. Iron and steam and something lonelier than either. It stops at the end of the quay as if it had always meant to.") +
                   [{"do": "music", "id": "legend_sea"}, setf("taywraith_met")]),
            {"do": "legend", "species": "taywraith", "level": 72, "flag": "caught_taywraith", "music": "legend_sea"},
            cmd_if("caught_taywraith", [{"do": "say", "who": "", "text": "The lamps dim to a warm, contented glow. Whatever was crossing the Tay has, at last, got to the other side. It seems to have decided that the other side is you."},
                                        setf("q_fife_poet_2"), {"do": "warp", "zone": "dundee", "x": 8, "y": 43, "facing": "down"}, {"do": "end"}],
                   [{"do": "say", "who": "", "text": "The lamps flicker, and fade back over the water towards the stumps. A long, low whistle. It will cross again."},
                    {"do": "warp", "zone": "dundee", "x": 8, "y": 43, "facing": "down"}, {"do": "end"}])],
         "else": say("", "Out on the water, the stumps of the old bridge stand in a line, like the posts of a fence nobody finished. Folk say a ghost train crosses here, but only at night.")}])
    trainer(z, "dun_spinner", "Spinner Jessie", "Mill Lass", "villager_6",
            [("bobbin", 69), ("shuttlecog", 70), ("linenwisp", 69)], 22, 29, "down",
            ["Jute's rough on the hands and loud on the ears. We used to talk in the mill by lip-reading over the racket. Can you read my lips? They're saying 'battle'."],
            "Och, you've got a good loom-hand on you.",
            "The jute came from Bengal, and the oil to soften it came from Dundee's whaling ships. The town was one big machine.", 2850)
    trainer(z, "dun_artist", "Comic Artist Kev", "Comic Artist", "student",
            [("cluricaun", 69), ("squawkster", 70), ("binfox", 69)], 46, 29, "left",
            ["I draw for the comics. Twelve panels a page. Every page needs a joke, a chase and a slapstick fall. You're my next page."],
            "KAPOW. That was you. I'll draw you in.",
            "Rule one of drawing comics: anything heavy will land on somebody's head. Rule two: see rule one.", 2850)
    trainer(z, "dun_designer", "Designer Nadia", "Designer", "festival_goer",
            [("prismite", 70), ("tubemole", 69), ("pierlord", 69)], 52, 37, "up",
            ["Dundee's a UNESCO City of Design. Games, comics, the V&A. Design is about solving problems. You're my problem."],
            "Elegant. I'd put that in a museum.",
            "The V&A's walls are made of about 2,500 precast stone panels, so the light changes on them all day. It never looks the same twice.", 2900)
    scaled(["dun_spinner", "dun_artist", "dun_designer"])
    wild_set(z, [("jamlet", 12, {}), ("grizzlet", 12, {}), ("binfox", 10, {"time": ["night", "dusk"]}), ("cooplet", 10, {}), ("strutcoo", 8, {}),
                 ("chipgull", 10, {}), ("starlet", 8, {"time": ["dusk", "dawn"]}), ("flittermouse", 8, {"time": ["night"]}), ("railspark", 8, {}),
                 ("rooklet", 8, {}), ("marmalord", 3, {})])
    wild_set(z, [("dolphlet", 18, {"time": ["day", "dawn"]}), ("pupplash", 16, {}), ("orcalet", 6, {}), ("gannetling", 14, {}), ("stalklet", 12, {}),
                 ("chipgull", 12, {})], "water")
    z.d["edges"] = {"south": {"to": "st_andrews", "offset": -36}}
    z.d["spawn"] = [41, 40]
    finish(z)
    z.save(OUT + "/" + zid + ".json")

    sanctuary(OUT, zid, "Dundee", (7, 38), music="sanctuary")
    shop(OUT, zid, "Dundee", (13, 38))
    nurse(zid, ["Hiya! Welcome to Dundee Sanctuary. Sit yourself down, your team looks like it walked over the Tay Road Bridge into the wind. Which it did.",
                "There's tea, and a slice of Dundee cake with the almonds on top. Never cherries. Don't let anybody tell you cherries.",
                "There you go, right as rain. In Dundee that's a very high standard of right.",
                "The Ark's over there. Have a click.",
                "Nae bother. Mind how you go, and say hello to the dolphins."])
    shopkeeper(zid, "Hiya! Bridies, Dundee cake, marmalade and every snare in the book. What can I get you?",
               "Cheers! If you're up the Law, take a jacket. It's always windier up the Law.")
    # ---- interiors ----
    interior(OUT, "dundee_discovery", "RRS Discovery", zid, (63, 41), "museum",
             [npc("dun_bosun", "sailor", 4, 3, "dun_bosun", name="Bosun"),
              npc("dun_icemaster", "explorer", 11, 3, "dun_icemaster", name="Ice Master", facing="left")], w=15, h=10,
             props=[("telescope", 1, 6, {}), ("wall_map", 7, 1, {"walk": True})],
             signs=[(13, 6, "THE WARDROOM. Scott, Shackleton, the naturalist Edward Wilson and the officers ate here, under a skylight, in the dark of the Antarctic winter. The ship froze into the sea ice for two winters.")])
    script("dundee_discovery", "dun_bosun", discovery_bosun())
    not_yet = say("Ice Master", "Get the stores aboard first. The Bosun has a list.")
    fight = say("Ice Master", "Provisions in, girdle and all. So the Bosun reckons you're crew. Before I sign you on for the ice, I want to see what you're made of.") + \
        [{"do": "battle", "trainer": "dun_icemaster", "intro": True}, setf("q_fife_discovery_4"),
         {"do": "say", "who": "Ice Master", "text": "Aye. You'll do. Go and tell the Bosun the Ice Master says you'll do."}]
    stores = [cmd_if("q_fife_discovery_1", [cmd_if("q_fife_discovery_2", [cmd_if("q_fife_discovery_3", fight, not_yet)], not_yet)], not_yet)]
    script("dundee_discovery", "dun_icemaster", [
        cmd_if("q_fife_discovery_4", say("Ice Master", "You'd do fine on the ice. Mind your toes, mind your dogs, and never trust a crevasse that looks friendly."),
               [cmd_if("q_fife_discovery_started", stores,
                       say("Ice Master", "Discovery was built strong for the ice: oak and elm and Riga fir, two feet thick at the bow. She was frozen in for two winters and came out fine. I've had worse flats."))])])
    TRN["dun_icemaster"] = {"id": "dun_icemaster", "name": "Ice Master Wilson", "class": "Ice Master", "sprite": "explorer",
                            "party": [{"species": s, "level": l} for s, l in [("orcaird", 72), ("polartern", 72), ("snowbunting", 72), ("reindeer", 73), ("haarling", 72), ("marmalord", 73)]],
                            "ai": "keeper", "money": 5200,
                            "intro": say("Ice Master Wilson", "Two winters frozen in at the bottom of the world, sledging on half-rations with frostbitten fingers. Compared to that, you're a nice afternoon out. Let's see you."),
                            "win": "Ha! You've a heart of oak, and fingers to match.", "after": "You'll do.", "scaled_floor": FLOOR}
    interior(OUT, "dundee_keillers", "Keiller's Jam Kitchen", zid, (21, 28), "cafe",
             [npc("dun_jammaker", "jam_maker", 3, 1, "dun_jammaker", name="Jam Maker")],
             props=[("kitchen_dresser", 9, 1, {"walk": True}), ("fireplace", 6, 1, {"walk": True})])
    script("dundee_keillers", "dun_jammaker", [
        cmd_if("q_fife_discovery_started", [
            cmd_if("q_fife_discovery_1", say("Jam Maker", "How's my wee Jamlet getting on? Feed it oranges. Not jam. It finds that confusing."),
                   say("Jam Maker", "Marmalade for the Discovery? Scott's men took Dundee marmalade to the Antarctic, you know. It goes well with a frozen biscuit.",
                       "Here, two jars, sealed tight. Now, hold still, there's something in the crate. Oh! It's one of the wee jam ones. It must have climbed in for the peel.") +
                   [give("dundee_marmalade", 2), {"do": "give_creature", "species": "jamlet", "level": 60},
                    {"do": "say", "who": "Jam Maker", "text": "It's taken a shine to you. Keep it. It's very sticky, very loyal, and it'll grow into a proper crock one day."},
                    setf("q_fife_discovery_1")])
        ], say("Jam Maker", "The Keillers sold marmalade from Dundee from the 1790s. Folk say Janet Keiller invented it with a cheap shipload of Seville oranges. Lovely story. Marmalade's older, though. Don't tell the tourists.",
               "The trick is the peel: thick-cut, bitter and sweet. The Keillers put their spare peel into a fruit cake, and that's how Dundee cake got famous. Waste not."))])
    interior(OUT, "dundee_verdant", "Verdant Works", zid, (10, 25), "mill",
             [npc("dun_mill_guide", "villager_1", 6, 4, "dun_mill_guide", name="Mill Guide")])
    script("dundee_verdant", "dun_mill_guide", [
        cmd_if("q_fife_discovery_started", [
            cmd_if("q_fife_discovery_2", say("Mill Guide", "Did the sacking fit? Dundee jute went everywhere: sandbags in two world wars, wagon covers in the American West, sacks for coffee and sugar all over the world."),
                   say("Mill Guide", "Sacking for the Discovery's stores? We can do that. Jute's tough, cheap and it doesn't mind the cold.",
                       "Take these hanks of fibre. And here's how the spinners twisted it into twine, if you fancy making snares of your own.") +
                   [give("jute_fibre", 4), {"do": "recipe", "id": "jute_snare"}, setf("q_fife_discovery_2")])
        ], say("Mill Guide", "This was a jute mill. Raw jute came from Bengal, was softened with whale oil, then carded, spun and woven. The noise was so loud the workers learnt to lip-read.",
               "At its height Dundee had dozens of mills and tens of thousands of jute workers. Most of them women and girls, some no older than you'd be starting high school."))])
    interior(OUT, "dundee_mcmanus", "The McManus", zid, (57, 26), "museum",
             [npc("dun_curator", "tour_guide", 7, 3, "dun_curator", name="Curator")], w=15, h=11,
             props=[("specimen_shelf", 1, 1, {}), ("display_case", 12, 4, {"variant": 1})],
             signs=[(4, 3, "THE TAY WHALE. A humpback whale that swam up the Tay in 1883. It was hunted, caught, and put on show, and its skeleton is here. McGonagall, of course, wrote a poem about it.")])
    script("dundee_mcmanus", "dun_curator", [
        cmd_if("q_fife_poet_started", [
            cmd_if("q_fife_poet_1", say("Curator", "Down by the old bridge stumps, at night. That's where folk say they see the lamps. Take a snare. Take a scarf."),
                   say("Curator", "Inspiration for the McGonagall Night? The Tay Whale's over there. He wrote 'The Famous Tay Whale' about it: 'Twas in the month of December, and in the year 1883'. You see the style.",
                       "But his most famous poem is the Tay Bridge Disaster. And if you want to know about the bridge, go down to the quay at night where the old stumps are. People say a train still crosses there.") +
                   [setf("q_fife_poet_1")])
        ], say("Curator", "The McManus opened in 1867, built in the Gothic style to remember Prince Albert. Dundee's own art, history and natural history, all under one very pointy roof.",
               "The whale skeleton is the Tay Whale, from 1883. It's the one the children ask about. The grown-ups ask where the cafe is."))])
    interior(OUT, "dundee_courier", "Courier Building", zid, (56, 19), "library",
             [npc("dun_editor", "commuter", 6, 4, "dun_editor", name="Editor")])
    script("dundee_courier", "dun_editor", say("Editor",
           "Dundee's papers have been printed here for well over a century, and the comics too. Generations of children have grown up on the funny pages drawn in this town.",
           "The rule of a good comic strip: set it up, knock it down, and somebody always gets a slipper at the end.",
           "Journalism's the third J. Jute's gone, jam's mostly gone, but we're still here. Still printing. Still spelling Dundee right."))
    interior(OUT, "dundee_vanda", "V&A Dundee", zid, (50, 43), "museum",
             [npc("dun_vanda_guide", "festival_goer", 6, 4, "dun_vanda_guide", name="Guide")],
             props=[("display_case", 2, 3, {"variant": 2}), ("display_case", 10, 3, {"variant": 1})])
    script("dundee_vanda", "dun_vanda_guide", say("Guide",
           "In the Scottish Design Galleries there's Mackintosh's Oak Room, a tearoom from Miss Cranston's in Glasgow, taken down in the 1970s, kept in pieces for fifty years, and put back together here.",
           "And there's everything from Dundee-made comics and video games to tweed, tartan and Scottish-made jumpers. Design is everywhere. Even in the tea towels. Especially in the tea towels."))
    interior(OUT, "dundee_tay_inn", "The Silvery Tay", zid, (25, 38), "cafe",
             [npc("dun_landlady", "villager_4", 3, 1, "dun_landlady", name="Landlady"),
              npc("dun_bard_npc", "bard", 9, 3, "dun_bard_npc", name="The Bard", facing="left")],
             props=[("fireplace", 6, 1, {"walk": True})])
    script("dundee_tay_inn", "dun_landlady", [
        choice("What'll it be?", ["The pub quiz", "The McGonagall Night", "Just the view"], "_fife_inn"),
        cmd_if("_fife_inn", [{"do": "quiz", "pub": "dundee_tay_inn", "region": "scotland", "who": "Landlady"}],
               [cmd_if("_fife_inn", poet_landlady(), say("Landlady", "The silvery Tay, just there. That's what McGonagall called it. Mostly it's grey. Silvery on a good day."), eq=1)], eq=0)])
    script("dundee_tay_inn", "dun_bard_npc", [
        cmd_if("q_fife_poet_done", say("The Bard", "Defeated. By a better worse poet. I am humbled. I shall write an ode about it, and it will be dreadful, in your honour."),
               say("The Bard", "I am the reigning champion of the McGonagall Night. My poem about a bus shelter in Broughty Ferry made a grown man weep. Not in a good way.",
                   "William McGonagall once walked from Dundee to Balmoral to ask Queen Victoria to make him her poet. They turned him away at the gate. He walked home. That's commitment."))])
    TRN["dun_bard"] = {"id": "dun_bard", "name": "The Bard of Broughty Ferry", "class": "Poet", "sprite": "bard",
                       "party": [{"species": s, "level": l} for s, l in [("murmurant", 70), ("lanternis", 70), ("taywraith", 71), ("hushwing", 71)]],
                       "ai": "trainer", "money": 3300,
                       "intro": say("The Bard of Broughty Ferry", "Your poem. My poem. Then our creatures settle it, as McGonagall would have wished. Probably. He never said."),
                       "win": "'Twas in the year of this very night, that I was beaten in a fight.", "after": "Defeated, but undaunted.", "scaled_floor": FLOOR}


def discovery_bosun():
    reward = say("Bosun", "The Ice Master says you'll do! Then the Discovery's provisioned and you're crew, honorary. Scott would be proud. Well. Scott would be busy. But proud.") + \
        [give("dundee_cake", 3), give("cranachan", 2), {"do": "standing", "nation": "scotland", "amount": 2}, setf("q_fife_discovery_done")]
    return [cmd_if("q_fife_discovery_done", say("Bosun", "Ship-shape, thanks to you. She's not sailing anywhere, mind. She's been in dock since 1986. But she could, if she had to."),
                   [cmd_if("q_fife_discovery_started", [cmd_if("q_fife_discovery_4", reward,
                       say("Bosun", "The list: a crate of Dundee marmalade from Keiller's jam kitchen, jute sacking from the Verdant Works, and an iron girdle from the smiths at Culross, over the Forth, for oatcakes on the ice.",
                           "When the stores are in, the Ice Master wants a word. He's on deck. He's always on deck."))],
                       say("Bosun", "Welcome aboard the Discovery! Built right here in Dundee in 1901, because Dundee built the best whaling ships in the world and whalers knew ice.",
                           "We're doing a living history day: provisioning her for the Antarctic, the way they did for Captain Scott. I need a hand. Marmalade from Keiller's, jute sacking from the Verdant Works, and a Culross girdle from over the Forth.",
                           "Then you'll need to impress the Ice Master. He doesn't impress easy. He once called a blizzard 'bracing'.") +
                       [setf("q_fife_discovery_started")])])]


def poet_landlady():
    compose = [
        {"do": "say", "who": "Landlady", "text": "Right. Your poem. The worse it is, the better it is. Pick the worst line every time, and I mean the worst."},
        choice("Your first line:", ["Beautiful river, the silvery Tay, I saw you yesterday and also today", "O Tay, thou glittering ribbon of the north", "The river shone beneath a pewter sky"], "_fife_poem_1"),
        cmd_if("_fife_poem_1", [
            choice("Your second line:", ["And the wind it did blow, which was very bad, and made the people of Dundee feel sad", "The wind came howling down the firth that night", "Grief, like the tide, came in and would not leave"], "_fife_poem_2"),
            cmd_if("_fife_poem_2", [
                choice("Your last line:", ["So I end my poem, here on this page, and it is the finest poem of this age", "And still the river runs, and still we grieve", "The lamps went dark. The bridge was gone. The end."], "_fife_poem_3"),
                cmd_if("_fife_poem_3",
                       say("Landlady", "Oh, that's dreadful. That's magnificent. McGonagall himself would have read that out and been hit with a pea for it. Now: the Bard wants a word.") +
                       [{"do": "battle", "trainer": "dun_bard", "intro": True}, setf("q_fife_poet_3"),
                        {"do": "say", "who": "Landlady", "text": "Ladies and gentlemen, the new champion of the McGonagall Night! Here, it's tradition: a jar, a bridie, and your name chalked on the board till next year."},
                        give("dundee_marmalade", 2), give("forfar_bridie", 3), {"do": "standing", "nation": "scotland", "amount": 2}, setf("q_fife_poet_done")],
                       say("Landlady", "No. That's far too good. Somebody might be moved by that. Start again."), eq=0)],
                say("Landlady", "No, no. That's actually quite good. Start again, and be worse."), eq=0)],
        say("Landlady", "No, no. That's actually quite good. Start again, and be worse."), eq=0)]
    return [cmd_if("q_fife_poet_done", say("Landlady", "Your name's on the board, champion. Nobody's beaten your poem for sheer awfulness. Nobody's tried very hard."),
                   [cmd_if("q_fife_poet_2", compose,
                           [cmd_if("q_fife_poet_started",
                                   say("Landlady", "You need inspiration first. Go and see the Tay Whale at the McManus, and then go and see what crosses the Tay at night. McGonagall wrote about both."),
                                   say("Landlady", "Every year we hold a McGonagall Night, in honour of William McGonagall, Dundee's own and the worst poet who ever lived. He was very proud of it. Of the poems. Not the worst bit.",
                                       "Write the worst poem in the room and beat the reigning champion, and you'll have your name on the board. But you'll need inspiration. Start with the Tay Whale at the McManus.") +
                                   [setf("q_fife_poet_started")])])])]


if __name__ == "__main__":
    OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
    forth_bridges(OUT)
    st_andrews(OUT)
    dundee(OUT)
    write_all(OUT)
    print("fife: written")
