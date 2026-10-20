# R6: the Rhondda, a route up the valley floor from Cardiff's north side to Merthyr. Terraced rows climb both
# sides in bands, the pit head and Heritage Park stand on the floor, the chapel keeps the choir.
from r6_common import *

YS = [9, 15, 21, 27, 33, 39, 45, 51, 57, 63]          # the E-W streets (door row is the one above)
EAST = [(40, 44, 1), (45, 49, 2), (50, 54, 3), (55, 57, 4)]
WEST = [(16, 20, 1), (11, 15, 2), (6, 10, 3), (3, 5, 4)]


def rhondda(OUT):
    W, H = 60, 72
    zid = "rhondda"
    z = Z(zid, "The Rhondda", W, H, kind="route", region=SW, music="route_moor", weather=WX)
    z.d["stage"] = "valley"
    z.d["scaled_floor"] = FLOOR
    z.legend["g"] = {"tile": "grass", "colour": "#6a8a48"}
    z.rect(0, 0, W, H, "g")
    z.border("T", 2, gaps=[(29, 0, 3, 2), (29, 70, 3, 2)])
    for y in range(H):
        for x in range(W):
            z.hg[y][x] = hband(x, EAST, WEST)
    # the valley floor: river, west-bank path, road, pavements, three bridges
    z.rect(23, 2, 1, 68, "w"); z.rect(24, 2, 2, 68, "~"); z.rect(26, 2, 1, 68, "w")
    z.rect(21, 2, 2, 68, "#")
    z.rect(29, 0, 3, H, "=")
    z.rect(28, 2, 1, 68, ":"); z.rect(32, 2, 1, 68, ":")
    for ys in (15, 39, 63):
        z.rect(23, ys, 5, 2, "=")
    for ys in YS:
        z.rect(3, ys, 19, 1, "#")
        z.rect(33, ys, 22, 1, "#")
    # terraced rows: the stone terraces of the Rhondda, each band a little higher than the last
    for ys in YS:
        for bx in (40, 45, 11, 16):
            if ys == 27 and bx == 40:
                continue
            z.building(bx, ys - 3, 5, 3, "valley_terrace")
    z.building(40, 24, 5, 3, "valley_terrace", "2 Bryn Terrace", door=2)
    z.warp(42, 26, "rhondda_home", 6, 7, "up")
    # on the floor: the pit head, the Institute, the chapel, the bakehouse
    z.building(33, 16, 7, 5, "winding_gear", "Rhondda Heritage Park", door=4)
    z.warp(37, 20, "rhondda_heritage", 6, 7, "up")
    z.building(33, 29, 6, 4, "red_brick", "Miners' Institute", door=3)
    z.warp(36, 32, "rhondda_institute", 6, 7, "up")
    z.building(33, 40, 6, 5, "chapel", "Bethania Chapel", door=3)
    z.warp(36, 44, "rhondda_chapel", 6, 7, "up")
    z.building(33, 53, 6, 4, "cream_render", "Y Popty (the bakehouse)", door=2)
    z.warp(35, 56, "rhondda_bakehouse", 5, 6, "up")
    for (x, y, v) in [(34, 13, 0), (36, 13, 1), (38, 14, 2), (35, 11, 1), (37, 10, 0)]:
        z.prop("slate_heap", x, y, variant=v)
    # pit-head furniture, benches and lamps along the road
    for y in (12, 24, 36, 48, 60):
        z.prop("lamp_post", 27, y)
    z.prop("bench", 35, 25); z.prop("bench", 39, 36); z.prop("planter", 31, 69); z.prop("bollard", 33, 22)
    for (x, y) in [(18, 10), (13, 16), (47, 29), (42, 40), (18, 46)]:
        z.prop("washing_line", x, y, walk=True)
    # the hillsides above the top terraces: bracken, rock, rowan, a coal tip greened over
    for (cx, cy, rx, ry, sd) in [(53, 12, 3, 5, 1), (52, 38, 3, 6, 2), (53, 60, 3, 5, 3), (8, 22, 3, 6, 4), (8, 50, 3, 7, 5), (8, 66, 3, 3, 6),
                                 (35, 8, 3, 3, 7), (36, 62, 3, 3, 8), (36, 36, 2, 2, 9), (35, 48, 3, 2, 10)]:
        blob(z, cx, cy, rx, ry, ",", only="g", seed=sd, jitter=0.4)
    scatter_props(z, "oak", 3, 3, 8, 66, 12, 31, avoid=("g",))
    scatter_props(z, "birch", 50, 3, 7, 66, 12, 32, avoid=("g",))
    scatter_props(z, "pine", 3, 3, 8, 66, 5, 33, avoid=("g",))
    for (x, y, v) in [(53, 20, 0), (55, 22, 1), (52, 24, 2), (54, 46, 0), (51, 48, 1), (56, 50, 2)]:
        z.prop("slate_heap", x, y, variant=v)
    smooth(z)

    # ---- signs and plaques
    z.sign(27, 66, "YR RHONDDA. Croeso! (Welcome!) Two valleys, Fawr (big) and Fach (little). South: Caerdydd, Cardiff. North: Merthyr Tydfil.")
    z.sign(27, 4, "MERTHYR TYDFIL, ahead. The iron capital of the world, once. Mind the hill, bach.")
    z.sign(22, 30, "Y GLO. 'Coal.' Every back yard along this river once had a tip behind it. The river ran black; it runs clear now, and the dippers have noticed.")
    plaque(z, "rhondda", "cwm", 27, 62, "Cwm and Rhondda",
           "A cwm (say 'coom') is a steep-sided valley, and the south Wales coalfield is a comb of them running down to the sea. The Rhondda is two: Fawr, big, and Fach, little, which meet at Porth. A hundred and fifty years ago most of it was sheep and woodland.")
    plaque(z, "rhondda", "coal", 27, 50, "Black Gold",
           "In 1913 the south Wales coalfield dug a record 56 million tons, and the Rhondda alone had dozens of pits. Steam coal from here drove ships all over the world, and Cardiff was the busiest coal port on earth.")
    plaque(z, "rhondda", "terraces", 27, 38, "Terraces",
           "In 1851 the Rhondda held a few thousand people. By 1911 it held over 150,000. Rows of stone houses were thrown up along the contours so that men could walk from bed to the pit, and every one had a chimney, a back yard and a chapel within shouting distance.")
    plaque(z, "rhondda", "choirs", 27, 26, "Male Voice Choirs",
           "The valleys' male voice choirs grew out of the chapels and the pits, where hundreds of men were used to singing in harmony. A choir might rehearse twice a week and compete at the eisteddfod, and some of them are over a hundred years old.")
    plaque(z, "rhondda", "calon", 27, 14, "Calon Lan",
           "'Calon Lan', 'a pure heart', is a hymn with words by Daniel James and a tune by John Hughes, and it is sung by Welsh choirs, chapels and rugby crowds with equal conviction. Nobody sings the second verse, but everybody knows it.")
    plaque(z, "rhondda", "tips", 27, 8, "The Tips",
           "Spoil from the pits was piled in great tips on the hillsides. Many have since been reshaped, grassed and planted, and walkers now cross slopes that were once black. The valley sides are green again, which makes the old photographs look like another country.")
    plaque(z, "rhondda", "aberfan", 22, 36, "Aberfan, 1966",
           "In memory of the 144 people who died at Aberfan on 21 October 1966, 116 of them children. Remembered.")
    z.prop("flower_patch", 22, 35); z.prop("flower_patch", 22, 37)

    # ---- people
    chat(z, "rhn_oldcollier", "tin_miner", 35, 24, "Old Collier",
         ["Forty-one years at the coal face and I still can't walk past a pit head without my knees telling me about it.",
          "The Rhondda Heritage Park is the old Lewis Merthyr colliery. They've kept the winding gear and the lamp room, and old boys like me show people round. I'm the exhibit, really.",
          "We used to sing on the way home. You'd come up out of the dark into the evening and a hundred men would have a hymn going by the first corner."], facing="down")
    chat(z, "rhn_washday", "mum", 47, 28, "Mrs Pugh",
         ["Monday is washday, cariad, always was. The whole row's out with the sheets and all the gossip goes along the line faster than the wind.",
          "My mam had a rule. Washing out on Monday, Welsh cakes on the bakestone Tuesday, and the coalman paid on Friday. If the coalman was late, the whole week fell over.",
          "Miners used to get coal for the fire as part of the job, tipped outside the front door. They call it concessionary coal. Nobody conceded anything, mind. They dug it."], facing="down")
    chat(z, "rhn_kid", "villager_6", 44, 46, "Kid",
         ["I got a Welsh cake and a Cobblet in the same day. The Cobblet knocked on my school bag. It wanted the Welsh cake.",
          "Grandad says the coblynau helped miners find coal. I think they mostly help themselves to lunch."], facing="left")
    chat(z, "rhn_walker", "hillwalker", 17, 58, "Walker",
         ["There's a footpath all the way up the ridge above the top terrace. You can see six valleys from the cairn on a clear day.",
          "On a clear day. In the Rhondda that's a theory more than a forecast."], facing="right")
    # trainers
    trn(z, "rhn_collier", "Collier Emrys", "Retired Collier", "tin_miner", [("moldiwarp", 35), ("tapknock", 35), ("glowmite", 35)], 44, 33, "left",
        ["Forty years underground and not one of my team has ever been late for a shift. Show me what you've got, boyo."],
        "Fair play. Fair play. You'd have made a good collier.", "The trick underground is to listen. If the roof is going to talk, it talks first.", 2700)
    trn(z, "rhn_tenor", "Tenor Rhys", "Choir Tenor", "choir_singer", [("versling", 35), ("kidgruff", 35), ("cragchough", 36)], 14, 45, "right",
        ["I'm warming up for the Saturday rehearsal. Doh, ray, me... oh, a challenger! Sing for it, then."],
        "My top note's gone. Not a word to the baritones.", "We're doing the Cwm Rhondda on Saturday. Roof's going to come off the chapel, as usual.", 2700)
    trn(z, "rhn_prop", "Prop Gethin", "Rugby Prop", "rugby_player", [("moolet", 35), ("herdlet", 35), ("foalmoor", 36)], 46, 39, "left",
        ["Rhondda boys grow up on rugby and chapel and cawl. Mostly in that order. Come on, then, scrum down."],
        "Duw, that was a clean turnover.", "I'll tell you the secret of a good scrum. It's cawl. Always has been.", 2700)
    # wild
    wild(z, [("tapknock", 34, 36, 14, {}), ("moldiwarp", 34, 36, 12, {}), ("kidgruff", 34, 36, 10, {}), ("cobblet", 34, 36, 9, {}),
             ("slatelet", 34, 36, 8, {}), ("glowmite", 34, 36, 8, {"time": ["night"]}), ("rooklet", 33, 35, 8, {"time": ["day"]}),
             ("stagbeet", 34, 36, 6, {}), ("steamlet", 34, 36, 4, {}), ("railspark", 35, 37, 3, {}), ("pepperling", 34, 36, 6, {"weather": ["sunshine"]}),
             ("hootlet", 34, 36, 6, {"time": ["night"]}), ("crumblet", 34, 36, 5, {}),
             ("seamknocker", 38, 39, 1, {"time": ["night"]}), ("penydarren", 38, 39, 1, {})])
    wild(z, [("holtling", 34, 36, 14, {}), ("dipling", 34, 36, 16, {}), ("pupplash", 33, 35, 6, {}), ("ductling", 34, 36, 6, {})], "water")
    z.d["edges"] = {"south": {"to": "cardiff", "offset": 16}, "north": {"to": "merthyr", "offset": 0}}
    z.d["spawn"] = [30, 68]
    done(z)
    z.save(OUT + "/" + zid + ".json")
    bad = reach_check(z)
    if bad:
        print("rhondda unreachable:", bad)

    # ---- interiors
    interior(OUT, "rhondda_heritage", "Rhondda Heritage Park", zid, (37, 21), "museum",
             [dict(id="rhn_heritage_guide", sprite="tin_miner", x=6, y=3, facing="down", move="still", script="rhn_heritage_guide", name="Dai, ex-collier"),
              dict(id="rhn_heritage_visitor", sprite="student", x=10, y=5, facing="left", move="still", script="rhn_heritage_visitor", name="Visitor")],
             furnish=False, drop=("statue",),
             extra=[P("display_case", 3, 2, variant=1), P("display_case", 9, 2, variant=2), P("slate_heap", 1, 5), P("slate_heap", 11, 6, variant=1),
                    P("wall_picture", 4, 1, walk=True), P("clock", 8, 1, walk=True), P("table", 2, 5), P("brazier", 11, 2)],
             signs=[{"x": 4, "y": 5, "plaque": "rhondda_lamproom", "title": "The Lamp Room",
                     "text": "Every collier collected a numbered brass tally and a lamp at the start of a shift. Tallies went on a board; when the shift ended each man took his tally down. If one was left hanging, the manager knew exactly who was still underground."}])
    DLG["rhondda_heritage"] = {
        "rhn_heritage_guide": [flag_if(Q + "wager_started",
                                       [flag_if(Q + "wager_1",
                                                say("Dai", "Coal for Trevithick's engine, is it? You've had your bucket already, bach. Don't waste it. It's the good stuff."),
                                                say("Dai", "Merthyr, is it? An engine to fire for the wager? Hah. Take this, then.",
                                                    "Best Rhondda steam coal. Dry, hard, burns hot and nearly smokeless, which is why the Navy bought it by the shipload.")
                                                + [setf(Q + "wager_1"), {"do": "give_item", "item": "steam_coal", "n": 1}])],
                                       say("Dai", "Bore da! I was fifteen when I first went underground. We called it 'going down the hole', as if it was a hobby.",
                                           "Rhondda steam coal was the best in the world. Low in smoke, hot as a dragon's breath. The Royal Navy ran on it.",
                                           "Lewis Merthyr, this was. The shafts are still down there. Mind the display cases; they're older than I am."))],
        "rhn_heritage_visitor": say("Visitor", "I came for the winding gear and I stayed for the tea. The man at the till says the lamp was only ever a flame behind a wire gauze. The Davy lamp, they call it.",
                                    "Sir Humphry Davy designed it in 1815 so a flame couldn't ignite the gas, and the colour of the flame told a miner whether the air was bad.")}

    interior(OUT, "rhondda_institute", "Miners' Institute", zid, (36, 33), "library",
             [dict(id="rhn_librarian", sprite="poet", x=6, y=3, facing="down", move="still", script="rhn_librarian", name="Librarian"),
              dict(id="rhn_reader", sprite="villager_3", x=3, y=6, facing="right", move="still", script="rhn_reader", name="Reader")],
             furnish=False,
             extra=[P("table", 4, 6), P("table", 8, 6), P("wall_picture", 5, 1, walk=True), P("wall_picture", 8, 1, walk=True), P("clock", 6, 1, walk=True),
                    P("potted_plant", 1, 1)],
             signs=[{"x": 8, "y": 3, "plaque": "rhondda_medical", "title": "The Medical Aid Society",
                     "text": "Miners' institutes ran libraries, reading rooms and, in some towns, medical aid societies. In Tredegar, a few miles from here, workers paid a few pence a week out of their wages for a doctor, nurses, medicine and hospital care for the whole family. A young Tredegar miner called Aneurin Bevan sat on its committee."},
                    {"x": 4, "y": 3, "plaque": "rhondda_nhs", "title": "5 July 1948",
                     "text": "The National Health Service began on 5 July 1948, with Aneurin Bevan, a miner's son from Tredegar, as Minister of Health. He later said the NHS was the Tredegar society's idea scaled up to the whole country: everyone pays in, anyone who needs care gets it."}])
    DLG["rhondda_institute"] = {
        "rhn_librarian": say("Librarian", "Institute rules: no spitting, no swearing and no hats on the books. A penny a week out of every pay packet built this room, the library and the reading room.",
                             "The miners ran the place themselves. There was a committee, a treasurer, minutes. People think the valleys were all coal dust and hymns. They were also quite remarkably well organised.",
                             "Have a look at the framed notice by the shelves. It's about the Tredegar Medical Aid Society. A few pence a week and the whole family saw a doctor. A man called Bevan helped run it, and later copied it for the whole country."),
        "rhn_reader": say("Reader", "Shh. I'm on the last chapter of 'How Green Was My Valley'. Richard Llewellyn wrote it about a mining village, and there's a stern father in it who sings very well.",
                          "I'll tell you the secret of the Institute: it was warm. A reading room with a coal fire and no draught beats most things, and I include the pub.")}

    interior(OUT, "rhondda_chapel", "Bethania Chapel", zid, (36, 45), "church",
             [dict(id="rhn_conductor", sprite="choir_singer", x=6, y=2, facing="down", move="still", script="rhn_conductor", name="Elwyn Prosser, conductor"),
              dict(id="rhn_organist", sprite="villager_2", x=3, y=2, facing="right", move="still", script="rhn_organist", name="Organist")],
             furnish=False, h=10,
             extra=[P("harp", 9, 2), P("piano", 2, 4), P("wall_picture", 6, 1, walk=True)],
             signs=[{"x": 10, "y": 6, "plaque": "rhondda_cwmrhondda", "title": "Cwm Rhondda",
                     "text": "The hymn tune 'Cwm Rhondda' was written by John Hughes in 1907 for a festival at a chapel in the valley, and it is the one that goes 'Bread of heaven, feed me till I want no more'. It is also what the Welsh sing at Cardiff Arms Park when a result is going well."}])
    DLG["rhondda_chapel"] = {
        "rhn_conductor": rhn_conductor_script(),
        "rhn_organist": say("Organist", "Nineteen hymns, six anthems and a Welsh Wedding March. I could play any of them in my sleep, and I have, in the sermon.",
                            "A male voice choir needs four parts: first tenor, second tenor, baritone, bass. Miss any one and you can hear the hole in it, like a missing tooth.")}

    interior(OUT, "rhondda_bakehouse", "Y Popty", zid, (35, 57), "cafe",
             [dict(id="rhn_baker", sprite="shopkeeper", x=3, y=1, facing="down", move="still", script="rhn_baker", name="Nan, the baker")],
             w=11, h=9, furnish=False,
             extra=[P("kettle_table", 8, 5), P("menu_board", 6, 1, walk=True), P("tea_urn", 1, 3), P("table", 8, 3), P("potted_plant", 9, 6)],
             signs=[{"x": 5, "y": 2, "plaque": "rhondda_welshcake", "title": "Picau ar y Maen",
                     "text": "Welsh cakes are 'cakes on the stone': flour, butter, sugar, currants and a pinch of mixed spice, cooked on a bakestone or a griddle, never in an oven. Eat them warm, with sugar. They keep, which is why miners' wives made them in bulk."}])
    DLG["rhondda_bakehouse"] = {"rhn_baker": rhn_baker_script()}

    interior(OUT, "rhondda_home", "2 Bryn Terrace", "rhondda", (42, 27), "home",
             [dict(id="rhn_home_mum", sprite="mum", x=4, y=3, facing="right", move="still", script="rhn_home_mum", name="Mrs Pugh's sister")],
             furnish=True,
             extra=[P("tea_urn", 2, 2), P("kitchen_dresser", 8, 1)])
    DLG["rhondda_home"] = {"rhn_home_mum": say("Mrs Pugh's sister", "Come in, cariad, mind the step, it's high. They built the fireplace first and the house round it. The fire's a range with an oven on the side.",
                                                  "There's a tin bath on a nail in the yard. Friday night was bath night for the men, one after the other, in front of the fire, shift by shift. You always wanted to be first.",
                                                  "Parlour's the best room and nobody's allowed in it. It's the one with the good china and the good clock. We use the kitchen like everybody else.")}


def rhn_conductor_script():
    voices = [Q + "choir_1", Q + "choir_2", Q + "choir_3", Q + "choir_4"]
    perform = (say("Elwyn", "Four parts at last: first tenor, second tenor, baritone and a proper bass. Four parts and one conductor with a very sore throat.")
               + [{"do": "fade_out"},
                  {"do": "say", "who": "", "text": "The eisteddfod pavilion is packed to the rafters. Elwyn raises his baton. For a moment there is no sound at all."},
                  {"do": "say", "who": "", "text": "Then forty men breathe in together, and the roof lifts. The Cwm Rhondda goes up through the canvas like a rocket."},
                  {"do": "fade_in"}]
               + say("Elwyn", "Second place! Second! We beat the Treorchy boys by a whisker and a bad key change. Here. Take the medal. It's yours as much as ours.")
               + [{"do": "give_item", "item": "eisteddfod_medal", "n": 1}, setf(Q + "choir_done"), {"do": "standing", "nation": "wales", "amount": 6}])
    nested = perform
    for v in reversed(voices):
        nested = [flag_if(v, nested, say("Elwyn", "We're still a voice short. Have you tried the baker, the Merthyr pub, the Workmen's Hall and Big Pit?"))]
    return [flag_if(Q + "choir_done",
                    say("Elwyn", "Practice is Thursday and Saturday. If you ever hear a roof coming off in the Rhondda, that's us."),
                    [flag_if(Q + "choir_started", nested,
                             say("Elwyn", "Bore da. Elwyn Prosser, conductor of the Bethania Male Voice Choir. We've got the National Eisteddfod in a fortnight and we're a quartet short.",
                                 "I need four voices: a first tenor, a second tenor, a baritone and a bass. I've heard rumours of singers in the bakehouse over the road, in a pub in Merthyr, in the Workmen's Hall at Blaenavon, and underground in Big Pit.",
                                 "Find them for me. And tell them they won't be paid, but there'll be tea.")
                             + [setf(Q + "choir_started")])])]


def rhn_baker_script():
    found = Q + "choir_1"
    ask = [{"do": "say", "who": "Nan", "text": "Sing? Me? I do a fair first tenor, mind. But I'm not singing for just anybody. A question first. Which hymn tune is named for this valley?"},
           {"do": "choice", "text": "Which hymn tune is named for the Rhondda?", "options": ["Cwm Rhondda", "Greensleeves", "Myfanwy", "Land of Hope and Glory"], "set": "_nan_q"},
           {"do": "if", "flag": "_nan_q", "eq": 0,
            "then": say("Nan", "Cwm Rhondda! 'Bread of heaven'! Good girl, good boy, good whatever you are. I'll sing. Tell Elwyn I'll bring Welsh cakes for the second row.")
                    + [setf(found), {"do": "sfx", "id": "item"},
                       {"do": "say", "who": "", "text": "You found the first tenor for the eisteddfod choir."}],
            "else": say("Nan", "No, no, no. Go and ask the old boys on the bench outside. Come back when you've got it.")}]
    return [flag_if(found, say("Nan", "I'll be at the chapel Saturday. Have a Welsh cake for the road."),
                    [flag_if(Q + "choir_started", ask,
                             say("Nan", "Welsh cakes, picau ar y maen: cakes on the stone. Flour, butter, currants, sugar and patience. Never an oven, never a rolling pin you've washed.",
                                 "Mind, I sing as well as I bake. Ask Elwyn at the chapel if he's short of voices. He always is."))]),
            {"do": "shop", "id": "rhondda_bakehouse"}]
