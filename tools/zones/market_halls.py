#!/usr/bin/env python3
"""Market Halls (3.4, wave 34 B): 25 real covered markets, each a room with a stall-holder who runs the `market`
story command (ui/market_hall_screen.gd), a price board and one fact plaque. Eight halls already had a room
(Leeds, Swansea, Inverness, Cork, Limerick, Oxford, Bristol, Edinburgh's Grassmarket): they get a stall-holder and
a plaque. The other 17 get a new room and a door cut into a doorless building in the town.
Run from the repo root: python3 tools/zones/market_halls.py   (idempotent)"""
import json, os, re

Z = "data/zones/%s.json"
D = "data/dialogue/%s.json"

# id, town, existing room?, name, trader name, sprite, lines (before the board), parting line, plaque title, plaque text
H = [
 ("leeds_kirkgate", "leeds", True, "Kirkgate Market", "Kirkgate Stallholder", "villager_3",
  ["Now then. Fruit, veg, a pound of tripe, a toy knight. Kirkgate sells everything, lad.", "Show us what you've got and I'll tell you what it's worth. Honest."],
  "Mind how you go. And buy something from the bazaar, it keeps the pigeons honest.",
  None, None),
 ("swansea_market", "swansea", True, "Swansea Market", "Market Stallholder", "villager_4",
  ["Hello, cariad! Laverbread, cockles, Welsh cakes still warm. You buying or selling?", "Selling, is it? Let's have a look at the board, then."],
  "Hwyl fawr! Mind the seagulls on the way out. They know a Welsh cake when they see one.",
  "Swansea Market",
  "Swansea Market is the largest indoor market in Wales. The first hall opened in 1897 and the present one went up after the wartime bombing, in 1961. Laverbread and cockles are still sold here."),
 ("inverness_market", "inverness", True, "Victorian Market", "Market Stallholder", "villager_2",
  ["Fit like? Och, no, that's Aberdeen. Welcome to Inverness. Whit can I dae for ye?", "Have a look at the board. Naebody gets fleeced in the Victorian Market. Or only slightly."],
  "Awa ye go, then. Mind the rain. Or the sun. It tends to be one or the other, and fast.",
  "The Victorian Market",
  "Inverness's Victorian Market, off Academy Street, was built in the 1870s. Its covered arcades, with their glass roofs and ironwork, have housed traders for well over a century."),
 ("cork_market", "cork", True, "The English Market", "English Market Trader", "villager_5",
  ["Well, boy! Tripe and drisheen, spiced beef, the best butter in Munster. What have you for me?", "Have a look at the board there. I'll give you a fair price, and a bit of chat for free."],
  "Good luck now. And don't mind the name. It's the oldest market in Cork and it's never been anything but ours.",
  "The English Market",
  "Cork's English Market has traded since 1788 and the covered hall you walk into dates from the 1860s. In 2011 Queen Elizabeth II strolled round it, which the stall-holders still bring up."),
 ("limerick_milkmarket", "limerick", True, "The Milk Market", "Milk Market Trader", "villager_6",
  ["Howya! Cheese, bread, honey, and the odd bit of music. Anything you want to sell?", "Check the board and tell me when you're ready. I'm not going anywhere. It's my pitch."],
  "Good luck now. And try the Saturday crowd if you can. It's an event, not a market.",
  "The Milk Market",
  "Limerick's Milk Market has been trading since 1852. The curved canopy over the square is modern, but the Saturday crowd, the cheese and the bakers are very much the old tradition."),
 ("oxford_market", "oxford", True, "The Covered Market", "Covered Market Trader", "villager_1",
  ["Good morning. Pies, cheese, marmalade, and some excellent gossip about the colleges. How can I help?", "Do take a look at the board. I find students rarely haggle. Tourists never do."],
  "Thank you so much. Mind the Gothic ironwork. Every pigeon in Oxford has an opinion about it.",
  "The Covered Market",
  "Oxford's Covered Market, off the High Street, opened in 1774. It was built to tidy the street stalls away, and it has been selling meat, cheese, pies and flowers ever since."),
 ("bristol_market", "bristol", True, "St Nicholas Market", "St Nicholas Trader", "villager_3",
  ["Alright my lover! Cider, cheese, pasties and a lot of cheek. What you got for me?", "Have a gander at the board. We're not in a hurry. The Nails will wait."],
  "Cheers drive! Tell your friends. Not the ones who owe me money.",
  "St Nicholas Market",
  "Bristol's Corn Exchange, designed by John Wood the Elder and opened in 1743, has the covered St Nicholas Market tucked behind it. The four bronze pillars outside are called the Nails, where merchants once settled their deals."),
 ("edinburgh_grassmarket", "edinburgh", True, "The Grassmarket", "Grassmarket Trader", "villager_5",
  ["Och aye, it's yourself. Wool, tweed, a wee dram if the council isn't looking. What are you selling?", "Have a gander at the board. Prices are fair. The weather is not."],
  "Safe hame. Mind the cobbles, they've seen worse than you.",
  "The Grassmarket",
  "The Grassmarket below Edinburgh Castle has hosted a market since 1477, mostly for livestock. In 1724 Maggie Dickson was hanged here, woke up in her coffin and lived another forty years, which is why they called her Half-Hangit Maggie."),
 ("cardiff_hall", "cardiff", False, "Cardiff Central Market", "Central Market Trader", "villager_4",
  ["Alright, butt? Faggots, laverbread, bara brith. Tidy. What have you got?", "Have a look at the board, now. Fair prices, and a fair roof over our heads."],
  "Ta-ra, then. Mind the stairs up to the balcony. The view's better than the pasties.",
  "Cardiff Central Market",
  "Cardiff Central Market opened in 1891 under a glass and iron roof, between Trinity Street and St Mary Street. It is still a working market, with fishmongers, butchers and a clock hanging over the cafe on the upper level."),
 ("glasgow_hall", "glasgow", False, "The Barras", "Barras Trader", "villager_2",
  ["Awright, pal? Anything and everything, that's the Barras. Whit ye selling?", "Gie's a look at the board. A fair price, and nae patter. Well, a wee bit of patter."],
  "Cheerio, big man. Mind the Gallowgate. It's no' as quiet as it looks.",
  "The Barras",
  "The Barras market in Glasgow's East End began in the 1920s, when Maggie McIver hired out barrows to street traders. The name is from the barrows. Barras is still the plural everyone uses."),
 ("aberdeen_hall", "aberdeen", False, "Aberdeen Market Hall", "Market Hall Trader", "villager_6",
  ["Fit like? Fish, butteries, a bittie of everything. Fit ye got fer me?", "Hae a look at the board. A fair price is a fair price, even in the Granite City."],
  "Tak care, loon. And dinna look at the seagulls. They tak that as encouragement.",
  "Aberdeen Granite",
  "Aberdeen is the Granite City because so much of it is built from local stone. Rubislaw Quarry supplied it for generations and was worked until 1971, by which time it was around 140 metres deep."),
 ("belfast_hall", "belfast", False, "St George's Market", "St George's Trader", "villager_5",
  ["Well, how's about ye? Fish, fruit, soda bread and a fair bit of craic. What are ye selling?", "Have a look at the board there. It's all above board. It's on a board."],
  "Wise up and mind yourself. And if it's a Friday, come back for the variety market.",
  "St George's Market",
  "St George's Market in Belfast is the city's last surviving Victorian covered market. It was built in the 1890s, and its Friday variety market, Saturday food market and Sunday market keep it busy."),
 ("dublin_moorest", "dublin", False, "Moore Street Market", "Moore Street Trader", "villager_4",
  ["Ah, howya! Fresh fruit, flowers, anything you can carry! What have you for me, love?", "Have a gander at the board there. And don't be giving me the sad eyes, I've heard it all."],
  "Good luck now. And mind the pavement. It's older than me, and I'm very old.",
  "Moore Street",
  "Moore Street has been a street market in Dublin for generations, with traders crying their fruit, veg and flowers. In April 1916 the leaders of the Rising retreated from the GPO to number 16 on this street."),
 ("galway_hall", "galway", False, "Galway Market", "Market Trader", "villager_1",
  ["Well now! Cheese, bread, honey, and a breath of sea air for nothing. What're you selling?", "Have a look at the board. We've no fancy hall, only the church wall and the Saturday crowd."],
  "Safe home. And mind the swans. They've no respect for anyone.",
  "Galway Market",
  "Galway Market has traded beside St Nicholas' Collegiate Church for generations, and the Saturday stalls still fill the street. The church itself dates from 1320 and is one of the largest medieval parish churches in Ireland."),
 ("birmingham_hall", "birmingham", False, "The Bull Ring", "Bull Ring Trader", "villager_3",
  ["Alright bab? Fish, fruit, fabric, the lot. What you got for us?", "Have a look at the board. Honest prices. Mostly."],
  "Ta-ra a bit, bab. Mind the bull. The big one outside, I mean.",
  "The Bull Ring",
  "Birmingham has traded in the Bull Ring since 1166, when Peter de Bermingham was granted a market charter by Henry II. Trading has barely stopped since, which makes it one of the oldest market sites in the country."),
 ("norwich_hall", "norwich", False, "Norwich Market", "Norwich Trader", "villager_2",
  ["Hello, bor. Fruit, veg, cheese, a jar of something pickled. Whatcha got for me?", "Have a look at the board. Norwich Market's been here since the Normans. I'd say we've had the practice."],
  "Mind how you go, bor. And look up at the canopies. We're quite proud of them.",
  "Norwich Market",
  "Norwich Market has traded on the same site below the castle since the Normans laid out the new town in the 11th century. It is one of the largest open-air markets in England, under its rows of coloured canopies."),
 ("bath_hall", "bath", False, "Guildhall Market", "Guildhall Market Trader", "villager_4",
  ["Good morning! Buns, bread, a few antiques and the odd Roman coin that isn't. What have you for me?", "Do have a look at the board. We pride ourselves on being fair and on being behind the Guildhall."],
  "Thank you so much. Do pop back. We're always here. It's very small.",
  "Bath Guildhall",
  "Bath's Guildhall was designed by Thomas Baldwin and finished in 1775. The covered Guildhall Market is tucked behind it, a stone's throw from the Pump Room, which is a lot of hot water to be next to."),
 ("carlisle_hall", "carlisle", False, "Carlisle Market Hall", "Market Hall Trader", "villager_6",
  ["Now then. Border pies, Cumberland sausage, a sticky toffee pudding the size of your head. What've you got?", "Have a look at the board. Reivers took what they liked. We pay."],
  "Mind how you go. And watch the Scots. They're lovely, but they've had a long grudge.",
  "Carlisle Market Hall",
  "Carlisle's Market Hall is a Victorian covered market in the heart of the old city, a few steps from the cathedral and the castle. The border town was fought over for centuries and has always known the value of a good stall."),
 ("plymouth_hall", "plymouth", False, "Pannier Market", "Pannier Market Trader", "villager_3",
  ["Alright my lover? Pasties, crab, saffron buns. What you got for me?", "Have a look at the board. It's a pannier, not a pirate ship. Fair prices."],
  "Cheers my 'andsome. Mind the gulls. They're better organised than the council.",
  "The Pannier Market",
  "Plymouth's city centre was flattened in the Blitz of 1941 and rebuilt to a new plan. The Pannier Market, named for the baskets that country traders once carried, is one of the places where the old trading habit survived."),
 ("newcastle_hall", "newcastle", False, "Grainger Market", "Grainger Market Trader", "villager_5",
  ["Howay, pet! Pies, pease pudding, a very large ham. What are you selling?", "Have a look at the board. Grainger built this to last, and to charge."],
  "Haway then. Mind the stairs. And don't mention the Sunderland.",
  "Grainger Market",
  "Grainger Market in Newcastle opened in 1835, built by the developer Richard Grainger as part of a rebuilt city centre. It was among the largest covered markets in Europe at the time, and its Penny Bazaar is still going."),
 ("york_hall", "york", False, "Shambles Market", "Shambles Trader", "villager_4",
  ["Now then. Fresh meat, a good fish, and veg from the Vale. What have you for me?", "Have a look at the board. Butchers have worked here for a thousand years. Never trust a quiet butcher, mind."],
  "Mind how you go, love. And don't lean on the houses. They're leaning enough already.",
  "The Shambles",
  "The Shambles in York is mentioned in the Domesday Book of 1086 as the Great Flesh Shambles. The name comes from the butchers' shelves, and the upper floors of the old houses still lean towards each other over the street."),
 ("cambridge_hall", "cambridge", False, "Cambridge Market", "Market Square Trader", "villager_2",
  ["Morning! Fruit, flowers, cheese and the occasional gown. What are you selling?", "Have a look at the board. Students pay in coins. Tourists pay in photos."],
  "Cheers. Mind the bikes. They have the right of way, and they know it.",
  "Market Hill",
  "Cambridge has held a market on Market Hill for centuries. The stalls still fill the square every day, beneath the same spires, and the market was trading before most of the colleges were built."),
 ("nottingham_hall", "nottingham", False, "Victoria Market", "Victoria Market Trader", "villager_1",
  ["Ey up me duck! Pork pies, plums, a pound of anything. What you got for me?", "Have a look at the board. Honest prices, duck. We've nowt to hide."],
  "Ta-ra, me duck. And watch the lions in the square. They're a bit friendly.",
  "The Old Market Square",
  "Nottingham's Old Market Square is one of the largest public squares in the country and has been the centre of the city's trading for centuries. The two stone lions outside the Council House are where people say they will meet."),
 ("hull_hall", "hull", False, "Trinity Market", "Trinity Market Trader", "villager_6",
  ["Now then, lad. Fish, fruit, patties and bread cakes. What've you got for me?", "Have a look at the board. We're in the shadow of the biggest church in town, so we're honest."],
  "Ta-ra then. Mind the Humber wind. It brings the whole North Sea with it.",
  "Holy Trinity",
  "Hull's Trinity Market stands near Holy Trinity, now Hull Minster, which is generally said to be the largest parish church in England by floor area. The city's trade came in by the Humber and the market grew up beside it."),
 ("macclesfield_hall", "macclesfield", False, "Market Hall", "Market Hall Trader", "villager_3",
  ["Now then, love. Pies, cheese, a bit of silk if you're lucky. What've you got for me?", "Have a look at the board. Mind, it's Macc. We're honest. Mostly."],
  "Tara, love. Don't forget your mum. You know she'll ask.",
  "Macclesfield Market",
  "Macclesfield's cobbled Market Place has hosted markets for centuries, and the Treacle Market there on one Sunday a month has been a regular draw. The town grew rich on silk and still proudly calls itself the silk town."),
]

WALK = set(".:#=sf,")  # tiles outside that are fine to stand on in front of a door

def jread(p):
    with open(p) as f:
        return json.load(f)

def jwrite(p, d):
    with open(p, "w") as f:
        json.dump(d, f, indent=1, ensure_ascii=True)
        f.write("\n")


def append_to(text, key, obj):
    """Add `obj` to the top-level array `key` of a zone file's text, leaving the rest of the file byte for byte."""
    body = json.dumps(obj, indent=1, ensure_ascii=False)
    item = "\n".join("  " + ln for ln in body.split("\n"))
    m = re.search(r'^ "%s": \[(\]?)' % key, text, re.M)
    if m is None:
        raise SystemExit("no array " + key)
    if m.group(1):  # empty: ' "signs": []'
        return text[:m.start()] + ' "%s": [\n%s\n ]' % (key, item) + text[m.end():]
    end = text.index("\n ]", m.end())
    return text[:end] + ",\n" + item + text[end:]

def edit_text(path, fn):
    with open(path) as f:
        t = f.read()
    t = fn(t)
    with open(path, "w") as f:
        f.write(t)

def occupied(z):
    s = set()
    for k in ("npcs", "signs", "props"):
        for e in z.get(k, []):
            s.add((int(e["x"]), int(e["y"])))
    for w in z.get("warps", []):
        s.add((int(w["x"]), int(w["y"])))
    return s

def find_door(z, level=0):
    """A doorless rectangular building with a walkable two-tile approach: (x, y) of its bottom-row centre."""
    rows = z["rows"]
    H_, W_ = len(rows), len(rows[0])
    occ = occupied(z)
    seen = set()
    best = None
    for sy in range(H_):
        for sx in range(W_):
            if rows[sy][sx] != "B" or (sx, sy) in seen:
                continue
            comp, stack = [], [(sx, sy)]
            seen.add((sx, sy))
            while stack:
                x, y = stack.pop()
                comp.append((x, y))
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < W_ and 0 <= ny < H_ and rows[ny][nx] == "B" and (nx, ny) not in seen:
                        seen.add((nx, ny))
                        stack.append((nx, ny))
            xs = [c[0] for c in comp]
            ys = [c[1] for c in comp]
            w, h = max(xs) - min(xs) + 1, max(ys) - min(ys) + 1
            if any(rows[y][x] not in 'BD' for x in range(min(xs), max(xs) + 1) for y in range(min(ys), max(ys) + 1)) or w < (3 if level == 0 else 2) or h < 2:
                continue
            by = max(ys)
            # no door in or touching the building; the row below must not be another building's door row
            cands = [min(xs) + w // 2]
            if level >= 2:
                cands = [x for x in range(min(xs) + (1 if w > 2 else 0), max(xs) + (0 if w > 2 else 1))]
            dx = None
            for c in cands:
                if level < 2 and any(rows[y][x] == "D" for x in range(min(xs) - 1, max(xs) + 2) for y in range(min(ys) - 1, by + 2)
                                     if 0 <= x < W_ and 0 <= y < H_):
                    continue
                if any(rows[y][x] == "D" for x in range(c - 2, c + 3) for y in range(by - 1, by + 2) if 0 <= x < W_ and 0 <= y < H_):
                    continue
                if by + 2 >= H_ or rows[by + 1][c] not in WALK or rows[by + 2][c] not in WALK:
                    continue
                if (c, by + 1) in occ or (c, by) in occ:
                    continue
                dx = c
                break
            if dx is None:
                continue
            score = abs(dx - W_ / 2) + abs(by - H_ / 2)
            if best is None or score < best[0]:
                best = (score, dx, by)
    return best

def new_room(hid, name, town_id, tx, ty, plaque_id, ptitle, ptext, trader, sprite):
    rows = ["x" * 13] + ["x" + "+" * 11 + "x" for _ in range(8)] + ["x" * 13]
    rows[8] = "x+++++D+++++x"
    rows = ["x" * 13] + ["x" + "+" * 11 + "x" for _ in range(7)] + ["x+++++D+++++x", "x" * 13]
    props = [{"type": "market_stall", "x": 2, "y": 2, "variant": 0}, {"type": "market_stall", "x": 4, "y": 2, "variant": 1},
             {"type": "market_stall", "x": 8, "y": 2, "variant": 2}, {"type": "market_stall", "x": 10, "y": 2, "variant": 0},
             {"type": "market_stall", "x": 2, "y": 5, "variant": 1}, {"type": "market_stall", "x": 10, "y": 5, "variant": 2},
             {"type": "bunting", "x": 3, "y": 1, "variant": 1, "walk": True}, {"type": "bunting", "x": 9, "y": 1, "variant": 2, "walk": True},
             {"type": "potted_plant", "x": 1, "y": 7}, {"type": "potted_plant", "x": 11, "y": 7}]
    return {"id": hid, "name": name, "region": "", "kind": "interior", "music": "", "weather": {}, "props": props,
            "warps": [{"x": 6, "y": 8, "to": town_id, "tx": tx, "ty": ty, "facing": "down"}], "edges": {},
            "npcs": [{"id": "hall_stallholder", "sprite": sprite, "x": 6, "y": 4, "facing": "down", "move": "still",
                      "script": "hall_stallholder", "name": trader}],
            "encounters": {},
            "signs": [{"x": 6, "y": 1, "text": ptext, "plaque": plaque_id, "title": ptitle}],
            "spawn": [6, 7], "rows": rows}

def free_tile(z, prefer):
    occ = occupied(z)
    rows = z["rows"]
    for (x, y) in prefer:
        if 0 < y < len(rows) - 1 and 0 < x < len(rows[0]) - 1 and rows[y][x] in "+|" and (x, y) not in occ \
                and (x, y + 1) not in occ:
            return x, y
    raise SystemExit("no free tile in " + z["id"])

def main():
    halls = {}
    for (hid, town, exists, name, trader, sprite, lines, parting, ptitle, ptext) in H:
        # mt_ prefix keeps plaque ids unique and out of the way of the existing ones
        plaque_id = "market_%s" % hid
        halls[hid] = {"name": name, "town": town, "trader": trader}
        if not exists:
            tz = jread(Z % town)
            if not any(w["to"] == hid for w in tz["warps"]):
                spot = find_door(tz) or find_door(tz, 1) or find_door(tz, 2)
                if spot is None:
                    raise SystemExit("no doorway for " + town)
                _, dx, dy = spot
                old = tz["rows"][dy]
                new = old[:dx] + "D" + old[dx + 1:]
                warp = {"x": dx, "y": dy, "to": hid, "tx": 6, "ty": 7, "facing": "up"}
                def door(t, old=old, new=new, warp=warp):
                    i = t.index('"rows": [') + len('"rows": [')
                    lines = t[i:].split("\n")  # lines[0] is the rest of the "rows" line, row n is lines[n + 1]
                    assert lines[dy + 1].strip().rstrip(",") == '"%s"' % old, "row mismatch"
                    lines[dy + 1] = lines[dy + 1].replace(old, new)
                    return append_to(t[:i] + "\n".join(lines), "warps", warp)
                edit_text(Z % town, door)
            else:
                w = [w for w in tz["warps"] if w["to"] == hid][0]
                dx, dy = int(w["x"]), int(w["y"])
            jwrite(Z % hid, new_room(hid, name, town, dx, dy + 1, plaque_id, ptitle, ptext, trader, sprite))
            script = "hall_stallholder"
        else:
            z = jread(Z % hid)
            script = "hall_stallholder"
            if not any(n.get("script") == script for n in z["npcs"]):
                x, y = free_tile(z, [(6, 3), (5, 3), (7, 3), (6, 4), (4, 4), (8, 4), (3, 4), (9, 4), (5, 5), (7, 5), (6, 6)])
                npc = {"id": "hall_stallholder", "sprite": sprite, "x": x, "y": y, "facing": "down", "move": "still",
                       "script": script, "name": trader}
                edit_text(Z % hid, lambda t, npc=npc: append_to(t, "npcs", npc))
            if ptitle and not any(s.get("plaque") for s in z["signs"]):
                x, y = free_tile(z, [(6, 1), (5, 1), (7, 1), (4, 1), (8, 1), (3, 1), (9, 1), (2, 1), (10, 1)])
                sign = {"x": x, "y": y, "text": ptext, "plaque": plaque_id, "title": ptitle}
                edit_text(Z % hid, lambda t, sign=sign: append_to(t, "signs", sign))
        # the dialogue file may already hold other scripts (existing rooms)
        dp = D % hid
        dlg = jread(dp) if os.path.exists(dp) else {}
        seq = [{"do": "say", "who": trader, "text": t} for t in lines]
        seq.append({"do": "market", "hall": hid})
        seq.append({"do": "say", "who": trader, "text": parting})
        dlg[script] = seq
        jwrite(dp, dlg)
    jwrite("data/market_halls.json", {"halls": halls})
    print(len(halls), "halls")

main()
