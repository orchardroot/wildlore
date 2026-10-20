# 3.3 "Overseas", wave 33 agent 2: Ascension Island (a British Overseas Territory in the South Atlantic).
#   ascension (town): Georgetown on the west coast, the Turtle Ponds, Fort Hayes, St Mary's, the Exiles Club, black cinder
#   ascension_green_mountain (route): the cloud forest, Dampier's Drip, the Farm, bamboo and the Red Lion
# Usage: python3 tools/zones/os_ascension.py data/zones   (zones, interiors, dialogue, trainers, quests, items, registry)
import sys
from os_common import *

TERR = "ascension"
REGION = "overseas_ascension"
WX = {"clear": 30, "sunshine": 28, "drizzle": 10, "fog": 6, "gale": 14, "downpour": 4}
WX_MOUNTAIN = {"fog": 38, "drizzle": 24, "clear": 12, "downpour": 10, "gale": 10, "sunshine": 6}


def cinder_legend(z):
    z.legend["k"] = {"tile": "sand", "colour": "#7a5444"}                 # red-brown cinder
    z.legend["a"] = {"tile": "sand", "colour": "#3f3634"}                 # black volcanic sand
    z.legend["j"] = {"tile": "rock", "colour": "#2c2628"}                 # lava
    z.legend["h"] = {"tile": "tall_grass", "colour": "#a08a56"}           # dry scrub, where the wild things live
    z.legend["g"] = {"tile": "grass", "colour": "#9a8c58"}


def ascension(OUT):
    W, H = 64, 52
    zid = "ascension"
    z = Z(zid, "Georgetown, Ascension", W, H, kind="town", region=REGION, music="town_cornwall", weather=WX)
    z.d["stage"] = "coast"; z.d["town_id"] = zid; z.d["scaled_floor"] = FLOOR
    cinder_legend(z)
    z.rect(0, 0, W, H, "k")
    # the sea along the west, a black beach, cinder cones and lava inland
    for y in range(H):
        edge = 8 + (2 if (y // 6) % 2 else 0)
        z.rect(0, y, edge - 1, 1, "$"); z.set(edge - 1, y, "w")
        z.rect(edge, y, 3, 1, "a")
    z.border("j", 2, gaps=[(0, 0, 0, 0)])
    z.rect(0, 0, 2, H, "$")
    mound(z, 50, 8, 11, 8, 4, tile="j", floor=3)      # Sisters Peak, to the north-east
    mound(z, 58, 40, 8, 9, 4, tile="j", floor=3)
    mound(z, 30, 47, 10, 4, 2)
    smooth(z)
    # scrub in the south and the north, where the wild things are
    blob(z, 24, 44, 11, 5, "h", only="k", seed=3, jitter=0.5)
    blob(z, 42, 46, 8, 4, "h", only="k", seed=4, jitter=0.5)
    blob(z, 16, 6, 8, 3, "h", only="k", seed=5, jitter=0.5)
    blob(z, 34, 4, 7, 2, "h", only="k", seed=6, jitter=0.5)
    # Georgetown's streets
    z.rect(11, 23, 46, 2, "=")                       # Georgetown Road
    z.rect(34, 0, 2, 50, "=")                        # the road to Green Mountain and the airfield
    z.d["edges"]["north"] = {"to": "ascension_green_mountain", "offset": -6}
    z.rect(11, 12, 2, 12, "#"); z.rect(11, 12, 24, 1, "#")
    # buildings, north side
    ret_fort = door_to(z, 15, 14, 10, 5, 4, "castle", "Fort Hayes", "ascension_fort", 13, 10)
    ret_church = door_to(z, 26, 15, 6, 4, 3, "chapel", "St Mary's Church", "ascension_church", 13, 10)
    ret_s, ret_h = town_buildings(z, zid, (38, 15, "sanctuary"), (45, 15, "shop"))
    ret_post = door_to(z, 51, 15, 6, 4, 2, "sa_colonial", "Post Office and Philatelic Bureau", "ascension_post", 11, 9)
    # south side
    ret_club = door_to(z, 15, 27, 8, 4, 3, "sa_colonial", "The Exiles Club", "ascension_club", 13, 10)
    z.building(38, 27, 6, 4, "sa_colonial", "Two Boats Village")
    z.building(45, 27, 6, 4, "sa_colonial", "Garrison Quarters")
    z.building(52, 27, 6, 4, "sa_colonial", "Garrison Quarters")
    # the Turtle Ponds, a pair of walled pools by the sea wall
    for (px, py) in [(24, 27), (24, 31)]:
        z.rect(px, py, 8, 3, "W"); z.rect(px + 1, py + 1, 6, 1, "~")
    # the radome and the aerials at the north end, no door
    z.building(42, 5, 7, 5, "radome", "Atlantic Relay", show_label=False)
    z.building(52, 6, 6, 4, "radome", "Radome", show_label=False)
    # the wharf: Clarence Bay's pier and boats
    z.rect(11, 38, 6, 2, "#")
    z.building(5, 37, 5, 3, "pier", "Pier", show_label=False)
    for (bx, by) in [(3, 34), (4, 42), (5, 28)]:
        z.prop("boat", bx, by, variant=1)
    z.prop("buoy", 6, 40); z.prop("bollard", 10, 38); z.prop("bollard", 15, 38)
    z.prop("lobster_pots", 12, 37)
    for (lx, ly) in [(20, 22), (30, 22), (40, 22), (50, 22), (34, 30)]:
        z.prop("lamp_post", lx, ly)
    for (bx, by) in [(21, 25), (47, 25)]:
        z.prop("bench", bx, by)
    scatter_props(z, "rock", 12, 3, 50, 46, 30, 21, avoid=("k",))
    z.d["spawn"] = [35, 25]
    # ---- plaques ----
    plaque(z, 36, 23, "ascension_name", "Ascension Island",
           "A speck of volcanic rock in the middle of the South Atlantic, about 1,500 kilometres from the coast of Africa and 2,250 from Brazil. It is named for the day it was first sighted by Europeans, Ascension Day, in 1501. Nobody lived here until the Royal Navy arrived in 1815.")
    plaque(z, 20, 20, "ascension_hms", "HMS Ascension",
           "In 1815, with Napoleon sent to St Helena, the Royal Navy occupied Ascension so that no one could use it to rescue him. It was run as a ship, the stone frigate HMS Ascension, with a captain, a crew and no ship. Sailors were paid the same as at sea, and the island has kept a naval air ever since.")
    plaque(z, 27, 21, "ascension_stmarys", "St Mary's Church",
           "Built in 1843, St Mary's was the Royal Marines' church, and it still has the garrison's plain good sense. The graveyard holds sailors and marines from stations all over the Atlantic. Ascension did not become a place for families to live until the twentieth century, so most of the early stones are for men.")
    plaque(z, 25, 26, "ascension_turtles", "The Turtle Ponds",
           "The ponds were built by the Navy in the 1820s. Green turtles caught on the beaches were kept alive in them until a ship needed fresh meat, or a turtle soup supper for Admiralty gentlemen. Today the turtles are protected, and the beaches are watched over by conservation staff who tag each female.")
    plaque(z, 44, 12, "ascension_wideawake", "Wideawake Airfield",
           "In 1942 the Americans built an airstrip here in about three months, to ferry bombers across the Atlantic. It is named for the wideawake fair, the sooty terns that once nested on the plain in hundreds of thousands. In 1982 Ascension became the staging post for the Falklands task force, and for a few weeks it was one of the busiest airfields in the world.")
    plaque(z, 53, 13, "ascension_cable", "A Wired Island",
           "Ascension has been a communications island since 1899, when the undersea telegraph cable arrived. Today it hosts a BBC relay, an American space tracking station and a joint RAF and US airfield. The big white domes are radomes: weatherproof covers over antennas, which look exactly like golf balls.")
    plaque(z, 18, 25, "ascension_exiles", "The Exiles Club",
           "The island's social club, named for the fact that nobody here is quite at home. Ascension has no indigenous population and no right of abode: everyone on the island is working here, from Saint Helenian staff to RAF and American personnel and contractors. The Exiles is where all of them go on a Friday.")
    plaque(z, 38, 25, "ascension_two_boats", "Two Boats Village",
           "A small settlement named for the two boats that once stood on the roadside here, with a concrete decorative flower bed made of two upturned lifeboat hulls. The houses belong to Saint Helenian staff, who have long made up much of the island's workforce, and who do most of the actual running of it.")
    plaque(z, 46, 24, "ascension_garrison", "The Garrison",
           "The Royal Marines garrisoned Ascension until 1922, when the Eastern Telegraph Company took over. Marines built a great deal here by hand: roads, water tanks, a sea wall, and the walled farm up Green Mountain that fed the whole garrison. Their hardest enemy was not the French but the water shortage.")
    plaque(z, 20, 41, "ascension_cinders", "Cinder Cones",
           "Ascension is the tip of an enormous volcano on the Mid-Atlantic Ridge, with about forty cinder cones and lava flows, and the youngest of them is probably only a few hundred years old. The ground is red, black and rust-brown cinder. Nothing much grows here unless somebody plants it.")
    # ---- folk ----
    chat(z, "asc_ranger", "hiker", 28, 24, "Conservation Officer",
         ["Green turtles come ashore on Long Beach at night, mostly between December and May. We count the tracks in the morning. The females come back to nest every two to five years, and they only nest here because they hatched here, we think. Thirty years later.",
          "Please keep the lights low and the dogs at home. A hatchling follows the brightest thing, and it should be the moon on the sea, not your torch."], "down", "still")
    chat(z, "asc_saint", "villager_4", 33, 28, "Saint Helenian Cook",
         ["I'm from St Helena. Plenty of us work here: it's a short flight and a long way home. I make a fish pie on a Friday, from wahoo, and I'll not be told it's too much.",
          "Everyone talks about the airfield and the turtles. Nobody mentions the goats. Ascension has goats. Ascension had goats before it had people. The goats do not read the plaques."], "right", "still")
    chat(z, "asc_marine", "sailor", 47, 24, "Royal Marine",
         ["The Marines built this place. Not the glamorous bits, the tanks and the wall and the lanes. We still get the job of looking at the plans and saying 'who thought of that?'",
          "There's a legend that we're not meant to say the island's name aloud on a Sunday. There isn't. But the legend doesn't mind."], "left", "still")
    chat(z, "asc_birder", "birdwatcher", 12, 40, "Birdwatcher",
         ["Ascension frigatebirds nest only on Boatswain Bird Island, a rock just offshore. They used to be nearly lost, because of rats and cats. The cats are gone now, and the frigatebirds are coming back.",
          "They steal food from the boobies in the air. The boobies, on the whole, are too polite to mind."], "up", "still")
    chat(z, "asc_goatkid", "villager_5", 40, 32, "Two Boats Kid",
         ["I've a pet donkey. Well, a wild donkey, but he lets me stand near him. Ascension has donkeys because they came for work and stayed.",
          "There's a place called the Devil's Riding School, a crater with a flat bottom, where it's said the devil practised his horse riding. I can't see why anyone needs a school for that."], "down", "wander")
    return_npc(z, zid, 36, 44, "rail_guard", "Movements Officer",
               "RAF Ascension, Wideawake. The Airbridge goes south to the Falklands and north to Brize Norton, and in between I decide whether there's room for you and your creatures. There is.",
               "Boarding now. Mind the step, and the goats.")
    # ---- environment details ----
    z.sign(33, 44, "WIDEAWAKE AIRFIELD. The South Atlantic Airbridge: Brize Norton, Ascension, Mount Pleasant. A long way for a cup of tea.")
    z.sign(35, 6, "NORTH: the road to Green Mountain, the Farm and Dampier's Drip.")
    # ---- trainers ----
    wild_set(z, [("cindershell", 14, {}), ("gannetling", 10, {}), ("ternlet", 10, {}), ("kidgruff", 10, {}), ("duneskink", 12, {}),
                 ("petrelash", 8, {"weather": ["gale"]}), ("beaconet", 8, {}), ("foalmoor", 8, {}), ("hootlet", 6, {"time": ["night"]})])
    wild_set(z, [("cindershell", 14, {}), ("plungebeak", 10, {}), ("clownbill", 10, {}), ("dolphlet", 10, {}), ("greyhaul", 8, {})], "water")
    trainer(z, "asc_ranger_t", "Ranger Naomi", "Conservation Officer", "hiker",
            [("cindershell", 95), ("gannetling", 95), ("duneskink", 96), ("ternlet", 96)], 18, 44, "up",
            ["Tag, count, release. That's my job, and it is also how I'd describe this battle."],
            "Good fight. I'll put you in the notebook under 'considerate'.",
            "A tagged turtle can be followed for decades. Ascension's nesting turtles are one of the largest colonies in the Atlantic, and the numbers are climbing.", 5600)
    trainer(z, "asc_airman", "Airman Brooks", "Airman", "warden_grunt",
            [("skyharker", 96), ("railspark", 95), ("beaconet", 95), ("stormswift", 96)], 38, 48, "up",
            ["Eighteen hours in a Voyager to get here, and I've a day off. Let's see what you have."],
            "Fair enough. I'll put the kettle on in the mess.",
            "The Airbridge flies to the Falklands from here twice a week in good weather, and is the reason any of this island is on a map.", 5800)
    trainer(z, "asc_diver", "Diver Seb", "Diver", "angler",
            [("greyhaul", 95), ("dolphlet", 96), ("plungebeak", 96), ("orcalet", 96)], 11, 33, "left",
            ["I dive on the wrecks off Georgetown. Visibility is thirty metres, the water's twenty-six degrees, and the sharks are polite."],
            "Well dived. Hold your breath for the next one.",
            "Ascension's waters are some of the clearest in the Atlantic, with blue marlin, yellowfin tuna, wahoo and a fair few galapagos sharks.", 5600)
    trainer(z, "asc_marine_t", "Corporal Pike", "Royal Marine", "sailor",
            [("legionette", 95), ("shieldbiter", 96), ("ironwatch", 96), ("causewarden", 96)], 24, 22, "right",
            ["We built the roads here with spades and a lot of sarcasm. Fall in."],
            "Well done. Stand easy.",
            "The first Marines to garrison Ascension in 1815 found a bare island and no water but a trickle. They were expected to make a settlement from it.", 5700)
    trainer(z, "asc_goatherd", "Goatherd Dan", "Goatherd", "farmer",
            [("billgruff", 96), ("kidgruff", 95), ("tormane", 96), ("peregrin", 95)], 52, 34, "left",
            ["They aren't mine. They aren't anyone's. I'm just the one who keeps counting them."],
            "That's a lot of kicks. Fine. The goats will talk.",
            "Feral goats were put on Ascension in the 1500s by Portuguese sailors, to feed passing ships. They ate the island to its bones. For three hundred years it had no trees.", 5500)
    trainer(z, "asc_legend", "Wideawake Warden Cass", "Island Warden", "explorer",
            [("ashmantle", 97), ("gannetling", 96), ("kitelet", 96), ("polartern", 97), ("ironwatch", 96), ("petrelash", 97)], 56, 22, "left",
            ["I've watched the wideawake fair come back to this island, one colony at a time, and I've been standing here ever since. You'll want to impress me."],
            "Well. That's a good fight. The terns would be proud, and they are never proud.",
            "Wideawake terns spend years at sea after fledging and then come back to nest on Ascension. They never stop calling, which is where the name comes from.", 9500)
    scaled(["asc_ranger_t", "asc_airman", "asc_diver", "asc_marine_t", "asc_goatherd", "asc_legend"])
    for n in z.d["npcs"]:
        if n["id"] == "asc_legend":
            del n["trainer"]; n["script"] = "asc_legend_talk"; n["name"] = "Wideawake Warden"
    finish_zone(z)
    z.save(OUT + "/" + zid + ".json")
    return ret_fort, ret_church, ret_s, ret_h, ret_post, ret_club


def green_mountain(OUT):
    W, H = 56, 60
    zid = "ascension_green_mountain"
    z = Z(zid, "Green Mountain", W, H, kind="route", region=REGION, music="route_forest", weather=WX_MOUNTAIN)
    z.d["stage"] = "forest"; z.d["scaled_floor"] = FLOOR
    z.legend["k"] = {"tile": "grass", "colour": "#4a7a3e"}
    z.legend["h"] = {"tile": "tall_grass", "colour": "#2f6a38"}
    z.legend["g"] = {"tile": "grass", "colour": "#5e9248"}
    z.legend["a"] = {"tile": "sand", "colour": "#6a4a3c"}
    z.legend["j"] = {"tile": "rock", "colour": "#3a3236"}
    z.rect(0, 0, W, H, "k")
    z.border("T", 2)
    mound(z, 28, 18, 18, 14, 5)
    mound(z, 30, 40, 14, 10, 3)
    smooth(z)
    # cinder paths up the mountain, a cloud forest of bamboo and fern
    z.d["edges"]["south"] = {"to": "ascension", "offset": 6}
    path(z, [(28, 59), (28, 36), (18, 36), (18, 24), (30, 24), (30, 10)], "a", 2)
    path(z, [(30, 36), (44, 36), (44, 28)], "a", 2)
    blob(z, 14, 12, 9, 6, "h", only="kg", seed=2, jitter=0.4)
    blob(z, 40, 14, 9, 7, "h", only="kg", seed=3, jitter=0.4)
    blob(z, 12, 40, 8, 8, "h", only="kg", seed=4, jitter=0.4)
    blob(z, 40, 46, 9, 7, "h", only="kg", seed=5, jitter=0.4)
    blob(z, 28, 18, 5, 4, "g", only="kh", seed=6, jitter=0.3)
    # Dampier's Drip: a spring and a pool
    blob(z, 22, 8, 3, 2, "~", only="kgh", seed=7, jitter=0.2)
    blob(z, 22, 8, 4, 3, "w", only="kgh", seed=8, jitter=0.2)
    scatter_props(z, "bush", 3, 3, 50, 54, 70, 31, avoid=("k", "g"))
    scatter_props(z, "oak", 3, 3, 50, 54, 40, 32, avoid=("k", "h"))
    scatter_props(z, "pine", 3, 3, 50, 54, 18, 33, avoid=("k",))
    # the Farm: a walled field and a cottage; the Red Lion, a rock on the lower road
    z.rect(42, 42, 9, 6, "W"); z.rect(43, 43, 7, 4, "g"); z.rect(46, 47, 1, 1, "g")
    z.building(44, 43, 4, 3, "sa_colonial", "The Farm", show_label=True)
    z.prop("rock", 12, 54, variant=2)
    z.d["spawn"] = [28, 56]
    plaque(z, 26, 54, "ascension_green_mountain", "Green Mountain",
           "From the sea Ascension looks like a bare cinder heap, yet its highest peak, at 859 metres, wears a cloud forest. In 1843 Joseph Hooker, a botanist, visited and advised on making the mountain wet. The Navy shipped in thousands of plants from Kew, Argentina, South Africa and the Cape, and the rain followed.")
    plaque(z, 30, 40, "ascension_hooker", "Hooker's Idea",
           "Joseph Hooker, of Kew, thought that if trees and ferns caught enough cloud on the top of the mountain, they would drip water into the soil and keep the island in water. Charles Darwin supported the idea. A great many species were planted over the next decades, and the mountain is now a patchwork of bamboo, ginger, Norfolk pine and tree ferns from half the world.")
    plaque(z, 24, 10, "ascension_dampier", "Dampier's Drip",
           "In 1701 the explorer William Dampier's ship, HMS Roebuck, sank at Ascension, and he and his crew survived on a trickle of fresh water on the mountain. It is still called Dampier's Drip. Until the Marines came, it was one of the few places on the island where drinking water could be found.")
    plaque(z, 44, 41, "ascension_farm", "The Farm",
           "The Royal Marines built terraces, walls and a pipeline here in the 1800s, so that the garrison could grow vegetables and keep a few cattle and pigs. Everything was carried up and down by hand or by donkey. It was the Navy's way of saying 'we are staying'.")
    plaque(z, 16, 24, "ascension_devils_riding", "The Devil's Riding School",
           "A flat-bottomed crater on the south-east coast, down at Comfortless Cove, where sand and dust blow so smoothly that it looks like an arena. The sailors named it. Standing there on a hot day, it is not hard to believe somebody once practised riding a very large horse.")
    plaque(z, 41, 24, "ascension_bamboo", "Bamboo on the Mountain",
           "Look about you: the tall green canes are bamboo, introduced as a windbreak and a building material. It now grows in thick stands near the summit. Nothing here is native except the ferns that grow on the highest rocks, which were already here when the people arrived.")
    plaque(z, 14, 38, "ascension_wideawake_fair", "The Wideawake Fair",
           "Sooty terns, nicknamed wideawakes for their constant calling, nest in the open on the island's plains. Before the rats and cats were cleared the colonies were tiny. The numbers are climbing again, and the 'fair' on the plain is one of the great noisy gatherings of the Atlantic.")
    # ---- folk ----
    chat(z, "asc_farmer", "farmer", 46, 46, "Farm Hand",
         ["We grow bananas, tomatoes, lettuces, tomatoes and more tomatoes. I'll tell you now that a banana from this farm has travelled seven miles.",
          "In the old days, the Marines carried water down the mountain in barrels on a donkey cart. The donkeys have retired. The barrels have not."], "left", "still")
    chat(z, "asc_botanist", "birdwatcher", 30, 14, "Botanist",
         ["Hooker's forest is a strange thing. Almost every plant here has been brought from elsewhere, and yet it is a real forest, and the island's only cloud forest. Is that a fake? I've spent my career not answering that.",
          "The tree fern is the only native plant I can promise you. It's on the rocks above. You'll want a fair bit of breath."], "down", "still")
    chat(z, "asc_walker", "hiker", 18, 28, "Hill Walker",
         ["The climb to the top of the mountain takes about two hours on a path made of cinder and thought. At the top you walk into cloud, and the cloud is cold, and you remember you are standing in the Tropics.",
          "I've taken the same path forty times and there is always a different bird."], "down", "wander")
    # ---- wild ----
    wild_set(z, [("mistfrond", 16, {}), ("kidgruff", 10, {}), ("billgruff", 8, {}), ("hootlet", 8, {"time": ["night"]}), ("flittermouse", 8, {"time": ["night"]}),
                 ("greenman", 8, {}), ("pixling", 8, {"weather": ["fog", "drizzle"]}), ("pepperling", 8, {}), ("midgie", 6, {})])
    wild_set(z, [("mistfrond", 10, {}), ("pollanet", 10, {}), ("rillotter", 10, {})], "water")
    trainer(z, "asc_botanist_t", "Botanist Elsie", "Botanist", "birdwatcher",
            [("mistfrond", 96), ("greenman", 96), ("flaxling", 96), ("thornwyn", 96)], 28, 20, "down",
            ["I'm cataloguing the forest. Every plant, every pest, and an unhealthy number of weeds. Would you like to see how the pests do in battle?"],
            "Good. I've never seen a bamboo shoot hold its own so well.",
            "Ascension's plant life is mostly introduced, which makes it a kind of living museum of the Victorian age and a good, damp, quiet place to think.", 5600)
    trainer(z, "asc_hiker_t", "Hill Walker Dev", "Hill Walker", "hillwalker",
            [("kidgruff", 95), ("pixling", 96), ("heilan", 96), ("stagmor", 96)], 18, 40, "up",
            ["Two hours up, an hour down, and a very long argument about the flask. Let's go."],
            "Quite right. Back to the flask.",
            "The top of the mountain is wrapped in cloud for much of the year, and a good deal of the island's fresh water comes from it.", 5500)
    trainer(z, "asc_goat_t", "Wild Goatherd Pip", "Goatherd", "farmer",
            [("billgruff", 96), ("kidgruff", 95), ("herdwick", 96), ("tormane", 96)], 40, 30, "left",
            ["The goats were here first. I just came up to check on them."],
            "A bit of a headbutt, that. I admire it.",
            "The goats of Ascension were let loose by passing sailors from the 1500s. They are now much more numerous than the people, and well adapted.", 5500)
    scaled(["asc_botanist_t", "asc_hiker_t", "asc_goat_t"])
    finish_zone(z)
    z.save(OUT + "/" + zid + ".json")


def interiors(OUT, ret_fort, ret_church, ret_post, ret_club):
    zid = "ascension"
    interior(OUT, "ascension_fort", "Fort Hayes", zid, ret_fort, "museum",
             [npc("asc_curator", "gown_student", 6, 3, "asc_curator", name="Museum Curator"),
              npc("asc_marine_guide", "sailor", 9, 5, "asc_marine_guide", name="Old Marine", facing="left")],
             signs=[(3, 6, "ASCENSION HERITAGE SOCIETY. Open Saturdays, and when the curator feels like it."),
                    (3, 6, "HMS ASCENSION. The only 'ship' in the Royal Navy that was never at sea. Commissioned 1815.")])
    script("ascension_fort", "asc_curator", say("Museum Curator",
           "Welcome to Fort Hayes. We have the garrison's cannons, a Victorian water tank and a very small number of things that survived the damp. Most of what the island has is in the memory of its people.",
           "In 1815 the Navy decided Ascension was a ship. It had a captain, a chaplain and a flag. It did not have a sea, only the sea around it. The paperwork called it 'the stone frigate'. Nobody was ever cross about it.",
           "Fort Hayes is named for Captain Hayes, a commander of the island. It guarded the bay with guns that were fired mostly for salutes."))
    script("ascension_fort", "asc_marine_guide", say("Old Marine",
           "Water. Everything here is about water. The garrison had one trickle and a lot of men. We dug tanks, we piped it down the mountain, we rationed it. A Marine could be flogged for stealing a cup. A cup.",
           "The mountain turned green because somebody remembered that clouds are made of water. Don't tell anyone, but it was a good plan."))
    interior(OUT, "ascension_church", "St Mary's Church", zid, ret_church, "church",
             [npc("asc_chaplain", "choir_singer", 6, 2, "asc_chaplain", name="Chaplain")])
    script("ascension_church", "asc_chaplain", say("Chaplain",
           "Welcome. This church has seen the Marines, the cable men, the Americans and a great many Saint Helenian families. Come as you are, and you are welcome to the cup of tea after.",
           "The church register records a fair number of passing ships' crews: sailors off the African squadron, which patrolled to stop the slave trade, and put in here for water and a burial. They're all listed. Mind the history.",
           "From the church steps you can see the sea in three directions. It is a fine place to think about how far a thing can be from anything else."))
    interior(OUT, "ascension_post", "Post Office and Philatelic Bureau", zid, ret_post, "cafe",
             [npc("asc_postmaster", "shopkeeper", 3, 1, "asc_postmaster", name="Postmaster")], w=11, h=9,
             signs=[(8, 3, "ASCENSION STAMPS. Turtles, frigatebirds, the Falklands task force: collectors the world over write here.")])
    script("ascension_post", "asc_postmaster", say("Postmaster",
           "We sell stamps to collectors in eighty countries, which is more than we sell to people on the island. Ascension has issued its own stamps since 1922. A good set of turtle stamps keeps the whole post office going for a year.",
           "Mail comes in on the Airbridge flight, and on the St Helena ship. If you send a postcard from here, it will arrive. Eventually. In the meantime, it has seen a great deal of the sea."))
    interior(OUT, "ascension_club", "The Exiles Club", zid, ret_club, "cafe",
             [npc("asc_barman", "villager_2", 3, 1, "asc_barman", name="Barman"),
              npc("asc_regular", "fisherman_north", 9, 3, "asc_regular", name="Regular", facing="left")],
             props=[("fireplace", 6, 1, {"walk": True})])
    script("ascension_club", "asc_barman", say("Barman",
           "Welcome to the Exiles. On Friday we have a quiz, and anyone is allowed to win, though the RAF has won more than their share. The question is always about somewhere far away.") +
           [{"do": "quiz", "pub": "ascension_club", "region": "overseas", "who": "Barman"}])
    script("ascension_club", "asc_regular", say("Regular",
           "I've been on Ascension eleven years. People ask if I miss England. I miss the weather, which is a thing you shouldn't miss, and sausage rolls that haven't travelled.",
           "The club has a rule. Whoever turns up in the last month of their contract gets the first round. Hardly anyone has it fall on a Friday."))


def quest_data(OUT):
    z = "ascension"
    Q = "q_overseas_ascension_"
    script(z, "asc_ranger", [cmd_if(Q + "done",
        say("Conservation Officer", "Another season counted, thanks to you. I'll add your name to the list of people who didn't step on a nest."),
        [cmd_if(Q + "3",
                say("Conservation Officer", "The Warden says you were a credit to the fair. Right, as promised: a tag from the very first turtle we ever followed, and a steak from the boat. You've earned them.") +
                [give("turtle_tag"), give("wahoo_steak")] + standing(3) + [setf(Q + "done")],
                [cmd_if(Q + "2",
                        say("Conservation Officer", "The Wideawake Warden is east of the main road, on the plain. Tell the Warden I sent you. Ask about the fair."),
                        [cmd_if(Q + "1",
                                say("Conservation Officer", "Now find the Wideawake Warden, east of the road, and ask about the fair. A turtle is a good introduction to a tern.") + [setf(Q + "2")],
                                [cmd_if(Q + "started",
                                        [when("has_cindershell",
                                              say("Conservation Officer", "A Cindershell! Beautiful. Tracks across the sand and a very straight look. You're a natural.") + [setf(Q + "1")],
                                              say("Conservation Officer", "Not yet. Try the shallows or the beach, around dusk. A green turtle, if it's feeling cooperative."))],
                                        say("Conservation Officer", "Green turtles nest here, and the team needs people to help count the tracks each morning. Would you? Start by finding a Cindershell on the beach.") + [setf(Q + "started")])])])])])])
    script(z, "asc_legend_talk", [cmd_if(Q + "3",
        say("Wideawake Warden", "You fought well and the terns are back on the plain. I'll make sure the Conservation Officer hears."),
        [cmd_if(Q + "2",
                say("Wideawake Warden", "The Conservation Officer sent you. Good. The fair on the plain is the loudest, messiest, most beautiful thing on the island, and I'd like to see how you handle a noisy crowd.") +
                [battle("asc_legend")] +
                say("Wideawake Warden", "That's the spirit of the fair. You kept your head, and your creatures, in a noise like that. I'll tell them.") + [setf(Q + "3")],
                say("Wideawake Warden", "Hello. I look after the terns. Not the turtles. They have a department of their own."))])])
    quests = [{"id": "ascension_turtles", "title": "Counting Tracks", "region": "overseas_ascension", "town": "ascension", "giver": "Conservation Officer",
               "summary": "Help the conservation team on Ascension: meet a green turtle, then prove yourself to the Wideawake Warden.",
               "start_flag": Q + "started",
               "steps": [{"flag": Q + "1", "text": "Catch a Cindershell and show it to the Conservation Officer in Georgetown.", "zone": "ascension"},
                         {"flag": Q + "2", "text": "Go and find the Wideawake Warden, east of the main road.", "zone": "ascension"},
                         {"flag": Q + "3", "text": "Win a battle against the Wideawake Warden, in the noise of the fair.", "zone": "ascension"},
                         {"flag": Q + "3", "text": "Report back to the Conservation Officer.", "zone": "ascension"}],
               "done_flag": Q + "done", "reward": "The Turtle Tag (a Tide charm), a Wahoo Steak and standing in the Overseas Territories."}]
    write_quests(TERR, quests)


def items_and_registry():
    items = [heal_item("wahoo_steak", "Wahoo Steak", 420, 150, "A thick steak from a wahoo, a fast, striped fish that the Ascension anglers are famous for catching offshore. Grilled with lime. Restores 150 HP."),
             heal_item("dampiers_drip", "Dampier's Drip", 260, 90, "Cool, clean water from the spring on Green Mountain that kept William Dampier's shipwrecked crew alive in 1701. Restores 90 HP."),
             charm_item("turtle_tag", "Turtle Tag", "A numbered flipper tag of the sort fitted to green turtles on Ascension's beaches. Conservation staff follow each tagged turtle for decades, long after it has swum 2,000 kilometres to Brazil and back.",
                        "Tide moves hit 20% harder.", {"effect": "boost", "type": "tide", "mult": 1.2}, "{name}'s Turtle Tag shone in the surf!")]
    return items


def main(OUT):
    ret_fort, ret_church, ret_s, ret_h, ret_post, ret_club = ascension(OUT)
    green_mountain(OUT)
    interiors(OUT, ret_fort, ret_church, ret_post, ret_club)
    sanctuary_and_shop(OUT, "ascension", "Georgetown", ret_s, ret_h,
        ["Hello there. Georgetown Hospital, which we call the Sanctuary for creatures. The sea air will do your team a world of good. Pop them on the counter.",
         "The water is boiled and the tea is brewed. A little rest never hurt anyone, even on an island where the rest is mostly a turtle's business.",
         "All done. They look as good as a freshly hatched turtle heading for the sea.",
         "The Ark's in the corner, next to the ledger of who owes whom a pint.",
         "No worries. The goats will keep you company."],
        ("Hello! Wahoo, Dampier's Drip, and supplies off the ship. Everything here has come a very long way, so we try not to waste it.", "Mind the cinder on your boots, it gets everywhere."),
        ["cup_of_tea", "flask_of_tea", "smelling_salts", "wicker_snare", "iron_snare", "water_snare", "night_snare", "wahoo_steak", "dampiers_drip"])
    quest_data(OUT)
    write_items("overseas_ascension", items_and_registry())
    write_registry("ascension", "Ascension Island", "ascension", 36, 43, "raf",
                   "A volcanic cinder cone in the South Atlantic. Green turtles, a cloud forest and a runway.",
                   "The Voyager drops through cloud over a very red island. The pilot says: Welcome to Ascension. Please do not feed the goats.")
    append_quiz("overseas", [
        ("geography", "Which ocean is Ascension Island in?", "The South Atlantic", ["The Pacific", "The Indian Ocean", "The Arctic"], "Ascension is about 1,500 kilometres from the African coast and 2,250 from Brazil."),
        ("history", "Which event brought the Royal Navy to Ascension in 1815?", "Napoleon being exiled to St Helena", ["The Battle of Trafalgar", "The Spanish Armada", "The Falklands War"], "The Navy occupied the island so no one could use it to rescue Napoleon."),
        ("nature", "What did Joseph Hooker advise doing on Green Mountain in 1843?", "Planting a cloud forest", ["Mining it", "Draining it", "Building a lighthouse"], "Plants from around the world trapped cloud and made the mountain wetter."),
        ("creatures", "Which animal comes ashore to nest on Ascension's beaches?", "The green turtle", ["The penguin", "The walrus", "The kiwi"], "They swim from Brazil, about 2,000 kilometres, to lay their eggs."),
        ("history", "In which year did Ascension become a staging post for the Falklands task force?", "1982", ["1962", "1942", "1992"], "The airfield became one of the busiest in the world for a few weeks."),
    ])


if __name__ == "__main__":
    OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
    main(OUT)
    write_all(OUT)
    print("ascension: written")
