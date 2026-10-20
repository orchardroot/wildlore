# Dover: the White Cliffs, the castle and its secret wartime tunnels (Operation Dynamo), the Western Heights,
# the port and the Channel. Town south of Canterbury, region south_east.
from se_common import *
from wcommon import _stand


def build(OUT):
    W, H = 64, 54
    zid = "dover"
    z = Z(zid, "Dover", W, H, kind="town", region=SE, music="town_north",
          weather={"clear": 26, "drizzle": 22, "gale": 18, "sunshine": 16, "fog": 12, "downpour": 6})
    z.d["stage"] = "coast"; z.d["town_id"] = "dover"
    z.legend.update({"g": DOWN_TURF, "k": CHALK, "q": SHORT})
    z.rect(0, 0, W, H, ".")
    z.border("T", 2, gaps=[(30, 0, 3, 2)])
    z.scatter(0, 0, W, 33, "P", 8, 81, only="T")
    # --- heights: the Western Heights, the Dour valley, the castle hill and the cliffs
    for y in range(H):
        for x in range(W):
            if y < 33:
                z.hg[y][x] = (3 if x < 10 else 2 if x < 14 else 0) if x < 38 else min(5, x - 37)
            else:
                z.hg[y][x] = 0 if x < 38 else 5
    for y in range(2, 28):
        for x in range(2, 14):
            z.set(x, y, "g")
    for y in range(2, 33):
        for x in range(38, W - 2):
            z.set(x, y, "g")
    # the White Cliffs and the sea beneath them
    for x in range(38, W):
        for y in range(33, 36):
            z.set(x, y, "k")
        for y in range(36, H):
            z.set(x, y, "$"); z.hg[y][x] = 0
    for y in range(24, 33):
        for x in range(42, W - 2):
            if (x * 7 + y * 3) % 5:
                z.set(x, y, "q")
    # --- the London road down the valley, and the town
    z.rect(30, 0, 3, 35, "=")
    station(z, 17, 5, 8, 4, "Dover Priory")
    z.prop("buffer_stop", 16, 8); z.prop("buffer_stop", 25, 8)
    z.rect(25, 7, 5, 1, ":")
    rail_guard(z, 23, 7, ["Dover Priory. Trains to London, Canterbury and everywhere you've been. Boats are down the hill.",
                          "All aboard! Mind the gap, and the seagulls, in that order."], facing="left")
    z.rect(15, 10, 15, 23, ":")
    z.building(16, 11, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(19, 14, "dover_sanctuary", 5, 6, "up")
    z.building(23, 11, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(25, 14, "dover_shop", 4, 5, "up")
    z.prop("lamp_post", 22, 16); z.prop("bench", 18, 18); z.prop("bench", 26, 18); z.prop("market_stall", 22, 20, variant=1)
    z.building(15, 23, 7, 3, "stone", "Dover Museum", door=3)
    z.building(23, 23, 6, 3, "flint_cottage", "Roman Painted House", door=2)
    z.building(15, 28, 7, 3, "weatherboard", "The White Horse Inn", door=3)
    z.building(23, 28, 6, 3, "weatherboard", "Castle Street")
    z.building(3, 28, 10, 3, "regency", "Waterloo Crescent")
    plaque(z, 22, 22, "dover_market_square", "The Market Square",
           "Dover's market square has seen Romans, Saxons, Normans, smugglers and day-trippers. Under it lie the remains of the Roman port of Dubris, whose harbour sat at the mouth of the River Dour where the town is now.")
    plaque(z, 29, 26, "dover_painted_house", "The Roman Painted House",
           "Part of a Roman hotel for officials crossing the Channel, built about 200 AD and found in 1970. Its walls still carry painted plaster, the best preserved of their kind in Britain, and it has underfloor heating. The Romans would have hated to be cold in Kent too.")
    plaque(z, 22, 27, "dover_bronze_age_boat", "The Dover Bronze Age Boat",
           "In 1992 roadworkers found a boat buried in the mud, made of oak planks sewn together with yew withies, about 3,500 years old. It is one of the oldest seagoing boats ever found, and it may have crossed the Channel. It is in the museum now, in a very large glass case.")
    plaque(z, 14, 31, "dover_white_horse", "The White Horse",
           "One of Dover's oldest pubs. By tradition, swimmers who make it across the Channel sign their names on its walls and ceiling, and there are thousands now, from all over the world. You can only sign if you've swum it. Being thirsty does not count.")
    # --- the seafront, the quay, the harbour and its piers
    z.rect(2, 33, 36, 2, "=")
    z.rect(2, 35, 36, 6, ":")
    z.rect(2, 41, 36, 13, "$")
    z.rect(2, 41, 36, 1, "w")
    z.rect(3, 41, 2, 11, ":"); z.rect(18, 41, 2, 8, ":"); z.rect(36, 35, 2, 16, ":")
    z.prop("lighthouse", 4, 51); z.prop("lighthouse", 37, 50)
    z.building(24, 36, 10, 3, "white_render", "Ferry Terminal", door=4)
    for (x, y) in [(10, 45), (26, 47), (31, 44), (12, 50), (28, 51)]:
        z.prop("boat", x, y, variant=(x // 3) % 2)
    for x in range(6, 36, 5):
        z.prop("bollard", x, 40)
    z.prop("statue", 10, 36, variant=0)
    plaque(z, 12, 36, "dover_captain_webb", "Captain Matthew Webb",
           "On 24 August 1875 Captain Webb walked into the sea here, covered in porpoise oil, and swam to France: the first person to swim the Channel without help. It took him nearly 22 hours, because the tide kept pushing him back. The memorial on the seafront remembers him.")
    plaque(z, 35, 39, "dover_port", "The Port of Dover",
           "The narrowest crossing to the continent, only 21 miles to Cap Gris-Nez, and the busiest ferry port in Britain, with millions of passengers and lorries a year. On a clear day you can see France from the cliffs, and France can see you.")
    plaque(z, 8, 34, "dover_cinque_ports", "The Cinque Ports",
           "Dover was one of the Cinque Ports, said 'sink', a league of Kent and Sussex harbours that gave the medieval kings ships in return for privileges. Their head is the Lord Warden of the Cinque Ports, an honour given to people such as Winston Churchill and the Queen Mother.")
    # --- the Western Heights
    for (x, y) in [(4, 6), (6, 5), (8, 6), (4, 9), (8, 9)]:
        z.prop("rock", x, y, variant=1)
    z.rect(4, 7, 5, 2, ":")
    plaque(z, 10, 12, "dover_western_heights", "The Western Heights",
           "Huge forts dug into the hill against a French invasion that never came, begun during the Napoleonic Wars. The Grand Shaft is a triple spiral staircase cut down through the cliff in 1806 so soldiers could reach the town fast: three staircases, twisting round each other.")
    z.rect(13, 12, 2, 1, "#")
    # --- the castle on its hill, the Roman lighthouse and the way to the tunnels
    z.rect(33, 17, 16, 1, "#")
    z.rect(48, 12, 1, 6, "#")
    z.building(43, 5, 12, 7, "castle", "Dover Castle", door=6)
    z.building(39, 7, 2, 2, "round_tower", "Roman Pharos")
    z.rect(48, 18, 1, 7, "#"); z.rect(48, 24, 8, 1, "#")
    z.building(52, 22, 4, 2, "stone", "Secret Wartime Tunnels", door=1)
    plaque(z, 47, 13, "dover_castle", "Dover Castle",
           "Called the Key of England: whoever held it held the shortest way in. Henry II built the great keep in the 1180s, and the castle was garrisoned for over 800 years, right up to 1958. It has seen sieges, Napoleonic barracks and the Second World War.")
    plaque(z, 41, 10, "dover_pharos", "The Roman Pharos",
           "Next to the castle church stands a Roman lighthouse, built in the first or second century AD to guide ships into Dubris. It is one of the tallest Roman structures left standing in Britain. Its partner on the Western Heights has all but gone.")
    plaque(z, 56, 24, "dover_operation_dynamo", "Operation Dynamo",
           "In May 1940 the British army was trapped at Dunkirk. From tunnels in these cliffs, Vice-Admiral Bertram Ramsay planned the evacuation, Operation Dynamo. Between 26 May and 4 June about 338,000 soldiers were brought home, helped by hundreds of little ships: ferries, fishing boats, pleasure steamers and private yachts.")
    plaque(z, 58, 4, "dover_bleriot", "Bleriot's Landing",
           "On 25 July 1909 Louis Bleriot flew across the Channel from Calais in his little monoplane and crash-landed in a meadow just north of the castle: the first flight across the sea between two countries. A memorial in the grass is shaped like his aeroplane.")
    plaque(z, 44, 31, "dover_white_cliffs", "The White Cliffs",
           "Chalk, up to 110 metres high, made from the limy skeletons of tiny sea algae that settled on a warm sea floor between about 100 and 66 million years ago. Fulmars and kittiwakes nest on the ledges, and peregrines hunt along them. For returning sailors and soldiers, they were the first sight of home.")
    plaque(z, 52, 27, "dover_bluebirds", "Bluebirds over the White Cliffs?",
           "In 1942 Vera Lynn sang that there would be bluebirds over the White Cliffs of Dover. It is a beautiful song, and there are no bluebirds in Britain at all: they are American birds, and the song was written by Americans. Swallows, perhaps.")
    # --- NPCs
    chat(z, "dv_ferry_fan", "villager_1", 34, 34, "Lorry Spotter",
         ["Ten thousand lorries a day through here, some days. Strawberries from Spain, cheese from France, car parts from everywhere.",
          "When the port stops, Kent stops. They park the lorries on the motorway. Operation Stack, they called it. Nobody enjoyed it."], "down", "wander")
    chat(z, "dv_birder", "birdwatcher", 50, 28, "Cliff Birder",
         ["Kittiwakes! Hear them? They say their own name. Kitti-waaake. There are thousands on these cliffs every spring.",
          "And there goes a fulmar: stiff wings, glides like a little albatross. They can spit a nasty oil at you if you get too near the nest. Ask me how I know."], "left", "still")
    chat(z, "dv_old_soldier", "villager_2", 21, 21, "Old Gunner",
         ["My dad was on a little ship at Dunkirk. A Thames pleasure boat, the sort you'd take to Margate for the day. He went back four times.",
          "When he got home he never talked about it, except once, to say the beach went on for ever."], "down", "still")
    # trainers
    tdef("dv_trucker", "Lorry Driver Gaz", "Lorry Driver", "villager_1", [("samsonian", 94), ("steelheart", 94), ("tubemole", 95)],
         ["Forty tonnes of Brie and a two-hour wait for the ferry. I'm in no hurry. Let's have a go."],
         "Jack-knifed. Fair play.", "If you ever see the queue for the ferry going back to the motorway, bring sandwiches. Bring a lot.", 4100)
    tnpc(z, "dv_trucker", 12, 37, "right")
    tdef("dv_swimmer", "Channel Swimmer Ffion", "Channel Swimmer", "surfer", [("orcaird", 94), ("bayrunner", 94), ("selkie", 95)],
         ["Twenty-one miles, as the gull flies. Further as the tide pushes. I'm training for it: cold water, goose fat and a lot of singing."],
         "Out-swum on dry land. That's a first.", "The rules say no wetsuit, just a costume, a cap and goggles. And grease. So much grease.", 4100)
    tnpc(z, "dv_swimmer", 20, 39, "up")
    tdef("dv_ranger", "Ranger Priya", "Cliff Ranger", "hiker", [("flintwarden", 95), ("stoopfalcon", 94), ("polartern", 94)],
         ["Stay back from the edge! The cliffs crumble without warning. Now then, shall we have a nice safe battle well away from it?"],
         "Lovely. Now please, back from the edge.", "Exmoor ponies graze the clifftop for us, eating the coarse grass so the wildflowers can grow. They work cheaper than I do.", 4100)
    tnpc(z, "dv_ranger", 58, 27, "left")
    # the secret tunnels (q_southeast_tunnels_*)
    q = "q_southeast_tunnels_"
    script(zid, "dv_tunnel_guide", [
        IF(q + "done", say("Tunnel Guide", "Thanks for helping out. Ramsay's map is back up, and the Harbourmaster's buying the teas."), [
            IF(q + "started", say("Tunnel Guide", "In you go. Find the signaller on duty, then Admiral Ramsay's operations room at the back. Mind your head: the Napoleonic diggers were short."),
               say("Tunnel Guide", "{greeting} These tunnels were dug into the chalk in the Napoleonic Wars as barracks. In 1940 the Navy took them over.",
                   "It was here, in the cliffs, that Vice-Admiral Ramsay planned the Dunkirk evacuation. We're opening the operations room again, but the signals post has gone quiet and the map needs putting back.",
                   "Give us a hand? It's dark, so keep a light handy. Find our signaller first: she won't let anyone past without a challenge.") + [setf(q + "started")])])])
    _stand(z, 55, 25)
    z.npc(id="dv_tunnel_guide", sprite="tour_guide", x=55, y=25, facing="left", move="still", script="dv_tunnel_guide", name="Tunnel Guide")
    # --- interiors
    door_to(z, OUT, zid, "dover_castle", "Dover Castle Keep", (49, 11), "castle", [
        talker("dover_castle", "dc_herald", "tour_guide", 7, 3, "Herald", [
            "Henry II built this Great Tower in the 1180s, partly to impress the pilgrims landing at Dover on their way to Becket's tomb. It worked. It still does.",
            "The walls are up to six metres thick. In 1216 French invaders under Prince Louis besieged the castle for months and undermined the north gate. It held. Just."], "down"),
        talker("dover_castle", "dc_cook", "shopkeeper", 2, 5, "Castle Cook", [
            "We've set the hall as it was for a royal visit: bright painted walls, hangings, gold plate. Medieval people didn't live in grey stone if they could help it."], "right")],
        w=15, h=10, extra_props=[P("fireplace", 7, 1), P("wall_picture", 4, 1, walk=True, variant=2), P("wall_picture", 10, 1, walk=True, variant=1), P("brazier", 1, 2), P("brazier", 13, 2)])
    door_to(z, OUT, zid, "dover_museum", "Dover Museum", (18, 25), "museum", [
        talker("dover_museum", "dm_curator", "poet", 6, 2, "Curator", [
            "The boat behind me is about 3,500 years old: oak planks, sewn together with twisted yew, the gaps stuffed with moss and beeswax.",
            "It was found nine metres down when they were building a road in 1992. They had to cut it into pieces to lift it. The pieces are back together now. Mostly."], "down")],
        extra_props=[P("display_case", 5, 4), P("display_case", 7, 4), P("display_case", 2, 6), P("display_case", 10, 6)])
    door_to(z, OUT, zid, "dover_painted_house", "Roman Painted House", (25, 25), "museum", [
        talker("dover_painted_house", "ph_guide", "student", 6, 4, "Guide", [
            "These painted walls are about 1,800 years old. Red, yellow, green, with painted columns and plants. A hotel for important travellers, the Mansio, with heating under the floor.",
            "Later the Romans built a fort over it, and knocked the top off the walls to make room. That's what saved the bottoms: buried and forgotten."], "down")],
        extra_props=[P("wall_picture", 2, 1, walk=True, variant=0), P("wall_picture", 4, 1, walk=True, variant=1), P("wall_picture", 8, 1, walk=True, variant=2), P("wall_picture", 10, 1, walk=True, variant=0)])
    door_to(z, OUT, zid, "dover_white_horse", "The White Horse Inn", (18, 30), "cafe", [
        talker("dover_white_horse", "wh_landlord", "villager_4", 3, 1, "Landlord", [
            "Every name on these walls swam to France. Or from France: a few come the other way. We've had swimmers in their seventies, and teenagers, and a fella who did it there and back.",
            "First thing they want when they get back? A cup of tea, and a pen."], "down"),
        talker("dover_white_horse", "wh_swimmer", "surfer", 9, 4, "Swimmer", [
            "Sixteen hours. Jellyfish, a ferry wake, and a seagull that followed me the whole way. My name's up there, by the fire. Spelt wrong. I don't care."], "left")],
        extra_props=[P("wall_picture", 8, 1, walk=True, variant=1), P("fireplace", 10, 1)])
    harbour = [IF(q + "done", say("Harbourmaster", "Thousands of ships a year in and out of here, and every one of them will tell you about Dunkirk if you buy them a tea."), [
        IF(q + "2", say("Harbourmaster", "Ramsay's plan, back on the wall? Good. Let me tell you what happened next, from the harbour's side.",
                        "Day and night for nine days, ships came in here packed with soldiers, more than 200,000 of them landed at Dover alone. Trains took them inland from the quay, one after another.",
                        "Among them came the little ships, owned by ordinary people, some sailed by their owners. Many are still afloat. They fly a special flag, a St George's Cross with the arms of Dunkirk.",
                        "Here, take this. A Dover keepsake: a brooch with a bluebird on it. There are no bluebirds in Britain, but there are a lot of brooches.") +
           [setf(q + "3"), give("bluebird_brooch"), standing(3), setf(q + "done")],
           say("Harbourmaster", "The port's never quiet. Ferries to Calais and Dunkirk all day and all night. Dunkirk. Funny how a name stays with a place."))])]
    door_to(z, OUT, zid, "dover_terminal", "Ferry Terminal", (28, 38), "hall", [
        scripted("dover_terminal", "harbourmaster", "sailor", 7, 2, "Harbourmaster", harbour),
        talker("dover_terminal", "ft_family", "villager_3", 3, 5, "Holidaymaker", [
            "We're off to France for the day. Hypermarket, a baguette, back by teatime. The kids want to see the cliffs from the sea. So do I, honestly."], "right")],
        extra_props=[P("wall_map", 4, 1, walk=True), P("bench", 9, 5), P("bench", 10, 5)])
    tunnels(z, zid, OUT)
    sanctuary(OUT, zid, "Dover", (19, 15), music="sanctuary")
    shop(OUT, zid, "Dover", (25, 15))
    nurse(zid, ["Hello, love! Welcome to the Dover Sanctuary, last stop before France. Let's have a look at your team.",
                "On the counter with them. Sea air's very good for them, but so is a sit-down.",
                "All done! Fit for the crossing, if you were going. Which you're not. They don't do Sanctuaries in Calais, I asked.",
                "The Ark's over there. It's been to France twice. It didn't like the ferry.",
                "Mind how you go. Keep back from the cliff edge, and away from the lorries."])
    shopkeeper(zid, "Afternoon! Snares, tea, a sandwich for the ferry? Everything you need for a crossing, except a passport.",
               "Bon voyage! Well, not really. Ta-ra!")
    lo, hi = LV
    wild(z, [("flintling", lo, hi, 16, {}), ("flintwarden", hi, hi, 3, {"weather": ["gale"]}), ("peregrin", lo, hi, 8, {}),
             ("chipgull", lo, hi, 12, {}), ("ternlet", lo, hi, 8, {}), ("petrelash", lo, hi, 8, {"weather": ["gale", "drizzle"]}),
             ("kitelet", lo, hi, 6, {"time": ["day"]}), ("leveret", lo, hi, 8, {}), ("rooklet", lo, hi, 8, {}), ("starlet", lo, hi, 8, {}),
             ("chalkling", lo, hi, 6, {}), ("barnling", lo, hi, 6, {"time": ["night"]})])
    wild(z, [("chipgull", lo, hi, 18, {}), ("pupplash", lo, hi, 14, {}), ("gannetling", lo, hi, 12, {}), ("pinchkin", lo, hi, 14, {}),
             ("greyhaul", hi, hi, 6, {}), ("dolphlet", lo, hi, 8, {"time": ["day"]})], "water")
    z.d["edges"] = {"north": {"to": "canterbury", "offset": 10}}
    z.d["spawn"] = [31, 2]
    scale_zone(z)
    smooth_walk(z)
    finish(z)
    z.save(OUT + "/" + zid + ".json")


def tunnels(z, zid, OUT):
    """the Secret Wartime Tunnels: dark chalk passages, the signals post and Ramsay's operations room."""
    q = "q_southeast_tunnels_"
    from zlib import Z as ZZ
    t = ZZ("dover_tunnels", "Secret Wartime Tunnels", 23, 14, fill="x", kind="interior", region="", music="", weather={})
    t.d["dark"] = True
    t.legend["c"] = {"tile": "floor_tile", "colour": "#d8d2c0"}
    # the main passage, the side galleries and the operations room at the back
    t.rect(2, 9, 19, 3, "c")
    t.rect(3, 2, 3, 8, "c"); t.rect(17, 2, 3, 8, "c")
    t.rect(8, 2, 7, 4, "c"); t.rect(10, 6, 3, 3, "c")
    t.set(11, 12, "D")
    t.warp(11, 12, zid, 53, 24, "down")
    t.d["spawn"] = [11, 11]
    for (x, y) in [(2, 10), (20, 10), (3, 2), (19, 2)]:
        t.prop("lamp_post", x, y)
    t.prop("wall_map", 11, 2, walk=True); t.prop("table", 9, 3); t.prop("table", 13, 3); t.prop("clock", 14, 2, walk=True)
    t.prop("table", 4, 4); t.prop("kettle_table", 18, 4); t.prop("stacked_chairs", 19, 6)
    tdef("dv_signaller", "Wren Signaller Joan", "Wren", "wren", [("railspark", 95), ("severnshock", 95), ("stormswift", 95), ("flintwarden", 95)],
         ["Halt! Who goes there? Password? No? Then you'll have to prove you're not a spy the old-fashioned way."],
         "Message received and understood. You may pass.", "The Wrens ran the signals down here, round the clock: teleprinters, telephones, coded messages from the ships.", 4800)
    t.npc(**scripted("dover_tunnels", "signaller", "wren", 4, 7, "Wren Signaller Joan", [
        IF("trainer_dv_signaller", say("Wren Signaller Joan", TRN["dv_signaller"]["after"], "Admiral Ramsay's operations room is at the back. Go and see Mr Ellis there."), [
            IF(q + "started", TRN["dv_signaller"]["intro"] + [fight("dv_signaller"), IF("trainer_dv_signaller", [setf(q + "1")] + say("Wren Signaller Joan", "Ops room's at the back of the tunnel. Mind the step."))],
               say("Wren Signaller Joan", "Restricted area. Unless you're with the guide, I'm afraid I can't let you any further."))])], "right"))
    t.npc(**scripted("dover_tunnels", "ops_historian", "poet", 11, 4, "Mr Ellis", [
        IF(q + "2", say("Mr Ellis", "There it is, back on the wall: the Channel, the beaches, the routes the ships took. Thank you."), [
            IF(q + "1", say("Mr Ellis", "You got past Joan? Then help me pin the map up. There. The beaches at Dunkirk, the three routes across, Y, X and Z, dodging the German guns and the sandbanks.",
                            "Ramsay worked in a room just like this with a handful of staff, almost without sleep, for nine days. They hoped to rescue 45,000 men. They brought back about 338,000.",
                            "Take the news to the Harbourmaster at the ferry terminal. He likes to hear it told.") + [setf(q + "2")],
               say("Mr Ellis", "The operations room. Admiral Ramsay's desk stood here. There's a map that wants putting back up, if Joan lets you through."))])], "down"))
    t.npc(**talker("dover_tunnels", "tunnel_medic", "night_nurse", 18, 7, "Hospital Orderly", [
        "There was an underground hospital in these tunnels during the war, with an operating theatre. Wounded airmen and soldiers were brought straight in from the harbour.",
        "Electric lights, generators and miles of passages. A whole little town in the chalk."], "left"))
    t.save(OUT + "/dover_tunnels.json")
    z.warp(53, 23, "dover_tunnels", 11, 11, "up")
