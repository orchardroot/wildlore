# plan 6 group A, part 1: northumberland_coast (Lindisfarne, Bamburgh, puffins) and hadrians_wall.
from p6a_common import *
from wcommon import _stand


def build(OUT):
    coast(OUT)
    wall(OUT)


def coast(OUT):
    W, H = 72, 62
    zid = "northumberland_coast"
    z = Z(zid, "Northumberland Coast", W, H, kind="route", region=NE, music="route_coast",
          weather={"clear": 24, "sunshine": 16, "drizzle": 22, "fog": 16, "gale": 16, "downpour": 6})
    z.d["stage"] = "coast"
    z.border("T", 2, gaps=[(47, 0, 3, 2), (20, 60, 3, 2)])
    z.scatter(0, 0, W, H, "P", 22, 71, only="T")
    # the sea on the east, with a beach
    vsea(z, 53, 0, H)
    z.rect(53, 0, 19, 2, "$"); z.rect(53, 60, 19, 2, "$")
    # dunes along the shore
    z.rect(49, 2, 4, 58, ",")
    for (cx, cy, rx, ry, sd) in [(10, 12, 6, 4, 1), (14, 40, 7, 4, 2), (36, 20, 5, 3, 3), (30, 49, 6, 3, 4), (8, 52, 5, 3, 5),
                                 (36, 38, 4, 3, 6), (28, 8, 5, 3, 7), (40, 54, 4, 3, 8)]:
        blob(z, cx, cy, rx, ry, ",", only=".", seed=sd, jitter=0.4)
    # the road south: down from Aberdeen, west along the fields, then south
    z.rect(47, 2, 3, 29, "#")
    z.rect(21, 29, 29, 3, "#")
    z.rect(21, 31, 3, 29, "#")
    # Lindisfarne: tidal flats, the causeway, the island
    z.rect(57, 5, 15, 21, "~")
    z.rect(50, 13, 12, 3, "#")
    z.rect(53, 14, 10, 3, "s")
    z.rect(53, 13, 10, 1, "s"); z.rect(53, 16, 10, 1, "s")
    z.rect(53, 14, 4, 1, "#")
    z.rect(57, 13, 6, 1, "~"); z.rect(57, 17, 6, 1, "~")
    z.rect(57, 14, 6, 3, "s")
    island(z, 62, 6, 9, 19)
    z.rect(63, 14, 4, 3, "#")
    z.height(62, 6, 9, 7, 1); z.height(63, 7, 7, 5, 2)
    z.building(63, 7, 7, 3, "castle", "Lindisfarne Castle")
    z.rect(66, 10, 1, 5, "#")
    z.building(65, 18, 5, 3, "chapel", "Lindisfarne Priory (ruins)", show_label=True)
    z.rect(63, 16, 7, 1, ".")
    z.prop("bench", 64, 14); z.prop("bush", 69, 22, variant=1); z.prop("bush", 63, 21)
    z.prop("rock", 68, 13); z.prop("rock", 63, 12)
    z.sign(55, 12, "THE PILGRIMS' WAY. Lindisfarne is an island twice a day and a peninsula the rest of the time. The causeway is covered by the tide, and the crossing times are posted on the board by the road. Check them. The refuge box on stilts in the middle exists because people have been rescued from it, with great embarrassment.")
    z.sign(64, 19, "LINDISFARNE PRIORY. Founded by St Aidan in 635. Viking raiders hit it in 793, the first big Viking raid on Britain, and the monks had made the Lindisfarne Gospels here, a book so beautiful it is now in the British Library under glass. The monks also made mead, which survived rather better than the roof.")
    z.sign(66, 11, "LINDISFARNE CASTLE. A tiny fort on a lump of whinstone built in the 1500s, then turned into a holiday home in 1901 by an architect who knew a good view when he saw one. The lime kilns by the harbour burned limestone for the farms of the Borders.")
    # Bamburgh Castle on its rock
    z.rect(47, 32, 3, 18, "#")
    z.height(41, 41, 13, 9, 1); z.height(42, 42, 11, 6, 2)
    z.rect(41, 41, 13, 1, "R"); z.rect(41, 41, 1, 9, "R"); z.rect(53, 41, 1, 9, "R")
    z.rect(42, 48, 5, 1, "R"); z.rect(50, 48, 3, 1, "R")
    z.building(42, 42, 11, 4, "castle", "Bamburgh Castle", door=5)
    z.rect(42, 46, 11, 2, ".")
    z.rect(47, 46, 3, 2, "#")
    z.prop("lamp_post", 44, 46); z.prop("lamp_post", 51, 46); z.prop("bench", 45, 47)
    z.sign(46, 31, "BAMBURGH. The seat of the kings of Northumbria, with a rock under it that is an old volcanic dyke. The castle was the first in England to fall to gunpowder, in the Wars of the Roses. These days it hosts weddings, school trips and a collection of very large armour.")
    z.sign(46, 50, "THE BEACH BELOW THE CASTLE. A wide sandy beach under a very large castle. Locals say it is the best beach in England and keep very quiet about it, which is not working.")
    # the Farne Islands: puffins offshore
    z.rect(58, 33, 6, 5, "R"); z.rect(59, 34, 4, 3, ".")
    z.rect(58, 33, 1, 1, "$"); z.rect(63, 37, 1, 1, "$")
    z.rect(57, 35, 2, 1, "w")  # a shallow sandbar out to the islet so the puffins can be reached
    z.prop("lighthouse", 61, 34)
    z.prop("boat", 56, 36, variant=1)
    # puffins: not walkable around, but they sit on the grass
    for i, (x, y) in enumerate([(59, 34), (62, 35), (60, 36)]):
        creature(z, zid, "puffling", x, y, move="still",
                 line="A puffin the size of a teapot carries nine sand eels in its beak at once, which is a world record, for puffins. It looks at you as if you are late.",
                 who="Puffin")
    z.sign(54, 35, "THE FARNE ISLANDS. Out on that rock is Longstone Lighthouse. In 1838 Grace Darling and her father rowed out through a storm to rescue nine survivors of a shipwreck. She was twenty-two. The boatmen of Seahouses will take you out to see the puffins, who have no sense of occasion.")
    # farms and walls inland
    z.building(30, 8, 6, 3, "slate_cottage", "Fenwick Farm"); z.building(38, 18, 5, 3, "slate_cottage", "Holburn Farm")
    z.building(6, 20, 6, 3, "slate_cottage", "Elwick Cottage"); z.building(36, 46, 6, 3, "slate_cottage", "Budle Farm")
    for (x, y, w, h) in [(4, 5, 20, 1), (4, 8, 1, 14), (18, 24, 1, 10), (4, 35, 12, 1), (26, 36, 10, 1), (12, 52, 9, 1)]:
        z.rect(x, y, w, h, "W")
    z.rect(24, 29, 3, 1, "#")
    scatter_props(z, "birch", 3, 3, 46, 56, 14, 11, avoid=(".",))
    scatter_props(z, "bush", 3, 3, 50, 56, 22, 12, avoid=(".", ","))
    scatter_props(z, "rock", 3, 3, 50, 56, 8, 13, avoid=(".",))
    z.prop("bench", 46, 24); z.prop("bench", 46, 27)
    # beach rock pool (Brook-wade)
    # the road south
    z.sign(25, 31, "ROUTE SOUTH. Left for the long beach and Seahouses. Right for Craster, and kippers. Straight on for the Wall, Newcastle, and an entirely different accent.")
    # NPCs
    chat(z, "nc_tidewarden", "villager_3", 54, 12, "Tide Warden",
         ["Tide's out. For now. The sea comes back twice a day, and it does not do a polite knock first.",
          "The rule is simple: if the water is on the road, you are late. If the water is on your boots, you are very late. If the water is on the refuge box, please wave."], "right", "still")
    chat(z, "nc_mead", "shopkeeper", 66, 16, "Mead Seller",
         ["Lindisfarne mead! Honey, water and a little tradition. The monks made it, and sold it, and I would like to think they would be proud, or at least interested in the margins.",
          "The island has about a hundred and fifty people living on it. And three thousand visitors a day in the season. The other forty-seven weeks are quiet."], "up", "still")
    chat(z, "nc_boatman", "fisher", 51, 36, "Seahouses Boatman",
         ["Puffin trip? Half past ten. The puffins turn up in April and clear off in August, and the rest of the year they are out at sea, bobbing about, being private.",
          "They fly with wings going about four hundred beats a minute. They land like a dropped suitcase. It's marvellous."], "right", "still")
    chat(z, "nc_steward", "tour_guide", 48, 47, "Castle Steward",
         ["Welcome to Bamburgh. The Great Hall has a roof from the 1890s, because Lord Armstrong, the man who made the cannons, bought the castle and rebuilt it as a hospital for sailors and a school for girls.",
          "It's the sort of castle that looks as if it has been here since before time. That is mostly the look of the rock."], "down", "still")
    chat(z, "nc_kipper", "villager_5", 22, 48, "Kipper Smoker",
         ["Craster kippers. Herring, split, salted, smoked over oak for sixteen hours. The smokehouse has been at it since 1856.",
          "People say they smell it from the road. I say: that's not a smell, that's a signpost."], "right", "still")
    # trainers
    trainer(z, "nc_birder", "Birdwatcher Margaret", "Birdwatcher", "birdwatcher",
            [("puffling", 78), ("plungebeak", 79), ("polartern", 79)], 45, 8, "right",
            ["Shh. Eider ducks. The males are black and white and the females are mottled brown, and they're called Cuddy ducks after St Cuthbert, who protected them. Now. Your move."],
            "Well flown. That's thrown my count off entirely.", "A birdwatcher counts, notes, waits. A trainer does all that and then shouts. I am learning.", 3120)
    trainer(z, "nc_fisher", "Fisher Alan", "Fisher", "fisher",
            [("greyhaul", 79), ("bayrunner", 79), ("pierlord", 80)], 53, 18, "up",
            ["Lobsters on the Holy Island pots. Crab, too. The crab is the clever one. It gets in, eats the bait, and writes a review."],
            "A fair haul. I've been out-fished by a visitor again.", "The sea's cold up here. The North Sea doesn't do warm. It does 'bracing'.", 3160)
    trainer(z, "nc_historian", "Historian Dr Aldred", "Historian", "poet",
            [("lanternis", 78), ("hushwing", 79), ("centurion", 79)], 63, 17, "up",
            ["The Lindisfarne Gospels were made around 715 by a monk named Eadfrith. That is the only fact I need. Please, take your time with the rest."],
            "A scholarly victory. I shall write it up in tiny, beautiful letters.", "Aldred was the monk who, two hundred years later, added the English translation between the lines. It's the oldest English version of the Gospels. He's the original footnote.", 3200)
    trainer(z, "nc_angler", "Angler Peggy", "Angler", "angler",
            [("heronarch", 79), ("levelcrane", 79), ("bradan", 80)], 44, 36, "right",
            ["Sea bass off the rocks, with a rod and a flask of tea. If a fish never bites I call it a day of contemplation."],
            "Nicely cast. You've a gift for it, and I mean fishing.", "The Farne seals are the real anglers. They do it all with no rod and no flask.", 3180)
    trainer(z, "nc_warden", "Warden Rupert", "Warden", "warden_grunt",
            [("sootwing", 79), ("rookery", 79), ("adderking", 80)], 25, 46, "left",
            ["The Enclosure has decided this coastline needs curating. Wide beaches, wild dunes and huge skies are a bit uncontrolled. I'm here to tidy them up."],
            "Curating, it seems, is harder than it looks.", "The Enclosure says the dunes will be neatly raked. I have seen the dunes. I have seen the rake.", 3100)
    # encounters
    wild(z, [("puffling", 78, 80, 14, {}), ("ternlet", 78, 80, 12, {}), ("starlet", 78, 80, 10, {"time": ["dusk", "dawn"]}),
             ("leveret", 78, 80, 10, {}), ("kitelet", 78, 80, 8, {"time": ["day"]}), ("zigzlet", 78, 80, 6, {"time": ["night"]}),
             ("hootlet", 78, 80, 6, {"time": ["night"]}), ("pepperling", 78, 80, 8, {}), ("pupplash", 78, 80, 8, {"weather": ["fog", "drizzle"]}),
             ("cooplet", 78, 80, 6, {})])
    wild(z, [("pupplash", 78, 80, 22, {}), ("gannetling", 78, 80, 18, {}), ("dolphlet", 78, 80, 12, {"time": ["day"]}),
             ("pinchkin", 78, 80, 20, {}), ("chipgull", 78, 80, 16, {}), ("puffling", 78, 80, 12, {}), ("ternlet", 78, 80, 8, {})], "water")
    z.d["edges"] = {"north": {"to": "aberdeen", "offset": 0}, "south": {"to": "hadrians_wall", "offset": 0}}
    z.rect(47, 0, 3, 2, "#"); z.rect(20, 60, 3, 2, "#")
    z.rect(54, 52, 2, 3, "o"); z.rect(54, 52, 2, 1, "w")
    z.d["spawn"] = [48, 4]
    done(z)
    z.save(OUT + "/" + zid + ".json")


def wall(OUT):
    W, H = 80, 56
    zid = "hadrians_wall"
    z = Z(zid, "Hadrian's Wall", W, H, kind="route", region=NE, music="route_moor",
          weather={"clear": 24, "sunshine": 12, "drizzle": 24, "fog": 18, "gale": 14, "downpour": 8})
    z.d["stage"] = "moor"
    z.legend["h"] = {"tile": "tall_grass", "colour": "#6e5a5c", "prop": "heather"}
    z.legend["k"] = {"tile": "tall_grass", "colour": "#7a7444", "prop": "none"}
    z.legend["g"] = {"tile": "grass", "colour": "#7d8a4a"}
    z.rect(0, 0, W, H, "g")
    z.border("T", 2, gaps=[(20, 0, 3, 2), (30, 54, 3, 2)])
    z.scatter(0, 0, W, H, "P", 25, 33, only="T")
    # the crags: heights step up to the Wall at y=25 and down again
    prof = {0: 0, 14: 0, 16: 1, 18: 1, 20: 2, 22: 2, 23: 3, 24: 3, 25: 3, 26: 3, 27: 2, 29: 2, 30: 1, 32: 1, 34: 0}
    ys = sorted(prof)
    for y in range(H):
        v = 0
        for a in ys:
            if y >= a:
                v = prof[a]
        for x in range(W):
            z.hg[y][x] = v
    # Sycamore Gap: a dip in the ridge
    for y in range(18, 34):
        for x in range(3, 13):
            d = max(abs(x - 7) / 4.0, abs(y - 26) / 6.0)
            z.hg[y][x] = max(0, z.hg[y][x] - (3 if d < 0.4 else 2 if d < 0.7 else 1 if d < 1.0 else 0))
    smooth(z)
    # cliffs on the north face of the crags where there is no path
    for x in range(3, W - 3):
        if not (18 <= x <= 24) and not (3 <= x <= 13):
            if 20 <= x <= 60 or x > 60:
                z.set(x, 21, "^")
    # heather moor and tall grass patches
    for (cx, cy, rx, ry, sd) in [(34, 9, 7, 3, 1), (56, 12, 8, 3, 2), (12, 10, 6, 3, 3), (68, 8, 6, 3, 4), (30, 42, 6, 3, 5),
                                 (66, 48, 7, 3, 6), (10, 46, 5, 3, 7), (52, 38, 4, 2, 8)]:
        blob(z, cx, cy, rx, ry, "h", only="g", seed=sd, jitter=0.4)
    for (cx, cy, rx, ry, sd) in [(44, 6, 6, 3, 9), (72, 20, 4, 3, 10), (20, 36, 5, 2, 11), (74, 40, 4, 3, 12)]:
        blob(z, cx, cy, rx, ry, ",", only="g", seed=sd, jitter=0.4)
    # the Wall itself
    z.rect(3, 25, W - 6, 1, "W")
    z.rect(3, 24, 1, 3, "W"); z.rect(W - 4, 24, 1, 3, "W")
    # Sycamore Gap: the Wall dips down and back up, and the gap is open grass
    z.rect(5, 24, 5, 3, "g")
    # the path through the Wall: the milecastle gate
    z.rect(20, 2, 3, 52, "#")
    z.rect(30, 38, 3, 16, "#")
    z.rect(20, 40, 13, 3, "#")
    z.rect(19, 24, 1, 3, "W"); z.rect(23, 24, 1, 3, "W")
    z.building(14, 22, 4, 2, "castle", "Milecastle 37")
    z.set(19, 25, "W"); z.set(23, 25, "W")
    z.rect(20, 25, 3, 1, "#")
    z.prop("lamp_post", 19, 23); z.prop("lamp_post", 23, 23)
    # the Sycamore Gap tree: a lone oak in the dip, with a respectful sign
    z.prop("oak", 7, 25, variant=1)
    z.rect(6, 28, 3, 1, "#")
    z.rect(7, 26, 1, 3, "#")
    z.rect(7, 29, 14, 1, "#")
    z.prop("bench", 5, 27); z.prop("bench", 9, 27)
    z.sign(7, 28, "SYCAMORE GAP. For about 150 years a single sycamore grew in this dip in the Wall, and it was in so many photographs, weddings and films that nobody could say who first loved it. It was cut down in 2023. It has been missed ever since, and the stump has sent up new shoots. The sign asks that you stand quietly here for a moment.")
    # Housesteads Roman Fort: walls, gates, ruins
    z.rect(40, 30, 22, 1, "W"); z.rect(40, 44, 22, 1, "W"); z.rect(40, 30, 1, 15, "W"); z.rect(61, 30, 1, 15, "W")
    z.rect(40, 37, 1, 3, "g"); z.rect(49, 30, 3, 1, "g")
    z.rect(41, 31, 20, 13, "g")
    z.height(40, 30, 22, 15, 1)
    z.building(43, 32, 6, 3, "castle", "Granary")
    z.building(53, 32, 6, 3, "castle", "Headquarters")
    z.building(43, 40, 6, 3, "castle", "Hospital")
    z.building(53, 40, 6, 3, "castle", "Barrack Block")
    z.building(55, 37, 3, 2, "chapel", "Latrines (the famous one)")
    z.rect(49, 31, 3, 13, "#")
    z.rect(33, 38, 8, 3, "#")
    z.rect(41, 37, 8, 3, "#")
    z.prop("bench", 46, 37); z.prop("planter", 48, 39)
    z.sign(52, 36, "HOUSESTEADS. Roman Vercovicium, a fort for about 800 soldiers, built around AD 124. The Romans had stone benches, a hospital, a granary on stilts to keep the mice out, and the best-preserved communal latrine in Britain: a row of seats over a flushing channel. They sat and chatted. It was the Roman break room.")
    # the Wall itself: signs and the Vindolanda tablet
    z.sign(25, 26, "HADRIAN'S WALL. Begun around AD 122 on the orders of the Emperor Hadrian, who came to Britain to see for himself, and ran from Wallsend on the Tyne to Bowness on the Solway: about 73 miles. A milecastle every Roman mile, a turret every third of a mile, and a ditch to the north. It was built by soldiers, not slaves, who left their names scratched into the stone.")
    z.sign(40, 13, "VINDOLANDA. Just down the road, archaeologists found a stack of thin wooden writing tablets, 1,900 years old. One is an invitation to a birthday party, from Claudia Severa to her friend Sulpicia Lepidina: 'Come to us on 11 September, to make the day more enjoyable for me.' It is the oldest known handwriting by a woman in Latin in Britain.")
    scatter_props(z, "rock", 3, 3, 74, 50, 24, 41, avoid=("g", "h"))
    scatter_props(z, "bush", 3, 3, 74, 50, 12, 42, avoid=("g",))
    scatter_props(z, "pine", 3, 3, 74, 14, 8, 43, avoid=("g",))
    # NPCs
    chat(z, "hw_centurion", "villager_2", 24, 28, "Centurion (Re-enactor)",
         ["Ave! I'm a Roman soldier, between jobs. The legions marched twenty miles a day in full kit, which is a pack, a spade, a stake and a very opinionated mule.",
          "Soldiers on the Wall came from Spain, Syria, Belgium and the Danube. It was the most multicultural place in Britain, and they all complained about the weather."], "right", "wander")
    chat(z, "hw_ranger", "tour_guide", 45, 47, "Wall Ranger",
         ["The Wall was painted white once, and plastered. In the sun it must have shone like a long, slightly smug chalk line across the country.",
          "The stones you see were reused in later centuries for farm walls and churches. A good deal of Northumberland is Roman, with extra sheep."], "up", "still")
    chat(z, "hw_volunteer", "villager_6", 8, 29, "Tree Volunteer",
         ["Be gentle. Folk come here to stand. Some just sit. Everyone lowers their voice, without being asked.",
          "They took cuttings and seeds, and the saplings are growing on, safe, in nurseries. A tree is slow, but it's good at beginnings."], "up", "still")
    chat(z, "hw_walker", "hiker", 28, 12, "Long-Distance Walker",
         ["Eighty-four miles of the Hadrian's Wall Path, coast to coast. The trail goes up, down, up, down, with a view at the top of every up and a sandwich at the bottom of every down.",
          "My feet have opinions. I haven't been told them yet. They are saving them for the second day."], "down", "wander")
    chat(z, "hw_shepherd", "farmer", 56, 22, "Shepherd",
         ["Sheep don't care about the Wall. They go over it, under it and through any gap they find. Hadrian planned for Picts. He did not plan for Swaledales.",
          "I counted two hundred this morning. Then I counted two hundred and four. Then I gave up."], "left", "wander")
    # trainers
    trainer(z, "hw_runner", "Fell Runner Sam", "Fell Runner", "jogger",
            [("kitelet", 80), ("ptarmigan", 80), ("stagmor", 80)], 24, 15, "left",
            ["Fell running: you run up a hill, then you run down it, and you do not walk. Nobody explains why. Shall we?"],
            "That was quick. I'd say you were a natural, but you also took the shortcut.", "The Wall Path 'Sprint' record is a few hours. Mine is a long weekend and a bag of jelly babies.", 3280)
    trainer(z, "hw_historian", "Historian Dr Pell", "Historian", "poet",
            [("centurion", 80), ("legionette", 80), ("brockmoor", 80)], 41, 36, "right",
            ["There are thirteen types of Roman helmet. I have strong views on all of them. Come, I'll tell you the whole lot, between rounds."],
            "Well fought. I shall note a minor error in my records. Your boots.", "The Romans left in 410. The Wall is still here. They may have been thinking ahead.", 3300)
    trainer(z, "hw_warden", "Warden Nigel", "Warden", "warden_grunt",
            [("forkwing", 80), ("raidtail", 80), ("hazeldoze", 80)], 34, 44, "up",
            ["The Enclosure says an ancient wall across the countryside is a bit of a fence. We think it needs a gate. And a ticket machine. And a turnstile."],
            "You win. I'll make a note to put a turnstile where you stood.", "We'll curate the gap, and put up a sign saying 'Gap'.", 3240)
    trainer(z, "hw_birder", "Birdwatcher Tilly", "Birdwatcher", "birdwatcher",
            [("goldeneyrie", 80), ("lochosprey", 80), ("stoopfalcon", 80)], 20, 34, "right",
            ["Peregrines on the crag, and ravens, and curlews that sound like a kettle, only sadder. Let me show you what real flight looks like."],
            "You're a joy to watch. Mind the curlews.", "A peregrine dives at two hundred miles an hour. I get a bit dizzy just writing it down.", 3260)
    # encounters
    wild(z, [("kitelet", 80, 80, 12, {"time": ["day"]}), ("ptarmlet", 80, 80, 12, {"weather": ["fog", "frost", "gale"]}),
             ("thistlet", 80, 80, 12, {}), ("fawnlet", 80, 80, 10, {"time": ["dawn", "dusk"]}), ("brockling", 80, 80, 10, {"time": ["dusk", "night"]}),
             ("leveret", 80, 80, 10, {}), ("zigzlet", 80, 80, 8, {"time": ["night"]}), ("horselet", 80, 80, 6, {"time": ["night"]}),
             ("stoatlet", 80, 80, 8, {}), ("rooklet", 80, 80, 8, {"time": ["day"]}), ("slatelet", 80, 80, 6, {})])
    z.d["edges"] = {"north": {"to": "northumberland_coast", "offset": 0}, "south": {"to": "newcastle", "offset": 0}}
    z.rect(20, 0, 3, 2, "#"); z.rect(30, 54, 3, 2, "#")
    z.d["spawn"] = [21, 4]
    done(z)
    z.save(OUT + "/" + zid + ".json")
