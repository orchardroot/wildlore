# Plain-data side of wave 33 agent 1 (RAF Brize Norton, Gibraltar, Akrotiri and Dhekelia): items, shops, quests,
# quiz questions, the six new creature lines and their recipes, knacks, the registry files and the Cotswolds gate.
# Idempotent: run it from the repo root after overseas_hub.py, overseas_gib.py and overseas_cyprus.py.
#
#   python3 tools/zones/overseas_data.py
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def path(*p):
    return os.path.join(ROOT, *p)


def read(p):
    return open(path(p), encoding="utf-8").read()


def write(p, text):
    os.makedirs(os.path.dirname(path(p)), exist_ok=True)
    open(path(p), "w", encoding="utf-8").write(text)


def lines_json(items):
    return "[\n" + ",\n".join(" " + json.dumps(i, ensure_ascii=False) for i in items) + "\n]\n"


def heal(i, name, price, amount, desc, one=None):
    d = {"id": i, "name": name, "kind": "heal", "price": price, "battle": True, "field": True, "amount": amount, "desc": desc + " Restores %d HP." % amount}
    if one:
        d["one"] = one
    return d


ITEMS = [
    heal("naafi_bacon_roll", "NAAFI Bacon Roll", 420, 150, "A soft white roll, two rashers, brown sauce, wrapped in greaseproof paper and handed over by someone who has been up since four. The Airbridge runs on them.", "a NAAFI Bacon Roll"),
    heal("mess_tin_stew", "Mess Tin Stew", 650, 220, "A thick stew of beef, carrots and barley served in a tin dish and eaten standing up. It does not look like much, and it is exactly what you want after a long flight."),
    heal("aircrew_sweets", "Aircrew Boiled Sweets", 160, 70, "A paper bag of boiled sweets, passed down the cabin at take-off and landing. Sucking one helps your ears pop, and nobody has ever asked what flavour it is."),
    heal("calentita", "Calentita", 400, 150, "Gibraltar's national dish: a baked cake of chickpea flour, olive oil, water, salt and pepper, hot from the oven in a round tin. The Genoese brought it with them, and the Rock took it for its own. Eat it with black pepper.", "a Calentita"),
    heal("gib_rosto", "Gibraltar Rosto", 620, 210, "Macaroni baked in a rich tomato sauce with beef or chicken, a Sunday dish on the Rock. Rosto is a Gibraltarian word for a dish nobody else seems to have a name for, and it tastes of a grandmother's kitchen."),
    heal("gib_fish_chips", "Main Street Fish and Chips", 520, 180, "Crispy battered fish and thick chips, in paper, eaten on a bench in Casemates Square while a seagull plans its next move. The vinegar has seen more sun than the fish.", "Main Street Fish and Chips"),
    {"id": "siege_cannonball", "name": "Siege Cannonball", "one": "a Siege Cannonball", "kind": "charm", "price": 0, "battle": False, "field": True, "wild": True,
     "desc": "A cast-iron ball from the Great Siege of 1779 to 1783, found in a tunnel and still heavy enough to knock a Spanish gun-boat off course. The Garrison fired red-hot shot at the floating batteries, and it worked.",
     "effect_text": "Its Iron moves hit 20% harder.", "charm": {"effect": "boost", "type": "iron", "mult": 1.2}, "msg": "{name} hits like the Great Siege!"},
    heal("halloumi", "Halloumi", 480, 170, "A firm, squeaky Cypriot cheese of sheep's and goat's milk, folded round a little mint and grilled until it browns. It is served hot with a squeeze of lemon, and it squeaks against the teeth.", "some Halloumi"),
    heal("loukoumi", "Loukoumi", 250, 90, "Cypriot delight: soft rose-scented squares dusted in icing sugar, handed out with coffee in every kafeneio. It sticks to everything and tastes like a flower."),
    heal("carob_syrup", "Carob Syrup", 380, 130, "A thick, dark syrup boiled from carob pods, tasting a little like toffee and a little like treacle. It is the old sweetener of Cyprus, poured over bread and yoghurt, and the word 'carat' comes from the carob seed."),
    {"id": "flamingo_feather", "name": "Flamingo Feather", "one": "a Flamingo Feather", "kind": "charm", "price": 0, "battle": False, "field": True, "wild": True,
     "desc": "A long, pale-pink feather found on the shore of the Akrotiri Salt Lake. Flamingos get their colour from the shrimp and algae they strain from the water, and wear it like a badge of what they ate.",
     "effect_text": "Speed up when it first comes out.", "charm": {"effect": "start_stage", "stat": "spd", "stages": 1}, "msg": "{name} struts out like a flamingo!"},
]
BASE_STOCK = ["cup_of_tea", "flask_of_tea", "bakewell_tart", "buxton_water", "smelling_salts", "kendal_mint_cake", "wicker_snare",
              "iron_snare", "night_snare", "water_snare", "scouse", "bara_brith", "silver_snare", "pasty", "cream_tea", "soda_bread",
              "barmbrack", "tablet", "cranachan", "irn_tonic", "yorkshire_pudding", "parkin", "pork_pie"]
SHOPS = {
    "brize_norton_corner_shop": ("NAAFI", BASE_STOCK + ["naafi_bacon_roll", "mess_tin_stew", "aircrew_sweets", "lavender_sachet"]),
    "gibraltar_corner_shop": ("Gibraltar Corner Shop", BASE_STOCK + ["calentita", "gib_rosto", "gib_fish_chips", "lavender_sachet"]),
    "akrotiri_corner_shop": ("Episkopi NAAFI", BASE_STOCK + ["halloumi", "loukoumi", "carob_syrup", "lavender_sachet"]),
    "dhekelia_corner_shop": ("Dhekelia Garrison Shop", BASE_STOCK + ["halloumi", "loukoumi", "carob_syrup", "lavender_sachet"]),
}

# ---------------------------------------------------------------------------------------------- quests
Q_BRIZE = {"quests": [
    {"id": "overseas_brize_norton_manifest", "title": "The Airbridge Manifest", "region": "overseas_brize_norton", "town": "brize_norton_airbridge", "giver": "Duty Officer",
     "summary": "The Airbridge runs on paperwork. Collect the distances from the Control Tower and a signature from the Loadmaster, and bring the manifest back.",
     "start_flag": "q_overseas_brize_norton_started",
     "steps": [
         {"flag": "q_overseas_brize_norton_1", "text": "Take the manifest from the Duty Officer at Airbridge Operations.", "zone": "brize_norton_airbridge"},
         {"flag": "q_overseas_brize_norton_2", "text": "Ask the Duty Controller in the Control Tower how far the Airbridge flies.", "zone": "brize_norton_tower"},
         {"flag": "q_overseas_brize_norton_3", "text": "Get the Loadmaster on the apron to sign it (he only signs for people who can beat him), then report back.", "zone": "brize_norton"}],
     "done_flag": "q_overseas_brize_norton_done", "reward": "Three flasks of tea, three cups of tea and standing with the Overseas Territories."}]}
Q_GIB = {"quests": [
    {"id": "overseas_gibraltar_rock", "title": "The Rock's Early Story", "region": "overseas_gibraltar", "town": "gibraltar_rock", "giver": "Cave Warden",
     "summary": "The Cave Warden at St Michael's wants someone to learn the Rock's first story: the Neanderthals, the caves and the apes.",
     "start_flag": "q_overseas_gibraltar_started",
     "steps": [
         {"flag": "q_overseas_gibraltar_1", "text": "Ask the Curator at the Gibraltar Museum about the Neanderthal skull.", "zone": "gibraltar_museum"},
         {"flag": "q_overseas_gibraltar_2", "text": "Tell the Cave Warden at St Michael's Cave what you learnt.", "zone": "gibraltar_stmichaels"},
         {"flag": "q_overseas_gibraltar_3", "text": "Win a fair match against the Ape Keeper at the Apes' Den, then report back to the Cave Warden.", "zone": "gibraltar_rock"}],
     "done_flag": "q_overseas_gibraltar_done", "reward": "A Siege Cannonball (an Iron charm), three Calentita, two Gibraltar Rosto and standing with the Overseas Territories."}]}
Q_CY = {"quests": [
    {"id": "overseas_akrotiri_dhekelia_census", "title": "The Flamingo Census", "region": "overseas_akrotiri_dhekelia", "town": "akrotiri", "giver": "Centre Warden",
     "summary": "The Environmental Centre is counting this winter's flamingos and needs a hand: catch a Brineling, then face the Flamingo Warden.",
     "start_flag": "q_overseas_akrotiri_dhekelia_started",
     "steps": [
         {"flag": "q_overseas_akrotiri_dhekelia_1", "text": "Catch a Brineling on the shore of the Akrotiri Salt Lake and show the Centre Warden.", "zone": "akrotiri"},
         {"flag": "q_overseas_akrotiri_dhekelia_2", "text": "The Flamingo Warden wants a fair match at the lake. Win it.", "zone": "akrotiri"},
         {"flag": "q_overseas_akrotiri_dhekelia_3", "text": "Report back to the Centre Warden at the Environmental Centre.", "zone": "akrotiri_centre"}],
     "done_flag": "q_overseas_akrotiri_dhekelia_done", "reward": "A Flamingo Feather (a Speed charm), three Halloumi, two Loukoumi and standing with the Overseas Territories."}]}


def quests_text(d):
    out = ['{"quests": [']
    for i, q in enumerate(d["quests"]):
        steps = ",\n".join("   " + json.dumps(st, ensure_ascii=False) for st in q["steps"])
        head = {k: v for k, v in q.items() if k not in ("steps", "done_flag", "reward")}
        h = json.dumps(head, ensure_ascii=False)[:-1]
        out.append(" " + h + ',\n  "steps": [\n' + steps + '\n  ],\n  ' + json.dumps({"done_flag": q["done_flag"], "reward": q["reward"]}, ensure_ascii=False)[1:-1]
                   + "}" + ("," if i < len(d["quests"]) - 1 else ""))
    out.append("]}\n")
    return "\n".join(out)


# ---------------------------------------------------------------------------------------------- creatures
def species_line(sp):
    return "    " + json.dumps(sp, ensure_ascii=False)


def line_file(line, species):
    return '{\n  "line": "%s",\n  "species": [\n%s\n  ]\n}\n' % (line, ",\n".join(species_line(s) for s in species))


MACAQUET = {"id": "macaquet", "name": "Macaquet", "types": ["urban", "spirit"], "base": {"hp": 80, "atk": 85, "def": 70, "lore": 80, "ward": 60, "spd": 95},
            "growth": "medium", "catch_rate": 45, "base_xp": 175,
            "learnset": [[1, "scrap"], [1, "dirty_look"], [5, "whisper"], [9, "bin_clang"], [13, "quick_nip"], [18, "crossroads_whisper"], [23, "bin_lid_bash"],
                         [28, "kerb_crunch"], [33, "keening"], [38, "mums_look"], [44, "gridlock"], [50, "poltergeist"]],
            "evolves": None, "habitat": ["gibraltar_rock", "gibraltar"], "appendix": True,
            "dex": {"text": "A tailless, rust-brown ape with a worried brow and a very good idea where you keep your sandwiches. It sits on the wall of the Rock with the air of a landlord, and it is not paying anyone a penny.",
                    "fact": "The Barbary macaque of Gibraltar is the only wild monkey in Europe, and it has no tail, which is why the Rock's old name for it was the Barbary ape. A few hundred live in several troops. The old saying is that when the apes leave the Rock, the British will leave too, and Churchill is said to have ordered their numbers restored during the Second World War."},
            "sprite": "macaquet"}
LEVANTER = {"id": "levanter", "name": "Levanter", "types": ["storm", "stone"], "base": {"hp": 75, "atk": 60, "def": 55, "lore": 100, "ward": 85, "spd": 95},
            "growth": "medium", "catch_rate": 45, "base_xp": 180,
            "learnset": [[1, "static_cling"], [1, "pebble_flick"], [5, "static_snap"], [9, "hard_hat"], [13, "thunder_plump"], [18, "wind_shear"], [23, "boulder_bump"],
                         [28, "thunderclap"], [33, "minch_squall"], [38, "megalith_mutter"], [44, "ball_lightning"], [50, "stornoway_gale"]],
            "evolves": None, "habitat": ["gibraltar_rock", "gibraltar"], "appendix": True,
            "dex": {"text": "A long white cloud that lies along the top of a rock like a tablecloth, and pours gently down the far side without ever quite reaching the ground. It is not the weather. It is the weather's hat.",
                    "fact": "The Levanter is an easterly wind through the Strait of Gibraltar. Moist air blowing against the Rock is forced up its east face, cools, and condenses into a banner cloud over the summit, which spills over the western side and melts away before it reaches the town."},
            "sprite": "levanter"}
SAPPERLING = {"id": "sapperling", "name": "Sapperling", "types": ["iron", "urban"], "base": {"hp": 85, "atk": 95, "def": 100, "lore": 55, "ward": 70, "spd": 50},
              "growth": "medium", "catch_rate": 60, "base_xp": 170,
              "learnset": [[1, "rivet"], [1, "riveters_brace"], [5, "bin_clang"], [9, "girder_sweep"], [13, "tannoy_squeal"], [18, "hull_clang"], [23, "bin_lid_bash"],
                           [28, "forge_hammer"], [33, "kerb_crunch"], [38, "blast_furnace"], [44, "girder_drop"], [50, "gridlock"]],
              "evolves": None, "habitat": ["gibraltar_rock", "gibraltar", "akrotiri", "dhekelia"], "appendix": True,
              "dex": {"text": "A stocky digger in a tin hat, who sees a wall and thinks 'this could do with a window'. It would rather go through a problem than round it, and it has left a lot of very neat holes.",
                      "fact": "During the Great Siege of Gibraltar, in 1782, Sergeant-Major Henry Ince of the Royal Military Artificers set about cutting a gallery through the Rock with hand tools and gunpowder, so that guns could fire down from the north face. By the Second World War the Rock held more than 50 kilometres of tunnels."},
              "sprite": "sapperling"}
BRINELING = {"id": "brineling", "name": "Brineling", "types": ["bog"], "base": {"hp": 50, "atk": 40, "def": 50, "lore": 60, "ward": 55, "spd": 45},
             "growth": "medium", "catch_rate": 190, "base_xp": 60,
             "learnset": [[1, "squelch"], [1, "murky_gaze"], [5, "rill_shot"], [9, "peat_spit"], [13, "sundew_snap"], [17, "puffball_burst"], [21, "mire_stomp"], [26, "bog_gas_belch"]],
             "evolves": {"to": "brineflame", "level": 30}, "habitat": ["akrotiri", "dhekelia"], "appendix": True,
             "dex": {"text": "A knock-kneed chick, grey with a pink flush, standing on one leg in water that is far too salty for anyone sensible. It has not decided yet whether it is a bird or a rumour.",
                     "fact": "Flamingo chicks are born grey or white. They turn pink over a couple of years from the pigments in the brine shrimp and algae they eat. The Akrotiri Salt Lake in Cyprus fills with greater flamingos each winter."},
             "sprite": "brineling"}
BRINEFLAME = {"id": "brineflame", "name": "Brineflame", "types": ["bog", "hearth"], "base": {"hp": 85, "atk": 65, "def": 78, "lore": 102, "ward": 92, "spd": 58},
              "growth": "medium", "catch_rate": 60, "base_xp": 165,
              "learnset": [[1, "squelch"], [1, "murky_gaze"], [5, "rill_shot"], [9, "peat_spit"], [13, "sundew_snap"], [17, "puffball_burst"], [21, "mire_stomp"], [26, "bog_gas_belch"],
                           [32, "smoulder"], [38, "peat_hag"], [44, "aga_roast"], [50, "will_o_wisp"]],
              "evolves": None, "habitat": ["akrotiri"], "appendix": True,
              "dex": {"text": "Tall, pink and burning with it. It sweeps its bent beak through the shallows with the air of a duchess stirring soup, and where it walks the water seems to glow at the edges.",
                      "fact": "A flamingo feeds with its head upside down, using its bent bill like a sieve to filter shrimp and algae out of the water. Its colour comes from carotenoid pigments in that food, the same family of colours that turns a carrot orange."},
              "sprite": "brineflame"}
TESSERITE = {"id": "tesserite", "name": "Tesserite", "types": ["stone", "fae"], "base": {"hp": 70, "atk": 75, "def": 95, "lore": 95, "ward": 90, "spd": 40},
             "growth": "medium", "catch_rate": 60, "base_xp": 170,
             "learnset": [[1, "pebble_flick"], [1, "glamour"], [5, "fairy_pinch"], [9, "flint_flick"], [13, "pixie_prick"], [18, "slate_slide"], [23, "thistledown_trick"],
                          [28, "quarry_blast"], [33, "fairy_ring"], [38, "millstone_drop"], [44, "bewitching_hour"], [50, "megalith_mutter"]],
             "evolves": None, "habitat": ["akrotiri", "dhekelia"], "appendix": True,
             "dex": {"text": "A walking mosaic of small coloured stones, which arrange themselves into a face when you look at it and a pattern of partridges when you look away. It is two thousand years old and it still hasn't lost a tile.",
                     "fact": "A tessera is one of the small cubes of stone, glass or tile used to make a mosaic. The House of Eustolios at Kourion, in the Akrotiri Sovereign Base Area, has floors of tesserae laid in the early Christian period, with birds, fish and a Greek inscription."},
             "sprite": "tesserite"}
LINES = [("macaquet", [MACAQUET]), ("levanter", [LEVANTER]), ("sapperling", [SAPPERLING]), ("brineling", [BRINELING, BRINEFLAME]), ("tesserite", [TESSERITE])]
KNACK_MAP = {"macaquet": "cocky", "levanter": "pea_souper", "sapperling": "hard_hat", "brineling": "sun_trap", "brineflame": "sun_trap", "tesserite": "solid_as_rock"}

QUIZ = [
    {"cat": "geography", "region": "all", "q": "Which British Overseas Territory is a limestone Rock at the entrance to the Mediterranean?", "a": "Gibraltar", "wrong": ["Malta", "Akrotiri", "Ascension Island"], "fact": "It is 426 metres high, was ceded to Britain by the Treaty of Utrecht in 1713, and has about 34,000 people living on less than 7 square kilometres."},
    {"cat": "creatures", "region": "all", "q": "Which is the only wild monkey living in Europe?", "a": "The Barbary macaque, on the Rock of Gibraltar", "wrong": ["The vervet monkey", "The howler monkey", "The common marmoset"], "fact": "It has no tail and lives in troops on the Upper Rock. Legend says Britain will rule Gibraltar as long as the apes stay."},
    {"cat": "history", "region": "all", "q": "Which siege of Gibraltar, from 1779 to 1783, led the garrison to dig the famous tunnels?", "a": "The Great Siege", "wrong": ["The Siege of 1704", "The Peninsular War siege", "The Moorish siege of 711"], "fact": "It lasted three years and seven months, the longest siege in British military history."},
    {"cat": "food", "region": "all", "q": "What is the chickpea-flour baked dish called that is Gibraltar's national dish?", "a": "Calentita", "wrong": ["Tortilla", "Rosto", "Paella"], "fact": "Its name is Spanish for 'little hot one', and Genoese settlers brought it with them from Liguria, where it is called farinata."},
    {"cat": "geography", "region": "all", "q": "What is unusual about the main road across Gibraltar's airfield?", "a": "It crosses the runway on the level, and closes when a plane lands", "wrong": ["It is a toll road", "It is a one-way street", "It goes under the runway in a tunnel"], "fact": "Winston Churchill Avenue has barriers like a railway crossing."},
    {"cat": "geography", "region": "all", "q": "Which two Sovereign Base Areas does the UK keep on Cyprus?", "a": "Akrotiri and Dhekelia", "wrong": ["Larnaca and Paphos", "Limassol and Kyrenia", "Famagusta and Nicosia"], "fact": "They were kept under the 1960 Treaty of Establishment, and cover about 254 square kilometres in all."},
    {"cat": "nature", "region": "all", "q": "Which bird arrives in thousands on Cyprus's Akrotiri Salt Lake every winter?", "a": "The greater flamingo", "wrong": ["The pink-footed goose", "The roseate tern", "The spoonbill"], "fact": "Flamingos get their pink colour from the pigments in the shrimp and algae they filter from the water."},
    {"cat": "folklore", "region": "all", "q": "According to legend, why does the monastery of St Nicholas on the Akrotiri peninsula keep cats?", "a": "Saint Helena sent cats from Egypt to kill the snakes", "wrong": ["A bishop was turned into a cat", "Sailors left them behind", "They guard the holy relics"], "fact": "The legend is of the 4th century, and the monastery still has many cats."},
    {"cat": "history", "region": "all", "q": "At which ancient city-kingdom on Cyprus, in the Akrotiri Sovereign Base Area, can you sit in a Greco-Roman theatre above the sea?", "a": "Kourion", "wrong": ["Salamis", "Paphos", "Amathus"], "fact": "The theatre seated about 3,500 people and is still used for summer performances."},
    {"cat": "history", "region": "all", "q": "What is the name of the South Atlantic air service from RAF Brize Norton to the Falkland Islands?", "a": "The South Atlantic Airbridge", "wrong": ["The Falklands Express", "The Ascension Shuttle", "The Transatlantic Link"], "fact": "It began after the 1982 conflict and normally stops at Ascension Island on the way."},
    {"cat": "geography", "region": "all", "q": "Which Oxfordshire village gives its name to the largest station of the Royal Air Force?", "a": "Brize Norton", "wrong": ["Carterton", "Burford", "Faringdon"], "fact": "RAF Brize Norton opened in 1937 and is the home of the RAF's transport and tanker aircraft."},
    {"cat": "history", "region": "all", "q": "In which year did the Gibraltarians vote in a referendum on staying British, with 12,138 votes to 44?", "a": "1967", "wrong": ["1713", "1982", "2002"], "fact": "10 September, the date of the vote, is now Gibraltar National Day."},
]

REGISTRY = {
    "gibraltar": {"id": "gibraltar", "name": "Gibraltar", "arrival": {"zone": "gibraltar", "x": 40, "y": 19}, "via": "raf", "unlock_flag": "champion",
                  "blurb": "The Rock: Barbary macaques, the Great Siege Tunnels and a runway with a road across it.",
                  "flight_line": "The Rock rises out of the haze, and the pilot announces that the runway has a road across it and the road has right of way, which is the other way round to everywhere else."},
    "akrotiri_dhekelia": {"id": "akrotiri_dhekelia", "name": "Akrotiri and Dhekelia", "arrival": {"zone": "akrotiri", "x": 58, "y": 19}, "via": "raf", "unlock_flag": "champion",
                          "blurb": "The Sovereign Base Areas of Cyprus: flamingos on the salt lake, Kourion's theatre and a monastery of cats.",
                          "flight_line": "The Voyager banks over a pink salt lake and a cliff-top Greek theatre, and the Cypriot afternoon hits you like a warm bath as the door opens."},
}


def main():
    write("data/items/overseas.json", lines_json(ITEMS))
    for sid, (name, stock) in SHOPS.items():
        write("data/shops/%s.json" % sid, json.dumps({"id": sid, "name": name, "stock": stock}) + "\n")
    write("data/quests/overseas_brize_norton.json", quests_text(Q_BRIZE))
    write("data/quests/overseas_gibraltar.json", quests_text(Q_GIB))
    write("data/quests/overseas_akrotiri_dhekelia.json", quests_text(Q_CY))
    for rid, e in REGISTRY.items():
        write("data/overseas/%s.json" % rid, json.dumps(e, indent=1, ensure_ascii=False) + "\n")
    # creatures
    order = read("data/dex_order.json")
    for line, sp in LINES:
        write("data/creatures/%s.json" % line, line_file(line, sp))
        for s in sp:
            if '"%s"' % s["id"] not in order:
                i = order.rindex('"') + 1
                order = order[:i] + ',\n  "%s"' % s["id"] + order[i:]
    write("data/dex_order.json", order)
    kn = read("data/knacks.json")
    if '"macaquet"' not in kn:
        last = kn.rindex('"\n  }\n}')
        kn = kn[:last + 1] + "".join(',\n    "%s": "%s"' % (k, v) for k, v in KNACK_MAP.items()) + kn[last + 1:]
        write("data/knacks.json", kn)
    # quiz
    qz = read("data/quiz/questions.json")
    if "Great Siege" not in qz:
        i = qz.rindex("}") + 1
        qz = qz[:i] + "".join(",\n\t" + json.dumps(q, ensure_ascii=False) for q in QUIZ) + qz[i:]
        write("data/quiz/questions.json", qz)
    # the Cotswolds' south side opens on to RAF Brize Norton, with RAF Police at the gap until you are the Champion
    zp = "data/zones/cotswolds.json"
    z = json.loads(read(zp))
    if "south" not in z["edges"]:
        rows = z["rows"]
        for y in (64, 65):
            r = list(rows[y])
            for x in range(72, 76):
                r[x] = "g"
            rows[y] = "".join(r)
        z["edges"]["south"] = {"to": "brize_norton", "offset": 0}
        z["signs"].append({"x": 71, "y": 59, "text": "SOUTH: RAF Brize Norton, the Airbridge and the flights to the overseas territories. Civilians must be the Champion to pass the RAF Police. They have a very good eye for a rosette."})
        for x in range(72, 76):
            z["npcs"].append({"id": "cw_raf_police_%d" % x, "sprite": "rail_guard", "x": x, "y": 62, "facing": "down", "move": "still",
                              "script": "cw_raf_police", "name": "RAF Police", "hide_if": "champion"})
        write(zp, json.dumps(z, indent=1) + "")
        dp = "data/dialogue/cotswolds.json"
        d = json.loads(read(dp))
        d["cw_raf_police"] = [{"do": "say", "who": "RAF Police", "text": "Sorry, this is the road to RAF Brize Norton and it is closed to civilians. Exercise in progress. Possibly two exercises."},
                              {"do": "say", "who": "RAF Police", "text": "Come back when you are the Champion of the Open Moot. The paperwork says Champions may use the Airbridge, and it says nothing at all about anybody else."}]
        write(dp, json.dumps(d, indent=1))
    import add_memory_coach  # every Sanctuary has its retired Keeper (idempotent)
    add_memory_coach.main(path("data", "zones"))
    print("overseas data written")


if __name__ == "__main__":
    main()
