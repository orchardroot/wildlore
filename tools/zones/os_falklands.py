# 3.3 "Overseas", wave 33 agent 2: the Falkland Islands.
#   falklands_stanley (town): Ross Road and the harbour, the Whalebone Arch, Christ Church Cathedral, the Dockyard Museum,
#                             the Globe, the Post Office, Government House, tin roofs, the hulks
#   falklands_camp (route): "Camp" beyond the town: Gypsy Cove, peat banks, tussac, Volunteer Point and a farm at smoko
# Usage: python3 tools/zones/os_falklands.py data/zones
import sys
from os_common import *
from sc_common import creature_npc

TERR = "falklands"
REGION = "overseas_falklands"
WX = {"gale": 26, "drizzle": 20, "clear": 18, "fog": 8, "downpour": 6, "sunshine": 10, "frost": 12}
Q = "q_overseas_falklands_"


def stanley(OUT):
    W, H = 72, 54
    zid = "falklands_stanley"
    z = Z(zid, "Stanley, Falkland Islands", W, H, kind="town", region=REGION, music="town_scotland", weather=WX)
    z.d["stage"] = "coast"; z.d["town_id"] = zid; z.d["scaled_floor"] = FLOOR
    z.legend["k"] = {"tile": "grass", "colour": "#9a9a5a"}                  # pale straw grass
    z.legend["g"] = {"tile": "grass", "colour": "#6e8c4a"}                  # the Cathedral Green
    z.legend["h"] = {"tile": "tall_grass", "colour": "#5a6e3c"}             # tussac
    z.legend["e"] = {"tile": "tall_grass", "colour": "#8a5e3a"}             # diddle-dee heath
    z.legend["a"] = {"tile": "sand", "colour": "#b8a88a"}                   # shingle
    z.legend["c"] = {"tile": "cliff", "colour": "#6a6458", "side": "#54503e"}
    z.rect(0, 0, W, H, "k")
    z.border("R", 2)
    z.rect(0, 0, W, 11, "$"); z.rect(0, 11, W, 1, "w"); z.rect(0, 12, W, 2, "a")
    mound(z, 36, 50, 30, 11, 4, tile="c", floor=4)               # Sapper Hill, behind
    smooth(z)
    blob(z, 12, 44, 9, 4, "h", only="k", seed=2, jitter=0.5)
    blob(z, 58, 44, 9, 4, "e", only="k", seed=3, jitter=0.5)
    blob(z, 36, 40, 8, 3, "e", only="k", seed=4, jitter=0.5)
    blob(z, 20, 34, 6, 3, "h", only="k", seed=5, jitter=0.5)
    # Ross Road along the front, Philomel Street behind, the road out to Camp
    z.rect(2, 14, 68, 2, "=")
    z.rect(2, 26, 68, 2, "=")
    z.rect(34, 26, 2, H - 26, "=")
    z.d["edges"]["south"] = {"to": "falklands_camp", "offset": 0}
    z.rect(34, H - 3, 2, 3, "=")
    # the Cathedral Green and the Whalebone Arch
    z.rect(38, 16, 12, 3, "g")
    z.building(41, 16, 5, 2, "whalebone_arch", "Whalebone Arch", show_label=True)
    # the hulks: Lady Elizabeth, Jhelum, and company, rusting in the harbour
    z.prop("ship_ribs", 14, 8); z.prop("ship_ribs", 52, 6); z.prop("ship_ribs", 24, 4)
    for (bx, by) in [(30, 6), (44, 8), (62, 5)]:
        z.prop("boat", bx, by, variant=1)
    z.prop("bollard", 20, 13); z.prop("bollard", 30, 13); z.prop("bollard", 50, 13); z.prop("lobster_pots", 26, 13)
    # row A (y 19..22): Government House, Post Office, Sanctuary, Shop, the Cathedral, the Museum
    ret_gov = door_to(z, 3, 17, 11, 6, 5, "sa_colonial", "Government House", "falklands_government", 13, 10)
    z.rect(1, 17, 2, 7, "g"); z.rect(3, 23, 11, 1, "g")
    ret_post = door_to(z, 16, 19, 6, 4, 2, "tin_cottage", "Post Office", "falklands_post", 11, 9)
    ret_s, ret_h = town_buildings(z, zid, (23, 19, "sanctuary"), (30, 19, "shop"))
    ret_cath = door_to(z, 40, 19, 7, 4, 3, "chapel", "Christ Church Cathedral", "falklands_cathedral", 13, 10)
    ret_museum = door_to(z, 49, 19, 8, 4, 3, "tin_cottage", "Historic Dockyard Museum", "falklands_museum", 13, 10)
    z.building(59, 19, 7, 4, "tin_cottage", "Ross Road")
    # row B (y 30..33): the Globe Tavern and the tin-roofed streets
    ret_globe = door_to(z, 13, 30, 8, 4, 3, "tin_cottage", "The Globe Tavern", "falklands_globe", 13, 10)
    for (bx, by, w) in [(4, 30, 7), (22, 30, 6), (38, 30, 6), (46, 30, 6), (54, 30, 6), (62, 30, 6)]:
        z.building(bx, by, w, 4, "tin_cottage", "Philomel Street")
    z.building(4, 38, 6, 4, "tin_cottage", "Dairy Paddock")
    z.building(24, 38, 6, 4, "tin_cottage", "Fitzroy Road")
    z.building(44, 38, 6, 4, "tin_cottage", "Davis Street")
    # the Liberation Monument by the waterfront, and Memorial Wood to the east
    z.building(60, 16, 1, 1, "obelisk", "Liberation Monument", show_label=False)
    z.rect(60, 18, 1, 1, "#")
    scatter_props(z, "pine", 52, 36, 16, 8, 14, 31, avoid=("k", "e"))
    # red phone boxes and street furniture
    z.prop("phone_box", 28, 16); z.prop("phone_box", 52, 16)
    z.prop("post_box", 22, 16)
    for (lx, ly) in [(10, 16), (20, 24), (32, 24), (48, 24), (58, 24), (36, 44)]:
        z.prop("lamp_post", lx, ly)
    for (bx, by) in [(40, 24), (47, 17)]:
        z.prop("bench", bx, by)
    scatter_props(z, "rock", 4, 36, 66, 14, 14, 33, avoid=("k",))
    z.d["spawn"] = [35, 24]
    # ---- plaques ----
    plaque(z, 12, 24, "falklands_islands", "The Falkland Islands",
           "Two main islands, East and West Falkland, and hundreds of smaller ones, in the South Atlantic around 500 kilometres off the coast of Patagonia. About 3,600 people live here, and a great many more sheep. The currency is the Falkland pound, at par with sterling.")
    plaque(z, 34, 12, "falklands_stanley", "Stanley",
           "The capital, with about 2,500 people, on a hillside above a long sheltered harbour. It became the capital in 1845, when the governor moved from Port Louis. The islanders call everything outside Stanley 'Camp', from the Spanish 'campo', the countryside. If you have ever heard 'the Camp', that is what is meant.")
    plaque(z, 43, 15, "falklands_whalebone", "The Whalebone Arch",
           "Made from the jawbones of two blue whales, the Whalebone Arch was put up in 1933 to mark a hundred years of British rule in the islands. It stands in front of Christ Church Cathedral. Stanley was once a whaling and sealing port, and the arch is a reminder of what the islands' waters used to hold.")
    plaque(z, 44, 23, "falklands_cathedral", "Christ Church Cathedral",
           "Built of local stone and red brick and completed in 1892, this is the southernmost Anglican cathedral in the world. It is small and plain and loved. Inside are memorials to wrecks and to the sailors lost in them, and in the churchyard a good many Falkland names.")
    plaque(z, 60, 18, "falklands_1982", "1982",
           "In April 1982 Argentine forces invaded the islands, and a British task force sailed 8,000 miles to retake them. After about ten weeks of fighting, Argentine forces surrendered at Stanley on 14 June. 255 British servicemen, 649 Argentine servicemen and three islanders died. The Liberation Monument, unveiled in 1984, lists the names of the British dead.")
    plaque(z, 56, 24, "falklands_referendum", "The 2013 Referendum",
           "In March 2013 the islanders were asked whether they wished the islands to remain a British Overseas Territory. 1,513 votes were in favour and three were against, a result so lopsided that the count was over before the kettle had boiled.")
    plaque(z, 8, 14, "falklands_hulks", "The Hulks",
           "Stanley Harbour is full of old ships. The iron barque Lady Elizabeth, built in 1879, was damaged off Cape Horn in 1913 and ended her days here as a hulk. The Jhelum, a clipper, was condemned here in 1871. They were used for storage, and many are still visible at low tide, rusting quietly.")
    plaque(z, 26, 28, "falklands_tin", "Tin Roofs",
           "Stanley's houses have corrugated iron roofs in bright blues, reds, greens and yellows, a practical choice in a place where wind blows slates off a roof. Many are clad in timber and painted, and the gardens are full of bulbs and wind-stunted trees. The overall effect is of a coastal village drawn by a child with a lot of paint.")
    plaque(z, 38, 25, "falklands_peat", "Peat",
           "For generations most homes in Stanley burned peat, cut by hand from peat banks in the hills in summer and stacked to dry. Peat fires burn slowly and smell wonderful, a little like a distant bonfire. Some houses still burn it, and the smell on a cold dusk is part of the town.")
    plaque(z, 50, 26, "falklands_wool", "Wool",
           "Sheep farming has made a living for the islands since the 1860s, and wool is still a key export. Islanders live and work in settlements in Camp, often many miles from the nearest road. Most of the day-to-day traffic is by Land Rover and light aircraft.")
    # ---- folk ----
    chat(z, "fal_baker", "shopkeeper", 18, 24, "Stanley Baker",
         ["Smoko. That's the word for the break in the morning, about eleven, when you stop everything and have tea and cake. Every farm and every office has it. It's not so much a meal as a state of mind.",
          "If you're going to Camp, take a hamper. People will always have a kettle on, but it would be rude to turn up with nothing. I bake the scones. I won't say how many a day. Scones are an honest industry."], "down", "still")
    chat(z, "fal_pilot", "warden_grunt", 53, 24, "RAF Airman",
         ["RAF Mount Pleasant is about thirty-five miles west of here. The Airbridge from Brize Norton takes about eighteen hours with a stop at Ascension, and I do the lot in a mood.",
          "Stanley's lovely. You come in off the plane and it's like arriving in a very windy village that has been told it's a capital."], "left", "still")
    chat(z, "fal_birder", "birdwatcher", 12, 15, "Birdwatcher",
         ["Gypsy Cove, a few miles east. Magellanic penguins, in burrows, braying like donkeys. You'll hear them before you see them. They stand at the entrance and give you a look.",
          "Jackass penguins, we call them. Because of the noise. It's affectionate. Or it was in my family."], "down", "still")
    chat(z, "fal_wreckwatcher", "fisherman_north", 6, 15, "Old Salt",
         ["That's the Lady Elizabeth, out there. She came in for repairs in 1913 and was never repaired. She is a hulk now, a floating warehouse that stopped floating. I'm told she's the best-preserved old sailing ship in the world, which is not a high bar.",
          "At low tide you can walk to some of them. Don't. The mud has been waiting a long time."], "right", "still")
    chat(z, "fal_kid", "villager_5", 28, 33, "Stanley Kid",
         ["Everyone knows everyone here. I know the Governor's dog, the vicar's cat and the name of every sheep on Dairy Paddock. If someone moves in I know their bus route by the end of the week.",
          "When the weather's bad the whole school stops and we look at the sky. We've a name for each sort of wind. The name for the worst is not in the dictionary."], "up", "wander")
    return_npc(z, zid, 36, 24, "rail_guard", "Airport Rep",
               "The Mount Pleasant bus leaves from here, and takes about an hour and a bit. The plane takes a long time to get home. I can book you on the next flight. It's the Airbridge: one stop, Ascension, and a lot of tea.",
               "Bus is at the kerb. Bring a flask, it's a long way to the Cotswolds.")
    # ---- wild ----
    wild_set(z, [("johnnyrook", 12, {}), ("herdlet", 10, {}), ("warrah", 6, {"time": ["night"]}), ("ternlet", 8, {}), ("hopperlet", 10, {}),
                 ("sodling", 8, {}), ("midgie", 6, {}), ("wispet", 6, {"time": ["night"]}), ("hootlet", 6, {"time": ["night"]}), ("kidgruff", 4, {})])
    wild_set(z, [("pandolph", 14, {}), ("selklet", 10, {}), ("orcalet", 8, {}), ("dolphlet", 10, {}), ("greyhaul", 8, {}), ("pinchkin", 8, {})], "water")
    trainer(z, "fal_airman", "Flight Sergeant Moyes", "RAF Airman", "warden_grunt",
            [("skyharker", 96), ("peregrin", 95), ("stormswift", 96), ("railspark", 96)], 46, 25, "left",
            ["Eighteen hours of seatbelt signs and a bag of peanuts. I am in the mood to be beaten fairly. Care to try?"],
            "Nicely done. I'll buy the first round at the Globe.",
            "RAF Mount Pleasant has been the islands' main airfield since 1985. The long runway, built for the Airbridge, is one of the best the RAF has ever laid.", 5800)
    trainer(z, "fal_wreck", "Hulk Watcher Alec", "Boatman", "fisherman_north",
            [("wispet", 96), ("wishtling", 95), ("shuck", 96), ("kelpie", 96)], 10, 15, "right",
            ["There's a ghost on the Jhelum, they say. I've not seen it myself but the ones who have looked quite unwell. Do you want to see?"],
            "Not even a ghost could beat that.",
            "Old sailors told of ghosts in the harbour hulks, in the tradition of ships' crews everywhere: a cold spot, a smell of tar, and a feeling that someone has just left.", 5700)
    trainer(z, "fal_priest", "Dean of Stanley", "Dean", "choir_singer",
            [("hushwing", 95), ("hobling", 96), ("wistoak", 96), ("kelpie", 96)], 44, 24, "right",
            ["Good afternoon. The Cathedral is open, the tea is hot and I'm just practising my hymns. Would you like a battle? It would be good for my wind."],
            "Very good. The Lord loves a sporting match.",
            "The Dean of the cathedral serves the southernmost cathedral in the world, with a congregation of islanders, sailors and the occasional visiting admiral.", 5600)
    trainer(z, "fal_sheep", "Sheep Shearer Kirsty", "Shearer", "farmer",
            [("herdlet", 96), ("herdwick", 96), ("loaghtan", 95), ("heilan", 96)], 22, 25, "up",
            ["Two hundred sheep a day, one at a time, the old way. Sore back, quick hands. Let's see how fast you shear a battle."],
            "A fast fight. You've the hands for the shed.",
            "A good shearer can shear a sheep in a couple of minutes. Shearing sheds ring with the sound of the clippers all summer.", 5600)
    scaled(["fal_airman", "fal_wreck", "fal_priest", "fal_sheep"])
    finish_zone(z)
    z.save(OUT + "/" + zid + ".json")
    return ret_gov, ret_post, ret_s, ret_h, ret_cath, ret_museum, ret_globe


def camp(OUT):
    W, H = 64, 60
    zid = "falklands_camp"
    z = Z(zid, "Camp: Gypsy Cove and Volunteer Point", W, H, kind="route", region=REGION, music="route_coast", weather=WX)
    z.d["stage"] = "moor"; z.d["scaled_floor"] = FLOOR
    z.legend["k"] = {"tile": "grass", "colour": "#a09a5a"}
    z.legend["h"] = {"tile": "tall_grass", "colour": "#566a3a"}             # tussac
    z.legend["e"] = {"tile": "tall_grass", "colour": "#8a5a3a"}             # diddle-dee
    z.legend["p"] = {"tile": "tall_grass", "colour": "#6a5440"}             # peat
    z.legend["a"] = {"tile": "sand", "colour": "#d4c8a8"}
    z.legend["c"] = {"tile": "cliff", "colour": "#6a6458", "side": "#54503e"}
    z.rect(0, 0, W, H, "k")
    # the east coast: sea, a long white beach (Volunteer Point)
    for y in range(H):
        edge = 52 + (2 if 12 < y < 26 else 0)
        z.rect(edge + 4, y, W - edge - 4, 1, "$"); z.set(edge + 3, y, "w")
        z.rect(edge, y, 3, 1, "a")
    z.border("R", 2)
    mound(z, 14, 12, 11, 8, 3, tile="c", floor=3)
    mound(z, 22, 50, 14, 7, 3)
    smooth(z)
    z.d["edges"]["north"] = {"to": "falklands_stanley", "offset": 0}
    path(z, [(34, 0), (34, 24), (20, 24), (20, 40)], "#", 2)
    path(z, [(34, 24), (46, 24), (46, 14)], "#", 2)
    path(z, [(20, 40), (40, 40), (40, 52)], "#", 2)
    z.rect(34, 0, 2, 3, "#")
    blob(z, 46, 8, 7, 5, "h", only="k", seed=2, jitter=0.5)      # tussac at Volunteer Point
    blob(z, 12, 30, 9, 6, "p", only="k", seed=3, jitter=0.5)      # peat banks
    blob(z, 50, 40, 7, 6, "e", only="k", seed=4, jitter=0.5)
    blob(z, 30, 12, 7, 4, "e", only="k", seed=5, jitter=0.5)
    blob(z, 26, 54, 8, 3, "h", only="k", seed=6, jitter=0.5)
    blob(z, 56, 24, 3, 6, "h", only="ak", seed=7, jitter=0.4)
    # peat stacks and a cutting
    for (sx, sy) in [(8, 28), (11, 33), (16, 29), (7, 36)]:
        z.building(sx, sy, 2, 1, "turf_stack", "Peat Stack", show_label=False)
    # the farm: farmhouse, shearing shed, a paddock fence
    ret_farm = door_to(z, 24, 43, 7, 4, 3, "tin_cottage", "Camp Farmhouse", "falklands_farmhouse", 11, 9)
    z.building(32, 43, 8, 4, "tin_cottage", "Shearing Shed")
    z.rect(23, 48, 18, 1, "F")
    scatter_props(z, "sheep", 10, 42, 12, 10, 6, 31, avoid=("k", "h", "e"))
    scatter_props(z, "rock", 4, 4, 54, 52, 28, 32, avoid=("k",))
    scatter_props(z, "bush", 20, 6, 30, 30, 20, 34, avoid=("e",))
    z.d["spawn"] = [34, 4]
    plaque(z, 36, 3, "falklands_camp", "Camp",
           "From here the land belongs to Camp: moorland, tussac grass, peat banks and sheep farms scattered along the coast. A settlement may have a dozen people and a shop, and the next may be a day's drive of rough track away. In the old days everyone went by horse. Most people go by Land Rover, and by light aircraft.")
    plaque(z, 44, 12, "falklands_gypsy", "Gypsy Cove",
           "The cove east of Stanley where Magellanic penguins burrow in the sandy banks above the beach. They come ashore in September to breed, and bray like donkeys, which is why the islanders call them jackass penguins. The beaches here were mined in 1982, and the last mines were cleared across the islands in 2020.")
    plaque(z, 54, 8, "falklands_volunteer", "Volunteer Point",
           "At the north-east tip of East Falkland is the biggest colony of king penguins in the islands, with gentoo and Magellanic penguins nearby. The kings stand a metre tall, orange-necked, in a crowd that looks like a pub on pay day. The track out here is rough, and worth it.")
    plaque(z, 38, 26, "falklands_wildlife", "Wildlife in Camp",
           "The Falklands have five kinds of penguin, elephant seals, sea lions, and Commerson's dolphins that play in the surf. The islands are home to birds seen almost nowhere else, such as the striated caracara, called Johnny rook, which will investigate your sandwiches, your rucksack and the rest of your day.")
    plaque(z, 14, 26, "falklands_peat_banks", "The Peat Banks",
           "Peat cutters work in summer, slicing blocks from the bank with a special spade. The blocks dry in stacks, then go to the house by trailer. A season's fuel for one home is hundreds of blocks. It is hard and wet work, and the best part of the day is the tea.")
    plaque(z, 56, 20, "falklands_tussac", "Tussac Grass",
           "Tussac grass grows in huge clumps up to two metres tall along the coast, and once covered most of the islands' shores. Sheep and fires ate much of it. It shelters seabirds, seals and penguins. Wherever it is left, so is the wildlife that depends on it.")
    plaque(z, 30, 50, "falklands_warrah", "The Warrah",
           "The Falkland Islands wolf, or warrah, was the islands' only native land mammal, a fox-like animal with a white tail tip. Charles Darwin saw one in 1833 and noted that it was tame and curious. It was hunted and poisoned, and the last was killed in about 1876. It is one of very few canids known to have gone extinct in historic times.")
    plaque(z, 22, 36, "falklands_diddle", "Diddle-Dee",
           "Diddle-dee is a low red-berried heath that covers the hillsides of the islands, turning the Camp a rusty brown in autumn. The berries are made into jam, pies and a sort of cordial, and are one of the Falkland tastes.")
    # ---- folk ----
    chat(z, "fal_peatcutter", "farmer", 12, 31, "Peat Cutter",
         ["Cut, stack, dry, carry. We do it every summer and the weather gives us about four good days. The rest is fog, and the smell of the bank, which is a rich, dark smell, and it gets in your hair.",
          "Smoko's the best part. Tea, scones, and sitting on a peat stack with my feet up. If you've a flask for a tired man, I'll be your friend for life."], "down", "still")
    chat(z, "fal_penguinwarden", "birdwatcher", 52, 14, "Penguin Warden",
         ["A king penguin takes over a year to raise one chick, so there are always chicks. A fluffy brown ball, which people call an 'oakum boy', after the brown fibre used to caulk ships.",
          "Keep two metres back, don't block the way to the sea, and nobody gets pecked."], "left", "still")
    chat(z, "fal_pilot_camp", "hiker", 40, 28, "Land Rover Driver",
         ["The road's a track and the track's a bog. If you're stuck in Camp, the rule is you sit tight and wait for a passer-by, and there will be one before dark. Everyone will stop and everyone will have a flask.",
          "Bring a flask, a spare tyre and a sense of humour, and in that order."], "down", "still")
    chat(z, "fal_johnny_kid", "villager_5", 28, 41, "Farm Kid",
         ["A Johnny rook took my sandwich and I'd got halfway through telling it off when it took the other half. Johnny rooks are clever. They'll follow your Land Rover and open the door if you let them.",
          "Darwin said they were so bold they'd peck the kettle off the fire. I'd say that's about right."], "up", "wander")
    wild_set(z, [("johnnyrook", 14, {}), ("hopperlet", 12, {}), ("warrah", 6, {"time": ["night"]}), ("herdlet", 10, {}), ("sodling", 10, {}), ("peatling", 8, {}),
                 ("sphagnet", 8, {}), ("turfclamp", 8, {}), ("ternlet", 8, {}), ("wispet", 6, {"time": ["night"]}), ("midgie", 8, {})])
    wild_set(z, [("pandolph", 14, {}), ("selklet", 10, {}), ("orcalet", 8, {}), ("greyhaul", 10, {}), ("dolphlet", 10, {}), ("puffling", 8, {})], "water")
    # penguin colony: a few rockhoppers standing about on the beach
    for i, (px, py) in enumerate([(50, 18), (52, 20), (51, 22), (50, 16)]):
        creature_npc(z, "fal_penguin%d" % i, "hopperlet", px, py, "A penguin stands quite still, looks you up and down, and goes back to what it was doing, which is nothing at all, but with great purpose.", move="still")
    trainer(z, "fal_peat_t", "Peat Cutter Hamish", "Peat Cutter", "farmer",
            [("sodling", 96), ("turfmere", 96), ("peatling", 95), ("peatmonarch", 96)], 18, 27, "right",
            ["Three hundred blocks a day, if the weather's kind. You'll excuse me if I swing a bit hard."],
            "I've been knocked flatter by a good gale. Well done.",
            "Peat takes thousands of years to form, and the banks the islanders cut have been growing since the last ice age. The cuttings are small and the islands are careful.", 5600)
    trainer(z, "fal_shepherd", "Shepherd Rhona", "Shepherd", "ghillie",
            [("herdlet", 95), ("herdwick", 96), ("tormane", 96), ("cusith", 96)], 28, 38, "right",
            ["My dogs do the hard work. I just stand about looking wise. Right, I'll do the same here."],
            "They've beaten me fair. The dogs agree.",
            "Sheepdogs on the Falklands are trained to work huge, empty hillsides. A good dog can bring in a flock from miles off at a single whistle.", 5600)
    trainer(z, "fal_penguin_t", "Penguin Warden Sue", "Warden", "birdwatcher",
            [("rockhopper", 96), ("hopperlet", 96), ("polartern", 96), ("pandolph", 96)], 48, 16, "down",
            ["Kings, gentoos, rockhoppers, Magellanics. The island has five kinds of penguin, and I have had a talking-to from all of them."],
            "A fine bit of fieldcraft. The penguins will talk.",
            "Penguins in the Falklands have faced changes in fish stocks and weather, and the islands' wardens and visitors count the nests every year.", 5700)
    trainer(z, "fal_legend", "Camp Manager Fergus", "Camp Manager", "ghillie",
            [("warrah", 97), ("johnnyrook", 97), ("pandolph", 97), ("rockhopper", 97), ("heilan", 96), ("peatmonarch", 97)], 31, 50, "down",
            ["I run six thousand acres, ten thousand sheep and a Land Rover I wouldn't give a dog. It's a lot of work, and I'll take a break from it for a battle."],
            "Right. The best fight I've had at smoko. Come in and have a scone.",
            "A Camp farm can cover tens of thousands of acres, with sheep outnumbering everything and a neighbour a long way off. People look out for each other, because they have to.", 9500)
    for n in z.d["npcs"]:
        if n["id"] == "fal_legend":
            del n["trainer"]; n["script"] = "fal_legend_talk"; n["name"] = "Camp Manager Fergus"
    scaled(["fal_peat_t", "fal_shepherd", "fal_penguin_t", "fal_legend"])
    finish_zone(z)
    z.save(OUT + "/" + zid + ".json")
    return ret_farm


def interiors(OUT, ret_gov, ret_post, ret_cath, ret_museum, ret_globe, ret_farm):
    zid = "falklands_stanley"
    interior(OUT, "falklands_government", "Government House", zid, ret_gov, "hall",
             [npc("fal_aide", "gown_student", 6, 3, "fal_aide", name="Governor's Aide")])
    script("falklands_government", "fal_aide", say("Governor's Aide",
           "Government House has been the Governor's home since the 1840s, and its garden is the only place in the islands with a proper lawn, a greenhouse and trees that don't lean. The Governor represents the King, and the islands have their own elected Legislative Assembly.",
           "Everyone in Stanley knows everyone else, and a good deal of government is done over a fence, and a cup of tea. It works rather better than you'd expect."))
    interior(OUT, "falklands_post", "Post Office and Philatelic Bureau", zid, ret_post, "cafe",
             [npc("fal_postmaster", "shopkeeper", 3, 1, "fal_postmaster", name="Postmaster")], w=11, h=9,
             signs=[(8, 3, "FALKLAND ISLANDS STAMPS. Penguins, ships and wildlife, sold to collectors on every continent.")])
    script("falklands_post", "fal_postmaster", say("Postmaster",
           "The Falklands have issued their own stamps since 1878, and wildlife is the favourite subject: penguins, albatrosses, sea lions, wild flowers. The Philatelic Bureau sells to collectors around the world, and the money helps pay for the islands' roads and schools.",
           "A card from here usually takes a week or two to reach Britain by the Airbridge. It has a very long route. It is quite worth it for the stamp."))
    interior(OUT, "falklands_cathedral", "Christ Church Cathedral", zid, ret_cath, "church",
             [npc("fal_verger", "choir_singer", 6, 2, "fal_verger", name="Verger")])
    script("falklands_cathedral", "fal_verger", say("Verger",
           "Christ Church Cathedral. Plain, a bit damp and rather loved. The memorials on the wall are to sailors lost at sea, and to the men who died in the 1982 conflict.",
           "The arch outside is made of two whale jawbones. It's a reminder of the whaling years. Nobody here would choose it now, but nobody would move it either."))
    interior(OUT, "falklands_museum", "Historic Dockyard Museum", zid, ret_museum, "museum",
             [npc("fal_museum_curator", "gown_student", 6, 3, "fal_museum_curator", name="Curator"),
              npc("fal_museum_guide", "tour_guide", 9, 5, "fal_museum_guide", name="Guide", facing="left")],
             signs=[(3, 6, "THE WARRAH. Darwin's fox-wolf, the islands' only native land mammal. No live one has been seen since the 1870s.")])
    script("falklands_museum", "fal_museum_curator", say("Curator",
           "The Museum tells the whole story of the islands: the early sealers and whalers, the gauchos from the Pampas, the sheep farms, the wrecks and the war. There's even a section on peat, and a little dress made from Falkland wool.",
           "My favourite things are the old ships' bells, and the photographs of the harbour when it was full of masts."))
    script("falklands_museum", "fal_museum_guide", say("Guide",
           "In 1982 the whole of Stanley was under occupation for ten weeks. The museum has stories from islanders: the curfew, the blackouts, the friendly soldiers and the not-so-friendly ones. Most of what we know is from people who were children.",
           "Most of what we know comes from people who were children then, and who tell it better than any book."))
    interior(OUT, "falklands_globe", "The Globe Tavern", zid, ret_globe, "cafe",
             [npc("fal_landlord", "villager_2", 3, 1, "fal_landlord", name="Landlord"),
              npc("fal_regular", "fisherman_north", 9, 3, "fal_regular", name="Regular", facing="left")],
             props=[("fireplace", 6, 1, {"walk": True})])
    script("falklands_globe", "fal_landlord", say("Landlord",
           "Welcome to the Globe, the best pub in the best town in the South Atlantic, which is a short list. Quiz night is Thursday, and the Navy always loses.") +
           [{"do": "quiz", "pub": "falklands_globe", "region": "overseas", "who": "Landlord"}])
    script("falklands_globe", "fal_regular", say("Regular",
           "In the 1850s Stanley was the place to refit before Cape Horn, and the pubs were full of sailors who had just been round it. I'm told some had a faraway look. I'm told the same of anyone who has just been to Camp.",
           "If you want to be an islander, learn to say 'smoko' and learn to stand up for the weather. Everything else comes with time."))
    zid = "falklands_camp"
    interior(OUT, "falklands_farmhouse", "Camp Farmhouse", zid, ret_farm, "home",
             [npc("fal_farmwife", "villager_6", 4, 3, "fal_farmwife", name="Farmer's Wife")], w=11, h=9)
    script("falklands_farmhouse", "fal_farmwife", say("Farmer's Wife",
           "Come in, come in, kettle's on. Smoko is at eleven and four. Scones, tea, diddle-dee jam, and if the men are in, a plate of something with mince.",
           "The old Camp houses were built of peat blocks and corrugated iron, with one big stove in the kitchen that heated the whole house. We still have the stove. It never goes out. I haven't the nerve to find out what happens if it does."))


def quest_data(OUT):
    z = "falklands_stanley"
    DLG[z]["fal_baker"] = [cmd_if(Q + "done",
        say("Stanley Baker", "I heard you took the hamper to the peat bank and fought the Camp Manager himself! I don't believe a word of it, but it's a good story, and I'll say so at the Globe."),
        [cmd_if(Q + "started",
                say("Stanley Baker", "Hamper's with you, I think? Take it out to Camp, to the peat cutters at the banks, west of the track. Then find the farm. And show the Camp Manager a Johnny Rook if you can catch one. It'll make his day."),
                say("Stanley Baker", "Smoko. That's the word for the break in the morning, about eleven, when you stop everything and have tea and cake. If you are going to Camp, take a hamper. Would you take one to the peat cutters? I'll never get there with the shop to mind.") +
                [give("smoko_hamper"), setf(Q + "started")])])]
    DLG["falklands_camp"]["fal_peatcutter"] = [cmd_if(Q + "1",
        say("Peat Cutter", "Cut, stack, dry, carry. And never miss smoko."),
        [cmd_if(Q + "started",
                say("Peat Cutter", "A hamper! From the baker. That's a fine thing to see on the bank. Tea, scones, and diddle-dee jam. I'll say a good word for you. Go on to the farm, and show the Camp Manager what you've got.") + [setf(Q + "1")],
                say("Peat Cutter", "Cut, stack, dry, carry. We do it every summer and the weather gives us about four good days. The rest is fog. Smoko's the best part, and I'd be grateful for a flask."))])]
    DLG["falklands_camp"]["fal_legend_talk"] = [cmd_if(Q + "done",
        say("Camp Manager Fergus", "You're welcome at any farm in Camp. And the scones. And the dog."),
        [cmd_if(Q + "1",
                [when("has_johnnyrook",
                      say("Camp Manager Fergus", "A Johnny Rook in your Fieldbook! They've had my sandwiches for years. Right. If you can look after that, you can look after yourself. One friendly fight, and then smoko.") + [setf(Q + "2"), battle("fal_legend")] +
                      say("Camp Manager Fergus", "That was a belter. Come in, have tea, have a scone, and take this: a pebble from the gentoos' nest, and a pot of diddle-dee jam. The jam's the better gift.") +
                      [give("gentoo_pebble"), give("diddle_dee_jam", 3)] + standing(3) + [setf(Q + "done")],
                      say("Camp Manager Fergus", "Come back with a Johnny Rook. There are plenty about, and they'll find you, the minute your sandwich is out."))],
                say("Camp Manager Fergus", "Morning. I'm the manager here. If the baker sent you with a hamper, take it to the peat cutters first. They are west of the track."))])]
    quests = [{"id": "falklands_smoko", "title": "Smoko", "region": "overseas_falklands", "town": "falklands_stanley", "giver": "Stanley Baker",
               "summary": "Carry the baker's smoko hamper out to Camp, show the manager a Johnny Rook, and win a friendly fight.",
               "start_flag": Q + "started",
               "steps": [{"flag": Q + "1", "text": "Take the smoko hamper to the peat cutters in Camp.", "zone": "falklands_camp"},
                         {"flag": Q + "2", "text": "Show the Camp Manager a Johnny Rook.", "zone": "falklands_camp"},
                         {"flag": Q + "done", "text": "Beat the Camp Manager in a friendly smoko fight.", "zone": "falklands_camp"}],
               "done_flag": Q + "done", "reward": "The Gentoo Pebble (a Frost charm), three jars of Diddle-Dee Jam and standing in the Overseas Territories."}]
    write_quests(TERR, quests)


def items_and_registry():
    return [heal_item("diddle_dee_jam", "Diddle-Dee Jam", 300, 120, "Jam from diddle-dee berries, the little red heath fruit that colours the Falkland hills. Tart and sweet, spread on a warm scone at smoko. Restores 120 HP."),
            heal_item("smoko_scone", "Smoko Scone", 260, 110, "A warm scone with butter, the centrepiece of smoko, the mid-morning tea break that stops every Falkland farm and office at eleven. Restores 110 HP."),
            key_item("smoko_hamper", "Smoko Hamper", "A wicker hamper of tea, scones and diddle-dee jam, packed by the Stanley baker for the peat cutters out in Camp. It is a very good hamper and a very long walk."),
            charm_item("gentoo_pebble", "Gentoo Pebble", "A smooth pebble of the sort a gentoo penguin gives to its mate. A nest is a heap of stones, and a good pebble is a courtship gift. This one is a keepsake from the Falklands.",
                       "Frost moves hit 20% harder.", {"effect": "boost", "type": "frost", "mult": 1.2}, "{name}'s Gentoo Pebble gleamed in the cold!")]


def main(OUT):
    ret_gov, ret_post, ret_s, ret_h, ret_cath, ret_museum, ret_globe = stanley(OUT)
    ret_farm = camp(OUT)
    interiors(OUT, ret_gov, ret_post, ret_cath, ret_museum, ret_globe, ret_farm)
    sanctuary_and_shop(OUT, "falklands_stanley", "Stanley", ret_s, ret_h,
        ["Morning! King Edward Memorial Hospital sends its regards, and so does the Sanctuary. Sit your team on the counter, and I'll put the kettle on. Tea first, everything else after.",
         "A cup of tea, a scone and a view of the harbour. The wind will sort the rest.",
         "All better. They're tougher than a penguin in a gale.",
         "The Ark's in the corner, next to the peat fire. It smells wonderful.",
         "No bother. Wrap up warm."],
        ("Hello! Scones, diddle-dee jam, and everything else that came on the ship. It's all a bit pricey, because of the distance, but it's all good.", "Mind the wind. It takes hats."),
        ["cup_of_tea", "flask_of_tea", "smelling_salts", "wicker_snare", "iron_snare", "water_snare", "night_snare", "diddle_dee_jam", "smoko_scone"])
    quest_data(OUT)
    write_items("overseas_falklands", items_and_registry())
    write_registry("falklands", "Falkland Islands", "falklands_stanley", 35, 24, "raf",
                   "Penguins, peat, tin roofs and a very long way from Brize Norton.",
                   "The Voyager makes the long run south from Ascension and drops through low cloud over Mount Pleasant. The pilot says: Welcome to the Falklands. Please keep your hats on. The wind has plans.")
    append_quiz("overseas", [
        ("geography", "What do Falkland Islanders call the countryside beyond Stanley?", "Camp", ["The Bush", "The Moor", "The Outback"], "From the Spanish 'campo', the countryside."),
        ("culture", "What is 'smoko' in the Falkland Islands?", "A mid-morning tea break", ["A kind of fish", "A peat fire", "A ship's bell"], "Farms and offices stop for tea and cake at about eleven."),
        ("creatures", "Which bird of prey is nicknamed the Johnny rook?", "The striated caracara", ["The kestrel", "The golden eagle", "The osprey"], "It is bold, curious and known for investigating visitors' bags."),
        ("history", "What was made from blue whale jawbones in Stanley in 1933?", "The Whalebone Arch", ["A bridge", "A bandstand", "A lighthouse"], "It marks a hundred years of British rule."),
        ("history", "In which year did the Falkland Islands vote in a referendum to remain British?", "2013", ["1982", "1995", "2020"], "1,513 voted yes and three voted no."),
    ])


if __name__ == "__main__":
    OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
    main(OUT)
    write_all(OUT)
    print("falklands: written")
