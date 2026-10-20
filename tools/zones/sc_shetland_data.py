# Shetland data that is not a zone: items, shop, quests, quiz, the Kirkwall ferry, the world map entries, Kirkwall's
# quay hand, habitats and the Up Helly Aa festival. Safe to re-run (every edit checks it hasn't been made already).
# Usage: python3 tools/zones/sc_shetland_data.py     (from the repo root)
import json, re

ROOT = "."


def rd(p):
    return open(ROOT + "/" + p, encoding="utf-8").read()


def wr(p, t):
    open(ROOT + "/" + p, "w", encoding="utf-8").write(t)


# ---------------------------------------------------------------- items, shop
ITEMS = [
    {"id": "reestit_mutton_soup", "name": "Reestit Mutton Soup", "kind": "heal", "price": 280, "battle": True, "field": True, "amount": 120,
     "desc": "Shetland's winter soup: mutton salted and hung to dry in the rafters (reested), then simmered with tatties and neeps. Salty, deep and warming. Restores 120 HP and puts colour in your cheeks."},
    {"id": "shetland_bannock", "name": "Shetland Bannock", "kind": "heal", "price": 190, "battle": True, "field": True, "amount": 95,
     "desc": "A soft, round loaf baked on a girdle, good with butter and jam, and with a cup of tea in a gale. Restores 95 HP and keeps the draught out."},
    {"id": "fair_isle_tammy", "name": "Fair Isle Tammy", "kind": "charm", "price": 3500, "battle": False, "field": True, "wild": True,
     "desc": "A knitted tammy in Fair Isle bands: crosses, stars and snowflakes, never more than two colours in a row. It has a bobble. The wind has opinions about bobbles.",
     "effect_text": "Gale moves hurt it 25% less.", "charm": {"effect": "resist", "type": "gale", "mult": 0.75}, "msg": "{name}'s Fair Isle Tammy kept the wind off!"},
    {"id": "jarlshof_whorl", "name": "Jarlshof Spindle Whorl", "kind": "charm", "price": 0, "battle": False, "field": True, "wild": False,
     "desc": "A copy of a carved stone spindle whorl, the flywheel of a hand spindle, like those found at Jarlshof, where people spun wool for four thousand years. A flat stone with a hole in it. Lucky, if you believe that sort of thing.",
     "effect_text": "Stone moves hit 20% harder.", "charm": {"effect": "boost", "type": "stone", "mult": 1.2}, "msg": "{name}'s Jarlshof Spindle Whorl spun steadily!"},
    {"id": "pony_rosette", "name": "Pony Show Rosette", "kind": "charm", "price": 0, "battle": False, "field": True, "wild": False,
     "desc": "A red rosette from the Mainland pony show, with 'ADEQUATE' written on the back in a judge's handwriting, which from him is gold.",
     "effect_text": "Kin moves hit 20% harder.", "charm": {"effect": "boost", "type": "kin", "mult": 1.2}, "msg": "{name}'s Pony Show Rosette stood up square!"},
]


def items_and_shop():
    wr("data/items/shetland.json", "[\n" + ",\n".join("  " + json.dumps(i, ensure_ascii=False) for i in ITEMS) + "\n]\n")
    stock = json.loads(rd("data/shops/stornoway_corner_shop.json"))["stock"]
    stock = [s for s in stock if s not in ("stornoway_black_pudding", "bere_bannock")] + ["reestit_mutton_soup", "shetland_bannock", "fair_isle_tammy"]
    wr("data/shops/lerwick_corner_shop.json", json.dumps({"id": "lerwick_corner_shop", "name": "Lerwick Corner Shop", "stock": stock}) + "\n")
    # the festival souvenir
    f = rd("data/items/festivals.json")
    if "fest_galley_torch" not in f:
        item = {"id": "fest_galley_torch", "name": "Guizer's Torch", "kind": "key", "price": 0, "battle": False, "field": True,
                "desc": "A burnt-out torch from Up Helly Aa in Lerwick, still smelling of paraffin and triumph. A thousand of them go into the galley in a few minutes, and this one came back."}
        i = f.rstrip().rfind("]")
        wr("data/items/festivals.json", f[:i].rstrip() + ",\n  " + json.dumps(item, ensure_ascii=False) + "\n]\n")


# ---------------------------------------------------------------- quests
def quests():
    q = [
        {"id": "shetland_survey", "title": "The South Mainland Survey", "region": "shetland", "town": "lerwick", "giver": "Curator Ingrid",
         "summary": "The Shetland Museum wants a visitor's survey of the road south: an archaeologist, a lighthouse and a Puffling.",
         "start_flag": "q_shetland_survey_started",
         "steps": [
             {"flag": "q_shetland_survey_1", "text": "Take the road south and answer the archaeologist's question at Jarlshof.", "zone": "shetland_mainland"},
             {"flag": "q_shetland_survey_2", "text": "Show the warden at Sumburgh Head a Puffling for the cliff records.", "zone": "shetland_mainland"},
             {"flag": "q_shetland_survey_3", "text": "Report back to Curator Ingrid at the Shetland Museum.", "zone": "lerwick_museum"}],
         "done_flag": "q_shetland_survey_done", "reward": "A Jarlshof Spindle Whorl (a charm: stone moves hit harder) and standing in Scotland."},
        {"id": "shetland_ponies", "title": "The Peerie Pony Show", "region": "shetland", "town": "shetland_mainland", "giver": "Gudrun the Breeder",
         "summary": "Gudrun's pony show needs a Foalmoor, and a team that can win over a very strict judge.",
         "start_flag": "q_shetland_ponies_started",
         "steps": [
             {"flag": "q_shetland_ponies_1", "text": "Catch a Foalmoor on the heath and show Gudrun the Breeder.", "zone": "shetland_mainland"},
             {"flag": "q_shetland_ponies_2", "text": "Beat the Show Judge at the pony field gate.", "zone": "shetland_mainland"}],
         "done_flag": "q_shetland_ponies_done", "reward": "A Pony Show Rosette (a charm: kin moves hit harder), the judge's purse and standing in Scotland."}]
    t = "{\"quests\": [\n" + ",\n".join(" " + json.dumps(x, ensure_ascii=False) for x in q)
    wr("data/quests/shetland.json", t + "\n]}\n")


# ---------------------------------------------------------------- quiz
QUIZ = [
    ("culture", "On which day is Up Helly Aa held in Lerwick?", "The last Tuesday of January", ["New Year's Day", "Midsummer's Eve", "The first Monday in May"], "Around a thousand guizers march with torches and burn a replica Viking longship."),
    ("history", "In which year did Shetland pass from Norway to Scotland?", "1469", ["1066", "1314", "1707"], "It was pledged as part of the dowry of Margaret of Denmark, who married James III."),
    ("culture", "What is a 'lodberry' in Lerwick?", "A stone house or store with its own landing place", ["A kind of fishing net", "A type of berry", "A Viking helmet"], "The old merchants' lodberries stand at the water's edge on Commercial Street."),
    ("nature", "Which small, sturdy horse breed comes from Shetland?", "The Shetland pony", ["The Exmoor pony", "The Highland garron", "The Connemara"], "It is tough as boots, and was used to haul peat and coal."),
    ("history", "What was the 'Shetland Bus'?", "A secret boat service to occupied Norway in the Second World War", ["A bus route to Sumburgh", "A fishing fleet", "A ferry to Fair Isle"], "Norwegian fishermen carried agents, radios and refugees across the North Sea in winter."),
    ("culture", "Shetland's name for the northern lights is...", "Mirrie dancers", ["Sky fires", "Odin's lamps", "Frost drifts"], "The merry dancers ripple green across the sky in winter."),
    ("history", "Which site near Sumburgh, named in a Walter Scott novel, was lived in for about four thousand years?", "Jarlshof", ["Skara Brae", "Maeshowe", "Broch of Gurness"], "The name comes from 'The Pirate' of 1822; people lived at the site for about four thousand years."),
    ("nature", "Which seabird nests on Sumburgh Head from May to August?", "The puffin", ["The penguin", "The ptarmigan", "The pelican"], "Puffins nest in burrows on the clifftops, then spend the winter out at sea."),
]


def quiz():
    t = rd("data/quiz/questions.json")
    if "Up Helly Aa held in Lerwick" in t:
        return
    add = ""
    for (cat, q, a, wrong, fact) in QUIZ:
        add += ",\n\t" + json.dumps({"cat": cat, "region": "scotland", "q": q, "a": a, "wrong": wrong, "fact": fact}, ensure_ascii=False)
    i = t.rstrip().rfind("]")
    wr("data/quiz/questions.json", t[:i].rstrip() + add + "\n]\n")


# ---------------------------------------------------------------- ferry, map, Kirkwall's quay, habitats
def _array_end(text, key):
    """index just past the matching ] of `"key": [` (first occurrence at or after the start of `text`)."""
    s = text.index(key)
    i = text.index("[", s)
    depth = 0
    for j in range(i, len(text)):
        if text[j] == "[":
            depth += 1
        elif text[j] == "]":
            depth -= 1
            if depth == 0:
                return j
    raise ValueError(key)


RING = [694, 6, 699, 10, 698, 16, 702, 22, 700, 28, 703, 34, 699, 40, 701, 47, 697, 52, 693, 46, 695, 40, 690, 34, 693, 28, 689, 22, 692, 16, 690, 10]


def ferry_and_map():
    t = rd("data/ferries.json")
    if "kirkwall_lerwick" not in t:
        entry = {"a": "kirkwall", "b": "lerwick", "ship": "the Hjaltland", "music": "ferry_north_channel",
                 "card": "Out of Kirkwall at dusk and north-east across the open sea. A long, dark swell, a fulmar keeping pace at the rail, and by morning a low green shore with a town of stone houses at the water's edge: Lerwick."}
        i = t.rstrip().rfind("}")
        wr("data/ferries.json", t[:i].rstrip() + ',\n "kirkwall_lerwick": ' + json.dumps(entry, ensure_ascii=False) + "\n}\n")
    m = rd("data/world_map.json")
    if '"lerwick"' not in m:
        k = re.search(r'"kirkwall": \{[^}]*\}', m)
        m = m[:k.end()] + ', "lerwick": {"name": "Lerwick", "x": 698, "y": 33, "nation": "scotland", "island": "shetland"}' + m[k.end():]
        pl = re.search(r'"places": \{', m)
        m = m[:pl.end()] + '"shetland_mainland": {"x": 696, "y": 47}, ' + m[pl.end():]
        fe = _array_end(m, '"ferries"')
        m = m[:fe] + ', ["kirkwall", "lerwick"]' + m[fe:]
        fp = re.search(r'"thurso_kirkwall": \[[^\]]*\]', m)
        m = m[:fp.end()] + ', "kirkwall_lerwick": [618.5, 69.7, 640.0, 66.0, 662.0, 58.0, 681.0, 45.0, 698.0, 33.0]' + m[fp.end():]
        for key in ('"land"', '"coast"'):
            s = m.index(key)
            e = _array_end(m[s:], '"scotland"') + s
            m = m[:e] + ", " + json.dumps([float(v) for v in RING]) + m[e:]
        wr("data/world_map.json", m)
    # Kirkwall's quay: a hand for the Lerwick boat
    z = rd("data/zones/kirkwall.json")
    if "kwl_lerwick_hand" not in z:
        anchor = re.search(r'\{\s*"id": "kwl_sailor",[^}]*\}', z)
        assert anchor
        new = ('{\n   "id": "kwl_lerwick_hand",\n   "sprite": "sailor",\n   "x": 44,\n   "y": 5,\n   "facing": "right",\n   "move": "still",\n'
               '   "script": "kwl_lerwick_hand",\n   "name": "Lerwick Hand"\n  }')
        z = z[:anchor.end()] + ",\n  " + new + z[anchor.end():]
        wr("data/zones/kirkwall.json", z)
        d = json.loads(rd("data/dialogue/kirkwall.json"))
        d["kwl_lerwick_hand"] = [
            {"do": "say", "who": "Lerwick Hand", "text": "The boat to Lerwick, in Shetland. Overnight, up past Fair Isle, with the sea in a mood. You'll want a coat. On arrival, you'll want a bigger coat."},
            {"do": "ferry", "route": "kirkwall_lerwick"}]
        wr("data/dialogue/kirkwall.json", json.dumps(d, indent=1, ensure_ascii=False))


HABITAT = {"foalmoor": ["lerwick", "shetland_mainland"], "puffling": ["lerwick", "shetland_mainland"], "rillotter": ["lerwick", "shetland_mainland"],
           "selklet": ["lerwick", "shetland_mainland"], "herdlet": ["lerwick", "shetland_mainland"], "gannetling": ["lerwick", "shetland_mainland"]}


def habitats():
    import glob
    for path in glob.glob(ROOT + "/data/creatures/*.json"):
        t = open(path, encoding="utf-8").read()
        out = []
        changed = False
        for line in t.split("\n"):
            m = re.search(r'"id": "([a-z_]+)"', line)
            if m and m.group(1) in HABITAT and '"habitat": [' in line and '"lerwick"' not in line:
                def sub(mm):
                    cur = json.loads(mm.group(1))
                    return '"habitat": ' + json.dumps(cur + HABITAT[m.group(1)])
                line = re.sub(r'"habitat": (\[[^\]]*\])', sub, line, count=1)
                changed = True
            out.append(line)
        if changed:
            open(path, "w", encoding="utf-8").write("\n".join(out))


JOBS = [
    {"id": "lerwick_otters", "nation": "scotland", "town": "lerwick", "badges": 9, "poster": "Shetland Amenity Trust",
     "title": "Otter count", "text": "The otters of the voes are shy, nocturnal and extremely good at not being counted. Catch a Rillotter for the survey, and do not, under any circumstances, tell it that it is on a list.",
     "step": {"type": "catch", "species": "rillotter"}, "pay": 3},
    {"id": "lerwick_bannocks", "nation": "scotland", "town": "lerwick", "badges": 9, "poster": "Up Helly Aa Hall Committee",
     "title": "Bannocks for the hall", "text": "A squad that has marched all night will eat anything, and we would rather it ate bannocks than the furniture. Two Shetland bannocks, please, from the corner shop.",
     "step": {"type": "bring", "item": "shetland_bannock", "n": 2}, "pay": 1},
]


def jobs():
    t = rd("data/jobs.json")
    if "lerwick_otters" in t:
        return
    i = t.rindex("\n ]")
    add = ",\n".join("  " + json.dumps(j, ensure_ascii=False) for j in JOBS)
    wr("data/jobs.json", t[:i] + ",\n" + add + t[i:])


# ---------------------------------------------------------------- Up Helly Aa
def festival():
    ev = json.loads(rd("data/festivals.json"))
    if any(e["id"] == "uphellyaa" for e in ev["events"]):
        return
    ev["events"].append({
        "id": "uphellyaa", "name": "Up Helly Aa", "town": "lerwick", "window": [1, 24, 1, 28],
        "rule": {"nth": "last", "weekday": 2, "month": 1, "from": -3, "to": 1},
        "when": "the last Tuesday of January (and the days around it)", "whatson": "Up Helly Aa, the fire festival and burning of a Viking galley",
        "who": "Guizer Magnus", "sprite": "festival_goer", "x": 26, "y": 17, "facing": "left", "script": "fest_uphellyaa", "quest": "festivals_uphellyaa",
        "spawn": {"species": "kindlet", "kinds": ["grass"], "share": 0.18}})
    wr("data/festivals.json", json.dumps(ev, indent=1, ensure_ascii=False))
    q = json.loads(rd("data/quests/festivals.json"))
    q["quests"].append({
        "id": "festivals_uphellyaa", "title": "Up Helly Aa", "region": "festivals", "town": "lerwick", "giver": "Guizer Magnus",
        "summary": "Lerwick needs a Kindlet to light the torches for the galley. On round the last Tuesday of January.",
        "start_flag": "q_festivals_uphellyaa_started",
        "steps": [
            {"flag": "q_festivals_uphellyaa_1", "text": "Catch a Kindlet, a little ember of a creature that only turns up round Lerwick at Up Helly Aa. Show it to Guizer Magnus.", "zone": "lerwick"},
            {"flag": "q_festivals_uphellyaa_2", "text": "Answer Guizer Magnus's question about the occasion.", "zone": "lerwick"}],
        "done_flag": "q_festivals_uphellyaa_done", "reward": "A guizer's torch (the first year only) and some reestit mutton soup."})
    wr("data/quests/festivals.json", json.dumps(q, indent=1, ensure_ascii=False))
    d = json.loads(rd("data/dialogue/festivals.json"))
    s = json.dumps(d["fest_bonfire"], ensure_ascii=False)
    for a, b in [
        ("Parkin and sparklers, the York way. Mind your eyebrows.", "A torch in each fist and a galley in the flames. That's Lerwick in January. Mind your eyebrows."),
        ("Quick, before the match is struck. What year was the Gunpowder Plot?", "Quick, before the torches are lit. When is Up Helly Aa held?"),
        ('["1605", "1066", "1666"]', '["The last Tuesday of January", "Hogmanay", "Midsummer"]'),
        ("1605, the fifth of November. Remember, remember, and all that. The Plot failed and we've been burning things ever since.",
         "The last Tuesday of January, every year, come wind, rain or sleet. It was once the end of Yule, and we've never quite stopped celebrating."),
        ("Right, light it! And have some parkin. It's a Yorkshire thing, ginger and oats and a bit of black treacle. Goes with every bonfire.",
         "Right, torches up! And have some reestit mutton soup. It's mutton salted and dried in the rafters, then simmered with tatties and neeps. A Shetland thing, and nothing warms you better after a night of fire."),
        ("Not quite. It was 1605, on the fifth of November. Think of the rhyme.", "Not quite. It's the last Tuesday of January. Think of the darkest, coldest bit of the year."),
        ("A Fizzlet! Look at it spit. That's the spirit of the night, that is.", "A Kindlet! Look at that tail glow. That's a proper spark for a torch."),
        ("Catch me a Fizzlet and I'll know the night is in safe hands.", "Catch me a Kindlet and I'll know the torches are in safe hands."),
        ("Catch a Fizzlet, a little firework of a creature that only turns up in York this week.", "Catch a Kindlet, a little ember of a creature that only turns up round Lerwick at Up Helly Aa."),
        ("Remember, remember! Bonfire Night's coming and York's got the best claim on it going. Guy Fawkes was born right here in 1570 and went to school at St Peter's, you know.",
         "Up Helly Aa! Lerwick's fire festival, the last Tuesday of January. A thousand guizers in Viking gear, torches blazing, and a galley the length of a bus that we build all winter to burn in minutes. No, I'm not joking."),
        ("We've a bonfire to light and not one spark to light it with. Things that fizz and crackle turn up round the town this week.",
         "We've a galley to light and not one decent spark. Things that glow and smoulder turn up round the town this week."),
        ("Help with Remember, Remember?", "Help with Up Helly Aa?"),
        ("has_fizzlet", "has_kindlet"), ("Bonfire Bernard", "Guizer Magnus"), ("fest_sparkler_tin", "fest_galley_torch"),
        ('"item": "parkin"', '"item": "reestit_mutton_soup"'), ("bonfire", "uphellyaa")]:
        assert a in s, a
        s = s.replace(a, b)
    d["fest_uphellyaa"] = json.loads(s)
    wr("data/dialogue/festivals.json", json.dumps(d, indent=1, ensure_ascii=False) + "\n")


if __name__ == "__main__":
    items_and_shop()
    quests()
    quiz()
    ferry_and_map()
    habitats()
    jobs()
    festival()
    print("shetland data: written")
