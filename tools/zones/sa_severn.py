# severn_crossing (route), bath (town) and bath_baths (interior), Bath Sanctuary and Corner Shop.
from wcommon import *


def build(OUT):
    severn(OUT)
    bath(OUT)


def severn(OUT):
    W, H = 72, 40
    z = Z("severn_crossing", "Severn Crossing", W, H, kind="route", region="south_england", music="route_coast",
          weather={"clear": 22, "sunshine": 12, "drizzle": 24, "gale": 22, "fog": 12, "downpour": 8})
    z.d["stage"] = "coast"
    z.legend["m"] = {"tile": "tall_grass", "colour": "#7b6a55", "prop": "none"}     # estuary mud
    z.legend["d"] = {"tile": "sand", "colour": "#8a7a62"}                            # firm mud
    z.rect(0, 0, W, H, "$")
    z.rect(0, 0, 17, H, "."); z.rect(55, 0, 17, H, ".")
    z.rect(17, 0, 1, H, "w"); z.rect(54, 0, 1, H, "w")
    z.border("T", 2, gaps=[(0, 20, 2, 3), (70, 20, 2, 3)])
    z.scatter(0, 0, 17, H, "P", 14, 2, only="T"); z.scatter(55, 0, 17, H, "P", 14, 3, only="T")
    # mudflats: broad walkable shores either side of the bridge
    for (x0, x1) in [(10, 22), (49, 60)]:
        for (y0, y1) in [(3, 17), (26, 38)]:
            for y in range(y0, y1):
                for x in range(x0, x1):
                    if z.g[y][x] in "$w.":
                        z.set(x, y, "m" if (x + y * 3) % 5 else "d")
    # sandbank islands reached by causeways off the bridge
    z.rect(30, 8, 5, 6, "m"); z.rect(42, 27, 9, 5, "m")
    z.rect(32, 14, 1, 6, "s"); z.rect(46, 23, 1, 4, "s")
    z.set(32, 13, "m"); z.set(46, 27, "m")
    # ---- the old bridge: a raised deck over rows 19..23 with parapets
    z.rect(0, 20, 72, 3, "=")
    z.rect(16, 19, 40, 1, "W"); z.rect(16, 23, 40, 1, "W")
    z.rect(2, 19, 14, 1, ":"); z.rect(2, 23, 14, 1, ":"); z.rect(56, 19, 14, 1, ":"); z.rect(56, 23, 14, 1, ":")
    z.height(18, 19, 2, 5, 1); z.height(20, 19, 34, 5, 2); z.height(52, 19, 2, 5, 1)
    z.set(32, 19, "="); z.set(46, 23, "=")
    z.height(32, 14, 1, 5, 1); z.height(46, 24, 1, 3, 1)
    # lay-by mid-span
    z.rect(34, 18, 6, 7, "="); z.height(34, 18, 6, 7, 2)
    z.rect(34, 17, 6, 1, "W"); z.rect(34, 25, 6, 1, "W")
    for (x, y) in [(33, 18), (40, 18), (33, 24), (40, 24)]:
        z.set(x, y, "W")
    z.prop("bench", 36, 18); z.prop("bench", 37, 24)
    for x in range(22, 52, 6):
        if x not in (34,):
            z.prop("lamp_post", x, 19) if z.g[19][x] == "W" else None
            z.prop("lamp_post", x, 23) if z.g[23][x] == "W" else None
    for x in (24, 30, 48):
        z.prop("lamp_post", x, 19); z.prop("lamp_post", x, 23)
    # toll plaza on the west bank
    z.rect(6, 17, 10, 7, "=")
    z.rect(6, 17, 10, 1, ":"); z.rect(6, 23, 10, 1, ":")
    z.building(8, 14, 3, 3, "white_render", "Toll Office")
    z.building(8, 24, 3, 3, "white_render", show_label=False)
    z.building(12, 14, 3, 3, "stone", "Cash Only")
    z.building(12, 24, 3, 3, "stone", show_label=False)
    for x in (7, 11, 15):
        z.prop("bollard", x, 18); z.prop("bollard", x, 22)
    z.prop("lamp_post", 6, 19); z.prop("lamp_post", 6, 23)
    z.sign(5, 19, "SEVERN BRIDGE. Opened 1966 by the Queen, with a 988 m main span. TOLLS ABOLISHED 17 DEC 2018. This booth now collects dust and dad jokes.")
    z.sign(55, 19, "WELCOME TO ENGLAND. Speed limit 50 on the bridge. Wind limit: your hat.")
    z.sign(38, 19, "THE SECOND SEVERN CROSSING, 1996, a cable-stayed bridge a little further down the river. The Severn has one of the biggest tides in the world, about 14 m. The mud knows.")
    z.sign(16, 13, "SOFT MUD. Estuary tides rise faster than you can run. Please don't feed the waders. They're on a strict diet of worm.")
    z.prop("lighthouse", 31, 9); z.prop("boat", 40, 4, variant=1); z.prop("boat", 20, 33, variant=1)
    z.prop("buoy", 28, 34); z.prop("buoy", 46, 7, variant=1); z.prop("boat", 58, 3, variant=1)
    scatter_props(z, "rock", 11, 4, 12, 13, 8, 4, avoid=("d", "m"))
    scatter_props(z, "rock", 49, 27, 11, 11, 8, 5, avoid=("d", "m"))
    scatter_props(z, "bush", 2, 2, 8, 36, 14, 6, avoid=(".",))
    scatter_props(z, "bush", 60, 2, 10, 36, 14, 7, avoid=(".",))
    z.rect(3, 4, 5, 5, ","); z.rect(4, 29, 6, 5, ","); z.rect(62, 5, 6, 5, ","); z.rect(62, 28, 7, 6, ",")
    z.rect(3, 4, 5, 1, "f"); z.rect(62, 28, 7, 1, "f")
    path(z, [(7, 17), (7, 10), (12, 10)], "#", 1); path(z, [(7, 26), (7, 32), (12, 32)], "#", 1)
    path(z, [(60, 19), (60, 10), (56, 10)], "#", 1); path(z, [(62, 24), (62, 30), (57, 30)], "#", 1)
    # wading birds as scenery
    for (sp, x, y, mv) in [("stalklet", 20, 12, "wander"), ("chipgull", 14, 6, "still"), ("stalklet", 52, 32, "wander"),
                           ("chipgull", 56, 14, "still"), ("cranelet", 31, 11, "still"), ("stalklet", 46, 29, "wander")]:
        z.npc(id="bird_%s_%d" % (sp, x), sprite="creature:" + sp, x=x, y=y, facing="down", move=mv, script="wader")
    script("severn_crossing", "wader", say("Wader", "It stares into the mud with the confidence of a bird who has never once been wrong about worms."))
    chat(z, "toll_ghost", "villager_3", 7, 20, "Ex Toll Collector",
         ["Twenty-three years in that booth. 'Seventy pence, please, ta.' Now it's free and I've nothing to say to people.",
          "They put a plaque up when the tolls ended. It says 'thank you'. I take it personally."], "right", "still")
    chat(z, "mud_watcher", "birdwatcher", 56, 12, "Wader Watcher",
         ["The Severn estuary hosts tens of thousands of wading birds in winter: dunlin, redshank, curlew, the lot.",
          "The mud looks like nothing. It's actually a five-star buffet. Mind your boots."], "down", "still")
    chat(z, "bridge_cyclist", "jogger", 44, 21, "Bridge Runner",
         ["It's over a mile of bridge. You can run it. The wind does half the work and half the swearing.",
          "In a gale they close it to high-sided lorries. In a bad gale, to me. I've been refused entry twice."], "left", "wander")
    chat(z, "sailor_sev", "sailor", 11, 28, "Bay Pilot",
         ["The Severn bore is a wave that rolls up the river on big spring tides. Surfers ride it for miles.",
          "My job is to avoid it. The surfers' job is the reverse. We nod politely."], "right", "still")
    chat(z, "motorist", "villager_6", 66, 21, "Motorist",
         ["Two countries in two minutes. You'd think the sat-nav would say something. Mine says 'recalculating'.",
          "Service station on the English side. I had a pasty. It was not a Cornish one. I checked."], "left", "wander")
    trainer(z, "severn_birder", "Birdwatcher Rosalind", "Birdwatcher", "birdwatcher", [("clawcastle", 37), ("bayrunner", 36), ("murmurant", 37)],
            14, 10, "left", ["Shh! I'm counting redshanks. I've got to 4,000 and you've just startled the 4,001st."],
            "Oh, you've ruined my tally. Not a bad battle.", "Four thousand and one. I'll have to start again.", 880)
    trainer(z, "severn_angler", "Angler Dennis", "Angler", "angler", [("greyhaul", 37), ("pierlord", 36), ("severnshock", 37)],
            52, 30, "right", ["Eels, flounders, shad, even a salmon once. And now, a Keeper's apprentice."],
            "Landed. You're a fine catch.", "The best bait here is patience. The second best is a pasty.", 900)
    trainer(z, "severn_surfer", "Surfer Kerensa", "Surfer", "surfer", [("petrelash", 37), ("stormswift", 38), ("bayrunner", 37)],
            41, 20, "down", ["Waiting for the Severn bore! Biggest river wave in Britain. Hold my board while I fight you."],
            "Wipeout. Total wipeout.", "The bore comes in on big tides. The rest of the time I just look moody.", 940)
    trainer(z, "severn_warden", "Warden Toby", "Warden", "warden_grunt", [("pierlord", 37), ("stormswift", 37), ("greyhaul", 36)],
            12, 21, "right", ["Welcome to the Gateway Experience! Today's fee is a fiver. Cash only. Booth's that way."],
            "Refund requested? Denied. But well fought.", "The tolls went. The fee for standing here did not.", 860)
    z.d["edges"] = {"west": {"to": "cardiff", "offset": 0}, "east": {"to": "bath", "offset": 0}}
    z.d["spawn"] = [4, 21]
    wild(z, [("clawcastle", 36, 38, 18, {}), ("greyhaul", 36, 37, 14, {"time": ["dawn", "day"]}),
             ("stormswift", 37, 38, 16, {"weather": ["gale", "drizzle"]}), ("murmurant", 36, 38, 14, {"time": ["dusk", "dawn"]}),
             ("severnshock", 37, 38, 14, {"weather": ["downpour", "drizzle", "fog"]}), ("pierlord", 36, 38, 14, {"time": ["day"]}),
             ("bayrunner", 37, 38, 12, {"time": ["day", "dawn"], "weather": ["clear", "sunshine"]}),
             ("wessexwyrm", 38, 38, 4, {"weather": ["gale"], "time": ["dusk", "night"]}), ("petrelash", 36, 38, 10, {"time": ["night"]})])
    wild(z, [("bayrunner", 36, 38, 25, {}), ("greyhaul", 36, 38, 25, {}), ("clawcastle", 37, 38, 20, {}),
             ("petrelash", 36, 38, 15, {"weather": ["gale", "downpour"]}), ("pierlord", 36, 37, 15, {})], "water")
    z.save(OUT + "/severn_crossing.json")


def bath(OUT):
    W, H = 60, 48
    z = Z("bath", "Bath", W, H, kind="town", region="south_england", music="town_city",
          weather={"clear": 28, "sunshine": 20, "drizzle": 30, "fog": 12, "downpour": 6, "frost": 4})
    z.d["stage"] = "spa_interior"; z.d["town_id"] = "bath"
    z.border("T", 2, gaps=[(0, 20, 2, 3), (58, 20, 2, 3)])
    z.scatter(0, 0, W, H, "P", 25, 2, only="T")
    # high street
    z.rect(0, 20, 60, 3, "="); z.rect(2, 19, 56, 1, ":"); z.rect(2, 23, 56, 1, ":")
    for x in (6, 14, 22, 30, 38, 54):
        z.prop("lamp_post", x, 19)
    for x in (10, 26, 34, 52):
        z.prop("lamp_post", x, 23)
    z.prop("phone_box", 4, 19); z.prop("post_box", 56, 23); z.prop("bench", 18, 19); z.prop("bench", 28, 23)
    # River Avon with Pulteney Bridge (shops on the bridge)
    z.rect(44, 3, 6, 42, "~")
    z.rect(43, 3, 1, 42, "s"); z.rect(50, 3, 1, 42, "s")
    z.rect(44, 19, 6, 5, ":"); z.rect(44, 20, 6, 3, "=")
    z.building(44, 16, 6, 3, "cream_render", "Pulteney Bridge Shops")
    z.building(44, 24, 6, 3, "cream_render", "Pulteney Bridge Tea Rooms")
    z.rect(43, 19, 1, 5, ":"); z.rect(50, 19, 1, 5, ":")
    z.rect(44, 31, 6, 1, "w")                       # the weir
    for (x, y, v) in [(46, 8, 0), (47, 37, 0), (45, 42, 0)]:
        z.prop("canal_boat", x, y, variant=v)
    z.prop("bench", 42, 28); z.prop("bench", 51, 10); z.prop("lamp_post", 42, 12); z.prop("lamp_post", 51, 33)
    z.sign(42, 24, "PULTENEY BRIDGE. Robert Adam, 1774. One of very few bridges in the world lined with shops. Wander over and buy a fudge.")
    # ---- Royal Crescent, a Georgian arc on a lawn hill
    z.height(2, 2, 28, 11, 2); z.height(2, 13, 28, 1, 1)
    z.rect(2, 2, 28, 12, ".")
    for i, (x, y) in enumerate([(3, 8), (8, 6), (13, 5), (18, 6), (23, 8)]):
        z.building(x, y, 5, 3, "terrace", "Royal Crescent" if i == 2 else None, show_label=(i == 2))
    z.rect(2, 11, 28, 2, "f"); z.rect(5, 12, 22, 1, ".")
    z.rect(5, 3, 22, 1, "H")
    z.rect(9, 13, 4, 6, ":")
    scatter_props(z, "oak", 3, 11, 26, 2, 7, 3, avoid=(".", "f"))
    z.prop("bench", 8, 12); z.prop("bench", 20, 12); z.prop("lamp_post", 14, 11); z.prop("lamp_post", 6, 11); z.prop("lamp_post", 25, 11)
    z.sign(8, 14, "THE ROYAL CRESCENT. 30 houses in one sweeping curve, 1767 to 1774. The lawn drops away in a ha-ha, a hidden ditch that keeps the cows off without spoiling the view.")
    # ---- Abbey, churchyard and Roman Baths
    z.building(32, 9, 12, 9, "cathedral", "Bath Abbey", door=5)
    z.rect(30, 18, 14, 2, ":")
    z.prop("statue", 31, 18); z.prop("bench", 40, 18); z.prop("planter", 34, 18); z.prop("planter", 41, 18)
    z.sign(38, 19, "BATH ABBEY. Founded 757, rebuilt in the 1500s. 'The Lantern of the West' for its huge windows. The ladders carved on the front come from a bishop's dream of angels.")
    z.building(31, 25, 12, 6, "stone", "Roman Baths", door=5)
    z.warp(36, 30, "bath_baths", 11, 13, "up")
    z.rect(28, 23, 16, 1, ":"); z.rect(28, 24, 3, 11, ":"); z.rect(28, 31, 17, 4, ":")
    z.prop("lamp_post", 30, 32); z.prop("lamp_post", 43, 32); z.prop("bench", 34, 32); z.prop("bench", 39, 32)
    z.prop("statue", 36, 33)
    z.sign(35, 31, "THE ROMAN BATHS. Sulis Minerva's temple, nearly 2,000 years old. About a million litres of 46 degree spring water a day. Please do not drink the green one.")
    # ---- Sanctuary, Corner Shop, high street
    z.building(18, 14, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.building(25, 14, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(21, 17, "bath_sanctuary", 5, 6, "up"); z.warp(27, 17, "bath_shop", 4, 5, "up")
    z.rect(18, 18, 12, 1, ":")
    z.building(5, 26, 8, 4, "terrace", "Sally Lunn's"); z.building(16, 26, 6, 4, "cream_render", "Jolly's Tea Rooms")
    z.building(3, 14, 5, 4, "cream_render", show_label=False)
    # station (south-west)
    z.building(4, 33, 10, 2, "station", "Bath Spa Station", door=4)
    z.rect(4, 35, 10, 1, "_"); z.rect(3, 36, 12, 1, "!")
    z.d["station"] = {"x": 8, "y": 35}
    z.rect(3, 24, 1, 12, "#"); z.rect(3, 35, 1, 1, "#"); z.rect(14, 35, 1, 1, "#"); z.rect(14, 24, 1, 12, ":")
    z.rect(3, 32, 12, 1, ":")
    z.prop("bench", 6, 35); z.prop("lamp_post", 12, 35)
    rail_guard(z, 10, 35, ["Bath Spa. Our platforms are Georgian. Our delays are timeless.",
                           "Hop aboard. The Wildlore rail runs to any town you have visited. Where to?"])
    # ---- Thermae Spa and the east bank
    z.building(52, 28, 5, 5, "white_render", "Thermae Spa")
    z.rect(51, 25, 7, 3, "f")
    z.rect(52, 5, 5, 12, ","); z.rect(51, 5, 1, 12, ".")
    z.prop("bench", 54, 26); z.prop("oak", 53, 10); z.prop("oak", 55, 14)
    z.sign(56, 26, "THERMAE BATH SPA. A rooftop pool of natural hot spring water at about 33 degrees, open to the sky. Britain's only naturally hot springs rise right here in Bath.")
    # ---- south: water meadows and Victoria Park
    z.rect(3, 38, 38, 7, "."); z.rect(8, 39, 10, 4, ","); z.rect(26, 40, 9, 4, ","); z.rect(20, 37, 6, 1, "f")
    z.rect(3, 37, 38, 1, ":")
    scatter_props(z, "oak", 4, 38, 36, 7, 12, 8, avoid=(".",))
    scatter_props(z, "bush", 4, 38, 36, 7, 8, 9, avoid=(".",))
    z.prop("bench", 22, 38); z.prop("statue", 18, 38); z.prop("lamp_post", 5, 37); z.prop("lamp_post", 38, 37)
    z.sign(23, 37, "VICTORIA PARK. Opened in 1830 by the 11-year-old Princess Victoria. She was not allowed to run. You are.")
    z.sign(12, 38, "BATH'S HOT SPRINGS. Britain's only natural ones, three of them, rising at the Roman Baths. Cold water from every other tap. Be grateful.")
    path(z, [(30, 35), (30, 38)], ":", 1)
    chat(z, "roman_actor", "tour_guide", 33, 33, "Roman Legionary",
         ["Salve! I am Gaius Maximus, legionary. Er, volunteer. The cloak is itchy but I'm told it's authentic.",
          "The Romans called this place Aquae Sulis, the waters of Sulis. Sulis was a Celtic goddess the Romans blended with Minerva. Smart marketing."], "down", "still")
    chat(z, "bath_buns", "shopkeeper", 15, 31, "Bun Baker",
         ["A Sally Lunn bun! Big, round, brioche-y. Sally Lunn herself is said to have baked them here in the 1680s.",
          "You split them and fill them with cream or cheese. I was told never to say 'a dollop' about a thing this elegant."], "up", "still")
    chat(z, "abbey_verger", "villager_4", 37, 19, "Verger",
         ["Bath Abbey has 52 windows, so many that it's called the Lantern of the West.",
          "Look at the carved ladders on the front. Bishop Oliver King dreamed of angels climbing them. Health and safety was not consulted."], "down", "wander")
    chat(z, "austen_fan", "student", 12, 20, "Austen Reader",
         ["Jane Austen lived here from 1801 to 1806 and, honestly, disliked it. Then she wrote about it for the rest of her life.",
          "Northanger Abbey and Persuasion are both partly set in Bath. The Assembly Rooms are still lovely for the stroll and the eye contact."], "right", "wander")
    chat(z, "bridge_busker", "harpist", 41, 20, "Street Harpist",
         ["Do you take requests? I take coins. They don't wear the strings out as quickly.",
          "I busk by the bridge because the acoustics are marvellous. Also the fudge shop is next door."], "right", "still")
    chat(z, "crescent_resident", "villager_5", 15, 12, "Crescent Resident",
         ["The Royal Crescent is Grade I listed. We may paint the front doors any colour, as long as it's white.",
          "I've never counted the houses. They're all identical. You'd get lost trying."], "down", "wander")
    chat(z, "boat_hirer", "angler", 51, 18, "Punt Hirer",
         ["The Avon here is only knee-deep at the weir. Don't ask how I know.",
          "Pulteney Weir is a horseshoe. Every year a duck goes over it on purpose. The duck has better balance than me."], "left", "still")
    trainer(z, "bath_student", "Student Ottilie", "Student", "student", [("clawcastle", 38), ("severnshock", 37), ("murmurant", 38)],
            29, 26, "down", ["I'm reading Classics! 'Aquae Sulis' translates as 'the waters of Sulis'. I've done my homework."],
            "Alea iacta est. Which means I lost.", "I'm off to the cafe. The Latin can wait.", 900)
    trainer(z, "bath_guard", "Warden Piers", "Warden", "warden_grunt", [("stormswift", 38), ("pierlord", 37)],
            27, 36, "right", ["We're bottling the spring! Heritage Water. Four pounds a bottle. It tastes of 2,000 years and a bit of lime."],
            "I've not been paid for this. I'll write you a receipt anyway.", "It's not stolen. It's curated. Different thing entirely.", 860)
    z.d["edges"] = {"west": {"to": "severn_crossing", "offset": 0}, "east": {"to": "mendips", "offset": 0}}
    z.d["spawn"] = [30, 21]
    wild(z, [("pincray", 37, 38, 20, {}), ("sulisa", 38, 38, 6, {"weather": ["drizzle", "fog"]}), ("severnshock", 37, 38, 16, {}),
             ("murmurant", 37, 38, 16, {"time": ["dusk"]}), ("stormswift", 37, 38, 14, {"time": ["dawn", "day"]}),
             ("flittermouse", 36, 38, 14, {"time": ["night"]}), ("rillotter", 37, 38, 14, {})])
    wild(z, [("pincray", 37, 38, 40, {}), ("rillotter", 37, 38, 40, {}), ("sulisa", 38, 38, 8, {})], "water")
    z.save(OUT + "/bath.json")
    sanctuary(OUT, "bath", "Bath", (21, 18))
    shop(OUT, "bath", "Bath", (27, 18))
    nurse("bath", ["Welcome to the Bath Sanctuary. We're Georgian, so mind the draught from the sash windows. Pop your team on the counter.",
                   "One moment. Relax, there's cucumber water. It's not from the spring. We checked.",
                   "All done! They look better than the Royal Crescent. Don't tell the Crescent.",
                   "The Ark terminal. It was a Roman hypocaust once. Now it holds creatures. And dust.",
                   "Quite right. Take the waters, take the air, take a bun."])
    shopkeeper("bath", "Welcome! We stock snares, buns and one umbrella with a very good fan club.",
               "Do come again. And mind the cobbles, they've defeated better.")
    # ------------------------------------------------ the Roman Baths
    b = Z("bath_baths", "The Roman Baths", 24, 16, fill="+", kind="interior", region="", music="sanctuary", weather={})
    b.d["stage"] = "spa_interior"
    b.legend["g"] = {"tile": "water", "colour": "#4f9a58"}
    b.border("x", 1)
    b.rect(2, 2, 20, 12, ":")
    b.rect(7, 4, 10, 7, "g")
    b.rect(2, 2, 20, 1, "+"); b.rect(2, 13, 20, 1, "+")
    b.rect(2, 4, 3, 7, "+"); b.rect(19, 4, 3, 7, "+")
    b.set(11, 14, "D")
    b.warp(11, 14, "bath", 36, 31, "down")
    for x in (6, 9, 12, 15, 18):
        b.prop("standing_stone", x, 3, variant=x % 3)
        b.prop("standing_stone", x, 12, variant=(x + 1) % 3)
    for y in (5, 9):
        b.prop("standing_stone", 6, y, variant=y % 3); b.prop("standing_stone", 17, y, variant=(y + 1) % 3)
    b.prop("statue", 3, 3); b.prop("statue", 20, 3); b.prop("lamp_post", 4, 6); b.prop("lamp_post", 19, 6)
    b.prop("planter", 3, 12); b.prop("planter", 20, 12); b.prop("bench", 3, 7); b.prop("bench", 20, 7)
    b.sign(13, 12, "THE GREAT BATH. Lined with sheets of lead, almost 2,000 years old and still watertight. The water is green because of algae and tradition.")
    b.sign(4, 4, "THE SACRED SPRING. 46 degrees, a million litres a day, rain that fell thousands of years ago. Travellers tossed in coins and curses. Only coins today, please.")
    b.npc(id="baths_guide", sprite="tour_guide", x=12, y=11, facing="down", move="still", script="baths_guide")
    b.npc(id="baths_visitor", sprite="villager_2", x=3, y=9, facing="right", move="wander", script="baths_visitor")
    script("bath_baths", "baths_guide", say("Audio Guide",
           "Tablets cursing thieves were thrown into the spring: 'May he who stole my cloak lose his mind and his eyes.' Roman customer service.",
           "Roman pipes were made of lead, so please do not drink the water. The Romans did anyway. Hmm."))
    script("bath_baths", "baths_visitor", say("Visitor", "It's steaming! I thought the steam was a special effect. It's actually the spring. Brilliant."))
    b.d["spawn"] = [11, 13]
    b.save(OUT + "/bath_baths.json")
