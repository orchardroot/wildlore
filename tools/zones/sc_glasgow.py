# plan 5 group B, part 2: glasgow (city) with Sanctuary and Corner Shop, the ceilidh double-battle pair and a station.
from sc_common import *
from sc_common import _stand


def build(OUT):
    glasgow(OUT)


def glasgow(OUT):
    W, H = 72, 60
    z = Z("glasgow", "Glasgow", W, H, kind="town", region=SCOT, music="town_scotland",
          weather={"drizzle": 40, "clear": 18, "downpour": 16, "fog": 6, "gale": 6, "sunshine": 14})
    z.d["stage"] = "city"; z.d["town_id"] = "glasgow"
    z.border("T", 2, gaps=[(22, 58, 3, 2), (30, 0, 3, 2), (70, 20, 2, 3)])
    z.scatter(0, 0, W, H, "P", 30, 21, only="T")
    # the Clyde: river y36..41 with quays either side
    z.rect(2, 36, 68, 6, "~")
    z.rect(2, 32, 68, 4, ":"); z.rect(2, 42, 68, 2, ":")
    z.rect(2, 28, 68, 4, "=")
    # Squinty Bridge (the Clyde Arc) and the Millennium footbridge
    z.rect(22, 36, 3, 6, ":"); z.rect(21, 36, 1, 6, "W"); z.rect(25, 36, 1, 6, "W")
    z.rect(41, 36, 2, 6, "|"); z.rect(40, 36, 1, 6, "F"); z.rect(43, 36, 1, 6, "F")
    z.rect(22, 44, 3, 14, "=")
    # George Square and the roads into it
    z.rect(30, 0, 3, 17, "=")
    z.rect(28, 17, 20, 10, ":")
    z.rect(47, 20, 25, 3, "=")
    z.rect(30, 27, 3, 1, "=")
    z.building(34, 11, 12, 6, "stone", "City Chambers", door=6)
    z.rect(40, 17, 1, 1, ":")
    # Kelvingrove: the gallery, the park
    z.building(4, 6, 12, 6, "cathedral", "Kelvingrove Art Gallery", door=6)
    z.rect(3, 12, 20, 12, ".")
    z.rect(10, 12, 1, 16, "#"); z.rect(4, 17, 18, 1, "#"); z.rect(22, 12, 1, 16, "#")
    for (x, y, w, h) in [(4, 13, 5, 4), (12, 13, 8, 4), (4, 19, 5, 4), (12, 19, 8, 4)]:
        z.rect(x, y, w, h, ",")
    z.rect(13, 14, 4, 2, "w"); z.rect(14, 14, 2, 1, "~")
    z.prop("statue", 9, 12); z.prop("statue", 11, 12)
    z.prop("bench", 9, 14); z.prop("bench", 11, 14); z.prop("lamp_post", 9, 16); z.prop("lamp_post", 11, 16)
    scatter_props(z, "oak", 3, 12, 20, 12, 12, 22, avoid=(".",))
    z.sign(11, 13, "KELVINGROVE ART GALLERY. Built of red sandstone for the 1901 International Exhibition, and now one of the most visited museums in Britain. It has a Spitfire hanging from the ceiling, an elephant called Sophie, a Dalí, and an organ that gives a free concert most days. Entry is free. Ask for the elephant.")
    # sanctuary and shop on the main street
    z.building(14, 24, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(17, 27, "glasgow_sanctuary", 5, 6, "up")
    z.building(23, 24, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(25, 27, "glasgow_shop", 4, 5, "up")
    # the north: tenements and the cathedral
    z.building(34, 3, 8, 5, "terrace"); z.building(43, 3, 8, 5, "red_brick")
    z.building(53, 3, 8, 5, "terrace"); z.building(62, 3, 8, 5, "red_brick")
    z.rect(18, 3, 10, 8, "."); scatter_props(z, "oak", 18, 3, 10, 8, 7, 23, avoid=(".",))
    z.building(57, 16, 10, 4, "cathedral", "Glasgow Cathedral")
    # Queen Street station
    station(z, 50, 12, 10, 4, "Queen Street Station")
    z.rect(48, 14, 2, 1, ":"); z.rect(48, 14, 1, 6, ":")
    z.rect(60, 14, 8, 1, ":"); z.prop("bench", 52, 14); z.prop("lamp_post", 57, 14)
    rail_guard(z, 56, 14, ["Queen Street Station. Trains for every station you have visited in Great Britain. Mind the gap, the step, and the pigeon.",
                           "Hop aboard! Where to? Ar adhart, as they say: onwards."], facing="left")
    # Merchant City and a quayside crane
    z.building(50, 23, 7, 4, "terrace", "Merchant City")
    z.building(59, 23, 9, 4, "red_brick", "Ceilidh Hall", door=4)
    z.building(51, 32, 7, 3, "aqueduct", "Finnieston Crane")
    z.rect(59, 27, 9, 1, ":")
    # south bank: Govan, a park, a science centre
    z.building(4, 46, 9, 4, "terrace"); z.building(14, 46, 6, 4, "red_brick")
    z.building(28, 46, 11, 5, "cream_render", "Science Centre")
    z.building(46, 46, 9, 4, "terrace"); z.building(57, 46, 9, 4, "red_brick")
    z.rect(4, 51, 16, 6, ","); z.rect(28, 52, 15, 5, ","); z.rect(46, 51, 20, 6, ",")
    z.rect(21, 51, 1, 1, "."); z.rect(26, 44, 1, 1, ":")
    for (x, y) in [(30, 31), (44, 31), (60, 31), (7, 31), (49, 21), (23, 45), (25, 45), (35, 25), (41, 25)]:
        z.prop("lamp_post", x, y)
    z.prop("planter", 21, 28); z.prop("planter", 27, 28); z.prop("bench", 20, 28); z.prop("post_box", 29, 28)
    z.prop("phone_box", 33, 30)
    # George Square dressing
    for (x, y) in [(31, 19), (44, 19), (31, 25), (44, 25)]:
        z.prop("statue", x, y)
    z.prop("statue", 37, 22)
    for (x, y) in [(34, 20), (40, 20), (34, 24), (40, 24)]:
        z.prop("bench", x, y)
    for (x, y) in [(29, 17), (46, 17), (29, 26), (46, 26)]:
        z.prop("planter", x, y)
    z.prop("lamp_post", 37, 25); z.prop("lamp_post", 37, 19)
    z.sign(36, 18, "GEORGE SQUARE. The front lawn of the City Chambers, lined with statues of writers, scientists and soldiers, including Walter Scott up on a very tall column. The square has also hosted film crews, Christmas markets and one truly ambitious pigeon.")
    z.prop("statue", 50, 21)
    z.sign(49, 22, "THE DUKE AND HIS CONE. Glasgow's famous Duke of Wellington statue always seems to wear a traffic cone. The council has removed it many times. The city has put it back many times more. Scotland's local politics, in one object.")
    z.sign(21, 35, "SQUINTY BRIDGE. Officially the Clyde Arc, opened in 2006. The arch leans to one side and the deck curves, so everyone calls it the Squinty Bridge. Nobody has ever called it the Clyde Arc without a wee smile.")
    z.sign(40, 35, "THE CLYDE. The river that built the city. Once the shipyards on its banks launched a big share of the world's ships. Today its quays are for walking, cycling and watching the water change colour.")
    z.sign(51, 35, "THE FINNIESTON CRANE. A giant cantilever crane from 1931, built to lift locomotives and boilers onto ships. Glasgow-built engines were sent all over the world. The crane is a monument now, and it still looks like it could lift your house.")
    z.sign(23, 19, "GLASCHU. Glasgow comes from an old name usually translated as 'the dear green place', and there are more parks here than you'd expect. St Mungo, the founder, left a rhyme: a bird that never flew, a tree that never grew, a bell that never rang, a fish that never swam. They're on the city's coat of arms.")
    # NPCs
    chat(z, "glw_subway", "villager_1", 21, 30, "Subway Rider",
         ["The Glasgow Subway is just one circle, opened in 1896, and it's the third oldest underground in the world after London and Budapest. We call it the Clockwork Orange. Politely, it's orange.",
          "It goes round and round, so you can't get on the wrong train. You can only get on the right train in the wrong direction."], "down", "wander")
    chat(z, "glw_guide", "tour_guide", 12, 12, "Gallery Guide",
         ["Welcome to Kelvingrove! Mind the elephant, he's called Sophie, and he's under glass. Be impressed, quietly.",
          "There's a Spitfire in the ceiling, a Dalí of Christ on a cross seen from above, and a great pipe organ that plays most days. The gallery's free, so don't get any ideas about paying."], "down", "still")
    chat(z, "glw_riveter", "farmer", 54, 35, "Retired Riveter",
         ["I worked on the Clyde for forty years. Whole ships grew from the river like a magic trick, and it took ten thousand of us to do the trick.",
          "That crane there lifted locomotives. Glasgow built engines for half the planet. The other half wanted them too."], "down", "still")
    chat(z, "glw_busker", "villager_6", 33, 21, "Square Busker",
         ["Nae bother in George Square. It's a cracking spot for a tune. The statues are a captive audience, and the pigeons are fair critics.",
          "A wee bit of Gaelic? Ciamar a tha thu, 'how are you'. Say it and people will smile. Say it badly and they'll smile more."], "down", "wander")
    chat(z, "glw_artstudent", "student", 22, 20, "Art Student",
         ["The Glasgow School of Art made this city a design capital. Charles Rennie Mackintosh's work is all over town: tall chairs, roses and a lot of straight lines.",
          "Mackintosh liked everything to match. He designed the building, the chairs, the cutlery and, probably, the weather."], "down", "wander")
    # the ceilidh pair: one double-battle trainer, two NPCs
    trainer(z, "glasgow_ceilidh", "Fiona and Ruaridh", "Ceilidh Caller", "ceilidh_caller",
            [("raidtail", 69), ("cooplet", 69), ("kidgruff", 70), ("grizzlet", 69)],
            62, 29, "down",
            ["FIONA: Strip the Willow starts at seven, and it starts with you.",
             "RUARIDH: We'll teach you the steps. We'll also teach you humility. That one costs extra."],
            "FIONA: Ye've the legs for it! RUARIDH: And the feet! We'll call that a draw. Mostly in our favour.",
            "Every step has a caller, and every caller has a favourite couple. We're the couple.", 2800)
    TRN["glasgow_ceilidh"]["double"] = True
    TRN["glasgow_ceilidh"]["name"] = "Fiona and Ruaridh"
    _stand(z, 63, 29)
    z.npc(id="glasgow_ceilidh_b", sprite="ceilidh_caller", x=63, y=29, facing="down", move="still", trainer="glasgow_ceilidh")
    trainer(z, "glw_piper", "Piper Dougal", "Piper", "piper", [("murmurant", 69), ("heronarch", 70), ("rookery", 69)],
            36, 30, "down", ["A piper on the quay is a Glasgow tradition. Listen for the drone. Then listen for me winning."],
            "A rare lull in the drone. Well played.", "A good piper never runs out of breath. A great piper runs out of friends and just plays louder.", 2700)
    trainer(z, "glw_student", "Student Kirsty", "Student", "student", [("flittermouse", 69), ("raidtail", 69), ("sootwing", 70)],
            16, 17, "right", ["I'm meant to be sketching the gallery. A battle is just a moving still life."],
            "Marvellous. I'll sketch that one later. From memory. Flatteringly.", "The trick to Kelvingrove is to go in for ten minutes and come out three hours later.", 2650)
    trainer(z, "glw_hillwalker", "Hillwalker Struan", "Hillwalker", "hiker", [("fawnlet", 69), ("stagmor", 70), ("eaglet", 69)],
            44, 54, "left", ["I came to Glasgow to see the city. I stayed because of the parks. Care for a tussle in the grass?"],
            "A grand walk and a grander fight. My boots concede.", "The West Highland Way starts just north of here. A hundred miles of lovely views and blisters.", 2700)
    z.d["edges"] = {"south": {"to": "galloway", "offset": 0}, "north": {"to": "glencoe", "offset": 0}, "east": {"to": "central_belt", "offset": 0}}
    z.d["spawn"] = [31, 22]
    wild(z, [("raidtail", 69, 70, 14, {}), ("grizzlet", 69, 70, 10, {"time": ["dawn", "day"]}), ("binfox", 69, 70, 12, {"time": ["night", "dusk"]}),
             ("strutcoo", 69, 70, 10, {"time": ["day", "dawn"]}), ("cooplet", 69, 70, 6, {"weather": ["drizzle", "downpour"]}),
             ("pierlord", 69, 70, 10, {}), ("starlet", 69, 70, 8, {"time": ["dusk", "dawn"]}), ("flittermouse", 69, 70, 8, {"time": ["night"]}),
             ("sootwing", 69, 70, 8, {"weather": ["fog", "drizzle"]}), ("bobbin", 69, 70, 6, {}), ("cluricaun", 69, 70, 4, {"time": ["night"]})])
    wild(z, [("pierlord", 69, 70, 25, {}), ("chipgull", 69, 70, 25, {}), ("dipling", 69, 70, 20, {}), ("stalklet", 69, 70, 15, {}),
             ("bradan", 69, 70, 10, {"weather": ["drizzle", "downpour"]}), ("rillotter", 69, 70, 12, {})], "water")
    z.save(OUT + "/glasgow.json")
    sanctuary(OUT, "glasgow", "Glasgow", (17, 28))
    shop(OUT, "glasgow", "Glasgow", (25, 28))
    nurse("glasgow", ["Haw there, and welcome to Glasgow Sanctuary. That's the traditional greeting. Pop your team on the counter, pal. Or friend. Or both.",
                      "Sit yersel doon. Have a cuppa. Don't mind the rain, it's only passing through. It's been passing through for eleven days.",
                      "There ye go, right as rain, which is exactly how you are. Mòran taing, as we say in the Gaelic bits. Mind the cone on the Duke.",
                      "The Ark terminal's in the corner. It's powered by hot water, determination and an enormous amount of tea.",
                      "No bother at all. Away you go. Beannachd leibh, and mind the puddles, they're deeper than they look."])
    shopkeeper("glasgow", "Hullo! We've snares, tablet, and an ambitious number of umbrellas. Anything you fancy?",
               "Cheers, pal! Mind how you go, and take a wee brolly. It's Glasgow.")
