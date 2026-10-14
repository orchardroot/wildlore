# plan 5 group A, part 2: belfast (+ belfast_yard), bushmills, derry, the cairnryan stub, and their Sanctuaries and Corner Shops.
from wcommon import *
from wcommon import _stand


def build(OUT):
    belfast(OUT)
    yard(OUT)
    bushmills(OUT)
    derry(OUT)
    cairnryan_stub(OUT)


def belfast(OUT):
    W, H = 72, 56
    z = Z("belfast", "Belfast", W, H, kind="town", region="ireland", music="town_city",
          weather={"drizzle": 32, "clear": 20, "downpour": 10, "fog": 6, "gale": 8, "sunshine": 24})
    z.d["stage"] = "docks"; z.d["town_id"] = "belfast"
    z.border("T", 2, gaps=[(30, 0, 3, 2), (35, 54, 3, 2)])
    z.scatter(0, 0, W, H, "P", 24, 2, only="T")
    # Belfast Lough in the north-east, the open water to the east
    z.rect(40, 0, 32, 12, "$")
    z.rect(62, 0, 10, H, "$")
    # the river Lagan, with shallow banks and a deep middle
    z.rect(40, 12, 5, 42, "~"); z.rect(40, 12, 1, 42, "w"); z.rect(44, 12, 1, 42, "w"); z.rect(41, 12, 3, 42, "o")
    # streets: Donegall Place north-south, Great Victoria Street east-west, the south road
    z.rect(30, 0, 3, 34, "="); z.rect(29, 2, 1, 32, ":"); z.rect(33, 2, 1, 32, ":")
    z.rect(2, 34, 43, 3, "="); z.rect(2, 33, 28, 1, ":"); z.rect(2, 37, 33, 1, ":")
    z.rect(35, 37, 3, 17, "=")
    z.rect(34, 38, 1, 16, ":"); z.rect(38, 38, 1, 16, ":")
    # the bridge over the Lagan, with parapets
    z.rect(40, 34, 5, 3, ":")
    z.rect(40, 33, 5, 1, "W"); z.rect(40, 37, 5, 1, "W")
    z.prop("lamp_post", 41, 32); z.prop("lamp_post", 43, 38)
    z.rect(45, 34, 17, 3, "=")
    z.sign(39, 32, "THE LAGAN. Belfast sits where this river meets the sea, and the name 'Béal Feirste' means 'mouth of the sandbank ford'. There used to be a ford here. Now there are bridges, a weir, and a very large metal fish.")
    # City Hall and Donegall Square
    z.rect(5, 5, 27, 9, ".")
    z.rect(8, 14, 25, 4, ":")
    z.building(13, 7, 14, 7, "liver_building", "Belfast City Hall")
    z.rect(8, 6, 4, 8, "f"); z.rect(28, 6, 4, 8, "f")
    z.prop("statue", 20, 15); z.prop("lamp_post", 12, 15); z.prop("lamp_post", 28, 15); z.prop("bench", 15, 17); z.prop("bench", 25, 17)
    z.prop("planter", 9, 14); z.prop("planter", 31, 14)
    z.sign(21, 17, "BELFAST CITY HALL. Opened in 1906 in Portland stone, with a copper dome that went green long ago. The grounds are open to everyone and have been used for fairs, concerts, and the city's grandest sulks.")
    z.rect(5, 18, 25, 2, ":")
    # the park: the Botanic style lawns, a Palm House, flower beds and tall grass
    z.rect(3, 20, 24, 9, ".")
    z.rect(14, 19, 1, 11, "#"); z.rect(4, 24, 22, 1, "#")
    z.rect(4, 21, 7, 3, ","); z.rect(18, 26, 8, 3, ","); z.rect(4, 26, 8, 3, "f"); z.rect(18, 21, 8, 3, "f")
    z.building(8, 21, 6, 3, "white_render", "Palm House")
    z.prop("oak", 6, 20, variant=1); z.prop("oak", 24, 21); z.prop("oak", 16, 27, variant=2); z.prop("birch", 5, 28); z.prop("birch", 22, 28)
    z.prop("bench", 13, 25); z.prop("bench", 15, 25); z.prop("lamp_post", 13, 23); z.prop("lamp_post", 15, 27)
    z.sign(16, 20, "THE PALM HOUSE. A curved glass and iron greenhouse from the 1830s, one of the oldest in the world. It was built to keep tropical plants alive in a climate that disagrees. The plants appear to have won.")
    # Sanctuary and Corner Shop, north of Great Victoria Street
    z.building(12, 30, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(14, 33, "belfast_shop", 4, 5, "up")
    z.building(20, 30, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(23, 33, "belfast_sanctuary", 5, 6, "up")
    # east of Donegall Place: an arts building, the Linen Hall, the leaning Albert Clock
    z.building(34, 6, 6, 6, "stone", "Ulster Museum")
    z.rect(34, 12, 6, 2, ":"); z.rect(34, 14, 5, 1, ":")
    z.building(34, 16, 6, 4, "terrace", "Linen Hall Library")
    z.building(36, 24, 2, 3, "chapel", "Albert Clock")
    z.prop("lamp_post", 34, 22); z.prop("lamp_post", 39, 22); z.prop("bench", 35, 29); z.prop("planter", 38, 29)
    z.sign(35, 21, "THE LINEN HALL LIBRARY. Founded in 1788, the oldest library in Belfast, with a collection that includes a thousand years of the city's stories, a cat, and a very patient librarian. Belfast once made so much linen it was nicknamed Linenopolis.")
    z.sign(38, 27, "THE ALBERT CLOCK. A tower from the 1860s built on wooden piles in soft ground. It leans a little, like a clock that has been up too late. It still tells the time, usually correctly.")
    z.prop("bollard", 39, 13); z.prop("bollard", 39, 16); z.prop("bollard", 39, 20)
    # the station: Great Victoria Street, south-west
    station(z, 6, 38, 9, 4, "Great Victoria Street")
    z.rect(4, 38, 2, 3, ":"); z.rect(4, 37, 2, 1, ":")
    z.prop("bench", 9, 40); z.prop("lamp_post", 14, 40)
    rail_guard(z, 12, 40, ["Great Victoria Street. Trains to every Northern Irish station you've visited. Please mind the gap, the step, and the seagull on the bench.",
                           "Hop aboard. The Wildlore rail runs to any town you have visited on this island. Where to?"])
    z.rect(3, 43, 30, 10, ".")
    z.building(4, 44, 8, 3, "terrace", "Lisburn Road Shops", door=None, show_label=False)
    z.building(14, 44, 7, 3, "red_brick", "Sandwich Bar", show_label=True)
    z.building(23, 44, 7, 3, "terrace", show_label=False)
    z.rect(4, 47, 26, 1, ":")
    for x in (7, 11, 16, 20, 25):
        z.prop("planter", x, 48)
    z.prop("oak", 6, 50); z.prop("oak", 12, 51, variant=1); z.prop("oak", 22, 50, variant=2); z.prop("bench", 17, 49)
    # the Titanic Quarter, east bank
    z.rect(45, 12, 17, 22, ".")
    z.building(49, 14, 12, 7, "stone", "Titanic Belfast")
    z.rect(46, 21, 16, 13, ":")
    z.rect(46, 12, 3, 9, ":")
    z.prop("lamp_post", 48, 22); z.prop("lamp_post", 60, 22); z.prop("lamp_post", 48, 32); z.prop("lamp_post", 60, 32)
    for x in (52, 55, 58):
        z.prop("bench", x, 23)
    z.prop("planter", 50, 22); z.prop("planter", 57, 22)
    z.prop("statue", 54, 28)
    z.sign(53, 28, "TITANIC BELFAST. A museum that opened in 2012, with a front like the prows of four ships, as tall as the Titanic's hull. The ship was built just along the slipway here by 15,000 workers at Harland and Wolff. This is where the story starts, not where it ends.")
    z.sign(47, 20, "THE SLIPWAYS. Two long slopes, each as big as a football pitch, where the biggest ships of their day slid into the water. The hulls took years to build and seconds to launch, and they were greased with tallow. Lots of tallow.")
    # the cranes and the yard
    z.rect(46, 37, 2, 14, ":"); z.rect(46, 42, 14, 2, ":")
    z.building(49, 38, 4, 3, "cream_render", "Samson")
    z.building(55, 38, 4, 3, "cream_render", "Goliath")
    z.prop("lamp_post", 48, 41); z.prop("lamp_post", 54, 41); z.prop("lamp_post", 58, 41)
    z.sign(53, 41, "SAMSON AND GOLIATH. The two giant yellow cranes of the shipyard, 106 and 96 metres tall, built in 1969 and 1974. They can be seen from almost anywhere in Belfast, and they are named after two strong men, one a hero and one a pushover.")
    z.rect(46, 50, 14, 1, ":")
    z.building(48, 44, 9, 6, "red_brick", "Belfast Yard", door=4)
    z.warp(52, 49, "belfast_yard", 8, 11, "up")
    z.prop("planter", 50, 50); z.prop("planter", 54, 50)
    # the ferry quay and pier
    z.rect(59, 37, 3, 10, ":"); z.rect(62, 44, 6, 3, ":")
    z.d["ferry"] = {"x": 66, "y": 45, "route": "belfast_cairnryan"}
    z.prop("boat", 69, 45, variant=0)
    z.prop("boat", 65, 40, variant=1); z.prop("boat", 66, 50, variant=1)
    z.prop("buoy", 64, 38); z.prop("buoy", 68, 41); z.prop("buoy", 66, 36)
    for (x, y) in [(63, 43), (63, 47), (67, 43), (67, 47)]:
        z.prop("bollard", x, y)
    z.sign(60, 36, "BELFAST PORT. The ferry to Cairnryan in Scotland leaves from here. The crossing takes a couple of hours, the sea is as grey as the sky, and the sandwiches are optimistic.")
    # people
    z.npc(id="belfast_sailor", sprite="sailor", x=64, y=44, facing="right", move="still", script="sailor")
    script("belfast", "sailor", say("Sailor", "Cairnryan, is it? The Selkie sails when the tide's right and the tea's brewed. Mind the gulls. They're organised.") + [{"do": "ferry", "route": "belfast_cairnryan"}])
    chat(z, "titanic_guide", "tour_guide", 52, 24, "Museum Guide",
         ["Welcome to Titanic Belfast! Harland and Wolff built the ship here, and it sailed in 1912. The story's sad, but the building is a joy, and the gift shop has a very good fudge.",
          "Did you know the Titanic had a sister ship, the Olympic, built right alongside her? The Olympic sailed for 24 years. Nobody tells you that, because it's a lovely story with no iceberg."], "down", "still")
    chat(z, "dock_worker", "tin_miner", 51, 42, "Dock Worker",
         ["I look up at Samson and Goliath every day. Hundred metres of yellow steel. They're no longer needed to build ships, but they're loved. We would never take them down.",
          "On a Friday, the whole city looks up at them and says, 'right, that's us'. It's a Belfast thing."], "up", "wander")
    chat(z, "black_taxi", "villager_4", 36, 38, "Taxi Driver",
         ["Black cab tour? I'll take you round all of it, and I'll tell you every story twice, once with feeling.",
          "Belfast's got a sense of humour like nobody else's. It's the only city I know where 'not bad' is a standing ovation."], "right", "wander")
    chat(z, "park_busker", "villager_5", 15, 18, "Busker",
         ["Fiddle, whistle, and a bodhran on my knee. I'm a one-man session. If the rain comes, I'll be a one-man wet session.",
          "'Craic' is the word for fun and gossip. If you've had good craic, you've had a good time. If you've had bad craic, you've been in a meeting."], "down", "still")
    chat(z, "bridge_walker", "villager_2", 38, 35, "Passer-by",
         ["The Lagan used to be so muddy you'd never guess there was a river. Now it's full of life: seals, salmon, even a few brave kayakers.",
          "There's a huge fish sculpture down by the Waterfront, covered in tiles telling the history of Belfast. It's been called the Big Fish for twenty years. Nobody has come up with a better name."], "down", "wander")
    trainer(z, "bel_student", "Student Padraig", "Student", "student", [("rivetling", 63), ("pierlord", 63), ("chipgull", 63)],
            14, 22, "up", ["I'm studying naval architecture. Which is boats. Mostly the shape of boats. Mostly their feelings, though they don't tell me."],
            "A sound design. I'll make a note.", "The Titanic's hull was almost 270 metres long. I couldn't find a seat in the lecture hall.", 2100)
    trainer(z, "bel_shipwright", "Shipwright Nuala", "Shipwright", "tin_miner", [("rivetling", 64), ("samsonian", 64), ("bobbin", 63)],
            54, 43, "left", ["I'm a shipwright, and my job is making things stay afloat. Yours is to try and make me sink. Fair?"],
            "Not even a leak. You've a steady hull.", "The rivets on the Titanic numbered about three million. All of them put in by hand. I've counted mine, and there are three.", 2250)
    z.d["edges"] = {"south": {"to": "mournes", "offset": 0}, "north": {"to": "antrim_coast", "offset": 0}}
    z.d["spawn"] = [31, 30]
    wild(z, [("rivetling", 62, 64, 16, {}), ("chipgull", 62, 64, 14, {"time": ["day", "dawn"]}), ("pierlord", 63, 64, 10, {"time": ["day", "dusk"]}),
             ("raidtail", 62, 63, 10, {}), ("binfox", 62, 64, 8, {"time": ["night", "dusk"]}), ("cooplet", 62, 63, 10, {"weather": ["drizzle", "downpour"]}),
             ("sootwing", 62, 64, 8, {"time": ["night"]}), ("strutcoo", 62, 63, 8, {"time": ["day", "dawn"]}), ("grizzlet", 62, 63, 8, {}),
             ("hootlet", 62, 63, 6, {"time": ["night"]}), ("samsonian", 64, 64, 3, {}), ("starlet", 62, 63, 8, {"time": ["dusk"]})])
    wild(z, [("pollanet", 62, 64, 30, {}), ("pierlord", 63, 64, 18, {}), ("chipgull", 62, 63, 16, {}), ("dipling", 62, 63, 14, {}),
             ("stalklet", 62, 64, 10, {}), ("bradan", 63, 64, 10, {"weather": ["drizzle", "downpour"]})], "water")
    z.save(OUT + "/belfast.json")
    sanctuary(OUT, "belfast", "Belfast", (23, 34))
    shop(OUT, "belfast", "Belfast", (14, 34))
    nurse("belfast", ["What about ye! Welcome to the Belfast Sanctuary. Pop your team on the counter, love, and we'll sort them out.",
                      "Right. Have a seat, there's a cuppa on, and I'll not say a word about the weather. It's got enough to say for itself.",
                      "All done. They're right as rain, which is a bit rich because it's raining. Mind how you go.",
                      "The Ark? Aye, that's the terminal in the corner. It runs on very strong tea and a cousin from Lisburn.",
                      "No bother. Come in out of the wet any time. The kettle never stops."])
    shopkeeper("belfast", "Come on in! Soda farls, snares, and an Ulster fry, if you've a very big appetite or a very sad week.",
               "Away on with you, and mind the gulls on the quay. They're not hungry. They just like the look of your sandwich.")


def yard(OUT):
    a = Z("belfast_yard", "Belfast Yard", 17, 14, fill="|", kind="interior", region="", music="battle_keeper", weather={"drizzle": 100})
    a.d["stage"] = "docks"
    a.border("x", 1)
    a.rect(2, 2, 13, 9, "+")
    a.rect(2, 2, 3, 7, "~")               # the slip: water under a half-built hull
    a.rect(5, 2, 1, 7, "|")
    a.rect(1, 1, 15, 1, "|"); a.rect(7, 11, 3, 1, "|")
    a.set(8, 12, "D")
    a.warp(8, 12, "belfast", 52, 50, "down")
    a.prop("boat", 3, 5, variant=1); a.prop("bollard", 6, 2); a.prop("bollard", 6, 8)
    a.prop("lamp_post", 13, 2); a.prop("lamp_post", 3, 10); a.prop("planter", 14, 9); a.prop("bench", 13, 6)
    a.prop("bollard", 1, 12); a.prop("bollard", 15, 12)
    a.npc(id="keeper_ruairi", sprite="keeper_ruairi", x=9, y=3, facing="down", move="still", script="keeper_ruairi")
    script("belfast_yard", "keeper_ruairi", say("Keeper Ruairi", "Placeholder: the story agent rewrites this Keeper battle script."))
    trainer(a, "yard_welder", "Shipwright Conor", "Shipwright", "tin_miner", [("rivetling", 63), ("quarrion", 63), ("bobbin", 63)],
            11, 7, "left", ["Visor down, friend. Ruairi tests every visitor on the rivets, and I'm the first rivet."],
            "A clean weld of an argument. On you go.", "Rivets hold a ship together. People hold a yard together. Mostly with tea.", 1980)
    trainer(a, "yard_apprentice", "Shipwright Maeve", "Shipwright", "tin_miner", [("samsonian", 64), ("shuttlecog", 63), ("tinnet", 64)],
            6, 5, "right", ["I'm only on my second year, so I take the heavy bits. Do you know how much a ship's anchor weighs? Neither does my back."],
            "I'll go and have a lie down in the hull.", "Ruairi's been welding for thirty years. He still says 'check it again'. So I check it again.", 2050)
    a.d["spawn"] = [8, 11]
    a.save(OUT + "/belfast_yard.json")


def bushmills(OUT):
    W, H = 44, 34
    z = Z("bushmills", "Bushmills", W, H, kind="town", region="ireland", music="town_ireland",
          weather={"drizzle": 28, "clear": 24, "fog": 8, "gale": 8, "sunshine": 28, "downpour": 4})
    z.d["stage"] = "town"; z.d["town_id"] = "bushmills"
    z.border("T", 2, gaps=[(0, 18, 2, 3), (42, 18, 2, 3)])
    z.scatter(0, 0, W, H, "P", 14, 8, only="T")
    # the main street runs east-west; the Bush river crosses it
    z.rect(0, 18, 44, 3, "="); z.rect(2, 17, 40, 1, ":"); z.rect(2, 21, 40, 1, ":")
    z.rect(30, 2, 5, 30, "~"); z.rect(30, 2, 1, 30, "w"); z.rect(34, 2, 1, 30, "w"); z.rect(31, 2, 3, 30, "o")
    z.rect(30, 18, 5, 3, "=")
    z.rect(31, 17, 3, 1, "W"); z.rect(31, 21, 3, 1, "W")
    z.prop("lamp_post", 29, 16); z.prop("lamp_post", 35, 22)
    # the village green
    z.rect(11, 7, 17, 9, "."); z.rect(11, 7, 17, 1, "F"); z.rect(11, 7, 1, 9, "F"); z.rect(27, 7, 1, 9, "F")
    z.rect(18, 7, 3, 1, "."); z.rect(11, 12, 1, 2, "."); z.rect(27, 12, 1, 2, ".")
    z.rect(12, 14, 15, 1, "#"); z.rect(19, 8, 1, 7, "#"); z.rect(12, 11, 15, 1, "#")
    z.rect(13, 8, 4, 2, "f"); z.rect(22, 8, 4, 2, "f"); z.rect(13, 12, 4, 2, ","); z.rect(22, 12, 4, 2, ",")
    z.rect(18, 15, 3, 2, "#")
    z.prop("oak", 14, 9, variant=1); z.prop("oak", 25, 10); z.prop("oak", 15, 13, variant=2); z.prop("oak", 24, 13, variant=1)
    z.prop("bench", 17, 11); z.prop("bench", 22, 11); z.prop("lamp_post", 19, 9); z.prop("planter", 21, 15); z.prop("planter", 17, 15)
    z.prop("statue", 19, 12)
    z.sign(20, 12, "THE VILLAGE GREEN. A square of grass at the heart of Bushmills, kept in trim by a few hundred feet and the odd sheep who 'got in'. It has hosted every fair, concert and short argument for over two hundred years.")
    # the old mill, by the river
    z.building(24, 24, 6, 4, "mill", "The Old Mill", door=3)
    z.rect(25, 28, 5, 1, ":")
    z.prop("planter", 24, 28); z.prop("bench", 27, 29)
    z.sign(28, 28, "THE OLD MILL. Bushmills is named for the mill on the river Bush: Muileann na Buaise, in Irish. A water mill has stood here for centuries, turning the river's weight into something useful and the walker's mood into 'oh, how quaint'.")
    # Sanctuary and Corner Shop, south of the street
    z.building(6, 22, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(8, 25, "bushmills_shop", 4, 5, "up")
    z.building(13, 22, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(16, 25, "bushmills_sanctuary", 5, 6, "up")
    z.rect(5, 26, 15, 1, ":")
    z.rect(20, 26, 1, 3, ":")
    z.building(4, 12, 6, 4, "white_render", "Post Office", show_label=True)
    z.building(36, 22, 5, 4, "terrace", "Craft Shop")
    z.building(36, 12, 5, 4, "slate_cottage", "Riverside Cottage")
    z.rect(36, 16, 5, 1, ":")
    z.prop("lamp_post", 38, 17); z.prop("lamp_post", 5, 17)
    z.prop("phone_box", 3, 17); z.prop("post_box", 10, 17); z.prop("bench", 6, 17)
    # the heritage railway: a narrow-gauge steam halt (the Giant's Causeway and Bushmills Railway)
    station(z, 4, 28, 7, 3, "Bushmills Railway")
    z.rect(2, 22, 1, 9, "#"); z.rect(3, 30, 1, 1, "#")
    rail_guard(z, 9, 30, ["Bushmills Station, home of the little steam railway to the Causeway. Narrow gauge, big smile, and a chimney that thinks it's a volcano.",
                          "Hop aboard. The Wildlore rail runs to any town you have visited on this island. Where to?"], "left")
    # trees and scatter
    scatter_props(z, "oak", 3, 3, 8, 12, 6, 2, avoid=(".",))
    scatter_props(z, "bush", 3, 22, 38, 9, 8, 3, avoid=(".",))
    z.rect(36, 3, 6, 8, ",")
    z.rect(4, 3, 6, 8, ",")
    z.sign(32, 15, "THE RIVER BUSH. A short, quick river full of salmon and trout, running down to the sea at the Causeway Coast. Anglers have been casting here for centuries. The river has been politely ignoring them for the same length of time.")
    z.sign(3, 15, "BUSHMILLS. A small town with a river, a green, a steam train and a view. In 1883 the world's first hydro-powered electric tramway ran from here to the Causeway. The tramway has gone, but the sense of being a bit ahead of everyone else remains.")
    chat(z, "mill_keeper", "villager_6", 27, 29, "Miller's Daughter",
         ["Don't tell anyone, but the mill hasn't ground a grain in a century. The wheel still turns, though, for the tourists. It likes the audience.",
          "The Bush is a quick little river. Quick to flood, quick to clear. Like a Bushmills argument."], "up", "still")
    chat(z, "green_gardener", "villager_2", 16, 13, "Gardener",
         ["I do the flower beds on the green. Two hundred years of Bushmills folk have walked across them, and not one asked permission.",
          "Planting tulips is an act of faith. You bury a thing in the cold, in the dark, and trust it to come back with a better attitude."], "right", "wander")
    chat(z, "station_volunteer", "farmer", 13, 30, "Railway Volunteer",
         ["We run a little steam train from here to the Causeway. Two kilometres, three-foot gauge, and a driver who waves at sheep.",
          "It's a slow train. That's the point. If you wanted to arrive quickly, you wouldn't be going to the Causeway."], "left", "wander")
    chat(z, "young_cyclist", "jogger", 25, 19, "Cyclist",
         ["I've cycled the whole coast road to get here and I'm thrilled. My legs have asked me to stop saying thrilled.",
          "There's a great chippy by the green. It's called the Chippy. Subtle, but it works."], "right", "wander")
    chat(z, "post_clerk", "shopkeeper", 7, 17, "Postmaster",
         ["Letters, parcels and gossip. Two out of three are free of charge.",
          "I know everybody who lives here and which dog belongs to whom. It's the dogs I rely on. They're never wrong."], "down", "still")
    z.d["edges"] = {"east": {"to": "causeway", "offset": 0}, "west": {"to": "derry", "offset": 0}}
    z.d["spawn"] = [22, 19]
    wild(z, [("redbreast", 66, 66, 14, {}), ("pipkin", 66, 66, 12, {}), ("strutcoo", 66, 66, 10, {"time": ["day"]}), ("rookery", 66, 66, 10, {}),
             ("dextera", 66, 66, 10, {}), ("stagmor", 66, 66, 8, {"time": ["dawn", "dusk"]}), ("hootlet", 66, 66, 8, {"time": ["night"]}),
             ("flaxling", 66, 66, 8, {}), ("starlet", 66, 66, 10, {"time": ["dusk", "dawn"]}), ("gealhare", 66, 66, 8, {})])
    wild(z, [("bradan", 66, 66, 25, {}), ("parrlet", 66, 66, 20, {}), ("rillotter", 66, 66, 20, {}), ("dipling", 66, 66, 15, {}),
             ("heronarch", 66, 66, 10, {}), ("pollanet", 66, 66, 10, {})], "water")
    z.save(OUT + "/bushmills.json")
    sanctuary(OUT, "bushmills", "Bushmills", (16, 26))
    shop(OUT, "bushmills", "Bushmills", (8, 26))
    nurse("bushmills", ["Well hello there! This is the Bushmills Sanctuary, which is small, warm, and entirely free of draughts, since we blocked them in 1998.",
                        "Sit yourself down, here's a cup of tea. You'll be fine after a bit of peace, a biscuit, and a pat from the Sanctuary cat.",
                        "There you are. All better. If you meet a seagull on the way out, don't make eye contact.",
                        "The Ark terminal's under the stairs, past the umbrella stand. We've named it after the river. It flows, it sits, it holds.",
                        "No problem. The door's always open and so is the biscuit tin."])
    shopkeeper("bushmills", "Come in, come in! Snares, scones, and an umbrella with only a slight personality.",
               "Safe home! And mind the cattle grid, it's a disgrace to the town.")


def derry(OUT):
    W, H = 72, 50
    z = Z("derry", "Derry", W, H, kind="town", region="ireland", music="town_city",
          weather={"drizzle": 32, "clear": 20, "downpour": 10, "fog": 8, "gale": 8, "sunshine": 22})
    z.d["stage"] = "city"; z.d["town_id"] = "derry"
    z.border("T", 2, gaps=[(70, 18, 2, 3)])
    z.scatter(0, 0, W, H, "P", 24, 3, only="T")
    # the hill: the walled city stands on a rise at level 1; the lower ground around is level 0
    z.height(8, 6, 35, 32, 1)
    # the river Foyle: shallows, deep middle, the Peace Bridge across it
    z.rect(52, 2, 9, 46, "~"); z.rect(52, 2, 1, 46, "w"); z.rect(60, 2, 1, 46, "w"); z.rect(54, 2, 5, 46, "o")
    z.rect(52, 18, 9, 3, ":")
    z.rect(52, 17, 9, 1, "W"); z.rect(52, 21, 9, 1, "W")
    z.prop("lamp_post", 54, 16); z.prop("lamp_post", 58, 16); z.prop("lamp_post", 54, 22); z.prop("lamp_post", 58, 22)
    z.sign(56, 16, "THE PEACE BRIDGE. A curving footbridge opened in 2011, 235 metres long, joining the two sides of the Foyle in one graceful S. It is made for walkers and cyclists, and for the sort of person who likes to cross a river in a flourish.")
    # the walls: a ring of cut stone with a walkway on top (platform), gates on four sides
    for x in range(8, 43):
        z.set(x, 6, "W"); z.set(x, 37, "W")
    for y in range(6, 38):
        z.set(8, y, "W"); z.set(42, y, "W")
    for x in range(9, 42):
        z.set(x, 7, "_"); z.set(x, 36, "_")
    for y in range(7, 37):
        z.set(9, y, "_"); z.set(41, y, "_")
    # streets inside: the four main streets meet at the Diamond
    z.rect(9, 18, 33, 3, ":"); z.rect(22, 7, 3, 30, ":")
    z.rect(18, 15, 11, 9, ":")
    for k in range(3):
        z.set(42, 18 + k, ":"); z.set(8, 18 + k, ":"); z.set(22 + k, 6, ":"); z.set(22 + k, 37, ":")
    for y in range(6, 38):
        for x in range(8, 43):
            if x in (8, 9, 41, 42) or y in (6, 7, 36, 37):
                z.hg[y][x] = 2 if z.g[y][x] == "_" else 1
    z.rect(22, 2, 3, 4, ":"); z.rect(22, 38, 3, 3, ":")
    z.prop("statue", 23, 19)
    z.sign(25, 22, "THE DIAMOND. The market square at the middle of the walled city, a town square with the streets running off the four sides like the arms of a clock. The pigeons hold their meetings here at noon.")
    # buildings inside the walls
    z.building(11, 9, 8, 5, "terrace", "Craft Village", show_label=True)
    z.building(26, 9, 8, 5, "stone", "Tower Museum")
    z.building(35, 9, 5, 5, "red_brick", "Bookshop", show_label=True)
    z.building(11, 23, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(13, 26, "derry_shop", 4, 5, "up")
    z.building(18, 25, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(21, 28, "derry_sanctuary", 5, 6, "up")
    z.rect(10, 29, 28, 2, ":"); z.rect(10, 27, 8, 2, ":")
    z.rect(13, 27, 1, 1, ":")
    z.building(27, 25, 7, 4, "tudor", "Waterloo Tavern", show_label=True)
    z.building(35, 24, 5, 5, "red_brick", "Linen Mill Flats")
    z.prop("lamp_post", 12, 17); z.prop("lamp_post", 20, 17); z.prop("lamp_post", 28, 17); z.prop("lamp_post", 36, 17)
    z.prop("lamp_post", 12, 21); z.prop("lamp_post", 32, 21)
    z.prop("bench", 17, 22); z.prop("bench", 29, 22); z.prop("planter", 19, 16); z.prop("planter", 27, 16)
    # cannons along the walkway
    z.prop("bollard", 14, 8); z.prop("bollard", 30, 8); z.prop("bollard", 36, 8); z.prop("bollard", 14, 35); z.prop("bollard", 33, 35)
    z.sign(11, 8, "THE WALLS. Built between 1613 and 1618, about 1.5 kilometres round, and still whole: Derry is the only city in Ireland that still has its walls all the way round. You can walk the whole top. It takes about an hour, or two with the views.")
    z.sign(16, 35, "ROARING MEG. A big old cannon on the walls that earned its name by being loud. It's been quiet for centuries, which in cannons counts as a hard-won retirement.")
    z.sign(10, 17, "BOGSIDE. West of the walls, the oak woods that gave the city its name: Doire means 'oak grove'. Many of the oaks are long gone, but plenty of people still say 'Derry' and mean every one of them.")
    # outside the walls: east apron, the Guildhall and Waterside
    z.rect(43, 16, 9, 7, ":")
    z.building(44, 6, 8, 6, "liver_building", "The Guildhall", door=4)
    z.rect(44, 12, 8, 4, ":")
    z.rect(43, 18, 9, 3, "=")
    z.prop("planter", 44, 15); z.prop("planter", 51, 15); z.prop("lamp_post", 43, 13); z.prop("lamp_post", 52, 12)
    z.sign(48, 14, "THE GUILDHALL. A big red Victorian building with a clock tower and a hall full of stained glass, built in 1890 and rebuilt after a fire in 1908. It has seen concerts, councils and one remarkable wedding cake.")
    # the Waterside, east bank: station and quay
    z.rect(61, 16, 9, 7, ":"); z.rect(61, 18, 11, 3, "=")
    station(z, 63, 8, 6, 3, "Derry Station")
    z.rect(61, 10, 2, 1, ":"); z.rect(61, 11, 1, 5, ":"); z.rect(61, 9, 1, 2, ":")
    z.prop("bench", 64, 10)
    rail_guard(z, 67, 10, ["Derry Station, on the far bank of the Foyle, which is the prettiest place to arrive in Ireland. I'm biased, but the view helps.",
                           "Hop aboard. The Wildlore rail runs to any town you have visited on this island. Where to?"], "left")
    scatter_props(z, "oak", 61, 25, 9, 20, 8, 4, avoid=(".",))
    z.rect(62, 27, 6, 3, ","); z.rect(62, 35, 6, 4, ",")
    scatter_props(z, "oak", 44, 24, 8, 20, 6, 5, avoid=(".",))
    z.rect(44, 24, 7, 3, ","); z.rect(44, 36, 7, 5, ",")
    scatter_props(z, "oak", 3, 6, 4, 32, 10, 6, avoid=(".",))
    z.rect(3, 26, 4, 8, ","); z.rect(2, 18, 6, 3, ":")
    z.rect(10, 42, 31, 1, "#")
    scatter_props(z, "oak", 10, 39, 31, 8, 10, 7, avoid=(".",))
    z.rect(12, 43, 8, 3, ","); z.rect(28, 43, 10, 3, ",")
    chat(z, "wall_guide", "tour_guide", 12, 8, "Walls Guide",
         ["Welcome to the Derry Walls! They're 1.5 kilometres round, up to 8 metres thick in places, and the oldest of their sort in Ireland.",
          "Please stay on the walkway. The walls have stood for 400 years, but they've never had to deal with tourists with selfie sticks."], "down", "still")
    chat(z, "museum_curator", "student", 27, 15, "Museum Curator",
         ["The Tower Museum tells Derry's story in four floors and one very steep staircase. We say the climb is an exhibit in itself.",
          "Doire means 'oak grove'. The city was named for a wood. Quite a few of the oaks are still around, and the rest are doing very well as furniture."], "down", "still")
    chat(z, "bridge_cyclist", "jogger", 56, 19, "Bridge Cyclist",
         ["I cross the Peace Bridge four times a day. I don't need to. It's just that every time, the light on the river is different.",
          "The bridge is built so it feels like it's dancing. You'll see. Take your time, even if you're late."], "left", "wander")
    chat(z, "diamond_busker", "villager_5", 20, 19, "Busker",
         ["I play on the Diamond. Wonderful acoustics: four streets, four directions of shouting, and a statue at the middle to absorb the heckles.",
          "Derry's known for its music, you know. Songs, fiddles, and a good melody in the kitchen at two in the morning."], "right", "still")
    chat(z, "ferry_pilot", "villager_6", 46, 20, "Foyle Walker",
         ["The Foyle's a lovely river. Wide, easy, full of light. The sort of river that makes you want to write down what you're feeling. Then you remember you have a bus to catch.",
          "The name Foyle comes from the Irish 'Feabhal', and it means 'lip' or 'edge'. The river sits on the edge of everything, like a politely lingering guest."], "down", "wander")
    trainer(z, "der_student", "Student Roisin", "Student", "student", [("hazeldoze", 67), ("gealhare", 67), ("rookery", 67)],
            30, 19, "right", ["I'm writing an essay about the Walls and I'm stuck. Walking them helps, but it keeps getting me lost. They go in a circle."],
            "Brilliant. That'll go in the footnotes.", "Walk the walls and you'll understand Derry. Walk them twice and you'll understand yourself. Walk them thrice and you'll want a sit down.", 2400)
    trainer(z, "der_warden", "Warden Barnaby", "Warden", "warden_grunt", [("sootwing", 67), ("pooka", 67), ("tormane", 67)],
            47, 19, "right", ["Excuse me. The Enclosure has pre-installed a viewing platform on these walls. You require a booking, a lanyard, and a laminated opinion."],
            "Hm. I appear to have booked the wrong day.", "The Enclosure has a lovely vision for Derry: a preserved city with the people removed. The people declined.", 2450)
    z.d["edges"] = {"east": {"to": "bushmills", "offset": 0}}
    z.d["spawn"] = [46, 19]
    wild(z, [("redbreast", 67, 67, 12, {}), ("hazeldoze", 67, 67, 10, {}), ("rookery", 67, 67, 12, {}), ("starlet", 67, 67, 10, {"time": ["dawn", "dusk"]}),
             ("cooplet", 67, 67, 8, {"weather": ["drizzle", "downpour"]}), ("strutcoo", 67, 67, 10, {"time": ["day"]}), ("pipkin", 67, 67, 10, {}),
             ("pooka", 67, 67, 8, {"time": ["night"]}), ("hootlet", 67, 67, 6, {"time": ["night"]}), ("stagmor", 67, 67, 8, {"time": ["dawn"]}),
             ("flaxling", 67, 67, 10, {}), ("bansheen", 67, 67, 4, {"weather": ["fog"]})])
    wild(z, [("bradan", 67, 67, 25, {}), ("heronarch", 67, 67, 15, {}), ("dipling", 67, 67, 20, {}), ("chipgull", 67, 67, 15, {}),
             ("pollanet", 67, 67, 15, {}), ("selklet", 67, 67, 10, {"time": ["dusk"]})], "water")
    z.save(OUT + "/derry.json")
    sanctuary(OUT, "derry", "Derry", (21, 29))
    shop(OUT, "derry", "Derry", (13, 27))
    nurse("derry", ["Hello there, love, and welcome to the Derry Sanctuary! Sit down, take the weight off, and let me look at your team.",
                    "Rest here. There's tea, a custard cream, and a window with a view of the Walls. It's always the best seat in town.",
                    "All done. They're in fine fettle, and so are you. Go on, off with ye. The Walls aren't going to walk themselves.",
                    "The Ark is the machine by the stairs. It has a screen, a fan, and the patience of a saint.",
                    "No bother. Pop in any time. Even if it's just to get out of the rain. Which is a good reason."])
    shopkeeper("derry", "Welcome! Snares, soda bread, and an umbrella that is currently being rented to the weather.",
               "Safe home now. And mind the cobbles. They're older than your granny's granny.")


def cairnryan_stub(OUT):
    z = Z("cairnryan", "Cairnryan", 40, 30, kind="town", region="scotland", music="town_city")
    z.d["stage"] = "docks"; z.d["town_id"] = "cairnryan"; z.d["stub"] = True
    z.border("T", 3)
    z.rect(3, 12, 34, 4, ":"); z.rect(30, 3, 7, 24, "$")
    z.rect(26, 12, 11, 4, ":")
    z.d["ferry"] = {"x": 33, "y": 13, "route": "belfast_cairnryan"}
    z.prop("boat", 36, 13, variant=0)
    z.npc(id="cairnryan_sailor", sprite="sailor", x=31, y=14, facing="right", move="still", script="sailor")
    script("cairnryan", "sailor", say("Sailor", "Back to Belfast? The ferry's ready when you are.") + [{"do": "ferry", "route": "belfast_cairnryan"}])
    z.d["spawn"] = [20, 13]
    z.save(OUT + "/cairnryan.json")
