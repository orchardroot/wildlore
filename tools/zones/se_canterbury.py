# Canterbury: the cathedral and Thomas Becket's martyrdom, Chaucer's pilgrims, the city walls and the Westgate,
# the Stour and its weavers, the crooked house, Dane John. Town east of the Kent Downs, region south_east.
from se_common import *
from wcommon import _stand


def build(OUT):
    W, H = 64, 58
    zid = "canterbury"
    z = Z(zid, "Canterbury", W, H, kind="town", region=SE, music="town_york",
          weather={"clear": 30, "drizzle": 26, "sunshine": 20, "fog": 10, "gale": 6, "downpour": 8})
    z.d["stage"] = "city"; z.d["town_id"] = "canterbury"
    z.legend.update({"g": {"tile": "grass", "colour": "#5f8f3e"}, "W": {"tile": "drystone_wall", "colour": "#5c8f3c"}})
    z.rect(0, 0, W, H, ".")
    z.border("T", 2, gaps=[(0, 26, 2, 3), (40, 56, 3, 2)])
    z.scatter(0, 0, W, H, "P", 10, 71, only="T")
    # --- the city walls (Roman, then medieval), with the Westgate and the Riding Gate gap
    for x in range(6, 59):
        z.set(x, 5, "W"); z.set(x, 49, "W")
    for y in range(5, 50):
        z.set(6, y, "W"); z.set(58, y, "W")
    for y in range(23, 29):
        z.set(6, y, ":")
    for x in range(40, 43):
        z.set(x, 49, "=")
    z.rect(7, 6, 51, 43, ":")
    # the main street: St Peter's Street and the High Street, west to east
    z.rect(0, 26, 58, 3, "=")
    z.rect(2, 26, 5, 3, "=")
    sign(z, 3, 25, "CANTERBURY. Pilgrims this way. Please leave your horse outside the walls.")
    z.building(4, 22, 6, 3, "westgate", "Westgate Towers", door=2)
    plaque(z, 10, 25, "canterbury_westgate", "The Westgate",
           "The largest surviving city gate in England, built about 1380 of Kentish ragstone, when the French were raiding the coast. It had gun ports for early cannon, and for centuries it was the city gaol. Traffic squeezed through its arch until 2012.")
    plaque(z, 3, 29, "canterbury_city_walls", "The City Walls",
           "Canterbury was the Roman town of Durovernum Cantiacorum, and the medieval walls follow the line of the Roman ones. More than half of their circuit still stands, about a mile and a half of it, with towers you can walk past and the odd gun loop for a nosy look out.")
    # the River Stour, through the walls, with a weavers' house and the ducking stool
    for y in range(5, 50):
        for x in (15, 16):
            if z.g[y][x] not in "=":
                z.set(x, y, "~")
    for x in (15, 16):
        z.set(x, 5, "W"); z.set(x, 49, "W")
        z.set(x, 40, "#")
    z.prop("boat", 15, 12, variant=0); z.prop("boat", 16, 35, variant=0); z.prop("boat", 15, 44, variant=0)
    z.building(17, 30, 6, 3, "tudor", "The Weavers", door=2)
    plaque(z, 23, 33, "canterbury_weavers", "The Weavers",
           "Protestant Huguenot and Walloon refugees fled persecution in France and the Low Countries in the 16th century, and many settled here, weaving silk and wool by the Stour. Outside this house hangs a replica ducking stool, once used to dunk scolds and cheats in the river while the town watched.")
    # --- the cathedral precinct to the north-east
    z.rect(24, 6, 34, 15, "g")
    z.rect(24, 21, 34, 1, "W")
    z.rect(39, 21, 2, 1, "#"); z.rect(39, 16, 2, 5, "#")
    z.building(30, 9, 19, 6, "canterbury_cathedral", "Canterbury Cathedral", door=3)
    z.rect(24, 16, 34, 2, "#")
    for (x, y) in [(26, 8), (52, 8), (55, 12), (26, 13), (50, 19), (28, 19)]:
        z.prop("oak", x, y, variant=x % 3)
    for (x, y) in [(36, 18), (44, 18), (31, 18)]:
        z.prop("bench", x, y)
    blob(z, 54, 15, 2.5, 1.2, ",", only="g", seed=8, jitter=0.3)
    blob(z, 27, 10, 2, 1.5, ",", only="g", seed=9, jitter=0.3)
    plaque(z, 38, 22, "canterbury_christ_church_gate", "Christ Church Gate",
           "The gateway into the cathedral precincts, finished around 1520, with a row of carved angels and heraldic shields. Pilgrims have walked under it for five hundred years, and so do the choristers, every single day, usually late.")
    plaque(z, 32, 16, "canterbury_cathedral", "Canterbury Cathedral",
           "St Augustine came from Rome in 597 and founded a cathedral here, the mother church of the English church ever since. The great central tower, Bell Harry, was finished around 1500. The Archbishop of Canterbury's seat is here.")
    plaque(z, 47, 16, "canterbury_becket", "Thomas Becket",
           "On 29 December 1170 four knights, who believed they were doing what Henry II wanted, murdered Archbishop Thomas Becket in this cathedral. He was made a saint in 1173, and Henry came to do penance at his tomb. For 350 years pilgrims flocked to the shrine, until Henry VIII had it destroyed in 1538.")
    # --- the High Street: buildings on its north side, doors on the street
    z.building(18, 22, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(21, 25, "canterbury_sanctuary", 5, 6, "up")
    z.building(25, 22, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(27, 25, "canterbury_shop", 4, 5, "up")
    z.building(31, 22, 7, 4, "tudor", "Chequer of Hope Inn", door=3)
    z.building(42, 22, 8, 4, "tudor", "The Beaney", door=3)
    z.building(51, 22, 5, 4, "tudor", "Crooked House", door=2)
    for y in range(22, 26):
        z.set(39, y, "#"); z.set(40, y, "#")
    plaque(z, 30, 25, "canterbury_chequer", "The Chequer of the Hope",
           "A great medieval inn stood on this corner, built by the cathedral's monks around 1390 to house pilgrims, with a dormitory that slept a hundred. One 15th-century sequel to Chaucer has his pilgrims lodging here when they arrive.")
    plaque(z, 50, 25, "canterbury_beaney", "The Beaney",
           "The Beaney House of Art and Knowledge, opened in 1899 with money left by James Beaney, a Canterbury boy who became a surgeon in Australia. It is mock-Tudor outside, and inside it is a museum, a library and a gallery, with a room full of cows painted by the Canterbury artist Thomas Sidney Cooper.")
    plaque(z, 57, 26, "canterbury_crooked_house", "The Crooked House",
           "Sir John Boys House, on King's Mile, leans so far that its door frame is cut on a slant to fit. It was built in the 17th century and has been subsiding ever since, because someone altered the chimney. It is a bookshop now. Mind your head, and the floor.")
    # --- south of the High Street: the Marlowe, Chaucer's statue, houses
    z.rect(7, 33, 51, 2, ":")
    z.building(26, 29, 9, 4, "white_render", "Marlowe Theatre", door=4)
    z.building(36, 29, 3, 4, "tudor", "Mercery Lane")
    z.prop("statue", 44, 31, variant=1)
    plaque(z, 42, 31, "canterbury_chaucer", "Geoffrey Chaucer",
           "Chaucer wrote The Canterbury Tales in the 1380s and 90s: a band of pilgrims riding from Southwark to Becket's shrine, each telling tales on the way. It was among the first great works written in English rather than French or Latin. He never finished it; the pilgrims never arrive.")
    plaque(z, 34, 34, "canterbury_marlowe", "Christopher Marlowe",
           "The playwright Christopher Marlowe was born in Canterbury in 1564, the son of a shoemaker, the same year as Shakespeare. He wrote Doctor Faustus and Tamburlaine, and was killed in a fight in Deptford at 29. The theatre here is named after him.")
    z.building(46, 29, 11, 4, "weatherboard", "Burgate")
    z.building(46, 36, 11, 4, "tudor", "Palace Street")
    z.building(24, 36, 9, 4, "flint_cottage", "Greyfriars")
    plaque(z, 23, 40, "canterbury_greyfriars", "Greyfriars Chapel",
           "Built over the Stour in 1267, the first house in England of the Franciscan friars, who arrived in 1224. A tiny building on arches with the river running underneath it, and still a chapel.")
    # --- Dane John Gardens and mound, south-west inside the walls
    z.rect(7, 41, 8, 8, "g")
    hills(z, [(10, 45, 3, 3)])
    z.rect(7, 41, 8, 1, "#")
    blob(z, 13, 47, 1.5, 1.2, ",", only="g", seed=11, jitter=0.3)
    plaque(z, 14, 42, "canterbury_dane_john", "Dane John",
           "The mound in these gardens began as a Roman burial mound and was later part of the Norman castle's defences. Its odd name probably comes from the French donjon, a castle keep. Climb it for a view of the cathedral over the rooftops.")
    # the road south through the Riding Gate gap to Dover, and Canterbury East outside the walls
    z.rect(40, 29, 3, 29, "=")
    station(z, 46, 51, 8, 4, "Canterbury East")
    z.prop("buffer_stop", 45, 54); z.prop("buffer_stop", 54, 54)
    z.rect(43, 53, 3, 1, ":")
    rail_guard(z, 52, 53, ["Canterbury East. Trains to London, and to Dover for the boats.",
                           "All aboard! The pilgrims walked. You don't have to."], facing="left")
    sign(z, 43, 55, "SOUTH TO DOVER. Watling Street, the Roman road from Dover to London, ran right through here. It still does, under the tarmac.")
    # --- NPCs
    chat(z, "cb_verger", "choir_singer", 41, 18, "Verger",
         ["The pilgrims came in their thousands, for the miracles. Monks wrote down hundreds of cures at Becket's tomb: the blind seeing, the lame walking, and one man whose pet bird was brought back to life.",
          "The windows in the Trinity Chapel show some of them. Eight hundred years old and still bright. Quite a lot brighter than the monks' handwriting."], "down", "still")
    chat(z, "cb_student", "student", 20, 28, "Student",
         ["Kent University's just up the hill. Half the city's students in term time, and half of them are lost in the Lanes at any moment.",
          "There's a bit of the Roman theatre under a pub cellar near here. Canterbury's like that: you dig a hole for a shed, you find a Roman."], "down", "still")
    chat(z, "cb_mudlark", "angler", 17, 38, "Mudlark",
         ["Pilgrims bought little lead flasks here, ampullae, full of 'Canterbury water': water with the tiniest drop of Becket's blood mixed in. They wore them round their necks home.",
          "Half the badges and flasks that ever turn up get found in rivers. Lost on the way home, or thrown in for luck. The Stour gives one up now and again."], "right", "still")
    # trainers
    tdef("cb_chorister", "Chorister Benedict", "Chorister", "choir_singer", [("lanternis", 94), ("wispet", 94), ("coblynn", 94)],
         ["Evensong's at half five, and I've got a solo. I'll warm up on you."],
         "Hit a bum note there. Don't tell the Precentor.", "The choir has sung here every day for centuries. Even on Christmas Day. Especially on Christmas Day.", 4000)
    tnpc(z, "cb_chorister", 33, 18, "down")
    tdef("cb_punt", "Punt Guide Tom", "Punt Guide", "sailor", [("spatelord", 94), ("heronarch", 94), ("ratty", 95)],
         ["Punt tour? Mind the low bridges. Mind the herons. Mind your phone: it's been a good year for the river and a bad year for phones."],
         "Out-poled. I'll see myself into the river.", "Look for the kingfishers under the Weavers' windows. Blue flash and gone. Like my tips.", 4000)
    tnpc(z, "cb_punt", 14, 40, "right")
    # the pilgrims in town (q_southeast_pilgrims_*) and the Host who judges them
    from se_kent import pilgrim
    pilgrim(z, zid, "cb_wife", "The Wife of Bath", "festival_goer", 51, 18,
            [("selkie", 95), ("gealhare", 95), ("stagmor", 95), ("connemarr", 95)],
            ["Married five times at the church door, and I've been to Jerusalem three times, Rome, Cologne and Compostela besides. My hat's as broad as a shield. Let's see your mettle."],
            ["My tale: a knight at King Arthur's court does a terrible wrong and must find out, within a year and a day, what women most desire, or lose his head.",
             "An old woman gives him the answer, in return for marrying him: what women want is sovereignty, to have their own way. He lets her choose, and she becomes young and lovely. The lesson is in the letting her choose."],
            "Good. I like a pilgrim with some spirit.", "q_southeast_pilgrims_3")
    pilgrim(z, zid, "cb_pardoner", "The Pardoner", "poet", 12, 29,
            [("hushwing", 95), ("jetwhitby", 95), ("coblynn", 95)],
            ["Relics! Pig bones, holy pig bones I mean, a glass of rags and a sheep's shoulder blade. Very reasonable. Or fight me for nothing."],
            ["Three drunken rioters set out to kill Death, who has taken their friend. An old man tells them Death is under a tree. They find a pile of gold instead.",
             "One goes for wine and poisons it; the other two stab him when he gets back, then drink the wine. All three find Death after all. Radix malorum est cupiditas: greed is the root of evil. Now, about my relics..."],
            "You have no need of my pardons. A pity. For me.", "q_southeast_pilgrims_4")
    pilgrim(z, zid, "cb_nunspriest", "The Nun's Priest", "pilgrim", 17, 41,
            [("sulphurhen", 95), ("binfox", 95), ("redbreast", 95)],
            ["A tale of a cockerel? Yes. A very learned cockerel. Bear with me."],
            ["Chauntecleer the rooster dreams of a beast in the yard, and his wife Pertelote tells him to take a laxative and stop being silly.",
             "Next morning the fox, Russell, flatters him into shutting his eyes to sing, and grabs him. Chauntecleer talks the fox into boasting to the chasing farmers, and when it opens its mouth he flies up a tree. Never trust a flatterer, and keep your eyes open."],
            "Cock-a-doodle-done. Well battled.", "q_southeast_pilgrims_5")
    lo, hi = LV
    wild(z, [("hoplet", lo, hi, 10, {}), ("legionette", lo, hi, 10, {}), ("centurion", hi, hi, 3, {}), ("cooplet", lo, hi, 12, {}),
             ("rooklet", lo, hi, 10, {}), ("binfox", lo, hi, 8, {"time": ["dusk", "night"]}), ("pipkin", lo, hi, 10, {}),
             ("wispet", lo, hi, 8, {"time": ["night"]}), ("grizzlet", lo, hi, 8, {}), ("flittermouse", lo, hi, 6, {"time": ["night"]})])
    wild(z, [("holtling", lo, hi, 14, {}), ("volet", lo, hi, 14, {}), ("dipling", lo, hi, 12, {}), ("stalklet", lo, hi, 12, {}),
             ("croakle", lo, hi, 10, {})], "water")
    # --- interiors
    host(z, zid, OUT)
    cathedral(z, zid, OUT)
    door_to(z, OUT, zid, "canterbury_westgate", "Westgate Towers", (6, 24), "castle", [
        scripted("canterbury_westgate", "wg_curator", "tour_guide", 6, 3, "Curator", [
            IF("q_southeast_becket_2", [IF("q_southeast_becket_3", say("Curator", "Enjoy the view from the roof. On a clear day you can see the cathedral, the university and three people arguing about parking."),
                                          say("Curator", "For the Becket exhibition? Here: a pilgrim badge, found in the Stour in the 1980s. A tiny tin Becket's head in a mitre, with a pin on the back for your hat.",
                                              "Pilgrims bought them by the thousand. They were the medieval fridge magnet.") + [setf("q_southeast_becket_3")])],
               say("Curator", "This was the city gaol for centuries, right up to the 1820s and beyond. The cells are still here. The prisoners weren't keen on the view.",
                   "The gun ports on the towers are some of the earliest built for cannon in England. Very modern. For 1380."))])],
        w=13, h=10, extra_props=[P("display_case", 2, 5), P("display_case", 10, 5)])
    door_to(z, OUT, zid, "canterbury_beaney", "The Beaney", (45, 25), "library", [
        talker("canterbury_beaney", "bn_librarian", "student", 6, 3, "Librarian", [
            "The Beaney was left to the city by James Beaney, who ran away to be a surgeon's apprentice and ended up famous in Melbourne. He wanted a library for working men. He got that and a museum.",
            "Upstairs there's a whole room of cows by Thomas Sidney Cooper. He painted cattle for seventy years. He had very strong opinions about cows."], "down"),
        talker("canterbury_beaney", "bn_bagpuss", "villager_3", 2, 6, "Visitor", [
            "Bagpuss was made near here! Oliver Postgate and Peter Firmin made their programmes in a barn at Blean, just up the road. The Beaney has a little exhibition about them."], "right")])
    door_to(z, OUT, zid, "canterbury_crooked", "The Crooked House", (53, 25), "library", [
        talker("canterbury_crooked", "ck_bookseller", "poet", 6, 2, "Bookseller", [
            "Everything in here is level except the building. The shelves are packed so tight they hold the walls up. Or the walls hold the shelves up. We don't ask.",
            "Charles Dickens put a crooked old house in Canterbury into David Copperfield. People like to think it was this one."], "down")])
    door_to(z, OUT, zid, "canterbury_weavers", "The Weavers", (19, 32), "workshop", [
        talker("canterbury_weavers", "wv_weaver", "villager_5", 6, 3, "Weaver", [
            "My family came over from Flanders in the 1500s with a loom and not much else. The city let us use the crypt of the cathedral as a church, and there's still a French service there.",
            "We wove silk here, by the light off the river. Good light, good water, and nobody minded the clatter."], "down")])
    door_to(z, OUT, zid, "canterbury_marlowe", "Marlowe Theatre", (30, 32), "theatre", [
        talker("canterbury_marlowe", "ml_actor", "poet", 6, 2, "Actor", [
            "Was this the face that launched a thousand ships? That's Marlowe. Doctor Faustus, seeing Helen of Troy. I say it every night. I'm the understudy for the ship.",
            "Marlowe was a spy, they say, for Queen Elizabeth's government. He died in a knife fight in 1593 over a bill, or over something else entirely. Nobody's sure. Theatre loves a mystery."], "down")])
    sanctuary(OUT, zid, "Canterbury", (21, 26), music="sanctuary")
    shop(OUT, zid, "Canterbury", (27, 26))
    nurse(zid, ["Welcome, pilgrim! The Canterbury Sanctuary has been patching up travellers for a while now. Not quite eight hundred years. Let's see them.",
                "Pop them on the counter. A rest, a drink of water. Not Canterbury water, the ordinary sort.",
                "There we are, right as rain. Off you go, and mind the cobbles on Mercery Lane.",
                "The Ark's in the corner. Somebody's put a pilgrim badge on it for luck.",
                "Safe travels, pilgrim. And if anyone tries to sell you a relic, keep walking."])
    shopkeeper(zid, "Good day! Snares, tea and a gypsy tart, if you're quick. What'll it be?",
               "Ta-ra! Mind the cathedral steps. They've had a lot of feet.")
    z.d["edges"] = {"west": {"to": "kent_downs", "offset": -6}, "south": {"to": "dover", "offset": -10}}
    z.d["spawn"] = [3, 27]
    scale_zone(z)
    finish(z)
    z.save(OUT + "/" + zid + ".json")


def host(z, zid, OUT):
    """the Chequer of Hope: Harry the Host judges the pilgrims' tales (q_southeast_pilgrims_*), and runs the quiz."""
    q = "q_southeast_pilgrims_"
    steps = [q + str(i) for i in range(1, 6)]
    told = [{"do": "if", "flag": f, "then": [], "else": say("Host", "Still waiting on a tale or two. The Knight and the Miller are on the Pilgrims' Way in the Kent Downs; the Wife of Bath's in the precincts, the Pardoner's by the Westgate, the Nun's Priest is down by the river.") + [{"do": "end"}]} for f in steps]
    cmds = [IF(q + "done", say("Host", "The tales were told, the supper was eaten, and nobody's paid for the wine. Like the old days."), [
        IF(q + "started", told + say("Host", "Five tales heard, five pilgrims beaten, and every one of them thinks they won. That's a proper contest.",
                                     "Chaucer's Host promised a free supper to the best teller. You heard them all and beat them all: the supper's yours, and something for the road.") +
           [give("gypsy_tart", 4), give("kentish_hops", 3), standing(4), setf(q + "done")],
           say("Host", "{greeting} I'm Harry, the Host. Pilgrims stop here on the way to the cathedral, same as they have since Chaucer's day.",
               "In the Tales, the Host of the Tabard in Southwark sets a contest: each pilgrim tells stories on the road, and the best wins a free supper on the way home.",
               "I've got five pilgrims in town with tales to tell, and none of them will shut up. Go and hear them, and if they want a scrap after, give them one. Then come back and tell me who won.") +
           [setf(q + "started")])])]
    DLG.setdefault("canterbury_chequer", {})["host"] = cmds
    DLG["canterbury_chequer"]["quizmaster"] = say("Quizmaster", "Pilgrims' quiz! Five questions on the islands. No relics allowed as prizes.") + [
        {"do": "choice", "text": "Fancy a round? Five questions.", "options": ["Go on then", "Not tonight"], "set": "_quiz_choice"},
        IF("_quiz_choice", [{"do": "quiz", "pub": "canterbury", "region": "england_south", "who": "Quizmaster"}], say("Quizmaster", "Another time, pilgrim."), eq=0)]
    door_to(z, OUT, zid, "canterbury_chequer", "Chequer of Hope Inn", (34, 25), "cafe", [
        {"id": "host", "sprite": "villager_1", "x": 3, "y": 1, "facing": "down", "move": "still", "script": "host", "name": "Host"},
        {"id": "quizmaster", "sprite": "villager_4", "x": 10, "y": 6, "facing": "left", "move": "still", "script": "quizmaster", "name": "Quizmaster"},
        talker("canterbury_chequer", "ch_pilgrim", "pilgrim", 7, 4, "Tired Pilgrim", [
            "Walked from Southwark. Four days. My feet have their own pilgrimage now, to a bucket of hot water."], "down")])


def cathedral(z, zid, OUT):
    """the cathedral (nave, the Martyrdom) and its crypt below, and the archivist's hunt for Becket's relics."""
    q = "q_southeast_becket_"
    archivist = [IF(q + "done", say("Archivist", "The exhibition's open. The ampulla, the badge, Grim's account. Becket would be mortified. Pilgrims are delighted."), [
        IF(q + "3", say("Archivist", "The badge from the Westgate! And you've stood at the Martyrdom and met Brother Edward in the crypt. That's the whole story, start to finish.",
                        "Please take this: a pilgrim's ampulla, a replica, but filled from the cathedral well. Pilgrims swore by them. I'm not allowed to swear, but it can't hurt.") +
           [give("canterbury_ampulla"), standing(3), setf(q + "done")], [
            IF(q + "started", say("Archivist", "Stand where Becket fell, at the Martyrdom just over there, then go down to the crypt where he was first buried. Then the Westgate museum has a badge for us."),
               say("Archivist", "{greeting} I'm putting together an exhibition on Becket for the pilgrims. I need someone to walk the story with me.",
                   "Start at the Martyrdom, the corner of the north-west transept where he was killed. The verger there knows it best. Then the crypt, where the monks buried him in a hurry that night. Then the Westgate museum, who are lending us a pilgrim badge.") +
               [setf(q + "started")])])])]
    martyr = [IF(q + "1", say("Verger", "Altar of the Sword's Point. Just a stone, a candle, and the shadow of three swords on the wall. It's enough."), [
        IF(q + "started", say("Verger", "This is the Martyrdom. On 29 December 1170, at dusk, four knights came in from the cloister: Reginald FitzUrse, Hugh de Morville, William de Tracy and Richard le Breton.",
                              "Becket refused to run. He told them he was ready to die. One sword blow broke on the stone floor here, and its point snapped off. The monks kept it as a relic: the Sword's Point.",
                              "Henry II was horrified when he heard, or said he was. Four years later he walked barefoot through Canterbury and let the monks whip him at the tomb.") + [setf(q + "1")],
           say("Verger", "This is the Martyrdom, where Thomas Becket died. Please be quiet here. People still come to light a candle."))])]
    rows = None

    def nave(r):
        # a long nave of pillars, the Martyrdom altar in the north-west corner, the steps down to the crypt
        r.d["props"] = [p for p in r.d["props"] if not (13 <= p["x"] <= 15 and 1 <= p["y"] <= 4)]
        r.set(15, 2, "D")
        r.warp(15, 2, "canterbury_crypt", 9, 3, "down")
    door_to(z, OUT, zid, "canterbury_cathedral", "Canterbury Cathedral", (33, 14), "church", [
        scripted("canterbury_cathedral", "archivist", "poet", 8, 2, "Archivist", archivist),
        scripted("canterbury_cathedral", "martyr_verger", "choir_singer", 2, 2, "Verger", martyr),
        talker("canterbury_cathedral", "cat_windows", "villager_2", 15, 5, "Glass Restorer", [
            "The Miracle Windows in the Trinity Chapel show the cures at Becket's tomb, made in the early 1200s. We clean them with cotton buds. One square inch at a time. I'll be done in 2090.",
            "There's a single candle burning in the Trinity Chapel, on the spot where the gold shrine stood until Henry VIII had it smashed and carted away. It took twenty-six carts, they say."], "left")],
        w=17, h=11, edit=nave, extra_props=[P("candelabra", 1, 1), P("candelabra", 4, 1), P("candelabra", 12, 1), P("tomb_chest", 10, 8)])
    tdef("cb_grim", "Brother Edward", "Re-enactor", "pilgrim", [("centurion", 95), ("hushwing", 95), ("longman", 95), ("coblynn", 95)],
         ["En garde! Well, not really. Monks don't en garde. Defend yourself!"],
         "Well struck. Grim would have approved.", "Grim's account says the murderers' last words were, 'Let us away, he will rise no more.' He's had more visitors since than they ever did.", 4600)
    grim = [IF("trainer_cb_grim", say("Brother Edward", "My arm's still sore. Historically speaking."), [
        IF(q + "1", say("Brother Edward", "I play Edward Grim, a monk from Cambridge who happened to be visiting that night. He was the only one who stood by Becket, and a sword nearly took his arm off.",
                        "He wrote what he saw. It's the account everybody uses. Want to know how it felt? Have a go at me. Gently.") + TRN["cb_grim"]["intro"] +
           [fight("cb_grim"), IF("trainer_cb_grim", [setf(q + "2")] + say("Brother Edward", "That's the spirit. Becket lay in this crypt for fifty years, till his shrine upstairs was ready in 1220. Off you go to the Westgate."))],
           say("Brother Edward", "This crypt is the oldest part of the cathedral, Norman, with carved beasts on the capitals. Becket's first tomb was down here. Henry II did his penance here, on his knees, in 1174."))])]
    def crypt(r):
        for x in range(1, r.w - 1):
            if x % 3 == 0:
                r.prop("crypt_arch", x, 1, variant=x % 2)
        for (x, y) in [(5, 4), (13, 4), (5, 7), (13, 7)]:
            r.prop("standing_stone", x, y, variant=2)
        r.prop("tomb_chest", 9, 6)
        r.prop("candelabra", 7, 6); r.prop("candelabra", 11, 6)
        r.set(9, 2, "D")
        r.warp(9, 2, "canterbury_cathedral", 14, 2, "left")
    from zlib import Z as ZZ
    c = ZZ("canterbury_crypt", "The Crypt", 19, 11, fill="+", kind="interior", region="", music="", weather={})
    c.border("x", 1)
    c.d["spawn"] = [9, 3]
    crypt(c)
    c.npc(**scripted("canterbury_crypt", "grim", "pilgrim", 9, 8, "Brother Edward", grim, "up"))
    c.npc(**talker("canterbury_crypt", "crypt_guide", "tour_guide", 15, 5, "Crypt Guide", [
        "Black Prince's chantry is down here, given by Edward the Black Prince when he married in 1361. He's buried upstairs, by the shrine, with his armour hung above him.",
        "The French church still holds a service in this crypt every Sunday, in French, as it has since the Huguenot weavers came."], "left"))
    c.save(OUT + "/canterbury_crypt.json")
