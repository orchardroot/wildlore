# Plain-data side of the Cotswolds and Oxford region (3.0 Wider Isles): items, shops, quests, quiz questions, the
# two new creature lines, the world map and the Birmingham gate. Idempotent: run it from the repo root after
# `python3 tools/zones/cotswolds.py data/zones`.
#
#   python3 tools/zones/cotswolds_data.py
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def path(*p):
    return os.path.join(ROOT, *p)


def read(p):
    return open(path(p), encoding="utf-8").read()


def write(p, text):
    open(path(p), "w", encoding="utf-8").write(text)


def lines_json(items):
    return "[\n" + ",\n".join(" " + json.dumps(i, ensure_ascii=False) for i in items) + "\n]\n"


# ---------------------------------------------------------------------------------------------- items and shops
ITEMS = [
    {"id": "double_gloucester", "name": "Double Gloucester", "kind": "heal", "price": 600, "battle": True, "field": True, "amount": 190,
     "desc": "A big orange wheel of Gloucestershire cheese, rich and nutty, the sort they roll down Cooper's Hill every spring. Colour from a seed called annatto, flavour from the cows. Restores 190 HP."},
    {"id": "banbury_cake", "name": "Banbury Cake", "kind": "heal", "price": 420, "battle": True, "field": True, "amount": 140,
     "desc": "A little oval of flaky pastry stuffed with spiced currants, from Banbury, just up the road from Oxford. People have been baking them since at least the 1500s. Restores 140 HP."},
    {"id": "oxford_marmalade", "name": "Oxford Marmalade", "kind": "heal", "price": 380, "battle": True, "field": True, "amount": 120,
     "desc": "Thick-cut Seville orange marmalade, dark and bitter and sweet, on toast. Sarah Cooper first made it in 1874 in her husband's High Street shop, and Captain Scott took it to the Antarctic. Restores 120 HP."},
    {"id": "coopers_wheel", "name": "Cooper's Hill Ribbon", "kind": "charm", "price": 0, "battle": False, "field": True, "wild": True,
     "desc": "A red ribbon from the cheese-rolling at Cooper's Hill, where people chase a rolling Double Gloucester down a slope so steep nobody can stay upright. The winner is the first to the bottom, and usually the one with the most grass on them.",
     "effect_text": "Its Brawn moves hit 20% harder.", "charm": {"effect": "boost", "type": "brawn", "mult": 1.2}, "msg": "{name} tumbles into action under the Cooper's Hill Ribbon!"},
    {"id": "rollright_pebble", "name": "Rollright Pebble", "kind": "charm", "price": 0, "battle": False, "field": True, "wild": True,
     "desc": "A small oolitic limestone pebble from beside the Rollright Stones. Folk say the King's Men have been standing about since 2500 BC, which has taught them to hold their ground.",
     "effect_text": "Ward up when it first comes out.", "charm": {"effect": "start_stage", "stat": "ward", "stages": 1}, "msg": "{name} stands its ground, like a King's Man!"},
    {"id": "readers_ticket", "name": "Reader's Ticket", "kind": "charm", "price": 0, "battle": False, "field": True, "wild": True,
     "desc": "A Bodleian reader's card, stamped, with the Declaration printed on the back: no fire or flame, no marking, no removing, no smoking. It has never been known to be refused.",
     "effect_text": "Lore up when it first comes out.", "charm": {"effect": "start_stage", "stat": "lore", "stages": 1}, "msg": "{name} has read up on the matter!"},
    {"id": "cotswold_fleece", "name": "Cotswold Fleece", "one": "a Cotswold Fleece", "kind": "material", "price": 0, "battle": False, "field": False,
     "desc": "A hank of long, lustrous wool from a Cotswold Lion. This breed's fleece was the wealth of the wool churches and merchants' houses, and smells of a very damp, very pleased sheep."},
]
BASE_STOCK = ["cup_of_tea", "flask_of_tea", "bakewell_tart", "buxton_water", "smelling_salts", "kendal_mint_cake", "wicker_snare",
              "iron_snare", "night_snare", "water_snare", "scouse", "bara_brith", "silver_snare", "pasty", "cream_tea", "soda_bread",
              "barmbrack", "tablet", "cranachan", "irn_tonic", "yorkshire_pudding", "parkin", "pork_pie"]
SHOPS = {
    "cotswolds_corner_shop": ("Cotswolds Corner Shop", BASE_STOCK + ["double_gloucester", "lavender_sachet"]),
    "oxford_corner_shop": ("Alice's Shop", BASE_STOCK + ["double_gloucester", "banbury_cake", "oxford_marmalade", "lavender_sachet"]),
}

# ---------------------------------------------------------------------------------------------- quests
QUESTS_COTS = {"quests": [
    {"id": "cotswolds_cheese", "title": "Down Cooper's Hill", "region": "cotswolds", "town": "cotswolds", "giver": "Master of Ceremonies",
     "summary": "Win the creature version of the Cooper's Hill cheese-rolling: chase a Double Gloucester down a hill too steep to stand on.",
     "start_flag": "q_cotswolds_cheese_started",
     "steps": [
         {"flag": "q_cotswolds_cheese_1", "text": "Learn the rules from the cheesemaker at Cooper's Hill Dairy, at the bottom of the hill.", "zone": "cotswolds_dairy"},
         {"flag": "q_cotswolds_cheese_2", "text": "Catch a Gloucelet in the tall grass and show it to the cheesemaker.", "zone": "cotswolds_dairy"},
         {"flag": "q_cotswolds_cheese_3", "text": "Win the race: three chasers, back to back, down Cooper's Hill.", "zone": "cotswolds"}],
     "done_flag": "q_cotswolds_cheese_done", "reward": "Three Double Gloucester, the Cooper's Hill Ribbon (a Brawn charm) and standing in England."},
    {"id": "cotswolds_stones", "title": "You Can't Count Them Twice", "region": "cotswolds", "town": "cotswolds", "giver": "Stone Keeper",
     "summary": "The Rollright Stones can never be counted the same twice. Count them from three sides and see.",
     "start_flag": "q_cotswolds_stones_started",
     "steps": [
         {"flag": "q_cotswolds_stones_1", "text": "Ask the counter on the north side of the King's Men how many stones there are.", "zone": "cotswolds"},
         {"flag": "q_cotswolds_stones_2", "text": "Ask the counter on the east side.", "zone": "cotswolds"},
         {"flag": "q_cotswolds_stones_3", "text": "Ask the counter on the west side.", "zone": "cotswolds"},
         {"flag": "q_cotswolds_stones_4", "text": "Tell the Stone Keeper what you found.", "zone": "cotswolds"}],
     "done_flag": "q_cotswolds_stones_done", "reward": "The Rollright Pebble (a Ward charm), two Banbury Cakes and standing in England."}]}
QUESTS_OX = {"quests": [
    {"id": "oxford_bodleian", "title": "The Bodleian Declaration", "region": "oxford", "town": "oxford", "giver": "Librarian",
     "summary": "Swear the Bodleian oath, never to kindle fire or flame, then find the bestiary leaf a don has borrowed.",
     "start_flag": "q_oxford_bodleian_started",
     "steps": [
         {"flag": "q_oxford_bodleian_1", "text": "Make the Declaration to the Librarian at the Bodleian, and ask about the missing leaf.", "zone": "oxford_bodleian"},
         {"flag": "q_oxford_bodleian_2", "text": "Ask the clerk in the Radcliffe Camera which way the reader went.", "zone": "oxford_camera"},
         {"flag": "q_oxford_bodleian_3", "text": "Find the don in the back of the Eagle and Child, and win the leaf back.", "zone": "oxford_eagle"},
         {"flag": "q_oxford_bodleian_4", "text": "Return the leaf to the Librarian at the Bodleian.", "zone": "oxford_bodleian"}],
     "done_flag": "q_oxford_bodleian_done", "reward": "The Reader's Ticket (a Lore charm), two Banbury Cakes and standing in England."}]}


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


DODO = {"id": "dodo", "name": "Dodo", "types": ["spirit", "kin"], "base": {"hp": 100, "atk": 55, "def": 82, "lore": 100, "ward": 90, "spd": 38},
        "growth": "slow", "catch_rate": 45, "base_xp": 190,
        "learnset": [[1, "scrap"], [1, "whisper"], [5, "rap_on_pane"], [9, "hunker"], [13, "quick_nip"], [17, "eerie_wail"], [21, "mums_look"],
                     [26, "deathwatch_tap"], [31, "barge"], [36, "passing_bell"], [42, "keening"], [48, "ghost_light"], [54, "poltergeist"]],
        "evolves": None, "habitat": [], "appendix": True,
        "dex": {"text": "A large, sad, blue-grey bird that steps out of its glass case on a quiet day and looks at you as though you owe it an apology. It has been waiting four hundred years, and it is not in a hurry.",
                "fact": "The Oxford Dodo, in the University Museum of Natural History, is the only dodo with soft tissue left anywhere in the world: a head and a foot, saved in 1755 when the Ashmolean's stuffed dodo was thrown out. Lewis Carroll put a Dodo in Alice's Adventures in Wonderland, partly as a joke on his own stammered name, Do-do-Dodgson."},
        "sprite": "dodo"}
GLOUCELET = {"id": "gloucelet", "name": "Gloucelet", "types": ["brawn", "hearth"], "base": {"hp": 62, "atk": 70, "def": 58, "lore": 40, "ward": 40, "spd": 40},
             "growth": "medium", "catch_rate": 150, "base_xp": 62,
             "learnset": [[1, "shove"], [1, "snug_as_a_bug"], [5, "kindle"], [9, "scrum_push"], [13, "hot_conker"], [17, "hob_sizzle"], [21, "flex"], [25, "smoulder"], [29, "haymaker"]],
             "evolves": {"to": "doublewheel", "level": 34}, "habitat": ["cotswolds"], "appendix": True,
             "dex": {"text": "A small round of cheese that has taken against the hill it was born on and means to get to the bottom of it. It rolls when it is cross, which is nearly always, and it smells wonderful while it does.",
                     "fact": "Double Gloucester is made from full-cream milk, pressed into big wheels, turned daily and matured for months. Its warm orange colour traditionally comes from annatto, a seed, and a wheel is rolled down Cooper's Hill near Gloucester each spring bank holiday."},
             "sprite": "gloucelet"}
DOUBLEWHEEL = {"id": "doublewheel", "name": "Doublewheel", "types": ["brawn", "hearth"], "base": {"hp": 100, "atk": 112, "def": 100, "lore": 55, "ward": 66, "spd": 50},
               "growth": "medium", "catch_rate": 60, "base_xp": 168,
               "learnset": [[1, "shove"], [1, "snug_as_a_bug"], [5, "kindle"], [9, "scrum_push"], [13, "hot_conker"], [17, "hob_sizzle"], [21, "flex"], [25, "smoulder"],
                            [29, "haymaker"], [34, "pit_pony_charge"], [38, "aga_roast"], [42, "caber_toss"], [46, "burnt_cakes"], [52, "blaze_dash"], [58, "chimney_crash"]],
               "evolves": None, "habitat": [], "appendix": True,
               "dex": {"text": "Two wheels stacked and a face like someone who has been rolled down a hill forty times and enjoyed every one. It never actually wins the race. It just arrives, shortly after the cheese, with the look of a champion.",
                       "fact": "The Cooper's Hill cheese-rolling has been held for at least two hundred years. A wheel of Double Gloucester of about three to four kilograms is sent down a slope as steep as one in two, and the first person to reach the bottom wins it."},
               "sprite": "doublewheel"}
KNACKS = {
    "not_quite_extinct": {"name": "Not Quite Extinct", "desc": "At full HP, a knockout blow leaves it hanging on with 1 HP.", "msg": "{name} is not quite extinct yet!", "endure_full": True},
    "thick_rind": {"name": "Thick Rind", "desc": "A good waxed rind: foes can't lower its stats, and brook and tide moves hurt it a quarter less.",
                   "msg_drop": "{name}'s rind is far too thick to dent!", "no_drops": True, "resist": {"types": ["brook", "tide"], "mult": 0.75}},
}
KNACK_MAP = {"dodo": "not_quite_extinct", "gloucelet": "thick_rind", "doublewheel": "thick_rind"}

QUIZ = [
    {"cat": "history", "region": "england_south", "q": "Which Oxford library, founded in 1602 by Sir Thomas Bodley, is entitled to a copy of every book published in the UK?", "a": "The Bodleian Library", "wrong": ["The Radcliffe Library", "The Ashmolean Library", "The Christ Church Library"], "fact": "Readers still make a declaration before they use it, promising not to kindle fire or flame inside."},
    {"cat": "culture", "region": "england_south", "q": "Which round, domed Oxford building of 1749, designed by James Gibbs, is a Bodleian reading room?", "a": "The Radcliffe Camera", "wrong": ["The Sheldonian Theatre", "Carfax Tower", "The Bridge of Sighs"], "fact": "'Camera' is Latin for a room, nothing to do with photographs."},
    {"cat": "folklore", "region": "england_south", "q": "Which stone circle on the Oxfordshire border is said to be impossible to count the same twice?", "a": "The Rollright Stones", "wrong": ["Avebury", "Castlerigg", "Stonehenge"], "fact": "Legend says a king and his army were turned to stone by a witch, and the stones will not be counted."},
    {"cat": "food", "region": "england_south", "q": "What is rolled down Cooper's Hill in Gloucestershire every spring bank holiday, with people chasing it?", "a": "A wheel of Double Gloucester cheese", "wrong": ["A barrel of cider", "A bale of wool", "A pumpkin"], "fact": "The hill is so steep that the cheese is said to reach 70 mph. The winner gets the cheese."},
    {"cat": "creatures", "region": "england_south", "q": "Which extinct bird's head and foot are the world's only soft tissue of its kind, kept in the Oxford University Museum of Natural History?", "a": "The dodo", "wrong": ["The great auk", "The passenger pigeon", "The moa"], "fact": "The Ashmolean's stuffed dodo was thrown out in 1755, but a clerk saved its head and a foot."},
    {"cat": "culture", "region": "england_south", "q": "Which Christ Church mathematics tutor wrote Alice's Adventures in Wonderland under a pen name?", "a": "Charles Dodgson (Lewis Carroll)", "wrong": ["J. R. R. Tolkien", "C. S. Lewis", "Kenneth Grahame"], "fact": "The story was first told on a river trip in 1862 to Dean Liddell's daughter Alice and her sisters."},
    {"cat": "folklore", "region": "england_south", "q": "How many times does Great Tom, the bell at Christ Church, ring each night at 9.05 pm?", "a": "101", "wrong": ["99", "100", "120"], "fact": "Once for each of the college's original students, to send them home."},
    {"cat": "culture", "region": "england_south", "q": "In which Oxford pub's back room did the Inklings, including Tolkien and C. S. Lewis, meet to read their work aloud?", "a": "The Eagle and Child", "wrong": ["The Turf Tavern", "The Bear", "The Lamb and Flag"], "fact": "The pub is known locally as the Bird and Baby."},
    {"cat": "geography", "region": "england_south", "q": "Which Oxford bridge of 1914, linking two parts of a college, is nicknamed after a famous bridge in Venice?", "a": "Hertford Bridge, the Bridge of Sighs", "wrong": ["Magdalen Bridge", "Folly Bridge", "Hythe Bridge"], "fact": "It crosses New College Lane, and looks more like the Rialto than the real Bridge of Sighs."},
    {"cat": "creatures", "region": "england_south", "q": "Which long-woolled sheep with a shaggy forelock built the wealth of the Cotswold wool churches?", "a": "The Cotswold Lion", "wrong": ["The Herdwick", "The Texel", "The Jacob"], "fact": "The breed is rare now, but its wool once clothed half of Europe."},
    {"cat": "history", "region": "england_south", "q": "What was the corrugated iron shed in James Murray's garden, where Oxford English Dictionary slips were sorted, called?", "a": "The Scriptorium", "wrong": ["The Wordhouse", "The Lexicon", "The Glossary"], "fact": "Thousands of volunteers posted in quotations on slips of paper."},
    {"cat": "nature", "region": "england_south", "q": "What kind of rock are the honey-coloured buildings of the Cotswolds built from?", "a": "Oolitic limestone", "wrong": ["Granite", "Sandstone", "Chalk"], "fact": "It formed in warm Jurassic seas about 167 million years ago, and the iron in it gives it the honey colour."},
    {"cat": "culture", "region": "england_south", "q": "On which day does the Magdalen College choir sing from the top of the tower at six in the morning?", "a": "1 May", "wrong": ["21 June", "25 December", "1 January"], "fact": "It is called May Morning, and Oxford turns out for morris dancing and breakfast."},
    {"cat": "geography", "region": "england_south", "q": "Which Cotswold town, the highest in the region, has the rhyme 'where the wind blows cold'?", "a": "Stow-on-the-Wold", "wrong": ["Cirencester", "Burford", "Moreton-in-Marsh"], "fact": "It stands at nearly 250 metres, and ancient roads, including the Fosse Way, meet here."},
]


# ---------------------------------------------------------------------------------------------- main
def main():
    # items and shops
    write("data/items/cotswolds.json", lines_json(ITEMS))
    for sid, (name, stock) in SHOPS.items():
        write("data/shops/%s.json" % sid, json.dumps({"id": sid, "name": name, "stock": stock}) + "\n")
    # quests
    write("data/quests/cotswolds.json", quests_text(QUESTS_COTS))
    write("data/quests/oxford.json", quests_text(QUESTS_OX))
    # creatures
    write("data/creatures/dodo.json", line_file("dodo", [DODO]))
    write("data/creatures/gloucelet.json", line_file("gloucelet", [GLOUCELET, DOUBLEWHEEL]))
    order = read("data/dex_order.json")
    for sid in ("dodo", "gloucelet", "doublewheel"):
        if '"%s"' % sid not in order:
            i = order.rindex('"') + 1
            order = order[:i] + ',\n  "%s"' % sid + order[i:]
    write("data/dex_order.json", order)
    # knacks
    kn = read("data/knacks.json")
    if '"thick_rind"' not in kn:
        mark = '\n  },\n  "species": {'
        i = kn.index(mark)
        add = "".join(',\n    "%s": %s' % (k, json.dumps(v, ensure_ascii=False)) for k, v in KNACKS.items())
        kn = kn[:i] + add + kn[i:]
        last = kn.rindex('"\n  }\n}')
        kn = kn[:last + 1] + "".join(',\n    "%s": "%s"' % (k, v) for k, v in KNACK_MAP.items()) + kn[last + 1:]
        write("data/knacks.json", kn)
    # quiz
    qz = read("data/quiz/questions.json")
    if "Rollright Stones" not in qz:
        i = qz.rindex("}") + 1
        qz = qz[:i] + "".join(",\n\t" + json.dumps(q, ensure_ascii=False) for q in QUIZ) + qz[i:]
        write("data/quiz/questions.json", qz)
    # world map: a town, a place, two rail legs (text insertions, so other regions' additions merge cleanly)
    wm = read("data/world_map.json")
    if '"oxford"' not in wm:
        a = '"birmingham": {"name": "Birmingham", "x": 700, "y": 939, "nation": "england", "island": "gb"},'
        assert a in wm
        wm = wm.replace(a, a + ' "oxford": {"name": "Oxford", "x": 749, "y": 1038, "nation": "england", "island": "gb"},')
        b = '"avon_gorge": {"x": 643, "y": 1082},'
        assert b in wm
        wm = wm.replace(b, b + ' "cotswolds": {"x": 713, "y": 1016},')
        c = '"rail": [['
        assert wm.count(c) == 1
        wm = wm.replace(c, '"rail": [[700.0, 939.5, 749.0, 1038.0], [749.0, 1038.0, 836.2, 1070.8], [')
        write("data/world_map.json", wm)
    # Birmingham: open the east gate onto the Cotswolds road
    bz = read("data/zones/birmingham.json")
    if '"to": "cotswolds"' not in bz:
        row = '  "F==============================================================F",'
        assert bz.count(row) == 3
        bz = bz.replace(row, '  "F' + '=' * 63 + '",')
        old = '   "x": 62,\n   "y": 25,\n   "text": "Road to Coventry closed for resurfacing. Again. Sorry for any inconvenience."'
        assert old in bz
        bz = bz.replace(old, '   "x": 61,\n   "y": 28,\n   "text": "EAST: the A44 to the Cotswolds and Oxford. (Coventry is closed for resurfacing. Again. Sorry for any inconvenience.)"')
        old = '  "south": {\n   "to": "salisbury_plain",\n   "offset": 0\n  }'
        assert old in bz
        bz = bz.replace(old, old + ',\n  "east": {\n   "to": "cotswolds",\n   "offset": 0\n  }')
        write("data/zones/birmingham.json", bz)
    print("cotswolds data written")


if __name__ == "__main__":
    main()
