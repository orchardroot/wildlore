# Hebrides region data that is not a zone: creatures, items, shop, quests, quiz, ferry, world map, Portree's quay and
# Skye's water. Safe to re-run (every edit checks it hasn't been made already).
# Usage: python3 tools/zones/sc_hebrides_data.py     (from the repo root)
import json, re

ROOT = "."


def rd(p):
    return open(ROOT + "/" + p, encoding="utf-8").read()


def wr(p, t):
    open(ROOT + "/" + p, "w", encoding="utf-8").write(t)


def line_file(line, species):
    out = '{\n  "line": "%s",\n  "species": [\n' % line
    out += ",\n".join("    " + json.dumps(s, ensure_ascii=False) for s in species)
    return out + "\n  ]\n}\n"


# ---------------------------------------------------------------- creatures
def creatures():
    rhym = [
        {"id": "skaldling", "name": "Skaldling", "types": ["storm"], "base": {"hp": 48, "atk": 40, "def": 42, "lore": 66, "ward": 50, "spd": 62}, "growth": "medium",
         "catch_rate": 150, "base_xp": 64,
         "learnset": [[1, "static_snap"], [1, "whisper"], [5, "hail_pelt"], [9, "static_cling"], [13, "eerie_wail"], [18, "gull_scream"], [23, "ghost_light"], [28, "thunderclap"]],
         "evolves": {"to": "skaldwake", "level": 34}, "habitat": ["harris", "stornoway", "skye"], "appendix": True,
         "dex": {"text": "A wee wave in a fine blue coat that cannot hear a line of verse without finishing it. It has been known to start one first. They do not scan, and it will not be told.",
                 "fact": "In Hebridean legend the Blue Men of the Minch (na fir ghorma) live in the strait between Lewis and the Shiant Isles. They swim up to boats and call out a line of verse: a skipper who can finish the rhyme sails on, and one who cannot is overturned."},
         "sprite": "skaldling"},
        {"id": "skaldwake", "name": "Skaldwake", "types": ["storm", "spirit"], "base": {"hp": 80, "atk": 68, "def": 76, "lore": 108, "ward": 88, "spd": 66}, "growth": "medium",
         "catch_rate": 45, "base_xp": 190,
         "learnset": [[1, "static_snap"], [1, "whisper"], [5, "hail_pelt"], [9, "static_cling"], [13, "eerie_wail"], [18, "gull_scream"], [24, "thunderclap"], [28, "crossroads_whisper"],
                      [34, "minch_squall"], [40, "ball_lightning"], [46, "keening"], [52, "storm_front"], [58, "washer_at_the_ford"], [64, "wrack_bolt"]],
         "evolves": None, "habitat": ["harris"], "appendix": True,
         "dex": {"text": "The chief of the Blue Men, grey-bearded in foam, rises out of a squall with a verse in one hand and a thunderbolt in the other. He is perfectly civil to anyone with a good ear for a rhyme, and to everyone else he is a wave.",
                 "fact": "The Minch, between the Outer Hebrides and the Scottish mainland, is notorious for its sudden storms. Sailors told of the Blue Men as the cause: their chief would raise a storm and challenge the crew to a rhyming contest."},
         "sprite": "skaldwake"}]
    wr("data/creatures/skaldling.json", line_file("skaldling", rhym))
    chess = [
        {"id": "shieldbiter", "name": "Shieldbiter", "types": ["iron", "brawn"], "base": {"hp": 90, "atk": 118, "def": 105, "lore": 40, "ward": 62, "spd": 60}, "growth": "slow",
         "catch_rate": 30, "base_xp": 215,
         "learnset": [[1, "shove"], [1, "rivet"], [5, "glower"], [9, "flex"], [13, "forge_hammer"], [18, "scrum_push"], [24, "riveters_brace"], [29, "hull_clang"], [34, "haymaker"],
                      [40, "girder_sweep"], [46, "caber_toss"], [52, "girder_drop"], [58, "strongmans_yell"]],
         "evolves": None, "habitat": ["harris"], "appendix": True,
         "dex": {"text": "A stout ivory warrior in a nasal helm, with its teeth clamped on the rim of its shield and the look of someone who has just won an argument with the board. It is not angry. It has simply lost its temper, quite deliberately, for the duration.",
                 "fact": "The Lewis Chessmen are 93 pieces carved in walrus ivory and whale tooth, found in 1831 in a sandbank at Uig on the Isle of Lewis and probably made in Norway in the 1100s. The rooks are carved as berserkers biting their shields."},
         "sprite": "shieldbiter"}]
    wr("data/creatures/shieldbiter.json", line_file("shieldbiter", chess))
    t = rd("data/dex_order.json")
    d = json.loads(t)
    for i in ("skaldling", "skaldwake", "shieldbiter"):
        if i not in d:
            d.append(i)
    wr("data/dex_order.json", json.dumps(d, indent=2) + "\n")
    k = rd("data/knacks.json")
    if '"skaldling"' not in k:
        k = k.replace('"species": {\n', '"species": {\n    "skaldling": "pwnco",\n    "skaldwake": "pwnco",\n    "shieldbiter": "keen_as_mustard",\n', 1)
        wr("data/knacks.json", k)


# ---------------------------------------------------------------- items, shop
ITEMS = [
    {"id": "stornoway_black_pudding", "name": "Stornoway Black Pudding", "kind": "heal", "price": 260, "battle": True, "field": True, "amount": 110,
     "desc": "Oatmeal, beef suet, onion and blood, spiced and sliced thick. Stornoway's has protected status, like Champagne, so nobody else may call theirs that. Restores 110 HP and sets you up for the day."},
    {"id": "bere_bannock", "name": "Bere Bannock", "kind": "heal", "price": 200, "battle": True, "field": True, "amount": 90,
     "desc": "A flat, heavy scone of bere, the old Hebridean barley grown on the machair, baked on a griddle and served warm with butter. Restores 90 HP and sticks to the ribs."},
    {"id": "harris_tweed_cap", "name": "Harris Tweed Cap", "kind": "charm", "price": 0, "battle": False, "field": True, "wild": False,
     "desc": "A flat cap in handwoven Harris Tweed, with the Orb stamped inside. Wool from sheep that live outdoors all year makes cloth that shrugs off a Hebridean winter.",
     "effect_text": "Frost moves hurt it 25% less.", "charm": {"effect": "resist", "type": "frost", "mult": 0.75}, "msg": "{name}'s Harris Tweed Cap kept the cold out!"},
    {"id": "ivory_warder", "name": "Ivory Warder", "kind": "charm", "price": 0, "battle": False, "field": True, "wild": False,
     "desc": "A little carved rook in the manner of the Lewis Chessmen: a berserker in a nasal helm, biting its shield. The originals are walrus ivory from the 1100s. This is a faithful copy, and just as bad-tempered.",
     "effect_text": "Iron moves hit 20% harder.", "charm": {"effect": "boost", "type": "iron", "mult": 1.2}, "msg": "{name}'s Ivory Warder bit its shield and glared!"},
    {"id": "blue_man_pebble", "name": "Blue Man's Pebble", "kind": "charm", "price": 0, "battle": False, "field": True, "wild": False,
     "desc": "A smooth sea-blue pebble from the Minch. Sailors say the Blue Men leave one with a skipper who finishes their rhyme, and that you should keep it dry, which is not easy on the Minch.",
     "effect_text": "Storm moves hit 20% harder.", "charm": {"effect": "boost", "type": "storm", "mult": 1.2}, "msg": "{name}'s Blue Man's Pebble hummed a line of verse!"},
    {"id": "hebridean_fleece", "name": "Hebridean Fleece", "kind": "key", "price": 0, "battle": False, "field": True,
     "desc": "A thick, clean fleece clipped from a Blackface sheep on the machair. Crofters sort a fleece by feel: springy for tweed, soft for next to the skin."},
    {"id": "crotal_dye", "name": "Crotal Dye", "kind": "key", "price": 0, "battle": False, "field": True,
     "desc": "A jar of rust-brown dye simmered from crotal, the lichen scraped off Hebridean rocks. It gives wool the colour of a wet hill, and a smell to match."},
    {"id": "tweed_bolt", "name": "Length of Tweed", "kind": "key", "price": 0, "battle": False, "field": True,
     "desc": "Four metres of handwoven tweed off a croft loom, still waiting for its Orb. Until the inspector stamps it, it is only a very good cloth."},
]
for key, nm, d in [("king", "King", "A king in walrus ivory, with a sword across his knees and the look of a man who has lost his kingdom and would like a sit-down."),
                   ("queen", "Queen", "A queen with her chin in her hand and a faraway look. Every Lewis Chessmen queen is carved this way, and nobody knows why. Everyone assumes it's the weather."),
                   ("bishop", "Bishop", "A bishop in a mitre, one hand raised in blessing and the other holding a crook. His expression suggests he can hear the others arguing."),
                   ("knight", "Knight", "A knight on a stocky pony, spear in hand, shield on arm. The pony is the more worried of the two."),
                   ("warder", "Warder", "A warder, what we'd call the rook, carved as a berserker biting the top of his shield, eyes wide. It is the most cheerful piece on the board.")]:
    ITEMS.append({"id": "lewis_" + key, "name": "Chessman: " + nm, "kind": "key", "price": 0, "battle": False, "field": True, "desc": d})


def items_and_shop():
    wr("data/items/hebrides.json", "[\n" + ",\n".join("  " + json.dumps(i, ensure_ascii=False) for i in ITEMS) + "\n]\n")
    stock = ["cup_of_tea", "flask_of_tea", "bakewell_tart", "buxton_water", "smelling_salts", "kendal_mint_cake", "wicker_snare", "iron_snare", "night_snare", "water_snare",
             "scouse", "bara_brith", "silver_snare", "pasty", "cream_tea", "soda_bread", "barmbrack", "tablet", "cranachan", "irn_tonic", "lavender_sachet", "oak_acorn", "hag_stone",
             "rowan_sprig", "stornoway_black_pudding", "bere_bannock"]
    wr("data/shops/stornoway_corner_shop.json", json.dumps({"id": "stornoway_corner_shop", "name": "Stornoway Corner Shop", "stock": stock}) + "\n")


# ---------------------------------------------------------------- quests
def quests():
    q = {"quests": [
        {"id": "hebrides_tweed", "title": "The Orb Stamp", "region": "hebrides", "town": "harris", "giver": "Seonag the Weaver",
         "summary": "Weave a length of Harris Tweed on a croft loom and get it stamped with the Orb in Stornoway.",
         "start_flag": "q_hebrides_tweed_started",
         "steps": [
             {"flag": "q_hebrides_tweed_1", "text": "Get a fleece from Crofter Murdo, out on the machair beside the weaver's croft.", "zone": "harris"},
             {"flag": "q_hebrides_tweed_2", "text": "Get crotal dye from Peigi the Dyer, outside the blackhouses at Gearrannan.", "zone": "harris"},
             {"flag": "q_hebrides_tweed_3", "text": "Take the fleece and dye to Seonag and weave the length on her loom.", "zone": "harris_weaver"},
             {"flag": "q_hebrides_tweed_4", "text": "Take the tweed to the Harris Tweed Authority in Stornoway for the Orb stamp.", "zone": "stornoway_tweed"}],
         "done_flag": "q_hebrides_tweed_done", "reward": "A Harris Tweed Cap (a charm: frost moves hurt less) and standing in Scotland."},
        {"id": "hebrides_chessmen", "title": "The Scattered Chessmen", "region": "hebrides", "town": "stornoway", "giver": "The Curator",
         "summary": "Five carved ivory chessmen have turned up around Harris and Lewis. Find them, then face the chess champion of Stornoway.",
         "start_flag": "q_hebrides_chess_started",
         "steps": [
             {"flag": "q_hebrides_chess_1", "text": "Find all five chessmen: a king at Callanish, a queen at Gearrannan, a bishop at Luskentyre, a knight by the Tarbert quay and a warder in the dune at Uig.", "zone": "harris"},
             {"flag": "q_hebrides_chess_2", "text": "Take them to the Curator at Museum nan Eilean, in Lews Castle.", "zone": "stornoway_castle"},
             {"flag": "q_hebrides_chess_3", "text": "Beat Chess Master Ailsa at her board in the museum.", "zone": "stornoway_castle"}],
         "done_flag": "q_hebrides_chess_done", "reward": "The Ivory Warder (a charm: iron moves hit harder), the prize money and standing in Scotland."},
        {"id": "hebrides_bluemen", "title": "The Blue Men of the Minch", "region": "hebrides", "town": "stornoway", "giver": "The Old Skipper",
         "summary": "Befriend one of the Blue Men's little ones, learn how a rhyme goes, and out-rhyme the Blue Men of the Minch.",
         "start_flag": "q_hebrides_rhyme_started",
         "steps": [
             {"flag": "q_hebrides_rhyme_1", "text": "Catch a Skaldling in the water round Harris or Stornoway and show the Old Skipper at the harbour.", "zone": "stornoway"},
             {"flag": "q_hebrides_rhyme_2", "text": "Learn how a rhyme goes from the Bard at the Minch Arms.", "zone": "stornoway_pub"},
             {"flag": "q_hebrides_rhyme_3", "text": "At the end of the quay, in a gale, a fog or the dark, finish the Blue Men's three rhymes, then face them.", "zone": "stornoway"}],
         "done_flag": "q_hebrides_rhyme_done", "reward": "The Blue Man's Pebble (a charm: storm moves hit harder), the prize money and standing in Scotland."}]}
    t = "{\"quests\": [\n"
    t += ",\n".join(" " + json.dumps(x, ensure_ascii=False) for x in q["quests"])
    wr("data/quests/hebrides.json", t + "\n]}\n")


# ---------------------------------------------------------------- quiz
QUIZ = [
    ("history", "Which Scottish island's sandbank gave up the Lewis Chessmen in 1831?", "Lewis", ["Skye", "Orkney", "Islay"], "The 93 carved pieces were found at Uig, on the west of Lewis."),
    ("history", "Who is credited with the first Orb mark on Harris Tweed cloth?", "The Harris Tweed Association (1909)", ["The Lord Lyon", "The Post Office", "A Glasgow mill"], "The Orb became a registered trademark in 1909, and the Harris Tweed Act of 1993 protects it in law."),
    ("culture", "By law, where must Harris Tweed be woven?", "By islanders at their homes in the Outer Hebrides", ["In a Glasgow mill", "On Skye, by the sea", "Anywhere in the Highlands"], "The Orb mark means woven by hand in the Outer Hebrides, from wool dyed and spun there."),
    ("food", "Which protected-status food is made in Stornoway?", "Black pudding", ["Cranachan", "Cullen skink", "Haggis"], "Stornoway Black Pudding has protected geographical status, like Champagne."),
    ("history", "About how old are the Callanish stones on Lewis?", "About 5,000 years", ["About 500 years", "About 1,000 years", "About 2,000 years"], "They were raised around 3,000 BC, older than Stonehenge."),
    ("nature", "Which secretive bird's rasping crex crex call is heard on Hebridean machair at night?", "The corncrake", ["The curlew", "The lapwing", "The nightjar"], "The Hebrides are one of the corncrake's last strongholds in Britain."),
    ("geography", "What is the Gaelic name for Stornoway?", "Steòrnabhagh", ["Inbhir Nis", "Port Righ", "Tairbeart"], "The name comes from the Old Norse for the 'steering bay'."),
    ("folklore", "In legend, what do the Blue Men of the Minch demand of a passing skipper?", "To finish their rhyme", ["A coin for the ferry", "A song in Gaelic", "A pot of tea"], "The skipper who can complete the rhyme sails on, and one who cannot is overturned."),
    ("culture", "What is a taigh dubh?", "A blackhouse", ["A whisky still", "A fishing boat", "A peat spade"], "The thick-walled thatched blackhouses of the Hebrides were lived in until the 20th century."),
    ("nature", "What is machair, found on the Atlantic coast of Scotland and Ireland?", "A low, flower-rich coastal grassland", ["A kind of peat", "A mountain pass", "A sea loch"], "Shell-sand blown inland makes the soil limy and the meadow full of flowers."),
]


def quiz():
    t = rd("data/quiz/questions.json")
    if "Lewis Chessmen in 1831" in t:
        return
    add = ""
    for (cat, q, a, wrong, fact) in QUIZ:
        add += ",\n\t" + json.dumps({"cat": cat, "region": "scotland", "q": q, "a": a, "wrong": wrong, "fact": fact}, ensure_ascii=False)
    i = t.rstrip().rfind("]")
    wr("data/quiz/questions.json", t[:i].rstrip() + add + "\n]\n")


# ---------------------------------------------------------------- ferry, map, Portree, Skye
def ferry_and_map():
    f = json.loads(rd("data/ferries.json"))
    f["portree_tarbert"] = {"a": "portree", "b": "harris", "ship": "the Sound of Harris",
                            "music": "ferry_north_channel",
                            "card": "Out past Raasay and across the Little Minch. The ship rolls, the gulls scold and somewhere to starboard a swell in a blue coat looks as if it might be about to say something."}
    wr("data/ferries.json", json.dumps(f, indent=1, ensure_ascii=False) + "\n")
    m = rd("data/world_map.json")
    if '"stornoway"' not in m:
        dun = '"dundee": {"name": "Dundee", "x": 618, "y": 408, "nation": "scotland", "island": "gb"}'
        assert dun in m
        m = m.replace(dun, dun + ', "stornoway": {"name": "Stornoway", "x": 355, "y": 173, "nation": "scotland", "island": "gb"}', 1)
        fb = '"forth_bridges": {"x": 587, "y": 466}'
        assert fb in m
        m = m.replace(fb, fb + ', "harris": {"x": 318, "y": 216}', 1)
        mm = re.search(r'"gweedore_tory": \[[^\]]*\]', m)
        assert mm
        m = m[:mm.end()] + ', "portree_tarbert": [370.0, 280.0, 352.0, 262.0, 336.0, 236.0, 324.0, 215.0]' + m[mm.end():]
        wr("data/world_map.json", m)
    # Portree's quay: a ferry hand and the landing tile
    z = json.loads(rd("data/zones/portree.json"))
    if "ferry" not in z:
        z["ferry"] = {"x": 34, "y": 11, "route": "portree_tarbert"}
        z["npcs"].append({"id": "por_ferryhand", "sprite": "sailor", "x": 35, "y": 11, "facing": "left", "move": "still", "script": "por_ferryhand", "name": "Ferry Hand"})
        wr("data/zones/portree.json", json.dumps(z, indent=1, ensure_ascii=False))
        dl = rd("data/dialogue/portree.json").rstrip()
        assert dl.endswith("}")
        add = {"por_ferryhand": [
            {"do": "say", "who": "Ferry Hand", "text": "The Harris boat. Across the Little Minch to Tarbert, on the Isle of Harris, in the Outer Hebrides. Fàilte, if you're going: that's welcome. Gaelic first, English second, sheep before either."},
            {"do": "ferry", "route": "portree_tarbert"}]}
        body = json.dumps(add, indent=1, ensure_ascii=False)[1:-1].rstrip()
        wr("data/dialogue/portree.json", dl[:-1].rstrip() + "," + body + "\n}\n")
    # Skye: a few Skaldlings in the water along the west side
    s = rd("data/zones/skye.json")
    if "skaldling" not in s:
        z = json.loads(s)
        z["encounters"]["water"].insert(0, {"species": "skaldling", "min": 74, "max": 76, "weight": 6, "weather": ["gale", "fog"]})
        wr("data/zones/skye.json", json.dumps(z, indent=1, ensure_ascii=False))


JOBS = [
    {"id": "stornoway_seals", "nation": "scotland", "town": "stornoway", "badges": 9, "poster": "Stornoway Harbour Trust",
     "title": "Seal census", "text": "The harbour seals sunbathe on the skerries and refuse to be counted. Catch a grey seal for the register, and write down that it looked pleased with itself. They all do.",
     "step": {"type": "catch", "species": "greyhaul"}, "pay": 3},
    {"id": "stornoway_bannocks", "nation": "scotland", "town": "stornoway", "badges": 9, "poster": "An Lanntair Ceilidh Committee",
     "title": "Bannocks for the ceilidh", "text": "Saturday's ceilidh is short of bannocks, and a ceilidh without a bannock is only a lot of people standing about. Two bere bannocks, please, from the corner shop. Mòran taing.",
     "step": {"type": "bring", "item": "bere_bannock", "n": 2}, "pay": 1},
]


def jobs():
    t = rd("data/jobs.json")
    if "stornoway_seals" in t:
        return
    i = t.rindex("\n ]")
    add = ",\n".join("  " + json.dumps(j, ensure_ascii=False) for j in JOBS)
    wr("data/jobs.json", t[:i] + ",\n" + add + t[i:])


if __name__ == "__main__":
    creatures()
    items_and_shop()
    quests()
    quiz()
    ferry_and_map()
    jobs()
    print("hebrides data: written")
