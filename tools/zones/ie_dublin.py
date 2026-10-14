# plan 4 group B, part 2: dublin (city) with its Keeper hall, Sanctuary, Corner Shop, ferry quay and station.
from wcommon import *
import math
from wcommon import _stand


def build(OUT):
    dublin(OUT)
    hall(OUT)


def dublin(OUT):
    W, H = 72, 54
    z = Z("dublin", "Dublin", W, H, kind="town", region="ireland", music="town_ireland",
          weather={"drizzle": 32, "clear": 20, "downpour": 12, "fog": 8, "gale": 8, "sunshine": 20})
    z.d["stage"] = "city"; z.d["town_id"] = "dublin"
    z.border("T", 2, gaps=[(30, 0, 3, 2), (30, 52, 3, 2)])
    z.scatter(0, 0, W, H, "P", 30, 2, only="T")
    z.rect(60, 0, 12, H, "$")
    # the Liffey, running east to the bay
    z.rect(0, 25, 60, 4, "~")
    # quays and streets
    z.rect(2, 20, 58, 1, ":"); z.rect(2, 21, 60, 3, "="); z.rect(2, 24, 58, 1, ":")
    z.rect(2, 29, 58, 1, ":"); z.rect(2, 30, 60, 3, "="); z.rect(2, 33, 58, 1, ":")
    z.rect(30, 0, 3, H, "=")
    z.rect(29, 2, 1, 23, ":"); z.rect(33, 2, 1, 23, ":"); z.rect(29, 29, 1, 23, ":"); z.rect(33, 29, 1, 23, ":")
    z.rect(29, 25, 1, 4, "W"); z.rect(33, 25, 1, 4, "W")
    z.rect(40, 25, 5, 1, "w"); z.rect(50, 28, 5, 1, "w")
    z.sign(34, 24, "O'CONNELL BRIDGE. Wider than it is long. It started as a narrow stone bridge, but it was widened in 1880 to match the street, so people could say it looked square. It does.")
    z.sign(34, 29, "THE RIVER LIFFEY. Dublin comes from 'Dubh Linn', the black pool. The Irish name is Baile Átha Cliath, 'the town of the hurdle ford'. Both names are about crossing water. Wise.")
    # the Ha'penny Bridge
    z.rect(18, 25, 2, 4, ":"); z.rect(17, 25, 1, 4, "W"); z.rect(20, 25, 1, 4, "W")
    z.prop("lamp_post", 17, 24); z.prop("lamp_post", 20, 24); z.prop("lamp_post", 17, 29); z.prop("lamp_post", 20, 29)
    z.sign(21, 24, "THE HA'PENNY BRIDGE. A cast iron footbridge from 1816 that used to cost a halfpenny to cross. The toll went in 1919. The name stuck, which is how you can tell Dubliners love a bargain.")
    # the north bank west: Phoenix-ish park and the Keeper hall
    z.rect(3, 3, 24, 10, ".")
    z.rect(14, 3, 1, 10, "#"); z.rect(3, 8, 24, 1, "#")
    z.rect(4, 4, 8, 3, ","); z.rect(17, 4, 8, 3, ","); z.rect(4, 10, 7, 2, ","); z.rect(18, 10, 8, 2, ",")
    z.rect(12, 7, 5, 3, "f")
    z.prop("statue", 15, 9)
    z.sign(16, 8, "THE PARK. Dublin has one of the biggest walled city parks in Europe, with a herd of fallow deer that have lived there since the 1660s. The park's name comes from 'fionn uisce', clear water. It was mangled into 'phoenix' a long time ago.")
    scatter_props(z, "oak", 3, 3, 24, 10, 10, 6, avoid=(".",))
    z.building(6, 13, 12, 7, "stone", "Dublin Hall", door=6)
    z.warp(12, 19, "dublin_hall", 8, 11, "up")
    z.prop("planter", 9, 20); z.prop("planter", 15, 20); z.prop("lamp_post", 6, 20); z.prop("lamp_post", 17, 20)
    z.sign(10, 20, "DUBLIN HALL. Where Dublin plays hurling and gets rather loud about it. It's the fastest field game in the world, played with a stick called a hurley and a ball called a sliotar. Helmets, please.")
    z.building(22, 16, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(25, 19, "dublin_sanctuary", 5, 6, "up")
    # the north bank east: the shop, the Custom House, the station and a stage
    z.building(34, 16, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(36, 19, "dublin_shop", 4, 5, "up")
    z.building(40, 13, 12, 7, "cream_render", "Custom House")
    z.building(53, 14, 6, 6, "terrace", show_label=False)
    station(z, 36, 4, 9, 4, "Connolly Station")
    z.rect(34, 6, 2, 1, ":")
    z.prop("bench", 37, 6); z.prop("lamp_post", 44, 6)
    rail_guard(z, 42, 6, ["Connolly Station. Trains to every Irish station you've visited. Please mind the gap, the step and your dignity.",
                          "Hop aboard. The Wildlore rail runs to any town you have visited on this island. Where to?"])
    z.rect(34, 9, 12, 3, ":"); z.rect(46, 2, 13, 10, ":")
    z.rect(48, 3, 9, 4, "|")
    z.prop("lamp_post", 47, 3); z.prop("lamp_post", 57, 3); z.prop("planter", 47, 7); z.prop("planter", 57, 7)
    for x in (49, 51, 53, 55):
        z.prop("bench", x, 9)
    z.sign(47, 10, "TODAY ON THE STAGE: an announcement. Tote bags are free. The announcement is a surprise, and so are the tote bags.")
    z.prop("bench", 35, 12); z.prop("lamp_post", 40, 12)
    z.sign(40, 20, "THE CUSTOM HOUSE. A grand Georgian building on the quays, finished in 1791, and burned by Irish rebels in 1921. It was restored. It is quite impressive when it isn't on fire.")
    # south bank west: Trinity College
    z.rect(4, 34, 1, 16, "W"); z.rect(4, 49, 23, 1, "W"); z.rect(26, 34, 1, 16, "W")
    z.rect(5, 38, 21, 11, ":")
    z.building(5, 34, 7, 4, "stone", "Trinity College", show_label=True)
    z.building(15, 34, 7, 4, "stone", show_label=False)
    z.rect(12, 34, 3, 4, ":"); z.rect(22, 34, 4, 4, ".")
    z.rect(7, 40, 7, 5, "."); z.rect(6, 45, 7, 3, ".")
    z.building(16, 40, 3, 3, "stone", "Campanile")
    z.building(14, 45, 11, 4, "cream_render", "Old Library")
    z.prop("oak", 8, 41); z.prop("oak", 12, 43, variant=1); z.prop("oak", 7, 46, variant=2); z.prop("bench", 10, 42); z.prop("bench", 10, 47)
    z.prop("lamp_post", 12, 38); z.prop("lamp_post", 14, 38); z.prop("planter", 24, 40); z.prop("planter", 22, 40)
    z.sign(11, 39, "TRINITY COLLEGE. Founded in 1592, it holds the Book of Kells, a gospel manuscript made around the year 800, and the Long Room, a library hall 65 m long with about 200,000 old books and a smell students call 'academic'.")
    z.sign(24, 44, "THE CAMPANILE. Legend says that if you walk under it, you'll fail your exams. Students walk round it. They fail anyway, just more slowly.")
    # south bank east: Temple Bar and St Stephen's Green
    z.rect(34, 34, 25, 7, ":")
    z.building(34, 34, 7, 4, "tudor", "The Temple Bar")
    z.building(42, 34, 6, 4, "red_brick", "The Cobbler's Tap")
    z.building(49, 34, 9, 4, "terrace", "Temple Bar Books")
    z.rect(41, 34, 1, 4, ":"); z.rect(48, 34, 1, 4, ":")
    z.prop("statue", 45, 39)
    z.sign(46, 39, "MOLLY MALONE. A bronze fishmonger with a barrow, from the old song, 'cockles and mussels, alive, alive-o'. She stands in a street full of buskers and has never once joined the chorus.")
    for x in (36, 44, 52, 57):
        z.prop("lamp_post", x, 38)
    z.prop("bench", 38, 40); z.prop("bench", 54, 40); z.prop("planter", 40, 38); z.prop("planter", 50, 38)
    z.sign(35, 38, "TEMPLE BAR. Cobbled lanes, pubs, and live music from every window. The name is old, and 'bar' here means a walkway, not a pub, which no one has told the pubs.")
    # St Stephen's Green
    z.rect(35, 42, 23, 10, ".")
    z.rect(35, 42, 23, 1, "F"); z.rect(35, 51, 23, 1, "F"); z.rect(35, 42, 1, 10, "F"); z.rect(57, 42, 1, 10, "F")
    z.rect(35, 46, 1, 2, "."); z.rect(46, 42, 2, 1, ".")
    z.rect(37, 43, 19, 1, "#"); z.rect(37, 50, 19, 1, "#"); z.rect(37, 43, 1, 8, "#"); z.rect(55, 43, 1, 8, "#")
    z.rect(46, 43, 1, 8, "#"); z.rect(36, 46, 20, 1, "#")
    z.rect(43, 44, 7, 6, "w"); z.rect(44, 45, 5, 4, "~")
    z.rect(46, 45, 1, 4, "|"); z.rect(43, 46, 7, 1, "|")
    z.rect(38, 44, 5, 2, "f"); z.rect(51, 44, 4, 2, "f"); z.rect(38, 47, 4, 3, ","); z.rect(51, 47, 4, 3, ",")
    z.prop("bench", 40, 46); z.prop("bench", 53, 46); z.prop("lamp_post", 37, 44); z.prop("lamp_post", 55, 49); z.prop("lamp_post", 37, 49)
    z.prop("oak", 40, 44, variant=1); z.prop("oak", 53, 44); z.prop("oak", 42, 49); z.prop("oak", 52, 49, variant=2); z.prop("birch", 39, 48); z.prop("birch", 54, 48)
    z.sign(36, 44, "ST STEPHEN'S GREEN. 22 acres of lawn, flowerbeds and ducks, opened to the public in 1880 after Lord Ardilaun, of the Guinness family, paid for the layout. The ducks have never said thank you.")
    # the port: the ferry pier, and a lighthouse pier
    z.rect(60, 21, 9, 3, ":")
    z.d["ferry"] = {"x": 67, "y": 22, "route": "holyhead_dublin"}
    z.prop("boat", 70, 22, variant=0)
    z.prop("boat", 66, 26, variant=1); z.prop("boat", 64, 18, variant=1); z.prop("buoy", 63, 19); z.prop("buoy", 68, 26); z.prop("buoy", 65, 34)
    z.prop("bollard", 62, 21); z.prop("bollard", 62, 23); z.prop("bollard", 65, 21); z.prop("bollard", 65, 23)
    z.rect(58, 33, 3, 7, ":"); z.rect(60, 38, 10, 2, ":")
    z.prop("lighthouse", 69, 38); z.prop("bollard", 63, 38); z.prop("bollard", 66, 39)
    z.sign(61, 20, "DUBLIN PORT. The ferry for Holyhead leaves from here. The crossing is a little over three hours, the sea is grey, and the chips on board are optimistic.")
    # NPCs and story placeholders
    z.npc(id="dub_sailor", sprite="sailor", x=66, y=21, facing="down", move="still", script="sailor")
    script("dublin", "sailor", say("Sailor", "Back to Holyhead, is it? The Ulysses is warming her engines, and a seagull has already bagged the best seat.") + [{"do": "ferry", "route": "holyhead_dublin"}])
    z.npc(id="kerrigan_launch", sprite="kerrigan", x=52, y=4, facing="down", move="still", script="kerrigan_launch")
    script("dublin", "kerrigan_launch", say("Director Kerrigan", "Placeholder: the story agent writes the Ireland's Ancient East Experience launch here."))
    chat(z, "bridge_busker", "villager_6", 18, 23, "Bridge Busker",
         ["The Ha'penny Bridge is a lovely spot to play. Everyone slows down on it, and the echo does half my work.",
          "A halfpenny to cross, they charged. I do it for a euro and a smile. Or a smile and a euro. The smile's optional."], "down", "still")
    chat(z, "kells_guide", "tour_guide", 13, 39, "Library Guide",
         ["The Book of Kells is a gospel written out by monks around 800 AD, with the most gorgeous illustrations: cats, mice, peacocks, and a lot of knotwork.",
          "It is kept under glass in the Old Library. They turn a page every so often so it doesn't get bored. Honestly."], "down", "still")
    chat(z, "green_duck", "villager_2", 45, 44, "Duck Feeder",
         ["These ducks know me. They know my pockets, my cardigan, and my heavy sighs.",
          "St Stephen's Green had a different feel, once. It was a common for grazing cattle. Now it's a common for grazing sandwiches."], "down", "wander")
    chat(z, "pub_regular", "farmer", 38, 39, "Pub Regular",
         ["Temple Bar's got more pubs per square foot than anywhere I know. I'm not recommending that, it's an observation.",
          "Sláinte, they say, which is 'health'. It means a toast. I'm told it also means 'one more'. Both are true on the same evening."], "right", "wander")
    chat(z, "deer_keeper", "hiker", 22, 5, "Park Walker",
         ["The deer in the park are fallow deer, spotted in summer, and they've lived here since the 1660s. They're very relaxed.",
          "You can walk right up to them, but I'd advise against it. They look fluffy. They're not for hugs."], "down", "wander")
    for (nid, x, y) in [("park_fawn_1", 8, 5), ("park_fawn_2", 21, 11)]:
        _stand(z, x, y)
        z.npc(id=nid, sprite="creature:fawnlet", x=x, y=y, facing="down", move="wander", script="fawn")
    script("dublin", "fawn", say("Fawnlet", "It looks at you with the calm of a deer that has seen several hundred tourists today. You are the nicest of them."))
    trainer(z, "dub_fiddler", "Fiddler Saoirse", "Fiddler", "fiddler", [("cluricaun", 48), ("pierlord", 48), ("leveret", 48)],
            48, 39, "left", ["A session in Temple Bar, is it? You're welcome to listen, so long as you tap your foot in time."],
            "Ah. I dropped a note. And a battle.", "If you hear a fiddle in Dublin, it's likely on purpose. If you hear three, it's a session.", 1500)
    trainer(z, "dub_student", "Student Cathal", "Student", "student", [("hushwing", 49), ("strutcoo", 48), ("raidtail", 49)],
            13, 42, "up", ["Don't walk under the Campanile! I mean it. I can't afford to fail again."],
            "A masterpiece of argument. I'm updating my notes.", "I failed the exam anyway. The tradition holds.", 1520)
    z.d["edges"] = {"north": {"to": "boyne_valley", "offset": 0}, "south": {"to": "wicklow", "offset": 0}}
    z.d["spawn"] = [31, 22]
    wild(z, [("cluricaun", 47, 49, 12, {"time": ["dusk", "night"]}), ("chipgull", 47, 48, 14, {"time": ["day"]}), ("pierlord", 48, 49, 10, {"time": ["day", "dusk"]}),
             ("binfox", 48, 49, 8, {"time": ["night", "dusk"]}), ("raidtail", 47, 49, 10, {}), ("grizzlet", 47, 48, 5, {"time": ["dawn", "day"]}),
             ("strutcoo", 47, 49, 10, {"time": ["day", "dawn"]}), ("cooplet", 47, 48, 5, {"weather": ["drizzle", "downpour"]}),
             ("flittermouse", 48, 49, 8, {"time": ["night"]}), ("hootlet", 47, 48, 6, {"time": ["night"]}),
             ("fawnlet", 47, 48, 8, {"time": ["dawn", "dusk"]}), ("sootwing", 48, 49, 6, {"weather": ["fog", "drizzle"]})])
    wild(z, [("pierlord", 47, 49, 30, {}), ("chipgull", 47, 48, 25, {}), ("dipling", 47, 49, 20, {}), ("bradan", 48, 49, 10, {"weather": ["drizzle", "downpour"]}),
             ("stalklet", 47, 48, 15, {})], "water")
    z.save(OUT + "/dublin.json")
    sanctuary(OUT, "dublin", "Dublin", (25, 20))
    shop(OUT, "dublin", "Dublin", (36, 20))
    nurse("dublin", ["Dia duit, and welcome to the Dublin Sanctuary. That's 'God be with you', which is how we say hello. Pop your team on the counter.",
                     "Right so. Sit down, have a biscuit, and don't mind the rain. It stops. Occasionally.",
                     "There you go. Go raibh maith agat for waiting, that's 'thanks' in Irish. Mind the cobbles, they've got opinions.",
                     "The Ark terminal. It runs on turf, tea and a very patient intern.",
                     "No bother. Come in out of the wet, there's a hundred thousand welcomes, but only one chair."])
    shopkeeper("dublin", "Dia duit! Snares, soda bread and one umbrella, which is on loan to the weather.",
               "Slán abhaile! That's 'safe home'. Mind the seagulls on the quays, they're organised.")


def hall(OUT):
    a = Z("dublin_hall", "Dublin Hall", 17, 14, fill="|", kind="interior", region="", music="battle_keeper",
          weather={"drizzle": 100})
    a.d["stage"] = "city"
    a.border("x", 1)
    a.rect(2, 2, 13, 9, ".")
    a.rect(2, 2, 13, 1, "+"); a.rect(2, 10, 13, 1, "+")
    a.rect(1, 1, 15, 1, "|"); a.rect(7, 11, 3, 1, "|")
    a.set(8, 12, "D"); a.rect(8, 11, 1, 1, "|")
    a.warp(8, 12, "dublin", 12, 20, "down")
    a.prop("lamp_post", 6, 2); a.prop("lamp_post", 10, 2)       # the goalposts
    a.prop("bench", 3, 11); a.prop("bench", 13, 11); a.prop("bench", 3, 3); a.prop("bench", 13, 3)
    a.prop("planter", 2, 7); a.prop("planter", 14, 7); a.prop("bollard", 1, 12); a.prop("bollard", 15, 12)
    a.npc(id="keeper_declan", sprite="keeper_declan", x=8, y=3, facing="down", move="still", script="keeper_declan")
    script("dublin_hall", "keeper_declan", say("Keeper Declan", "Placeholder: the story agent rewrites this Keeper battle script."))
    trainer(a, "hall_hurler", "Hurler Ciarán", "Hurler", "hurler", [("raidtail", 48), ("dextera", 48), ("tormane", 49)],
            12, 7, "left",
            ["Fancy a puck-about? Declan likes us to warm up the visitors. I'm the warm-up. The rest of the lads are the main course."],
            "Good hit! Go on through. The boss is at the far end, and he's even louder than I am.",
            "Hurling's the fastest field game in the world. I'm told. I've never beaten it to the ball.", 960)
    trainer(a, "hall_hurler2", "Hurler Niamh", "Hurler", "hurler", [("stagmor", 49), ("gealhare", 50), ("warrender", 49)],
            4, 5, "right",
            ["Camogie's the same game, only the rules are a bit better and the players a bit faster. You'll see."],
            "Fair play. You've got a lovely swing.", "A sliotar can hit 150 kilometres an hour. Keep your helmet on. Metaphorically.", 1000)
    a.d["spawn"] = [8, 11]
    a.save(OUT + "/dublin_hall.json")
