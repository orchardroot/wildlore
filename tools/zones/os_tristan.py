# 3.3 "Overseas", wave 33 agent 2: Tristan da Cunha, the most remote inhabited island in the world.
#   tristan_da_cunha (town, one zone): Edinburgh of the Seven Seas on the Settlement Plain, the harbour, the Potato Patches,
#   Red Hill (the 1961 eruption) and Queen Mary's Peak behind
# Usage: python3 tools/zones/os_tristan.py data/zones
import sys
from os_common import *

TERR = "tristan"
REGION = "overseas_tristan"
WX = {"drizzle": 22, "fog": 14, "clear": 18, "gale": 24, "downpour": 10, "sunshine": 8, "frost": 4}
Q = "q_overseas_tristan_"


def tristan(OUT):
    W, H = 66, 58
    zid = "tristan_da_cunha"
    z = Z(zid, "Edinburgh of the Seven Seas", W, H, kind="town", region=REGION, music="town_scotland", weather=WX)
    z.d["stage"] = "coast"; z.d["town_id"] = zid; z.d["scaled_floor"] = FLOOR
    z.legend["k"] = {"tile": "grass", "colour": "#6c8a4c"}
    z.legend["g"] = {"tile": "grass", "colour": "#4e7a3c"}
    z.legend["h"] = {"tile": "tall_grass", "colour": "#5e7a46"}
    z.legend["a"] = {"tile": "sand", "colour": "#3a363c"}                 # black volcanic sand
    z.legend["j"] = {"tile": "rock", "colour": "#2a2628"}
    z.legend["q"] = {"tile": "sand", "colour": "#8a4c3a"}                 # red cinder on Red Hill
    z.legend["n"] = {"tile": "path", "colour": "#e6edf2"}                 # snow near the summit
    z.legend["c"] = {"tile": "cliff", "colour": "#5e564e", "side": "#4a423c"}
    z.rect(0, 0, W, H, "k")
    # the sea along the north, a black beach, the Settlement Plain, and the cone behind
    z.rect(0, 0, W, 9, "$"); z.rect(0, 9, W, 1, "w"); z.rect(0, 10, W, 3, "a")
    z.border("T", 2, gaps=[(0, 0, 0, 0)]); z.rect(0, 0, W, 10, "$"); z.rect(0, 9, W, 1, "w"); z.rect(0, 10, W, 3, "a")
    z.rect(0, 13, 2, H - 13, "c"); z.rect(W - 2, 13, 2, H - 13, "c"); z.rect(0, H - 2, W, 2, "c")
    mound(z, 33, 52, 26, 11, 7, tile="c", floor=4)               # Queen Mary's Peak
    mound(z, 33, 52, 8, 5, 7, tile="n", floor=6)
    mound(z, 55, 24, 8, 7, 4, tile="j", floor=2)                 # Red Hill, the 1961 cone
    smooth(z)
    blob(z, 55, 24, 6, 5, "q", only="kj", seed=3, jitter=0.3)
    blob(z, 55, 24, 3, 3, "j", only="kq", seed=4, jitter=0.2)
    blob(z, 12, 44, 8, 4, "h", only="k", seed=5, jitter=0.5)
    blob(z, 50, 44, 9, 4, "h", only="k", seed=6, jitter=0.5)
    blob(z, 30, 40, 8, 3, "h", only="k", seed=7, jitter=0.5)
    # the one road, with a lane up toward the peak
    z.rect(6, 20, 54, 2, "=")
    z.rect(31, 13, 2, 30, "=")
    z.rect(31, 40, 2, 4, "#")
    # the harbour: a breakwater, boats, the factory quay
    z.building(40, 6, 9, 4, "pier", "Harbour", show_label=False)
    for (bx, by) in [(22, 5), (32, 3), (56, 4)]:
        z.prop("boat", bx, by, variant=0)
    z.prop("bollard", 38, 13); z.prop("bollard", 46, 13); z.prop("lobster_pots", 36, 13); z.prop("lobster_pots", 50, 13)
    # row A
    ret_church = door_to(z, 12, 14, 7, 4, 3, "chapel", "St Mary's Church", "tristan_church", 13, 10)
    ret_s, ret_h = town_buildings(z, zid, (21, 14, "sanctuary"), (28, 14, "shop"))
    ret_hall = door_to(z, 36, 14, 9, 4, 4, "harbour_white", "Prince Philip Hall", "tristan_hall", 13, 10)
    ret_fact = door_to(z, 46, 14, 7, 4, 3, "harbour_white", "Fishing Factory", "tristan_factory", 13, 10)
    # row B
    ret_post = door_to(z, 12, 23, 6, 4, 2, "tin_cottage", "Post Office", "tristan_post", 11, 9)
    ret_knit = door_to(z, 19, 23, 6, 4, 2, "tin_cottage", "The Knitters' House", "tristan_knit", 11, 9)
    z.building(26, 23, 5, 4, "tin_cottage", "Edinburgh")
    z.building(34, 23, 6, 4, "tin_cottage", "Edinburgh")
    z.building(41, 23, 6, 4, "tin_cottage", "Edinburgh")
    ret_school = door_to(z, 48, 23, 7, 4, 3, "harbour_white", "St Mary's School", "tristan_school", 13, 10)
    # the Potato Patches, west: walled plots
    for (px, py) in [(4, 28), (10, 28), (4, 34), (10, 34), (4, 40), (16, 34)]:
        z.rect(px, py, 5, 4, "W"); z.rect(px + 1, py + 1, 3, 2, "g"); z.set(px + 2, py, "g")
    scatter_props(z, "sheep", 20, 30, 12, 8, 4, 31, avoid=("k",))
    for (lx, ly) in [(14, 21), (24, 21), (38, 21), (50, 21), (32, 30)]:
        z.prop("lamp_post", lx, ly)
    for (bx, by) in [(20, 22), (44, 22)]:
        z.prop("bench", bx, by)
    scatter_props(z, "rock", 4, 14, 58, 36, 22, 32, avoid=("k",))
    z.d["spawn"] = [32, 19]
    # ---- plaques ----
    plaque(z, 26, 19, "tristan_island", "Tristan da Cunha",
           "The most remote inhabited island in the world: about 2,400 kilometres from St Helena and 2,800 from Cape Town, the nearest city. A Portuguese sailor, Tristao da Cunha, saw it in 1506. The island is the tip of a volcano rising from the floor of the Atlantic, and the settlement is on its only flat land.")
    plaque(z, 34, 20, "tristan_edinburgh", "Edinburgh of the Seven Seas",
           "The only settlement, named after Prince Alfred, Duke of Edinburgh, Queen Victoria's second son, who visited in 1867, the first royal to do so. The islanders call it, simply, the Settlement. It has about 250 people, a hospital, a school, a church, a pub and one shop.")
    plaque(z, 33, 25, "tristan_glass", "William Glass",
           "In 1816 Britain garrisoned Tristan to stop anyone using it to rescue Napoleon from St Helena. When the garrison left in 1817, a Scottish corporal, William Glass of Kelso, stayed on with his wife and children. He founded the community, and Glass is still one of the island's seven surnames.")
    plaque(z, 24, 20, "tristan_surnames", "Seven Surnames",
           "Everyone on Tristan carries one of seven surnames: Glass, Green, Hagan, Lavarello, Repetto, Rogers and Swain. They come from a Scot, a Dutchman, two Italian sailors shipwrecked in 1892, an American whaler and others. The islanders have a shared sense of humour about it.")
    plaque(z, 56, 18, "tristan_eruption", "The Eruption of 1961",
           "In October 1961 earthquakes shook the settlement, and a new volcano opened right next to it. Every islander was evacuated, by boat to Nightingale Island, then to Cape Town and on to England, where they lived for two years near Southampton. In 1963 most chose to return, and found their houses still standing.")
    plaque(z, 8, 33, "tristan_potatoes", "The Potato Patches",
           "The islanders' traditional farm is the Patches, a set of walled fields west of the Settlement where the potatoes grow. Tristan potatoes are eaten at nearly every meal. The soil is rich and volcanic, and the wind is strong enough to take your cap and carry it to St Helena.")
    plaque(z, 52, 19, "tristan_crawfish", "The Crawfish",
           "Tristan rock lobster, called crawfish by the islanders, is the island's main source of income. The fishery has been carefully managed, with a quota and a season, for decades. The catch is processed at the factory here and shipped out to markets abroad, in the holds of a ship that visits only a few times a year.")
    plaque(z, 40, 11, "tristan_rockhoppers", "Rockhopper Penguins",
           "Northern rockhopper penguins nest on Tristan and its neighbours, Nightingale and Gough. They hop, rather than waddle, from rock to rock, with both feet together. Their numbers have crashed over the last century, and they are now an endangered species, so the islanders protect their colonies.")
    plaque(z, 30, 41, "tristan_peak", "Queen Mary's Peak",
           "The island's summit, 2,062 metres, rises almost straight out of the sea, and in winter is white with snow. It is the volcano itself, with a crater lake near the top. There are paths to the summit, but the islanders say you should never go without telling someone and leaving before the cloud comes in.")
    plaque(z, 36, 28, "tristan_gough", "Gough and Inaccessible",
           "Gough Island and Inaccessible Island, in the Tristan da Cunha group, are a World Heritage Site for their seabirds and endemic species. Inaccessible has the world's smallest flightless bird, the Inaccessible Island rail, and Gough has one of the great albatross colonies. Both are protected, and visitors need a permit.")
    # ---- folk ----
    chat(z, "tri_glass", "villager_3", 33, 28, "Islander (Glass)",
         ["I'm a Glass. My family has been here since William Glass, and he was from Kelso, in the Scottish Borders. He had his own flag, his own rules, and a wife who kept the rest of them in order.",
          "We say 'Yes' to everything here, because it's more polite. You can always change your mind later."], "right", "still")
    chat(z, "tri_green", "fisherman_north", 42, 28, "Islander (Green)",
         ["I'm a Green. Peter Green was a Dutch sailor who came ashore in the 1830s and stayed. Sailors have been doing that here since the first ship, and I think the potatoes are why.",
          "The Greens, the Glasses and the rest got on, married and argued, and made a place that works. It's a very small place, and everyone has an opinion about it."], "left", "still")
    chat(z, "tri_repetto", "sailor", 22, 28, "Islander (Repetto)",
         ["We're Repettos and Lavarellos. Two Italian sailors off the Italia, a barque wrecked on Tristan in 1892. They came from the little town of Camogli, near Genoa, and stayed.",
          "Nobody's had a bad word to say about their cooking since. Tristan has a good deal of garlic."], "down", "still")
    chat(z, "tri_rogers", "ghillie", 52, 28, "Islander (Rogers)",
         ["I'm a Rogers. We started with an American whaler, Andrew Rogers, who came in the 1830s. Whaling ships used to put in at Tristan for water and potatoes, and he chose a different life.",
          "I can tell you the whole story, but I'd rather you went up to the Patches and saw the potatoes yourself."], "left", "still")
    chat(z, "tri_knitter", "villager_4", 14, 29, "Knitter",
         ["We knit hats, gloves, jumpers, socks. The sheep's wool goes round and round the island a few times before it is a jumper. I'll tell you now: a Tristan hat will see you through a winter in the Atlantic.",
          "Every stitch is for somebody. If there's a gale coming and you've none to hand, you'll be offered one."], "down", "still")
    chat(z, "tri_birder", "birdwatcher", 40, 12, "Penguin Counter",
         ["Rockhoppers. We count them from the cliff paths and the boats. In the last century their numbers have fallen by about nine in ten, which is a thing you say very gently.",
          "A penguin will stare at you as though you've taken its seat. It's a good lesson. They've been there longer."], "down", "still")
    return_npc(z, zid, 41, 12, "sailor", "Harbour Master",
               "The ship is in. Strictly, there is no flight from Tristan, because we've no airstrip. The RAF drops you at Cape Town and a fishing boat does the rest. You've done the rest. Shall we get you back?",
               "All aboard. Six days to the Cape, if the sea behaves, and a Voyager at the other end.", facing="down")
    # ---- wild ----
    wild_set(z, [("hopperlet", 14, {}), ("thumbrail", 10, {}), ("ternlet", 8, {}), ("gannetling", 8, {}), ("petrelash", 8, {"weather": ["gale"]}),
                 ("herdlet", 8, {}), ("sodling", 8, {}), ("beaconet", 8, {}), ("haarling", 8, {"weather": ["fog", "frost"]}), ("hootlet", 6, {"time": ["night"]})])
    wild_set(z, [("crawfisher", 14, {}), ("selklet", 10, {}), ("orcalet", 8, {}), ("basaltling", 10, {}), ("pupplash", 10, {}), ("puffling", 8, {})], "water")
    trainer(z, "tri_lobsterman", "Lobsterman Dennis", "Lobsterman", "fisherman_north",
            [("crawfisher", 96), ("pinchkin", 95), ("greyhaul", 96), ("clawcastle", 96)], 44, 12, "left",
            ["Pots down at dawn, pots up at dusk. The sea decides, and the quota decides after that. Fancy a bet on the weather?"],
            "A fair haul. I'll tell the factory you've been unusually kind.",
            "The crawfish fishery on Tristan is certified sustainable: strict quotas, minimum sizes and a closed season. It supports the whole island, and a lot of tea.", 5700)
    trainer(z, "tri_farmer", "Potato Farmer Sandy", "Farmer", "farmer",
            [("herdlet", 95), ("turfmere", 96), ("sodling", 95), ("turfclamp", 96)], 12, 31, "right",
            ["Every family has Patches, and every Patches has a wall, and every wall has a dispute about it. The potatoes are fine."],
            "Well. That's me done for the harvest.",
            "Potatoes are the island's staple and most families grow their own in the Patches. Cattle and sheep graze the open ground, and everything goes to the plate.", 5500)
    trainer(z, "tri_rower", "Longboat Rower Lena", "Rower", "currach_rower",
            [("selklet", 96), ("orcalet", 96), ("polartern", 96), ("plungebeak", 96)], 36, 12, "down",
            ["In a gale the longboat is the only way off this island. We row it out beyond the surf, then it's all arms. A battle is just a boat race with sillier rules."],
            "That's a good pull. You'd do well in the second crew.",
            "Tristan's open longboats carry people and cargo out to the ships, which anchor beyond the surf. The landing place, Calshot Harbour, is named for the place in Hampshire where the evacuees stayed.", 5700)
    trainer(z, "tri_penguin_t", "Penguin Counter Oli", "Conservation Officer", "birdwatcher",
            [("hopperlet", 96), ("rockhopper", 96), ("thumbrail", 95), ("polartern", 96)], 28, 11, "right",
            ["I've been counting these for eight years. I can tell the difference between a rockhopper and a punk rocker, as long as the rocker isn't hopping."],
            "A very decent show. I'll put you down as 'courteous'.",
            "Seabird colonies on Tristan, Nightingale and Gough have been counted by islanders and scientists for decades, which is how we know how fast the numbers have fallen.", 5700)
    trainer(z, "tri_legend", "Chief Islander Mabel", "Chief Islander", "keeper_hester",
            [("rockhopper", 97), ("crawfisher", 97), ("thumbrail", 96), ("beaconblaze", 97), ("selkie", 97), ("polartern", 97)], 52, 18, "left",
            ["Chief Islander is a real job, you know. It means chairing the Council, settling disputes about walls, and being at the harbour whenever a ship comes. You'll take a seat, and I'll show you how we do things."],
            "Well. The Council will be told you fought fair. And that you ate a lot of cake.",
            "Tristan has a Chief Islander and an Island Council, an Administrator sent out from London, and a good many committees, all of them held in the same room.", 9500)
    # the Chief Islander is the quest-giver and last battle
    for n in z.d["npcs"]:
        if n["id"] == "tri_legend":
            del n["trainer"]; n["script"] = "tri_legend_talk"; n["name"] = "Chief Islander Mabel"
    scaled(["tri_lobsterman", "tri_farmer", "tri_rower", "tri_penguin_t", "tri_legend"])
    finish_zone(z)
    z.save(OUT + "/" + zid + ".json")
    return ret_church, ret_s, ret_h, ret_hall, ret_fact, ret_post, ret_knit, ret_school


def interiors(OUT, ret_church, ret_hall, ret_fact, ret_post, ret_knit, ret_school):
    zid = "tristan_da_cunha"
    interior(OUT, "tristan_church", "St Mary's Church", zid, ret_church, "church",
             [npc("tri_priest", "choir_singer", 6, 2, "tri_priest", name="Priest")])
    script("tristan_church", "tri_priest", say("Priest",
           "Welcome to St Mary's. After the eruption the congregation worshipped in a hall at Calshot, in Hampshire, for two years. When they came home, the first service was here, and there was not a dry eye.",
           "Everyone comes on Sunday. It is hard not to, on an island of two hundred and fifty. We also have a lot of weddings, because it's hard to find someone in a community of this size who isn't a cousin, and we're all very good about it."))
    interior(OUT, "tristan_hall", "Prince Philip Hall and Albatross Bar", zid, ret_hall, "cafe",
             [npc("tri_barman", "villager_2", 3, 1, "tri_barman", name="Barman"),
              npc("tri_dancer", "fiddler", 9, 3, "tri_dancer", name="Fiddler", facing="left")],
             props=[("fireplace", 6, 1, {"walk": True})])
    script("tristan_hall", "tri_barman", say("Barman",
           "Welcome to the Albatross Bar. We've a quiz on Friday, a dance on Saturday, and on Sunday we recover. The beer comes by ship, so there are good weeks and bad weeks.") +
           [{"do": "quiz", "pub": "tristan_hall", "region": "overseas", "who": "Barman"}])
    script("tristan_hall", "tri_dancer", say("Fiddler",
           "The squaredance is our big one. A caller shouts the steps and everyone swings, and the whole hall shakes like a boat. We've done it for generations, and the floor has never once complained.",
           "A fiddle, an accordion and the wind outside, and nobody leaves till the ship's bell goes. If a ship is in, nobody leaves at all."))
    interior(OUT, "tristan_factory", "Fishing Factory", zid, ret_fact, "workshop",
             [npc("tri_foreman", "steelworker", 6, 3, "tri_foreman", name="Factory Foreman")],
             props=[("table", 3, 3, {}), ("table", 9, 3, {})])
    script("tristan_factory", "tri_foreman", say("Foreman",
           "This is where the crawfish are processed. Tails frozen, whole lobsters packed, everything labelled. Every islander who isn't at the harbour is in here, on the line.",
           "When the ship arrives the whole island turns out to load it. It takes a day. Everyone has a job, even the children, and the gulls take on whatever's left."))
    interior(OUT, "tristan_post", "Post Office", zid, ret_post, "cafe",
             [npc("tri_postmistress", "shopkeeper", 3, 1, "tri_postmistress", name="Postmistress")], w=11, h=9,
             signs=[(8, 3, "TRISTAN STAMPS. Penguins, albatrosses and boats. Collectors write from all over the world.")])
    script("tristan_post", "tri_postmistress", say("Postmistress",
           "Tristan has had its own stamps since 1952, and they have always been popular with collectors. The money helps pay for the island. If you write a card, it goes on the ship with the crawfish.",
           "A letter takes a few months to get home from here, depending on how many sea days there are between you and the Cape. Please be patient. And be nice to the postmistress."))
    interior(OUT, "tristan_knit", "The Knitters' House", zid, ret_knit, "home",
             [npc("tri_granny", "villager_6", 4, 3, "tri_granny", name="Knitting Granny")], w=11, h=9)
    script("tristan_knit", "tri_granny", say("Knitting Granny",
           "Sit down, love. I'll finish this row and then we'll talk. I knit hats for the whole island and for the ship's crew, and they come back to buy more.",
           "The old way is to knit from the fleece of our own sheep, which are small and tough and a bit sniffy about being sheared. The wool is thick and oily and keeps out anything the Atlantic can throw."))
    interior(OUT, "tristan_school", "St Mary's School", zid, ret_school, "school",
             [npc("tri_teacher", "gown_student", 6, 3, "tri_teacher", name="Teacher")])
    script("tristan_school", "tri_teacher", say("Teacher",
           "My class is eleven children. We learn the usual things, and a good few the other schools don't: knitting, boat handling, how to read a sky. Most of my pupils will go away to study and many will come home.",
           "The children write to penpals all round the world, and the letters take months. They've learned that waiting for an answer is a skill."))


def quest_data(OUT):
    z = "tristan_da_cunha"
    hint = say("Chief Islander Mabel", "Four families will tell you where their names came from. A Glass, a Green, a Repetto and a Rogers. Talk to each of them, and come back.")
    fight = say("Chief Islander Mabel", "You've heard the names of the founders, from the ones who carry them. The Council is pleased. Now, a bit of island custom: a friendly fight, with no hard feelings and a lot of tea after.") + \
        [battle("tri_legend")] + \
        say("Chief Islander Mabel", "Well fought. The island makes you an honorary Tristanian for a day. Here is a hat of our own wool, and a basket of our own potatoes.") + \
        [give("tristan_hat"), give("tristan_potato", 3)] + standing(3) + [setf(Q + "done")]
    DLG[z]["tri_legend_talk"] = [cmd_if(Q + "done",
        say("Chief Islander Mabel", "Our friend of the island! Come and have a cup of tea any time. And bring your own hat."),
        [cmd_if(Q + "started",
                [cmd_if(Q + "1", [cmd_if(Q + "2", [cmd_if(Q + "3", [cmd_if(Q + "4", fight, hint)], hint)], hint)], hint)],
                say("Chief Islander Mabel", "Hello! You've come a long way. Would you like to hear where we all came from? Four families will tell you: a Glass, a Green, a Repetto and a Rogers. Find them in the Settlement, and then come back to me.") + [setf(Q + "started")])])]
    for nid, who, key in [("tri_glass", "Islander (Glass)", "1"), ("tri_green", "Islander (Green)", "2"), ("tri_repetto", "Islander (Repetto)", "3"), ("tri_rogers", "Islander (Rogers)", "4")]:
        old = DLG[z][nid]
        DLG[z][nid] = old + [cmd_if(Q + "started", [setf(Q + key)])]
    # the last name sets step 4; the earlier steps are flags set as each is told (any order)
    quests = [{"id": "tristan_names", "title": "Four Names", "region": "overseas_tristan", "town": "tristan_da_cunha", "giver": "Chief Islander Mabel",
               "summary": "Learn where Tristan's families came from, from the Glasses, Greens, Repettos and Rogers, then take the Chief Islander's challenge.",
               "start_flag": Q + "started",
               "steps": [{"flag": Q + "1", "text": "Hear the Glass story: a Scottish corporal from Kelso.", "zone": "tristan_da_cunha"},
                         {"flag": Q + "2", "text": "Hear the Green story: a Dutch sailor who settled in the 1830s.", "zone": "tristan_da_cunha"},
                         {"flag": Q + "3", "text": "Hear the Repetto story: two Italian sailors from Camogli.", "zone": "tristan_da_cunha"},
                         {"flag": Q + "4", "text": "Hear the Rogers story: an American whaler, then return to the Chief Islander for a battle.", "zone": "tristan_da_cunha"}],
               "done_flag": Q + "done", "reward": "The Tristan Hat (a Frost charm), three Tristan Potatoes and standing in the Overseas Territories."}]
    write_quests(TERR, quests)


def items_and_registry():
    return [heal_item("tristan_potato", "Tristan Potato", 240, 100, "A potato from the Patches, boiled in its skin, split and buttered. Tristan potatoes are the staple of the island and are eaten at almost every meal. Restores 100 HP."),
            heal_item("crawfish_tail", "Crawfish Tail", 520, 170, "The tail of a Tristan rock lobster, which the islanders call crawfish, steamed and served with a little butter. The fishery is the island's main income. Restores 170 HP."),
            charm_item("tristan_hat", "Tristan Hat", "A thick woollen hat knitted on Tristan from the wool of the island's own sheep. It has seen off gales that would have taken a lighthouse.",
                       "Frost moves hurt it 25% less.", {"effect": "resist", "type": "frost", "mult": 0.75}, "{name} was kept snug by the Tristan Hat!")]


def main(OUT):
    ret_church, ret_s, ret_h, ret_hall, ret_fact, ret_post, ret_knit, ret_school = tristan(OUT)
    interiors(OUT, ret_church, ret_hall, ret_fact, ret_post, ret_knit, ret_school)
    sanctuary_and_shop(OUT, "tristan_da_cunha", "Edinburgh", ret_s, ret_h,
        ["Come in, come in. The Tristan hospital, which for creatures we call the Sanctuary. There's a nurse on shift every night, because on an island like this somebody must be.",
         "A cup of tea and a bun, and you'll be right as a penguin in a gale. Pop them down.",
         "All better. They're tougher than a Tristan hat now.",
         "The Ark's in the corner. We'd put it by the window but the gulls take an interest.",
         "No bother. Take your hat."],
        ("Hello! Potatoes, crawfish and the odd tin that the ship brought. We have the one shop, so I know everyone's business, and I'll tell you none of it.", "Mind the wind on the way out. It's got ideas."),
        ["cup_of_tea", "flask_of_tea", "smelling_salts", "wicker_snare", "iron_snare", "water_snare", "night_snare", "tristan_potato", "crawfish_tail"])
    quest_data(OUT)
    write_items("overseas_tristan", items_and_registry())
    write_registry("tristan", "Tristan da Cunha", "tristan_da_cunha", 32, 19, "raf",
                   "The most remote inhabited island on Earth. Rockhoppers, crawfish and a volcano.",
                   "There is no airstrip on Tristan da Cunha, so the Voyager sets down at Cape Town and a fishing boat does the rest. Six days of sea later: Edinburgh of the Seven Seas, and a very large penguin waiting politely.")
    append_quiz("overseas", [
        ("geography", "Which settlement is the only one on Tristan da Cunha?", "Edinburgh of the Seven Seas", ["Georgetown", "Jamestown", "Stanley"], "It is named after Prince Alfred, Duke of Edinburgh, who visited in 1867."),
        ("history", "What happened on Tristan da Cunha in October 1961?", "A volcano erupted", ["A hurricane struck", "A great ship sank in the bay", "An airfield opened"], "The whole island was evacuated to England and most chose to return in 1963."),
        ("creatures", "Which bird is the world's smallest flightless bird?", "The Inaccessible Island rail", ["The kiwi", "The penguin", "The dodo"], "It lives only on Inaccessible Island in the Tristan da Cunha group."),
        ("food", "Which vegetable grows in the Patches on Tristan da Cunha?", "Potatoes", ["Carrots", "Turnips", "Cabbages"], "Tristan potatoes are eaten at almost every meal."),
        ("history", "How many surnames are there on Tristan da Cunha?", "Seven", ["Three", "Twenty", "A hundred"], "Glass, Green, Hagan, Lavarello, Repetto, Rogers and Swain."),
    ])


if __name__ == "__main__":
    OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
    main(OUT)
    write_all(OUT)
    print("tristan: written")
