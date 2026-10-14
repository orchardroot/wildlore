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
g.rect(25, 13, 6, 1, "_"); g.rect(24, 14, 8, 1, "!")
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
g.d["spawn"] = [27, 18]
g.save(OUT + "/mesh_gallery.json")
