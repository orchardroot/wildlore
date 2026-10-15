# plan 6 group A, part 3: newcastle (the Tyne, the Quayside, the Angel of the North, a station), its Sanctuary and Corner Shop.
from p6a_common import *
from wcommon import _stand


def build(OUT):
    newcastle(OUT)


def newcastle(OUT):
    W, H = 84, 66
    zid = "newcastle"
    z = Z(zid, "Newcastle", W, H, kind="town", region=NE, music="town_north",
          weather={"drizzle": 30, "clear": 26, "fog": 8, "gale": 10, "sunshine": 20, "downpour": 6})
    z.d["stage"] = "city"; z.d["town_id"] = "newcastle"
    z.border("T", 2, gaps=[(30, 0, 3, 2), (0, 20, 2, 3), (52, 64, 3, 2)])
    z.scatter(0, 0, W, H, "P", 24, 81, only="T")
    # the Tyne runs north to south; quays either side
    z.rect(36, 2, 12, 62, "~")
    z.rect(36, 2, 1, 62, "w"); z.rect(47, 2, 1, 62, "w")
    z.rect(37, 6, 1, 9, "o"); z.rect(46, 6, 1, 9, "o"); z.rect(37, 48, 1, 12, "o"); z.rect(46, 48, 1, 12, "o")
    z.rect(28, 2, 8, 62, ":")
    z.rect(48, 2, 7, 62, ":")
    # streets on the west bank
    z.rect(30, 0, 3, 28, "=")
    z.rect(0, 20, 30, 3, "=")
    z.rect(3, 9, 25, 2, ":")
    z.rect(3, 15, 25, 2, ":")
    z.rect(3, 28, 25, 2, ":")
    z.rect(3, 36, 25, 1, ":")
    z.rect(30, 28, 3, 36, "=")
    # bridges: the Tyne Bridge (an arch you admire), the swing-bridge road you cross, the Millennium footbridge
    z.building(36, 17, 12, 3, "aqueduct", "Tyne Bridge")
    z.rect(36, 24, 12, 3, "=")
    z.rect(36, 23, 12, 1, "W"); z.rect(36, 27, 12, 1, "W")
    z.rect(36, 24, 1, 3, "="); z.rect(47, 24, 1, 3, "=")
    z.rect(36, 43, 12, 1, "F"); z.rect(36, 46, 12, 1, "F")
    z.rect(36, 44, 12, 2, "|")
    z.prop("lamp_post", 38, 22); z.prop("lamp_post", 45, 22); z.prop("lamp_post", 38, 28); z.prop("lamp_post", 45, 28)
    z.sign(35, 23, "THE TYNE BRIDGE. Opened in 1928 and the symbol of the city. Its builders, Dorman Long of Middlesbrough, went on to make the Sydney Harbour Bridge, which looks rather like it. Seven bridges cross the Tyne between Newcastle and Gateshead within about a mile, and every Geordie has a favourite.")
    z.sign(35, 44, "GATESHEAD MILLENNIUM BRIDGE. Opened in 2001, the world's first tilting bridge. When a ship comes, the whole arch swings up like an eyelid, and it is nicknamed 'The Blinking Eye'. It really does blink.")
    # castle and cathedral
    z.building(4, 3, 10, 6, "castle", "The Castle Keep", door=5)
    z.building(16, 3, 10, 6, "cathedral", "St Nicholas' Cathedral", door=5)
    z.rect(9, 9, 1, 1, ":"); z.rect(21, 9, 1, 1, ":")
    z.sign(14, 9, "THE NEW CASTLE. Robert Curthose, son of William the Conqueror, put up a wooden fort here in 1080 on the site of a Roman one, and the town is named for that 'new castle'. The stone keep dates from 1172 and is one of the best-preserved Norman keeps in the country. A railway line runs right past it.")
    # Grainger Town and the Monument
    z.building(4, 11, 10, 4, "terrace", "Grainger Town"); z.building(15, 11, 12, 4, "terrace", "Grey Street")
    z.sign(14, 15, "GREY STREET. Often voted one of the finest streets in England. It curves down the hill in honey stone to Grey's Monument, a column for the Prime Minister who passed the Great Reform Act in 1832. Locals use it as a meeting point: 'meet you at the Monument' is the city's whole diary.")
    z.prop("statue", 24, 16, variant=2)
    # Sanctuary and Corner Shop on the Westgate road
    z.building(10, 17, 6, 3, "sanctuary", "Sanctuary", door=3)
    z.warp(13, 19, "newcastle_sanctuary", 5, 6, "up")
    z.building(18, 17, 5, 3, "shop", "Corner Shop", door=2)
    z.warp(20, 19, "newcastle_shop", 4, 5, "up")
    # the Bigg Market and the theatre
    z.building(4, 24, 8, 4, "red_brick", "Bigg Market"); z.building(13, 24, 7, 4, "stone", "Theatre Royal", door=3)
    z.building(21, 24, 6, 4, "terrace", "The Crown Posada")
    # Central Station
    station(z, 6, 31, 12, 6, "Newcastle Central Station")
    z.rect(5, 32, 1, 3, ":"); z.rect(18, 32, 1, 3, ":")
    z.prop("bench", 8, 35); z.prop("bench", 15, 35); z.prop("lamp_post", 12, 35)
    rail_guard(z, 16, 33, ["Newcastle Central. The first station to be lit by electricity, nearly. Trains for every station you have visited. Mind the gap and the gannet.",
                           "All aboard! Howay, where are we off to?"], facing="down")
    # the stadium and the Town Moor
    z.building(4, 38, 14, 6, "red_brick", "St James' Park")
    z.rect(4, 44, 22, 2, ":")
    z.rect(3, 46, 24, 16, ".")
    blob(z, 15, 54, 11, 7, ",", only=".", seed=3, jitter=0.3)
    z.rect(14, 44, 1, 10, "#")
    scatter_props(z, "oak", 3, 46, 24, 16, 8, 9, avoid=(".",))
    z.sign(15, 46, "THE TOWN MOOR. 1,000 acres of open grass in the middle of a city, bigger than Hyde Park and Hampstead Heath put together. The Freemen of Newcastle have the right to graze their cattle here, and some still do, which is why the cows have a better address than you.")
    # quayside market and boats
    for (x, y) in [(29, 11), (29, 13), (33, 11), (33, 13), (29, 33), (33, 33), (29, 35), (33, 35)]:
        z.prop("market_stall", x, y, variant=(x + y) % 3)
    for (x, y) in [(40, 8), (43, 11), (41, 33), (44, 38), (40, 52), (44, 56), (42, 60)]:
        z.prop("boat", x, y, variant=1)
    for (x, y) in [(39, 30), (44, 31), (42, 36)]:
        z.prop("buoy", x, y)
    for y in range(6, 62, 8):
        z.prop("lamp_post", 28, y); z.prop("lamp_post", 54, y)
    z.prop("bench", 34, 20); z.prop("bench", 49, 20); z.prop("bench", 34, 40); z.prop("bench", 49, 40)
    z.sign(33, 4, "THE QUAYSIDE. In the Middle Ages this was the busiest bit of the city: coal, wool and salt left from here to everywhere. On Sunday mornings there's a market with cheese, crafts, and a sausage roll that could convert the Pope.")
    # Gateshead: the Sage and the Baltic
    z.building(58, 16, 14, 5, "cream_render", "Sage Gateshead", door=7)
    z.rect(55, 21, 24, 2, ":")
    z.building(58, 30, 9, 5, "mill", "BALTIC Centre for Contemporary Art", door=4)
    z.rect(55, 35, 14, 1, ":")
    z.building(70, 30, 10, 4, "terrace", "Gateshead Quays")
    z.rect(70, 34, 10, 1, ":")
    z.rect(55, 24, 24, 3, "=")
    z.rect(52, 27, 3, 37, "=")
    z.rect(48, 28, 7, 34, ":")
    z.rect(52, 27, 3, 37, "=")
    z.prop("planter", 60, 22); z.prop("planter", 70, 22); z.prop("bench", 63, 22); z.prop("bench", 66, 22)
    z.sign(57, 22, "THE SAGE. A great curving ripple of glass and steel, opened in 2004, that looks like a silver armadillo that learned music. It is home to the Royal Northern Sinfonia. The concert hall is called Hall One. The architect gave it no other name. It is exactly what it says.")
    z.sign(56, 36, "THE BALTIC. Not a sea, a flour mill. It was Rank Hovis's mill, built 1950, and became a very large gallery for contemporary art in 2002. Locals call it the Baltic, as the fashion was to name a mill after a sea, and the sea after a mill. There is a viewing box on the roof.")
    # the Angel of the North, on her hill to the south
    hills(z, [(67, 55, 3, 8)])
    z.rect(60, 48, 14, 14, ".")
    z.prop("lamp_post", 63, 56); z.prop("lamp_post", 71, 56)
    z.rect(62, 56, 10, 1, "#")
    z.rect(55, 56, 8, 1, "#")
    z.sign(65, 57, "THE ANGEL OF THE NORTH. Antony Gormley's steel angel stands on a hill beside the A1, 20 metres tall with a wingspan of 54 metres, wider than a jumbo jet. Made of weathering steel that goes a deep rust red, and visited by about 150,000 people each year. She was put up in 1998 and some people hated her. Nobody does now.")
    blob(z, 70, 46, 6, 2, ",", only=".", seed=4, jitter=0.3)
    z.rect(60, 38, 14, 6, ".")
    z.building(58, 38, 10, 4, "terrace", "Gateshead Terraces"); z.building(70, 38, 9, 4, "red_brick", "Gateshead Library")
    z.rect(55, 42, 24, 1, ":")
    scatter_props(z, "oak", 56, 38, 22, 24, 12, 12, avoid=(".",))
    scatter_props(z, "bush", 56, 38, 22, 24, 10, 13, avoid=(".",))
    # the Angel herself: a tall figure on the hilltop, wings out
    z.building(67, 53, 1, 1, "chapel", "The Angel of the North", show_label=True)
    z.prop("statue", 65, 54, variant=0); z.prop("statue", 69, 54, variant=1)
    # NPCs
    chat(z, "ncl_geordie", "fisher", 31, 18, "Quayside Fisherman",
         ["Howay, pet! Welcome to the Toon. Geordie's not hard. 'Canny' is nice. 'Bairn' is a child. 'Hadaway' is 'oh, go on, you're having me on'.",
          "We say 'Howay the lads'. It means 'come on, then!' Everyone says it, even to the dog."], "right", "wander")
    chat(z, "ncl_baker", "shopkeeper", 29, 31, "Bakery Worker",
         ["Greggs started right here in Newcastle, in 1939, when John Gregg started delivering eggs by bike. Now it's every high street in the land.",
          "The sausage roll is the national treasure, and I'll thank you not to say 'vegan' within hearing of the older Geordies. They are fond of it, for a reason."], "down", "still")
    chat(z, "ncl_guide", "tour_guide", 41, 25, "Bridge Guide",
         ["Seven bridges, a mile, and a river. There's the Swing Bridge, the High Level Bridge, the Tyne Bridge, the Gateshead Millennium Bridge, the Redheugh, King Edward VII and the Metro one.",
          "The Tyne Bridge has a plaque for each and every parapet, and a seagull on each. In the season they are on a rota."], "up", "wander")
    chat(z, "ncl_artstudent", "student", 62, 37, "Art Student",
         ["The Baltic has no permanent collection, which is the idea. It changes every few months, so you never see the same thing twice. Unless you go to the cafe.",
          "From the top floor you can see the whole Tyne, and the Sage, and a lot of seagulls auditioning."], "left", "wander")
    chat(z, "ncl_freeman", "farmer", 8, 58, "Freeman",
         ["I'm a Freeman of the City. Which gets me grazing rights on the Town Moor, among other things. I've three cows. They think they own the place, and in a way, so do I.",
          "The Hoppings fair comes every June, the biggest travelling fair in Europe. The cows have a front row view."], "right", "wander")
    chat(z, "ncl_busker", "villager_5", 32, 38, "Busker",
         ["Newcastle sound? Geordie folk music. Pipes: not the Highland kind, the Northumbrian kind. Smaller, gentler, played sitting down with the bellows under the arm. Posh.",
          "Aye, a smallpipes tune can make a grown man cry. Or a seagull. Mostly the seagull."], "down", "wander")
    # trainers
    trainer(z, "ncl_band", "Brass Bandsman Arthur", "Brass Bandsman", "villager_4",
            [("shuttlecog", 81), ("samsonian", 81), ("sootwing", 81)], 34, 16, "left",
            ["The colliery bands were the heart of this region. Brass, polish, and a conductor who counts in a voice you can hear through a wall. Four, three, two..."],
            "Magnificent! I have not been so thoroughly out-played since Gateshead.", "A brass band is thirty people who all need to breathe at the same time. It's closer to a miracle than music.", 3400)
    trainer(z, "ncl_fisher", "Fisher Geordie", "Fisher", "fisher",
            [("pierlord", 81), ("greyhaul", 81), ("clownbill", 82)], 31, 46, "right",
            ["I fish for salmon off the Tyne. They came back when the river was cleaned up. First one in a hundred years: I cried. Right here, on this quay."],
            "Canny work, pet. You've a fine hand.", "The Tyne was once nearly dead from the shipyards. Now it has salmon and seals. That's a good bit of cleaning.", 3380)
    wild(z, [("peregrin", 81, 82, 14, {"time": ["day", "dawn"]}), ("binfox", 81, 82, 10, {"time": ["night", "dusk"]}), ("starlet", 81, 82, 10, {"time": ["dusk", "dawn"]}),
             ("cooplet", 81, 82, 10, {}), ("pepperling", 81, 82, 8, {}), ("swiftlet", 81, 82, 8, {"weather": ["gale", "drizzle"]}), ("grizzlet", 81, 82, 8, {}),
             ("flittermouse", 81, 82, 6, {"time": ["night"]}), ("rooklet", 81, 82, 8, {}), ("chipgull", 81, 82, 8, {}), ("bobbin", 81, 82, 6, {})])
    wild(z, [("chipgull", 81, 82, 20, {}), ("pierlord", 81, 82, 18, {}), ("dipling", 81, 82, 16, {}), ("stalklet", 81, 82, 14, {}),
             ("holtling", 81, 82, 14, {}), ("bradan", 81, 82, 10, {"weather": ["drizzle", "downpour"]}), ("pupplash", 81, 82, 8, {})], "water")
    z.d["edges"] = {"north": {"to": "hadrians_wall", "offset": 0}, "west": {"to": "penshaw", "offset": 0}, "south": {"to": "north_york_moors", "offset": 0}}
    z.d["spawn"] = [31, 21]
    done(z)
    z.save(OUT + "/" + zid + ".json")
    sanctuary(OUT, zid, "Newcastle", (13, 20), music="sanctuary")
    shop(OUT, zid, "Newcastle", (20, 20))
    nurse(zid, ["Why aye, pet! Welcome to the Newcastle Sanctuary. Pop the team on the counter and we'll have them right as rain, which, aye, is the usual weather.",
                "Sit yersel doon, pet. There's tea in the pot, a stottie on the plate, and a wind outside that could unseat a statue.",
                "Aa done, hinny! Not a scratch, no a scuff. Mind how ye go, and mind the seagulls. They've been told you're the next one.",
                "The Ark terminal's in the corner. It's powered by hot tea and stubbornness. Go on, pet, give us a click.",
                "No bother, pet. Come back when you need us. We'll still be here, and so will the wind."])
    shopkeeper(zid, "Howay in, pet! Snares, tea, stotties, pease pudding and a sausage roll, which we do not discuss in terms of who made it first. What can I get ye?",
               "Cheers, pet! Take a brolly. It's not raining now, but it knows you're leaving.")
