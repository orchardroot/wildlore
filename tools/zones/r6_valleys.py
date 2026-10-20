# Wider Isles, region R6: the South Wales valleys, hung off the north side of Cardiff.
#   python3 tools/zones/r6_valleys.py data/zones
# Writes rhondda, merthyr, blaenavon and their interiors, dialogue and trainers, opens Cardiff's north wall, and
# writes the region's items, shops, quests, quiz questions and map entries (all idempotent, additive text edits).
# Creatures: python3 tools/zones/r6_creatures.py (sprites via spritegen).
import os, sys, json, re
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from r6_common import *
from r6_rhondda import rhondda
from r6_merthyr import merthyr
from r6_blaenavon import blaenavon

ROOT = None


def cardiff_north(OUT):
    """open the north wall of Cardiff at x 45..47 and send it to the Rhondda (text edit, keeps the file's style)."""
    p = OUT + "/cardiff.json"
    s = open(p).read()
    if '"north"' in s:
        return
    s = s.replace('''  "west": {
   "offset": 0.0,
   "to": "beacons"
  }
 },''', '''  "north": {
   "offset": -16.0,
   "to": "rhondda"
  },
  "west": {
   "offset": 0.0,
   "to": "beacons"
  }
 },''', 1)
    head, tail = s.split(' "rows": [\n', 1)
    lines = tail.split("\n")
    for i in (0, 1):
        r = lines[i].strip()
        assert r.startswith('"') and len(r.rstrip(",")) == 66, r
        lines[i] = '  "' + r[1:46] + "..." + r[49:]
    s = head + ' "rows": [\n' + "\n".join(lines)
    s = s.replace(' "signs": [\n', ''' "signs": [
  {
   "text": "THE VALLEYS. North: the Rhondda, then Merthyr Tydfil and Blaenavon. Coal, iron, chapels, choirs, and rain that goes sideways. Croeso!",
   "x": 44.0,
   "y": 2.0
  },
''', 1)
    open(p, "w").write(s)


def data_files(OUT):
    root = os.path.dirname(os.path.dirname(os.path.abspath(OUT)))
    items = [
        {"id": "cawl", "name": "Cawl", "kind": "heal", "price": 340, "battle": True, "field": True, "amount": 150,
         "desc": "Lamb, leeks, swede, carrots and potatoes simmered for hours in one pot. Welsh cooks say it's better the next day, and nobody ever leaves it that long. Restores 150 HP."},
        {"id": "glamorgan_sausage", "name": "Glamorgan Sausage", "kind": "heal", "price": 260, "battle": True, "field": True, "amount": 125,
         "desc": "A vegetarian sausage of Caerphilly cheese, leeks and breadcrumbs, fried crisp. It was invented when meat was short, and it outlived the shortage by a century. Restores 125 HP."},
        {"id": "blaenavon_cheddar", "name": "Pwll Mawr Cheddar", "kind": "heal", "price": 300, "battle": True, "field": True, "amount": 140,
         "desc": "A cloth-bound cheddar matured in the cool, damp tunnels of Big Pit, ninety metres down an old coal mine. It tastes of cheddar, and faintly of adventure. Restores 140 HP."},
        {"id": "steam_coal", "name": "Rhondda Steam Coal", "one": "a lump of Steam Coal", "kind": "key", "price": 0, "battle": False, "field": True,
         "desc": "A bucket of dry, hard, nearly smokeless coal from the Rhondda. It drove the Royal Navy and half the world's steamers, and Trevithick's engine will want some."},
        {"id": "big_pit_lamp", "name": "Big Pit Lamp", "kind": "key", "price": 0, "battle": False, "field": True,
         "desc": "A borrowed cap lamp from the Big Pit lamp room, numbered like every miner's. It lights ten feet of tunnel and a good many memories."},
        {"id": "davy_lamp", "name": "Davy Lamp", "kind": "charm", "price": 0, "battle": False, "field": True, "wild": False,
         "desc": "A miner's safety lamp, the flame inside a gauze of fine wire. Sir Humphry Davy designed it in 1815 so the flame couldn't ignite firedamp, and a changed flame warned of bad air.",
         "effect_text": "Hearth moves hurt it 25% less.", "charm": {"effect": "resist", "type": "hearth", "mult": 0.75}, "msg": "{name}'s Davy Lamp kept the flame in!"},
        {"id": "wager_guinea", "name": "Wager Guinea", "kind": "charm", "price": 0, "battle": False, "field": True, "wild": False,
         "desc": "A gold guinea, one of five hundred won on 21 February 1804 when Trevithick's locomotive hauled ten tons of iron from Penydarren to Abercynon, against all advice.",
         "effect_text": "Iron moves hit 20% harder.", "charm": {"effect": "boost", "type": "iron", "mult": 1.2}, "msg": "{name}'s Wager Guinea paid off!"},
        {"id": "eisteddfod_medal", "name": "Eisteddfod Medal", "kind": "charm", "price": 0, "battle": False, "field": True, "wild": False,
         "desc": "A bronze medal for second place in the male voice choir competition at the Eisteddfod, on a ribbon of red, white and green. The first tenor insists it was a very close second.",
         "effect_text": "Lore up a stage when it comes out.", "charm": {"effect": "start_stage", "stat": "lore", "stages": 1}, "msg": "{name} came out in fine voice!"},
        {"id": "penydarren_pig", "name": "Penydarren Pig Iron", "one": "a bar of Pig Iron", "kind": "material", "price": 0, "battle": False, "field": False,
         "desc": "A bar of cast iron stamped at Penydarren, named for the channels in the sand: a sow with her piglets. Merthyr iron went into rails, bridges and cannon, and a good deal of the railway age."},
    ]
    lines = ",\n".join("  " + json.dumps(i, ensure_ascii=False) for i in items)
    open(root + "/data/items/valleys.json", "w").write("[\n" + lines + "\n]\n")
    base = ["cup_of_tea", "flask_of_tea", "bakewell_tart", "buxton_water", "smelling_salts", "kendal_mint_cake", "wicker_snare", "iron_snare", "night_snare",
            "water_snare", "scouse", "bara_brith", "silver_snare", "lavender_sachet"]
    shops = {
        "rhondda_bakehouse": ("Y Popty", ["welsh_cake", "bara_brith", "cawl", "glamorgan_sausage", "cup_of_tea", "flask_of_tea"]),
        "merthyr_corner_shop": ("Merthyr Corner Shop", base + ["cawl"]),
        "merthyr_market_stall": ("Merthyr Market", ["cawl", "glamorgan_sausage", "welsh_cake", "bara_brith", "laverbread", "cup_of_tea"]),
        "blaenavon_corner_shop": ("Blaenavon Corner Shop", base + ["cawl"]),
        "blaenavon_cheese_stall": ("Pwll Mawr Cheese", ["blaenavon_cheddar", "glamorgan_sausage", "bara_brith", "cup_of_tea", "flask_of_tea"]),
    }
    for sid, (nm, stock) in shops.items():
        open(root + "/data/shops/%s.json" % sid, "w").write(json.dumps({"id": sid, "name": nm, "stock": stock}) + "\n")
    # quests
    def step(flag, text, zone):
        return {"flag": Q + flag, "text": text, "zone": zone}
    quests = {"quests": [
        {"id": "valleys_bigpit", "title": "Down Big Pit", "region": "valleys", "town": "blaenavon", "giver": "Gwilym, ex-miner",
         "summary": "Ride the cage ninety metres down Big Pit and follow the knocking in the dark.",
         "start_flag": Q + "pit_started",
         "steps": [step("pit_1", "Pass the lamp-room check with Gwilym at Big Pit and take a lamp.", "blaenavon"),
                   step("pit_2", "Ride the cage down and find Idris at the coal face.", "blaenavon"),
                   step("pit_3", "Follow the knocking at the east face, and catch the Cobblet making it.", "blaenavon"),
                   step("pit_done", "Ride back up and tell Gwilym.", "blaenavon")],
         "done_flag": Q + "pit_done", "reward": "A Davy Lamp, three Pwll Mawr cheddars and standing in Wales."},
        {"id": "valleys_choir", "title": "Voices for the Eisteddfod", "region": "valleys", "town": "rhondda", "giver": "Elwyn Prosser, conductor",
         "summary": "Bethania's choir is four voices short with the Eisteddfod a fortnight away. Find a tenor, a second tenor, a baritone and a bass.",
         "start_flag": Q + "choir_started",
         "steps": [step("choir_1", "Find a first tenor in the Rhondda bakehouse.", "rhondda"),
                   step("choir_2", "Find a second tenor at the Dic Penderyn pub in Merthyr.", "merthyr"),
                   step("choir_3", "Find a baritone at the Workmen's Hall in Blaenavon.", "blaenavon"),
                   step("choir_4", "Find a bass at Big Pit, once you have been down it.", "blaenavon"),
                   step("choir_done", "Take the four voices back to Elwyn at Bethania Chapel.", "rhondda")],
         "done_flag": Q + "choir_done", "reward": "An Eisteddfod Medal and standing in Wales."},
        {"id": "valleys_wager", "title": "Trevithick's Wager", "region": "valleys", "town": "merthyr", "giver": "Bryn, Iron Heritage guide",
         "summary": "Replay the 1804 wager: Rhondda coal, a Steamlet to fire the boiler, and a doubting agent to beat.",
         "start_flag": Q + "wager_started",
         "steps": [step("wager_1", "Ask Dai at the Rhondda Heritage Park for a bucket of steam coal.", "rhondda"),
                   step("wager_2", "Catch a Steamlet and show it to Bryn in Merthyr.", "merthyr"),
                   step("wager_3", "Beat the ironmaster's agent at Trevithick's plinth on the main street.", "merthyr"),
                   step("wager_done", "Report back to Bryn.", "merthyr")],
         "done_flag": Q + "wager_done", "reward": "A Wager Guinea, two bars of Penydarren pig iron and standing in Wales."},
    ]}
    json.dump(quests, open(root + "/data/quests/valleys.json", "w"), indent=1, ensure_ascii=False)
    # quiz questions
    qs = [
        ("history", "Richard Trevithick's Penydarren locomotive of 1804 hauled what along the Merthyr tramroad?", "Ten tons of iron and about seventy men", ["A cargo of cheese", "The Prince of Wales", "A hundred sheep"],
         "It was the first journey by a steam locomotive on rails, and it won a bet of 500 guineas."),
        ("history", "Which Merthyr man was hanged in Cardiff in 1831 after the Rising?", "Dic Penderyn", ["Owain Glyndwr", "Keir Hardie", "Evan James"],
         "Many believed Richard Lewis, known as Dic Penderyn, was innocent. His last words are said to have been 'O Arglwydd, dyma gamwedd'."),
        ("history", "Which Scot, who first went down a mine aged ten, was elected MP for Merthyr Tydfil in 1900?", "Keir Hardie", ["Aneurin Bevan", "David Lloyd George", "Ramsay MacDonald"],
         "Hardie became the first leader of the Labour Party and held the Merthyr seat until his death in 1915."),
        ("food", "Which Welsh dish is a broth of lamb, leeks and root vegetables?", "Cawl", ["Laverbread", "Bara brith", "Glamorgan sausage"],
         "Cawl is often called the national dish of Wales, and traditionally tastes better the next day."),
        ("geography", "What does the Welsh word 'cwm' mean?", "A steep-sided valley", ["A hill fort", "A stone circle", "A stream"],
         "The south Wales coalfield is a comb of cwms, and the Rhondda is two of them: Fawr and Fach."),
        ("history", "In which year did the Blaenavon Industrial Landscape become a UNESCO World Heritage Site?", "2000", ["1975", "1988", "2009"],
         "It was the first industrial site in Wales to be listed."),
        ("history", "Roughly how far down does the cage take visitors at Big Pit?", "90 metres", ["9 metres", "20 metres", "900 metres"],
         "Big Pit closed as a colliery in 1980 and reopened as the National Coal Museum, with ex-miners as guides."),
        ("history", "What did Sidney Gilchrist Thomas and Percy Gilchrist test at Blaenavon in 1878?", "A way to make steel from iron rich in phosphorus", ["A steam locomotive", "A safety lamp", "A canal lock"],
         "Their 'basic' process opened up the world's phosphoric iron ores to steelmaking."),
        ("history", "A medical aid society in which Welsh mining town inspired the National Health Service?", "Tredegar", ["Merthyr Tydfil", "Swansea", "Aberystwyth"],
         "Tredegar's miners paid a few pence a week for medical care. Aneurin Bevan, born there, launched the NHS in 1948."),
        ("culture", "Which Merthyr-born composer wrote the love song 'Myfanwy'?", "Joseph Parry", ["Ivor Novello", "Daniel James", "John Hughes"],
         "Parry was born in Merthyr in 1841, worked in the ironworks as a boy and wrote 'Myfanwy' in 1875."),
        ("food", "What are Welsh cakes traditionally cooked on?", "A bakestone or griddle", ["An open fire spit", "A baking tray in the oven", "A hot stone in a river"],
         "Picau ar y maen are 'cakes on the stone': flour, butter, currants, sugar and a pinch of spice."),
        ("history", "Who built Cyfarthfa Castle above his Merthyr ironworks in 1824?", "The ironmaster William Crawshay II", ["The Marquess of Bute", "Lord Penrhyn", "Isambard Brunel"],
         "The castle looked down on the furnaces, and is now a museum and art gallery."),
    ]
    p = root + "/data/quiz/questions.json"
    txt = open(p).read()
    if "Trevithick's Penydarren" not in txt:
        body = txt.rstrip()
        assert body.endswith("]")
        body = body[:-1].rstrip()
        add = "".join(',\n\t' + json.dumps({"cat": c, "region": "wales", "q": q, "a": a, "wrong": w, "fact": f}, ensure_ascii=False) for (c, q, a, w, f) in qs)
        open(p, "w").write(body + add + "\n]\n")
    # world map
    p = root + "/data/world_map.json"
    txt = open(p).read()
    if '"merthyr"' not in txt:
        txt = txt.replace('"towns": {', '"towns": {"merthyr": {"name": "Merthyr Tydfil", "x": 586, "y": 1038, "nation": "wales", "island": "gb"}, '
                          '"blaenavon": {"name": "Blaenavon", "x": 610, "y": 1034, "nation": "wales", "island": "gb"}, ', 1)
        txt = txt.replace('"places": {', '"places": {"rhondda": {"x": 577, "y": 1052}, ', 1)
        txt = txt.replace('"rail": [', '"rail": [[602, 1075, 586, 1038], ', 1)
        open(p, "w").write(txt)


def post(OUT):
    """the shared post-passes, run on a scratch copy of just this region's zones so no other zone is touched."""
    import glob, shutil, tempfile, subprocess
    tmp = tempfile.mkdtemp()
    mine = [f for pre in ("rhondda", "merthyr", "blaenavon") for f in glob.glob(OUT + "/" + pre + "*.json")]
    for f in mine:
        shutil.copy(f, tmp)
    import add_memory_coach, building_kinds
    add_memory_coach.main(tmp)
    building_kinds.tag_all(tmp)
    for f in mine:
        shutil.copy(os.path.join(tmp, os.path.basename(f)), f)
    shutil.rmtree(tmp)
    root = os.path.dirname(os.path.dirname(os.path.abspath(OUT)))
    subprocess.run([sys.executable, os.path.join(root, "tools/zones/noticeboards.py"), "merthyr", "blaenavon"], cwd=root, check=True)


if __name__ == "__main__":
    OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
    rhondda(OUT)
    merthyr(OUT)
    blaenavon(OUT)
    write_all(OUT)
    cardiff_north(OUT)
    data_files(OUT)
    post(OUT)
