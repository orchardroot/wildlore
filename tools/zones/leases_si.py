# wave 38 session C: four Enclosure lease zones (Scotland, Ireland, Northern Ireland) to the lease contract in
# docs/briefs/wave38.md. Writes data/leases/<id>.json, data/zones/lease_<id>.json and data/dialogue/lease_<id>.json.
#   python3 tools/zones/leases_si.py tools/zones data/zones     (run from the repo root, like the other zone scripts)
# Each zone is a cul-de-sac off its anchor: its one edge leads back to the anchor (the edge carries "lease": "<id>",
# which the validator lets through without an edge coming back, since the anchor edge only opens once you own it).
import importlib.util, os, sys
# tools/zones/zlib.py is ours, but Python's built-in zlib wins the name unless it is loaded by path first
_here = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, _here)
_spec = importlib.util.spec_from_file_location("zlib", os.path.join(_here, "zlib.py"))
sys.modules["zlib"] = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(sys.modules["zlib"])
from ie_common import *
import math

# stage flag the lease core sets as the land heals: lease_<id>_stage = 0..3 (damaged, planted, recovering, wild)
STAGE_FLAG = "lease_%s_stage"


def entry(z, side, g, hub):
    """3-wide opening at index g on `side` (the border is 2 thick) and a path from it to the hub (hx, hy)."""
    hx, hy = hub
    if side == "north":
        z.rect(g, 0, 3, 2, "k"); s = (g + 1, 2); pts = [s, (s[0], hy), (hx, hy)]
    elif side == "east":
        z.rect(z.w - 2, g, 2, 3, "k"); s = (z.w - 3, g + 1); pts = [s, (hx, s[1]), (hx, hy)]
    else:
        z.rect(0, g, 2, 3, "k"); s = (2, g + 1); pts = [s, (hx, s[1]), (hx, hy)]
    path(z, pts)
    z.rect(hx - 4, hy - 3, 9, 7, "k")
    path(z, pts)
    z.d["edges"][side] = {"to": ANCHOR_OF[z.d["id"]], "offset": 0}


def plaque(z, x, y, pid, title, text):
    z.d["signs"].append({"x": x, "y": y, "text": text, "plaque": pid, "title": title})


def seasons(who, spring, summer, autumn, winter):
    """a chat script whose line follows the in-game season (the land changes over the seasons)."""
    def one(season, line, rest):
        return [{"do": "when", "cond": season, "chat": True, "then": say(who, line), "else": rest}]
    return one("spring", spring, one("summer", summer, one("autumn", autumn, say(who, winter))))


def table(z, rows, flag, name="grass"):
    """rows = [(species, weight, stage, extra)]; stage 0 is always there, later stages need lease_<id>_stage."""
    for sp, wt, st, extra in rows:
        e = dict(extra)
        if st:
            e["requires_flag"] = flag
            e["flag_at_least"] = st
        wild(z, [(sp, z.lo, z.hi, wt, e)], name)


ANCHOR_OF = {}
LEASES = []


def lease(spec, build):
    zid = "lease_" + spec["id"]
    ANCHOR_OF[zid] = spec["anchor"]
    LEASES.append((spec, build))


# ---------------------------------------------------------------- Coire Dubh, a Highland deer forest (Scotland)
def coire_dubh(OUT, spec):
    zid = "lease_coire_dubh"
    W, H = 48, 40
    z = Z(zid, "Coire Dubh Deer Forest", W, H, fill="k", kind="route", region="scotland", music="route_highlands",
          weather={"clear": 22, "drizzle": 28, "fog": 20, "sunshine": 10, "gale": 10, "downpour": 10})
    z.lo, z.hi = 76, 77
    z.d["stage"] = "moor"
    z.legend["k"] = {"tile": "grass", "colour": "#76804c"}
    z.legend["h"] = {"tile": "tall_grass", "colour": "#7a5c6a", "prop": "heather"}
    z.border("P", 2)
    entry(z, "north", spec["gap"][0], (30, 18))
    for i in range(14):                                   # heather and tall grass, the deer's pasture
        blob(z, 6 + (i * 11) % 40, 6 + (i * 7) % 30, 3 + i % 3, 2 + i % 2, "h", only="k", seed=i)
    for y in range(3, 37):                                # the burn, with two fords
        bx = 22 + round(2 * math.sin(y / 5.0))
        ford = y in (10, 11, 26, 27)
        for x in range(bx - 1, bx + 2):
            z.set(x, y, "w" if ford or x != bx else "~")
    z.scatter(4, 22, 16, 14, "P", 90, 7, only="k")        # a remnant of old pinewood
    z.rect(26, 30, 11, 1, "F"); z.rect(39, 30, 7, 1, "F")  # a deer fence nobody has taken down
    z.rect(44, 8, 1, 13, "W")                             # a drystone march wall
    z.building(39, 5, 5, 4, "slate_cottage", "Stalker's Lodge")
    z.d["props"][-1]["kind"] = "cottage"
    for x, y in [(40, 11), (41, 12), (18, 8)]:
        z.prop("rock", x, y, variant=0)
    scatter_props(z, "pine", 3, 3, 8, 16, 7, 3, avoid=("k",))
    scatter_props(z, "birch", 24, 3, 8, 10, 6, 5, avoid=("k",))
    z.prop("bench", 28, 14, variant=0)
    chat(z, "cd_ranger", "ghillie", 31, 17, "Ranger Iona", [
        "You took the lease. Not the Trust. I don't know whether to shake your hand or sit down.",
        "Thank you. Whatever happens to the numbers on the ledger, the glen has a chance now.",
        "Come back through the seasons. It doesn't look the same twice."])
    script(zid, "cd_ranger", seasons("Ranger Iona",
        "Thank you for the lease. Spring, and the burn is loud with snowmelt. The deer are thin after winter, so give them room.",
        "Summer. The deer have gone up the hill for the breeze, and the seedlings are up in their cages. Thank you.",
        "Autumn, and the stags are roaring on the tops. It's loud, and it's the best week of my year. Thank you for this.",
        "Winter. The deer come down to the shelter of the pines. Thank you for the lease, and for the quiet."))
    chat(z, "cd_walker", "hillwalker", 33, 21, "Hillwalker", [
        "I came for a bit of a stravaig and I've been asked to sign a visitors' book. Sort of. I like it.",
        "Under the Land Reform Act we can walk almost anywhere in Scotland, if we behave. Here, somebody finally asked us to."])
    creature(z, zid, "stagmor", 14, 12, line="A red deer stag stands on the skyline with the whole glen's attention on him.")
    creature(z, zid, "caperling", 9, 30, move="still", line="It clatters up into a pine and looks insulted that you noticed.")
    plaque(z, 29, 19, "lease_coire_dubh_forest", "A Deer Forest",
           "A DEER FOREST. The word is the old one for land kept for hunting, not a wood. Most of it is open hill with hardly a tree on it. Red deer are the largest wild land animal in Scotland, and where their numbers are kept high, young trees are eaten before they can grow.")
    plaque(z, 33, 15, "lease_coire_dubh_pinewood", "The Caledonian Pinewood",
           "THE CALEDONIAN PINEWOOD. Scots pine woods once covered much of the Highlands. Only scattered fragments of that forest survive. Where deer are fewer, or fenced out, pine, birch, rowan and juniper come back on their own, which is why people argue so hard about deer.")
    plaque(z, 36, 20, "lease_coire_dubh_stalking", "Stalking and the Railway",
           "STALKING AND THE RAILWAY. Deer stalking became fashionable in the 1800s, helped by the railways and by Queen Victoria's Highland holidays at Balmoral. Whole glens were cleared of people and farming for sporting estates. Since 2003 the Land Reform (Scotland) Act has given everyone a right of responsible access to most land.")
    table(z, [("fawnlet", 12, 0, {}), ("ptarmlet", 10, 0, {"time": ["day", "dawn"]}), ("stoatlet", 10, 0, {}),
              ("buntling", 8, 0, {"season": ["autumn", "winter"]}), ("caperling", 8, 1, {}),
              ("stagmor", 6, 2, {"time": ["dawn", "dusk"]}), ("capercaillie", 5, 3, {"time": ["dawn", "dusk"]}),
              ("highlynx", 4, 3, {"time": ["dusk", "night"]})], STAGE_FLAG % spec["id"])
    table(z, [("rillotter", 20, 0, {}), ("spatelord", 14, 0, {}), ("bradan", 12, 2, {})], STAGE_FLAG % spec["id"], "water")
    z.d["spawn"] = [30, 20]
    z.save(OUT + "/" + zid + ".json")


# ---------------------------------------------------------------- Dubh Lochan Flow, a Flow Country peat bog (Scotland)
def dubh_lochan(OUT, spec):
    zid = "lease_dubh_lochan"
    W, H = 52, 42
    z = Z(zid, "Dubh Lochan Flow", W, H, fill="m", kind="route", region="scotland", music="route_highlands",
          weather={"drizzle": 30, "fog": 24, "clear": 18, "downpour": 12, "gale": 8, "sunshine": 8})
    z.lo, z.hi = 76, 77
    z.d["stage"] = "bog"
    z.legend["m"] = {"tile": "tall_grass", "colour": "#9a8448"}
    z.legend["k"] = {"tile": "grass", "colour": "#7d8a50"}
    z.legend["y"] = {"tile": "grass", "colour": "#6b7444"}
    z.border("P", 2)
    entry(z, "east", spec["gap"][0], (36, 23))
    for i in range(10):                                   # the dubh lochans: pools in the bog
        blob(z, 6 + (i * 9) % 36, 5 + (i * 13) % 32, 2 + i % 3, 1 + i % 2, "~", only="m", seed=20 + i)
    for i in range(6):                                    # firm ground to walk round them
        blob(z, 10 + (i * 8) % 34, 8 + (i * 11) % 28, 4, 3, "y", only="m", seed=40 + i)
    z.scatter(3, 3, 46, 36, "*", 40, 9, only="m")         # bog you cannot cross without Bog-cross; kept sparse
    # the plantation: rows of sitka spruce on drained ground, ploughed in lines
    for x in range(5, 26, 2):
        z.rect(x, 24, 1, 14, "P")
    z.rect(5, 23, 21, 1, "k")
    z.rect(4, 3, 1, 1, "m")
    z.rect(30, 8, 12, 1, "F"); z.rect(30, 8, 1, 6, "F")   # a fenced block with the drains still cut
    for dy in (10, 12, 14):
        z.rect(31, dy, 10, 1, "q")
    z.legend["q"] = {"tile": "path", "colour": "#6a5a3c"}  # a peat drain, long and straight
    scatter_props(z, "rock", 3, 3, 46, 36, 8, 13, avoid=("m", "y"))
    chat(z, "dl_ranger", "birdwatcher", 35, 22, "Ranger Calum", [
        "You've taken the lease on a bog. People say that as if it's a joke. It's the most valuable thing you could have bought.",
        "Every drain we block, every tree we pull, and the water comes back. Thank you.",
        "Mind the green bits. They're not grass."])
    script(zid, "dl_ranger", seasons("Ranger Calum",
        "Spring. The golden plover are back on the tops and shouting about it. Thank you for the lease.",
        "Summer. Look at the cotton grass. The whole flow is nodding. Thank you for this, from every midge.",
        "Autumn, and the sphagnum is red and gold. It's the best colour on the bog, and nobody ever believes me.",
        "Winter. The pools freeze and the bog sleeps. It's still storing carbon, mind. It never clocks off. Thank you."))
    chat(z, "dl_surveyor", "fox_watcher", 28, 26, "Surveyor", [
        "I count the pools. The more water, the better the bog is doing.",
        "Four years ago this strip was a drain. Now look at it. It's learned to be wet again."])
    creature(z, zid, "dubhlet", 20, 12, line="It sits in the sphagnum like a very old sponge that has opinions.")
    creature(z, zid, "midgie", 12, 30, move="still", line="A small, furious cloud. You are, at the moment, its entire world.")
    plaque(z, 34, 24, "lease_dubh_lochan_flow", "The Flow Country",
           "THE FLOW COUNTRY. In Caithness and Sutherland lies one of the largest areas of blanket bog in Europe, about 4,000 square kilometres. The peat has been building up since the end of the last ice age, one thin layer of dead sphagnum moss at a time, and it holds a great deal of carbon.")
    plaque(z, 38, 20, "lease_dubh_lochan_trees", "Trees on a Bog",
           "TREES ON A BOG. In the 1980s tax relief on forestry led to large parts of the Flow Country being drained and planted with non-native conifers, which dried the peat. The relief ended in 1988 after a campaign by conservationists. Now the work is pulling the trees out and blocking the drains so the bog can re-wet.")
    plaque(z, 37, 26, "lease_dubh_lochan_heritage", "A World Heritage Bog",
           "A WORLD HERITAGE BOG. In 2024 the peatlands of Caithness and Sutherland were inscribed as a UNESCO World Heritage Site, recognising a landscape that was nearly planted over. Peatland covers only a small part of the Earth's land, but it stores more carbon than all the world's forests.")
    table(z, [("dubhlet", 16, 0, {}), ("midgie", 10, 0, {"weather": ["clear", "drizzle", "fog", "sunshine"]}),
              ("squibbet", 10, 0, {}), ("sphagnet", 10, 1, {}), ("croakle", 8, 1, {"weather": ["drizzle", "downpour"]}),
              ("crakeling", 8, 2, {"time": ["dusk", "night"]}), ("eaglet", 6, 2, {}),
              ("peatmonarch", 4, 3, {}), ("goldeneyrie", 3, 3, {})], STAGE_FLAG % spec["id"])
    table(z, [("flowmoor", 14, 1, {}), ("dubhlet", 16, 0, {})], STAGE_FLAG % spec["id"], "water")
    z.d["spawn"] = [35, 23]
    z.save(OUT + "/" + zid + ".json")


# ---------------------------------------------------------------- Clonbeg Cutaway, an Irish cutaway bog
def clonbeg(OUT, spec):
    zid = "lease_clonbeg"
    W, H = 50, 40
    z = Z(zid, "Clonbeg Cutaway", W, H, fill="k", kind="route", region="ireland_west", music="route_forest",
          weather={"drizzle": 38, "clear": 25, "fog": 12, "sunshine": 15, "downpour": 6, "gale": 4})
    z.lo, z.hi = 58, 59
    z.d["scaled_floor"] = 58
    z.d["stage"] = "bog"
    z.legend["k"] = {"tile": "grass", "colour": "#5a5448"}     # bare, dark cut peat
    z.legend["m"] = {"tile": "tall_grass", "colour": "#7c7048"}
    z.legend["q"] = {"tile": "path", "colour": "#40382e"}
    z.border("T", 2)
    entry(z, "west", spec["gap"][0], (14, 23))
    for x in range(8, 44, 4):                                # long straight drains between the cut fields
        z.rect(x, 4, 1, 14, "~") if x not in (16,) else None
    for x in range(8, 44, 4):
        z.rect(x, 4, 1, 3, "w"); z.rect(x, 12, 1, 2, "w")    # fords across every drain
    for i in range(8):
        blob(z, 6 + (i * 7) % 40, 22 + (i * 5) % 14, 3, 2, "m", only="k", seed=60 + i)
    z.rect(30, 20, 14, 2, "q"); z.rect(18, 21, 12, 1, "q")   # an old narrow-gauge railway bed
    z.rect(40, 22, 8, 12, "o"); z.rect(39, 22, 1, 12, "w"); z.rect(40, 34, 8, 1, "w")  # a new lake in the cutaway
    scatter_props(z, "birch", 3, 3, 44, 34, 9, 17, avoid=("k", "m"))
    scatter_props(z, "bush", 3, 3, 44, 34, 8, 19, avoid=("k", "m"))
    z.building(34, 27, 3, 1, "turf_stack", None, show_label=False)
    z.building(6, 28, 2, 1, "turf_stack", None, show_label=False)
    chat(z, "cb_ranger", "farmer", 15, 22, "Ranger Siobhan", [
        "You leased Clonbeg. I'm sorry, I'm still getting used to people who say yes.",
        "My grandfather cut turf on a bog like this with a sleán. Then the machines came and took it all in a few decades.",
        "Now we let the water back. Thank you. Go easy on the soft bits."])
    script(zid, "cb_ranger", seasons("Ranger Siobhan",
        "Spring, and the lapwings are tumbling over the field. Thank you for the lease. It sounds like a school playground.",
        "Summer, and look at it. Bog cotton, birch scrub, a lake where there was a pit. Thank you, truly.",
        "Autumn. The whooper swans will be in soon, up from Iceland. They always know before we do.",
        "Winter. The birds come in their thousands to the new wetlands. Thank you for giving them the room."))
    chat(z, "cb_cutter", "villager_3", 33, 24, "Turf Cutter", [
        "I cut turf by hand every spring, the old way, for the home fire. Nobody minds that. It's the machines that took the lot.",
        "Is it true you can't make a decent fire with a birch? You can. It's a different fire, that's all."])
    creature(z, zid, "sodling", 24, 14, line="It heaves itself out of the cutaway like a dropped clod and looks around sadly.")
    creature(z, zid, "crexling", 10, 32, move="still", line="A rasping call comes from somewhere in the grass, and it is, annoyingly, this one.")
    plaque(z, 17, 20, "lease_clonbeg_cutaway", "A Cutaway Bog",
           "A CUTAWAY BOG. Across the Midlands, Bord na Móna cut peat by machine for power stations and for gardens through most of the 1900s. When the peat is gone, bare ground called cutaway is left behind. Burning peat for electricity ended in 2020, and many cutaways are now being left to re-wet and grow wetland, scrub and woodland.")
    plaque(z, 13, 25, "lease_clonbeg_mesolithic", "The Oldest Fire",
           "THE OLDEST FIRE. At Lough Boora in County Offaly, workers cutting a bog found flint tools and traces of fires left by hunter-gatherers more than 8,000 years ago, the Mesolithic people. A bog keeps what falls into it, so what the machines uncovered was a landscape no one had seen since.")
    plaque(z, 17, 26, "lease_clonbeg_turf", "Turf and the Sleán",
           "TURF AND THE SLEÁN. For centuries families cut their own fuel by hand with a sleán, a narrow spade with a wing on one side, in spring. The sods were turned, footed, and stacked to dry in summer. Many still do, though bogs now belong to a wider story about carbon and wildlife.")
    table(z, [("sodling", 14, 0, {}), ("croakle", 10, 0, {"weather": ["drizzle", "downpour"]}), ("squibbet", 10, 0, {}),
              ("crexling", 8, 1, {}), ("bittling", 6, 1, {"time": ["dawn", "dusk"]}),
              ("kerryspot", 8, 2, {}), ("turfclamp", 6, 2, {}),
              ("corncrake", 5, 3, {"season": ["spring", "summer"]}), ("boomern", 4, 3, {"time": ["dusk", "night"]})], STAGE_FLAG % spec["id"])
    table(z, [("kerryspot", 12, 0, {}), ("bradan", 8, 2, {}), ("rillotter", 10, 3, {})], STAGE_FLAG % spec["id"], "water")
    z.d["spawn"] = [14, 23]
    z.save(OUT + "/" + zid + ".json")


# ---------------------------------------------------------------- Glenashen, an Antrim glen (Northern Ireland)
def glenashen(OUT, spec):
    zid = "lease_glenashen"
    W, H = 50, 44
    z = Z(zid, "Glenashen", W, H, fill="k", kind="route", region="ireland", music="route_forest",
          weather={"drizzle": 35, "clear": 22, "fog": 14, "sunshine": 14, "downpour": 10, "gale": 5})
    z.lo, z.hi = 64, 66
    z.d["stage"] = "valley"
    z.legend["k"] = {"tile": "grass", "colour": "#6f9248"}
    z.legend["h"] = {"tile": "tall_grass", "colour": "#7a6a52"}
    z.border("T", 2)
    entry(z, "east", spec["gap"][0], (36, 34))
    for y in range(3, 40):                                   # the glen water, with fords
        bx = 20 + round(3 * math.sin(y / 6.0))
        ford = y in (14, 15, 30, 31)
        for x in range(bx - 1, bx + 2):
            z.set(x, y, "w" if ford or x != bx else "~")
    for i in range(10):
        blob(z, 5 + (i * 9) % 42, 5 + (i * 13) % 34, 3, 2, "h", only="k", seed=80 + i)
    z.rect(6, 3, 1, 12, "W"); z.rect(6, 15, 8, 1, "W"); z.rect(30, 3, 14, 1, "W")   # sheep walls on the hill
    z.rect(30, 3, 1, 10, "W")
    z.scatter(3, 18, 12, 20, "T", 70, 5, only="k")                                   # a bit of glen woodland
    z.building(8, 26, 4, 3, "slate_cottage", "Ruined Cottage")
    z.d["props"][-1]["kind"] = "cottage"
    scatter_props(z, "oak", 3, 3, 14, 38, 8, 23, avoid=("k",))
    scatter_props(z, "rock", 24, 3, 22, 38, 8, 29, avoid=("k", "h"))
    z.prop("bench", 34, 33, variant=0)
    chat(z, "ga_ranger", "hillwalker", 35, 33, "Ranger Ciarán", [
        "You've taken Glenashen on. You might want to sit down, because I'm about to be very sincere at you.",
        "The glens were farmed by families, then by sheep, then by sporting estates. Everyone had a turn at keeping it down.",
        "Thank you. Let's see what it does when we stop."])
    script(zid, "ga_ranger", seasons("Ranger Ciarán",
        "Spring. Primroses on the bank and a hare in every field. Thank you for the lease. It is giddy out here.",
        "Summer. The ferns are shoulder high and the whole glen smells of wet green. Thank you, from the bottom of my boots.",
        "Autumn, and the beech and oak are going copper. Thank you. Bring a flask. It's cold in the glen and warm in the heart.",
        "Winter. The burn is brown and loud and the hills are white. Thank you for the lease, and the quiet."))
    chat(z, "ga_farmer", "farmer", 14, 28, "Hill Farmer", [
        "My family had the sheep on that hill for four generations. We'd a few good years. The lease isn't mine to complain about now.",
        "Leave the gate how you find it. That's the only rule worth having."])
    creature(z, zid, "leveret", 28, 12, line="An Irish hare, the only hare that belongs here, freezes with its ears flat in the grass.")
    creature(z, zid, "pixling", 12, 36, move="still", line="Something small peers out of the ferns. When you look again, there are only ferns.")
    plaque(z, 34, 35, "lease_glenashen_glens", "The Glens of Antrim",
           "THE GLENS OF ANTRIM. The glens are traditionally counted as nine, running down from the Antrim plateau to the sea, each cut by its own river. Glenariff is known as the Queen of the Glens. For centuries they were hill farms, and for a time the isolation kept the Irish and Gaelic traditions alive in the glens.")
    plaque(z, 38, 31, "lease_glenashen_hare", "The Irish Hare",
           "THE IRISH HARE. Ireland has its own subspecies of the mountain hare, which has lived here since the last ice age and mostly stays brown in winter, unlike the Scottish ones that turn white. It is Ireland's only native hare, and it is protected.")
    plaque(z, 33, 31, "lease_glenashen_squirrel", "Red Squirrels",
           "RED SQUIRRELS. The grey squirrel was brought to Ireland in 1911, when a few were released at Castle Forbes in County Longford. Greys carry squirrelpox, which kills reds, and push them out. Reds hold on best in conifer woods where the greys are fewer, and in places such as the glens where people have worked to keep them.")
    table(z, [("leveret", 12, 0, {}), ("pipkin", 10, 0, {}), ("stoatlet", 8, 0, {}),
              ("pixling", 8, 1, {"time": ["dusk", "night"]}), ("eaglet", 6, 2, {}),
              ("gealhare", 8, 2, {}), ("pixiedell", 5, 3, {"time": ["dusk", "night"]}), ("finnmacool", 4, 3, {})],
          STAGE_FLAG % spec["id"])
    table(z, [("bradan", 20, 0, {}), ("parrlet", 14, 0, {}), ("rillotter", 10, 2, {}), ("ratty", 8, 3, {})],
          STAGE_FLAG % spec["id"], "water")
    z.d["spawn"] = [36, 36]
    z.save(OUT + "/" + zid + ".json")


# ---------------------------------------------------------------- lease data (the contract) and the writer
SPECS = [
    {"id": "coire_dubh", "name": "Coire Dubh Deer Forest", "nation": "scotland", "kind": "deer_forest",
     "anchor": "cairngorms", "side": "south", "zone": "lease_coire_dubh", "reserve": 90000, "upkeep": 450,
     "unlock_flag": "game_complete", "trust_wants": True, "gap": [34, 3], "build": coire_dubh,
     "blurb": "A Highland deer forest above the Cairngorms: ten thousand acres of cropped hill, a deer fence, and a lodge the Enclosure kept for a few weeks of shooting a year. The Trust wants the stags kept up. The pines have other plans.",
     "rewild": {"biome": "pinewood", "rect": [3, 3, 41, 36], "lines": [
         "Grass cropped to the bone, and not a young tree on the hill.",
         "Seedlings in cages, and the first rowans are up through the heather.",
         "Young pines at shoulder height, juniper in the burn gullies.",
         "A pinewood again, and a capercaillie clattering through it like a dropped tea tray."]}},
    {"id": "dubh_lochan", "name": "Dubh Lochan Flow", "nation": "scotland", "kind": "peatland",
     "anchor": "flow_country", "side": "west", "zone": "lease_dubh_lochan", "reserve": 70000, "upkeep": 350,
     "unlock_flag": "game_complete", "trust_wants": False, "gap": [22, 3], "build": dubh_lochan,
     "blurb": "A drained corner of the Flow Country: rows of spruce on dried peat, ditches cut in straight lines, and a Vane Forestry sign. The bog is waiting under it, and it has all the time in the world.",
     "rewild": {"biome": "moss", "rect": [3, 3, 46, 36], "lines": [
         "Rows of spruce on dry peat, and the ditches still draining the hill.",
         "Drains blocked with peat dams, the first pools filling behind them.",
         "Sphagnum spreading in the wet, cotton grass in the open ground.",
         "Wet, red and gold with moss, and the plover back on the tops."]}},
    {"id": "clonbeg", "name": "Clonbeg Cutaway", "nation": "ireland", "kind": "cutaway_bog",
     "anchor": "lough_gur", "side": "east", "zone": "lease_clonbeg", "reserve": 45000, "upkeep": 300,
     "unlock_flag": "game_complete", "trust_wants": False, "gap": [22, 3], "build": clonbeg,
     "blurb": "A midland cutaway: eighty years of peat taken by the ton and the narrow-gauge railway left rusting in the heather. Nobody wants it, which is why you can have it. Let the water back and see.",
     "rewild": {"biome": "cutaway", "rect": [3, 3, 44, 36], "lines": [
         "Bare dark peat in long fields, drains running straight to nowhere.",
         "Drains blocked, birch seedlings starting along the edges.",
         "A shallow lake forming, reeds and rushes along its edge.",
         "Wetland, birch scrub, a lake full of birds, and a corncrake somewhere in the grass."]}},
    {"id": "glenashen", "name": "Glenashen", "nation": "northern_ireland", "kind": "glen_estate",
     "anchor": "antrim_coast", "side": "west", "zone": "lease_glenashen", "reserve": 55000, "upkeep": 350,
     "unlock_flag": "game_complete", "trust_wants": True, "gap": [33, 3], "build": glenashen,
     "blurb": "One of the quieter Antrim glens: a sheep-walled hill, a ruined cottage, a river in a hurry and a sporting lease the Trust would very much like back. Nobody has walked it in a generation.",
     "rewild": {"biome": "heath", "rect": [3, 3, 44, 38], "lines": [
         "Sheep-bitten grass, bracken on the slopes, and not a hare in sight.",
         "The sheep gone, the fences down, and the first rowan up in the gully.",
         "Heather and gorse, ferns on the river bank, a hare in the open field.",
         "Wild glen, birch and hazel in the gullies, and a hare in every field."]}},
]


def main(OUT):
    root = os.path.dirname(os.path.dirname(os.path.abspath(OUT)))
    os.makedirs(os.path.join(root, "data", "leases"), exist_ok=True)
    for spec in SPECS:
        ANCHOR_OF["lease_" + spec["id"]] = spec["anchor"]
        spec["build"](OUT, spec)
        zp = os.path.join(OUT, spec["zone"] + ".json")
        d = json.load(open(zp))
        back = {"north": "south", "south": "north", "east": "west", "west": "east"}[spec["side"]]
        d["edges"][back]["lease"] = spec["id"]               # lets the validator through; the anchor edge opens when owned
        json.dump(d, open(zp, "w"), indent=1)
        rec = {k: spec[k] for k in ("id", "name", "nation", "kind", "anchor", "side", "zone", "reserve", "upkeep",
                                    "unlock_flag", "trust_wants", "blurb")}
        rec["gap"] = {"from": spec["gap"][0], "len": spec["gap"][1]}   # where the anchor's border opens
        rec["stage_flag"] = STAGE_FLAG % spec["id"]
        rec["rewild"] = spec["rewild"]
        json.dump(rec, open(os.path.join(root, "data", "leases", spec["id"] + ".json"), "w"), indent=1)
    write_all(OUT)


if __name__ == "__main__":
    main(sys.argv[2])
