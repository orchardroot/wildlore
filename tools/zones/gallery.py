# Dev-only zone showing every M2 mesh: python3 tools/zones/gallery.py tools/zones data/zones
import sys; sys.path.insert(0, sys.argv[1]); from zlib import Z
OUT = sys.argv[2]
g = Z("mesh_gallery", "Mesh Gallery", 56, 34, kind="town", region="dev")
g.border("T", 1)
g.rect(1, 16, 54, 1, "=")
g.building(3, 3, 8, 4, "mill", "Mill", door=3)
g.building(13, 4, 8, 3, "terrace", "Terrace", door=2)
g.building(23, 4, 5, 3, "tudor", "Tudor", door=2)
g.building(30, 4, 4, 3, "slate_cottage", "Cottage", door=1)
g.building(36, 3, 4, 4, "chapel", "Capel", door=1)
g.building(42, 3, 10, 8, "castle", "Castle", door=4)
g.building(3, 10, 9, 4, "cathedral", "Cathedral", door=4)
g.building(14, 10, 9, 4, "liver_building", "Liver Building", door=4)
g.building(25, 11, 6, 2, "station", "Station", door=2)
g.rect(25, 13, 6, 1, "_"); g.rect(24, 14, 11, 1, "!")
# a second line running north-south through a level crossing on the road, tunnel mouths at the ends of both lines
g.rect(38, 8, 1, 12, "!"); g.set(38, 16, "&")
# a river under the aqueduct, a sea corner, bramble, scree
g.rect(3, 20, 14, 3, "~")
g.building(3, 18, 14, 2, "aqueduct", show_label=False)
g.prop("canal_boat", 8, 21, variant=1)
g.rect(30, 22, 25, 11, "$"); g.rect(30, 20, 25, 2, "s")
g.prop("boat", 40, 26); g.prop("buoy", 34, 24); g.prop("buoy", 48, 24, variant=1)
g.prop("lighthouse", 52, 21)
g.rect(20, 20, 6, 3, "%"); g.rect(20, 24, 6, 3, "/"); g.rect(3, 25, 10, 4, "o")
for i, x in enumerate([14, 16, 18]):
    g.prop("standing_stone", x, 28, variant=i)
g.prop("slate_heap", 22, 29); g.prop("slate_heap", 24, 29, variant=1)
g.prop("statue", 27, 17); g.prop("harp", 29, 17); g.prop("bollard", 31, 19); g.prop("bollard", 33, 19)
g.prop("buffer_stop", 24, 14); g.prop("tunnel_portal", 34, 14); g.prop("tunnel_portal", 38, 8); g.prop("tunnel_portal", 38, 19, variant=1)
# immersion dressing: lamps, bunting, flags, and a row of furnishings (walk = whether you can step on it)
g.prop("lamp_post", 3, 29); g.prop("lamp_post", 8, 29)
g.prop("bunting", 3, 29, variant=5, walk=True); g.prop("hanging_basket", 8, 29, walk=True); g.prop("washing_line", 11, 29, variant=3, walk=True)
for i in range(7):
    g.prop("flagpole", 16 + 2 * i, 30, variant=i)
for i, (t, walk) in enumerate([("rug", True), ("fireplace", False), ("wall_picture", True), ("clock", True), ("kitchen_dresser", False),
                               ("fryer", False), ("menu_board", True), ("piano", False), ("telescope", False), ("plant_stand", False),
                               ("sofa", False), ("display_case", False)]):
    g.prop(t, 3 + 2 * i, 31, walk=walk)
g.d["spawn"] = [27, 18]
g.save(OUT + "/mesh_gallery.json")
