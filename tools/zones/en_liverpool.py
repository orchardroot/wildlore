# Part of england_north.py (exec'd in its namespace): Liverpool and the club.

# ====================================================================
# LIVERPOOL  64 x 58, city: east gap to Chat Moss, south gap to the Wirral
# ====================================================================
l = Z("liverpool", "Liverpool", 64, 58, kind="town", region="merseyside", music="town_city", fill=".",
      weather={"clear": 25, "sunshine": 20, "drizzle": 25, "gale": 15, "fog": 8, "downpour": 7})
l.d["stage"] = "docks"; l.d["town_id"] = "liverpool"
l.legend["d"] = {"tile": "tall_grass", "colour": "#c9b96d", "prop": "none"}
l.legend["r"] = REEDS
l.border("T", 3, gaps=[(26, 55, 3, 3), (61, 20, 3, 3)])
# the Mersey (north), the quay and the pier
l.rect(0, 0, 64, 9, "~"); l.rect(3, 9, 58, 2, ":")
l.rect(19, 3, 2, 6, ":")
l.prop("boat", 24, 5, variant=0); l.prop("boat", 8, 6, variant=1); l.prop("boat", 44, 4, variant=1)
l.prop("buoy", 12, 4); l.prop("buoy", 31, 3, variant=1); l.prop("buoy", 36, 6); l.prop("buoy", 52, 5, variant=1)
for x in (5, 9, 14, 17, 22, 30, 38, 43): l.prop("bollard", x, 9)
l.prop("lamp_post", 18, 8); l.prop("lamp_post", 21, 8)
l.d["ferry"] = {"x": 19, "y": 3, "route": "liverpool_douglas"}
l.sign(21, 3, "MERSEY FERRIES. Cross the Mersey to the Isle of Man. Bring a sandwich. And a sailor's hat if you've got one.")
l.sign(18, 6, "FERRY TO DOUGLAS. Departures when the tide, the captain and the seagulls agree.")
# the Three Graces
l.building(14, 11, 8, 4, "stone", "Cunard Building", door=3)
l.building(24, 11, 9, 4, "liver_building", "Royal Liver Building", door=4)
l.building(35, 11, 8, 4, "red_brick", "Port of Liverpool Building", door=3)
l.rect(10, 15, 40, 5, ":")
l.rect(11, 11, 2, 4, ":"); l.rect(44, 9, 2, 11, ":")
for (x, y) in [(13, 15), (22, 15), (34, 15), (43, 15)]: l.prop("lamp_post", x, y)
for x in (35, 36, 37, 38): l.prop("statue", x, 17)
l.sign(33, 18, "THE FAB FOUR, in bronze. Please do not ask them to get back together. They've heard.")
l.prop("statue", 19, 17); l.sign(18, 18, "SUPERLAMBANANA. It's exactly what it says. A banana-lamb. Don't think too hard.")
l.prop("bench", 12, 17); l.prop("bench", 48, 17); l.prop("planter", 30, 17); l.prop("planter", 24, 17)
l.sign(28, 15, "THE LIVER BIRDS. If they fly away, Liverpool ceases to exist. They have a very good union.")
# Albert Dock
l.rect(46, 11, 15, 13, ":"); l.rect(48, 14, 10, 6, "~")
l.building(47, 11, 7, 2, "mill", "Albert Dock Warehouse", door=3)
l.rect(55, 9, 5, 4, ":")
l.building(55, 11, 5, 2, "red_brick", "Maritime Museum", door=2)
l.building(46, 23, 8, 4, "mill", "Albert Dock South", door=3)
l.building(55, 23, 5, 4, "red_brick", "The Beatles Story", door=2)
for (x, y, v) in [(51, 16, 1), (55, 17, 1)]: l.prop("canal_boat", x, y, variant=v)
l.prop("boat", 53, 18, variant=1)
for y in (14, 17): l.prop("bollard", 47, y)
for y in (15, 18): l.prop("bollard", 58, y)
l.sign(46, 20, "ALBERT DOCK, 1846. The first warehouses built with no wood at all. Only brick, iron and stone. The fire brigade were overjoyed.")
# streets
l.rect(3, 20, 61, 3, ":"); l.rect(3, 21, 61, 1, "=")
l.rect(26, 23, 3, 35, ":"); l.rect(27, 15, 1, 43, "=")
l.rect(26, 15, 3, 5, ":")
for x in (6, 14, 22, 32, 40, 52, 58): l.prop("lamp_post", x, 22)
for y in (26, 32, 38, 44, 50):
    l.prop("lamp_post", 25, y); l.prop("lamp_post", 29, y)
# Sanctuary, Corner Shop, club
l.rect(4, 23, 22, 6, ":")
town_services(l, "liverpool", "Liverpool", (6, 24), (14, 24))
cb = l.building(31, 24, 7, 4, "red_brick", "The Cavern (ish)", door=3)
cbf = door_to(l, cb, "liverpool_club", 6, 9)
l.rect(31, 28, 8, 2, ":")
l.sign(33, 29, "THE CAVERN (ISH). Where four lads once played 292 times. Our drummer plays only 291. Keeper's Club. Members only. And you.")
l.prop("lamp_post", 30, 29); l.prop("planter", 39, 28)
l.prop("phone_box", 25, 24); l.prop("post_box", 25, 29)
l.building(40, 24, 5, 4, "terrace", show_label=False)
# Lime Street station (west)
l.rect(3, 31, 22, 11, ":")
l.building(6, 36, 8, 2, "station", "Lime Street Station", door=3)
l.rect(3, 38, 17, 1, "_"); l.rect(3, 39, 22, 1, "!")
l.d["station"] = {"x": 9, "y": 38}
l.prop("lamp_post", 5, 40); l.prop("lamp_post", 17, 40); l.prop("bench", 12, 40)
l.sign(16, 35, "LIME STREET. Beautiful station. Terrible at timetables. Excellent at goodbyes.")
for (x, y) in [(5, 32), (13, 33), (20, 32), (22, 36)]: l.prop("oak", x, y)
# south: terraces, the cathedral and Sefton-ish park with dune grass
l.rect(40, 31, 18, 8, ":"); l.rect(30, 38, 9, 3, ":")
l.building(42, 33, 9, 4, "cathedral", "Liverpool Cathedral", door=4)
l.prop("lamp_post", 41, 38); l.prop("lamp_post", 52, 38)
l.sign(47, 38, "LIVERPOOL CATHEDRAL. Biggest in Britain. Took 74 years to finish. Builders apparently on a tea break.")
l.rect(3, 41, 22, 14, "."); l.rect(4, 41, 21, 1, "#")
for x in (4, 14): l.building(x, 44, 8, 3, "terrace", show_label=False)
l.rect(4, 47, 21, 1, "#"); l.rect(7, 42, 1, 2, "#"); l.rect(18, 42, 1, 2, "#"); l.rect(7, 48, 1, 5, "#")
for x in (4, 14): l.building(x, 50, 8, 3, "terrace", show_label=False)
l.rect(4, 53, 21, 1, "#")
l.rect(30, 41, 28, 14, "."); l.rect(30, 41, 28, 1, ":")
l.building(31, 43, 7, 3, "cream_render", "Bold Street Books", door=3)
l.rect(31, 46, 8, 1, ":")
l.rect(41, 43, 16, 11, "."); pond(l, 49, 49, 4, 2)
for (cx, cy, rx, ry) in [(44, 45, 3, 2), (55, 46, 2, 2), (43, 52, 3, 1), (55, 53, 3, 1), (36, 51, 3, 2)]:
    ell(l, cx, cy, rx, ry, "d", only=".s")
l.rect(41, 54, 16, 1, "s")
for (x, y) in [(42, 44), (47, 44), (52, 44), (56, 44), (45, 52), (53, 51), (40, 49), (57, 49)]: l.prop("oak", x, y)
l.prop("bench", 48, 46)
l.sign(41, 42, "SEFTON PARK-ISH. Dunes, ducks and a man throwing a ball for a very tired dog.")
l.sign(60, 23, "EAST: Chat Moss and Manchester. Scouse to Manc: 'You're a long way from the sea'.")
l.sign(29, 54, "SOUTH: the Wirral Way and Chester. Mind the tide.")
# NPCs
l.npc(id="kit", sprite="kit", x=30, y=18, facing="left", move="still", script="kit_pier", name="Kit")
l.npc(id="liv_sailor", sprite="sailor", x=20, y=4, facing="down", move="still", script="sailor", name="Sailor")
l.npc(id="liv_birdman", sprite="birdwatcher", x=26, y=16, facing="up", move="still", script="liver_bird_fan", name="Bird Fan")
l.npc(id="liv_beatles", sprite="villager_5", x=34, y=19, facing="up", move="wander", script="beatles_fan", name="Beatles Fan")
l.npc(id="liv_historian", sprite="villager_1", x=50, y=13, facing="down", move="still", script="dock_historian", name="Dock Historian")
l.npc(id="liv_verger", sprite="villager_3", x=44, y=39, facing="up", move="still", script="verger", name="Verger")
l.npc(id="liv_scouser", sprite="villager_2", x=24, y=19, facing="right", move="wander", script="scouser", name="Local")
l.npc(id="liv_ferryfan", sprite="villager_4", x=16, y=9, facing="down", move="wander", script="ferry_fan", name="Ferry Fan")
l.npc(id="rail_guard", sprite="rail_guard", x=8, y=38, facing="down", move="still", script="rail_guard", name="Rail Guard")
say("liverpool", "kit_pier", "Kit", "Hey! Wow, you got here! I'm doing a live stream. Say hi to the viewers. All twelve of them.")
say("liverpool", "sailor", "Sailor", "The ferry to Douglas leaves whenever the tide agrees. Fancy a trip across?")
DLG["liverpool"]["sailor"].append({"do": "ferry", "route": "liverpool_douglas"})
say("liverpool", "rail_guard", "Rail Guard", "Lime Street. Mind the gap. And mind the seagulls.")
DLG["liverpool"]["rail_guard"].append({"do": "rail"})
say("liverpool", "liver_bird_fan", "Bird Fan", "Up on the Liver Building sit two Liver Birds, Bella and Bertie. One looks over the city, one over the sea.", "Legend says if they ever fly away, the city will cease to exist. Don't tell them there's a gull strike.")
say("liverpool", "beatles_fan", "Beatles Fan", "The Beatles played the Cavern Club nearly 300 times between 1961 and 1963. Mostly lunchtimes.", "That's one every other day, nearly. Meanwhile I can't even manage a Tuesday.")
say("liverpool", "dock_historian", "Dock Historian", "Albert Dock opened in 1846. It was the first dock complex in the world built without any wood, so no fires.", "Now it's all museums and tea rooms. Same bricks, fewer rum barrels.")
say("liverpool", "verger", "Verger", "Liverpool Cathedral is the largest cathedral in Britain. Took seventy-four years to build, from 1904.", "The tower's the highest of any cathedral. Do not try to dust it.")
say("liverpool", "scouser", "Local", "Scouse is a stew of beef, veg and spuds. The name comes from 'lobscouse', a sailor's meal.", "We named ourselves after the stew. Not the other way round. Probably.")
say("liverpool", "ferry_fan", "Ferry Fan", "Gerry and the Pacemakers sang 'Ferry Cross the Mersey' in 1964. Everyone on the boat has to hum it. It's the law.", "The ferry's older than the song. And better at turning.")
l.d["encounters"] = {"grass": [
    {"species": "starlet", "min": 18, "max": 20, "weight": 18, "time": ["dawn", "day", "dusk"]},
    {"species": "cooplet", "min": 18, "max": 20, "weight": 20},
    {"species": "chipgull", "min": 18, "max": 20, "weight": 22},
    {"species": "duneskink", "min": 19, "max": 20, "weight": 16, "weather": ["clear", "sunshine"]},
    {"species": "natterjack", "min": 19, "max": 20, "weight": 12, "weather": ["drizzle", "downpour", "gale"]},
    {"species": "grizzlet", "min": 18, "max": 20, "weight": 12, "time": ["dawn", "dusk"]},
    {"species": "binfox", "min": 18, "max": 20, "weight": 14, "time": ["dusk", "night"]},
    {"species": "swiftlet", "min": 19, "max": 20, "weight": 10, "weather": ["gale", "clear"]},
    {"species": "flittermouse", "min": 18, "max": 20, "weight": 8, "time": ["night"]}],
    "water": [
    {"species": "chipgull", "min": 18, "max": 20, "weight": 35},
    {"species": "pinchkin", "min": 18, "max": 20, "weight": 30},
    {"species": "pupplash", "min": 19, "max": 20, "weight": 15},
    {"species": "holtling", "min": 18, "max": 19, "weight": 15}]}
l.d["edges"] = {"east": {"to": "chat_moss", "offset": 0}, "south": {"to": "wirral_way", "offset": 0}}
l.d["spawn"] = [27, 24]
deco(l, 3, 15, 58, 40, ["bush"], 8, 401, on=".")
deco(l, 10, 15, 40, 5, ["planter", "bench", "bollard", "market_stall"], 10, 411, on=":")
deco(l, 3, 31, 22, 8, ["bench", "planter", "bush"], 6, 412, on=".:")
deco(l, 40, 31, 18, 8, ["planter", "bench", "lamp_post"], 6, 413, on=":")
deco(l, 4, 23, 22, 6, ["planter", "bench", "bollard"], 5, 414, on=":")
deco(l, 46, 11, 15, 13, ["bench", "planter"], 4, 415, on=":")
l.save(OUT + "/liverpool.json")

# ---- the club: Keeper Ray's arena ----
cl = interior("liverpool_club", "The Cavern (ish)", 13, 12, 6, "liverpool", cbf[0], cbf[1], music="battle_keeper")
cl.d["stage"] = "city"
cl.rect(1, 1, 11, 10, "|"); cl.rect(3, 1, 7, 3, "+")
cl.rect(1, 1, 2, 1, "C"); cl.rect(10, 1, 2, 1, "C")
for x in (1, 11): cl.prop("bookshelf", x, 5); cl.prop("potted_plant", x, 8)
cl.prop("table", 3, 1); cl.prop("table", 9, 1); cl.prop("lamp_post", 4, 4); cl.prop("lamp_post", 8, 4)
for y in (3, 7): cl.prop("bookshelf", 1, y); cl.prop("bookshelf", 11, y)
cl.prop("table", 3, 9); cl.prop("table", 9, 9); cl.prop("bench", 2, 10); cl.prop("bench", 10, 10)
cl.npc(id="keeper_ray", sprite="keeper_ray", x=6, y=2, facing="down", move="still", script="keeper_ray", name="Keeper Ray")
for t in [("club_lenny", "Mod Lenny", "Busker", "villager_5", [("cooplet", 18), ("grizzlet", 19)], 620, 3, 6, "right",
           ["Oi, oi! You're not on the guest list. Nobody is.", "Hold up. Ray makes you earn the front row."],
           "Alright, you've got moves. Ray's up the front.", "Hear that? That's a tambourine in my chest."),
          ("club_jude", "Student Jude", "Student", "student", [("chipgull", 19), ("starlet", 19), ("swiftlet", 20)], 680, 9, 6, "left",
           ["I'm studying Merseybeat. Nobody told me there'd be fighting.", "Right. Tune up."],
           "Fine, fine. Ray'll sort you out.", "I think the bass drum has opinions about me.")]:
    tid, nm, cls, spr, party, money, x, y, facing, intro, win, after = t
    trainer(tid, nm, cls, spr, party, money, intro, win, after)
    cl.npc(id=tid, sprite=spr, x=x, y=y, facing=facing, move="still", trainer=tid)
cl.save(OUT + "/liverpool_club.json")
say("liverpool_club", "keeper_ray", "Keeper Ray", "Right. You're here for the Urban Stone. Let's see you keep time.")
nurse_and_shop("liverpool",
    ["Hiya, love. Come in. Sit down. Mind the chipped mug.",
     "Hand them over. We'll have them tip-top before you can say 'arr-ite'.",
     "There you go, la. Right as rain. Well, better than rain.",
     "The Ark's over there. Don't put your scouse in it. We've had that.",
     "No worries, la. The tea's on."],
    ["Alright? Scouse by the tin, tea by the bucket and a very nice umbrella.", "See you, la. Mind how you go."])
