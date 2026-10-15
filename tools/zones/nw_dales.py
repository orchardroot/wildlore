# plan 6 group B, part 1: yorkshire_dales (route west from York) and lancaster (town, castle and canal).
from nw_common import *


def build(OUT):
    dales(OUT)
    lancaster(OUT)


def dales(OUT):
    W, H = 72, 46
    z = Z("yorkshire_dales", "Yorkshire Dales", W, H, kind="route", region="yorkshire", music="route_moor", weather=WX_NORTH)
    z.d["stage"] = "valley"
    z.legend["l"] = {"tile": "path", "colour": "#b4b5a8"}          # limestone pavement
    z.border("T", 2, gaps=[(0, 20, 2, 3), (70, 20, 2, 3)])
    z.scatter(0, 0, W, H, "P", 22, 3, only="T")
    # the way west: one broad track, with lanes up to the Cove and down to the falls
    z.rect(2, 20, 68, 3, "#")
    z.rect(47, 12, 2, 8, "#"); z.rect(40, 23, 2, 11, "#"); z.rect(40, 39, 2, 5, "#")
    z.rect(14, 9, 2, 11, "#")
    # drystone walls, with gaps wherever a lane or beck goes through
    wall_h(z, 17, 3, 68, gaps=[14, 15, 30, 31, 32, 47, 48])
    wall_h(z, 25, 3, 68, gaps=[30, 31, 32, 40, 41])
    wall_v(z, 24, 18, 19); wall_v(z, 58, 18, 19); wall_v(z, 36, 26, 33); wall_v(z, 60, 26, 32); wall_v(z, 10, 26, 33)
    # Malham Cove: a curved limestone amphitheatre with a pavement on top
    for x in range(20, 43):
        dy = round(4 * math.sqrt(max(0.0, 1 - ((x - 31) / 11.5) ** 2)))
        fy = 6 + dy
        for y in range(3, fy):
            z.g[y][x] = "l"; z.hg[y][x] = 4
        z.g[fy][x] = "^"; z.g[fy + 1][x] = "^"; z.hg[fy][x] = 4; z.hg[fy + 1][x] = 4
    for y in range(2, 9):
        put(z, 19, y, "^")
        z.hg[y][19] = 4
    z.rect(19, 2, 31, 1, "^")
    z.height(19, 2, 31, 1, 4)
    z.rect(43, 3, 7, 6, "l"); z.height(43, 3, 7, 6, 4)
    z.rect(43, 9, 3, 1, "^"); z.height(43, 9, 3, 1, 4)
    z.rect(50, 3, 1, 7, "^")
    # the ramp up to the top, a walled lane rising one step at a time
    for i, y in enumerate((11, 10, 9)):
        z.height(47, y, 2, 1, i + 1)
        z.height(46, y, 1, 1, i + 1); z.height(49, y, 1, 1, i + 1)
        put(z, 46, y, "W"); put(z, 49, y, "W")
    z.rect(49, 9, 1, 1, "W"); z.height(49, 8, 1, 1, 4); put(z, 49, 8, "l")
    z.height(47, 8, 2, 1, 4)
    z.rect(47, 9, 2, 3, "#")
    # Malham Beck leaves from under the cliff, runs south under the track
    z.rect(30, 12, 3, 16, "w"); z.rect(31, 12, 1, 15, "~")
    z.rect(27, 27, 9, 5, "w"); z.rect(28, 28, 7, 3, "~")
    z.rect(30, 20, 3, 3, "|")
    z.rect(30, 17, 3, 1, "w")                     # wall gap over the beck
    z.rect(30, 25, 3, 1, "w")
    # pavement on top: clints and grykes
    for (x, y) in [(24, 4), (27, 6), (33, 4), (36, 6), (39, 5), (22, 5), (30, 3), (45, 5), (41, 3)]:
        z.prop("rock", x, y, variant=(x + y) % 3)
    z.rect(24, 4, 3, 1, ","); z.rect(34, 5, 3, 1, ","); z.rect(38, 4, 2, 1, ",")
    z.sign(32, 6, "MALHAM COVE. A curved cliff 80 metres high, made of limestone laid down when this was a warm tropical sea. After the Ice Age a waterfall as tall as Niagara poured over the lip. Today the beck vanishes underground and comes out at the bottom. Please do not follow it.")
    z.sign(28, 5, "LIMESTONE PAVEMENT. The cracks are called grykes and the blocks are clints. Ferns grow down in the grykes where it is sheltered. If you can identify a clint without a guidebook, you may call yourself a geologist.")
    # Gordale Scar: a gorge with a stepped waterfall
    for y in range(3, 9):
        z.rect(5, y, 1, 1, "^"); z.rect(9, y, 1, 1, "^")
        z.hg[y][5] = 3; z.hg[y][9] = 3
    z.rect(6, 3, 3, 8, "w"); z.rect(6, 3, 3, 4, "~")
    for y in range(3, 11):
        lv = 3 if y < 5 else 2 if y < 7 else 1 if y < 9 else 0
        z.height(6, y, 3, 1, lv)
    z.rect(5, 2, 5, 1, "^")
    # limestone pavement patch west of the lane
    z.rect(3, 11, 11, 6, "l"); z.rect(10, 9, 3, 2, "l")
    for (x, y) in [(4, 12), (6, 14), (8, 12), (11, 15), (5, 15), (9, 14), (12, 12)]:
        z.prop("rock", x, y, variant=(x * y) % 3)
    z.rect(6, 12, 2, 1, ","); z.rect(9, 15, 2, 1, ","); z.rect(4, 13, 1, 2, ",")
    # fields of tall grass, flowers, field barns
    for (x, y, w, h) in [(4, 18, 8, 2), (17, 18, 6, 2), (52, 18, 10, 2), (64, 18, 4, 2), (4, 26, 5, 6), (12, 26, 10, 5), (44, 26, 10, 5),
                         (62, 26, 6, 5), (52, 6, 12, 8), (20, 14, 8, 3), (34, 14, 8, 3)]:
        if w and h:
            z.rect(x, y, w, h, ",")
    z.rect(52, 6, 12, 8, "."); z.rect(54, 7, 8, 5, ","); z.rect(53, 13, 10, 1, "f")
    z.rect(24, 42, 12, 2, "f"); z.rect(16, 29, 1, 1, "f"); z.rect(46, 19, 1, 1, "f")
    z.building(54, 14, 5, 3, "stone", "Field Barn")
    z.building(14, 28, 5, 3, "slate_cottage", "Field Barn")
    z.building(62, 28, 5, 3, "stone", "Laithe")
    z.building(5, 41, 6, 3, "stone", "Field Barn")
    z.building(48, 40, 6, 3, "slate_cottage", "Barn")
    z.building(20, 29, 6, 3, "cream_render", "Dales Creamery")
    # the river with its falls: three steps down going west
    z.rect(3, 34, 66, 5, "~")
    z.rect(3, 34, 66, 1, "w"); z.rect(3, 38, 66, 1, "w")
    for x in range(3, 69):
        lv = 3 if x >= 59 else 2 if x >= 56 else 1 if x >= 53 else 0
        z.height(x, 33, 1, 7, lv)
    z.rect(40, 34, 2, 5, "|")
    z.rect(4, 33, 65, 1, "#"); z.rect(4, 39, 65, 1, "#")
    z.rect(40, 33, 2, 7, "#"); z.rect(40, 34, 2, 5, "|")
    # trees, rocks, flowers
    scatter_props(z, "oak", 3, 3, 66, 40, 20, 41, avoid=(".",))
    scatter_props(z, "rock", 3, 3, 66, 40, 22, 42, avoid=(".", "l"))
    scatter_props(z, "bush", 3, 18, 66, 26, 16, 43, avoid=(".",))
    z.prop("bench", 44, 22); z.prop("lamp_post", 38, 19); z.prop("bollard", 39, 33)
    # signs
    z.sign(4, 21, "THE YORKSHIRE DALES. Green valleys, grey walls, and a great many sheep with opinions. Welcome west. The tea shops are about two miles apart, which is the proper distance.")
    z.sign(15, 18, "A DRYSTONE WALL. Built with no mortar, only skill and a good eye. There are about 5,000 miles of them in the Dales, and every one is held up by gravity and pride. Please close the gate.")
    z.sign(46, 31, "AYSGARTH FALLS. Three sets of falls on the River Ure, stepping down over limestone ledges. This is where the film of the outlaw of Sherwood was shot in 1990. The Dales will play any forest if asked nicely.")
    z.sign(54, 21, "WENSLEYDALE. Famous for a crumbly white cheese, which a certain inventor with a dog loves. It goes very well with fruit cake. This is not a joke. It is a Yorkshire tradition.")
    z.sign(49, 22, "FIELD BARNS. The Dales have thousands of small stone barns, one to a field. Each kept hay for a few cows through the winter. Now they keep views for the walkers, and the occasional ewe.")
    z.sign(11, 8, "GORDALE SCAR. A gorge where the cliffs close in until they nearly touch overhead, and a waterfall comes down the middle. Turner painted it. John Ruskin said it was the best of its kind. The beck did not comment.")
    # people
    chat(z, "dales_walker", "hillwalker", 20, 19, "Walker",
         ["I'm doing the Three Peaks: Pen-y-ghent, Whernside and Ingleborough, twenty-four miles in twelve hours. My knees have said they will do it, and then they will never speak to me again.",
          "Rule one of the Dales is you always say hello to a walker. Rule two is you never go past a gate without closing it. Rule three is the weather changes on the hour."], "down", "wander")
    chat(z, "dales_waller", "villager_4", 58, 19, "Wall Builder",
         ["Drystone walling. You pick up a stone, you look at it, you put it down in the right place. Then you do that eleven thousand times and you have a wall.",
          "The middle of a wall is full of small stones called hearting. It's what keeps the big ones standing. Same as most families."], "down", "still")
    chat(z, "dales_cheesewife", "villager_5", 28, 33, "Creamery Worker",
         ["Wensleydale cheese: crumbly, mild and good with fruit cake. If you're a Yorkshire person, it's a reasonable thing to say, 'Cheese and cake? Lovely.'",
          "Monks from France first made it here in the twelfth century, and we've been very polite about the recipe ever since."], "right", "still")
    chat(z, "dales_geologist", "student", 36, 7, "Geology Student",
         ["See the pavement? That's the sea floor of a tropical sea, around 330 million years ago. The fossils in it are corals and shells.",
          "Yes, the same thing that makes the cliff also makes the cheese land. It's all limestone, one way or another."], "left", "wander")
    chat(z, "dales_postie", "jogger", 44, 21, "Postie",
         ["I deliver to farms where the nearest neighbour is a bull. It's the only time in my life I've been relieved to have a van with a lock on it.",
          "There's a farm up the lane where the post box is a stone wall with a hole in it. Nobody's lost a letter yet."], "right", "wander")
    # trainers
    trainer(z, "dales_fellrunner", "Fell Runner Ingrid", "Fell Runner", "jogger", [("kitelet", 84), ("kidgruff", 84), ("moldiwarp", 85)],
            22, 19, "down", ["Race you to the top! Not you, personally. I'm racing the gradient. It's very rude."],
            "Fair enough. You've the lungs. I've the vest.", "Fell running is mostly down. The up bit's just a very long wait.", 3300)
    trainer(z, "dales_climber", "Climber Sven", "Climber", "hillwalker", [("slatelet", 85), ("eaglet", 84), ("brockling", 85)],
            45, 14, "right", ["Malham Cove is a famous climbing crag. The route is called Raindrops Keep Falling. It's very good. It's very high. I'm very nervous."],
            "Just let me find my footing. And my dignity.", "The cove has routes called Lichen Spin and Rainbow Warrior. I know, I know.", 3400)
    trainer(z, "dales_angler", "Angler Maureen", "Angler", "angler", [("stalklet", 85), ("volet", 84), ("rillotter", 85)],
            39, 30, "right", ["Grayling on the Ure, trout in the becks. I've been fishing here since before the road was tarmac. The fish and I have an arrangement."],
            "I've been out-fished. And in a field, no less.", "Always check the river before you cross it. Then check it again. Then take the bridge.", 3350)
    trainer(z, "dales_birder", "Birdwatcher Tobias", "Birdwatcher", "birdwatcher", [("ospret", 85), ("cranelet", 84), ("starlet", 85)],
            62, 19, "down", ["Curlews on the moor, lapwings in the meadow, peregrines on the crag. I keep a list. It's a long list, but a quiet one."],
            "You've got a good eye. Better than mine, and I have binoculars.", "A curlew's call is the sound of the moors. I'd call it back, but I'd be wrong in every way.", 3300)
    z.d["edges"] = {"east": {"to": "york", "offset": 0}, "west": {"to": "lancaster", "offset": 0}}
    z.d["spawn"] = [36, 21]
    wild(z, [("moldiwarp", 84, 86, 18, {}), ("dozelet", 84, 85, 12, {}), ("brockling", 84, 86, 10, {}), ("kidgruff", 84, 86, 10, {}),
             ("slatelet", 84, 85, 8, {}), ("starlet", 84, 85, 10, {"time": ["day", "dawn"]}), ("zigzlet", 84, 86, 8, {"time": ["night", "dusk"]}),
             ("kitelet", 85, 86, 8, {"time": ["day"]}), ("sphagnet", 84, 85, 8, {"weather": ["drizzle", "downpour", "fog"]}),
             ("flittermouse", 84, 85, 6, {"time": ["night"]}), ("eaglet", 85, 86, 4, {})])
    wild(z, [("volet", 84, 86, 30, {}), ("stalklet", 84, 85, 16, {}), ("cranelet", 84, 85, 14, {}), ("rillotter", 85, 86, 10, {}),
             ("dipling", 84, 85, 12, {}), ("minkshade", 85, 86, 8, {"time": ["night", "dusk"]}), ("elverlet", 84, 85, 8, {"weather": ["drizzle", "downpour"]})], "water")
    tidy(z)
    z.save(OUT + "/yorkshire_dales.json")


def lancaster(OUT):
    W, H = 60, 46
    z = Z("lancaster", "Lancaster", W, H, kind="town", region="cumbria", music="town_city", weather=WX_NORTH)
    z.d["stage"] = "town"; z.d["town_id"] = "lancaster"
    z.border("T", 2, gaps=[(58, 20, 2, 3), (30, 0, 3, 2)])
    z.scatter(0, 0, W, H, "P", 14, 7, only="T")
    # streets
    z.rect(4, 20, 56, 3, "="); z.rect(4, 19, 54, 1, ":"); z.rect(4, 23, 54, 1, ":")
    z.rect(30, 0, 3, 20, "="); z.rect(29, 2, 1, 17, ":"); z.rect(33, 2, 1, 17, ":")
    z.rect(4, 17, 6, 8, ":")
    # the castle on its hill, with the priory below it
    hill(z, 7, 4, 18, 11, 4)
    z.building(9, 5, 14, 6, "castle", "Lancaster Castle")
    z.building(11, 11, 4, 3, "chapel", "The Priory")
    z.rect(16, 11, 2, 9, ":")
    for (x, y) in [(8, 6), (24, 6), (8, 11), (24, 11), (19, 11), (19, 14), (15, 14)]:
        z.prop("lamp_post" if (x + y) % 3 else "bench", x, y)
    scatter_props(z, "oak", 5, 15, 22, 4, 5, 71, avoid=(".",))
    z.sign(17, 12, "LANCASTER CASTLE. A fortress on a hill above the River Lune for nearly a thousand years, and a working prison until 2011. In 1612 the Pendle witches were tried here. History is not kind to them. The tour guides, however, are very kind to the visitors, and have a joke about the stairs.")
    z.sign(13, 14, "THE PRIORY. The parish church stands on Roman and Saxon ground, next door to the castle, which is the sort of arrangement you get when a town has been busy for two thousand years.")
    # the canal and its towpath
    z.rect(46, 3, 3, 25, "~"); z.rect(45, 3, 1, 26, ":"); z.rect(49, 3, 1, 26, ":")
    z.rect(45, 19, 5, 5, "="); z.rect(45, 19, 5, 1, ":"); z.rect(45, 23, 5, 1, ":")
    for (x, y) in [(47, 7), (47, 13), (47, 25)]:
        z.prop("canal_boat", x, y)
    z.prop("bollard", 45, 10); z.prop("bollard", 49, 16); z.prop("bollard", 45, 26)
    z.sign(45, 18, "THE LANCASTER CANAL. Opened in 1797, 57 miles long with no locks for most of it. Barges carried coal, limestone and cargo to Kendal. Now they carry holidaymakers and sandwiches. The towpath is flat, which is the canal's nicest feature.")
    # sanctuary and shop on the north side of the main street
    z.building(35, 15, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(38, 18, "lancaster_sanctuary", 5, 6, "up")
    z.building(51, 15, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(53, 18, "lancaster_shop", 4, 5, "up")
    z.building(41, 15, 4, 4, "red_brick", "Market Hall", show_label=True)
    z.building(34, 4, 7, 4, "stone", "Judges' Lodgings")
    z.building(35, 9, 7, 4, "terrace"); z.building(51, 5, 6, 4, "red_brick"); z.building(51, 10, 6, 4, "terrace")
    z.rect(34, 8, 8, 1, ":")
    z.prop("planter", 35, 14); z.prop("planter", 39, 14); z.prop("lamp_post", 34, 19); z.prop("lamp_post", 44, 19)
    # the south side of the street
    z.building(4, 24, 8, 4, "terrace"); z.building(13, 24, 6, 4, "red_brick", "Bakery")
    z.building(20, 24, 8, 4, "stone", "Maritime Museum")
    z.building(53, 24, 5, 4, "white_render", "Tea Rooms")
    z.prop("bench", 52, 24); z.prop("post_box", 29, 24); z.prop("phone_box", 12, 24)
    # the station
    station(z, 36, 27, 9, 4, "Lancaster Station")
    z.rect(34, 23, 2, 7, ":")
    rail_guard(z, 42, 29, ["Lancaster Station. Trains for every station you have visited in England, Wales and Scotland. Mind the gap, the step, and the lad with the clipboard."], facing="left")
    # Williamson Park-ish green on the south-west, and the Lune
    z.rect(4, 29, 28, 5, "."); z.rect(6, 30, 8, 3, ","); z.rect(20, 30, 8, 3, ","); z.rect(16, 31, 3, 2, "f")
    z.rect(2, 36, 56, 4, "~"); z.rect(2, 35, 56, 1, "w"); z.rect(2, 40, 56, 1, "w")
    z.rect(4, 41, 52, 3, "."); z.rect(8, 42, 8, 2, ","); z.rect(38, 42, 10, 2, ",")
    z.rect(30, 23, 3, 21, "="); z.rect(29, 36, 1, 4, "W"); z.rect(33, 36, 1, 4, "W")
    z.rect(12, 35, 2, 6, "|"); z.rect(11, 36, 1, 4, "F"); z.rect(14, 36, 1, 4, "F")
    scatter_props(z, "oak", 4, 29, 26, 5, 6, 72, avoid=(".",))
    scatter_props(z, "bush", 4, 29, 26, 5, 6, 73, avoid=(".",))
    z.prop("bench", 22, 29); z.prop("bench", 10, 34)
    z.prop("buoy", 20, 38); z.prop("buoy", 40, 37)
    z.prop("boat", 45, 38, variant=1)
    z.sign(31, 34, "THE LUNE. A fast, wide river that gave Lancaster its name (Lune Castle). Ships once sailed up it to the Old Port, full of sugar and rum and cotton. The quay has been quiet for a century, which makes it a good place to sit and eat chips.")
    z.sign(12, 34, "MILLENNIUM BRIDGE. Opened in 2001, a footbridge shaped like a sail. It's the best place to watch the tide come in at dusk. Take your time. Everyone in Lancaster does.")
    # people
    chat(z, "lan_student", "student", 19, 21, "Student",
         ["Lancaster University is a campus on a hill outside town, and the buses are the only thing that hold it together. It opened in 1964 and the campus is a bit concrete, but the people are lovely.",
          "The city has a legend: the Pendle witches were held in the castle. I hear a lot of people, in the town, pretending not to be descended from them."], "down", "wander")
    chat(z, "lan_boater", "fisher", 50, 21, "Narrowboat Owner",
         ["Our boat's called Wet Weekend. I've had it eleven years, and it hasn't been dry for any of them.",
          "The canal runs fifty-seven miles with no locks, which means you sit on the back all day and watch the cows. The cows watch back."], "left", "still")
    chat(z, "lan_guide", "tour_guide", 17, 16, "Castle Guide",
         ["Welcome to the castle! The oldest bit is the Norman keep. The newest bit is the gift shop. Mind the steps, they're original.",
          "The Pendle witches of 1612 were held here before their trial. The history is sad, and so is the weather. But the tour is warm, and the tea is hot."], "down", "still")
    chat(z, "lan_baker", "villager_6", 16, 28, "Baker",
         ["Lancashire hotpot: lamb, onions, sliced potato on top, and a long, slow bake. It's the Sunday dinner of the north. I've been told I make it too well, which has never once been a complaint.",
          "We sell Eccles cakes, too, though they're from down the road. Don't tell the Eccles people."], "up", "wander")
    chat(z, "lan_walker", "hillwalker", 31, 5, "Walker",
         ["Lancaster's the gateway north. Fell country is that way, with the Lakes at the end of it. Wear boots. The Lakes have opinions about trainers.",
          "From Lancaster you can see the hills across Morecambe Bay. On a clear day. Today is... a day."], "down", "wander")
    trainer(z, "lan_angler", "Angler Dennis", "Angler", "angler", [("holtling", 85), ("stalklet", 85), ("minkshade", 85)],
            43, 19, "right", ["Barbel in the Lune and roach in the canal. I come every Sunday. The fish don't come every Sunday. It's a kind of friendship."],
            "Fair do's. You netted me.", "The canal fish are fat from sandwiches. They know a soft touch when they see one.", 3400)
    trainer(z, "lan_warden", "Warden Cuthbert", "Warden", "warden_grunt", [("binfox", 85), ("sootwing", 85), ("grizzlet", 85)],
            31, 10, "down", ["Welcome to the Lancaster Heritage Experience! Castle, canal and quay, all curated for your convenience. The fee is, as ever, a surprise."],
            "I'll have to ask my manager. He's on a fell somewhere.", "The Enclosure says the Lune should be tidier. I've been told to be kind to rivers. They don't listen.", 3300)
    z.d["edges"] = {"east": {"to": "yorkshire_dales", "offset": 0}, "north": {"to": "lake_district", "offset": 0}}
    z.d["spawn"] = [31, 21]
    wild(z, [("starlet", 84, 85, 16, {}), ("binfox", 84, 85, 12, {"time": ["night", "dusk"]}), ("chipgull", 84, 85, 14, {}),
             ("minkshade", 85, 86, 8, {"time": ["night"]}), ("grizzlet", 84, 85, 10, {}), ("cooplet", 84, 85, 12, {}),
             ("stalklet", 85, 86, 8, {}), ("zigzlet", 84, 85, 6, {"time": ["night"]})])
    wild(z, [("holtling", 84, 85, 22, {}), ("chipgull", 84, 86, 16, {}), ("pierlord", 85, 86, 8, {}), ("dipling", 84, 85, 14, {}),
             ("stalklet", 84, 85, 12, {}), ("pupplash", 85, 86, 6, {"weather": ["drizzle", "downpour"]})], "water")
    tidy(z)
    z.save(OUT + "/lancaster.json")
    sanctuary(OUT, "lancaster", "Lancaster", (38, 19))
    shop(OUT, "lancaster", "Lancaster", (53, 19))
    nurse("lancaster", ["Well, hello there, love. Welcome to the Lancaster Sanctuary. Pop your team on the counter and I'll have a look.",
                        "Sit yourself down. There's a brew on, and a fruit scone if you ask nicely. Your creatures are in good hands.",
                        "All done. They're fighting fit and a bit smug about it. Go on, off with you. Mind the canal.",
                        "The Ark? It's the terminal by the window. It runs on a very old computer and a lot of faith.",
                        "Right you are. Pop back any time. We're warmer than the castle, and the tea's better."])
    shopkeeper("lancaster", "Come in, come in. Hotpot, hot tea, and a map that is only slightly wrong. What can I get you?",
               "Cheerio, then. And watch the cobbles. They've caused more tumbles than the witches.")
