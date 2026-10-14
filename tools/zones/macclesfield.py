import sys; sys.path.insert(0, sys.argv[1]); from zlib import Z
OUT = sys.argv[2]
z = Z("macclesfield", "Macclesfield", 52, 38, music="town_cheshire")
z.border("T", 3, gaps=[(49, 18, 3, 3)])
z.scatter(0, 0, 52, 38, "P", 60, 3, only="T")
# main road east-west with pavements, out to the forest gap
z.rect(3, 19, 49, 1, ":"); z.rect(3, 20, 49, 1, "="); z.rect(3, 21, 46, 1, ":")
# market place
z.rect(17, 11, 19, 8, ":")
z.building(19, 7, 6, 4, "sanctuary", "Sanctuary", door=3)
z.building(28, 7, 5, 4, "shop", "Corner Shop", door=2)
z.building(36, 23, 8, 4, "stone", "Town Hall")
z.rect(36, 27, 8, 1, ":")
z.rect(17, 11, 1, 1, ":")
z.prop("bench", 20, 14); z.prop("bench", 31, 14); z.prop("lamp_post", 18, 12); z.prop("lamp_post", 34, 12)
z.prop("lamp_post", 18, 18); z.prop("lamp_post", 34, 18)
z.rect(25, 14, 3, 2, "f")
for x in (21, 23, 29, 31): z.prop("market_stall", x, 16, variant=x % 3)
z.prop("planter", 17, 15); z.prop("planter", 35, 15); z.prop("phone_box", 26, 11); z.prop("post_box", 27, 18)
# more houses along the north side, with gardens
z.building(13, 7, 5, 4, "red_brick", show_label=False)
z.building(34, 6, 3, 4, "cream_render", show_label=False)
z.rect(13, 11, 4, 1, "f")
# trees and greens inside town
for (x, y) in [(3, 17), (12, 14), (15, 15), (36, 18), (47, 25), (27, 24), (31, 25), (45, 9), (15, 3)]:
    z.prop("oak", x, y, variant=(x + y) % 3)
z.rect(44, 23, 5, 4, "."); z.prop("bench", 45, 24)
z.rect(23, 23, 11, 4, ".")
z.building(28, 23, 4, 3, "red_brick", show_label=False)
# home, garden and hedge
z.building(6, 7, 5, 4, "cream_render", "Home", door=2)
z.rect(5, 11, 7, 1, "#"); z.rect(8, 12, 1, 7, "#")
z.rect(4, 13, 3, 3, "f"); z.rect(11, 6, 1, 6, "H"); z.rect(4, 6, 8, 1, "H")
# terraces south of the road
z.building(5, 23, 5, 3, "red_brick", show_label=False)
z.building(11, 23, 5, 3, "red_brick", show_label=False)
z.building(17, 23, 4, 3, "red_brick", show_label=False)
z.rect(4, 26, 18, 1, "#")
# River Bollin with a ford, silk mill on the far bank
z.rect(3, 29, 46, 2, "~"); z.rect(24, 29, 2, 2, "w"); z.rect(24, 22, 2, 7, "#")
z.rect(3, 28, 46, 1, "s"); z.rect(24, 28, 2, 1, "#")
z.building(29, 31, 13, 4, "red_brick", "Paradise Mill")
z.rect(24, 31, 2, 4, "#")
z.scatter(3, 31, 24, 4, "f", 18, 9)
# St Michael's on its plateau, up the 108 Steps
z.height(38, 3, 11, 7, 2); z.rect(38, 3, 11, 7, ".")
z.building(41, 4, 6, 4, "stone", "St Michael's")
z.rect(40, 9, 2, 1, "#"); z.height(40, 10, 2, 1, 1); z.rect(40, 10, 2, 1, "#"); z.rect(40, 11, 2, 1, "#")
z.rect(39, 9, 1, 1, "R"); z.rect(47, 8, 1, 1, "R"); z.rect(38, 5, 1, 1, "R"); z.rect(48, 4, 1, 1, "R")
z.sign(42, 11, "THE 108 STEPS. There are not 108 of them. Count them if you like, we'll wait.")
# Field Station, east end of town
z.building(44, 13, 5, 4, "white_render", "Field Station", door=2)
z.rect(46, 17, 1, 2, "#")
z.prop("lamp_post", 43, 18)
z.sign(47, 22, "MACCLESFIELD. Silk town. Mind the hills. East: Macclesfield Forest.")
z.sign(16, 18, "MARKET PLACE. Market on Tuesdays. Pigeons every day.")
z.scatter(4, 32, 20, 3, ".", 1, 1)
for x in (6, 14, 30, 38): z.prop("lamp_post", x, 22)
# doors
z.warp(8, 10, "macc_home", 4, 5, "up"); z.warp(22, 10, "macc_sanctuary", 5, 6, "up")
z.warp(30, 10, "macc_shop", 4, 5, "up"); z.warp(46, 16, "macc_fieldstation", 5, 6, "up")
z.d["edges"] = {"east": {"to": "macc_forest", "offset": 0}}
z.d["spawn"] = [8, 11]
z.save(OUT + "/macclesfield.json")

def interior(zid, name, w, h, door_x, out_zone, ox, oy, counters=(), music="town_cheshire"):
    r = Z(zid, name, w, h, fill="|", kind="interior", music=music, weather={})
    r.border("x", 1)
    r.set(door_x, h - 2, "D")
    for (x, y, ww) in counters: r.rect(x, y, ww, 1, "C")
    r.warp(door_x, h - 2, out_zone, ox, oy, "down")
    r.d["spawn"] = [door_x, h - 3]
    return r
home = interior("macc_home", "Home", 9, 8, 4, "macclesfield", 8, 11, counters=[(2, 2, 2), (6, 2, 1)])
home.rect(2, 5, 1, 1, "+"); home.rect(6, 4, 2, 1, "+")
home.save(OUT + "/macc_home.json")
s = interior("macc_sanctuary", "Macclesfield Sanctuary", 11, 9, 5, "macclesfield", 22, 11, counters=[(3, 3, 5)], music="sanctuary")
s.rect(1, 6, 2, 1, "+"); s.rect(8, 6, 2, 1, "+"); s.save(OUT + "/macc_sanctuary.json")
sh = interior("macc_shop", "Corner Shop", 9, 8, 4, "macclesfield", 30, 11, counters=[(2, 2, 3)])
sh.rect(6, 2, 2, 3, "C"); sh.save(OUT + "/macc_shop.json")
f = interior("macc_fieldstation", "Field Station", 11, 9, 5, "macclesfield", 46, 17, counters=[(2, 2, 3), (6, 2, 3), (2, 5, 1), (8, 5, 1)])
f.save(OUT + "/macc_fieldstation.json")
