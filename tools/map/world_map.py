# Builds data/world_map.json from rough real coordinates (lon, lat). Run: python3 tools/map/world_map.py data/world_map.json
import json, sys
LON0, LON1, LAT0, LAT1 = -11.0, 2.0, 59.5, 49.8
def pt(lon, lat):
    return [round((lon - LON0) / (LON1 - LON0) * 1000), round((LAT0 - lat) / (LAT0 - LAT1) * 1300)]
GB = [(-3.52,58.6),(-3.0,58.64),(-3.1,58.44),(-3.65,58.1),(-4.0,57.87),(-4.2,57.52),(-3.87,57.6),(-2.95,57.68),(-2.0,57.69),(-1.78,57.5),
(-2.08,57.15),(-2.2,56.96),(-2.47,56.7),(-2.58,56.56),(-2.97,56.46),(-2.8,56.34),(-2.58,56.28),(-3.15,56.11),(-3.2,55.98),(-2.52,56.0),
(-2.13,55.9),(-2.0,55.77),(-1.71,55.6),(-1.43,55.0),(-1.37,54.9),(-1.2,54.69),(-0.61,54.49),(-0.4,54.28),(-0.08,54.12),(0.12,53.58),
(0.34,53.14),(0.2,52.9),(0.5,52.95),(1.3,52.93),(1.73,52.6),(1.75,52.47),(1.35,51.96),(1.15,51.79),(0.7,51.54),(1.38,51.39),(1.31,51.13),
(0.97,50.91),(0.57,50.85),(-0.14,50.82),(-1.09,50.79),(-1.88,50.72),(-2.45,50.6),(-2.94,50.72),(-3.4,50.62),(-3.64,50.22),(-4.14,50.37),
(-5.2,49.96),(-5.71,50.07),(-5.48,50.21),(-5.07,50.42),(-4.94,50.54),(-4.55,50.83),(-4.52,51.02),(-4.12,51.21),(-3.47,51.2),(-2.98,51.35),
(-2.65,51.55),(-2.98,51.55),(-3.17,51.46),(-3.27,51.39),(-3.7,51.48),(-3.94,51.6),(-4.33,51.56),(-4.7,51.67),(-4.94,51.6),(-5.15,51.7),
(-5.3,51.9),(-4.98,52.0),(-4.7,52.1),(-4.26,52.24),(-4.08,52.41),(-4.05,52.55),(-4.05,52.72),(-4.11,52.86),(-4.14,52.92),(-4.41,52.89),
(-4.72,52.8),(-4.52,52.95),(-4.28,53.14),(-4.7,53.31),(-4.33,53.42),(-4.09,53.27),(-3.83,53.33),(-3.49,53.32),(-3.32,53.36),(-3.1,53.25),
(-3.18,53.38),(-3.0,53.42),(-3.07,53.56),(-3.0,53.65),(-3.05,53.82),(-3.0,53.93),(-2.87,54.07),(-3.23,54.11),(-3.64,54.49),(-3.57,54.64),
(-3.5,54.71),(-3.2,54.95),(-4.05,54.83),(-4.86,54.64),(-5.03,54.97),(-5.0,55.1),(-4.63,55.46),(-4.87,55.8),(-4.75,55.95),(-5.3,55.85),
(-5.55,55.4),(-5.8,55.3),(-5.6,55.75),(-5.6,56.0),(-5.47,56.41),(-5.85,56.7),(-6.22,56.73),(-5.83,57.0),(-5.71,57.28),(-5.8,57.6),
(-5.7,57.73),(-5.16,57.9),(-5.24,58.15),(-5.0,58.62),(-4.75,58.57)]
IRELAND = [(-7.37,55.38),(-7.0,55.2),(-6.66,55.2),(-6.15,55.23),(-5.8,54.86),(-5.9,54.65),(-5.45,54.5),(-5.55,54.35),(-5.88,54.2),(-6.4,54.0),
(-6.25,53.72),(-6.2,53.35),(-6.03,52.98),(-6.45,52.33),(-6.36,52.17),(-7.0,52.15),(-7.85,51.95),(-8.25,51.8),(-8.5,51.7),(-9.8,51.45),
(-10.45,52.12),(-9.9,52.4),(-9.93,52.56),(-9.43,52.97),(-9.05,53.27),(-10.2,53.4),(-10.2,53.95),(-10.0,54.25),(-9.2,54.25),(-8.6,54.3),
(-8.3,54.6),(-8.8,54.65),(-8.3,55.15)]
MAN = [(-4.36,54.42),(-4.3,54.3),(-4.42,54.15),(-4.65,54.06),(-4.8,54.1),(-4.7,54.25),(-4.5,54.38)]
SKYE = [(-6.3,57.7),(-5.9,57.55),(-5.7,57.25),(-6.0,57.05),(-6.5,57.3),(-6.75,57.45)]
ORKNEY = [(-3.35,59.1),(-2.75,59.1),(-2.6,58.9),(-3.0,58.8),(-3.4,58.9)]
TOWNS = {
 "macclesfield": ("Macclesfield", -2.13, 53.26, "england"), "buxton": ("Buxton", -1.91, 53.26, "england"),
 "manchester": ("Manchester", -2.24, 53.48, "england"), "liverpool": ("Liverpool", -2.99, 53.41, "england"),
 "chester": ("Chester", -2.89, 53.19, "england"), "keswick": ("Keswick", -3.13, 54.6, "england"),
 "lancaster": ("Lancaster", -2.8, 54.05, "england"), "york": ("York", -1.08, 53.96, "england"),
 "whitby": ("Whitby", -0.61, 54.49, "england"), "newcastle": ("Newcastle", -1.61, 54.97, "england"),
 "sheffield": ("Sheffield", -1.47, 53.38, "england"), "nottingham": ("Nottingham", -1.15, 52.95, "england"),
 "birmingham": ("Birmingham", -1.9, 52.49, "england"), "bath": ("Bath", -2.36, 51.38, "england"),
 "glastonbury": ("Glastonbury", -2.72, 51.15, "england"), "penzance": ("Penzance", -5.54, 50.12, "england"),
 "london": ("London", -0.13, 51.51, "england"),
 "llangollen": ("Llangollen", -3.17, 52.97, "wales"), "llanberis": ("Llanberis", -4.13, 53.12, "wales"),
 "aberystwyth": ("Aberystwyth", -4.08, 52.41, "wales"), "st_davids": ("St Davids", -5.27, 51.88, "wales"),
 "cardiff": ("Cardiff", -3.18, 51.48, "wales"),
 "edinburgh": ("Edinburgh", -3.19, 55.95, "scotland"), "glasgow": ("Glasgow", -4.25, 55.86, "scotland"),
 "fort_william": ("Fort William", -5.1, 56.82, "scotland"), "inverness": ("Inverness", -4.22, 57.48, "scotland"),
 "portree": ("Portree", -6.19, 57.41, "scotland"), "aberdeen": ("Aberdeen", -2.1, 57.15, "scotland"),
 "kirkwall": ("Kirkwall", -2.96, 58.98, "scotland"),
 "belfast": ("Belfast", -5.93, 54.6, "northern_ireland"), "bushmills": ("Bushmills", -6.52, 55.2, "northern_ireland"),
 "derry": ("Derry", -7.31, 55.0, "northern_ireland"),
 "dublin": ("Dublin", -6.26, 53.35, "ireland"), "kilkenny": ("Kilkenny", -7.25, 52.65, "ireland"),
 "cork": ("Cork", -8.47, 51.9, "ireland"), "dingle": ("Dingle", -10.27, 52.14, "ireland"),
 "galway": ("Galway", -9.05, 53.27, "ireland"), "sligo": ("Sligo", -8.47, 54.27, "ireland"),
 "newgrange": ("Newgrange", -6.48, 53.69, "ireland"), "douglas": ("Douglas", -4.48, 54.15, "man"),
 "holyhead": ("Holyhead", -4.63, 53.31, "wales"),
}
# routes and landmarks shown as small dots (for Creaturepedia habitats)
PLACES = {
 "macc_forest": (-2.03, 53.24), "cat_and_fiddle": (-1.99, 53.25), "goyt_valley": (-2.02, 53.33), "chat_moss": (-2.6, 53.46),
 "wirral_way": (-3.1, 53.3), "dee_valley": (-3.05, 52.98), "ogwen": (-3.7, 53.12), "yr_wyddfa": (-4.08, 53.07),
 "dinas_emrys": (-4.08, 53.02), "anglesey": (-4.35, 53.25),
 "severn_crossing": (-2.7, 51.6), "mendips": (-2.7, 51.28), "somerset_levels": (-2.85, 51.1), "dartmoor": (-3.9, 50.57),
 "tintagel": (-4.75, 50.67), "wicklow": (-6.35, 53.0), "comeraghs": (-7.6, 52.3), "ring_of_kerry": (-9.8, 51.95),
 "burren": (-9.1, 53.05), "connemara": (-9.8, 53.5), "boyne_valley": (-6.6, 53.7), "cambrian_coast": (-4.06, 52.7), "pembroke_coast": (-4.95, 51.75), "beacons": (-3.44, 51.88),
}
d = {"space": [1000, 1300], "outlines": {"gb": [pt(*p) for p in GB], "ireland": [pt(*p) for p in IRELAND], "man": [pt(*p) for p in MAN],
     "skye": [pt(*p) for p in SKYE], "orkney": [pt(*p) for p in ORKNEY]},
     "towns": {k: {"name": v[0], "x": pt(v[1], v[2])[0], "y": pt(v[1], v[2])[1], "nation": v[3],
                   "island": {"ireland": "ireland", "northern_ireland": "ireland", "man": "man"}.get(v[3], "gb")} for k, v in TOWNS.items()},
     "places": {k: {"x": pt(*v)[0], "y": pt(*v)[1]} for k, v in PLACES.items()},
     "ferries": [["liverpool", "douglas"], ["holyhead", "dublin"]]}
json.dump(d, open(sys.argv[1], "w"), indent=0)
