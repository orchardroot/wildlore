# plan 6 group B, part 3: sheffield (city; its west edge joins Buxton), sherwood (landmark forest) and nottingham (city).
from nw_common import *


def build(OUT):
    sheffield(OUT)
    sherwood(OUT)
    nottingham(OUT)


def sheffield(OUT):
    W, H = 80, 60
    z = Z("sheffield", "Sheffield", W, H, kind="town", region="yorkshire", music="town_city", weather=WX_NORTH)
    z.d["stage"] = "city"; z.d["town_id"] = "sheffield"
    z.border("T", 2, gaps=[(0, 20, 2, 3), (30, 0, 3, 2), (44, 58, 3, 2)])
    z.scatter(0, 0, W, H, "P", 30, 11, only="T")
    # the seven hills: a terraced hill in the south-west, Park Hill in the north-east
    hill(z, 6, 40, 10, 6, 4)
    hill(z, 58, 4, 20, 6, 3)
    # the River Don, with a road bridge and two footbridges
    z.rect(20, 2, 4, 56, "~"); z.rect(19, 2, 1, 56, "w"); z.rect(24, 2, 1, 56, "w")
    # streets: Arundel Gate east-west, the north road to York, the south road
    z.rect(0, 20, 78, 3, "="); z.rect(2, 23, 76, 1, ":")
    z.rect(19, 20, 6, 3, "="); z.rect(20, 19, 4, 1, "W"); z.rect(20, 23, 4, 1, "W")
    z.rect(30, 0, 3, 20, "=")
    z.rect(44, 23, 3, 37, "="); z.rect(43, 24, 1, 34, ":"); z.rect(47, 24, 1, 22, ":")
    z.rect(19, 13, 6, 2, "|"); z.rect(19, 40, 6, 2, "|")
    # Kelham Island: the big mill on the west bank, with works and slag heaps
    z.building(4, 6, 14, 7, "mill", "Kelham Island")
    z.rect(3, 13, 17, 1, ":"); z.rect(18, 13, 2, 7, ":")
    z.building(4, 15, 8, 4, "mill", "Cutlery Works", show_label=True)
    z.building(13, 15, 5, 4, "red_brick", "Forge")
    for (x, y) in [(3, 5), (19, 6), (2, 10), (19, 10), (2, 19)]:
        z.prop("slate_heap", x, y, variant=(x + y) % 3)
    z.prop("lamp_post", 5, 14); z.prop("lamp_post", 12, 14); z.prop("lamp_post", 17, 14); z.prop("bollard", 19, 12); z.prop("bollard", 19, 15)
    z.sign(10, 14, "KELHAM ISLAND. A man-made island between the river and a channel called the goit, once crammed with works that rolled steel and ground knives. At its peak Sheffield was the steel capital of the world. The mill hooter still goes in people's heads at half past seven.")
    z.sign(9, 19, "STAINLESS STEEL. Harry Brearley, working here in 1913, found that adding chromium made steel that would not rust. He was meant to be making better gun barrels. He made better forks instead, and the world has been eating off them ever since.")
    # the Town Hall and the Peace Gardens
    z.building(36, 14, 16, 5, "stone", "Town Hall", door=8)
    z.building(42, 11, 3, 3, "chapel", show_label=False)
    z.rect(34, 19, 20, 1, ":")
    z.rect(34, 24, 21, 13, ":")
    for xx in (37, 43, 49):
        for yy in (27, 33):
            z.rect(xx - 1, yy - 1, 3, 3, "w"); put(z, xx, yy, "~")
    z.rect(34, 24, 21, 1, "f"); z.rect(34, 36, 21, 1, "f")
    for (x, y) in [(35, 30), (53, 30), (40, 30), (46, 30), (40, 25), (46, 25), (40, 35), (46, 35)]:
        z.prop("bench" if (x + y) % 2 else "planter", x, y)
    for (x, y) in [(36, 25), (52, 25), (36, 35), (52, 35), (43, 30)]:
        z.prop("lamp_post", x, y)
    z.sign(44, 24, "THE PEACE GARDENS. A square of cobbles and fountains in front of the Town Hall, with jets that shoot up in patterns and children who shoot through them in other patterns. On a hot day the whole city is here, shoes off, without a thought for the pigeons.")
    z.sign(43, 19, "SHEFFIELD TOWN HALL. Opened in 1897, built of local sandstone, with a tower that has a statue of Vulcan on top, god of the forge. He is looking at the city, which is looking back.")
    z.building(36, 38, 7, 3, "cream_render", "Millennium Gallery")
    z.building(6, 41, 10, 3, "terrace")
    z.building(56, 25, 12, 4, "white_render", "Winter Garden")
    z.building(58, 31, 8, 4, "red_brick", "Crucible Theatre")
    z.building(68, 31, 6, 4, "cathedral", "Cutlers' Hall")
    z.rect(55, 30, 20, 1, ":"); z.rect(55, 35, 20, 1, ":")
    z.sign(62, 36, "THE CRUCIBLE. A theatre that hosts the World Snooker Championship every spring, when the whole of Sheffield goes quiet and holds its breath for the black ball. A quiet Sheffield is the most unusual thing in England.")
    z.sign(72, 36, "THE CUTLERS' HALL. Home to the Company of Cutlers in Hallamshire since 1624. The guild has a feast every year where the guests take home a silver spoon. It's the one meal where you really are allowed to take the cutlery.")
    # Park Hill flats on the high ground in the north-east
    z.building(60, 4, 14, 4, "red_brick", "Park Hill")
    z.rect(60, 8, 14, 1, ":")
    # Sanctuary and Corner Shop face the main road
    z.building(56, 16, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(59, 19, "sheffield_sanctuary", 5, 6, "up")
    z.building(66, 16, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(68, 19, "sheffield_shop", 4, 5, "up")
    z.building(24, 14, 5, 5, "terrace"); z.building(72, 16, 5, 4, "terrace")
    z.prop("planter", 55, 19); z.prop("planter", 63, 19); z.prop("post_box", 64, 19); z.prop("phone_box", 65, 19)
    # the railway station
    station(z, 54, 44, 10, 4, "Sheffield Station")
    z.rect(47, 46, 7, 1, ":")
    rail_guard(z, 60, 46, ["Sheffield Station. Trains for every station you have visited in England, Wales and Scotland. Please take your steel, your relish and your football scarf with you."], facing="left")
    # south of the road: shops, then Endcliffe Park with ponds and tall grass
    z.building(26, 25, 8, 4, "terrace"); z.building(26, 31, 8, 4, "red_brick", "Corner Cafe")
    z.building(2, 25, 8, 4, "terrace"); z.building(2, 31, 8, 4, "red_brick")
    z.rect(48, 50, 30, 8, "."); z.rect(50, 52, 8, 4, ","); z.rect(66, 51, 10, 5, ",")
    z.rect(60, 53, 5, 3, "w"); z.rect(61, 54, 3, 1, "~")
    z.rect(26, 41, 16, 15, "."); z.rect(28, 42, 8, 6, ","); z.rect(30, 52, 8, 4, ",")
    z.rect(3, 53, 14, 3, ","); z.rect(2, 24, 1, 0, ",")
    z.rect(6, 36, 10, 3, ",")
    scatter_props(z, "oak", 25, 41, 17, 15, 9, 111, avoid=(".",))
    scatter_props(z, "oak", 48, 50, 30, 8, 9, 112, avoid=(".",))
    scatter_props(z, "bush", 3, 36, 18, 18, 8, 113, avoid=(".",))
    z.prop("bench", 62, 52); z.prop("bench", 56, 51); z.prop("lamp_post", 49, 49)
    z.sign(48, 49, "ENDCLIFFE PARK. Sheffield is said to have more trees per person than any other city in Europe, and a good number of them are in parks like this one. People here say it is the greenest industrial city in England. They are rather proud of it, and rather polite about it.")
    z.sign(11, 47, "THE HILLS. Sheffield, like Rome, is built on seven hills, which is why every street is either up or down. Walking here is a free gym membership and a hearty cardiovascular argument.")
    # people
    chat(z, "shf_steelman", "tin_miner", 8, 19, "Retired Steelworker",
         ["Thirty-eight years in the melting shop. It was hot enough to fry an egg on a bar, and we did, most Fridays.",
          "The best steel, Crucible steel, was poured from white-hot pots, and the ring when you tapped it was like a church bell. That's the sound I miss."], "down", "wander")
    chat(z, "shf_snooker", "student", 63, 30, "Snooker Fan",
         ["The Crucible seats 980, and it's the quietest 980 you'll ever hear. You could hear a chalk drop.",
          "Cue ball, red, colour, red, colour. It's maths with a stick, and a lot of nerves. I could watch it for hours. I have."], "down", "still")
    chat(z, "shf_busker", "villager_6", 40, 31, "Busker",
         ["Some lads from just up the road made an album in a bedroom and now people write songs about the city's chip shops. I do the same. No one writes about me.",
          "I've been told to 'play it with feeling'. I'm told the feeling is mostly cold."], "right", "wander")
    chat(z, "shf_relish", "shopkeeper", 29, 24, "Cafe Owner",
         ["Henderson's Relish: Sheffield's secret sauce, a thin dark liquid that goes with everything. The recipe is known only to a few people. They've taken a vow, and I've seen them. They look very calm.",
          "We have a saying: if you leave Sheffield, it follows you. Usually in a bottle in your luggage."], "down", "wander")
    chat(z, "shf_fullmonty", "jogger", 52, 21, "Local",
         ["A famous film about six lads who lost their jobs at the steelworks was set right here, and I should say it was funny and kind in equal parts.",
          "People still stop me and ask where they can get the hat. I tell them it was a small hat. They understand."], "left", "wander")
    chat(z, "shf_student", "student", 28, 21, "Student",
         ["Two universities, forty thousand students, and a hill on every route. The first week, everyone says 'I'll take the bus'. By week three they say 'where's the gym?'",
          "The city got a tram in 1994. It goes up the hill. It doesn't go down. Or it goes down very quietly."], "down", "wander")
    trainer(z, "shf_steelworker", "Steelworker Mick", "Steelworker", "tin_miner", [("cutlet", 86), ("rivetling", 86), ("tinnet", 86)],
            12, 19, "down", ["Forged in Sheffield. Hardened in Sheffield. Tempered in a pub in Sheffield. That's a Sheffield education."],
            "Stainless, you are. I'll give you that.", "I tempered the blade and the temper. You can't do one without the other, my lad.", 3600)
    trainer(z, "shf_warden", "Warden Aldous", "Warden", "warden_grunt", [("binfox", 86), ("railspark", 86), ("grizzlet", 86)],
            40, 23, "down", ["Welcome to the Sheffield Heritage Experience! The steel has been curated, the hills have been curated, and the pigeons are, regrettably, still wild."],
            "A very decent win. I'll say it was a tie in my report.", "The Enclosure has plans for a tasteful Kelham Island Experience. Possibly with a theme park. I'm told the mill said no.", 3550)
    trainer(z, "shf_student_t", "Student Pria", "Student", "student", [("bobbin", 86), ("shuttlecog", 86), ("sootwing", 86)],
            34, 55, "up", ["I'm doing metallurgy. Which is the study of metals. And of why I'm still in the library."],
            "That was a stress test. I think the material held.", "You can tell steel by its sound. You can tell a student by how often they say 'I'll start tomorrow'.", 3500)
    z.d["edges"] = {"west": {"to": "buxton", "offset": 0}, "north": {"to": "york", "offset": 0}, "south": {"to": "sherwood", "offset": 0}}
    z.d["spawn"] = [31, 21]
    wild(z, [("cutlet", 86, 87, 18, {}), ("bobbin", 86, 87, 12, {}), ("rivetling", 86, 87, 10, {}), ("tinnet", 86, 87, 8, {}),
             ("binfox", 86, 86, 10, {"time": ["night", "dusk"]}), ("grizzlet", 86, 86, 10, {}), ("cooplet", 86, 86, 10, {}),
             ("starlet", 86, 87, 8, {"time": ["day", "dusk"]}), ("sootwing", 86, 87, 8, {"time": ["night"]}), ("railspark", 86, 87, 5, {"weather": ["downpour", "gale"]}),
             ("pepperling", 86, 86, 8, {})])
    wild(z, [("stalklet", 86, 87, 20, {}), ("chipgull", 86, 86, 16, {}), ("minkshade", 86, 87, 10, {"time": ["night", "dusk"]}),
             ("holtling", 86, 86, 14, {}), ("pincray", 86, 87, 10, {}), ("dipling", 86, 86, 12, {})], "water")
    tidy(z)
    z.save(OUT + "/sheffield.json")
    sanctuary(OUT, "sheffield", "Sheffield", (59, 20))
    shop(OUT, "sheffield", "Sheffield", (68, 20))
    nurse("sheffield", ["Now then, love. Welcome to the Sheffield Sanctuary. Pop 'em on the counter and let's have a look.",
                        "Sit down, sit down. I'll fetch you a brew, and there's a Henderson's butty if you've the stomach for it. Your team's in the best of hands.",
                        "Right as rain, they are. Better than steel. Ee, they've a shine on them. Go on, off with you, and mind the hills.",
                        "The Ark? Up the stairs, past the relish. It runs on steam, I think. Or maybe it's Wi-Fi.",
                        "Right you are. Come back if it gets too hilly. It always does."])
    shopkeeper("sheffield", "Now then! Relish, pies, and enough sharpened cutlery to fell a small oak. What'll you have?",
               "Ta-ra, then. Mind the hills, they come at you in the dark.")


def sherwood(OUT):
    W, H = 64, 60
    z = Z("sherwood", "Sherwood Forest", W, H, kind="route", region="midlands", music="route_forest",
          weather={"clear": 22, "drizzle": 24, "fog": 18, "sunshine": 14, "downpour": 12, "gale": 6, "frost": 4})
    z.d["stage"] = "forest"
    z.border("T", 2, gaps=[(44, 0, 3, 2), (44, 58, 3, 2)])
    rnd = random.Random(77)
    for y in range(2, H - 2):
        for x in range(2, W - 2):
            r = rnd.random()
            z.g[y][x] = "T" if r < 0.34 else "," if r < 0.5 else "."
    # the route: a winding track through the oaks
    path(z, [(44, 0), (44, 10), (30, 10), (30, 22)], "#", 3)
    z.rect(44, 0, 3, 13, "#")
    path(z, [(32, 33), (32, 40), (44, 40), (44, 58)], "#", 3)
    path(z, [(30, 16), (20, 16)], "#", 2)
    # the clearing of the Major Oak
    for y in range(22, 40):
        for x in range(24, 41):
            if math.hypot(x - 32, y - 30) <= 7.2:
                z.g[y][x] = "."
    for y in range(22, 40):
        for x in range(24, 41):
            if 5.4 <= math.hypot(x - 32, y - 30) <= 7.2 and (x + y) % 3:
                z.g[y][x] = "f"
    z.rect(30, 22, 3, 6, "#")
    n = 0
    for yy in range(28, 32):
        for xx in range(30, 34):
            z.prop("oak", xx, yy, variant=(n % 3)); n += 1
    z.prop("oak", 29, 29, variant=1); z.prop("oak", 34, 30, variant=2); z.prop("oak", 31, 27, variant=0); z.prop("oak", 32, 32, variant=1)
    z.prop("bench", 26, 30); z.prop("bench", 38, 30); z.prop("lamp_post", 27, 27); z.prop("lamp_post", 37, 27)
    z.prop("bench", 28, 35); z.prop("bench", 36, 35)
    z.sign(32, 33, "THE MAJOR OAK. The most famous tree in England, maybe a thousand years old, with a trunk so wide that its hollow once held twenty people. It's propped up on timber stilts, because it is very old and a bit tired, and the forest is very proud of it. It is said to have sheltered Robin Hood and his band. The tree is not telling.")
    # the visitor centre and the archery glade
    z.rect(20, 38, 10, 7, "."); z.rect(27, 35, 2, 5, "#")
    z.building(21, 39, 6, 3, "slate_cottage", "Visitor Centre")
    z.prop("bench", 23, 43); z.prop("planter", 20, 42); z.prop("lamp_post", 28, 41)
    for y in range(11, 26):
        for x in range(10, 28):
            if math.hypot(x - 17, y - 18) <= 6.5:
                z.g[y][x] = "."
    z.rect(11, 17, 14, 2, "#")
    z.prop("bench", 13, 21); z.prop("bench", 21, 21)
    z.sign(18, 20, "ARCHERY GLADE. A clearing where visitors may try a longbow. The targets are straw. The signs say 'please aim at the targets'. The signs have been shot at, too, which is why this one is written in very small letters.")
    # Herne's clearing, and the way out
    for y in range(42, 57):
        for x in range(40, 61):
            if math.hypot(x - 51, y - 49) <= 7.5:
                z.g[y][x] = "."
    for i in range(7):
        a = i * 2 * math.pi / 7
        z.prop("standing_stone", 51 + round(5.2 * math.cos(a)), 49 + round(4.6 * math.sin(a)), variant=i % 3)
    z.rect(44, 40, 3, 20, "#")
    z.rect(48, 47, 6, 5, "f")
    z.sign(49, 45, "HERNE'S CLEARING. The old stories say a hunter with antlers rides through the forest at dusk with a pack of hounds that no one quite sees. He's not cruel. He's only very fond of the chase. If you hear horns, stay on the path and say good evening.")
    z.npc(id="herne_spot", sprite="creature:herne", x=51, y=49, facing="left", move="still", script="herne", hide_if="caught_herne")
    script("sherwood", "herne", say("Herne the Hunter", "Placeholder: the story agent rewrites this legend script."))
    # trees across the whole wood: oaks, a few pines, bracken
    scatter_props(z, "oak", 3, 3, 58, 54, 150, 78, variants=3, avoid=(".",))
    scatter_props(z, "bush", 3, 3, 58, 54, 36, 79, avoid=(".",))
    z.sign(43, 5, "SHERWOOD FOREST. Once it covered a fifth of the county. A lot of it is now fields, but an ancient core of oaks survives, some as old as Domesday. The way through is marked. Please stay on it. The outlaws left years ago, but the nettles stayed.")
    z.sign(29, 11, "ROBIN HOOD. Nobody agrees when he lived, or if. In the earliest ballads he lived in Barnsdale, in Yorkshire. Then Nottingham got the story, with the Sheriff. Then Hollywood moved it all about. The forest has never had a view on the matter.")
    z.sign(36, 41, "LARDER OF THE OUTLAWS. Hunters in the old forest laws had to leave the king's deer alone. A good ballad made it a game. A bad winter made it a necessity. Please do not hunt the visitors.")
    # people
    chat(z, "sh_ranger", "birdwatcher", 28, 33, "Forest Ranger",
         ["The Major Oak is propped up on stilts, and there's a fence round the roots. Acorns drop on the path and the squirrels have a guard.",
          "Some oaks here are over eight hundred years old. They've seen kings come and go, and a good number of hikers. The hikers get on the nerves more."], "right", "still")
    chat(z, "sh_kid", "villager_3", 36, 31, "Acorn Collector",
         ["I've collected two hundred acorns! They're for the squirrels. I'm going to give them to the squirrels. The squirrels will not say thank you.",
          "You can put an acorn in a pot and in a hundred years it'll be a tree. I'll be a hundred and eleven. I've worked it out."], "left", "wander")
    chat(z, "sh_historian", "poet", 38, 12, "Ballad Singer",
         ["He robbed the rich to feed the poor, or he was a tax-dodger with a green hat. The ballads aren't sure. Oldest one's from the fifteenth century, and he's already a legend then.",
          "The Sheriff of Nottingham appears in the earliest stories. The poor man's always had a fine villain."], "down", "still")
    chat(z, "sh_birder", "hillwalker", 22, 21, "Night Walker",
         ["Nightjars come to the heath at dusk. They sound like a small machine that's been left on, and a sky that's gone very quiet. It's the best noise in the world.",
          "At night it's another forest. The tree trunks lean in. Even the hoots sound like questions."], "right", "wander")
    chat(z, "sh_tourist", "tour_guide", 24, 37, "Visitor Centre Guide",
         ["Welcome to Sherwood! We have a fine display of longbows, a mannequin in Lincoln green, and a gift shop selling green hats. They are, in all honesty, very good hats.",
          "The forest was a royal hunting preserve once. Now it's a country park where the deer are protected and the walkers are not."], "down", "still")
    trainer(z, "sh_forester", "Forester Alan", "Forester", "ghillie", [("dozelet", 87), ("martling", 87), ("spikkin", 87)],
            38, 8, "down", ["I manage the woodland. By which I mean I stand here and tell it what to do. It's not been listening since the Normans."],
            "Fair do's. You've a better eye for a tree than I.", "An oak is slow to grow and slow to leave. It's a lesson in patience, and in not planning anything.", 3800)
    trainer(z, "sh_archer", "Archer Marian", "Archer", "ghillie", [("zigzlet", 88), ("caperling", 88), ("thistlet", 87)],
            27, 14, "right", ["Bullseye? I never miss. Well. I never miss twice."],
            "A shot to the heart. Mine, not yours.", "Longbowmen could shoot twelve arrows a minute. In this forest, they'd have been shooting deer. And, I'm told, signs.", 3900)
    trainer(z, "sh_birdwatcher", "Birdwatcher Edmund", "Birdwatcher", "birdwatcher", [("hootlet", 88), ("barnling", 88), ("rooklet", 88)],
            36, 37, "left", ["Tawny owls, nightjars and woodpeckers. The woodpeckers drum on the oaks, which sounds like an outlaw knocking."],
            "My notes say you were unexpected. I've underlined it.", "Owls turn their heads two hundred and seventy degrees. It doesn't help their sense of direction.", 3800)
    trainer(z, "sh_archer2", "Archer Tuck", "Archer", "ghillie", [("fawnlet", 88), ("crexling", 88), ("pixling", 88)],
            40, 39, "down", ["I'm in the Merry Men's second string. I'm very merry. Whether I'm very good, you'll find out."],
            "A friar's tale, that. I'll go and make some ale.", "Never trust a man in Lincoln green who offers you a free hat.", 3850)
    trainer(z, "sh_warden", "Warden Rupert", "Warden", "warden_grunt", [("binfox", 88), ("sootwing", 88), ("cooplet", 88)],
            48, 53, "left", ["Welcome to the Robin Hood Experience! We've curated the forest for the benefit of everyone who pays for parking."],
            "You've beaten the Experience. I'll update the brochure.", "Lord Vane wants a theme park here with a rope bridge. Honestly, the oaks have been very patient.", 3800)
    z.rect(27, 14, 3, 1, "."); z.rect(35, 37, 2, 1, "."); z.rect(38, 8, 1, 2, ".")
    tidy(z)
    z.d["edges"] = {"north": {"to": "sheffield", "offset": 0}, "south": {"to": "nottingham", "offset": 0}}
    z.d["spawn"] = [45, 4]
    wild(z, [("dozelet", 87, 89, 14, {}), ("martling", 87, 88, 12, {}), ("zigzlet", 87, 89, 10, {"time": ["night", "dusk"]}),
             ("spikkin", 87, 88, 12, {}), ("fawnlet", 87, 89, 10, {}), ("hootlet", 87, 88, 10, {"time": ["night"]}),
             ("rooklet", 87, 88, 8, {}), ("thistlet", 87, 89, 8, {}), ("glowmite", 88, 89, 6, {"time": ["night", "dusk"]}),
             ("pixling", 87, 88, 8, {"weather": ["fog", "drizzle"]}), ("caperling", 88, 89, 6, {}), ("barnling", 87, 88, 8, {"time": ["night"]}),
             ("glisglis", 88, 89, 3, {"time": ["night"]}), ("flittermouse", 87, 88, 5, {"time": ["night"]})])
    z.save(OUT + "/sherwood.json")


def nottingham(OUT):
    W, H = 72, 56
    z = Z("nottingham", "Nottingham", W, H, kind="town", region="midlands", music="town_city", weather=WX_MID)
    z.d["stage"] = "city"; z.d["town_id"] = "nottingham"
    z.border("T", 2, gaps=[(44, 0, 3, 2), (30, 54, 3, 2)])
    z.scatter(0, 0, W, H, "P", 20, 13, only="T")
    # the castle on its sandstone rock
    z.rect(8, 5, 20, 8, "."); z.height(8, 5, 20, 8, 4)
    z.rect(6, 5, 2, 8, "^"); z.height(6, 5, 2, 8, 4)
    z.rect(8, 13, 20, 2, "^"); z.height(8, 13, 20, 2, 4)
    z.rect(8, 4, 20, 1, "^"); z.height(8, 4, 20, 1, 4)
    z.rect(28, 4, 1, 3, "^"); z.rect(28, 10, 1, 3, "^")
    z.rect(6, 13, 2, 2, "^")
    z.height(28, 7, 1, 3, 3); z.height(29, 7, 1, 3, 2); z.height(30, 7, 1, 3, 1)
    z.rect(28, 7, 3, 3, "#"); z.rect(31, 8, 13, 2, "#")
    z.building(11, 5, 14, 6, "castle", "Nottingham Castle")
    z.prop("statue", 27, 11); z.prop("lamp_post", 9, 6); z.prop("lamp_post", 26, 6); z.prop("bench", 15, 12); z.prop("bench", 21, 12)
    z.sign(26, 11, "ROBIN HOOD. A bronze outlaw with a bow, striding out of the castle gates since 1952. The sword fell off in 2012, and was replaced. The arrow was lost once to a bad day. The statue is smiling in all of them.")
    z.sign(14, 11, "NOTTINGHAM CASTLE. The castle sits on a rock of sandstone with caves honeycombed beneath it. The first castle was a Norman wooden fort. The current building is a grand house, because the castle itself was knocked about in the Civil War, and then burned down by an angry crowd in 1831. It is much more peaceful now.")
    # Ye Olde Trip to Jerusalem and the caves
    z.building(6, 17, 8, 3, "tudor", "Ye Olde Trip to Jerusalem")
    z.sign(10, 20, "THE CAVES. Beneath Nottingham are more than eight hundred hand-cut caves in the soft sandstone, used for cellars, tanneries, beer, wartime shelters and the odd secret. The pub next door claims it was founded in 1189. The caves keep their own counsel.")
    # the north road, the Old Market Square and the Council House
    z.rect(44, 0, 3, 22, "=")
    z.rect(26, 22, 27, 12, ":")
    z.building(31, 16, 12, 6, "liver_building", "Council House", door=6)
    z.prop("statue", 35, 23); z.prop("statue", 39, 23)
    z.sign(37, 23, "THE LIONS. Two stone lions guard the Council House, and Nottingham folk say they will 'meet you by the lions' with a certainty that has seen off many a mobile phone. They're called Leo and Oscar. Neither has ever been late.")
    for (cx, cy) in ((29, 28), (49, 28)):
        z.rect(cx - 1, cy - 1, 3, 3, "w"); put(z, cx, cy, "~")
    for (x, y) in [(33, 26), (45, 26), (33, 30), (45, 30), (38, 28), (40, 28)]:
        z.prop("market_stall" if x in (38, 40) else "bench", x, y)
    for (x, y) in [(27, 23), (51, 23), (27, 32), (51, 32), (42, 32), (36, 32)]:
        z.prop("lamp_post", x, y)
    z.prop("planter", 31, 24); z.prop("planter", 43, 24)
    z.sign(42, 24, "THE OLD MARKET SQUARE. One of the biggest city squares in Britain, with fountains and lions and room for the Goose Fair, which has been going for over seven hundred years. Come in October and you can eat a candy apple the size of your head, with a view.")
    # sanctuary and shop, with a cobbled lane in front
    z.rect(20, 34, 40, 1, ":"); z.rect(20, 39, 38, 1, ":")
    z.rect(30, 34, 3, 21, "=")
    z.building(23, 35, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(25, 38, "nottingham_shop", 4, 5, "up")
    z.building(35, 35, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(38, 38, "nottingham_sanctuary", 5, 6, "up")
    z.building(2, 23, 9, 4, "terrace"); z.building(12, 23, 8, 4, "red_brick", "Bike Works")
    z.building(2, 28, 9, 4, "terrace"); z.building(12, 28, 8, 4, "mill", "Lace Works")
    # the Lace Market
    z.rect(53, 13, 18, 22, ":")
    z.building(56, 15, 9, 5, "mill", "Lace Market")
    z.building(66, 15, 5, 5, "terrace"); z.building(56, 22, 8, 4, "terrace"); z.building(66, 22, 5, 4, "red_brick")
    z.building(56, 28, 8, 4, "red_brick", "Pork Pie Shop"); z.building(66, 28, 5, 4, "terrace")
    for (x, y) in [(55, 21), (65, 21), (55, 27), (65, 27), (55, 33), (65, 33)]:
        z.prop("lamp_post", x, y)
    z.sign(54, 21, "THE LACE MARKET. In Victorian times Nottingham made most of the world's machine-made lace, and the merchants built tall red-brick warehouses to show it. The lace has gone, the buildings remain, and now they sell cake. It is the best use of a warehouse.")
    # the station and its lane
    station(z, 46, 41, 10, 4, "Nottingham Station")
    z.rect(44, 39, 1, 5, ":"); z.rect(45, 43, 1, 1, ":")
    rail_guard(z, 52, 43, ["Nottingham Station. Trains for every station you have visited. Please stand clear of the platform edge, the lace curtains and the large goose."], facing="left")
    # the Trent
    z.rect(2, 47, 68, 5, "~"); z.rect(2, 46, 68, 1, "w"); z.rect(2, 52, 68, 1, "w")
    z.rect(30, 46, 3, 7, "="); z.rect(29, 47, 1, 5, "W"); z.rect(33, 47, 1, 5, "W")
    z.rect(3, 40, 22, 5, ","); z.rect(58, 40, 10, 5, ","); z.rect(3, 53, 26, 1, ","); z.rect(34, 53, 34, 1, ",")
    z.rect(26, 40, 3, 5, "."); z.rect(33, 40, 10, 5, ".")
    scatter_props(z, "oak", 3, 40, 40, 5, 5, 131, avoid=(".",))
    scatter_props(z, "birch", 3, 40, 66, 5, 5, 132, avoid=(".", ","))
    z.prop("bench", 34, 45); z.prop("bench", 40, 45); z.prop("lamp_post", 28, 45); z.prop("lamp_post", 34, 40)
    z.prop("boat", 12, 49, variant=1); z.prop("canal_boat", 52, 50); z.prop("buoy", 40, 49)
    z.sign(28, 44, "THE TRENT. The big river of the Midlands, wide and brown and slow. On its banks stand a football ground and a cricket ground, and a pair of football teams who are both rather proud of their trophies. The reeds hold more than their share of birds.")
    # people
    chat(z, "not_lace", "villager_5", 61, 21, "Lace Historian",
         ["Nottingham lace was machine-made on frames of cast iron, a bit like a very precise loom. The lace curtains in your gran's front window were probably made here.",
          "The Lace Market warehouses have a big sign inside saying 'Gents' and a small sign saying 'Please do not iron the exhibits'."], "down", "wander")
    chat(z, "not_caver", "tin_miner", 12, 21, "Cave Guide",
         ["There's a city under the city. Eight hundred caves, hand-cut with pick and chisel in the soft stone. Tanners, brewers, bakers, hiders. Nottingham likes to keep something in reserve.",
          "In the war, the caves were air raid shelters. Now they're museums and wine cellars. Not at the same time."], "down", "still")
    chat(z, "not_footie", "jogger", 40, 31, "Football Fan",
         ["Nottingham Forest won the European Cup. Twice. In a row. 1979 and 1980. We bring it up whenever we are, to be fair, losing at something else.",
          "Brian Clough managed them. He once said, 'I wouldn't say I was the best manager in the business, but I was in the top one.' I'm proud, and also dubious."], "down", "wander")
    chat(z, "not_goose", "villager_4", 46, 26, "Goose Fair Stallholder",
         ["Goose Fair started as a medieval market where people sold geese. Now it sells mushy peas and a ride that goes upside down. The geese went home, but the name stayed.",
          "A bag of brandy snap, a candy apple and a whirl on the waltzers. That's a Nottingham October. Everything else is bunting."], "left", "still")
    chat(z, "not_cyclist", "jogger", 18, 21, "Cyclist",
         ["Raleigh bicycles started here in 1887, and soon they made hundreds of thousands a year. It was a Nottingham invention. I'm not saying the bike was a Nottingham invention. I'm saying the best ones were.",
          "My bike's called Brenda. She's got a bell like a church."], "right", "wander")
    trainer(z, "not_archer", "Archer Mathilda", "Archer", "ghillie", [("zigzlet", 88), ("fawnlet", 88), ("caperling", 88)],
            42, 12, "right", ["Robin Hood's from here, so I'm contractually obliged to say I'm his cousin. I am, in fact, his accountant's cousin."],
            "A clean shot. Can I take your autograph? For the castle?", "In the ballads, Robin won an archery contest by splitting his rival's arrow. In the film, he did it twice for effect.", 4000)
    trainer(z, "not_warden", "Warden Quentin", "Warden", "warden_grunt", [("binfox", 88), ("railspark", 88), ("raidtail", 88)],
            47, 31, "left", ["Welcome to the Sheriff's Experience! Taxes are in the post. The Experience is free, though the exit is a gift shop."],
            "I'll tell the Sheriff I tried my best. He'll be furious. And polite.", "The Enclosure wants Nottingham's caves converted to a 'subterranean retail opportunity'. The caves said no, politely.", 3950)
    trainer(z, "not_angler", "Angler Gerald", "Angler", "angler", [("stalklet", 88), ("pincray", 88), ("bittling", 88)],
            28, 46, "right", ["Barbel, chub and bream on the Trent. There's a bittern in the reeds somewhere. I've heard it. I've never seen it."],
            "Flushed out of my reeds. Well fought.", "A bittern stands with its beak pointing at the sky so it looks like a reed. I tried it once. It did not work.", 3900)
    z.d["edges"] = {"north": {"to": "sherwood", "offset": 0}, "south": {"to": "birmingham", "offset": 0}}
    z.d["spawn"] = [45, 28]
    wild(z, [("bittling", 88, 89, 12, {"time": ["dawn", "dusk", "night"]}), ("binfox", 88, 88, 10, {"time": ["night", "dusk"]}), ("grizzlet", 88, 89, 10, {}),
             ("cooplet", 88, 88, 12, {}), ("bobbin", 88, 89, 8, {}), ("starlet", 88, 89, 10, {"time": ["day", "dusk"]}), ("sootwing", 88, 89, 8, {"time": ["night"]}),
             ("hootlet", 88, 88, 6, {"time": ["night"]}), ("chipgull", 88, 89, 10, {}), ("pepperling", 88, 89, 8, {})])
    wild(z, [("stalklet", 88, 89, 18, {}), ("minkshade", 88, 89, 10, {"time": ["night", "dusk"]}), ("cranelet", 88, 89, 14, {}),
             ("pincray", 88, 89, 10, {}), ("chipgull", 88, 88, 14, {}), ("dipling", 88, 89, 12, {}), ("bittling", 88, 89, 8, {})], "water")
    tidy(z)
    z.save(OUT + "/nottingham.json")
    sanctuary(OUT, "nottingham", "Nottingham", (38, 39))
    shop(OUT, "nottingham", "Nottingham", (25, 39))
    nurse("nottingham", ["Hiya, duck! Welcome to the Nottingham Sanctuary. Pop your team on the counter and I'll take a look.",
                         "Sit yourself down, duck. There's a brew on, and a custard cream. Your team's in good hands. Even the Sheriff would say so.",
                         "All done, duck. They're fit as a fiddle and twice as shiny. Mind how you go, and mind the lions.",
                         "The Ark? It's down in the cellar, duck, in one of the caves. It runs very cool, which is nice. It's also a bit damp.",
                         "No worries, duck. Come back any time. We're open when it rains. Which it does."])
    shopkeeper("nottingham", "Now then, duck! Pork pies, brandy snap and a bottle of something brown. What'll it be?",
               "Ta-ra, duck. Meet you by the lions.")
