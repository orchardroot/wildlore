import json, os
R = os.path.expanduser('~/Projects/wildlore/.claude/worktrees/w45-m-borders/art/recipes/creatures/')
shadow = {"shape": "ellipse", "at": [48, 92], "size": [52, 6], "colour": "#2a2a30", "rim": False, "shade": False}
def w(i, d):
    d["id"] = i
    json.dump(d, open(R + i + '.json', 'w'), indent=1)
w("chamelet", {"palette": {"g": "#6fb34a", "g2": "#3f7f34", "band": "#e8d24a", "wood": "#7a5236", "ink": "#1c2018", "eye": "#9fd068", "blush": "#e89a7a"},
 "layers": [shadow,
  {"shape": "line", "points": [[8, 84], [50, 82], [88, 86]], "width": 6, "colour": "wood"},
  {"shape": "line", "points": [[60, 72], [76, 74], [82, 64], [76, 56], [70, 62], [74, 66]], "width": 6, "colour": "g", "pattern": "stripes", "pcolour": "g2", "period": 6, "pangle": 40},
  {"shape": "ellipse", "at": [36, 82], "size": [10, 7], "colour": "g2", "mirror": True},
  {"shape": "ellipse", "at": [48, 66], "size": [42, 30], "colour": "g", "pattern": "speckle", "pcolour": "g2", "density": 10},
  {"shape": "ellipse", "at": [48, 68], "size": [34, 7], "colour": "band", "front_only": True, "rim": False},
  {"shape": "poly", "points": [[36, 44], [48, 22], [60, 44]], "colour": "g2"},
  {"shape": "ellipse", "at": [48, 46], "size": [30, 24], "colour": "g"},
  {"shape": "circle", "at": [36, 47], "r": 7.5, "colour": "g2", "mirror": True}],
 "face_layers": [
  {"shape": "line", "points": [[40, 56], [48, 58], [56, 56]], "width": 1.2, "colour": "ink", "shade": False},
  {"shape": "ellipse", "at": [33, 55], "size": [5, 3], "colour": "blush", "shade": False, "mirror": True}],
 "eyes": [{"at": [36, 47], "r": 4.2, "colour": "eye", "pupil": [2.2, 2.2], "mirror": True}]})
w("chameleer", {"palette": {"g": "#3f9a6a", "g2": "#2a6a5a", "band": "#e88a3a", "band2": "#5aa0d8", "wood": "#6a4630", "leaf": "#4a8a3a", "ink": "#16201a", "eye": "#e8d24a"},
 "layers": [shadow,
  {"shape": "line", "points": [[4, 86], [48, 84], [92, 88]], "width": 7, "colour": "wood"},
  {"shape": "ellipse", "at": [84, 84], "size": [12, 6], "colour": "leaf", "angle": -20},
  {"shape": "line", "points": [[62, 70], [82, 74], [90, 60], [84, 48], [74, 52], [76, 60], [82, 58]], "width": 8, "colour": "g", "pattern": "stripes", "pcolour": "g2", "period": 7, "pangle": 40},
  {"shape": "ellipse", "at": [34, 83], "size": [12, 8], "colour": "g2", "mirror": True},
  {"shape": "ellipse", "at": [48, 64], "size": [52, 36], "colour": "g", "pattern": "speckle", "pcolour": "g2", "density": 12},
  {"shape": "ellipse", "at": [48, 60], "size": [44, 7], "colour": "band", "front_only": True, "rim": False},
  {"shape": "ellipse", "at": [48, 70], "size": [40, 6], "colour": "band2", "front_only": True, "rim": False},
  {"shape": "poly", "points": [[32, 40], [48, 8], [64, 40]], "colour": "g2"},
  {"shape": "poly", "points": [[40, 34], [48, 16], [56, 34]], "colour": "band", "front_only": True, "rim": False},
  {"shape": "ellipse", "at": [48, 42], "size": [36, 28], "colour": "g"},
  {"shape": "circle", "at": [33, 43], "r": 9, "colour": "g2", "mirror": True}],
 "face_layers": [
  {"shape": "line", "points": [[38, 54], [48, 57], [58, 54]], "width": 1.4, "colour": "ink", "shade": False}],
 "eyes": [{"at": [33, 43], "r": 5, "colour": "eye", "pupil": [2.4, 2.4], "mirror": True}]})
w("agrino", {"palette": {"coat": "#a2552e", "coat2": "#7a3a20", "cream": "#efe4cc", "dark": "#3a2a22", "horn": "#8a7a62", "horn2": "#5e5242", "hoof": "#2a2420", "ink": "#1a1410"},
 "layers": [shadow,
  {"shape": "rect", "at": [34, 76], "size": [6, 18], "colour": "coat2", "round": 2, "mirror": True},
  {"shape": "rect", "at": [34, 91], "size": [7, 3], "colour": "hoof", "round": 1, "mirror": True},
  {"shape": "ellipse", "at": [48, 64], "size": [50, 30], "colour": "coat"},
  {"shape": "ellipse", "at": [27, 60], "size": [9, 11], "colour": "cream", "mirror": True, "front_only": True, "rim": False},
  {"shape": "ellipse", "at": [48, 74], "size": [32, 9], "colour": "cream", "rim": False},
  {"shape": "ellipse", "at": [48, 54], "size": [24, 24], "colour": "dark"},
  {"shape": "ellipse", "at": [35, 32], "size": [10, 5], "colour": "coat2", "angle": -20, "mirror": True},
  {"shape": "ellipse", "at": [48, 38], "size": [20, 26], "colour": "coat"},
  {"shape": "ellipse", "at": [48, 47], "size": [12, 9], "colour": "cream", "front_only": True, "rim": False},
  {"shape": "line", "points": [[43, 28], [34, 18], [22, 20], [17, 32], [22, 44], [30, 46]], "width": 6.5, "colour": "horn", "pattern": "stripes", "pcolour": "horn2", "period": 4, "pangle": 0, "mirror": True}],
 "face_layers": [
  {"shape": "ellipse", "at": [45, 48], "size": [2, 1.6], "colour": "ink", "shade": False, "mirror": True},
  {"shape": "line", "points": [[45, 51], [48, 52], [51, 51]], "width": 1, "colour": "ink", "shade": False}],
 "eyes": [{"at": [42, 37], "r": 2.6, "colour": "#d8a040", "pupil": [2.6, 1.0], "mirror": True}]})
