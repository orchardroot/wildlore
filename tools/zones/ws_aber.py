# aberystwyth (town) and aber_lab (interior), plus the town's Sanctuary and Corner Shop.
from wcommon import *
from ws_cambrian import seal_ns


def build(OUT):
    z = Z("aberystwyth", "Aberystwyth", 56, 46, kind="town", region="mid_wales", music="town_wales",
          weather={"clear": 25, "drizzle": 30, "gale": 12, "sunshine": 18, "fog": 15})
    z.d["stage"] = "coast"; z.d["town_id"] = "aberystwyth"
    z.border("T", 2)
    z.scatter(0, 0, 56, 46, "P", 30, 2, only="T")
    # sea, beach and the promenade
    for y in range(46):
        for x in range(0, 8 if y < 12 else 6):
            z.set(x, y, "$")
    z.rect(6, 12, 1, 34, "w"); z.rect(7, 12, 3, 33, "s"); z.rect(6, 45, 4, 1, "T")
    z.rect(10, 12, 2, 33, ":")
    z.rect(12, 14, 1, 31, "=")      # Marine Terrace road
    z.rect(13, 14, 1, 31, ":")
    for y in range(14, 44, 5):
        z.prop("lamp_post", 9, y)
    for y in (17, 22, 33, 39):
        z.prop("bench", 10, y)
    z.prop("planter", 10, 29); z.prop("planter", 10, 31)
    scatter_props(z, "rock", 7, 14, 3, 30, 5, 2, avoid=("s",))
    z.prop("buoy", 3, 18); z.prop("boat", 2, 33, variant=1); z.prop("buoy", 4, 40, variant=1); z.prop("boat", 3, 14, variant=1)
    # Royal Pier
    z.rect(5, 25, 5, 1, "|"); z.building(1, 24, 4, 3, "white_render", "Royal Pier Pavilion")
    # main streets: the N-S road down the middle and Great Darkgate Street across
    z.rect(30, 0, 3, 46, "=")
    z.rect(13, 28, 40, 2, "="); z.rect(13, 27, 40, 1, ":"); z.rect(13, 30, 40, 1, ":")
    z.rect(29, 0, 1, 46, ":"); z.rect(33, 0, 1, 46, ":")
    z.rect(29, 28, 5, 2, "=")
    z.rect(29, 14, 1, 1, ":")
    for x in (16, 22, 38, 44, 50):
        z.prop("lamp_post", x, 30)
    z.prop("phone_box", 27, 27); z.prop("post_box", 36, 27)
    # --- Constitution Hill and the cliff railway
    z.height(10, 8, 19, 4, 1); z.height(10, 6, 19, 2, 2); z.height(10, 4, 19, 2, 3); z.height(10, 0, 19, 4, 4)
    z.rect(10, 0, 19, 12, ".")
    z.rect(8, 0, 2, 12, "^")
    z.rect(10, 1, 18, 1, "R"); z.rect(10, 0, 18, 1, "R")
    z.building(13, 12, 5, 2, "stone", "Cliff Railway", show_label=True)
    z.rect(15, 4, 1, 8, "!")
    z.building(12, 1, 7, 3, "stone", "Camera Obscura")
    path(z, [(22, 12), (22, 4), (13, 4)], "#", 2)
    z.rect(22, 12, 2, 2, "#")
    z.rect(22, 14, 2, 1, "#")
    z.rect(22, 3, 6, 1, "."); z.rect(22, 0, 6, 4, ".")
    z.rect(23, 8, 5, 3, ","); z.rect(11, 6, 3, 4, ","); z.rect(17, 8, 3, 4, "f")
    z.prop("bench", 24, 2); z.prop("bench", 26, 2); z.prop("statue", 22, 1)
    z.sign(21, 3, "CAMERA OBSCURA. Claims to be the world's biggest. Shows the whole bay on a table. Today the table shows drizzle.")
    z.sign(20, 12, "CLIFF RAILWAY. 1896. Up in 4 minutes, down in 4 minutes, a lifetime of 'one more go' in between.")
    z.sign(11, 11, "CONSTITUTION HILL, 130 m. The 'Constitution' is a walk. Not a law.")
    # --- the University hill, east
    z.height(35, 4, 20, 16, 1); z.height(37, 6, 16, 12, 2)
    z.rect(35, 4, 20, 16, "."); z.rect(37, 6, 16, 12, ".")
    z.rect(35, 4, 20, 1, "T"); z.rect(53, 4, 2, 16, "T")
    z.building(38, 7, 7, 4, "stone", "Old College")
    z.building(46, 7, 5, 4, "white_render", "Wardstone Lab", door=2)
    z.building(38, 13, 6, 3, "red_brick", "Hugh Owen Library", show_label=True)
    z.building(46, 13, 6, 3, "cream_render", "National Library of Wales")
    z.rect(37, 11, 16, 2, "#"); z.rect(44, 11, 2, 7, "#")
    path(z, [(33, 19), (36, 19)], "#", 1); path(z, [(36, 19), (36, 12)], "#", 1)
    z.rect(37, 12, 1, 1, "#")
    z.rect(33, 18, 4, 2, "#")
    z.prop("statue", 44, 12); z.prop("bench", 41, 12); z.prop("bench", 49, 12); z.prop("oak", 40, 17); z.prop("oak", 52, 17)
    z.prop("oak", 37, 10, variant=1); z.prop("oak", 52, 6); z.prop("planter", 43, 12); z.prop("planter", 46, 12)
    z.sign(36, 17, "ABERYSTWYTH UNIVERSITY. Founded 1872 on pennies from ordinary Welsh people. First college of its kind in Wales. Don't leave bikes on the grass.")
    z.sign(45, 18, "NATIONAL LIBRARY OF WALES. Quiet please. The Black Book of Carmarthen is asleep.")
    # --- Sanctuary and Corner Shop on the street
    z.building(15, 23, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.building(22, 23, 5, 4, "shop", "Corner Shop", door=2)
    z.building(34, 22, 8, 5, "terrace", "The Chippy")
    z.building(43, 22, 5, 5, "cream_render", "Ice Cream Parlour")
    z.building(49, 22, 4, 5, "white_render", show_label=False)
    z.building(15, 16, 7, 4, "terrace", "Marine Terrace")
    z.building(23, 16, 6, 4, "cream_render", show_label=False)
    z.building(14, 31, 6, 3, "terrace", show_label=False)
    z.building(21, 31, 6, 3, "red_brick", "Aber Arts", show_label=True)
    z.rect(14, 34, 14, 1, ":")
    for (x, y) in [(15, 21), (20, 21), (25, 21)]:
        z.prop("planter", x, y)
    z.warp(18, 26, "aberystwyth_sanctuary", 5, 6, "up"); z.warp(24, 26, "aberystwyth_shop", 4, 5, "up")
    z.warp(48, 10, "aber_lab", 6, 7, "up")
    # --- station
    pf = station(z, 34, 32, 8, 3, "Aberystwyth Station")
    z.rect(33, 34, 1, 1, "#"); z.rect(42, 34, 1, 1, "#"); z.rect(43, 35, 10, 1, "!"); z.rect(34, 31, 8, 1, ":")
    z.rect(33, 31, 1, 4, "#")
    z.prop("bench", 36, 34); z.prop("lamp_post", 41, 34)
    rail_guard(z, 39, 34, ["Aberystwyth, end of the line for the Cambrian, start of the line for everything else.",
                           "Tickets? Hop on. The Wildlore rail runs to any town you have visited. Where to?"])
    # --- castle ruins on the south-west headland
    z.height(14, 35, 15, 10, 1)
    z.rect(14, 35, 15, 10, ".")
    z.building(15, 36, 5, 4, "castle", "Aberystwyth Castle")
    z.building(22, 37, 4, 3, "castle", show_label=False)
    z.building(15, 41, 4, 3, "castle", show_label=False)
    z.rect(14, 44, 15, 1, "^"); z.rect(14, 35, 15, 1, "R")
    z.rect(20, 41, 1, 1, "#"); path(z, [(13, 40), (21, 40)], "#", 1); path(z, [(21, 40), (21, 36)], "#", 1)
    z.rect(22, 41, 3, 1, "f")
    z.prop("rock", 24, 41); z.prop("rock", 27, 38); z.prop("standing_stone", 25, 42, variant=2); z.prop("bench", 23, 40)
    z.sign(21, 35, "ABERYSTWYTH CASTLE. Edward I, 1277. Blown up after the Civil War. A very old ruin with a very good sea view.")
    # --- harbour
    z.rect(35, 38, 17, 6, "~"); z.rect(34, 37, 19, 1, "s"); z.rect(34, 38, 1, 6, "s"); z.rect(52, 38, 1, 6, "s")
    z.rect(33, 37, 1, 8, ":")
    z.prop("boat", 38, 40, variant=1); z.prop("boat", 45, 41, variant=1); z.prop("boat", 49, 39); z.prop("buoy", 42, 39)
    z.prop("bollard", 34, 36); z.prop("bollard", 40, 37); z.prop("bollard", 46, 37)
    z.sign(33, 36, "ABERYSTWYTH HARBOUR. Tide times on the board. The board is optimistic.")
    z.rect(53, 36, 2, 8, "T")
    z.rect(43, 34, 8, 2, ".")
    z.prop("oak", 46, 35); z.prop("oak", 49, 34)
    # --- NPCs
    chat(z, "cliff_op", "villager_3", 18, 15, "Railway Operator",
         ["Aberystwyth Cliff Railway, 1896. Longest electric cliff railway in Britain.",
          "Two cars, one cable, balanced like a see-saw. The car going up pulls the car coming down. Physics!"], "down", "still")
    chat(z, "ice_cream", "villager_1", 44, 28, "Ice Cream Seller",
         ["Mint choc chip, Welsh honey or 99 with a flake. Pick quickly, a seagull is already looking.",
          "Last Tuesday one took a whole cone out of a toddler's hand. Now it has a regular spot. Business model."], "down", "still")
    chat(z, "starling_man", "birdwatcher", 8, 25, "Starling Watcher",
         ["Come back in winter at dusk. Thousands of starlings roost under the Royal Pier.",
          "They swirl like smoke and then, whoosh, they all vanish under the boards. Best free show in Wales."], "right", "still")
    chat(z, "student_aber", "student", 41, 17, "Student",
         ["It's the Old College, the first building of the university. Gothic revival, with a courtyard and echoes.",
          "I came for the degree. I stayed for the cliff railway. Don't tell my tutor."], "down", "wander")
    chat(z, "librarian", "villager_4", 48, 19, "Librarian",
         ["The National Library of Wales gets a free copy of every book published in the UK. It's called legal deposit.",
          "It's lovely. It's also heavy. The staff have excellent arms."], "left", "still")
    chat(z, "fisher_aber", "angler", 38, 36, "Harbour Angler",
         ["Aber is short for 'mouth of the river'. Ystwyth plus aber. Aberystwyth. See?",
          "Rivers meet the sea here. I meet the fish less often."], "down", "still")
    chat(z, "prom_walker", "villager_5", 11, 20, "Promenade Walker",
         ["Kicking the Bar is a tradition. You walk the whole prom and kick the railing at the far end.",
          "Students do it in Freshers' week. Beginners kick it in the wrong direction, usually."], "down", "wander")
    # --- tall grass patch and wild table
    z.rect(26, 40, 3, 4, ","); z.rect(23, 4, 2, 2, ",")
    wild(z, [("chipgull", 30, 32, 100, {})])
    z.d["edges"] = {"north": {"to": "cambrian_coast", "offset": 0}, "south": {"to": "pembroke_coast", "offset": 0}}
    z.d["spawn"] = [31, 28]
    seal_ns(z, 30, 32, True, True)
    z.save(OUT + "/aberystwyth.json")
    sanctuary(OUT, "aberystwyth", "Aberystwyth", (18, 27))
    shop(OUT, "aberystwyth", "Aberystwyth", (24, 27))
    nurse("aberystwyth", ["Welcome to the Aberystwyth Sanctuary. Pop your team on the counter. Mind the starling feathers.",
                          "Cwtch them in for a minute, we'll have them right as rain.",
                          "All better! Don't be a stranger, and do wipe your feet. The sea comes in everywhere.",
                          "The Ark terminal's just here. It's been fine since the student unplugged it to charge a phone.",
                          "Right you are. Shout if anyone needs a plaster."])
    shopkeeper("aberystwyth", "Croeso! Snares, tea, and one very well travelled umbrella, which is mine.",
               "Hwyl fawr! Mind the seagulls. They've read your shopping list.")

    # ---------------------------------------------------------------- aber_lab
    lab = Z("aber_lab", "Wardstone Lab", 13, 10, fill="+", kind="interior", region="", music="town_wales", weather={})
    lab.d["stage"] = "town"
    lab.border("x", 1)
    lab.rect(1, 1, 11, 8, "+"); lab.rect(2, 4, 3, 1, "C"); lab.rect(8, 4, 3, 1, "C")
    lab.rect(5, 7, 3, 1, "|"); lab.set(6, 8, "D")
    lab.warp(6, 8, "aberystwyth", 48, 11, "down")
    lab.prop("bookshelf", 1, 1); lab.prop("bookshelf", 3, 1); lab.prop("bookshelf", 9, 1); lab.prop("bookshelf", 11, 1)
    lab.prop("potted_plant", 1, 7); lab.prop("potted_plant", 11, 7)
    lab.prop("standing_stone", 10, 2, variant=2); lab.prop("table", 3, 7)
    lab.prop("table", 9, 7)
    lab.npc(id="dr_hughes", sprite="dr_hughes", x=6, y=3, facing="down", move="still", script="dr_hughes")
    script("aber_lab", "dr_hughes", say("Dr Hughes", "Dr Anwen Hughes, Wardstone Lab. Placeholder: the story agent rewrites this."))
    chat(lab, "postgrad", "student", 3, 5, "Postgrad",
         ["I measure how loudly stones hum. It's a very small and very nerdy field.",
          "The hum goes up when a Warden walks by. I've a graph. The graph is rude."], "right", "still")
    chat(lab, "technician", "villager_4", 9, 5, "Technician",
         ["Dr Hughes used to share an office with Professor Garside at university. They argued about everything.",
          "They still do, on the phone, for hours. We take bets on who hangs up first."], "left", "still")
    lab.d["spawn"] = [6, 7]
    lab.save(OUT + "/aber_lab.json")
