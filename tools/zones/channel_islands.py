# Wildlore 3.3 "Overseas", wave 33: the Channel Islands. Poole Quay (the ferry port, a cul-de-sac off the Exe Estuary's
# east side, gated on the Storm Stone), Jersey (St Helier and the island's east and north), Guernsey (St Peter Port and
# the island's west) and a nod to Sark. All written at par 40, the band of the fourth badge.
#
#   python3 tools/zones/channel_islands.py data/zones && python3 tools/zones/ci_anchor.py data/zones
#
# Writes the zones, their interiors, dialogue (data/dialogue) and trainers (data/trainers). Quests, items, shops,
# creatures, ferries, map data and the registry files are plain data files edited by hand.
import sys
from ci_common import *


def poole():
    W, H = 48, 40
    zid = "poole"
    z = Z(zid, "Poole Quay", W, H, kind="town", region="south_england", music="town_cornwall",
          weather={"drizzle": 22, "clear": 30, "sunshine": 24, "fog": 6, "gale": 10, "downpour": 8})
    z.d["stage"] = "docks"; z.d["town_id"] = zid; z.d["scaled_floor"] = FLOOR
    z.rect(0, 0, W, H, ".")
    z.border("T", 2, gaps=[(0, 11, 2, 3)])
    z.scatter(0, 0, W, H, "P", 8, 5, only="T")
    # the harbour: shallows, then open water; sandy spit on the east for Sandbanks
    z.rect(0, 29, W, 11, "$"); z.rect(0, 28, W, 1, "w")
    z.rect(40, 25, 8, 3, "s"); z.rect(38, 28, 10, 1, "w")
    # streets: High Street from the Exeter road, Thames Street behind the quay, the Quay itself and a lane between
    z.rect(0, 11, 22, 4, "="); z.rect(22, 11, 24, 4, ":")
    z.rect(21, 15, 3, 10, ":")
    z.rect(4, 19, 41, 2, ":")
    z.rect(4, 25, 36, 3, ":")
    # the station, north-east: platform and rail with the line running off the east edge, a buffer stop at the west end
    station(z, 34, 3, 8, 3, "Poole Station")
    z.rect(43, 6, 5, 1, "!"); z.prop("buffer_stop", 32, 6)
    z.rect(31, 5, 3, 1, ":"); z.rect(31, 5, 1, 7, ":")
    rail_guard(z, 38, 5, ["Poole. Trains from every station you have been to, and a short walk to the boats.",
                          "The line stops here because the sea starts there. Brunel would have built a bridge. He'd have had opinions about the ferry, too."], facing="down")
    plaque(z, 40, 5, "station", "Poole Station",
           "The line reached Poole in 1847 and the town has been the end of the railway ever since, with the harbour just a short walk off. The ferries to Jersey, Guernsey and, in summer, Cherbourg tie in with the trains.")
    # north block, facing High Street
    z.building(4, 7, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(7, 10, "poole_sanctuary", 5, 6, "up")
    z.building(11, 7, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(13, 10, "poole_shop", 4, 5, "up")
    z.building(18, 7, 8, 4, "stone", "RNLI Headquarters", door=4)
    z.warp(22, 10, "poole_rnli", 6, 7, "up")
    z.building(27, 7, 4, 4, "terrace", show_label=False)
    z.building(35, 8, 10, 3, "red_brick", "Poole Pottery", show_label=True)
    # mid block, facing Thames Street
    z.building(4, 15, 8, 4, "red_brick", "The Poole Arms", door=4)
    z.warp(8, 18, "poole_pub", 5, 6, "up")
    z.building(13, 15, 7, 4, "georgian_brick", "Custom House", door=3)
    z.warp(16, 18, "poole_customs", 6, 7, "up")
    z.building(25, 15, 6, 4, "terrace", show_label=False)
    z.building(32, 15, 6, 4, "white_render", show_label=False)
    z.building(39, 15, 6, 4, "guest_house", show_label=False)
    # quay block, facing the Quay
    z.building(4, 21, 9, 4, "waterfront_museum", "Poole Museum", door=4)
    z.warp(8, 24, "poole_museum", 6, 7, "up")
    z.building(14, 21, 6, 4, "harbour_row", show_label=False)
    z.building(26, 21, 10, 4, "red_brick", "Ferry Terminal", door=5)
    z.warp(31, 24, "poole_terminal", 6, 7, "up")
    z.building(38, 21, 7, 4, "harbour_row", show_label=False)
    # the ferry pier into the harbour
    z.rect(29, 28, 5, 7, ":")
    z.d["ferry"] = {"x": 31, "y": 33, "route": "poole_st_helier"}
    for (x, y) in [(29, 30), (33, 30)]:
        z.prop("bollard", x, y)
    for (x, y) in [(10, 31), (15, 33), (38, 31), (43, 34), (22, 35), (6, 35)]:
        z.prop("boat", x, y, variant=(x + y) % 3)
    for (x, y) in [(8, 29), (24, 30), (40, 30)]:
        z.prop("buoy", x, y)
    z.prop("lobster_pots", 12, 26); z.prop("lobster_pots", 24, 26); z.prop("lobster_pots", 37, 26)
    for x in (6, 16, 27, 36):
        z.prop("bollard", x, 27)
    for (x, y) in [(3, 14), (21, 12), (30, 14), (44, 13), (9, 19), (25, 20), (38, 20), (12, 25), (22, 26)]:
        z.prop("lamp_post", x, y)
    for (x, y) in [(6, 20), (28, 26), (34, 26)]:
        z.prop("bench", x, y)
    z.prop("bunting", 22, 12, variant=1, walk=True); z.prop("bunting", 22, 20, variant=3, walk=True)
    z.prop("flagpole", 26, 12, variant=4)
    z.prop("post_box", 3, 12)
    # Poole Park, north-west: tall grass and oaks
    blob(z, 12, 4, 8, 2, ",", only=".", seed=41, jitter=0.3)
    scatter_props(z, "oak", 3, 3, 24, 4, 7, 43, avoid=("."))
    blob(z, 40, 13, 3, 1, ",", only=".", seed=44)
    # fingerposts
    fingerpost(z, 4, 14, "WEST: the Exe Estuary, Exeter and Dartmoor. SOUTH: the Quay, the museum and the boats to the islands.")
    fingerpost(z, 28, 29, "FERRIES. East pier: JERSEY (St Helier) and GUERNSEY (St Peter Port). Tickets from the terminal, which is the big brick shed behind you.")
    # plaques
    plaque(z, 16, 14, "harbour", "Poole Harbour",
           "One of the largest natural harbours in the world, a drowned river valley full of mudflats, islands and reedbeds. It has an unusual double high tide, so the water stays up for hours, which helped the port work its ships in and out for centuries.")
    plaque(z, 18, 26, "newfoundland", "The Newfoundland Trade",
           "In the 1600s and 1700s Poole merchants sent ships to Newfoundland every spring to fish for cod, then sold the salted catch round the Mediterranean. Poole grew rich on it, and many of the quay's old warehouses and fine houses were built on cod.")
    plaque(z, 12, 20, "customs", "The Custom House",
           "In October 1747 a gang of smugglers broke into Poole's Custom House to take back a cargo of tea that the customs men had seized. The building you see now dates from 1813. Smuggling was a way of life along this coast, and the tea was not the only thing that arrived by moonlight.")
    plaque(z, 5, 26, "rnli", "RNLI Headquarters",
           "The Royal National Lifeboat Institution has had its headquarters in Poole for decades. It began in 1824, set up by Sir William Hillary, who lived in Douglas on the Isle of Man and later helped crew the lifeboats himself. Its crews are volunteers, and its lifeboats are paid for by public donations.")
    plaque(z, 14, 26, "logboat", "The Poole Logboat",
           "An Iron Age dugout canoe, hollowed from one huge oak about 2,200 years ago, found in the harbour mud in 1964 and now in Poole Museum. At about ten metres long it is one of the largest of its kind found in Britain.")
    plaque(z, 37, 20, "pottery", "Poole Pottery",
           "Jesse Carter began a tile and pottery works on the quay in 1873. As Poole Pottery, its brightly hand-painted dishes and vases were Art Deco favourites between the wars. Pieces are still much collected.")
    plaque(z, 45, 23, "sandbanks", "Sandbanks and the Chain Ferry",
           "The sandy spit across the harbour mouth is Sandbanks, among the most expensive land per acre in the world. A chain ferry has hauled cars across the mouth to Studland since 1926, pulling itself along on huge chains laid on the harbour bed. The crossing takes only a few minutes.")
    plaque(z, 45, 12, "marconi", "Marconi at Sandbanks",
           "In 1898 Guglielmo Marconi set up wireless equipment at the Haven Hotel on Sandbanks and talked over the water to his station on the Isle of Wight, in the early days of radio. The mast has long gone, but a plaque at the hotel remembers it.")
    plaque(z, 22, 27, "brownsea", "Brownsea Island",
           "The wooded island in the middle of the harbour. In August 1907 Robert Baden-Powell took twenty boys camping there, the experiment that grew into the Scout movement. It is also one of the few places in southern England where red squirrels still live wild. The National Trust looks after it.")
    # people
    chat(z, "poole_fisher", "fisherman_north", 17, 27, "Quay Fisherman",
         ["Cod to Newfoundland, tea off the boats, and now crossing the Channel in a boat the size of a block of flats. Poole's always been about getting out to sea.",
          "The tide here does something odd. It comes up, stops, dips a little, then comes up again. Double high water. Gives the pilots all the time in the world, if they've the nerve."], "left")
    chat(z, "poole_scout", "student", 24, 24, "Scout Leader",
         ["Brownsea Island's over there, with the red squirrels. Baden-Powell brought twenty boys over in 1907 and said, in effect, 'build a fire and see what happens'. A hundred years later, half the country's been to a Scout camp.",
          "I've forty Cubs coming Saturday. Send help. Or hot dogs."], "right")
    chat(z, "poole_yachtie", "villager_5", 42, 27, "Sandbanks Resident",
         ["I live on Sandbanks. The house is the size of a garden shed, but the land underneath costs about the same as a small country.",
          "The chain ferry's lovely, though. It pulls itself over on a chain, all day, calmly. I find it very soothing. I've been watching it for years."], "left")
    z.npc(id="poole_sailor_je", sprite="sailor", x=29, y=31, facing="right", move="still", script="poole_sailor_je", name="Ferry Hand")
    script(zid, "poole_sailor_je", say("Ferry Hand", "St Helier, Jersey? The cows are golden, the potatoes are royal and the tax is low. Not that you'll be seeing the tax.") + [{"do": "ferry", "route": "poole_st_helier"}])
    z.npc(id="poole_sailor_gu", sprite="sailor", x=33, y=31, facing="left", move="still", script="poole_sailor_gu", name="Ferry Hand")
    script(zid, "poole_sailor_gu", say("Ferry Hand", "Guernsey! Cows, castles and a Frenchman's exile. Hold your hat, it's a fresh crossing.") + [{"do": "ferry", "route": "poole_st_peter_port"}])
    # trainers
    trainer(z, "poo_lifeboat", "Helmsman Pike", "Lifeboat Volunteer", "sailor",
            [("baskling", 40), ("selklet", 40), ("pupplash", 41)], 8, 26, "down",
            ["Pager's quiet, so I'm free for a scrap. Volunteer crew, all of us. If the pager goes, I'm gone mid-sentence, and you'll know the reason."],
            "Well done. If you ever get into trouble out there, you'll know who to call.", "Over a hundred thousand people have been saved by RNLI crews since 1824. I'm proud to be a small bit of that.", 760)
    trainer(z, "poo_scout", "Scout Hartley", "Scout", "student",
            [("puffling", 40), ("ternlet", 40), ("starlet", 41), ("hootlet", 41)], 34, 12, "left",
            ["Be prepared! I've got a woggle, a penknife and a first-aid badge. Prepared for anything except you."],
            "That's a badge for you. Fair play.", "Baden-Powell's camp on Brownsea was in 1907. My troop go every summer. Red squirrels, mostly.", 720)
    trainer(z, "poo_sandbanks", "Yacht-Owner Camilla", "Yachtswoman", "villager_5",
            [("clownbill", 41), ("dolphlet", 40), ("chipgull", 41)], 36, 26, "left",
            ["Darling, I own a yacht. It is mostly moored. It's far too nice to take out in anything rougher than a bath."],
            "Oh, I say. You're quite good. Do come aboard for a drink and lose gracefully.", "The yacht's called Second Wind. We got it from the first one. It was just called Wind.", 880)
    scale(["poo_lifeboat", "poo_scout", "poo_sandbanks"])
    wild(z, [("chipgull", 40, 42, 14, {}), ("ternlet", 40, 41, 12, {}), ("starlet", 40, 41, 10, {"time": ["dawn", "day", "dusk"]}),
             ("cooplet", 40, 41, 10, {}), ("grizzlet", 40, 41, 8, {}), ("pinchkin", 40, 41, 10, {}), ("rivetling", 40, 42, 8, {}),
             ("binfox", 41, 42, 6, {"time": ["dusk", "night"]}), ("hootlet", 41, 42, 6, {"time": ["night"]}),
             ("gannetling", 40, 42, 6, {"weather": ["gale", "clear"]})])
    wild(z, [("pinchkin", 40, 41, 18, {}), ("baskling", 40, 42, 14, {}), ("selklet", 40, 42, 10, {}), ("dolphlet", 40, 42, 10, {}),
             ("puffling", 40, 41, 10, {"season": ["spring", "summer"]}), ("pupplash", 40, 42, 12, {}), ("orcalet", 41, 42, 4, {})], "water")
    z.d["edges"] = {"west": {"to": "exe_estuary", "offset": 0}}
    z.d["spawn"] = [4, 12]
    seal(z, [(0, 11, 2, 3)])
    done(z)
    z.save(OUT + "/" + zid + ".json")

    sanctuary(OUT, zid, "Poole", (7, 11))
    shop(OUT, zid, "Poole", (13, 11))
    nurse(zid, ["Hello, love. Poole Sanctuary: ferry sick, sea sick, sick of seagulls, we treat the lot. Pop your team on the counter.",
                "There you go, dear, have a sit. There's tea, and a lifeboat-shaped biscuit tin the volunteers keep topped up.",
                "All done. Fit as a fiddle, and a lot fitter than anyone coming off the Guernsey boat in a swell.",
                "The Ark's by the window. It's got a lovely view of the harbour and an unreasonable amount of salt on the glass.",
                "Right you are. Mind the gulls on the quay, they've taken three of my sandwiches this year alone."])
    shopkeeper(zid, "Hello! Tea, snares, pasties for the crossing, and a ginger biscuit if you're feeling queasy. Get your sea legs in order.",
               "Good crossing! And do bring us back a Jersey Royal, if they've any left.")
    room(z, "poole_rnli", 18, 7, 8, 4, "stone", "RNLI Headquarters", 4, "hall",
         [("poo_rnli_crew", "sailor", 4, 4, "right", "Lifeboat Crew",
           ["The RNLI began in 1824 as the Royal National Institution for the Preservation of Life from Shipwreck. Sir William Hillary of Douglas started it, after watching wrecks off the Isle of Man.",
            "Crews are volunteers: nurses, bakers, plumbers. When the pager goes they drop everything and run. The charity is paid for by donations, not the government, and the lifeboats are named for the people who paid."]),
          ("poo_rnli_boat", "shipwright", 9, 4, "left", "Boat Builder",
           ["That's a model of a modern lifeboat, a Shannon class. It's driven by water jets, so it can be beached to pick up a casualty, or run on to the sand and float off again.",
            "The first lifeboats were pulled by oars and sail. Each crew member wore a cork life jacket, which is where the word 'lifejacket' got started. They did it for the love of it, and they still do."])])
    room(z, "poole_pub", 4, 15, 8, 4, "red_brick", "The Poole Arms", 4, "cafe",
         [("poo_landlord", "shopkeeper", 3, 1, "down", "Landlord",
           ["Welcome to the Poole Arms. This pub's been on the Quay for well over two hundred years, and we've fed a good many sailors who'd just come in from Newfoundland. We still have plenty of fish.",
            "We do a crab sandwich that will change your life. Or at least stop it feeling quite so long until teatime."]),
          ("poo_quiz", "fiddler", 7, 4, "left", "Quizmaster", None)],
         rw=11, rh=9)
    room(z, "poole_customs", 13, 15, 7, 4, "georgian_brick", "Custom House", 3, "hall",
         [("poo_customs_off", "tour_guide", 4, 4, "right", "Customs Officer",
           ["The Custom House is where cargoes were measured, taxed and sometimes argued over. In 1747 a gang broke into the previous building to get back a cargo of tea that officers had seized from a smuggler.",
            "Tea was heavily taxed, so smugglers brought it in cheap from the Continent. A great deal of the Channel Islands' history is about boats coming and going with something under the nets. Mostly lace and brandy."])])
    room(z, "poole_museum", 4, 21, 9, 4, "waterfront_museum", "Poole Museum", 4, "museum",
         [("poo_curator", "tour_guide", 9, 4, "left", "Curator",
           ["The prize here is the Poole Logboat: an Iron Age dugout canoe about 2,200 years old, found in the harbour in 1964. It was carved from a single giant oak and is about ten metres long. Imagine paddling that out for fish.",
            "The museum also tells of the Newfoundland trade, Poole Pottery and the harbour's smuggling. We have a very nice lifeboat too."])])
    room(z, "poole_terminal", 26, 21, 10, 4, "red_brick", "Ferry Terminal", 5, "hall",
         [("poo_clerk", "shopkeeper", 4, 4, "right", "Ticket Clerk",
           ["Channel Islands boats from the east pier, Jersey and Guernsey. Between them they run all year round, though the sea decides most days. Bring a coat, a book and something for the gulls.",
            "The Channel Islands are not part of the United Kingdom. They're Crown Dependencies, with their own governments, laws and stamps. You won't need a passport from here, only a good ticket and a strong stomach."]),
          ("poo_traveller", "villager_4", 9, 4, "left", "Traveller",
           ["First time? Everyone's first time they get a bit emotional about the cows. The cows are the best bit. Pale gold and big eyes, like a Disney deer who's been told off.",
            "Take a jumper. Both islands gave their names to jumpers, jersey and guernsey. It's cold on the boat."])],
         rw=15, rh=10)
    poole_story()


def poole_story():
    pubquiz("poole_pub", "poo_quiz", "poole", "Quiz night's tonight, if you fancy it. Warm-up question: which island in Poole Harbour did the Scouts begin on? Brownsea! Not hard, to be fair.")


if __name__ == "__main__":
    poole()
    import ci_jersey, ci_guernsey
    ci_jersey.build()
    ci_guernsey.build()
    import ci_story
    ci_story.write()
    write_all(OUT)
