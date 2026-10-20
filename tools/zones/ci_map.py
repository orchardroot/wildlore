# Adds the Channel Islands to data/world_map.json (idempotent): Poole, St Helier, St Peter Port and Sark as towns at their
# real positions in the map's projection, the islands' coasts, the rail from Exeter to Poole, the four ferry routes, and
# a taller map space so Jersey (49.2 N) fits under Cornwall's 1300.
#   python3 tools/zones/ci_map.py data/world_map.json
import json, re, sys
p = sys.argv[1] if len(sys.argv) > 1 else "data/world_map.json"
LON0, LON1, LAT0, LAT1 = -11.0, 2.0, 59.5, 49.8


def pt(lon, lat):
    return [round((lon - LON0) / (LON1 - LON0) * 1000, 1), round((LAT0 - lat) / (LAT0 - LAT1) * 1300, 1)]


def ring(ll):
    out = []
    for (lon, lat) in ll:
        out.extend(pt(lon, lat))
    out.extend(pt(*ll[0]))
    return out


JERSEY = [(-2.255, 49.178), (-2.19, 49.175), (-2.15, 49.18), (-2.105, 49.168), (-2.05, 49.165), (-2.01, 49.185), (-2.02, 49.215),
          (-2.04, 49.24), (-2.10, 49.255), (-2.17, 49.262), (-2.235, 49.255), (-2.26, 49.225)]
GUERNSEY = [(-2.66, 49.43), (-2.60, 49.415), (-2.54, 49.425), (-2.515, 49.445), (-2.52, 49.47), (-2.51, 49.50), (-2.55, 49.505),
            (-2.60, 49.48), (-2.65, 49.47), (-2.675, 49.455)]
SARK = [(-2.37, 49.41), (-2.34, 49.415), (-2.345, 49.45), (-2.375, 49.45)]
ALDERNEY = [(-2.22, 49.70), (-2.17, 49.705), (-2.19, 49.725), (-2.235, 49.72)]

lines = open(p).read().split("\n")
idx = {}
for i, l in enumerate(lines):
    m = re.match(r' "([a-z_]+)": (.*?)(,?)$', l)
    if m:
        idx[m.group(1)] = (i, json.loads(m.group(2)), m.group(3))


def put(key, val):
    i, _, comma = idx[key]
    lines[i] = ' "%s": %s%s' % (key, json.dumps(val, separators=(", ", ": ")), comma)


put("space", [1000, 1420])
towns = idx["towns"][1]
for tid, name, lon, lat, nation, island in [("poole", "Poole", -1.987, 50.715, "england", "gb"),
                                            ("st_helier", "St Helier", -2.107, 49.183, "channel_islands", "jersey"),
                                            ("st_peter_port", "St Peter Port", -2.536, 49.456, "channel_islands", "guernsey"),
                                            ("sark", "Sark", -2.36, 49.433, "channel_islands", "sark")]:
    x, y = pt(lon, lat)
    towns[tid] = {"name": name, "x": round(x), "y": round(y), "nation": nation, "island": island}
put("towns", towns)
places = idx["places"][1]
for pid, lon, lat in [("jersey_country", -2.09, 49.22), ("guernsey_country", -2.58, 49.46)]:
    x, y = pt(lon, lat)
    places[pid] = {"x": round(x), "y": round(y)}
put("places", places)
ferries = idx["ferries"][1]
for pair in (["poole", "st_helier"], ["poole", "st_peter_port"], ["st_helier", "st_peter_port"], ["st_peter_port", "sark"]):
    if pair not in ferries:
        ferries.append(pair)
put("ferries", ferries)
land = idx["land"][1]; coast = idx["coast"][1]
land["channel_islands"] = [ring(JERSEY), ring(GUERNSEY), ring(SARK), ring(ALDERNEY)]
coast["channel_islands"] = list(land["channel_islands"])
put("land", land); put("coast", coast)
rail = idx["rail"][1]
line = [575, 1176, 620, 1170, 660, 1172, 693, 1177]
if line not in rail:
    rail.append(line)
put("rail", rail)
paths = idx["ferry_paths"][1]
paths["poole_st_helier"] = [695, 1183, 702, 1260, 702, 1350, 700, 1392, 690, 1394, 684, 1385]
paths["poole_st_peter_port"] = [695, 1183, 690, 1250, 668, 1306, 655, 1338, 651, 1346]
paths["st_helier_st_peter_port"] = [684, 1388, 668, 1392, 650, 1372, 651, 1346]
paths["st_peter_port_sark"] = [651, 1346, 660, 1353, 665, 1350]
put("ferry_paths", paths)
seas = idx["seas"][1]
if not any(s["name"] == "Gulf of St Malo" for s in seas):
    seas.append({"name": "Gulf of St Malo", "x": 640, "y": 1405})
put("seas", seas)
open(p, "w").write("\n".join(lines))
