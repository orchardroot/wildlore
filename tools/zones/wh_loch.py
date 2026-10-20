"""Loch Lomond route (west of Glasgow) and its interiors, trainers and the Rob Roy quest scripts."""
from wh_lib import *

Z = "loch_lomond"


def build():
    o = Out(Z, "Loch Lomond", "route", 64, 56, "route_highlands", "forest",
            {"drizzle": 30, "clear": 22, "downpour": 14, "fog": 12, "gale": 6, "sunshine": 16})
    o.border()
    # pine and oak scatter first; paths, buildings and people overwrite or clear it
    o.scatter("P", 120)
    o.scatter("T", 60)
    # tall grass for the wild table
    o.ell(14, 40, 9, 6, ",", only=".PT")
    o.ell(40, 41, 10, 6, ",", only=".PT")
    o.ell(30, 49, 9, 3, ",", only=".PT")
    o.ell(50, 49, 6, 3, ",", only=".PT")
    o.ell(5, 28, 3, 6, ",", only=".PT")
    o.ell(58, 36, 3, 5, ",", only=".PT")
    # the loch, with a wading rim
    o.ell(31, 12, 19, 9, "~")
    wet = []
    for y in range(o.h):
        for x in range(o.w):
            if o.at(x, y) == "~":
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    if o.at(x + dx, y + dy) not in "~w":
                        wet.append((x, y))
                        break
    for x, y in wet:
        o.put(x, y, "w")
    # Ben Lomond: cliff and scree with one switchback path to the top
    o.rect(51, 2, 11, 20, "^")
    for _ in range(30):
        o.put(o.rng.randrange(51, 62), o.rng.randrange(2, 21), "/")
    o.line([(56, 22), (56, 19), (59, 19), (59, 14), (54, 14), (54, 9), (58, 9), (58, 5), (54, 5)], "#")
    o.rect(56, 22, 1, 6, "#")
    # the West Highland Way: Balloch road in from the east, the trail west, then up to the Oban road
    o.rect(50, 28, 14, 3, "=")
    o.rect(12, 28, 38, 2, "#")
    o.rect(12, 20, 2, 10, "#")
    o.rect(0, 20, 12, 3, "=")
    o.rect(7, 5, 2, 15, "#")             # the lane into Luss
    o.rect(40, 19, 2, 10, "#")           # Balloch pier
    o.rect(47, 25, 1, 3, "#")            # to Rob Roy's Cave
    o.rect(22, 30, 2, 13, "#")           # to the kirk
    # --- buildings --------------------------------------------------------------------------------------
    ds = {}
    ds["maid"] = o.building(36, 16, 8, 3, "paddle_steamer", "Maid of the Loch", None, 4, "loch_lomond_maid", 7, 7)
    ds["tea"] = o.building(3, 8, 5, 4, "white_render", "Luss Tea Room", "cafe", 4, "loch_lomond_tearoom", 6, 7)
    o.building(10, 8, 3, 3, "slate_cottage", "Cottage", "cottage", -1)
    o.building(3, 14, 4, 3, "slate_cottage", "Cottage", "cottage", -1)
    o.building(10, 14, 3, 3, "white_render", "Cottage", "cottage", -1)
    ds["ranger"] = o.building(30, 24, 6, 4, "stone", "Rowardennan Ranger Station", "museum", 3, "loch_lomond_ranger", 6, 7)
    ds["cave"] = o.building(46, 22, 4, 3, "gritstone", "Rob Roy's Cave", None, 1, "loch_lomond_cave", 7, 9)
    ds["kirk"] = o.building(17, 39, 5, 3, "chapel", "Balquhidder Kirk", "church", 4, "loch_lomond_kirk", 6, 7)
    # --- edges ------------------------------------------------------------------------------------------
    o.edges = {"east": {"to": "glasgow", "offset": 0}, "west": {"to": "oban", "offset": 0}}
    o.spawn = [56, 29]
    # --- dressing -----------------------------------------------------------------------------------------
    for x, y in ((51, 27), (61, 27), (38, 27), (14, 27)):
        o.prop("lamp_post", x, y)
    o.prop("bench", 53, 27)
    o.prop("bench", 34, 21)
    o.prop("bench", 9, 19)
    o.prop("boat", 24, 11, variant=1)
    o.prop("boat", 45, 9, variant=1)
    o.prop("buoy", 20, 15)
    o.prop("bollard", 39, 27)
    o.prop("bollard", 42, 27)
    for x, y in ((3, 18), (5, 17), (4, 19)):
        o.prop("sheep", x, y, variant=o.rng.randrange(2))
    for x, y in ((46, 40), (50, 41), (53, 38)):
        o.prop("brazier", x, y)
    o.prop("standing_stone", 20, 33, variant=1)
    o.sprinkle("bush", 40, only=".", variants=3, rows=(24, 53))
    o.sprinkle("rock", 25, only=".", variants=3, rows=(2, 53))
    o.sprinkle("birch", 20, only=".", variants=3, rows=(2, 20))
    # --- signs and plaques --------------------------------------------------------------------------------
    o.sign(60, 27, "BALLOCH. West: Loch Lomond, the Trossachs and on to Oban. East: Glasgow. The pier is for the paddle steamer and the car park is for everyone else.")
    o.sign(13, 19, "FINGERPOST. Luss, north. Oban, west. Ben Lomond, back the way you came and then up, a long way up.")
    o.sign(41, 29, "BALLOCH PIER. The Maid of the Loch is moored here. Volunteers are still restoring her, so come in and say hello.")
    o.sign(54, 4, "BEN LOMOND SUMMIT. The view takes in the loch, the Trossachs and, on a clear day, a mountain you can't name that someone is already naming loudly.")
    P = o.sign
    P(44, 27, "LOCH LOMOND. By surface area it is the biggest stretch of fresh water in Great Britain: about 24 miles long, with about thirty islands. In the song the low road is the way the spirit of the dead returns home, which is why he gets there first.",
      "whl_loch_lomond", "Loch Lomond")
    P(55, 6, "BEN LOMOND. At 974 metres it is the most southerly Munro. A Munro is a Scottish mountain over 3,000 feet, named for Sir Hugh Munro, who first listed them in 1891. Ticking them all off is called Munro-bagging, and it is not as violent as it sounds.",
      "whl_ben_lomond", "Ben Lomond")
    P(30, 27, "WEST HIGHLAND WAY. Scotland's first official long distance path, opened in 1980. It runs 96 miles from Milngavie, north of Glasgow, to Fort William, and the lochside stretch is where most people discover that their boots are not as waterproof as the shop said.",
      "whl_west_highland_way", "West Highland Way")
    P(42, 20, "MAID OF THE LOCH. Launched in 1953, she was the last paddle steamer built in Britain. She carried passengers up and down Loch Lomond until 1981, and volunteers have been bringing her back to life ever since.",
      "whl_maid_of_the_loch", "Maid of the Loch")
    P(32, 22, "OSPREYS. Hunted out of Scotland as breeding birds by the early 1900s, they came back by themselves to Loch Garten in 1954. They fish the lochs all summer, diving feet first, then fly to West Africa for the winter.",
      "whl_ospreys", "Ospreys")
    P(30, 43, "CAPERCAILLIE. The biggest grouse in the world, and a bird with opinions. The name is Gaelic, capall-coille, 'horse of the wood'. They died out in Scotland in the 1700s, were brought back from Sweden in 1837 and are now rare again. In spring a male will challenge walkers, so look wise and back away.",
      "whl_capercaillie", "Capercaillie")
    P(9, 18, "LUSS. A village of slate-roofed cottages beside the water, built for estate and quarry workers. For years it stood in for the fictional village of Glendarroch in a Scottish television drama called Take the High Road.",
      "whl_luss", "Luss")
    P(48, 26, "ROB ROY'S CAVE. Rob Roy MacGregor (1671 to 1734) was a cattle dealer turned outlaw, and legend says he hid in caves on the east shore of Loch Lomond. Whether this very cave ever sheltered him is a matter for the tourist board.",
      "whl_rob_roys_cave", "Rob Roy's Cave")
    P(52, 29, "BALLOCH. The name comes from the Gaelic bealach, which here means the outlet of the loch: the little River Leven leaves the water just south of here and heads for the Clyde.",
      "whl_balloch", "Balloch")
    P(24, 42, "THE CLAN BAN. The name MacGregor was banned by law for much of the 1600s and 1700s (1603 to 1661, and again 1693 to 1774). Rob Roy sometimes went by his mother's name, Campbell, which was a joke only the MacGregors found funny.",
      "whl_clan_ban", "The Clan Ban")
    # --- creatures and people ---------------------------------------------------------------------------
    T = o.enc
    for sp, lo, hi, w, cond in [
        ("fawnlet", 68, 70, 14, {"time": ["dawn", "dusk", "day"]}), ("stagmor", 68, 70, 8, {"time": ["dawn", "dusk"]}),
        ("lekling", 68, 70, 12, {"time": ["dawn", "day"]}), ("pinewraith", 68, 70, 10, {"time": ["dusk", "night"]}),
        ("brockling", 68, 70, 8, {"time": ["night", "dusk"]}), ("martling", 68, 70, 8, {}),
        ("hootlet", 68, 70, 8, {"time": ["night"]}), ("midgie", 68, 70, 8, {"weather": ["drizzle", "downpour"]}),
        ("wildkit", 68, 70, 6, {"time": ["dusk", "night"]}), ("ospret", 68, 70, 6, {"time": ["dawn", "day"]}),
        ("caperling", 68, 70, 5, {"time": ["dawn", "day"]}),
    ]:
        T("grass", sp, lo, hi, w, **cond)
    for sp, lo, hi, w, cond in [
        ("rillotter", 68, 70, 14, {}), ("dipling", 68, 70, 14, {}), ("ospret", 68, 70, 12, {"time": ["dawn", "day"]}),
        ("heronarch", 68, 70, 8, {}), ("bradan", 68, 70, 10, {"weather": ["drizzle", "downpour"]}),
        ("stalklet", 68, 70, 8, {}), ("minkshade", 68, 70, 8, {"time": ["dusk", "night"]}),
    ]:
        T("water", sp, lo, hi, w, **cond)
    o.npc("whl_redmac", "ghillie", 52, 31, "whl_redmac", "up", name="Red Mac")
    o.npc("whl_clansman", "ghillie", 54, 33, "whl_clansman", "left", name="Clansman")
    o.npc("whl_osprey", "creature:ospret", 33, 21, "whl_osprey", "down", "wander", radius=1)
    o.npc("whl_walker_talk", "hiker", 16, 27, "whl_walker_talk", "down", name="Way Walker")
    o.npc("whl_sheepfarmer", "farmer", 8, 16, "whl_farmer", "right", name="Hill Farmer")
    o.npc("whl_lek", "creature:lekling", 32, 46, "whl_lek", "up", "wander", radius=1)
    o.trainer_npc("whl_walker", "hillwalker", 26, 28, "whl_walker", "right")
    o.trainer_npc("whl_birder", "birdwatcher", 22, 26, "whl_birder", "down")
    o.trainer_npc("whl_angler", "angler", 11, 16, "whl_angler", "right")
    o.trainer_npc("whl_factor", "commuter", 44, 26, "whl_factor", "left")
    o.trainer_npc("whl_ghillie", "ghillie", 12, 44, "whl_ghillie", "right")
    # make sure nobody stands in a tree
    for n in o.npcs:
        if o.at(n["x"], n["y"]) in "TPR^~B":
            o.put(n["x"], n["y"], ".")
    for s in o.signs:
        if o.at(s["x"], s["y"]) in "TP":
            o.put(s["x"], s["y"], ".")
    for p in o.props:
        if p["type"] != "building" and o.at(p["x"], p["y"]) in "TP":
            o.put(p["x"], p["y"], ".")
    for dx, dy in ds.values():
        if o.at(dx, dy) in "TP":
            o.put(dx, dy, ".")
    o.save()

    # --- trainers ---------------------------------------------------------------------------------------
    trainer("whl_walker", "Way Walker Morven", "Hillwalker", "hillwalker",
            [("stagmor", 69), ("ptarmigan", 69), ("heilan", 70)], 2400,
            ["Ninety-six miles, Milngavie to Fort William, and I am on day two. My feet have formed a union."],
            "Right. I'll sit here and become part of the heather.",
            "Blisters are just the body's way of saying you're doing it right. It's lying.")
    trainer("whl_birder", "Osprey Watcher Iain", "Birdwatcher", "birdwatcher",
            [("lochosprey", 70), ("heronarch", 69), ("goldeneyrie", 70)], 2450,
            ["Shhh. There's an osprey about to dive. No, wait. It's a plastic bag. Ah well, you'll do instead."],
            "Marvellous. You scared off the real one, mind.",
            "They hover first, then fold and drop feet first. Spectacular. Also very quick, so I generally miss it blinking.")
    trainer("whl_angler", "Angler Fiona", "Angler", "angler",
            [("bradan", 69), ("rillotter", 68), ("heronarch", 69), ("minkshade", 69)], 2300,
            ["Powan, perch, pike, brown trout. Loch Lomond has a powan too, a fish that has been here since the ice age. I've caught none of them."],
            "I'll say this for you, you're quicker than any powan.",
            "The powan is a freshwater whitefish stranded here after the last ice age. It's rare, so mind where you stand.")
    trainer("whl_factor", "Montrose's Factor", "Factor", "commuter",
            [("rookery", 70), ("highlynx", 70), ("adderking", 71), ("raidtail", 70)], 3300,
            ["Good day. I act for the Duke of Montrose. I'm to inform you that a certain cattle dealer owes my employer a sum of money, and I'm awfully keen to find him. You haven't seen a MacGregor?"],
            "Hmph. I shall make a note in my ledger: 'lost, but with great dignity'.",
            "Do remind your friend the outlaw that the Duke is a patient man. The Duke is not a patient man.")
    trainer("whl_ghillie", "Ghillie Archie", "Ghillie", "ghillie",
            [("lekling", 69), ("caperling", 69), ("pinewraith", 70), ("brockmoor", 70)], 2350,
            ["Tread softly in these pines. The big grouse are lekking, and the cocks have no manners. One chased me up a gatepost last April."],
            "Good fight. Walk away slowly, don't turn your back, and nobody gets pecked.",
            "A lek is where the males gather to show off. It is, in short, a nightclub for grouse.")

    # --- scripts -------------------------------------------------------------------------------------------
    talk(Z, "whl_osprey", "", "An osprey hangs over the water on beating wings, folds up, and drops feet first. It comes up with a trout and a very smug expression.")
    talk(Z, "whl_lek", "", "A lekling struts in a little ring of flattened grass, fanning its tail and clicking like a pair of knitting needles. It is practising for an audience of none.")
    talk(Z, "whl_walker_talk", "Way Walker",
         "The West Highland Way opened in 1980, and I have been walking it in sections since. Section three is the one with the boulders. Section four is the one with the other boulders.",
         "Rule one: no cotton socks. Rule two: no cotton socks. There is no rule three because I can't think past the pain.")
    talk(Z, "whl_farmer", "Hill Farmer",
         "These sheep are Blackfaces, the commonest Scottish hill breed. Hardy, tough, and with an opinion about everything. They know where my gate is. They choose not to use it.")
    # Rob Roy quest, giver
    all_done = [if_("trainer_whl_factor",
                    [say("Red Mac", "The Factor beaten! Rob himself would raise a dram. Take this: an outlaw's sporran. It has carried worse than loose change, I promise."),
                     item("outlaws_sporran"), standing("scotland", 3), set_flag("q_westhighlands_rob_done"),
                     say("Red Mac", "Mind how you go. And if anyone asks, you never saw a MacGregor. You never saw a MacGregor, did you?")],
                    [say("Red Mac", "Montrose's Factor is still sniffing about east of the cave, by the water. Show him the MacGregors don't take orders from a ledger.")])]
    script(Z, "whl_redmac", [
        if_("q_westhighlands_rob_done",
            [say("Red Mac", "Rob Roy would have liked you. Not loved you, he loved no one who could count, but liked you.")],
            [if_("q_westhighlands_rob_started",
                 [if_("q_westhighlands_rob_1",
                      [if_("q_westhighlands_rob_2", all_done,
                           [say("Red Mac", "The cave is done. Next, Balquhidder: the kirkyard to the south-west, where he lies. The sexton keeps the old stories.")])],
                      [say("Red Mac", "Start where he hid. The cave on the east shore, south of the loch. My cousin's inside, in a tartan you'll hear before you see.")])],
                 [say("Red Mac", "Halt! Are you a Campbell? No? Good. I'm Red Mac, I do the Rob Roy tours, and my moustache is real."),
                  say("Red Mac", "Rob Roy MacGregor (1671 to 1734): a drover, a cattle dealer, an outlaw, a hero, a nuisance. Walter Scott wrote a novel about him in 1817 and made him famous."),
                  say("Red Mac", "He borrowed money from the Duke of Montrose to buy cattle, his clerk ran off with the cash, and the Duke called him an outlaw. Rob never forgave him. Shall we walk his trail?"),
                  set_flag("q_westhighlands_rob_started"),
                  say("Red Mac", "Three stops. The cave. The kirkyard at Balquhidder. Then the Duke's Factor, who is lurking east of the cave with a ledger. Come back to me when it's all done.")])])])
    talk(Z, "whl_clansman", "Clansman",
         "Don't mind the plaid, it's authentic wool, which is to say itchy. I'm Red Mac's cousin. We take it in turns to be fearsome.")
    # Interiors --------------------------------------------------------------------------------------------
    maid = interior("loch_lomond_maid", "Maid of the Loch", 15, 9, Z, ds["maid"],
                    props=[{"type": "steel_plates", "x": 2, "y": 2}, {"type": "steel_plates", "x": 12, "y": 2},
                           {"type": "table", "x": 4, "y": 5}, {"type": "table", "x": 10, "y": 5}, {"type": "bench", "x": 3, "y": 5},
                           {"type": "bench", "x": 11, "y": 5}, {"type": "clock", "x": 7, "y": 1, "walk": True},
                           {"type": "wall_picture", "x": 5, "y": 1, "walk": True, "variant": 1},
                           {"type": "wall_picture", "x": 9, "y": 1, "walk": True, "variant": 2},
                           {"type": "display_case", "x": 6, "y": 3, "variant": 1}, {"type": "potted_plant", "x": 1, "y": 7},
                           {"type": "rug", "x": 7, "y": 3, "w": 1, "h": 4, "variant": 1, "walk": True}],
                    npcs=[inpc("whl_maid_vol", "shipwright", 8, 3, "whl_maid_vol", name="Restoration Volunteer"),
                          inpc("whl_maid_purser", "sailor", 12, 6, "whl_maid_purser", "left", name="Old Purser")])
    talk("loch_lomond_maid", "whl_maid_vol", "Volunteer",
         "She was built by A and J Inglis, the Glasgow shipbuilders, in sections, then bolted together at Balloch in 1953. She was the last paddle steamer built in Britain.",
         "Paddle steamers are wonderfully simple. A steam engine turns a wheel and the wheel shoves the water. We are shoving at the council for a grant.")
    talk("loch_lomond_maid", "whl_maid_purser", "Old Purser",
         "Sailed her for years. Tea in the saloon, a band on summer Saturdays, and a purser's life is mostly telling people which way is the loch. It's the big wet thing.")
    tea = interior("loch_lomond_tearoom", "Luss Tea Room", 13, 8, Z, ds["tea"],
                   props=[{"type": "table", "x": 3, "y": 3}, {"type": "table", "x": 9, "y": 3}, {"type": "table", "x": 3, "y": 5},
                          {"type": "table", "x": 9, "y": 5}, {"type": "kitchen_dresser", "x": 6, "y": 1}, {"type": "potted_plant", "x": 1, "y": 6},
                          {"type": "potted_plant", "x": 11, "y": 6}, {"type": "wall_picture", "x": 3, "y": 1, "walk": True, "variant": 1},
                          {"type": "wall_picture", "x": 9, "y": 1, "walk": True, "variant": 2}, {"type": "tea_urn", "x": 11, "y": 1}],
                   counters=[(4, 2, 5)],
                   npcs=[inpc("whl_tea_owner", "mum", 6, 1, "whl_tea_owner", name="Tea Room Owner")])
    script("loch_lomond_tearoom", "whl_tea_owner", [
        say("Tea Room Owner", "Welcome, welcome. Scones are fresh, jam is local and the rain outside is not my fault."),
        if_("whl_tea_free", [say("Tea Room Owner", "You've had your free cuppa. The second one is a pound, but the biscuits are on the house.")],
            [say("Tea Room Owner", "Here, a cuppa for the road. This village was once on the telly, you know. 'Take the High Road'. Half of Luss was an extra."),
             item("cup_of_tea"), set_flag("whl_tea_free")])])
    ranger = interior("loch_lomond_ranger", "Rowardennan Ranger Station", 13, 9, Z, ds["ranger"],
                      props=[{"type": "wall_map", "x": 5, "y": 1, "walk": True}, {"type": "display_case", "x": 2, "y": 3, "variant": 1},
                             {"type": "specimen_shelf", "x": 9, "y": 1}, {"type": "bookshelf", "x": 1, "y": 1}, {"type": "table", "x": 6, "y": 4},
                             {"type": "bench", "x": 3, "y": 6}, {"type": "potted_plant", "x": 11, "y": 7},
                             {"type": "rug", "x": 5, "y": 5, "w": 3, "h": 2, "variant": 0, "walk": True},
                             {"type": "wall_picture", "x": 8, "y": 1, "walk": True, "variant": 3}],
                      npcs=[inpc("whl_ranger", "birdwatcher", 4, 3, "whl_ranger", name="Ranger"),
                            inpc("whl_ranger2", "hiker", 10, 4, "whl_ranger2", "left", name="Day Walker")])
    talk("loch_lomond_ranger", "whl_ranger", "Ranger",
         "Loch Lomond and the Trossachs became Scotland's first national park in 2002. We look after about seven hundred square miles of water, woodland and hill.",
         "The capercaillie lek in the old pines to the south. They're very rare now, and very rude. If a big dark grouse the size of a turkey squares up to you, you've been noticed.")
    talk("loch_lomond_ranger", "whl_ranger2", "Day Walker",
         "I did Ben Lomond yesterday. 974 metres, the most southerly Munro. Went up in sunshine, came down in four kinds of weather. Scotland does that.")
    cave = interior("loch_lomond_cave", "Rob Roy's Cave", 14, 11, Z, ds["cave"],
                    props=[{"type": "rock", "x": 2, "y": 2}, {"type": "rock", "x": 11, "y": 3}, {"type": "rock", "x": 3, "y": 7},
                           {"type": "brazier", "x": 6, "y": 3}, {"type": "standing_stone", "x": 10, "y": 7, "variant": 0}],
                    npcs=[inpc("whl_cave_guide", "ghillie", 7, 4, "whl_cave_guide", name="MacGregor Clansman")],
                    floor="e", extra={"legend_extra": {"e": {"tile": "path", "colour": "#5a5651"}}, "stage": "cave"})
    script("loch_lomond_cave", "whl_cave_guide", [
        say("MacGregor Clansman", "Mind your head. Rob Roy MacGregor is said to have hidden in caves like this one along the shore, away from the Duke's men and the Duke's lawyers, who were worse."),
        say("MacGregor Clansman", "Cattle drover, they called him. He moved herds from the glens down to the trysts, the great cattle markets. Then he borrowed against the herd, and his clerk made off with the money."),
        say("MacGregor Clansman", "The Duke of Montrose took his lands. Rob took to the hills. For years he led the redcoats a dance. In the end he was pardoned, and died in his bed at Balquhidder in 1734."),
        say("MacGregor Clansman", "Seek out his grave. It's in the kirkyard at Balquhidder, south-west of here. Tell the sexton the MacGregors sent you."),
        if_("q_westhighlands_rob_started", [set_flag("q_westhighlands_rob_1")])])
    kirk = interior("loch_lomond_kirk", "Balquhidder Kirk", 11, 9, Z, ds["kirk"],
                    props=[{"type": "bench", "x": 3, "y": 3}, {"type": "bench", "x": 3, "y": 5}, {"type": "bench", "x": 7, "y": 3},
                           {"type": "bench", "x": 7, "y": 5}, {"type": "statue", "x": 1, "y": 1}, {"type": "candelabra", "x": 5, "y": 1},
                           {"type": "wall_picture", "x": 8, "y": 1, "walk": True, "variant": 2}, {"type": "potted_plant", "x": 9, "y": 7}],
                    npcs=[inpc("whl_sexton", "poet", 5, 3, "whl_sexton", name="Sexton")], floor="+")
    script("loch_lomond_kirk", "whl_sexton", [
        say("Sexton", "Rob Roy lies in the kirkyard outside, with his wife Mary and two of his sons. The stone has a sword on it and a Celtic cross, and a surprising number of visitors lay coins on it."),
        say("Sexton", "He was nearly sixty-three when he died, which for a man who'd been hunted most of his life is a good innings. The story says he received his last visitors fully dressed, with his sword and his bagpipes."),
        say("Sexton", "He asked for the pipes to be played as he died. Whether it's true or not, nobody dared contradict a MacGregor. Not at the time."),
        if_("q_westhighlands_rob_started", [set_flag("q_westhighlands_rob_2")])])
    return {"maid": maid, "tea": tea, "ranger": ranger, "cave": cave, "kirk": kirk}
