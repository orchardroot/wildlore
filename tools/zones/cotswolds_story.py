# Dialogue, trainers and NPC placement for the Cotswolds and Oxford (cotswolds.py).
# Quest flags are q_cotswolds_<quest>_* and q_oxford_<quest>_*; see data/quests/cotswolds.json and oxford.json.
from wcommon import say

ENG = "england"


def s(who, *lines):
    return say(who, *lines)


def sett(*flags):
    return [{"do": "set", "flag": f} for f in flags]


def iff(flag, then, other=None):
    return {"do": "if", "flag": flag, "then": then, "else": other or []}


def when(cond, then, other=None):
    return {"do": "when", "cond": cond, "then": then, "else": other or []}


def item(i, n=1):
    return {"do": "give_item", "item": i, "n": n}


def standing(n):
    return {"do": "standing", "nation": ENG, "amount": n}


def plain_trainer(TRN, tid, name, cls, sprite, party, intro, win, money):
    """a trainer who only fights inside a script (a gauntlet or a battle command), with no NPC of their own."""
    TRN[tid] = {"id": tid, "name": name, "class": cls, "sprite": sprite,
                "party": [{"species": sp, "level": lv} for sp, lv in party], "ai": "trainer", "money": money,
                "intro": s(name, *intro), "win": win, "after": win}


# ------------------------------------------------------------------------------------------------ the Cotswolds
def cotswolds_cast(z, chat, trainer, stand):
    # Cooper's Hill: the Master of Ceremonies, at the top of the slope
    stand(z, 15, 37)
    z.npc(id="cw_master", sprite="tour_guide", x=15, y=37, facing="down", move="still", script="cw_master", name="Master of Ceremonies")
    chat(z, "cw_marshal", "hillwalker", 11, 59, "Hill Marshal",
         ["I stand at the bottom with a very large bag of bandages and a very large sense of occasion.",
          "Nobody has ever caught the cheese on foot. They catch the bottom of the hill. The cheese is going at about 70 mph and has a head start."], "up")
    chat(z, "cw_shepherd", "farmer", 42, 53, "Shepherd",
         ["Cotswold Lions. See the forelock? That's a fringe, and it's the reason for the name. Nothing to do with a roar. They are terribly polite.",
          "In the Middle Ages their wool was the best in Europe, long and lustrous, and it paid for every church in the district. The saying was that the golden fleece was a Cotswold one."], "right")
    chat(z, "cw_duckman", "villager_4", 37, 39, "Duck Feeder",
         ["The Windrush is never more than knee deep and the ducks know it. They hold the right of way on all five bridges, and they enforce it.",
          "Don't be tempted to paddle in your good shoes. The water is clear, cold and a good deal colder than it looks."], "down")
    chat(z, "cw_folly", "astronomer", 13, 13, "Folly Keeper",
         ["Broadway Tower was built as a folly in 1798, so that a beacon lit on top could be seen from the Countess of Coventry's house, thirty-odd miles away. She never checked.",
          "On a clear day you can see sixteen counties from the top. On a cloudy day, you can see the inside of a cloud, which has its charms."], "down")
    chat(z, "cw_morris_chat", "fiddler", 38, 31, "Fiddler",
         ["There are Cotswold Morris sides in nearly every village. White shirts, bells on the shins and sticks that clack. It's much more athletic than it looks.",
          "It's said morris dancing came from the Moors, which is why it's called morris. Folklorists doubt it, but it's a nice theory, and the dancers are not going to argue."], "down")
    chat(z, "cw_wool_chat", "villager_6", 56, 31, "Wool Trader",
         ["The Cotswold wool trade made this whole district rich. Sheep walked in from miles around to Stow fair, tens of thousands in a day.",
          "The old wool churches are the proof. The merchants wanted heaven to know where their money had gone."], "left")

    trainer(z, "cots_shepherd", "Shepherd Alwyn", "Shepherd", "farmer",
            [("herdlet", 89), ("loaghtan", 90), ("moolet", 90), ("foalmoor", 90)], 30, 20, "down",
            ["Quiet, now. These ones have heard a lot of Cotswold Lions' gossip and they do not impress easily."],
            "Well. That was loud. The sheep are going to talk about this for weeks.",
            "Cotswold Lion fleece was the finest in medieval Europe. A bale of it was worth a small fortune. The sheep have never let it go to their heads.", 4200)
    trainer(z, "cots_morris", "Morris Dancer Bernard", "Morris Dancer", "festival_goer",
            [("pixling", 89), ("leveret", 90), ("brownie", 90), ("cluricaun", 90)], 62, 36, "left",
            ["Bells on my shins, sticks in my hands and a hanky in my pocket. You may well regret asking."],
            "Oh, dear. A bell has come off. It happens to the best of us, usually in the middle of a figure.",
            "The Cotswold Morris is danced in white with baldricks and bells. The Adderbury and Bampton sides are famous. They dance on the first of May, and the sun is persuaded to come up.", 4000)
    trainer(z, "cots_walker", "Rambler Dorothea", "Rambler", "hillwalker",
            [("kitelet", 89), ("ptarmlet", 90), ("tapknock", 90), ("slatelet", 90)], 36, 12, "down",
            ["I am doing the Cotswold Way, a hundred miles from Chipping Campden to Bath. Pause, fight, resume, in that order."],
            "Not bad. Lunch time, I think. There's a pub at Broadway with scones.",
            "The Cotswold Way starts at Chipping Campden, runs along the western scarp over Broadway Hill and ends at Bath Abbey. About a hundred miles. Most people take a week, and most people take a taxi for the last bit.", 4000)
    trainer(z, "cots_waller", "Waller Gethin", "Drystone Waller", "tin_miner",
            [("slatelet", 89), ("kidgruff", 90), ("tinnet", 90), ("moldiwarp", 90)], 22, 19, "right",
            ["A wall is two faces leaning in, tied across with throughstones, filled with the little ones. Same as a good team. Shall we see?"],
            "Nicely placed. You'd make a decent waller. Hard on the knees, mind.",
            "Never throw a stone back that you've picked up. Pick it up once, put it in its place. That's the first rule. The second is: don't lean on the wall. The third is also: don't lean on the wall.", 4100)
    trainer(z, "cots_beekeeper", "Beekeeper Marguerite", "Beekeeper", "jam_maker",
            [("flaxling", 89), ("gentlet", 90), ("starlet", 90), ("dozelet", 90)], 74, 46, "up",
            ["Honey from the hives in the walled garden. Perhaps more of a bribe than a prize. We'll see."],
            "Stung! Not by the bees. By the defeat. Have a honey sandwich.",
            "Cotswold limestone holds the day's heat like a storage heater, so the bees love it. A hive against a south-facing honey wall is worth ten in the open.", 4300)
    trainer(z, "cots_quarryman", "Quarryman Hal", "Quarryman", "steelworker",
            [("slatelet", 89), ("tinnet", 90), ("rivetling", 90), ("slatelet", 91)], 56, 13, "down",
            ["Honey-coloured limestone? Not just pretty, you know. Real stone, real work, and I intend to do a bit more of it to you."],
            "Hard stone, hard luck. Well fought.",
            "Cotswold stone comes out of the ground soft and full of quarry water, and hardens as it dries in the air. Quarrymen like to dig it in the autumn, so the frost can't split it before it sets.", 4200)

    # the Rollright Stones: the Keeper and the three counters (see the quest below)
    stand(z, 75, 19)
    z.npc(id="cw_warden", sprite="druid", x=75, y=19, facing="left", move="still", script="cw_warden", name="Stone Keeper")
    for nid, sprite, x, y, face in (("cw_count_n", "hiker", 74, 6, "down"), ("cw_count_e", "hillwalker", 79, 11, "left"),
                                    ("cw_count_w", "birdwatcher", 69, 11, "right")):
        stand(z, x, y)
        z.npc(id=nid, sprite=sprite, x=x, y=y, facing=face, move="still", script=nid, name="Counter")


# ------------------------------------------------------------------------------------------------ Oxford
def oxford_cast(z, chat, trainer, stand):
    chat(z, "ox_guide", "tour_guide", 28, 29, "Walking Guide",
         ["Welcome to Carfax, the crossing at the middle of Oxford. 'Carfax' is from the Latin for four-forked. Four roads, one tower, and two thousand people photographing it.",
          "That's not the main tower, by the way. People always point at the wrong spire. There are about a hundred. Choose one and look amazed."], "right")
    chat(z, "ox_busker", "fiddler", 47, 31, "Busker",
         ["They don't let you busk on the cobbles by the Camera, which is a pity. The acoustic is superb and so are the tourists. I do my fiddling here, with an eye out for the Proctors.",
          "The University has a pair of Proctors, who walk the streets in black gowns and white bow ties, with two helpers called Bulldogs in bowler hats. They're allowed to arrest students. They mostly just say hello."], "down", "wander")
    chat(z, "ox_bookseller", "poet", 22, 29, "Bookseller",
         ["Oxford University Press is one of the oldest university presses in the world, and there are more bookshops here than I can count, and I try. Blackwell's has a floor called the Norrington Room, with three miles of shelves.",
          "Nobody reads the whole of any shelf. They look, they sigh, they buy a postcard. It's a lovely life."], "right")
    chat(z, "ox_runner", "jogger", 5, 31, "Towpath Runner",
         ["I run the towpath along the Thames. The college boathouses are all along it, and in Eights Week the eights bump each other, which is a rowing race where you try to hit the boat in front. Gentle, it isn't.",
          "Cox shouts. Everyone else is busy. It's a good arrangement."], "up", "wander")
    chat(z, "ox_cherwell", "angler", 67, 29, "Cherwell Angler",
         ["The Cherwell comes down from Northamptonshire and joins the Thames here. It's called 'Charwell', not 'Cherwell', by anyone who went to school nearby.",
          "That's the sort of thing Oxford does. Magdalen is 'Maudlin' and Cherwell is 'Charwell'. Nobody says it right on purpose."], "left")
    chat(z, "ox_bobby", "villager_2", 36, 42, "Meadow Walker",
         ["Christ Church Meadow has had cattle in it since before the college. They are Longhorns, so you'll have to give way. The cows have the right of way, the Dean has the right of way and the Dean's cat has it, too.",
          "The Meadow is the loveliest walk in the city. Sometimes the river floods it. Then it's a different walk."], "down")
    trainer(z, "ox_fresher", "Fresher Pippa", "Fresher", "gown_student",
            [("zigzlet", 89), ("bobbin", 90), ("rooklet", 90)], 40, 17, "right",
            ["First week and I've already lost my gown, my bike and my sense of direction. Fighting's the only thing I know how to do here."],
            "Oh! You're good. Do you do tutorials? I'm told they are different from this.",
            "Matriculation is when you join the University. You wear subfusc, which is the formal black and white, and a mortarboard you carry rather than wear. If you wear it, you won't graduate. That's the rule.", 4400)
    trainer(z, "ox_cyclist", "Cyclist Imogen", "Cyclist", "jogger",
            [("cooplet", 89), ("parakit", 90), ("binfox", 90), ("pipkin", 90)], 20, 29, "right",
            ["I have the right of way, the right bike and a basket with a baguette in it. It's a cliché and it's mine. En garde."],
            "Fair enough. Mind the cobbles, they've broken better bikes than mine.",
            "Oxford has more cyclists than cars in the centre, and a thing called Bicycle Theft, where the bikes go missing on the same days as the students. Lock it twice. Then once more.", 4300)
    trainer(z, "ox_porter", "Head Porter Mr Bowler", "Head Porter", "warden_grunt",
            [("grizzlet", 90), ("brockling", 90), ("tubemole", 90), ("legionette", 90)], 43, 38, "up",
            ["Visitors to the college may not walk on the grass. I'm afraid that also applies to creatures. Shall we step outside?"],
            "Well. Carry on, Madam or Sir. I'll make a note of it in the Porter's book.",
            "A head porter knows everything: whose bike is whose, who's staying where and who's been out after Great Tom. The Porter's Lodge is the best-informed place in any college and the only one that never sleeps.", 4800)
    trainer(z, "ox_punter", "Punter Rory", "Punter", "sailor",
            [("volet", 89), ("dipling", 90), ("holtling", 90), ("stalklet", 90)], 66, 37, "right",
            ["In Oxford we stand at the sloping end, as God and the Cherwell intended. The Cambridge lot stand on the till. Shocking."],
            "Splash! I should have seen that coming. It's in the pole's nature to stick in the mud.",
            "Never let go of the pole if it sticks in the mud. You'll either be pulled out of the punt or lose your pole. Everybody has done it once.", 4200)
    trainer(z, "ox_chorister", "Chorister Felix", "Chorister", "choir_singer",
            [("starlet", 89), ("bansheen", 90), ("wispet", 90)], 56, 29, "down",
            ["I'm in the Magdalen choir. On May Morning I sing from the top of the tower at six in the morning, in a surplice, in the cold, with a hangover from the night before. It's glorious."],
            "A cappella defeat. I'll go and stand on a tower and think about it.",
            "On 1 May at six the choir sings the Hymnus Eucharisticus from Magdalen Tower. There's morris on the street, the bells ring and people jump into the Cherwell off the bridge. Not any more, it's roped off. They did, a lot.", 4100)
    trainer(z, "ox_rower", "Cox Beatrice", "Rower", "student",
            [("elverlet", 89), ("volet", 90), ("cranelet", 90)], 30, 48, "down",
            ["Stroke, stroke, stroke! I'm the cox, which means I sit in the stern and shout. The best seat in the boat and the lightest."],
            "A clean race. Hmm, 'bump', I suppose that's one way of saying 'lost'.",
            "In Torpids and Eights Week, the college boats start in a line and chase the boat in front. Catch it and touch it and that's a bump, and you swap places. You can do that four days running, and be Head of the River.", 4200)

    # Magdalen Bridge: the Sloping End
    chat(z, "ox_poet", "bard", 21, 28, "Street Poet",
         ["'That sweet city with her dreaming spires.' Matthew Arnold, 1866. I have it on a mug.",
          "The spires are not all dreaming, by the way. Some of them are leaning on cranes. Preservation is a long job."], "right")


def oxford_interiors(OUT, zid, landmark):
    """the walk-in rooms (zones <zid>_*): arrival at the foot of the room, exit door at the bottom middle."""
    landmark(OUT, "oxford_bodleian", "Bodleian Library", zid, (42, 15), "library",
             [dict(id="ox_librarian", sprite="poet", x=7, y=3, facing="down", move="still", script="ox_librarian", name="Librarian"),
              dict(id="ox_reader", sprite="gown_student", x=11, y=6, facing="left", move="still", script="ox_reader", name="Reader")], w=15, h=11)
    landmark(OUT, "oxford_camera", "Radcliffe Camera", zid, (53, 17), "library",
             [dict(id="ox_camera_clerk", sprite="astronomer", x=6, y=3, facing="down", move="still", script="ox_camera_clerk", name="Reading Room Clerk"),
              dict(id="ox_camera_student", sprite="student", x=10, y=5, facing="left", move="still", script="ox_camera_student", name="Student")])
    landmark(OUT, "oxford_natural", "Museum of Natural History", zid, (42, 9), "museum",
             [dict(id="ox_dodo", sprite="creature:dodo", x=4, y=4, facing="right", move="still", script="ox_dodo", name="Dodo", hide_if="caught_dodo"),
              dict(id="ox_natural_curator", sprite="tour_guide", x=11, y=3, facing="left", move="still", script="ox_natural_curator", name="Curator"),
              dict(id="ox_natural_sketcher", sprite="student", x=3, y=7, facing="up", move="still", script="ox_natural_sketcher", name="Sketcher")], w=15, h=11)
    landmark(OUT, "oxford_pitt", "Pitt Rivers Museum", zid, (54, 9), "museum",
             [dict(id="ox_pitt_curator", sprite="explorer", x=9, y=4, facing="left", move="still", script="ox_pitt_curator", name="Curator"),
              dict(id="ox_pitt_visitor", sprite="hiker", x=4, y=6, facing="right", move="still", script="ox_pitt_visitor", name="Visitor")])
    landmark(OUT, "oxford_eagle", "The Eagle and Child", zid, (27, 14), "cafe",
             [dict(id="ox_landlord", sprite="shopkeeper", x=3, y=1, facing="down", move="still", script="ox_landlord", name="Landlord"),
              dict(id="ox_quizmaster", sprite="fiddler", x=6, y=4, facing="left", move="still", script="ox_quizmaster", name="Quizmaster"),
              dict(id="ox_don", sprite="poet", x=4, y=5, facing="right", move="still", script="ox_don", name="Don Percival"),
              dict(id="ox_inkling", sprite="bard", x=10, y=4, facing="left", move="still", script="ox_inkling", name="Writer")])
    landmark(OUT, "oxford_christchurch", "Christ Church", zid, (50, 38), "hall",
             [dict(id="ox_dean_guide", sprite="tour_guide", x=8, y=4, facing="down", move="still", script="ox_dean_guide", name="Guide"),
              dict(id="ox_proctor", sprite="gown_student", x=4, y=7, facing="right", move="still", script="ox_proctor", name="Senior Proctor Clementine")], w=15, h=11)
    landmark(OUT, "oxford_market", "Covered Market", zid, (40, 29), "hall",
             [dict(id="ox_cheesemonger", sprite="shopkeeper", x=4, y=2, facing="down", move="still", script="ox_cheesemonger", name="Cheesemonger"),
              dict(id="ox_pieman", sprite="villager_4", x=9, y=4, facing="left", move="still", script="ox_pieman", name="Pie Stall"),
              dict(id="ox_marmaladier", sprite="jam_maker", x=6, y=5, facing="up", move="still", script="ox_marmaladier", name="Marmalade Stall")])
    landmark(OUT, "oxford_oed", "Oxford English Dictionary", zid, (19, 22), "library",
             [dict(id="ox_lexicographer", sprite="poet", x=4, y=3, facing="right", move="still", script="ox_lexicographer", name="Lexicographer"),
              dict(id="ox_wordsmith", sprite="student", x=9, y=5, facing="left", move="still", script="ox_wordsmith", name="Reader")])
    landmark(OUT, "oxford_ashmolean", "Ashmolean Museum", zid, (19, 8), "museum",
             [dict(id="ox_ashmolean_guide", sprite="tour_guide", x=10, y=4, facing="left", move="still", script="ox_ashmolean_guide", name="Guide")], w=15, h=11)
    landmark(OUT, "oxford_boathouse", "Magdalen Bridge Boathouse", zid, (68, 43), "cafe",
             [dict(id="ox_boatman", sprite="sailor", x=3, y=1, facing="down", move="still", script="ox_boatman", name="Boatman")], w=11, h=9)


# ------------------------------------------------------------------------------------------------ scripts
def write(DLG, TRN, scale):
    def put(zone, sid, cmds):
        DLG.setdefault(zone, {})[sid] = cmds

    # ========================================================== quest: the Cooper's Hill cheese race
    C = "q_cotswolds_cheese"
    put("cotswolds", "cw_master", [
        iff(C + "_done", s("Master of Ceremonies",
            "Our champion! Your name will be called down the hill every spring, and nobody will remember it. That's how the glory works.",
            "Mind the cheese. It's in the dairy. It has a mind of its own, and a very good lawyer."),
            [iff(C + "_2", [
                {"do": "choice", "text": "Take your place at the top of Cooper's Hill? Three chasers, back to back, no rest between.", "options": ["On my marks", "Not yet"], "set": "_cheese_choice"},
                {"do": "if", "flag": "_cheese_choice", "eq": 0,
                 "then": s("Master of Ceremonies", "Ladies and gentlemen! Down the hill, after the cheese! On the count of three... One, two, THREE!")
                 + [{"do": "gauntlet", "trainers": ["cots_chaser_a", "cots_chaser_b", "cots_legend"], "flag": C + "_3", "prize_from": "the Hill",
                     "exit": {"zone": "cotswolds", "x": 12, "y": 55},
                     "lose_line": "You come round at the bottom of the hill, covered in grass and mud. The cheese is long gone. So is your dignity, but it comes back."},
                    iff(C + "_3", s("Master of Ceremonies",
                        "First to the bottom! The cheese is yours, and it has rolled itself into your bag, which is a first.",
                        "A Double Gloucester is made from the milk of the Gloucester cow, which is a rare breed with a white stripe over the back. The cheese is pressed, turned and left to ripen for months, and then thrown down a hill. It's a great respect.",
                        "Take this wheel, and this one, from the dairy. And the Cooper's Hill ribbon. A lovely thing to wear to a funeral.")
                        + sett(C + "_done") + [item("double_gloucester", 3), item("coopers_wheel"), standing(5)])],
                 "else": s("Master of Ceremonies", "No hurry. The hill has waited since before records began. Take a breath, and a flask of tea.")}],
             [iff(C + "_started", s("Master of Ceremonies", "See the cheesemaker at the Dairy, at the bottom of the hill. She knows the rules. I only know the shouting."),
              s("Master of Ceremonies",
                "Welcome to Cooper's Hill! Each spring bank holiday, a round of Double Gloucester is rolled down this slope and anyone who dares chases it. The first to the bottom wins the cheese.",
                "The hill is so steep that the cheese reaches 70 mph and the people reach the ground in a variety of ways. They've been doing it for at least two hundred years.",
                "We're short of a competitor for the creature version. Would you take part? See the cheesemaker at the Dairy first: she'll tell you the rules and want to see a Gloucelet.")
              + sett(C + "_started"))])])])
    put("cotswolds_dairy", "cw_cheesemaker", [
        iff(C + "_done", s("Cheesemaker",
            "Double Gloucester, cloth-bound, turned every day. It's the colour of a good sunset and goes with everything except a diet.",
            "The 'double' means a double-size wheel, made from full-cream milk, so it matures into a rich, nutty cheese. The orange colour was originally added so that it looked like the richer cheese. Annatto. It's from a seed."),
            [iff(C + "_2", s("Cheesemaker", "Off you go to the Master. And do me a favour: let the cheese win now and then. It's good for its self-esteem."),
              [iff(C + "_1", [when("has_gloucelet", s("Cheesemaker",
                    "Look at that! A Gloucelet, round as a good wheel and twice as stubborn. It is, as far as anyone knows, made of mostly cheese and a bit of attitude.",
                    "Right. You're ready. The Master's waiting at the top of the hill.") + sett(C + "_2"),
                  s("Cheesemaker", "You need to have a Gloucelet to show first. They live in the tall grass on the wold and on the hill. Look for something round, orange and furious. It rolls when it's cross."))],
                [iff(C + "_started", s("Cheesemaker",
                    "The rules of the race? Easy. There aren't any. A round of Double Gloucester, about three to four kilos in a wooden case, is launched at the top; it gets a start, and everyone follows. First to the bottom wins the cheese.",
                    "Nobody catches the cheese. It moves faster than a car on a motorway. The winner is the one who crosses the line first, which is usually the one who didn't fall over.",
                    "Now, the creature version. You'll need a Gloucelet: the wheel of Double Gloucester that learned to roll for itself. Catch one on the hill or the wold and show me.") + sett(C + "_1"),
                    s("Cheesemaker",
                      "Cooper's Hill Dairy. Double Gloucester made as it was in the vale: full-cream milk, a cloth, a press and patience.",
                      "If you're after the cheese-rolling, the Master of Ceremonies is at the top of the hill."))])])])])
    put("cotswolds_dairy", "cw_dairyshop", s("Dairy Hand",
        "We make the wheels, then we turn them every day for weeks. If we stop turning, the rind goes wrong. There's a rhyme: turn it, brush it, leave it alone. I don't remember the rest, I've been turning.",
        "A Double Gloucester that's rolled down Cooper's Hill is never for eating. They use a lookalike wheel for the race, and a lovely real one for the winner."))
    plain_trainer(TRN, "cots_chaser_a", "Chaser Tamsin", "Cheese Chaser", "jogger",
                  [("leveret", 89), ("cooplet", 90), ("kitelet", 90)],
                  ["Head first, feet second, brain not at all. That's the Cooper's Hill method. You're not very fast, are you?"],
                  "Ow! Head over heels. In the best tradition, I suppose.", 3800)
    plain_trainer(TRN, "cots_chaser_b", "Chaser Barry", "Cheese Chaser", "rugby_player",
                  [("grizzlet", 90), ("brockling", 90), ("scuttlet", 90), ("roachroo", 90)],
                  ["I've been down this hill eleven times. Two ambulances and a nice bit of cheese. I'm in shape."],
                  "Fair play. I'll have a bit of a lie down at the bottom with the others. Mind the ambulance.", 4000)
    plain_trainer(TRN, "cots_legend", "Gloria the Gloucester Gazelle", "Cheese Champion", "fell_runner",
                  [("gloucelet", 91), ("herdlet", 90), ("foalmoor", 90), ("brockling", 90), ("thistlet", 90), ("loaghtan", 91)],
                  ["Eleven cheeses. Eleven! They call me the Gloucester Gazelle, mostly because they can't catch me. Down the hill, if you can. Hold on to something."],
                  "Twelve cheeses next year. You've earned that one. I'm only slightly sulking.", 6500)

    # ========================================================== quest: count the Rollright Stones
    R = "q_cotswolds_stones"

    def counter(nid, n, flag, line):
        put("cotswolds", nid, [
            iff(R + "_started", [iff(flag, s("Counter", line[1]),
                s("Counter", line[0]) + sett(flag))],
                s("Counter", "I'm counting the stones. It's harder than it looks. Do you know, I think I've got the same number twice? No. That can't be right."))])

    counter("cw_count_n", 77, R + "_1", ("From up here... that's seventy-seven. No, seventy-six, one has a lichen that looks like a stone. Right, seventy-seven. I'm writing it down before it changes.",
                                         "I've written down seventy-seven. If it changes by the time I get home, I'm blaming the stones."))
    counter("cw_count_e", 73, R + "_2", ("On this side I make it seventy-three! Wait. Did we start at that one? Hmm. Seventy-three. Perhaps it was the other way round.",
                                         "Seventy-three, and nothing you can say will change my mind. The stones can try."))
    counter("cw_count_w", 79, R + "_3", ("Seventy-nine! Are there more of them than there were this morning? There's a stone in the bushes that wasn't there when I counted on the other side.",
                                         "Seventy-nine, I tell you. There's a mound. There's a root. There's a stone in a hat. It's fine."))
    put("cotswolds", "cw_warden", [
        iff(R + "_done", s("Stone Keeper",
            "The King's Men have let you count them. That doesn't happen often. Most people go away muttering a number and not quite sure of it, which is the correct response.",
            "If you ever do count the same number three times, come and tell me. I'll tell the King. He'll be thrilled."),
            [iff(R + "_started", [iff(R + "_1", [iff(R + "_2", [iff(R + "_3", s("Stone Keeper",
                    "Seventy-seven, seventy-three and seventy-nine! Three counts, three answers. Quite right. You can't count them the same twice. Nobody has, in as long as we've been keeping the legend.",
                    "The usual number they give is seventy-seven, but it's an estimate. Some stones have fallen, some are buried and some are only stumps, and the ring is a circle, which is a terrible shape to count round. Well done.",
                    "The old way was to put a bun on each stone, and a baker did just that, and got the number wrong. Take this pebble. It has been standing about with the King's Men since 2500 BC, so it knows how to hold its position.")
                    + sett(R + "_4", R + "_done") + [item("rollright_pebble"), item("banbury_cake", 2), standing(5)],
                    s("Stone Keeper", "One more count to go. Try the west side of the ring."))],
                    s("Stone Keeper", "Two counts to go. East side of the ring next."))],
                    s("Stone Keeper", "Count them from the north side, from the east and from the west. Three counters are already out there. Ask each how many they get."))],
             s("Stone Keeper",
               "Welcome to the Rollright Stones. The King's Men are the circle, the King is the stone across the road, and the Whispering Knights are the leaning ones over there, plotting.",
               "The legend: a king and his men were marching on England when a witch told him, 'Seven long strides shalt thou take, and if Long Compton thou canst see, King of England thou shalt be.' A mound rose up, he couldn't see the village, and she turned him to stone.",
               "You can't count the stones the same twice. They won't let you. Would you have a go? Three counts, from three sides, and let me know what numbers you get.")
             + sett(R + "_started"))])])

    # ========================================================== Cotswolds interiors
    put("cotswolds_church", "cw_churchwarden", s("Churchwarden",
        "St Edward's. Look up at the roof and the great windows; the wool merchants paid for all this and we are still thanking them. You could say every stone of it has a sheep somewhere in the accounts.",
        "Outside, the north door sits between two ancient yews. They look like two guardians, and some say Tolkien had them in mind for the doors of Moria. We don't make any claims. We just stand them well."))
    put("cotswolds_woolhouse", "cw_woolman", s("Wool Stapler",
        "A stapler grades wool by how long the fibres are. Cotswold wool is long, lustrous and heavy, perfect for the cloth of kings. A bale was one of the most valuable things a man could own.",
        "The wool was sold at the fairs, bought by merchants from as far away as Italy, and shipped across the sea. A Cotswold sheep once had customers in Florence."))
    put("cotswolds_woolhouse", "cw_fleecegirl", s("Spinner",
        "Wool goes through carding, spinning, weaving and fulling. Fulling is when it's pounded in water, which makes it thick. Cotswold villages are full of old fulling mills, and the ones on the Windrush are the prettiest.")
        + [{"do": "daily", "key": "cotswolds_fleece_day",
            "then": s("Spinner", "Here, a hank of Cotswold fleece, straight off the Lion. It smells like a sheep in the rain. I think it's lovely.") + [item("cotswold_fleece")],
            "else": s("Spinner", "That's your fleece for today. The sheep need a bit of fleece left for themselves.")}])
    put("cotswolds_fleece", "cw_landlord", s("Landlord",
        "Welcome to the Fleece. There's an old Cotswold rhyme about a wool pub for every mile. I don't know if that's true, but they all seem to have been called the Fleece or the Woolpack.",
        "Have a half of the local and a ploughman's. Cheese, pickle, bread. Double Gloucester, naturally."))
    put("cotswolds_fleece", "cw_quizmaster", s("Quizmaster",
        "Quiz night at the Fleece! Five questions, no phones, and no arguing about the Rollright count. We've had a stand-off.",
        "Rules: no phones, no shouting out and no arguing with the Quizmaster. He is always right, even when he is wrong.") + [
        {"do": "choice", "text": "Fancy a round? Five questions, no phones.", "options": ["Count me in", "Not tonight"], "set": "_quiz_choice"},
        {"do": "if", "flag": "_quiz_choice", "eq": 0,
         "then": [{"do": "quiz", "pub": "cotswolds", "region": "england_south", "who": "Quizmaster"}],
         "else": s("Quizmaster", "Suit yourself. The crisps are cheese and onion either way.")}])
    put("cotswolds_model", "cw_modelman", s("Model Maker",
        "The Model Village is a copy of the village at one-ninth scale, built from local stone in 1937. It has a church, shops, a pub and a river with bridges. Everything is the right size and all of them are wrong.",
        "In the model, there's a model of the model village. Inside that, a model of the model of the model. We've lost count. There may be a lot of them. That's the thing about recursion."))

    # ========================================================== quest: the Bodleian oath and the lost leaf
    B = "q_oxford_bodleian"
    OATH = ("I hereby undertake not to remove from the Library, or to mark, deface, or injure in any way, any volume, document or other object belonging to it or in its custody; "
            "not to bring into the Library or kindle therein any fire or flame, and not to smoke in the Library; and I promise to obey all rules of the Library.")
    put("oxford_bodleian", "ox_librarian", [
        iff(B + "_done", s("Librarian",
            "The leaf is back in its folder, the Bestiary is whole and the reader is writing very long letters of apology. Thank you.",
            "The Bodleian has over 13 million printed items on over 100 miles of shelves. A great many of them in the stacks underneath Broad Street, where you can't see them and nobody can hear you."),
            [iff(B + "_3", s("Librarian",
                "The leaf! Safe, in one piece, and with only a slight smell of beer. He took it to the pub to read by the fire? That's two breaches of the Declaration in one go.",
                "The Ashmole Bestiary is a twelfth-century book of beasts, real and imagined, and famous for its lions. I'm so glad to have the leaf back.",
                "Take this Reader's Ticket, with my thanks. And a Banbury cake or two. Not in the reading room, though. Outside. With the pigeons.")
                + sett(B + "_4", B + "_done") + [item("readers_ticket"), item("banbury_cake", 2), standing(5)],
              [iff(B + "_2", s("Librarian", "The Eagle and Child? He's taken a medieval leaf to a pub. I need to sit down. The back room, the Rabbit Room, I think. He's a don. Find him."),
                [iff(B + "_1", s("Librarian", "Ask in the Radcliffe Camera, across the square. The clerk in the reading room sees everything and says nothing, except to me."),
                  [iff(B + "_started", s("Librarian", "You haven't made the Declaration yet. I can't take you any further until you do. It's the rule."),
                    [{"do": "choice", "text": "The Bodleian Library: to read here you make the Declaration. Take the oath?", "options": ["I do", "Not yet"], "set": "_oath_choice"},
                     {"do": "if", "flag": "_oath_choice", "eq": 0,
                      "then": s("Librarian",
                          "Repeat after me. '" + OATH + "'",
                          "Marvellous. That's all it takes. It's been said, in one form or another, for four centuries, and the bit about fire and flame is there because there was a lot of both about. The library has never once burned. Knock on a bookshelf.",
                          "Now. I've a problem I can only share with someone who has made the oath. A leaf is missing from the Ashmole Bestiary, a page with a very rare beast painted on it. A reader took it, and he's a don, which is worse.",
                          "He was last seen heading for the Radcliffe Camera. See the clerk in the reading room, across Radcliffe Square, and find out where he went. And no fire. Even your Kindlets.") + sett(B + "_started", B + "_1"),
                      "else": s("Librarian", "Whenever you're ready. It's very short, and the penalty for breaking it is mostly shame.")}])])])])])])
    put("oxford_bodleian", "ox_reader", s("Reader",
        "I've sworn the Declaration three times. Once as an undergraduate, once as a doctoral student, once when I lost the card.",
        "You can't take anything out. You can't mark it. And you can't light so much as a candle. We read in rooms with the lights on and our hands, like the Declaration says, strictly to ourselves."))
    put("oxford_camera", "ox_camera_clerk", [
        iff(B + "_1", [iff(B + "_2", s("Reading Room Clerk", "The Eagle and Child, the back room. I've told you everything. My lips are sealed. Mostly."),
            s("Reading Room Clerk",
              "A reader in a mackintosh with ink on the cuffs came through here with something flat under his coat, looking shifty. I said 'You can't take that out.' He said it was a copy.",
              "Then he mentioned a fire, and I said you can't have one in here, and he said he was going somewhere with a bit more atmosphere, by a fire, with a pint. He went out by the Catte Street door, muttering about a Bird and a Baby.",
              "Bird and a Baby. That's the Eagle and Child, up St Giles. They all go there. Tell the Librarian I said nothing.") + sett(B + "_2"))],
            s("Reading Room Clerk",
              "The Radcliffe Camera. Built from 1737 to 1749 with the money of Dr John Radcliffe, a royal physician who never married and left his fortune to books.",
              "It was a science library first, then the Bodleian took it over in 1860. The reading room is on the upper floor, under the dome, with perfect acoustics and perfect silence. You may think about whispering. Don't."))])
    put("oxford_camera", "ox_camera_student", s("Student",
        "I read here to look at the dome. It's a trick. You look up, and for a second you think you've understood Latin.",
        "Everyone says the Camera is round because Gibbs wanted a rotunda. 'Camera' is Latin for a room. It has nothing to do with photographs, though people sometimes take them. Outside."))
    put("oxford_eagle", "ox_don", [
        iff(B + "_3", s("Don Percival", "I'm off to the Bodleian to apologise in person. Possibly in writing, possibly in verse."),
            [iff(B + "_2", s("Don Percival",
                "A bestiary leaf? I? What a suggestion. I'm merely, ah, reading a leaf. By a fire. In the pub where the Inklings met. It's atmospheric. It's research!")
                + [{"do": "battle", "trainer": "ox_don", "intro": True},
                   iff("trainer_ox_don", s("Don Percival",
                       "Oh, take it. It's been a joy and a worry. I've sworn the Declaration three times and this is the first time I've broken it. Not the fire, I haven't lit it. The fireplace is somebody else's.",
                       "Tell the Librarian I'll write. In Latin, so it won't be read.") + sett(B + "_3"))],
                s("Don Percival",
                  "Welcome to the Eagle and Child. Do sit down, and don't mind me. I'm reading. Nothing important. A leaf, of the... ah. Of the news. Of the day."))])])
    plain_trainer(TRN, "ox_don", "Don Percival", "Don", "poet",
                  [("glowmite", 89), ("zigzlet", 90), ("hootlet", 90), ("pooka", 90)],
                  ["I demand the right to finish my pint! And to read in peace. And to... ah, fight, I suppose. I'm a don. I'm in the habit of disagreeing."],
                  "A palpable hit. I yield. Mind the leaf, it's older than the pub, the college and my sense of shame.", 4600)
    put("oxford_eagle", "ox_landlord", s("Landlord",
        "The Eagle and Child, known as the Bird and Baby. It's the pub where the Inklings met, the writers' group, in the back room from the 1930s to 1962.",
        "Tolkien and Lewis read chapters aloud on Tuesday lunchtimes and criticised them with great enthusiasm. A great many of the arguments about whether they were any good happened right here."))
    put("oxford_eagle", "ox_inkling", s("Writer",
        "I'm writing a book in the back room. Not really, but it's polite to look as though you might be.",
        "The Inklings read their work aloud and everyone was rude about it. It's called constructive criticism. The 'constructive' bit is optional."))
    put("oxford_eagle", "ox_quizmaster", s("Quizmaster",
        "Quiz night at the Eagle and Child! Five questions, no phones, and nobody quoting Tolkien at me. I've had enough of hobbits for one night.") + [
        {"do": "choice", "text": "Fancy a round? Five questions, no phones.", "options": ["Count me in", "Not tonight"], "set": "_quiz_choice"},
        {"do": "if", "flag": "_quiz_choice", "eq": 0,
         "then": [{"do": "quiz", "pub": "oxford", "region": "england_south", "who": "Quizmaster"}],
         "else": s("Quizmaster", "Suit yourself. The crisps are salt and vinegar either way.")}])

    # ========================================================== Oxford: the dodo and the museums
    put("oxford_natural", "ox_dodo", s("",
        "Behind the glass, the Oxford dodo looks back at you with enormous sorrow. A card reads: THE ONLY SOFT TISSUE OF A DODO ANYWHERE IN THE WORLD.",
        "Then the glass is just a window, and the dodo is just a bird, and it steps out of the case and lets out a long, low, hooting sigh. Evidently it has been waiting a very long time for someone to ask.")
        + [{"do": "legend", "species": "dodo", "level": 92, "flag": "caught_dodo", "music": "legend"}])
    put("oxford_natural", "ox_natural_curator", s("Curator",
        "The Museum of Natural History opened in 1860, in a Gothic building with an iron and glass roof like a cathedral for animals. In 1860 it hosted the great debate about Darwin's theory, between Bishop Wilberforce and Thomas Huxley.",
        "The dodo is the pride of the museum. It was a stuffed bird in the Ashmolean's first collection, which rotted and was thrown out, but its head and foot were saved. They are the only soft tissue of a dodo anywhere in the world.",
        "Dodos lived on Mauritius until the 1600s and were gone within about eighty years. Alice Liddell visited this museum as a child, and Lewis Carroll put the Dodo in her story. He was a sort of Dodo himself, in his own account."))
    put("oxford_natural", "ox_natural_sketcher", s("Sketcher",
        "I'm drawing the swifts. There's a colony in the tower, and in summer they scream around it in a gang. They hardly ever land at all.",
        "Look at the columns. Each column is a different British rock, and the capitals are carved with different plants, by Irish stonemasons, the O'Shea brothers, who also put in the stone animals."))
    put("oxford_pitt", "ox_pitt_curator", s("Curator",
        "The Pitt Rivers Museum is arranged by type, not by place. A case of masks, a case of musical instruments, a case of boats. You can see how the same idea was solved in lots of ways around the world.",
        "It opened in 1884, when Lieutenant-General Augustus Pitt Rivers gave the University his collection of 22,000 objects. It has more than 500,000 now, in cases packed so tight that the labels are handwritten and some of the drawers stick.",
        "Look for the witch bottles. People once buried them under hearths, full of pins and hair, to catch a curse before it got into the house."))
    put("oxford_pitt", "ox_pitt_visitor", s("Visitor",
        "It's dark in here on purpose, to protect the objects. It's also dark because they've never changed the bulbs. I've heard both.",
        "There's a totem pole at the middle, over ten metres tall, from the Haida people of Canada. It rises through every floor, and the museum has a lovely way of making you feel small."))
    put("oxford_ashmolean", "ox_ashmolean_guide", s("Guide",
        "The Ashmolean is Britain's oldest public museum, opened in 1683. It started with the cabinet of curiosities of the Tradescants, father and son, gardeners to the king.",
        "The treasure is King Alfred's Jewel, a gold and enamel pointer for reading, found in Somerset in the 1690s. It says, in Old English, 'Alfred ordered me made'. Not bad for a book mark.",
        "Their old collection had a dodo. It rotted in 1755, and was ordered burned, but someone saved the head and foot. So you can thank a clerk with a good eye for the dodo in the other museum."))
    put("oxford_christchurch", "ox_dean_guide", s("Guide",
        "Christ Church, founded by Cardinal Wolsey in 1525 and refounded by Henry VIII in 1546. It's a college and a cathedral at the same time, the only place in the world that can say that, and the smallest cathedral in England.",
        "Alice Liddell was the Dean's daughter. Charles Dodgson, who wrote as Lewis Carroll, was the mathematics tutor. In 1862 he rowed her up the river and told the story of Alice's Adventures in Wonderland. There's a stained glass window with Alice in it, in the hall.",
        "And the Great Hall's portraits include thirteen prime ministers. The staircase to it is the one in all the films, and in none of them is it as steep as it is in real life."))
    put("oxford_christchurch", "ox_proctor", [
        iff("trainer_ox_proctor", s("Senior Proctor Clementine", "Splendid. I shall report that the Proctors have been defeated. That will be the first time in living memory. I'll put it in the Gazette."),
            s("Senior Proctor Clementine",
              "Do you see the bow tie? The black gown? The two men in bowler hats standing behind me? They are the Bulldogs, and I am the Senior Proctor, and I have the power to fine you. Possibly arrest you.",
              "It's an old power, from the 1200s, when the University was in constant argument with the townspeople. It's still law, and still used. We carry it on a good day with a smile.")
            + [{"do": "battle", "trainer": "ox_proctor", "intro": True}])])
    plain_trainer(TRN, "ox_proctor", "Senior Proctor Clementine", "Senior Proctor", "gown_student",
                  [("hushwing", 91), ("tubemole", 90), ("pooka", 90), ("glisglis", 90), ("rooklet", 91), ("wispet", 91)],
                  ["Let it be recorded that on this day the University did call upon the visitor to explain themselves. In a fair fight. Bulldogs, stand back."],
                  "Well fought. I'll waive the fine. And the right to detain you. Just this once.", 7000)
    put("oxford_market", "ox_cheesemonger", s("Cheesemonger",
        "Double Gloucester, Oxford Blue, Stinking Bishop. Yes, it's real. It's named after a pear, not a bishop.",
        "The Covered Market opened in 1774 to get the stalls out of the High Street. It's still the place to buy a pie, a cheese or a hat and be mildly insulted by a stallholder who's known your family for years."))
    put("oxford_market", "ox_pieman", s("Pie Stall",
        "A real pork pie, a proper steak pie and a hot sausage roll. We start early because the students have been up all night. It's a social service, really.",
        "Oxford has a thing called the Oxford sausage, made with pork, veal, lemon and sage, and Banbury cakes come from just up the road, spiced currants in flaky pastry. The University has a lot of traditions, and nearly all of them involve food."))
    put("oxford_market", "ox_marmaladier", s("Marmalade Stall",
        "Oxford marmalade is thick-cut Seville orange, a dark, bittersweet, chunky one. Sarah Cooper first made it in 1874 for her husband Frank's grocer's shop on the High Street, and the dons took to it for breakfast. It even went to the Antarctic with Captain Scott.",
        "The Seville oranges only arrive in January for a few weeks. People queue for them. It's the most Oxford thing there is, apart from the queue."))
    put("oxford_oed", "ox_lexicographer", s("Lexicographer",
        "The Oxford English Dictionary! We trace every word back to its first use, with quotations. 'Dodo' is in there, with a note that nobody is sure whether it comes from a Portuguese word for a fool or a Dutch one.",
        "It took seventy years to finish the first edition, from 1857 to 1928. The editor, James Murray, sorted the paper slips in a corrugated iron shed in his garden in north Oxford, called the Scriptorium. His children helped."))
    put("oxford_oed", "ox_wordsmith", s("Reader",
        "Volunteers sent in millions of slips. One of the busiest was an American army surgeon, W. C. Minor, who sent thousands from the secure hospital where he lived. Murray thought he was a colleague for years, and then went to visit.",
        "The Dictionary is online now and updated every quarter. It has more than 600,000 words and never once says no. It just says: 'earliest known use'."))
    put("oxford_boathouse", "ox_boatman", s("Boatman",
        "We hire punts by the hour, from Magdalen Bridge. In Oxford you stand at the sloping end and punt from there, which looks wrong and works fine. In Cambridge they stand on the till at the back.",
        "The first rule: keep hold of the pole. The second rule: pull it out smartly. The third rule: if you hear a splash, it's not you. Possibly. Don't look."))

    scale([t for t in TRN if t.startswith(("cots_", "ox_"))])
