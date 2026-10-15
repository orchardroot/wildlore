# plan 6 group A, part 4: whitby (the abbey on the east cliff, the 199 steps, the harbour, jet; Black Shuck's clifftop).
from p6a_common import *
from wcommon import _stand


def build(OUT):
    whitby(OUT)


def whitby(OUT):
    W, H = 72, 56
    zid = "whitby"
    z = Z(zid, "Whitby", W, H, kind="town", region=YK, music="town_north",
          weather={"drizzle": 24, "fog": 20, "clear": 22, "gale": 14, "sunshine": 14, "downpour": 6})
    z.d["stage"] = "coast"; z.d["town_id"] = "whitby"
    z.legend["g"] = {"tile": "grass", "colour": "#7b9150"}
    z.rect(0, 0, W, H, "g")
    z.border("T", 2, gaps=[(0, 30, 2, 3), (14, 54, 3, 2)])
    z.scatter(0, 0, W, H, "P", 14, 91, only="T")
    # the sea to the north and east
    z.rect(0, 0, W, 7, "$")
    z.rect(58, 7, 14, 49, "$")
    z.rect(2, 7, 56, 1, "w"); z.rect(0, 0, W, 2, "$")
    # the East Cliff: heights climb with the steps
    prof = {8: 4, 14: 3, 19: 2, 24: 1, 29: 0}
    for y in range(8, 29):
        v = 4 if y < 14 else 3 if y < 19 else 2 if y < 24 else 1
        for x in range(36, 58):
            z.hg[y][x] = v
    z.rect(56, 8, 2, 23, "^")
    # the River Esk and the harbour
    z.rect(28, 8, 8, 38, "~")
    z.rect(28, 8, 1, 38, "w"); z.rect(35, 8, 1, 38, "w")
    z.rect(29, 8, 1, 14, "o"); z.rect(34, 8, 1, 14, "o")
    z.rect(28, 46, 8, 1, "w")
    z.rect(26, 8, 2, 38, ":")
    z.rect(36, 29, 4, 17, ":")
    # the piers with their lighthouses
    z.rect(25, 3, 2, 5, ":"); z.rect(37, 3, 2, 5, ":")
    z.rect(25, 7, 3, 1, ":"); z.rect(36, 7, 3, 1, ":")
    z.prop("lighthouse", 25, 3); z.prop("lighthouse", 38, 3)
    # the swing bridge and the road
    z.rect(0, 30, 28, 3, "=")
    z.rect(28, 30, 8, 3, "=")
    z.rect(28, 29, 8, 1, "W"); z.rect(28, 33, 8, 1, "W")
    z.rect(36, 30, 4, 3, ":")
    z.prop("lamp_post", 29, 28); z.prop("lamp_post", 34, 28)
    z.sign(27, 28, "THE SWING BRIDGE. It opens twice a day to let the boats in and out of the upper harbour, and it makes a clatter when it does. The Esk gives the town its fresh water, its fish and, in the right light, its mood.")
    # the 199 steps
    z.rect(37, 9, 3, 20, "#")
    z.rect(37, 13, 20, 2, "#")
    for y in (13, 18, 23, 27):
        z.prop("bench", 40, y)
    z.rect(40, 14, 1, 15, "^")
    z.sign(36, 28, "THE 199 STEPS. Counted by every child who has ever climbed them, and there are 199, unless you count the landing, in which case there are 199 and a half. The old Church Stairs were used to carry coffins up to the churchyard, with a stop for a breather at every landing. The benches are for the living.")
    z.sign(38, 19, "STEP COUNT. 100. Halfway. The abbey is still up there. So is the wind.")
    # St Mary's and the abbey ruins on the clifftop
    z.building(41, 9, 5, 3, "chapel", "St Mary's Church")
    z.building(47, 8, 9, 5, "cathedral", "Whitby Abbey (ruins)", door=4)
    z.rect(41, 13, 15, 1, ".")
    z.prop("bench", 43, 14); z.prop("bench", 47, 14); z.prop("lamp_post", 41, 12); z.prop("lamp_post", 46, 12)
    z.prop("rock", 55, 13); z.prop("rock", 54, 15)
    z.sign(45, 13, "WHITBY ABBEY. Founded in 657 by St Hilda, an abbess who hosted the Synod of Whitby that fixed the date of Easter for the English church. One of her cowherds, Caedmon, sang a hymn in English and became the first English poet we know by name. The ruins you see are from the 13th century and keep losing a stone or two to the weather.")
    z.sign(53, 14, "DRACULA. In 1890 the writer Bram Stoker stayed in Whitby and was inspired by the abbey, the churchyard and the harbour. In his novel the Count arrives on a wrecked ship, in the form of a great black dog that races up the steps of the churchyard. The graveyard benches here are the place where Mina sat.")
    # Black Shuck's spot
    _stand(z, 53, 16)
    z.npc(id="shuck_spot", sprite="creature:shuck", x=53, y=16, facing="down", move="still", script="shuck", hide_if="caught_shuck")
    script(zid, "shuck", say("Black Shuck", "Placeholder: the story agent rewrites this legend script."))
    # the plateau below the abbey: grass and tall grass
    blob(z, 49, 22, 5, 3, ",", only="g", seed=5, jitter=0.3)
    blob(z, 46, 26, 4, 2, ",", only="g", seed=6, jitter=0.3)
    # the lower East Side: lanes of jet workshops and fish bars
    z.rect(40, 32, 17, 1, ":")
    z.building(41, 29, 6, 3, "slate_cottage", "Jet Workshop", door=2)
    z.building(48, 29, 8, 3, "terrace", "Henrietta Street")
    z.building(41, 34, 6, 3, "white_render", "Fish and Chips", door=2)
    z.building(48, 34, 8, 3, "terrace", "Church Street")
    z.rect(40, 37, 17, 1, ":")
    z.building(41, 38, 14, 4, "tudor", "Smugglers' Alley")
    z.prop("lamp_post", 40, 33); z.prop("lamp_post", 56, 33); z.prop("bench", 46, 37); z.prop("planter", 50, 37)
    # the West Cliff: Cook's statue, the whalebone arch
    hills(z, [(11, 14, 3, 10)])
    z.rect(5, 9, 18, 16, "g")
    z.rect(4, 22, 20, 1, "#"); z.rect(13, 12, 1, 11, "#"); z.rect(6, 13, 16, 1, "#")
    z.prop("statue", 13, 11, variant=1)
    z.prop("standing_stone", 11, 13, variant=2); z.prop("standing_stone", 16, 13, variant=2)
    z.prop("bench", 10, 15); z.prop("bench", 17, 15); z.prop("lamp_post", 12, 22); z.prop("lamp_post", 15, 22)
    z.sign(13, 14, "CAPTAIN COOK AND THE WHALEBONE ARCH. James Cook learnt his seamanship in Whitby's colliers and sailed from here to the Pacific in the Endeavour, a Whitby-built ship. The arch of whale jawbones nearby is a nod to the whalers who once sailed from this harbour, and it has been rebuilt more than once. The whalers' wives watched from here.")
    # town buildings on the west bank
    z.building(4, 25, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(7, 28, "whitby_sanctuary", 5, 6, "up")
    z.building(11, 25, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(13, 28, "whitby_shop", 4, 5, "up")
    z.building(17, 25, 8, 4, "white_render", "Captain Cook Memorial Museum")
    z.building(4, 35, 8, 4, "terrace", "Flowergate"); z.building(4, 41, 8, 4, "red_brick", "The Harbour Inn")
    z.rect(5, 39, 8, 1, ":")
    z.building(17, 41, 8, 3, "stone", "Pannett Park Museum")
    # Whitby station
    station(z, 19, 36, 8, 4, "Whitby Station")
    z.rect(18, 38, 1, 2, ":"); z.rect(27, 38, 1, 2, ":")
    z.prop("bench", 21, 40); z.prop("lamp_post", 24, 40)
    rail_guard(z, 25, 38, ["Whitby Station. The end of the line, quite literally, or the start of it, depending on whether you have a bag of chips.",
                            "All aboard! The trains go everywhere you have been. Mind the gap, and the herring gull."], facing="left")
    # the road south to York
    z.rect(14, 33, 3, 22, "=")
    z.rect(14, 54, 3, 2, "=")
    blob(z, 8, 50, 6, 4, ",", only="g", seed=7, jitter=0.3)
    blob(z, 22, 50, 5, 3, ",", only="g", seed=8, jitter=0.3)
    scatter_props(z, "oak", 3, 46, 50, 8, 8, 14, avoid=("g",))
    scatter_props(z, "bush", 3, 8, 50, 46, 14, 15, avoid=("g",))
    # boats in the harbour
    for (x, y) in [(31, 12), (33, 17), (30, 24), (33, 27), (31, 37), (33, 41), (30, 20)]:
        z.prop("boat", x, y, variant=1)
    z.prop("buoy", 32, 14)
    for y in range(10, 46, 6):
        z.prop("bollard", 26, y)
    z.sign(26, 34, "WHITBY HARBOUR. A fishing port, a shipbuilder and a whaling station in its time. Its fish and chips are, according to everybody, the best in the world, and according to everybody else's town, a close second. The seagulls here are the most skilled thieves in Yorkshire.")
    # NPCs
    chat(z, "wby_chipper", "shopkeeper", 44, 33, "Chip Shop Owner",
         ["Haddock, chips, mushy peas, bread and butter, and a pot of tea. Yorkshire law, that is. The haddock is from the boat you just saw.",
          "Watch your chips. The gulls here are professionals. They don't dive. They wait until you look at the sea."], "down", "still")
    chat(z, "wby_jeweller", "villager_5", 43, 31, "Jet Carver",
         ["Whitby jet is fossilised monkey-puzzle wood, nearly 180 million years old. You can carve it, and it takes a lovely polish, and it will pull a tiny scrap of paper to itself if you rub it.",
          "Queen Victoria wore it in mourning, so every lady in the land wanted it. At the peak there were two hundred jet workshops in this little town. Now there are some. I'm one."], "down", "still")
    chat(z, "wby_goth", "villager_6", 17, 34, "Goth Weekender",
         ["Whitby Goth Weekend! Twice a year, thousands of us arrive in black velvet and top hats and walk up the 199 steps, because that is what Dracula would do.",
          "The locals are delighted. A top hat on a seagull is a statement. A seagull wearing it is a different matter."], "left", "wander")
    chat(z, "wby_skipper", "angler", 27, 36, "Harbour Skipper",
         ["The Endeavour was built here in 1764 as a coal ship called the Earl of Pembroke. The navy bought it, renamed it, and sent Captain Cook round the world in it. A Whitby collier, circling the globe!",
          "Colliers were broad and flat-bottomed, so they could sit on the mud at low tide without falling over. A good ship for the unknown."], "left", "still")
    chat(z, "wby_bard", "poet", 42, 15, "Churchyard Poet",
         ["Caedmon was a cowherd who was too shy to sing at feasts. He left one night, had a dream, and woke up able to sing in his own language. He sang, in English, about creation. It's the oldest English poem we have.",
          "I have written nine hundred poems and a limerick. The limerick is the one people remember."], "up", "wander")
    # trainers
    trainer(z, "wby_fisher", "Fisher Jack", "Fisher", "fisher",
            [("greyhaul", 83), ("bayrunner", 83), ("clownbill", 83)], 26, 20, "right",
            ["The herring boats went out each night with lanterns, and the harbour looked like a field of stars. The herring don't do that any more, but I like to tell it."],
            "Well sailed. A hair of the sea to you.", "My grandfather caught herring. My father caught cod. I catch trouble. It never gets away.", 3460)
    trainer(z, "wby_ghost", "Ghost Walker Mortimer", "Ghost Walker", "tour_guide",
            [("hushwing", 83), ("legionette", 83), ("jetwhitby", 84)], 38, 24, "up",
            ["Good evening. Do you know what lurks on the 199 steps at dusk? Tourists. But if you look closely, you can also see... where did my bowler hat go? It was on the bench a minute ago."],
            "Splendid. I'll put you in the tour: 'the Visitor Who Won'.", "The 199 steps are haunted by the ghost of a legend, a black hound with burning eyes, the Barghest. It was right behind me on the way up. Please check.", 3520)
    trainer(z, "wby_historian", "Historian Dr Hilda", "Historian", "poet",
            [("lanternis", 83), ("centurion", 83), ("peatmonarch", 83)], 45, 18, "left",
            ["The Synod of Whitby in 664 decided how the English church would count Easter. Years of argument, a lot of calendars, and the answer was Rome's. History hinges on small things."],
            "I yield. A sound argument, and an excellent hat.", "Hilda was an abbess, and a teacher of bishops. Five of her pupils became bishops. That is a better record than most schools.", 3500)
    wild(z, [("jetling", 83, 83, 18, {}), ("kitelet", 83, 83, 8, {"time": ["day"]}), ("swiftlet", 83, 83, 8, {"weather": ["gale", "drizzle"]}),
             ("chipgull", 83, 83, 10, {}), ("ternlet", 83, 83, 10, {}), ("hootlet", 83, 83, 6, {"time": ["night"]}), ("barnling", 83, 83, 6, {"time": ["night"]}),
             ("flittermouse", 83, 83, 6, {"time": ["night"]}), ("rooklet", 83, 83, 8, {}), ("starlet", 83, 83, 8, {"time": ["dusk", "dawn"]}),
             ("pepperling", 83, 83, 6, {}), ("gannetling", 83, 83, 6, {})])
    wild(z, [("pupplash", 83, 83, 20, {}), ("gannetling", 83, 83, 18, {}), ("pinchkin", 83, 83, 18, {}), ("chipgull", 83, 83, 16, {}),
             ("dolphlet", 83, 83, 12, {"time": ["day"]}), ("dipling", 83, 83, 10, {}), ("stalklet", 83, 83, 10, {})], "water")
    z.d["edges"] = {"west": {"to": "north_york_moors", "offset": 0}, "south": {"to": "york", "offset": 0}}
    z.rect(0, 30, 2, 3, "="); z.rect(14, 54, 3, 2, "=")
    z.d["spawn"] = [8, 31]
    done(z)
    z.save(OUT + "/" + zid + ".json")
    sanctuary(OUT, zid, "Whitby", (7, 29), music="sanctuary")
    shop(OUT, zid, "Whitby", (13, 29))
    nurse(zid, ["Now then, love! Welcome to Whitby Sanctuary. Pop your team on the counter and I'll see them right. They look like they've climbed all 199 steps.",
                "Sit thissen down. There's a pot of tea, a plate of parkin, and a view of the harbour. If a seagull takes the parkin, that's tradition.",
                "There! Champion. Right as rain, which round here is a state of mind. Mind how you go, and watch the bench, there's a hat on it.",
                "The Ark's in the corner, love. It's got a faint smell of sea air and a very polite fish on the lid. Go on, have a click.",
                "No bother at all, love. Off you pop, and give my regards to the steps."])
    shopkeeper(zid, "Ey up! Snares, tea, a bag of chips on the side, and a jet pendant which I will not let you leave without admiring. What'll it be?",
               "Ta-ra, love! Mind the gulls. They know where you live.")
