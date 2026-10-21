# Wildlore 3.3 "Overseas", wave 33 agent 1: RAF Brize Norton, the hub the departures board flies from.
#
#   python3 tools/zones/overseas_hub.py        (from the repo root; then overseas_data.py for the plain data)
#
# One outdoor zone (brize_norton: the village with St Britius, the wire, the apron and the runway) and its rooms.
# It joins the Cotswolds' south side as a cul-de-sac, sign-posted, with RAF Police stopping you at the gap until
# you are the Champion (hide_if "champion"). Everything is scaled from par 95 like the territories it flies to.
from overseas_lib import *
from wcommon import _stand

TERR = "brize"          # plaque / flag prefix
QF = "q_overseas_brize_norton"
W, H = 88, 56


def brize():
    zid = "brize_norton"
    z = Z(zid, "RAF Brize Norton", W, H, kind="town", region="overseas_brize_norton", music="town_north",
          weather={"clear": 26, "sunshine": 18, "drizzle": 24, "fog": 12, "gale": 8, "downpour": 6, "frost": 6})
    z.d["stage"] = "town"
    z.d["scaled_floor"] = FLOOR
    z.legend.update({"g": {"tile": "grass", "colour": "#9db45a"}, "k": {"tile": "tall_grass", "colour": "#8aa34e"}})
    z.rect(0, 0, W, H, "g")
    z.border("H", 2, gaps=[(72, 0, 4, 2)])
    z.d["spawn"] = [66, 33]

    # ---- the lane down from the Cotswolds (the Burford road) and the village street
    path(z, [(72, 0), (72, 12)], "=", 4)
    z.rect(10, 8, 62, 1, ":")
    z.rect(10, 9, 62, 2, "=")
    z.sign(70, 3, "RAF BRIZE NORTON. The RAF's biggest station and the home of the Airbridge. Flights to the territories leave from the terminal: follow the road south. NORTH: the Cotswolds. Please do not feed the planespotters.")
    for x in range(14, 70, 8):
        z.prop("lamp_post", x, 7)

    # ---- the village of Brize Norton, outside the wire
    bld(z, 30, 2, 8, 6, "limestone_church", "St Britius Church", 4, "brize_norton_church")
    z.rect(30, 8, 8, 1, ":")
    plaque(z, 38, 8, TERR, "church", "St Britius Church",
           "The village church is dedicated to St Britius, or Brice, a fifth-century bishop of Tours, and has Norman origins. Its name is thought to have given the village its name, 'Brize' being a worn-down 'Brice'. Down the road, the airfield took the village's name when it opened in 1937.")
    for x in (12, 18, 44, 50, 56):
        bld(z, x, 2, 5 if x % 2 == 0 else 4, 4, "cotswold_cottage", show_label=False)
        z.rect(x + 2, 6, 1, 2, "#")
    for x in (14, 22, 30, 38, 46, 54):
        z.prop("planter", x, 11, variant=1)
    blob(z, 24, 5, 4, 2, "f", only=".", seed=3, jitter=0.3)
    z.sign(62, 7, "BRIZE NORTON VILLAGE. Please drive slowly: the geese have the right of way, and so have the Hercules.")
    plaque(z, 60, 7, TERR, "village", "Brize Norton Village",
           "Brize Norton is an Oxfordshire village of Cotswold-stone cottages that happens to have the largest station of the Royal Air Force over the hedge. The RAF opened the airfield in 1937. The village has learnt to stop and look up whenever a big grey aircraft goes over, and it goes over often.")

    # ---- the wire, with the Main Gate where the lane comes in
    z.rect(3, 12, 65, 1, "F")
    z.rect(80, 12, 5, 1, "F")
    bld(z, 68, 10, 4, 3, "raf_block", "Guardroom", show_label=True)
    bld(z, 76, 10, 4, 3, "raf_block", show_label=False)
    z.prop("bollard", 71, 13)
    z.prop("bollard", 76, 13)
    z.prop("flagpole", 71, 9, variant=6)
    z.prop("flagpole", 76, 9, variant=6)
    plaque(z, 76, 8, TERR, "est", "Station Brize Norton",
           "RAF Brize Norton is the largest station in the Royal Air Force. It is home to the RAF's air transport and air-to-air refuelling fleets, which means that when British troops, aid or post need to go a very long way, they usually start here. Its runway is just over 3 kilometres long, and the air stays remarkably busy.")

    # ---- the base: the road down to the forecourt, apron and runway
    path(z, [(72, 12), (72, 35)], "=", 4)
    z.rect(30, 30, 52, 6, ":")
    z.rect(8, 37, 70, 11, ":")
    z.rect(3, 49, 82, 3, "=")
    z.rect(3, 52, 82, 1, ":")
    z.rect(70, 36, 8, 12, ":")
    # the terminal, the tower, the Airbridge ops room, the NAAFI, the sanctuary and the heritage hangar
    bld(z, 56, 23, 14, 6, "raf_terminal", "Air Terminal", 7, "brize_norton_terminal")
    bld(z, 48, 24, 4, 5, "control_tower", "Control Tower", 1, "brize_norton_tower")
    bld(z, 37, 23, 10, 6, "raf_hangar", "Heritage Hangar", 2, "brize_norton_hangar")
    bld(z, 24, 23, 12, 6, "raf_hangar", show_label=False)
    bld(z, 10, 23, 12, 6, "raf_hangar", show_label=False)
    bld(z, 77, 23, 6, 4, "raf_block", "Sanctuary", 3)
    z.warp(80, 26, "brize_norton_sanctuary", 5, 6, "up")
    bld(z, 77, 29, 6, 4, "raf_block", "NAAFI", 3)
    z.warp(80, 32, "brize_norton_shop", 4, 5, "up")
    bld(z, 62, 14, 9, 4, "raf_block", "Airbridge Operations", 4, "brize_norton_airbridge")
    bld(z, 40, 14, 7, 4, "raf_block", "The Mess", 3, "brize_norton_mess")
    z.rect(40, 18, 7, 2, ":")
    z.rect(62, 18, 9, 2, ":")
    z.rect(34, 18, 40, 1, ":")
    # a row of transport aircraft on the apron
    for (x, y) in [(12, 38), (26, 38), (40, 40), (54, 38)]:
        z.building(x, y, 9, 4, "raf_aircraft", None)
    plaque(z, 66, 36, TERR, "voyager", "The Voyager",
           "The Airbus Voyager is the RAF's tanker and transport: a modified A330 airliner that can carry passengers and cargo as well as refuel fighters in mid-air from underwing hoses. It entered RAF service in 2011, and it flies the Airbridge to the South Atlantic. Some of the Voyagers were painted in a livery with the Union flag on the tail; one carried the Royal Family.")
    plaque(z, 33, 42, TERR, "atlas", "The Atlas",
           "The Airbus A400M Atlas is the RAF's newer transport, with four propeller engines that look old-fashioned and do the job extremely well. The RAF took its first one in 2014, and it can land on short rough strips where a jet airliner cannot. Brize Norton also looks after its crews.")
    plaque(z, 48, 47, TERR, "vc10", "The VC10 Years",
           "The Vickers VC10 was a British jet airliner built in the 1960s with four engines on the tail, and the RAF flew it from Brize Norton from 1966 as a transport and, later, a tanker. It was loud, fast and loved. The last RAF VC10 flew in 2013, and several of the airframes are kept in museums.")
    plaque(z, 36, 31, TERR, "sac", "The Americans at Brize",
           "In the early 1950s the United States Air Force's Strategic Air Command took over Brize Norton as a base for its bombers, and for years there were more American voices in the Carterton pubs than English ones. The station was handed back to the RAF in 1965, which is when it became the Transport Command base it is today.")
    plaque(z, 46, 31, TERR, "horsa", "The Gliders",
           "In the Second World War Brize Norton trained glider pilots and paratroopers. The big plywood Airspeed Horsa glider was built in thousands and carried troops and equipment into battle at Normandy and Arnhem, towed by bombers, landing with no engine. A Horsa is on show in the heritage hangar's collection of old aircraft and older stories.")
    plaque(z, 74, 40, TERR, "airbridge", "The South Atlantic Airbridge",
           "After the Falklands conflict of 1982 the RAF began a regular air service between Brize Norton and the islands, with a stop at Ascension Island on the way. It is called the South Atlantic Airbridge, and it covers about 13,000 kilometres each way, which is a very long way to take a Christmas card.")
    plaque(z, 30, 47, TERR, "runway", "The Runway",
           "The main runway at Brize Norton is a little over 3 kilometres long, long enough for the heaviest aircraft the RAF flies. The apron is a great concrete parking lot for aeroplanes, and the lights down the runway used to be lit by hand. Today the Control Tower looks after them.")

    # fences, bollards and lamps to dress the apron
    z.rect(3, 53, 82, 1, "F")
    for x in range(12, 80, 10):
        z.prop("floodlight", x, 36)
    z.prop("flagpole", 68, 31, variant=6)
    z.prop("flagpole", 70, 31, variant=6)
    z.prop("bench", 60, 31)
    z.prop("bench", 63, 31)
    z.prop("post_box", 75, 29)

    # the grass between the wire and the runway: planespotters and wild things
    for (cx, cy, rx, ry, s) in [(8, 31, 3, 2, 1), (18, 33, 4, 2, 2), (82, 40, 2, 3, 3), (6, 45, 2, 3, 4), (80, 45, 3, 2, 5),
                                (10, 15, 4, 2, 6), (82, 8, 3, 2, 7), (6, 5, 3, 3, 9)]:
        blob(z, cx, cy, rx, ry, "k", only="g", seed=s, jitter=0.3)

    # ---- people
    chat(z, "brz_guard", "rail_guard", 71, 14, "Gate Sentry",
         ["Good day. Champion, is it? You're on the list. The RAF Police checked you at the Cotswolds gap, and I trust their judgement more than my own.",
          "The terminal is straight down the road, on your right. Mind the apron. Aircraft always have right of way, and some of them don't have a driver."], "down")
    chat(z, "brz_spotter_chat", "birdwatcher", 4, 47, "Planespotter",
         ["I can tell a Voyager from an Atlas by the sound alone. The Atlas is a rumble. The Voyager is a polite whistle.",
          "They say that if you stand here with a flask and a notebook you can write down forty tail numbers an hour. That's the dream, anyway."], "right")
    chat(z, "brz_vicar", "pilgrim", 36, 8, "Churchgoer",
         ["St Britius is the church in the village, and the RAF has its own chapel, but the village takes the Sunday bell for itself.",
          "At Christmas, the aircraft come in over the church tower. It's said that this is how the angels' flight path was planned."], "down")
    chat(z, "brz_pjt", "hiker", 76, 40, "Parachute Instructor",
         ["I teach people to fall out of aeroplanes and arrive in one piece. It is just the second half that's hard.",
          "We jump from the Atlas here. The trick is to be afraid for the first three seconds and have a splendid time for the next three minutes."], "left")

    # trainers: station personnel on the apron, scaled from par 95
    trainer(z, "brz_loadmaster", "Loadmaster", "Loadmaster", "sailor",
            [("quayhulk", 95), ("shuttlecog", 95), ("samsonian", 95)], 30, 36, "right",
            ["Cargo checked, weight spread, ties done. You're in my loading bay, so you're my cargo now.", "Stand still while I strap you down."],
            "Fair enough. I'll sign you off as 'Fragile'.", "Fifteen tonnes of aid and I never dropped one crate. A little Tormane kicked me, but that doesn't count.", 4200)
    trainer(z, "brz_controller", "Air Traffic Controller", "Controller", "astronomer",
            [("stormswift", 95), ("skyharker", 95), ("peregrin", 95)], 52, 33, "left",
            ["Cleared for take-off, if you will excuse me. Or rather, you may begin your approach.", "Bring it in, slowly, and mind your separation."],
            "Cleared. Report to the ground for debrief.", "I've talked down a Voyager in fog before. It's a talk-down I'd give anyone: nice and slow.", 4300)
    trainer(z, "brz_spotter", "Planespotter", "Planespotter", "birdwatcher",
            [("polartern", 95), ("goldeneyrie", 95), ("stoopfalcon", 95)], 20, 34, "down",
            ["Don't move. There's an Atlas due on finals and I've never got the nose-gear shot.", "Oh, a battle. Fine. But the light is going."],
            "That's a lovely Peregrin, though. Don't tell my mum I said so.", "I have a hundred and twelve photos of the same aircraft. They are all different. Nobody believes me.", 3800)
    trainer(z, "brz_wing_commander", "Wing Commander", "Station Officer", "explorer",
            [("shieldbiter", 95), ("stoopfalcon", 95), ("railspark", 95), ("landship", 95)], 74, 45, "up",
            ["I command a wing of the Air Mobility Force: eight thousand people, fifty-odd aircraft and not enough tea.",
             "The Airbridge never closes, and neither does my interest in who's walking about on my apron."],
            "Well flown. I'll put you down for the Air Officer's commendation, just as soon as I remember where the pen is.",
            "The best of the Airbridge is that every flight has something nobody expected. One had a goat.", 6200)
    for t in ("brz_loadmaster", "brz_controller", "brz_spotter", "brz_wing_commander"):
        TRN[t]["scaled_floor"] = FLOOR

    # ---- wild things on the grass at the edges
    wild(z, [("starlet", 95, 97, 14, {}), ("murmurant", 95, 97, 8, {"time": ["dusk", "night"]}), ("peregrin", 95, 97, 8, {"time": ["day"]}),
             ("kitelet", 95, 97, 10, {}), ("hootlet", 95, 97, 6, {"time": ["night"]}), ("leveret", 95, 97, 10, {"time": ["dawn", "dusk"]}),
             ("redbreast", 95, 97, 8, {}), ("swiftlet", 95, 97, 10, {"time": ["day", "dawn"]}), ("tootlet", 95, 97, 6, {}),
             ("bleeplet", 95, 97, 4, {"weather": ["downpour", "gale"]})])
    z.d["edges"] = {"north": {"to": "cotswolds", "offset": 0}}
    smooth(z)
    reach_check(z)
    done(z)
    z.save(OUT + "/" + zid + ".json")

    # ---- the rooms
    sanctuary(OUT, zid, "Brize Norton", (80, 27))
    shop(OUT, zid, "Brize Norton", (80, 33))
    nurse(zid, ["Afternoon. Station Medical Centre, which the sign outside calls a Sanctuary because a Wing Commander lost an argument.",
                "Pop your team on the trolley. We treat everything that comes through the door, from sprained wings to altitude sickness.",
                "All patched up and fit to fly. You've got a clean bill of health from the RAF.",
                "The Ark's through the back, by the vending machine. Please do not feed the vending machine.",
                "Take your time. The kettle's always on. It's the station's one constant."])
    shopkeeper(zid, "NAAFI! Tea, pies, kit and the sort of snares we've had since the Berlin Airlift. What'll it be?",
               "Cheers. Mind the door; it's heavier than it looks, like most of our aircraft.")

    landmark(OUT, "brize_norton_terminal", "Air Terminal", zid, (63, 29), "hall", [
        dict(id="brz_movements", sprite="rail_guard", x=6, y=2, facing="down", move="still", script="brz_movements", name="Movements Officer"),
        dict(id="brz_lounge", sprite="commuter", x=10, y=5, facing="left", move="still", script="brz_lounge", name="Passenger"),
        dict(id="brz_steward", sprite="shopkeeper", x=2, y=5, facing="right", move="still", script="brz_steward", name="Terminal Steward")])
    landmark(OUT, "brize_norton_tower", "Control Tower", zid, (49, 29), "workshop", [
        dict(id="brz_tower_ctrl", sprite="astronomer", x=6, y=3, facing="down", move="still", script="brz_tower_ctrl", name="Duty Controller")])
    landmark(OUT, "brize_norton_hangar", "Heritage Hangar", zid, (39, 29), "museum", [
        dict(id="brz_curator", sprite="prof_garside", x=4, y=3, facing="right", move="still", script="brz_curator", name="Curator"),
        dict(id="brz_volunteer", sprite="villager_2", x=8, y=4, facing="left", move="still", script="brz_volunteer", name="Volunteer")])
    landmark(OUT, "brize_norton_airbridge", "Airbridge Operations", zid, (66, 18), "hall", [
        dict(id="brz_duty", sprite="explorer", x=6, y=2, facing="down", move="still", script="brz_duty", name="Duty Officer"),
        dict(id="brz_loadsheet", sprite="commuter", x=3, y=4, facing="right", move="still", script="brz_loadsheet", name="Load Planner")])
    landmark(OUT, "brize_norton_mess", "The Mess", zid, (43, 18), "cafe", [
        dict(id="brz_chef", sprite="shopkeeper", x=3, y=1, facing="down", move="still", script="brz_chef", name="Mess Chef"),
        dict(id="brz_padre", sprite="pilgrim", x=8, y=4, facing="left", move="still", script="brz_padre", name="Padre")], w=11, h=9)
    landmark(OUT, "brize_norton_church", "St Britius Church", zid, (34, 8), "church", [
        dict(id="brz_sexton", sprite="villager_3", x=6, y=2, facing="down", move="still", script="brz_sexton", name="Sexton")])
    # the hall's rows are tiled: this reads as "a terminal" (see the furniture in zlib)
    story()


def story():
    z = "brize_norton_terminal"
    script(z, "brz_movements", [
        iff("champion", [
            {"do": "say", "who": "Movements Officer", "text": "Champion! Welcome to Air Movements. Passport? Ha, no, not for the territories. They're all ours."},
            {"do": "choice", "text": "Where to?", "options": ["Departures board", "Not today"], "set": "_dep_choice"},
            {"do": "if", "flag": "_dep_choice", "eq": 0, "then": [{"do": "overseas"}], "else": say1("Movements Officer", "No rush. The next flight is always about to leave.")}],
            say1("Movements Officer", "Sorry, civilians can't fly the Airbridge. It's the Champion's privilege: you need to have won the Open Moot, and the paperwork says you haven't yet.",
                 "Come back with a title, and I'll find you a seat. The Airbridge always has a seat. The tea is another matter.")),
    ])
    script(z, "brz_lounge", say1("Passenger", "I've been on the Airbridge twice and I still can't sleep on it. There's a bit in the middle where it's just sea, for nine hours.",
                                 "Take a cardigan. It's warm on the ground and cold on the plane, and there's a rule that the tea is never hot enough."))
    script(z, "brz_steward", say1("Terminal Steward", "Hot drinks at the counter, toilets by the door, departures straight ahead.",
                                  "Every territory on the board has a flight line. The pilots read them out on landing. I've heard them all."))
    z = "brize_norton_tower"
    script(z, "brz_tower_ctrl", [iff(QF + "_started", [iff(QF + "_2", say1("Duty Controller", "Told the Duty Officer yet? The runway never gets any shorter, but the paperwork does."),
        say1("Duty Controller", "Right, since you ask about the Airbridge. Brize to Ascension is a little over 6,000 kilometres, and Ascension to the Falklands is about the same again.",
             "So the Airbridge has one stop and a great deal of sea. Go and tell the Duty Officer, and keep your elbows in on the stairs.") + sett(QF + "_2"))],
        say1("Duty Controller", "This is the tower. We look after about a hundred movements a day, on a quiet one. The big windows at the top are not for the view: they're for seeing what's about to hit us.",
             "I sit here with a mug of tea and a radio and tell very large aeroplanes where to go. It's the best job in the Air Force."))])
    z = "brize_norton_hangar"
    script(z, "brz_curator", say1("Curator", "This is the heritage hangar. We keep a few of the old types alive for the station's history, and there's a Horsa glider in the corner, which looks like a flying shed because it was one.",
                                  "A Horsa has no engine. It was towed up by a bomber and cast off over the field, and the pilot had one go at the landing. The pilots were wonderfully brave and a bit mad."))
    script(z, "brz_volunteer", say1("Volunteer", "I do Tuesdays. I dust the VC10 poster and I tell visitors it was the quietest jet ever built. That is a lie, and the VC10 knows it.",
                                    "Here, have a mint. They're from the NAAFI, they're older than the Atlas, and they are still very good."))
    z = "brize_norton_airbridge"
    script(z, "brz_duty", [
        iff(QF + "_done", say1("Duty Officer", "Our friend with the manifest! Every flight since has run on time, or near enough. I'd bet it was your clean handwriting."),
            [iff(QF + "_2", [iff("trainer_brz_loadmaster",
                 say1("Duty Officer", "Signed by the Loadmaster, and the distances from the Tower? Splendid. That's the Airbridge manifest done, and my phone has finally stopped ringing.",
                      "Have a few supplies from the stores, and the station's thanks. We don't hand out medals for paperwork, so you'll have to settle for tea.")
                 + sett(QF + "_3", QF + "_done") + [item("flask_of_tea", 3), item("cup_of_tea", 3), standing(10)],
                 say1("Duty Officer", "The Tower gave you the distances? Lovely. Now the Loadmaster on the apron has to sign the manifest, and he only signs for people who can beat him in a fair fight. Don't ask me why."))],
                [iff(QF + "_started", say1("Duty Officer", "Ask the Duty Controller in the Tower about the Airbridge distances, then have a word with the Loadmaster on the apron. Then come back."),
                     say1("Duty Officer", "Ah, a Champion with time on their hands. The Airbridge flies to the Falklands and back with a stop at Ascension, and every one of those flights is a mountain of paperwork.",
                          "Could you walk the manifest round for me? Tower first for the distances, then the Loadmaster on the apron for a signature. I'd do it myself, but I've got a phone that won't stop.")
                     + sett(QF + "_started", QF + "_1"))])])])
    script(z, "brz_loadsheet", say1("Load Planner", "Every aircraft has a weight and a balance. Passengers are weighed with their bags. Aid is weighed in tonnes. Post is weighed on a kitchen scale in the corner.",
                                    "The Atlas can lift about thirty tonnes. The Voyager can carry nearly three hundred passengers or a lot of fuel. We try not to mix them."))
    z = "brize_norton_mess"
    script(z, "brz_chef", say1("Mess Chef", "Full English at any hour. The Airbridge has no clock: there's always someone landing, someone leaving and someone starving.",
                               "The secret is the bacon. Two rashers per person on the way out, three on the way back."))
    script(z, "brz_padre", say1("Padre", "I'm the station Padre. The job is mainly listening and tea. I've married a few and held hands with a great many people about to fly for the first time.",
                                "Remember that the best landing is the one you walk away from. And the best take-off is the one with the tea still hot."))
    z = "brize_norton_church"
    script(z, "brz_sexton", say1("Sexton", "St Britius has stood here since Norman times. The tower is the one the aircraft come in over, and the bells are rung by hand every Sunday by a team of six, including one RAF Corporal.",
                                 "Britius, or Brice, was a bishop of Tours who had a rocky start and a fine finish. That is the best story in the village."))


def main():
    brize()
    TRN["brz_loadmaster"]["intro"] = say("Loadmaster", "Cargo checked, weight spread, ties done. Got the manifest? Then you'll want my signature.", "Stand still while I strap you down.")
    write_dialogue_and_trainers()
    print("brize_norton written")


if __name__ == "__main__":
    main()
