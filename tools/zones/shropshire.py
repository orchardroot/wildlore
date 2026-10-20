# Wildlore 3.0 "Wider Isles": Shropshire, off Chester's south side. Shrewsbury (the town in the Severn loop),
# the Ironbridge Gorge (Coalbrookdale, the Iron Bridge, Blists Hill, the Wrekin, Much Wenlock and Wenlock Edge)
# and the Shropshire Hills (the Long Mynd and the Stiperstones). All scaled from par 21, Chester's band.
#
#   python3 tools/zones/shropshire.py data/zones
#
# Writes the zones, their interiors, dialogue (data/dialogue) and trainers (data/trainers). Quests, items,
# shop and creatures are plain data files edited by hand.
import sys
from p6a_common import *
from wcommon import _stand
from zlib import landmark

REG = "midlands"
FLOOR = 21  # Chester's band: everything here is authored for a level ~21 team and lifts with the story
OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"


def river(z, pts, wdt=4):
    """a river as thick axis-aligned strokes of deep water, then a walkable shallow fringe where it meets land."""
    path(z, pts, "~", wdt)


def fringe(z, land=".,#:=fT"):
    marks = []
    for y in range(z.h):
        for x in range(z.w):
            if z.g[y][x] != "~":
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                xx, yy = x + dx, y + dy
                if 0 <= xx < z.w and 0 <= yy < z.h and z.g[yy][xx] in land:
                    marks.append((x, y))
                    break
    for (x, y) in marks:
        z.set(x, y, "w")


def plaque(z, x, y, pid, title, text):
    _stand(z, x, y)
    z.d["signs"].append({"x": x, "y": y, "plaque": "shropshire_" + pid, "title": title, "text": text})


def door_in(z, x, y, to, w=13, h=10):
    """warp from a town door at (x, y) into a landmark interior of size w x h (arrive above its exit)."""
    z.warp(x, y, to, w // 2, h - 3, "up")


def scale_trainers(ids):
    for t in ids:
        TRN[t]["scaled_floor"] = FLOOR


# ------------------------------------------------------------------------------------------------ Shrewsbury
def shrewsbury():
    W, H = 72, 60
    zid = "shrewsbury"
    z = Z(zid, "Shrewsbury", W, H, kind="town", region=REG, music="town_cheshire",
          weather={"drizzle": 30, "clear": 30, "sunshine": 20, "fog": 10, "gale": 4, "downpour": 6})
    z.d["stage"] = "town"; z.d["town_id"] = zid; z.d["scaled_floor"] = FLOOR
    z.rect(0, 0, W, H, ".")
    z.border("T", 2, gaps=[(26, 0, 3, 2), (70, 33, 2, 3), (23, 58, 3, 2)])
    z.scatter(0, 0, W, H, "P", 10, 3, only="T")
    # the Severn loop: in from the west, round the town and out to the east; the town sits inside it
    river(z, [(0, 18), (12, 18), (12, 50), (57, 50), (57, 18), (68, 18)])
    z.rect(68, 18, 4, 4, "~")
    fringe(z)
    z.rect(70, 18, 2, 4, "~"); z.rect(0, 18, 2, 4, "~")
    # the road from Chester, down to the town through the neck of the loop
    z.rect(26, 0, 3, 27, "=")
    # Ditherington Flax Mill, north of the town
    z.building(3, 3, 16, 4, "flax_mill", "Ditherington Flax Mill", door=8)
    door_in(z, 11, 6, "shrewsbury_flaxmill", 15, 10)
    z.rect(4, 7, 22, 1, ":")
    plaque(z, 20, 7, "flax_mill", "Ditherington Flax Mill",
           "Built in 1797 to spin flax into linen thread, with a frame of cast-iron columns and beams instead of timber, so it would not burn down like other mills. It was the first iron-framed building in the world, the grandfather of every skyscraper. Later it malted barley for brewers, and it has been restored.")
    # Shrewsbury Castle at the neck, the station just beyond it
    z.building(33, 2, 9, 6, "castle", "Shrewsbury Castle", door=4)
    door_in(z, 37, 7, "shrewsbury_castle")
    z.rect(29, 8, 25, 1, ":")
    plaque(z, 35, 8, "castle", "Shrewsbury Castle",
           "Roger de Montgomery built a castle here in red sandstone soon after 1066, to guard the only dry way into the town, across the neck of the river loop. Thomas Telford tidied it up around 1790 and added Laura's Tower as a summerhouse. It now holds the Soldiers of Shropshire Museum.")
    station(z, 45, 9, 8, 3, "Shrewsbury Station")
    z.rect(44, 8, 1, 5, ":")
    z.rect(44, 12, 1, 1, ":")
    z.rect(44, 12, 1, 1, ":")
    z.rect(45, 12, 27, 1, "!")
    z.rect(44, 12, 1, 1, "!")
    z.set(44, 11, ":")
    z.prop("buffer_stop", 43, 12)
    z.rect(42, 9, 2, 3, ":")
    rail_guard(z, 52, 11, ["Shrewsbury Station, done up in mock Tudor in 1848 to match the black-and-white town. Part of it is built out over the river. Lovely, as long as you don't drop your ticket.",
                           "Trains to everywhere you have been. You need a Rail Pass, and if you say Shrewsbury wrong the barrier says it back to you."], facing="left")
    plaque(z, 41, 10, "station", "Shrewsbury Station",
           "Opened in 1848 and built in a Tudor Gothic style to suit the old town. Part of the station stands on a bridge over the Severn, which makes it one of very few stations in Britain built over a river.")
    # Castle Foregate: brick terraces between the station and the river
    z.building(31, 14, 9, 3, "terrace", show_label=False)
    z.building(47, 14, 8, 3, "terrace", show_label=False)
    z.rect(30, 17, 26, 1, "#")
    # the neck: grass and a few trees between the castle and the river
    blob(z, 8, 12, 5, 3, ",", only=".", seed=11, jitter=0.3)
    blob(z, 62, 6, 5, 3, ",", only=".", seed=12, jitter=0.3)
    scatter_props(z, "oak", 3, 9, 22, 7, 7, 13, avoid=("."))
    scatter_props(z, "oak", 55, 3, 14, 12, 5, 14, avoid=("."))

    # ---- inside the loop: the medieval town
    # High Street and Pride Hill: three cobbled rows from the Welsh Bridge to Wyle Cop
    z.rect(16, 26, 26, 3, ":")
    z.rect(16, 23, 10, 3, ".")
    z.rect(26, 23, 3, 3, "=")
    # Wyle Cop runs down the hill to the English Bridge
    z.rect(40, 26, 3, 10, ":")
    z.rect(40, 33, 17, 3, ":")
    # the Welsh Bridge (west) and Frankwell beyond it
    z.rect(4, 26, 12, 3, "=")
    # the English Bridge (east) and Abbey Foregate, the road out to the Ironbridge Gorge
    z.rect(57, 33, 15, 3, "=")
    # north side of High Street
    z.building(17, 21, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(20, 24, "shrewsbury_sanctuary", 5, 6, "up")
    z.building(29, 22, 5, 3, "shop", "Corner Shop", door=2)
    z.warp(31, 24, "shrewsbury_shop", 4, 5, "up")
    z.building(34, 21, 7, 4, "stone", "Shrewsbury Library", door=3)
    door_in(z, 37, 24, "shrewsbury_library")
    z.prop("statue", 34, 25, variant=1)
    plaque(z, 33, 25, "darwin_statue", "Darwin's Statue",
           "Charles Darwin was born in Shrewsbury on 12 February 1809 and went to school in this very building, which was Shrewsbury School then and is the town library now. He was a poor pupil by his own account and spent his free time collecting beetles. His statue has sat here since 1897.")
    z.rect(23, 21, 3, 2, "f")
    # south side of High Street: the market, the cake shop, the pub
    z.building(17, 29, 8, 3, "red_brick", "Market Hall", door=4)
    door_in(z, 21, 31, "shrewsbury_market")
    z.building(26, 29, 5, 3, "magpie", "Shrewsbury Cakes", door=2)
    door_in(z, 28, 31, "shrewsbury_bakery", 11, 9)
    z.building(32, 29, 5, 3, "red_brick", show_label=False)
    z.building(37, 29, 3, 3, "magpie", show_label=False)
    z.rect(16, 32, 24, 1, ":")
    # Fish Street, Butcher Row and the shuts: black-and-white houses
    z.building(17, 33, 5, 3, "white_render", show_label=False)
    z.building(22, 33, 7, 3, "magpie", "Shrewsbury Museum", door=3)
    door_in(z, 25, 35, "shrewsbury_museum")
    z.building(29, 33, 5, 3, "magpie", "Bear Steps Hall", door=2)
    z.warp(31, 35, "shrewsbury_bearsteps", 5, 6, "up")
    z.building(34, 33, 6, 3, "magpie", show_label=False)
    z.rect(16, 36, 24, 1, ":")
    z.rect(16, 32, 1, 5, ":")
    plaque(z, 36, 32, "magpie", "Black and White Town",
           "Shrewsbury has more than six hundred listed buildings, and many are timber-framed in the Shropshire black-and-white style, nicknamed magpie work: oak beams tarred black, panels whitewashed. The upper floors jut out over the street because building space upstairs was taxed less than the ground.")
    plaque(z, 39, 36, "shuts", "The Shuts",
           "The narrow alleys between Shrewsbury's streets are called shuts, because they could be shut off at night with a gate. Grope Lane, Gullet Passage and Peacock Passage are still there. Grope Lane's name is exactly as rude as it sounds, and it is centuries old.")
    plaque(z, 43, 31, "wyle_cop", "Wyle Cop",
           "The steep street down to the English Bridge. Henry Tudor is said to have stayed in a house on Wyle Cop in 1485, on his way to win the crown at Bosworth. The house is still there, with its timbers leaning companionably on the neighbours.")
    # St Chad's and the Quarry
    z.building(32, 38, 7, 4, "chapel", "St Chad's Church")
    z.rect(16, 42, 40, 1, "#")
    z.rect(30, 37, 1, 6, "#")
    blob(z, 23, 45, 5, 3, "f", only=".", seed=21, jitter=0.2)
    z.rect(21, 44, 5, 1, "#")
    blob(z, 46, 46, 8, 2, ",", only=".", seed=22, jitter=0.3)
    blob(z, 46, 39, 6, 2, ",", only=".", seed=23, jitter=0.3)
    for (x, y) in [(17, 39), (19, 47), (28, 47), (36, 47), (41, 44), (53, 44), (54, 39), (17, 44)]:
        z.prop("oak", x, y, variant=(x + y) % 3)
    for (x, y) in [(18, 41), (26, 41), (36, 41), (48, 43)]:
        z.prop("bench", x, y)
    z.prop("bunting", 20, 42, variant=2, walk=True)
    z.prop("bunting", 28, 42, variant=4, walk=True)
    z.prop("lamp_post", 31, 41)
    plaque(z, 22, 43, "quarry", "The Quarry and the Dingle",
           "Twenty-nine acres of park inside the river loop, laid out in 1719 where stone was once dug. The old quarry pit became the Dingle, a sunken flower garden that Percy Thrower, the television gardener, looked after as the town's parks superintendent from 1946 to 1974.")
    plaque(z, 33, 43, "flower_show", "Shrewsbury Flower Show",
           "Held in the Quarry every August since 1875, which makes it one of the longest-running flower shows in the world. Marquees of prize dahlias, giant leeks, fireworks over the river, and a great deal of serious talk about compost.")
    plaque(z, 39, 37, "st_chads", "St Chad's Church",
           "A round church, finished in 1792 after the old St Chad's fell down. Charles Darwin was baptised here, and the graveyard holds a stone for Ebenezer Scrooge, left over from filming A Christmas Carol in the town in 1984.")
    # Kingsland Bridge, out to the south and the hills
    z.rect(23, 43, 3, 7, "#")
    z.rect(23, 49, 3, 11, "=")
    plaque(z, 26, 48, "kingsland", "Kingsland Bridge",
           "An iron bridge of 1883, built by a private company and still a toll bridge, one of the very few left in Britain. Walkers cross free. The keeper will happily tell you it is cheaper than the Severn Bridge.")
    z.building(30, 54, 10, 3, "stone", "Shrewsbury School")
    plaque(z, 41, 56, "school", "Shrewsbury School",
           "The school Darwin went to, founded in 1552, moved up here to Kingsland in 1882, leaving its old building to the town library. Its rowers are out on the Severn below most mornings, being shouted at through a megaphone.")
    blob(z, 12, 56, 7, 2, ",", only=".", seed=31, jitter=0.3)
    blob(z, 52, 56, 9, 2, ",", only=".", seed=32, jitter=0.3)
    scatter_props(z, "oak", 3, 54, 66, 4, 6, 33, avoid=("."))
    # Frankwell, over the Welsh Bridge
    z.building(3, 22, 8, 3, "glass_tower", "Theatre Severn")
    z.rect(3, 25, 9, 1, ":")
    z.building(3, 31, 7, 3, "red_brick", "The Mount")
    z.rect(3, 34, 9, 1, "#")
    z.rect(10, 29, 1, 6, "#")
    plaque(z, 8, 34, "the_mount", "The Mount",
           "Charles Darwin was born in this house on 12 February 1809, the son of a doctor. He sailed on HMS Beagle from 1831 to 1836, and in 1859 published On the Origin of Species, the book that explained evolution by natural selection. It is still a private house, so wave nicely.")
    z.building(3, 38, 7, 3, "magpie", "The Coracle", door=3)
    door_in(z, 6, 40, "shrewsbury_coracle", 11, 9)
    z.rect(3, 41, 9, 1, ":")
    z.rect(10, 35, 1, 7, "#")
    plaque(z, 2, 36, "frankwell", "Frankwell",
           "The suburb across the Welsh Bridge was once outside the town walls, and a free market for Welsh traders who wanted to avoid the town's tolls. The Welsh Bridge itself dates from 1795.")
    blob(z, 6, 46, 4, 2, ",", only=".", seed=34, jitter=0.3)
    # Abbey Foregate, over the English Bridge
    z.building(60, 24, 9, 5, "cathedral", "Shrewsbury Abbey", door=4)
    door_in(z, 64, 28, "shrewsbury_abbey")
    z.rect(64, 29, 1, 4, ":")
    z.rect(60, 37, 9, 4, "f")
    z.rect(64, 36, 1, 5, "#")
    plaque(z, 63, 29, "abbey", "Shrewsbury Abbey",
           "Founded in 1083 by Roger de Montgomery as a Benedictine monastery. In 1138 the monks brought the bones of St Winefride here from Wales, a story the writer Ellis Peters turned into the first of her Brother Cadfael mysteries. Cadfael is made up; the abbey and its herb garden are not.")
    plaque(z, 66, 36, "owen", "Wilfred Owen",
           "The poet Wilfred Owen grew up in Shrewsbury. He was killed in France a week before the end of the First World War, and his mother got the telegram here on 11 November 1918, as the town's bells rang for the Armistice. A sculpture by the abbey remembers him.")
    plaque(z, 55, 32, "english_bridge", "The English Bridge",
           "The bridge to England, as the Welsh Bridge is the bridge to Wales. Built in 1774, it was taken down and rebuilt wider and flatter in the 1920s, using the same stones. The river below is the Severn, Britain's longest.")
    blob(z, 65, 46, 4, 3, ",", only=".", seed=35, jitter=0.3)
    # street furniture
    for (x, y) in [(16, 25), (25, 28), (39, 25), (44, 32), (56, 36), (60, 32), (13, 25), (5, 29)]:
        z.prop("lamp_post", x, y)
    for (x, y) in [(23, 28), (35, 28)]:
        z.prop("hanging_basket", x, y, walk=True, rot=0)
    z.prop("bunting", 17, 26, variant=1, walk=True)
    z.prop("bunting", 41, 33, variant=3, walk=True)
    z.prop("planter", 33, 26)
    # fingerposts
    z.sign(25, 3, "NORTH: Chester, by the old road. SOUTH: Shrewsbury town centre, the Severn and the castle.")
    z.sign(56, 32, "EAST: Abbey Foregate, then the Wrekin, Coalbrookdale and the Iron Bridge.")
    z.sign(22, 49, "SOUTH over Kingsland Bridge (toll for carriages): Church Stretton, the Long Mynd and the Stiperstones.")

    # ---- people
    chat(z, "shr_shrows", "villager_2", 24, 27, "Shrowsbury Man",
         ["It's SHROWS-bury. Rhymes with 'throws'. My family has said it that way since the Tudors and we are not about to stop for anybody's satnav.",
          "That fella over there says SHROOS-bury. Rhymes with 'shoes'. He's from Wellington, which is basically Telford."], "right")
    chat(z, "shr_shrews", "villager_5", 26, 27, "Shroosbury Woman",
         ["SHROOS-bury. Like the animal, a shrew. Spelt like it, said like it. Simple.",
          "He'll tell you the posh school says Shrows. They do. That's half the problem."], "left")
    chat(z, "shr_coracle", "currach_rower", 11, 37, "Coracle Maker",
         ["A coracle is a round little boat of willow and hide, or calico and tar these days, light enough to carry on your back. Folk fished the Severn from them for centuries.",
          "When Shrewsbury Town played down at the Gay Meadow by the river, a coracle man used to paddle out and fetch the footballs that sailed over the stand. Best job in football."], "right")
    chat(z, "shr_gardener", "farmer", 24, 46, "Head Gardener",
         ["The Dingle was a quarry pit once. Now it's the prettiest hole in England. Mind the dahlias; they've been entered for August.",
          "If you're after beetles, turn over a log by the river. Gently, and put it back. Young Darwin would have had his pockets full."], "up")
    chat(z, "shr_cadfael", "poet", 62, 31, "Cadfael Fan",
         ["Brother Cadfael was a Welsh monk who had been a crusader and a sailor before he settled down to grow herbs at Shrewsbury Abbey and solve murders. Twenty books of them.",
          "The books are set in the 1130s and 40s, during the war between Stephen and Matilda. Ellis Peters was the pen name of Edith Pargeter, a Shropshire writer."], "down")
    chat(z, "shr_cakes", "villager_6", 30, 32, "Cake Fancier",
         ["Shrewsbury cakes are not cakes. They are crisp, buttery biscuits with a hint of lemon and a scalloped edge, and they've been made here since at least the 1500s.",
          "In the old days they were a famous present to send off by coach. They arrived in crumbs, and everybody said that was the authentic way."], "down")
    chat(z, "shr_drover", "villager_1", 8, 27, "Frankwell Local",
         ["Welsh drovers came over this bridge with their cattle and their wool for hundreds of years. The town got rich on Welsh wool, cloth and the trade along the Severn.",
          "In Welsh the town is Amwythig. Write that down. There'll be a test."], "left")
    chat(z, "shr_rower", "student", 48, 55, "Rowing Coach",
         ["EASY OAR! Sorry. Habit. The school's rowers train on this stretch of the Severn. The river loops so tightly round the town you can row for miles and never get anywhere.",
          "Rowing on a river with a current is all about the timing. Rather like getting a word in at a Shrewsbury dinner party."], "left")
    # trainers
    trainer(z, "shr_cox", "Cox Hattie", "Rower", "student",
            [("elverlet", 21), ("dipling", 22), ("stalklet", 22)], 44, 55, "right",
            ["Stroke, stroke, stroke! I'm the cox, which means I sit at the back and shout. It's the best seat in the boat and the lightest."],
            "Easy oar. You out-rowed us.", "We'll get you next time. We've a new eight on order and a new megaphone.", 680)
    trainer(z, "shr_monk", "Novice Wilfrid", "Herbalist", "villager_3",
            [("sphagnet", 21), ("pixling", 21), ("squibbet", 22)], 61, 41, "up",
            ["Brother Cadfael would have dosed me with comfrey and sent me to bed. I'm told a battle is better for the humours."],
            "Pax. Have some sage for your trouble. It's good for sore heads.", "Rue for regret, rosemary for remembrance, and a battle for a dull afternoon.", 650)
    trainer(z, "shr_showgrower", "Grower Marjorie", "Show Grower", "farmer",
            [("pepperling", 21), ("gentlet", 21), ("puffkin", 22), ("dozelet", 22)], 18, 45, "right",
            ["Twenty years I've grown dahlias for the Flower Show. Second every year. Second! I'll have a first off somebody today."],
            "Highly commended. Again.", "The judge was a man from Ludlow. Says it all, really.", 700)
    trainer(z, "shr_trader", "Stallholder Gaz", "Market Trader", "villager_4",
            [("binfox", 21), ("cooplet", 22), ("grizzlet", 22)], 18, 27, "down",
            ["Three for a pound! Not the creatures. The creatures fight. Ready?"],
            "Fair do's. Have a fiver off your next pound of carrots.", "Market Hall's open six days a week. Like me. Like my bad back.", 660)
    trainer(z, "shr_actor", "Actor Perpetua", "Thespian", "festival_goer",
            [("glowmite", 21), ("pixling", 22), ("legionette", 22)], 7, 25, "down",
            ["To fight, or not to fight? We've done the Scottish play, the Christmas panto and three farces. Today, a matinee."],
            "Curtain! A triumph, darling. For you.", "Theatre Severn sits on the river, so the interval drinks come with a view and a duck.", 650)
    scale_trainers(["shr_cox", "shr_monk", "shr_showgrower", "shr_trader", "shr_actor"])
    # quests: the Shrows/Shrews pair also run the pronunciation quest (see dialogue below)
    # wild creatures: the Quarry, the riverside and the neck
    wild(z, [("squibbet", 21, 23, 18, {}), ("starlet", 21, 23, 14, {"time": ["dawn", "day", "dusk"]}),
             ("cooplet", 21, 23, 12, {}), ("binfox", 21, 23, 10, {"time": ["dusk", "night"]}),
             ("pepperling", 21, 22, 10, {}), ("hootlet", 21, 23, 8, {"time": ["night"]}),
             ("brockling", 21, 23, 10, {"time": ["dawn", "dusk", "night"]}), ("pixling", 21, 22, 8, {"weather": ["fog", "drizzle"]})])
    wild(z, [("elverlet", 21, 23, 22, {}), ("rillotter", 21, 23, 14, {"time": ["dawn", "dusk", "night"]}),
             ("dipling", 21, 23, 16, {}), ("stalklet", 21, 23, 14, {}), ("volet", 21, 22, 12, {})], "water")
    z.d["edges"] = {"north": {"to": "chester", "offset": 0}, "east": {"to": "ironbridge_gorge", "offset": 0},
                    "south": {"to": "shropshire_hills", "offset": 0}}
    z.d["spawn"] = [27, 27]
    z.d["props"] = [p for p in z.d["props"] if p]
    done(z)
    z.save(OUT + "/" + zid + ".json")

    # ---- interiors
    sanctuary(OUT, zid, "Shrewsbury", (20, 25))
    shop(OUT, zid, "Shrewsbury", (31, 25))
    nurse(zid, ["Hello, duck! Welcome to Shrewsbury Sanctuary, or Shrowsbury, I'm not getting into that. Pop your team on the counter.",
                "Sit yourself down. There's tea, and a Shrewsbury cake, which is a biscuit, which I'm also not getting into.",
                "There we are. Right as rain, and the rain round here is mostly off the Welsh hills.",
                "The Ark's in the corner, duck. It came from Ludlow and it's never let us forget it.",
                "No bother. Mind the Severn, it comes up quick in the winter and so do the swans."])
    shopkeeper(zid, "Ow bist? That's Shropshire for hello. Tea, snares, and fresh Shrewsbury cakes from round the corner. What'll it be?",
               "Ta-ra then. Mind the shuts after dark, the cobbles are older than the Tudors.")
    landmark(OUT, "shrewsbury_library", "Shrewsbury Library", zid, (37, 25), "library",
             [dict(id="shr_librarian", sprite="poet", x=4, y=3, facing="down", move="still", script="shr_librarian", name="Librarian")])
    landmark(OUT, "shrewsbury_market", "Shrewsbury Market Hall", zid, (21, 32), "hall",
             [dict(id="shr_marketeer", sprite="shopkeeper", x=4, y=2, facing="down", move="still", script="shr_marketeer", name="Cheese Stall"),
              dict(id="shr_marketgran", sprite="villager_3", x=9, y=4, facing="left", move="still", script="shr_marketgran", name="Regular")])
    landmark(OUT, "shrewsbury_bakery", "Shrewsbury Cake Shop", zid, (28, 32), "cafe",
             [dict(id="shr_baker", sprite="shopkeeper", x=3, y=1, facing="down", move="still", script="shr_baker", name="Baker")], w=11, h=9)
    landmark(OUT, "shrewsbury_museum", "Shrewsbury Museum", zid, (25, 36), "museum",
             [dict(id="shr_curator", sprite="tour_guide", x=9, y=4, facing="left", move="still", script="shr_curator", name="Curator")])
    landmark(OUT, "shrewsbury_flaxmill", "Ditherington Flax Mill", zid, (11, 7), "mill",
             [dict(id="shr_engineer", sprite="steelworker", x=4, y=4, facing="right", move="still", script="shr_engineer", name="Mill Engineer")], w=15, h=10)
    landmark(OUT, "shrewsbury_castle", "Soldiers of Shropshire Museum", zid, (37, 8), "castle",
             [dict(id="shr_warder", sprite="ravenmaster", x=9, y=3, facing="left", move="still", script="shr_warder", name="Museum Warder")])
    landmark(OUT, "shrewsbury_abbey", "Shrewsbury Abbey", zid, (64, 29), "church",
             [dict(id="shr_verger", sprite="villager_3", x=6, y=2, facing="down", move="still", script="shr_verger", name="Verger")])
    landmark(OUT, "shrewsbury_coracle", "The Coracle", zid, (6, 41), "cafe",
             [dict(id="shr_quizmaster", sprite="fiddler", x=7, y=4, facing="left", move="still", script="shr_quizmaster", name="Quizmaster"),
              dict(id="shr_landlord", sprite="shopkeeper", x=3, y=1, facing="down", move="still", script="shr_landlord", name="Landlord")], w=11, h=9)
    # Bear Steps Hall: a small timbered hall up the steps (11 x 9 room, arrive at (5, 6))
    landmark(OUT, "shrewsbury_bearsteps", "Bear Steps Hall", zid, (31, 36), "hall",
             [dict(id="shr_bearsteps", sprite="tour_guide", x=3, y=3, facing="right", move="still", script="shr_bearsteps", name="Guide")], w=11, h=9)


# ------------------------------------------------------------------------------------------- Ironbridge Gorge
def ironbridge():
    W, H = 72, 60
    zid = "ironbridge_gorge"
    z = Z(zid, "Ironbridge Gorge", W, H, kind="route", region=REG, music="route_forest",
          weather={"drizzle": 30, "clear": 26, "sunshine": 18, "fog": 16, "gale": 4, "downpour": 6})
    z.d["stage"] = "forest"; z.d["scaled_floor"] = FLOOR
    z.legend["b"] = {"tile": "road", "bridge": True, "colour": "#5a4a44"}
    z.rect(0, 0, W, H, ".")
    z.border("T", 2, gaps=[(0, 33, 2, 3)])
    z.scatter(0, 0, W, H, "P", 12, 41, only="T")
    # the Severn, down the middle of the gorge
    z.rect(40, 0, 5, H, "~")
    fringe(z)
    # the gorge sides rise near the bridge: the banks stand three levels over the river, the deck level with them
    cols = {35: 1, 36: 2, 37: 3, 38: 3, 39: 3, 45: 3, 46: 3, 47: 3, 48: 2, 49: 1}
    rows = {17: 1, 18: 2, 36: 2, 37: 1}
    for y in range(17, 38):
        for x, hx in cols.items():
            z.hg[y][x] = min(hx, rows.get(y, 3))
    for y in range(17, 38):
        for x in (40, 44):
            if z.g[y][x] == "w":
                z.g[y][x] = "~"
    # the Iron Bridge: a deck over the river (the arch is the iron_bridge prop below it)
    z.rect(30, 26, 10, 2, "=")
    z.rect(40, 26, 5, 2, "b")
    z.rect(45, 26, 16, 2, "=")
    for y in (26, 27):
        for x in range(40, 45):
            z.hg[y][x] = 3
    z.prop("iron_bridge", 42, 26, walk=True)
    plaque(z, 38, 25, "iron_bridge", "The Iron Bridge",
           "The first major bridge in the world made of cast iron, cast by Abraham Darby III at Coalbrookdale and opened in 1781. Nobody had built in iron before, so its 378 tonnes of parts were joined like a timber frame, with dovetails and wedges. It gave the town, and a whole revolution, its name.")
    plaque(z, 46, 28, "gorge", "Ironbridge Gorge",
           "Geologists think the gorge was cut at the end of the last Ice Age, when meltwater burst out of a lake dammed by ice and carved a new course for the Severn. Coal, iron ore, limestone and clay all lay close together here, and in the 1700s the gorge became the busiest industrial valley on Earth. It was made a World Heritage Site in 1986.")
    # the road in from Shrewsbury
    z.rect(0, 33, 31, 3, "=")
    z.rect(30, 26, 2, 10, "=")
    # Coalbrookdale, up the dale to the north
    z.rect(30, 8, 2, 18, "#")
    z.rect(20, 10, 12, 1, "#")
    z.building(22, 5, 7, 5, "blast_furnace", "Darby's Old Furnace", door=3)
    door_in(z, 25, 9, "coalbrookdale_furnace")
    z.building(32, 4, 6, 4, "red_brick", "Museum of Iron")
    z.rect(32, 8, 6, 1, "#")
    plaque(z, 21, 10, "old_furnace", "Darby's Old Furnace",
           "In 1709 Abraham Darby I smelted iron here using coke, baked from coal, instead of charcoal from trees. Charcoal was running out with the forests; coal was not. Cheap iron poured out of Coalbrookdale for pots, rails, steam engines and, in time, the Iron Bridge. The furnace is still here, under a glass roof.")
    plaque(z, 38, 8, "pig_iron", "Pig Iron",
           "Molten iron from the furnace ran into a channel in the sand floor, with lots of little moulds branching off it. Ironworkers thought it looked like a row of piglets feeding from a sow, so the bars were called pigs, and the metal pig iron.")
    blob(z, 35, 13, 3, 2, ",", only=".", seed=51, jitter=0.3)
    scatter_props(z, "oak", 17, 2, 22, 22, 9, 52, avoid=("."))
    # the wooded gorge sides
    scatter_props(z, "oak", 33, 18, 7, 7, 12, 63, avoid=("."))
    scatter_props(z, "oak", 33, 29, 7, 7, 10, 64, avoid=("."))
    scatter_props(z, "oak", 45, 29, 6, 7, 10, 65, avoid=("."))
    scatter_props(z, "oak", 45, 17, 5, 7, 8, 66, avoid=("."))
    # the Wrekin, a lone hill to the north-west
    hills(z, [(9, 11, 5, 10)])
    z.rect(9, 12, 1, 21, "#")
    blob(z, 4, 18, 3, 3, ",", only=".", seed=53, jitter=0.3)
    blob(z, 14, 6, 3, 2, ",", only=".", seed=54, jitter=0.3)
    for (x, y) in [(7, 9), (11, 9), (6, 12), (12, 12), (7, 14), (11, 14)]:
        z.prop("standing_stone", x, y, variant=(x + y) % 3)
    plaque(z, 10, 11, "wrekin", "The Wrekin",
           "A lone hill, 407 metres high, that every Salopian can see from home. Iron Age people built a hill fort on top. To go 'all round the Wrekin' is to take the long way round, and the old Shropshire toast is 'to all friends round the Wrekin'. The red light on top is a television mast.")
    scatter_props(z, "pine", 2, 2, 16, 20, 10, 55, avoid=("."))
    # Much Wenlock and the Linden Field, to the south-west
    z.rect(13, 36, 2, 6, "#")
    z.rect(3, 41, 30, 1, ":")
    z.building(4, 37, 8, 4, "cathedral", "Wenlock Priory")
    z.building(16, 38, 7, 3, "stone", "Much Wenlock Museum", door=3)
    door_in(z, 19, 40, "wenlock_museum")
    z.building(24, 38, 6, 3, "magpie", "Much Wenlock Guildhall")
    plaque(z, 31, 40, "guildhall", "Much Wenlock Guildhall",
           "A timber-framed guildhall of 1540, built over an open market space where the stocks and the whipping post once stood. The town council still meets upstairs, without the whipping post.")
    plaque(z, 3, 42, "priory", "Wenlock Priory",
           "St Milburga ran an abbey here in the 600s, and Cluniac monks rebuilt it as a great priory after the Normans came. Henry VIII closed it in 1540; the ruins, and some magnificent topiary, are what is left.")
    z.rect(5, 45, 17, 11, ".")
    z.rect(4, 44, 19, 1, "F"); z.rect(4, 56, 19, 1, "F"); z.rect(4, 44, 1, 13, "F"); z.rect(22, 44, 1, 13, "F")
    z.rect(13, 42, 2, 3, "#")
    for (x, y) in [(6, 46), (20, 46), (6, 54), (20, 54)]:
        z.prop("flagpole", x, y, variant=0)
    z.prop("bunting", 9, 46, variant=1, walk=True); z.prop("bunting", 17, 46, variant=4, walk=True)
    z.rect(8, 50, 11, 1, "#")
    plaque(z, 16, 43, "olympian", "The Wenlock Olympian Games",
           "In 1850 a Much Wenlock doctor, William Penny Brookes, started the Wenlock Olympian Games, with running, jumping, cricket, quoits and tilting at the ring on horseback. Pierre de Coubertin came to see them in 1890, and six years later he started the modern Olympic Games in Athens. The Wenlock Games still run every July.")
    # Wenlock Edge: a long wooded limestone scarp
    for y in range(44, 58):
        for x in range(29, 38):
            z.hg[y][x] = 2
        z.hg[y][28] = 1
    z.rect(28, 44, 1, 14, "^")
    z.rect(25, 42, 2, 8, "#")
    z.rect(25, 50, 8, 2, "#")
    blob(z, 33, 47, 3, 2, ",", only=".", seed=56, jitter=0.3)
    blob(z, 33, 54, 3, 2, ",", only=".", seed=57, jitter=0.3)
    scatter_props(z, "oak", 29, 44, 10, 14, 10, 58, avoid=("."))
    plaque(z, 34, 50, "wenlock_edge", "Wenlock Edge",
           "A limestone scarp running for about thirty kilometres, made of the reefs of a warm tropical sea some 425 million years ago; look closely and the stone is full of corals and shells. A. E. Housman wrote 'On Wenlock Edge the wood's in trouble' in A Shropshire Lad, and the wood still is, on windy days.")
    # Ironbridge town on the far bank: the tollhouse and the hill of houses
    z.building(51, 22, 4, 3, "red_brick", "The Tollhouse", door=2)
    door_in(z, 53, 24, "ironbridge_tollhouse", 11, 9)
    z.building(56, 21, 8, 4, "terrace", show_label=False)
    z.building(56, 15, 8, 3, "terrace", show_label=False)
    z.rect(53, 25, 1, 1, "#")
    z.rect(55, 18, 10, 1, "#")
    z.rect(64, 18, 1, 8, "#")
    z.rect(60, 28, 2, 9, "#")
    z.prop("lamp_post", 50, 25); z.prop("lamp_post", 57, 25)
    # Blists Hill: a Victorian town, gas lamps and all
    z.rect(48, 37, 21, 1, ":")
    z.building(49, 38, 6, 4, "red_brick", "Blists Hill Bank", door=3)
    door_in(z, 52, 41, "blists_hill_bank")
    z.building(56, 38, 5, 4, "terrace", "Sweet Shop")
    z.building(62, 38, 6, 4, "mill", "Blists Hill Foundry")
    z.rect(48, 42, 21, 2, ":")
    z.building(50, 44, 6, 3, "red_brick", "The New Inn")
    z.building(58, 44, 5, 3, "slate_cottage", "Squatter's Cottage")
    for x in (48, 55, 61, 68):
        z.prop("lamp_post", x, 43)
    plaque(z, 64, 43, "blists_hill", "Blists Hill Victorian Town",
           "An open-air museum built round real blast furnaces, a brickworks and a canal, with a whole Victorian town of shops, a bank, a pub and a foundry, staffed by people in Victorian dress. You can change your money into pounds, shillings and pence at the bank and spend it in the sweet shop.")
    blob(z, 58, 51, 6, 3, ",", only=".", seed=59, jitter=0.3)
    blob(z, 56, 9, 6, 3, ",", only=".", seed=60, jitter=0.3)
    # the Tar Tunnel by the river
    z.rect(46, 47, 2, 3, "R")
    z.rect(48, 44, 1, 6, "#")
    plaque(z, 48, 50, "tar_tunnel", "The Tar Tunnel",
           "In 1786 miners digging a canal tunnel at Coalport struck a spring of natural bitumen, black tar oozing out of the rock. They sold it as medicine and for caulking boats. It still seeps from the brick walls today.")
    plaque(z, 66, 56, "coalport", "Coalport China",
           "Downriver at Coalport, from the 1790s, the works made fine porcelain painted with flowers and birds, fired in bottle kilns by the canal. Coalport china was on the tables of kings, and the old works is now a museum.")
    scatter_props(z, "oak", 46, 2, 24, 12, 8, 61, avoid=("."))
    scatter_props(z, "oak", 46, 47, 22, 10, 7, 62, avoid=("."))
    z.sign(3, 32, "WEST: Shrewsbury. NORTH: Coalbrookdale, the Wrekin. EAST over the Iron Bridge: Ironbridge, Blists Hill. SOUTH: Much Wenlock.")
    # ---- people
    chat(z, "ib_toaster", "hillwalker", 10, 14, "Wrekin Walker",
         ["To all friends round the Wrekin! That's the old Shropshire toast. Raise your flask.",
          "They say a Welsh giant meant to dam the Severn and drown Shrewsbury with a spadeful of earth. He met a cobbler carrying a sack of worn-out shoes, who said he'd walked so far from Shrewsbury he'd worn them all through. The giant gave up and dropped his earth here. That's the Wrekin."], "down", "wander")
    chat(z, "ib_guide", "tour_guide", 33, 10, "Museum Guide",
         ["Three Abraham Darbys, grandfather, son and grandson, and every one of them a Quaker ironmaster. Darby the first worked out coke smelting; Darby the third cast the bridge.",
          "Coalbrookdale also cast the first iron rails and some of the first iron steam engine cylinders. If it was heavy and hot, it probably started here."], "down")
    chat(z, "ib_lamplighter", "lamplighter", 57, 42, "Lamplighter",
         ["Evening! It's gas, you see. I go round with my pole and light every lamp in Blists Hill. Electric light is a fad, mark my words.",
          "A penny for the sweet shop goes a long way in eighteen-ninety-something. Get a quarter of humbugs and a sherbet dab."], "down")
    chat(z, "ib_tarman", "tin_miner", 49, 47, "Tar Tunnel Guide",
         ["Put the hard hat on. Down there the walls weep tar, real natural bitumen, and they've been weeping since 1786.",
          "They bottled it as British Oil and sold it for rheumatism. Did it work? Well, it smelt as if it should."], "left")
    chat(z, "ib_housman", "poet", 31, 52, "Poet on the Edge",
         ["On Wenlock Edge the wood's in trouble; his forest fleece the Wrekin heaves. A. E. Housman. He wasn't from Shropshire, you know. He just loved it from a distance, like a lot of us.",
          "Pick up any stone up here and look closely. Corals, shells, sea lilies. This hill was a tropical reef, 425 million years ago. I find it a great comfort on a wet Tuesday."], "down", "wander")
    chat(z, "ib_kayaker", "currach_rower", 46, 31, "Coracle Paddler",
         ["Ironbridge was famous for its coracles. The last of the old coracle makers here kept going into his nineties. Every family on the river had one hanging on the wall.",
          "Watch the Severn in a spate. It comes up the gorge brown and fast and has been known to visit the pubs."], "left")
    chat(z, "ib_secretary", "villager_5", 13, 47, "Games Secretary", ["placeholder"], "down")
    # trainers
    trainer(z, "ib_apprentice", "Apprentice Ned", "Furnace Hand", "steelworker",
            [("pigling", 22), ("cutlet", 22), ("rivetling", 22)], 27, 11, "down",
            ["Master says nobody touches his pattern till they've beaten me. I've been beaten twice today. Third time lucky, for me."],
            "Hot work! Go on in, the master's expecting you.", "Coke, not charcoal. That's the whole secret, and now you know it too.", 700)
    trainer(z, "ib_bobby", "Constable Pargeter", "Victorian Bobby", "villager_4",
            [("rooklet", 22), ("grizzlet", 22), ("bobbin", 22)], 53, 36, "down",
            ["'Allo, 'allo! Loitering in Blists Hill without a Victorian hat? That's a summons. Or a battle. Your choice. It's a battle."],
            "Very good. Mind how you go, and mind the horse.", "I'm on the beat till six, when I go home and change into a modern person.", 690)
    trainer(z, "ib_walker", "Rambler Doreen", "Rambler", "hiker",
            [("starlet", 21), ("foalmoor", 22), ("swiftlet", 22)], 9, 24, "down",
            ["I've walked all round the Wrekin. Literally, all the way round. I'm going up it next week."],
            "Lovely stuff. Map's in the side pocket if you want it.", "Don't go up the Wrekin in fog. Or do; you'll have it to yourself.", 660)
    trainer(z, "ib_painter", "China Painter Edith", "Painter", "poet",
            [("glowmite", 22), ("flaxling", 22), ("zigzlet", 22)], 63, 53, "left",
            ["A Coalport rose takes forty brush strokes and a steady hand. Let's see how steady yours is."],
            "Exquisite. I'll paint you on a saucer.", "Bone china is made with bone ash. Ask me why at a dinner party. Actually don't.", 670)
    scale_trainers(["ib_apprentice", "ib_bobby", "ib_walker", "ib_painter"])
    # the Wenlock Olympian Games: a gauntlet of four (no standing NPCs; the secretary calls them out)
    games = [
        ("wen_sprinter", "Sprinter Ada", "Runner", "fell_runner", [("swiftlet", 22), ("leveret", 22), ("parakit", 23)],
         ["First event: the foot race! The early Wenlock Games had races for all sorts, and once even a race for old women with a pound of tea as the prize. I'm after the tea."],
         "Beaten by a nose. The tea's yours."),
        ("wen_quoits", "Quoits Champion Bert", "Quoits Player", "farmer", [("moldiwarp", 22), ("gentlet", 22), ("bobbin", 23)],
         ["Second event: quoits! Iron rings, thrown at a pin in a bed of clay. I've rung the pin more times than the church bell."],
         "A ringer! Well thrown."),
        ("wen_tilter", "Tilter Gwen", "Tilting Rider", "villager_6", [("foalmoor", 23), ("fawnlet", 23), ("kitelet", 23)],
         ["Third event: tilting at the ring! Gallop down the field and spear a little ring hanging from a post. The winner was crowned with laurel by a lady of the town."],
         "You took the ring clean. Consider yourself laurelled."),
        ("wen_champion", "Olympian Penny", "Wenlock Champion", "jogger",
         [("pigling", 24), ("squibbet", 24), ("rillotter", 24), ("foalmoor", 24), ("swiftlet", 24), ("brockling", 25)],
         ["Final event: the pentathlon of creatures! I'm no relation of the doctor, whatever the programme says. But I have trained like an Olympian, and eaten like one."],
         "Citius, altius, fortius! The medal's yours, and so is the laurel."),
    ]
    for (tid, name, cls, sprite, party, intro, win) in games:
        TRN[tid] = {"id": tid, "name": name, "class": cls, "sprite": sprite,
                    "party": [{"species": sp, "level": lv} for sp, lv in party], "ai": "trainer", "money": 400 + 100 * len(party),
                    "intro": say(name, *intro), "win": win, "after": win, "scaled_floor": FLOOR}
    wild(z, [("pigling", 21, 23, 16, {}), ("squibbet", 21, 23, 12, {}), ("brockling", 21, 23, 10, {"time": ["dawn", "dusk", "night"]}),
             ("rooklet", 21, 23, 12, {}), ("zigzlet", 21, 23, 8, {"weather": ["sunshine", "clear"]}), ("fawnlet", 21, 22, 8, {"time": ["dawn", "dusk"]}),
             ("starlet", 21, 23, 10, {"time": ["day"]}), ("hootlet", 21, 23, 8, {"time": ["night"]}), ("bobbin", 21, 22, 8, {})])
    wild(z, [("elverlet", 21, 23, 22, {}), ("rillotter", 21, 23, 16, {}), ("dipling", 21, 23, 14, {}), ("holtling", 21, 22, 12, {}),
             ("stalklet", 21, 23, 12, {})], "water")
    z.d["edges"] = {"west": {"to": "shrewsbury", "offset": 0}}
    z.d["spawn"] = [3, 34]
    done(z)
    z.save(OUT + "/" + zid + ".json")
    landmark(OUT, "coalbrookdale_furnace", "Darby's Old Furnace", zid, (25, 10), "workshop",
             [dict(id="ib_furnacemaster", sprite="steelworker", x=4, y=3, facing="down", move="still", script="ib_furnacemaster", name="Furnace Master")])
    landmark(OUT, "ironbridge_tollhouse", "The Tollhouse", zid, (53, 25), "cottage",
             [dict(id="ib_tollkeeper", sprite="villager_1", x=3, y=3, facing="right", move="still", script="ib_tollkeeper", name="Toll Keeper")], w=11, h=9)
    landmark(OUT, "blists_hill_bank", "Blists Hill Bank", zid, (52, 42), "hall",
             [dict(id="ib_clerk", sprite="shopkeeper", x=4, y=2, facing="down", move="still", script="ib_clerk", name="Bank Clerk")])
    landmark(OUT, "wenlock_museum", "Much Wenlock Museum", zid, (19, 41), "museum",
             [dict(id="wen_curator", sprite="tour_guide", x=9, y=4, facing="left", move="still", script="wen_curator", name="Curator")])


# ------------------------------------------------------------------------------------------ Shropshire Hills
def hills_zone():
    W, H = 64, 60
    zid = "shropshire_hills"
    z = Z(zid, "Shropshire Hills", W, H, kind="route", region=REG, music="route_moor",
          weather={"drizzle": 28, "fog": 22, "clear": 20, "sunshine": 14, "gale": 10, "downpour": 6})
    z.d["stage"] = "moor"; z.d["scaled_floor"] = FLOOR
    z.legend["h"] = {"tile": "tall_grass", "prop": "heather", "colour": "#7d6a52"}
    z.legend["k"] = {"tile": "grass", "colour": "#8a8a5a"}
    z.rect(0, 0, W, H, ".")
    z.border("T", 2, gaps=[(23, 0, 3, 2)])
    z.scatter(0, 0, W, H, "P", 12, 71, only="T")
    # the lane south from Kingsland, down into Church Stretton
    z.rect(23, 0, 3, 14, "#")
    z.rect(18, 13, 20, 2, "#")
    z.rect(24, 15, 2, 33, "#")
    # the Long Mynd: a heather plateau to the east, with the gliders overhead
    hills(z, [(47, 27, 4, 15)])
    for y in range(4, 56):
        for x in range(32, 62):
            if z.hg[y][x] >= 2 and z.g[y][x] == ".":
                z.set(x, y, "h")
    # Carding Mill Valley: a stream down from the moor, a path up beside it
    path(z, [(26, 20), (36, 20), (36, 28), (44, 28)], "#", 2)
    path(z, [(27, 23), (33, 23), (33, 31), (41, 31)], "~", 2)
    fringe(z, land=".,#h:")
    z.building(28, 16, 6, 3, "slate_cottage", "Carding Mill Tea Room", door=3)
    door_in(z, 31, 18, "hills_tearoom", 11, 9)
    z.rect(27, 19, 9, 1, "#")
    plaque(z, 35, 19, "carding_mill", "Carding Mill Valley",
           "Named after a mill that carded wool, combing the fibres straight for spinning, in the 1800s. The stream tumbles off the Long Mynd past a reservoir and a waterfall called the Lightspout. Victorians who came to take the air called Church Stretton 'Little Switzerland'.")
    # the gliding club on top
    z.building(48, 18, 8, 3, "field_barn", "Midland Gliding Club")
    z.rect(44, 21, 14, 3, "k")
    for (x, y, v) in [(52, 12, 0), (40, 15, 1), (57, 33, 0), (45, 40, 1)]:
        z.prop("glider", x, y, variant=v, walk=True)
    plaque(z, 47, 21, "long_mynd", "The Long Mynd",
           "A heather plateau about eleven kilometres long and over five hundred metres high, made of some of the oldest rocks in England. Gliders have soared off it since the 1930s, riding the wind that hits the hill and goes up. Wild hill ponies graze the tops.")
    # the Stiperstones: a jagged quartzite ridge to the west
    hills(z, [(10, 34, 5, 13)])
    blob(z, 10, 36, 6, 10, "h", only=".", seed=72, jitter=0.4)
    for (x, y) in [(7, 22), (8, 23), (12, 27), (13, 27), (9, 30), (10, 30), (11, 30), (9, 31), (11, 31), (6, 38), (7, 38),
                   (13, 41), (14, 42), (7, 46), (8, 46)]:
        z.set(x, y, "R")
    for (x, y) in [(5, 25), (6, 26), (14, 35), (15, 36), (5, 42), (11, 47), (12, 48)]:
        z.set(x, y, "/")
    path(z, [(24, 34), (16, 34), (16, 33), (10, 33)], "#", 1)
    path(z, [(10, 33), (10, 44)], "#", 1)
    plaque(z, 12, 32, "devils_chair", "The Devil's Chair",
           "The biggest of the Stiperstones tors. The Devil, they say, sat here to rest while carrying an apron full of rocks; the strings broke and the stones spilled down the hill. When the mist covers the ridge, he is in his chair. If the Stiperstones ever sink into the ground, England will fall.")
    plaque(z, 9, 44, "stiperstones", "The Stiperstones",
           "A ridge of quartzite, about 480 million years old, shattered into tors by the frost of the Ice Ages. Below it, the Snailbeach lead mines were worked from Roman times until 1955, one of the richest lead mines in Europe in its day.")
    z.building(16, 48, 6, 3, "stone", "Snailbeach Engine House")
    z.rect(15, 51, 11, 1, "#")
    z.rect(24, 47, 2, 5, "#")
    plaque(z, 22, 50, "wild_edric", "Wild Edric",
           "Edric was a real Saxon lord who held out against the Normans after 1066. Legend says he married a fairy wife, Godda, and still rides over these hills with her and his men before a war; lead miners swore they heard them knocking in the rock.")
    # the Devil's Chair spot: when the mist is down, something sits in it
    _stand(z, 10, 32)
    z.npc(id="hills_chair", sprite="creature:diaboulder", x=10, y=32, facing="down", move="still", script="hills_chair", hide_if="caught_diaboulder")
    _stand(z, 14, 38)
    z.npc(id="hills_quartz", sprite="tin_miner", x=14, y=38, facing="left", move="still", script="hills_quartz", name="Rock Hound")
    blob(z, 20, 40, 3, 3, ",", only=".", seed=73, jitter=0.3)
    blob(z, 30, 52, 5, 3, ",", only=".", seed=74, jitter=0.3)
    scatter_props(z, "oak", 16, 3, 16, 10, 8, 75, avoid=("."))
    scatter_props(z, "oak", 26, 40, 8, 16, 6, 76, avoid=("."))
    z.sign(22, 15, "WEST: the Stiperstones and the Devil's Chair. EAST: Carding Mill Valley and the Long Mynd. NORTH: Shrewsbury.")
    # people
    chat(z, "hills_pony", "farmer", 50, 30, "Pony Warden",
         ["The Long Mynd hill ponies have grazed up here for centuries. They belong to the commoners, who have the right to graze the hill, and they're tough as old boots.",
          "Don't feed them. They'll have your sandwiches, your map and your hat."], "left", "wander")
    chat(z, "hills_miner", "tin_miner", 19, 52, "Old Lead Miner",
         ["Snailbeach was one of the richest lead mines in Europe once. The Romans had lead out of these hills, and pigs of lead have been found stamped with an emperor's name to prove it.",
          "Lead is heavy, soft and poison. We put it on church roofs and in the water pipes. Now we know better, and the hill is quiet."], "left")
    trainer(z, "hills_pilot", "Glider Pilot Rupert", "Glider Pilot", "hiker",
            [("kitelet", 22), ("swiftlet", 22), ("bittling", 22), ("parakit", 23)], 52, 22, "down",
            ["No engine, just wind up the hillside. The trick is to find the lift and stay in it. Rather like an argument."],
            "Well flown. I'm off to look for a thermal.", "The ridge lift here is famous. On a good westerly you can soar the whole length of the Mynd.", 700)
    trainer(z, "hills_runner", "Fell Runner Tamsin", "Fell Runner", "fell_runner",
            [("foalmoor", 22), ("leveret", 22), ("ptarmlet", 22)], 37, 25, "left",
            ["Up the Mynd and back before the tea room shuts. Fight first, if you're quick about it."],
            "Fair enough. Downhill's my strong suit, not this.", "The Long Mynd has a whole fan of little valleys, and I've fallen in all of them.", 680)
    trainer(z, "hills_walker", "Rambler Clive", "Rambler", "hillwalker",
            [("tapknock", 22), ("slatelet", 22), ("moldiwarp", 22)], 16, 33, "right",
            ["Don't go sitting in the Devil's Chair. Last bloke who did it is still waiting for his lift home."],
            "Good on you. Watch the mist.", "If the stones ever sink, England falls. I come up most weeks to check.", 680)
    scale_trainers(["hills_pilot", "hills_runner", "hills_walker"])
    wild(z, [("foalmoor", 21, 23, 14, {}), ("squibbet", 21, 23, 12, {}), ("tapknock", 21, 23, 10, {"weather": ["fog", "drizzle"]}),
             ("slatelet", 21, 23, 10, {}), ("kitelet", 21, 23, 10, {"time": ["day"]}), ("ptarmlet", 21, 22, 8, {}),
             ("leveret", 21, 23, 10, {"time": ["dawn", "dusk"]}), ("bittling", 21, 22, 8, {"weather": ["drizzle", "downpour"]})])
    wild(z, [("dipling", 21, 23, 20, {}), ("volet", 21, 23, 16, {}), ("holtling", 21, 22, 10, {})], "water")
    z.d["edges"] = {"north": {"to": "shrewsbury", "offset": 0}}
    z.d["spawn"] = [24, 3]
    done(z)
    z.save(OUT + "/" + zid + ".json")
    landmark(OUT, "hills_tearoom", "Carding Mill Tea Room", zid, (31, 19), "cafe",
             [dict(id="hills_teaserver", sprite="shopkeeper", x=3, y=1, facing="down", move="still", script="hills_teaserver", name="Tea Room")], w=11, h=9)


if __name__ == "__main__":
    shrewsbury()
    ironbridge()
    hills_zone()
    import shropshire_story
    shropshire_story.write(DLG, TRN)
    write_all(OUT)
