# The Kent Downs: east of London along the Pilgrims' Way. The Garden of England: hop gardens, oast houses,
# orchards, Kit's Coty House and Leeds Castle on its lake. Route, region south_east.
from se_common import *
from wcommon import _stand


def build(OUT):
    W, H = 70, 50
    zid = "kent_downs"
    z = Z(zid, "Kent Downs", W, H, kind="route", region=SE, music="route_forest",
          weather={"clear": 30, "sunshine": 26, "drizzle": 22, "fog": 10, "gale": 6, "downpour": 6})
    z.d["stage"] = "grass"
    z.legend.update({"g": DOWN_TURF, "q": SHORT, "h": {"tile": "hedge", "colour": "#5d8a34"}, "c": CHALK_PATH})
    z.rect(0, 0, W, H, ".")
    z.border("T", 2, gaps=[(0, 20, 2, 3), (68, 20, 2, 3)])
    z.scatter(0, 0, W, H, "P", 12, 51, only="T")
    # --- the North Downs to the north: chalk turf rising, yews, Kit's Coty House
    for y in range(2, 19):
        for x in range(2, W - 2):
            z.hg[y][x] = 3 if y < 10 else 2 if y < 13 else 1 if y < 16 else 0
            z.set(x, y, "g")
    for i, (cx, cy, rx, ry) in enumerate([(10, 6, 5, 2), (30, 8, 6, 2.5), (50, 5, 5, 2), (60, 12, 4, 2), (40, 14, 5, 1.5)]):
        blob(z, cx, cy, rx, ry, "q", only="g", seed=60 + i, jitter=0.4)
    for (x, y) in [(4, 3), (5, 4), (22, 3), (23, 4), (38, 3), (44, 4), (45, 3), (58, 3), (64, 5), (65, 4), (20, 11), (54, 9)]:
        z.set(x, y, "P")
    for (x, y, v) in [(15, 12, 0), (17, 12, 1), (16, 11, 2)]:
        z.prop("standing_stone", x, y, variant=v)
    z.prop("rock", 16, 12)
    plaque(z, 18, 13, "kentdowns_kits_coty", "Kit's Coty House",
           "Three great upright stones and a capstone across the top: all that is left of a Neolithic long barrow, a burial mound built here over 5,000 years ago. The earth that covered it has long since been ploughed away. Nobody knows who Kit was.")
    plaque(z, 34, 18, "kentdowns_pilgrims_way", "The Pilgrims' Way",
           "An ancient trackway along the foot of the North Downs, high enough to stay out of the mud and low enough to stay out of the wind. From the 1170s pilgrims walked this way to Thomas Becket's shrine at Canterbury, and the Victorians named it after them.")
    # --- the Pilgrims' Way itself
    z.rect(0, 20, W, 3, "#")
    for y in range(19, 24):
        for x in range(W):
            if z.g[y][x] in "g.":
                z.hg[y][x] = 0
    sign(z, 2, 19, "WEST TO LONDON. You'll know it when you see it. You'll hear it first.")
    sign(z, 66, 19, "EAST TO CANTERBURY. The pilgrims did it on foot in a few days. Please don't take as long.")
    # --- the Weald: a hop garden, oast houses, an orchard, a cricket green, Leeds Castle in its lake
    blob(z, 12, 25, 6, 1.2, ",", only=".", seed=1, jitter=0.4)
    for y in range(27, 40, 2):
        for x in range(4, 25):
            if x not in (13, 14):
                z.set(x, y, "h")
        for x in range(4, 25):
            if z.g[y + 1][x] == ".":
                z.set(x, y + 1, ",")
    for x in range(3, 26):
        z.set(x, 26, "#")
    plaque(z, 3, 25, "kentdowns_hop_garden", "The Hop Garden",
           "Hops climb strings up to wires on tall poles, five metres and more by late summer. Picking used to be done by hand, and every September whole families came down from London's East End for 'hopping': hard work, a hut to sleep in, and the nearest thing many had to a holiday.")
    z.building(27, 26, 7, 3, "oast_house", "Hop Farm Oast", door=1)
    z.building(27, 31, 5, 3, "oast_house", "Oast Cottage")
    z.building(58, 26, 7, 3, "oast_house", "Little Oast")
    plaque(z, 34, 29, "kentdowns_oast_houses", "Oast Houses",
           "Freshly picked hops are wet and would rot, so they were dried in oasts: a fire below, a slatted floor above, and the round or square kiln drawing hot air up through the hops and out of the white cowl, which swings with the wind. Most Kentish oasts are homes now, and very nice ones.")
    # the orchard
    z.rect(36, 25, 18, 9, ".")
    for y in range(26, 34, 3):
        for x in range(37, 53, 3):
            z.prop("oak", x, y, variant=(x + y) % 3)
            if z.g[y + 1][x] == ".":
                z.set(x, y + 1, ",")
    plaque(z, 35, 25, "kentdowns_garden_of_england", "The Garden of England",
           "Kent's soils and mild weather made it the Garden of England: apples, pears and cherries, hops and cobnuts. Henry VIII's fruiterer planted the first big orchards of new apple and cherry trees near Teynham in the 1530s. The National Fruit Collection at Brogdale still grows thousands of varieties.")
    # the village green with its cricket square
    z.rect(4, 41, 18, 7, ".")
    z.prop("pitch_line", 12, 44, rot=90)
    z.building(4, 41, 4, 2, "weatherboard", "Pavilion")
    plaque(z, 9, 43, "kentdowns_cricket", "Village Cricket",
           "Kent and Sussex both claim to have invented cricket, and both have a good case: the earliest records of the game come from the Weald, played by shepherd boys with a crooked stick. Kent's first-class county club is one of the oldest anywhere.")
    # Leeds Castle in its lake
    z.rect(42, 35, 25, 13, "~")
    z.rect(42, 35, 25, 1, "w"); z.rect(42, 35, 1, 13, "w")
    z.rect(49, 37, 13, 8, "g")
    z.building(51, 37, 9, 5, "castle", "Leeds Castle", door=4)
    z.rect(55, 23, 1, 12, "#"); z.rect(50, 34, 6, 1, "#"); z.rect(50, 35, 1, 2, "#")
    z.rect(54, 42, 3, 3, "#")
    for (x, y) in [(46, 40), (63, 39), (60, 46)]:
        z.prop("boat", x, y, variant=0)
    plaque(z, 54, 34, "kentdowns_leeds_castle", "Leeds Castle",
           "A castle built on islands in a lake, first in stone by the Normans in 1119. It was a royal palace for six medieval queens, and Henry VIII spent a fortune on it. Despite the name it is in Kent, near Maidstone, not in Leeds. Its black swans have been here since the 1930s.")
    # paths through the Weald
    z.rect(30, 23, 1, 3, "#"); z.rect(12, 23, 1, 3, "#"); z.rect(12, 40, 1, 2, "#"); z.rect(13, 26, 1, 15, "#")
    z.rect(30, 29, 1, 2, "#"); z.rect(30, 34, 1, 12, "#"); z.rect(14, 45, 17, 1, "#")
    # --- NPCs
    chat(z, "kd_walker", "hiker", 40, 21, "Walker",
         ["The Pilgrims' Way runs from Winchester all the way to Canterbury. They reckon Chaucer's lot came down from London on Watling Street instead, the A2 now.",
          "Either way, pilgrims bought souvenir badges at the shrine and wore them home on their hats. People find them in the Thames mud even now."], "down", "wander")
    chat(z, "kd_hop_farmer", "farmer", 25, 27, "Hop Farmer",
         ["Hops are for beer: they make it bitter and help it keep. Before hops, English ale was sweet and went off in days.",
          "Every bine goes up its string clockwise. Try to make one go the other way and it'll unwind itself overnight. Stubborn things. Like farmers."], "down", "still")
    chat(z, "kd_cobnut_seller", "villager_3", 53, 23, "Cobnut Seller",
         ["Kentish cobnuts! A kind of hazelnut, grown in plats in the Weald. Eat them fresh in August while they're green and milky, or wait till they're brown and crack them by the fire.",
          "My great-gran picked them for the London markets. She could fill a basket faster than a squirrel, and the squirrels hated her for it."], "down", "still")
    # trainers
    tdef("kd_hop_picker", "Hop Picker Elsie", "Hop Picker", "villager_5", [("oastcowl", 94), ("thistlord", 94), ("pinewraith", 94)],
         ["My nan came hopping every year from Bermondsey. Sang the whole way down on the train. I've come back for the singing."],
         "Well, that's my bin full of trouble. Go on.", "They paid by the bushel, and the measurer always pushed the hops down hard in his basket. My nan never forgave him.", 4000)
    tnpc(z, "kd_hop_picker", 13, 33, "up")
    tdef("kd_cricketer", "Cricketer Raj", "Cricketer", "rugby_player", [("stagmajor", 94), ("warrender", 94), ("tunneller", 95)],
         ["Howzat! No? Fair enough. Fancy an innings anyway? Bring your own bat. Bring your own team, actually."],
         "Clean bowled. I'll be in the pavilion if anyone needs me. There's cake.", "Tea at four. Cricket stops for tea. That's the law. Possibly the actual law.", 4000)
    tnpc(z, "kd_cricketer", 16, 43, "left")
    tdef("kd_orchard", "Orchard Keeper Mabel", "Orchard Keeper", "farmer", [("pixiedell", 94), ("burrenbloom", 94), ("hazeldoze", 95)],
         ["Cox, Bramley, Russet, and a little tree at the back nobody can name. Pick one. No, not the little one."],
         "Ooh, you've a fair bit of crunch to you.", "In January we wassail the trees: toast in the branches, cider at the roots, and a lot of shouting to wake them up for spring.", 4000)
    tnpc(z, "kd_orchard", 46, 28, "down")
    tdef("kd_guide", "Castle Guide Philippa", "Castle Guide", "tour_guide", [("hushwing", 94), ("centurion", 94), ("lochosprey", 95)],
         ["Welcome to Leeds Castle. Yes, it's in Kent. No, I don't know why either. Shall we battle while you get over it?"],
         "Splendid. You can join the black swans for a victory lap.", "Lady Baillie bought the castle in 1926 and filled it with parties and exotic birds. The black swans were hers.", 4000)
    tnpc(z, "kd_guide", 55, 30, "down")
    # Chaucer's pilgrims on the road (q_southeast_pilgrims_*): the Knight and the Miller
    pilgrim(z, zid, "kd_knight", "The Knight", "pilgrim", 22, 21,
            [("centurion", 95), ("stagmor", 95), ("billgruff", 95)],
            ["A verray, parfit, gentil knyght. Very perfect, gentle, and not at all wanting to fight you, unless the Host says so. He says so."],
            ["My tale is of two cousins, Palamon and Arcite, prisoners in Athens, who both fall for the lady Emelye from their tower window.",
             "They fight for her in a great tournament. Arcite wins, then his horse throws him and he dies. Palamon marries Emelye in the end. Knights' tales are long. That is the short version."],
            "Well fought. Chivalry is about losing nicely, too.", "q_southeast_pilgrims_1")
    pilgrim(z, zid, "kd_miller", "Robin the Miller", "farmer", 31, 30,
            [("brockmoor", 95), ("thornsow", 95), ("oastcowl", 95)],
            ["I'm the Miller. Chaucer says I could break a door off its hinges by running at it with my head. I've had a drink. Let's go."],
            ["My tale's about a carpenter, his young wife, and a lodger who tricks the carpenter into sleeping in a tub in the roof to escape a second Noah's flood.",
             "It ends with a misplaced kiss, a red-hot poker, and the carpenter crashing through the ceiling. Chaucer apologised for it in advance. I don't."],
            "Ha! Took that like a millstone. Fair play.", "q_southeast_pilgrims_2")
    lo, hi = LV
    wild(z, [("hoplet", lo, hi, 16, {}), ("chalkling", lo, hi, 8, {}), ("dozelet", lo, hi, 8, {}), ("pipkin", lo, hi, 10, {}),
             ("spikkin", lo, hi, 8, {}), ("fawnlet", lo, hi, 8, {}), ("brockling", lo, hi, 6, {"time": ["dusk", "night"]}),
             ("rooklet", lo, hi, 8, {}), ("puffkin", lo, hi, 6, {"season": ["autumn"]}), ("oastcowl", hi, hi, 3, {"weather": ["sunshine"]}),
             ("hootlet", lo, hi, 6, {"time": ["night"]}), ("glowmite", lo, hi, 5, {"time": ["night"]})])
    wild(z, [("holtling", lo, hi, 14, {}), ("volet", lo, hi, 14, {}), ("stalklet", lo, hi, 12, {}), ("croakle", lo, hi, 14, {}),
             ("cranelet", lo, hi, 8, {}), ("dipling", lo, hi, 10, {})], "water")
    # --- interiors
    door_to(z, OUT, zid, "kent_oast", "Hop Farm Oast", (28, 28), "mill", [
        talker("kent_oast", "oast_dryer", "farmer", 6, 2, "Hop Drier", [
            "Up there's the drying floor: slats of wood with horsehair cloth over, and the hops spread a foot deep. Below, the fire, burning day and night for weeks in September.",
            "The drier slept here in the oast and turned the hops with a big wooden scuppet. Too hot and they scorch, too cool and they go mouldy. Get it right and the whole valley smells of beer.",
            "Some oasts burned sulphur on the fire too, to keep the hops a nice green colour. You can still smell it on old beams, on a warm day."], "down"),
        talker("kent_oast", "oast_presser", "villager_5", 2, 5, "Hop Presser", [
            "The dried hops go into long sacks called pockets, pressed in tight. A full pocket weighs about as much as two grown men and smells better than either."], "right")],
        extra_props=[P("slate_heap", 10, 1), P("fireplace", 6, 1)])
    door_to(z, OUT, zid, "kent_leeds_castle", "Leeds Castle", (55, 41), "castle", [
        talker("kent_leeds_castle", "lc_steward", "tour_guide", 6, 3, "Steward", [
            "Six medieval queens owned this castle in their own right, starting with Eleanor of Castile in 1278. It was a gift kings gave their wives. Better than flowers.",
            "Henry VIII turned it into a palace for Catherine of Aragon. He came through on his way to meet the King of France at the Field of the Cloth of Gold in 1520, with five thousand people in tow.",
            "The historian Lord Conway called it 'the loveliest castle in the world'. We put that on everything. Wouldn't you?"], "down"),
        talker("kent_leeds_castle", "lc_dogcollar", "student", 10, 5, "Visitor", [
            "There's a museum of dog collars here! Hundreds of years of them, some with spikes against wolves. I came for the castle. I'm staying for the collars."], "left")],
        w=15, h=10, extra_props=[P("display_case", 1, 5), P("display_case", 13, 5), P("wall_picture", 4, 1, walk=True, variant=1), P("wall_picture", 10, 1, walk=True, variant=2)])
    z.d["edges"] = {"west": {"to": "london", "offset": 6}, "east": {"to": "canterbury", "offset": 6}}
    z.d["spawn"] = [3, 21]
    scale_zone(z)
    smooth_walk(z)
    finish(z)
    z.save(OUT + "/" + zid + ".json")
    return z


def pilgrim(z, zid, tid, name, sprite, x, y, party, intro, tale, win, step):
    """one of Chaucer's pilgrims: tells their tale and fights for the Host's prize once the contest is on."""
    tdef(tid, name, "Pilgrim", sprite, party, intro, win, "My tale's told. Go and hear the others, and tell the Host I was the best.", 4600)
    cmds = [IF("trainer_" + tid, say(name, TRN[tid]["after"]), [
        IF("q_southeast_pilgrims_started", TRN[tid]["intro"] + say(name, *tale) + [fight(tid), IF("trainer_" + tid, [setf(step)])],
           say(name, "I'm saving my tale for the road. The Host at the Chequer of Hope in Canterbury is judging a contest, if you'd care to hear it."))])]
    script(zid, tid + "_talk", cmds)
    _stand(z, x, y)
    z.npc(id=tid + "_talk", sprite=sprite, x=x, y=y, facing="down", move="still", script=tid + "_talk", name=name)
