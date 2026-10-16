"""Landmark interiors for Liverpool and Douglas doors. Usage: python3 tools/zones/landmarks_lpool.py data/zones"""
import json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from zlib import landmark

out = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
dlg = "data/dialogue"

# town, short, door (x, y), label, kind, sprite, speaker, lines
L = [
 ("liverpool", "warehouse", (50, 12), "Albert Dock Warehouse", "mill", "villager_3", "Dock Warden", [
   "Mind the pillars. They're cast iron, and they've been holding this roof up since 1846.",
   "The Albert Dock warehouses were the first in Britain built with no wood in the structure at all.",
   "Iron, brick and stone, so a fire couldn't take the lot. Very sensible. Very Victorian."]),
 ("liverpool", "maritime", (57, 12), "Maritime Museum", "museum", "sailor", "Curator", [
   "Welcome aboard! Well, ashore. Mind the model ships, they're older than your nan.",
   "Fun fact: the Titanic was registered in Liverpool. 'LIVERPOOL' is painted right across her stern.",
   "She never actually sailed from here, mind. Sailed from Southampton, sank in the Atlantic."]),
 ("liverpool", "cunard", (17, 14), "Cunard Building", "hall", "tour_guide", "Guide", [
   "This is the Cunard Building. Finished in 1916 for the shipping line, and it looks like a palace.",
   "It's one of the Three Graces on the Pier Head, along with the Liver and Port of Liverpool buildings.",
   "Italian Renaissance style, if you want to sound clever at parties."]),
 ("liverpool", "liver", (28, 14), "Royal Liver Building", "hall", "tour_guide", "Guide", [
   "Up top there are two Liver Birds, Bella and Bertie. Bella looks out to sea, Bertie watches the city.",
   "Legend says if they ever fly away, Liverpool will cease to exist. So we keep them well fed.",
   "The clock faces are 25 feet across, bigger than Big Ben's. We don't brag. Much."]),
 ("liverpool", "portbuilding", (38, 14), "Port of Liverpool Building", "hall", "commuter", "Clerk", [
   "Finished in 1907 for the Mersey Docks and Harbour Board. Yes, it has a dome. We like a dome.",
   "It was the first of the Three Graces to go up, so the other two had to try rather hard.",
   "If you ever want to know how much a ship is allowed to weigh, I am your person."]),
 ("liverpool", "tate", (49, 26), "Albert Dock South", "museum", "student", "Gallery Assistant", [
   "Welcome to the gallery in the old dock warehouse. Tate Liverpool opened here in 1988.",
   "It's the national collection of modern art, up north. London doesn't get to keep all of it.",
   "That statue? Don't ask me. I just stand next to it and look thoughtful."]),
 ("liverpool", "beatles", (57, 26), "The Beatles Story", "museum", "festival_goer", "Fab Fan", [
   "Yeah yeah yeah! The Beatles Story opened on the Albert Dock in 1990.",
   "They played the Cavern Club on Mathew Street hundreds of times before anyone outside Liverpool cared.",
   "Lunchtime sessions, too. Imagine popping out for a sandwich and getting John, Paul, George and Ringo."]),
 ("liverpool", "cathedral", (46, 36), "Liverpool Cathedral", "church", "keeper_hester", "Verger", [
   "Welcome to the largest cathedral in Britain. Do mind the echo, it likes to answer back.",
   "It took 74 years to build, from 1904 to 1978. Giles Gilbert Scott designed it, aged just 22 when he won.",
   "He also designed the red telephone box. Cathedral, phone box. Quite the range."]),
 ("liverpool", "bold", (34, 45), "Bold Street Books", "library", "poet", "Bookseller", [
   "Bold Street has been Liverpool's posh shopping street since the 1800s. Now it's independents and oat milk.",
   "It's named after a local merchant, Jonas Bold. Nice to be remembered for a road.",
   "Browse as long as you like. Just don't crease the spines, I will know."]),
 ("douglas", "gaiety", (29, 17), "Gaiety Theatre", "theatre", "ceilidh_caller", "Stage Manager", [
   "Shh, we're between shows. Well, shh-ish. This is the Gaiety Theatre.",
   "It opened in 1900 and was designed by Frank Matcham, the man behind half the great theatres in Britain.",
   "Red velvet, gold plaster, and a ghost or two, depending who you ask."]),
 ("douglas", "tramdepot", (29, 29), "Horse Tram Depot", "mill", "farmer", "Tram Driver", [
   "Douglas Bay Horse Tramway opened in 1876, and it's still going. Horse power, quite literally.",
   "It's the oldest surviving horse tramway in the world, so we're rather proud of it.",
   "The horses get a rest in the afternoon. The timetable does not, I'm afraid."]),
 ("douglas", "kippers", (38, 30), "Manx Kipper Shop", "cafe", "fisher", "Fishmonger", [
   "Manx kippers! Herring split, salted and smoked over oak, no dye needed.",
   "Peel, on the west coast, is the place for them. Moore's smokehouse there has been at it since 1882.",
   "Best with a poached egg. Do not stand downwind of the smoker. Trust me on that."]),
]
NPCPOS = {"mill": (6, 3), "museum": (5, 4), "hall": (6, 2), "church": (6, 3), "library": (6, 3),
          "theatre": (6, 3), "cafe": (6, 3)}

for town, short, (dx_, dy_), label, kind, spr, who, lines in L:
    zid = f"{town}_{short}"
    x, y = NPCPOS[kind]
    npc = dict(id="keeper", sprite=spr, x=x, y=y, facing="down", move="still", script="keeper")
    landmark(out, zid, label, town, (dx_, dy_ + 1), kind, [npc])
    script = {"keeper": [{"do": "say", "who": who, "text": t} for t in lines]}
    with open(f"{dlg}/{zid}.json", "w") as f:
        json.dump(script, f, indent=1, ensure_ascii=False)
    p = f"{out}/{town}.json"
    d = json.load(open(p))
    if not any(w["x"] == dx_ and w["y"] == dy_ for w in d["warps"]):
        d["warps"].append({"x": dx_, "y": dy_, "to": zid, "tx": 6, "ty": 7, "facing": "up"})
        with open(p, "w") as f:
            json.dump(d, f, indent=1, ensure_ascii=False)
