# The South Downs: south of London. The Weald, the chalk scarp up to Ditchling Beacon, Jack and Jill, the
# Long Man of Wilmington, the Seven Sisters and Beachy Head, and Lyminster's knucker hole. Route, region south_east.
from se_common import *
from wcommon import _stand
import math


def build(OUT):
    W, H = 64, 60
    zid = "south_downs"
    z = Z(zid, "South Downs", W, H, kind="route", region=SE, music="route_moors",
          weather={"clear": 30, "sunshine": 24, "drizzle": 20, "gale": 12, "fog": 10, "downpour": 4})
    z.d["stage"] = "grass"
    z.legend.update({"g": DOWN_TURF, "k": CHALK, "c": CHALK_PATH, "q": SHORT, "p": SHINGLE})
    z.rect(0, 0, W, H, ".")
    z.border("T", 2, gaps=[(30, 0, 3, 2), (20, 58, 3, 2)])
    z.scatter(0, 0, W, H, "P", 10, 21, only="T")
    # --- heights: the Weald low in the north, the scarp, the high downs, the long dip slope to the sea
    for y in range(H):
        for x in range(W):
            z.hg[y][x] = 0 if y < 18 else 4 if y < 38 else 3 if y < 46 else 2 if y < 53 else 1
    # --- the Weald: small hedged fields and oaks
    z.rect(2, 2, 60, 16, ".")
    for (x0, x1, y) in [(3, 28, 7), (34, 61, 7), (3, 28, 12), (34, 61, 12)]:
        for x in range(x0, x1):
            if x not in (14, 15, 47, 48):
                z.set(x, y, "H")
    for y in range(2, 17):
        if y not in (9, 10, 14, 15):
            z.set(18, y, "H"); z.set(44, y, "H")
    blob(z, 9, 4, 4, 1.6, ",", only=".", seed=1, jitter=0.4)
    blob(z, 25, 15, 3, 1.4, ",", only=".", seed=2, jitter=0.4)
    blob(z, 52, 9, 5, 1.6, ",", only=".", seed=3, jitter=0.4)
    blob(z, 38, 15, 3, 1.2, ",", only=".", seed=4, jitter=0.4)
    scatter_props(z, "oak", 3, 2, 26, 15, 10, 5, avoid=("."))
    scatter_props(z, "oak", 34, 2, 27, 15, 10, 6, avoid=("."))
    z.rect(30, 0, 3, 19, "#")
    # --- the scarp: a wavy chalk escarpment, the only way up is the lane to the Beacon
    for x in range(2, W - 2):
        s = 18 + int(round(math.sin(x / 4.5)))
        for i in range(3):
            z.set(x, s + i, "k")
            z.hg[s + i][x] = 1 + i
        for y in range(18, s):
            z.hg[y][x] = 0
            if z.g[y][x] == ".":
                z.set(x, y, ".")
    for y in range(17, 24):
        for x in range(30, 33):
            z.set(x, y, "#")
    for x in range(30, 33):
        for y in range(17, 22):
            s = 18 + int(round(math.sin(x / 4.5)))
            z.hg[y][x] = 0 if y < s else min(4, 1 + (y - s))
    # --- the high downs
    for y in range(21, 46):
        for x in range(2, W - 2):
            if z.g[y][x] == "." and z.hg[y][x] >= 3:
                z.set(x, y, "g")
    for y in range(18, 24):
        for x in range(2, W - 2):
            if z.g[y][x] == "." and z.hg[y][x] >= 4:
                z.set(x, y, "g")
    # the South Downs Way along the ridge
    z.rect(2, 25, W - 4, 1, "c")
    z.rect(30, 21, 3, 5, "c")
    sign(z, 33, 26, "THE SOUTH DOWNS WAY. West to Winchester, 100 miles. East to Eastbourne, not quite so far. South to Brighton, downhill all the way, which is the best direction for a hill.")
    # Ditchling Beacon: trig point and dew pond
    z.prop("standing_stone", 34, 23, variant=0)
    z.rect(37, 22, 3, 2, "~")
    z.prop("bench", 28, 23)
    plaque(z, 33, 23, "southdowns_ditchling", "Ditchling Beacon",
           "At 248 metres this is the highest point in East Sussex. A fire beacon stood here in the chain of warning lights lit when the Spanish Armada sailed in 1588. On the London to Brighton bike ride, this is the hill everyone talks about afterwards.")
    plaque(z, 36, 24, "southdowns_dew_pond", "Dew Pond",
           "Chalk lets rain straight through, so downland farmers dug shallow ponds lined with puddled clay and straw to catch it for their sheep. They are called dew ponds, though it is mostly rain that fills them. Some are hundreds of years old.")
    # Jack and Jill, the Clayton windmills
    z.building(7, 21, 2, 2, "windmill_black", "Jack", show_label=True)
    z.building(12, 21, 2, 2, "windmill_white", "Jill", show_label=True)
    plaque(z, 10, 24, "southdowns_jack_and_jill", "Jack and Jill",
           "Two windmills above Clayton. Jill, the white wooden post mill, was built in Brighton in 1821 and dragged up here by teams of oxen in 1852. Jack, the black brick tower mill beside her, went up in 1866. Jill still grinds flour on open days.")
    # cropped turf, chalkhill blues on the horseshoe vetch, sheep
    for i, (cx, cy, rx, ry) in enumerate([(12, 30, 6, 2.5), (24, 36, 5, 2), (8, 40, 4, 2), (36, 33, 5, 2.5), (58, 31, 3, 3), (40, 41, 6, 2)]):
        blob(z, cx, cy, rx, ry, "q", only="g", seed=10 + i, jitter=0.4)
    for i, (cx, cy) in enumerate([(20, 28), (30, 40), (16, 34)]):
        blob(z, cx, cy, 2, 1, "f", only="g", seed=20 + i, jitter=0.5)
    for (x, y) in [(16, 29), (19, 31), (6, 33), (22, 32), (27, 30), (14, 37)]:
        z.prop("sheep", x, y, variant=1)
    plaque(z, 23, 29, "southdowns_skylarks", "Skylarks and Chalkhill Blues",
           "Skylarks sing as they climb, hanging over the downs for minutes at a time. The chalkhill blue butterfly lays its eggs on horseshoe vetch, and ants look after its caterpillars, milking them for a sugary drink. Close-cropped chalk turf can hold forty kinds of plant in a square metre.")
    # --- the Long Man of Wilmington on Windover Hill
    hills(z, [(48, 30, 8, 16)])
    for y in range(22, 42):
        for x in range(40, 57):
            if z.g[y][x] in ".q":
                z.set(x, y, "g")
    fig = [(47, 25), (48, 25), (49, 25), (47, 26), (49, 26), (47, 27), (48, 27), (49, 27), (48, 28)]
    fig += [(x, 29) for x in range(44, 53)]
    fig += [(46, y) for y in range(30, 36)] + [(50, y) for y in range(30, 36)] + [(x, 36) for x in range(46, 51)]
    fig += [(45, 37), (45, 38), (44, 39), (44, 40), (51, 37), (51, 38), (52, 39), (52, 40)]
    fig += [(43, y) for y in range(23, 41)] + [(53, y) for y in range(23, 41)]
    for (x, y) in fig:
        z.set(x, y, "c")
    plaque(z, 55, 26, "southdowns_long_man", "The Long Man of Wilmington",
           "A chalk figure about 70 metres tall, holding a staff in each hand. For centuries people took him for a prehistoric giant, but digs in 2003 dated him to the 16th or 17th century. In 1874 his outline was marked out in yellow bricks, and today it is painted concrete blocks. Nobody knows who he is meant to be.")
    # --- the dip slope down to the coast: Cuckmere Haven, the Seven Sisters, Beachy Head
    for y in range(46, H - 2):
        for x in range(2, W - 2):
            if z.g[y][x] in ".":
                z.set(x, y, ".")
    blob(z, 30, 50, 6, 2, ",", only=".", seed=31, jitter=0.4)
    blob(z, 14, 37, 3, 1.3, "q", only="g", seed=32, jitter=0.4)
    # the sea, from x 24 eastwards
    for y in range(50, H):
        for x in range(24, W):
            z.set(x, y, "$"); z.hg[y][x] = 0
    for x in range(24, 34):
        z.set(x, 50, "p"); z.set(x, 51, "w")
        z.hg[50][x] = 0; z.hg[51][x] = 0
    for x in range(24, 34):
        for y in range(46, 50):
            if z.g[y][x] in ".,":
                z.hg[y][x] = 1
    # the River Cuckmere meanders out to the haven
    for (x, y) in [(28, 41), (28, 42), (29, 43), (30, 44), (30, 45), (29, 46), (29, 47), (30, 48), (31, 49), (31, 50), (31, 51)]:
        z.set(x, y, "~"); z.hg[y][x] = 0
    z.set(29, 44, "~"); z.set(31, 48, "~")
    # the sisters: seven rises and dips along the chalk, then Beachy Head, highest of all
    for x in range(34, W):
        k = (x - 34) // 3
        top = (5 if k % 2 == 0 else 4) if x < 56 else 6
        for y in range(40, 48):
            if z.g[y][x] in ".,gq":
                z.set(x, y, "q" if (x + y) % 5 else "g")
            z.hg[y][x] = max(z.hg[y][x], top - (1 if y < 43 and top > 4 else 0))
        z.set(x, 48, "k"); z.set(x, 49, "k")
        z.hg[48][x] = top; z.hg[49][x] = top
    z.building(49, 43, 3, 2, "lighthouse_house", "Belle Tout")
    z.prop("lighthouse", 59, 52)
    for (x, y) in [(40, 55), (52, 57)]:
        z.prop("boat", x, y, variant=0)
    plaque(z, 38, 46, "southdowns_seven_sisters", "The Seven Sisters",
           "Chalk cliffs between Cuckmere Haven and Birling Gap, a row of summits and dips where old dry valleys have been cut through by the sea. The waves undercut them and the edge falls away a little every year, so keep well back. Some say there are really eight sisters, but nobody wants to be the one to tell them.")
    plaque(z, 56, 46, "southdowns_beachy_head", "Beachy Head",
           "At 162 metres, the highest chalk sea cliff in Britain. The red and white lighthouse at its foot was finished in 1902. The old lighthouse on the top, Belle Tout, was so often lost in low cloud that it was replaced; in 1999 the whole building was moved 17 metres back from the crumbling edge.")
    # --- Lyminster and the knucker hole, in the low south-west corner
    for y in range(40, H - 2):
        for x in range(2, 20):
            z.hg[y][x] = 1
            if z.g[y][x] in "gq":
                z.set(x, y, ".")
    z.building(3, 40, 6, 3, "flint_cottage", "Lyminster Church")
    z.rect(6, 47, 6, 5, "w")
    z.rect(7, 48, 4, 3, "o")
    for (x, y) in [(5, 46), (12, 47), (5, 51), (12, 50), (13, 49)]:
        z.set(x, y, "*")
    plaque(z, 10, 43, "southdowns_knucker_hole", "The Knucker Hole",
           "A spring-fed pond the locals swore had no bottom, home to a water dragon called the knucker. The name comes from the Old English nicor, a water monster. Lyminster's tale says a local lad killed it with a poisoned pie; a worn gravestone in the church, the Slayer's Slab, is said to be his.")
    # paths: the Way down to Brighton, and the lane to Lyminster
    z.rect(21, 25, 1, 33, "#"); z.rect(20, 56, 3, 4, "#")
    z.rect(9, 44, 13, 1, "#"); z.rect(9, 26, 1, 18, "#")
    z.rect(48, 41, 1, 5, "c")
    sign(z, 23, 55, "SOUTH TO BRIGHTON. Mind the cyclists coming the other way. They have been going uphill since London and they are not in the mood.")
    # --- NPCs
    chat(z, "sd_skylark_man", "birdwatcher", 26, 33, "Skylark Counter",
         ["Hear that? A skylark, straight up and singing the whole way. They can keep it going for twenty minutes without a breath you can see.",
          "Meredith wrote a poem about one, and Vaughan Williams set it to music: The Lark Ascending. Every summer it wins a poll. Every summer the lark ignores it."], "left", "still")
    chat(z, "sd_walker", "hillwalker", 31, 27, "Rambler",
         ["The downs are chalk all the way down: a sea floor, once, made of tiny skeletons. Every footpath up here is white when it rains, and so are your boots.",
          "Fancy a sandwich? I've got cheese and pickle, or pickle and cheese. I'm a rambler, not a caterer."], "down", "wander")
    chat(z, "sd_paraglider_watcher", "villager_2", 58, 37, "Cliff Walker",
         ["Look down there: the Seven Sisters, all white. Ships used to steer by them. The cliffs are coming towards us at about a foot a year, so I like to visit while there's still a view."], "down", "still")
    # trainers
    tdef("sd_cyclist", "Cyclist Bryony", "Cyclist", "jogger", [("stormswift", 94), ("stoopfalcon", 94), ("railspark", 95)],
         ["Ditchling Beacon! The meanest hill on the London to Brighton ride. Thirty thousand of us do it every summer, and about twenty-nine thousand of us push the bike up the last bit."],
         "Fair enough. My legs had already lost before you turned up.", "It's 54 miles from London to Brighton. All the way you think: nearly there. Then the Beacon.", 4100)
    tnpc(z, "sd_cyclist", 31, 19, "down")
    tdef("sd_shepherd", "Shepherd Amos", "Shepherd", "farmer", [("dextera", 94), ("longman", 94), ("gealhare", 95)],
         ["Southdown sheep, these. Small, tough, a face like a teddy bear. They were bred on these hills, and half the world's sheep have a bit of Southdown in them somewhere."],
         "Ah, well. The sheep weren't watching.", "My grandad's grandad kept a shepherd's crook made at Pyecombe forge. Pyecombe hooks were the best in Sussex.", 3900)
    tnpc(z, "sd_shepherd", 18, 32, "right")
    tdef("sd_birder", "Birder Linnet", "Birdwatcher", "birdwatcher", [("murmurant", 94), ("forkwing", 94), ("redbreast", 95)],
         ["Peregrines nest on the cliffs at Beachy Head. Fastest animal on the planet, in a dive. I'll settle for fastest to a fight."],
         "Outflown. I'll put it in my notebook as a 'difficult sighting'.", "A peregrine's stoop can top 180 miles an hour. Mine tops out at a brisk walk to the café.", 3900)
    tnpc(z, "sd_birder", 44, 44, "down")
    tdef("sd_paraglider", "Paraglider Jas", "Paraglider", "hillwalker", [("stormswift", 94), ("levelcrane", 94), ("goldeneyrie", 95)],
         ["The wind comes off the sea, hits the scarp and goes straight up. Lovely lift. I've been airborne since breakfast. Well, on and off."],
         "Brought down to earth. It happens to all of us eventually.", "Devil's Dyke, up the way, is the place for it. The story goes the Devil dug it to let the sea in and drown the churches of the Weald. He ran out of night.", 3900)
    tnpc(z, "sd_paraglider", 40, 30, "left")
    # the knucker quest (q_southeast_knucker_*): churchwarden, miller, and the knucker itself at night
    q = "q_southeast_knucker_"
    script(zid, "sd_churchwarden", [
        IF(q + "done", say("Churchwarden", "You met the knucker and lived! And it ate the pie. I'll write it in the parish book: second knucker, first happy ending."), [
            IF(q + "3", say("Churchwarden", "The pie's at the edge of the knucker hole. Come back after dark. Bring a snare, and your manners."), [
                IF(q + "2", say("Churchwarden", "Flour from Jill, a pie dish from the Lanes. Right, stand back.", "There. Mutton, onion, a good crust, and no poison, because it's not the 1600s and we've all calmed down.", "Leave it by the water and come back at night. Whatever comes up for it, be polite.") + [setf(q + "3")], [
                    IF(q + "started", say("Churchwarden", "Flour from the miller up at Jack and Jill, and a pie dish big enough for a dragon. The antiques shop in Brighton's Lanes has one, I'm told."), say(
                        "Churchwarden", "{greeting} That stone in the church is the Slayer's Slab. The tale goes that a dragon, the knucker, lived in that pond and ate the livestock, and the odd person.",
                        "A local lad, Jim Pulk some say, baked an enormous poisoned pie, carted it to the pond, and when the knucker ate it, he cut off its head.",
                        "I've always felt sorry for the knucker. It lived here first. I'd like to make it up to the family, if there are any.",
                        "Help me bake a peace pie? Flour from the miller at Jack and Jill on the Downs, and a pie dish big enough, from the antiques shop in Brighton's Lanes.") + [setf(q + "started")])])])])])
    z.npc(id="sd_churchwarden", sprite="choir_singer", x=10, y=45, facing="down", move="still", script="sd_churchwarden", name="Churchwarden")
    script(zid, "sd_miller", [
        IF(q + "1", say("Miller", "That flour's stone-ground. Wind-ground, really. Jill does the work, I do the sneezing."), [
            IF(q + "started", say("Miller", "A pie for the knucker? Well, that's the strangest order Jill's had since 1852.", "Here: a sack of wholemeal, ground this morning. Don't let it get wet. You'll have a pie dish full of glue.") + [setf(q + "1")],
               say("Miller", "{greeting} Jill's a post mill: the whole body of the mill turns on one big post to face the wind. You push it round with the tail pole. Some days she pushes back.", "Jack's the brick tower one. Only his cap turns. They're a couple, in the way that windmills can be."))])])
    z.npc(id="sd_miller", sprite="farmer", x=11, y=24, facing="down", move="still", script="sd_miller", name="Miller")
    _stand(z, 11, 24); _stand(z, 10, 45)
    script(zid, "knucker", [{"do": "when", "cond": "night", "else": [{"do": "say", "who": "", "text": "The pie sits by the still water. Nothing stirs. Knuckers are night creatures; come back after dark."}], "then": [
        {"do": "say", "who": "", "text": "The water heaves. Something long and green and very, very old lifts its head, sniffs the pie, and looks straight at you."},
        setf(q + "4"),
        {"do": "legend", "species": "knucker", "level": 94, "flag": "caught_knucker", "music": "legend"},
        IF("caught_knucker", [setf(q + "done"), {"do": "say", "who": "", "text": "The knucker settles into your snare like it has been waiting for a good excuse. The pie dish is licked clean."}],
           [{"do": "say", "who": "", "text": "The knucker slides back into the bottomless dark. The pie is still there. It'll be back."}])]}])
    _stand(z, 8, 51)
    z.npc(id="knucker_spot", sprite="creature:knucker", x=8, y=51, facing="up", move="still", script="knucker",
          show_if=q + "3", hide_if="caught_knucker")
    # wild creatures
    lo, hi = LV
    wild(z, [("chalkling", lo, hi, 16, {}), ("leveret", lo, hi, 10, {}), ("kitelet", lo, hi, 8, {"time": ["day"]}),
             ("peregrin", lo, hi, 6, {}), ("flintling", lo, hi, 6, {}), ("zigzlet", lo, hi, 6, {"weather": ["sunshine", "clear"]}),
             ("rooklet", lo, hi, 8, {}), ("pipkin", lo, hi, 8, {}), ("stoatlet", lo, hi, 6, {}), ("puffkin", lo, hi, 5, {"season": ["autumn"]}),
             ("barnling", lo, hi, 6, {"time": ["night"]}), ("flittermouse", lo, hi, 6, {"time": ["night", "dusk"]}),
             ("longman", hi, hi, 2, {"weather": ["fog"]})])
    wild(z, [("croakle", lo, hi, 20, {}), ("holtling", lo, hi, 10, {}), ("stalklet", lo, hi, 10, {}), ("chipgull", lo, hi, 10, {}),
             ("pupplash", lo, hi, 10, {}), ("gannetling", lo, hi, 8, {})], "water")
    z.d["edges"] = {"north": {"to": "london", "offset": 21}, "south": {"to": "brighton", "offset": 14}}
    z.d["spawn"] = [31, 3]
    scale_zone(z)
    smooth_walk(z)
    finish(z)
    z.save(OUT + "/" + zid + ".json")
