# Wider Isles, region R5: Swansea (Abertawe) and Gower (Gŵyr), hung off the south side of the Brecon Beacons.
#   python3 tools/zones/r5_swansea.py data/zones
# Writes swansea, gower and their interiors, plus their dialogue and trainers. Everything is scaled from par 33
# (the Beacons' band), so it is worth a visit whenever you wander down from the hills.
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ie_common import *
from ie_common import _stand
from p6a_common import smooth, done
from zlib import landmark

FLOOR = 33
SW = "south_wales"
Q = "q_swansea_"


def T(tid, name, cls, sprite, party, intro, win, after, money):
    """a scaled trainer file only (fought through a script or an npc's "trainer")."""
    TRN[tid] = {"id": tid, "name": name, "class": cls, "sprite": sprite, "scaled_floor": FLOOR,
                "party": [{"species": s, "level": l} for s, l in party], "ai": "trainer", "money": money,
                "intro": say(name, *intro), "win": win, "after": after}


def trn(z, tid, name, cls, sprite, party, x, y, facing, intro, win, after, money, move="still"):
    trainer(z, tid, name, cls, sprite, party, x, y, facing, intro, win, after, money, move)
    TRN[tid]["scaled_floor"] = FLOOR


def plaque(z, pid, x, y, title, text):
    z.d["signs"].append({"x": x, "y": y, "plaque": "swansea_" + pid, "title": title, "text": text})


def flag_if(flag, then, other=None):
    return {"do": "if", "flag": flag, "then": then, "else": other or []}


def flag_l(flag, then, other=None):
    return [flag_if(flag, then, other)]


def setf(flag, value=True):
    return {"do": "set", "flag": flag, "value": value}


def interior(OUT, zid, name, town, ret, kind, npcs, w=13, h=10, extra=(), furnish=True, music="", drop=()):
    z = landmark(OUT, zid, name, town, ret, kind, npcs, w=w, h=h, furnish=furnish, write=False)
    z.d["props"] = [q for q in z.d["props"] if q["type"] not in drop]
    taken = {(p["x"], p["y"]) for p in z.d["props"]} | {(n["x"], n["y"]) for n in z.d["npcs"]}
    for p in extra:
        if (p["x"], p["y"]) in taken and not p.get("walk"):
            # make room: our own furniture wins over the furnisher's
            z.d["props"] = [q for q in z.d["props"] if not (q["x"] == p["x"] and q["y"] == p["y"])]
        z.d["props"].append(dict(p))
    if music:
        z.d["music"] = music
    z.save(OUT + "/" + zid + ".json")
    return z


def P(t, x, y, **kw):
    d = {"type": t, "x": x, "y": y}
    d.update(kw)
    return d


# ======================================================================================================== Swansea
def swansea(OUT):
    W, H = 76, 60
    zid = "swansea"
    z = Z(zid, "Swansea", W, H, kind="town", region=SW, music="town_city",
          weather={"drizzle": 34, "downpour": 14, "clear": 18, "sunshine": 18, "gale": 10, "fog": 6})
    z.d["stage"] = "coast"; z.d["town_id"] = zid; z.d["scaled_floor"] = FLOOR
    z.legend["g"] = {"tile": "grass", "colour": "#7f9655"}
    z.rect(0, 0, W, H, "g")
    z.border("T", 2, gaps=[(34, 0, 3, 2), (0, 40, 2, 3)])
    z.scatter(0, 0, W, H, "P", 24, 51, only="T")
    # hills: the Uplands (Cwmdonkin), Kilvey Hill over the river, Mumbles Hill
    hills(z, [(15, 6, 2, 7), (71, 10, 3, 12), (7, 46, 2, 6)])

    # --- Swansea Bay: the prom, the sand, the sea; the Tawe running in from the north
    z.rect(14, 47, 50, 1, "#")
    z.rect(14, 48, 50, 3, "s")
    z.rect(14, 51, 50, 1, "w")
    z.rect(14, 52, 50, 1, "o")
    z.rect(0, 53, W, 7, "$")
    z.rect(14, 52, 1, 1, "$")
    z.rect(65, 2, 2, 51, "~"); z.rect(64, 2, 1, 49, "w"); z.rect(67, 2, 1, 46, "w")
    z.rect(68, 46, 6, 5, "s"); z.rect(67, 48, 7, 3, "s"); z.rect(64, 51, 10, 2, "$")
    # Mumbles: the headland, its islands and lighthouse
    z.rect(2, 52, 12, 2, "g")
    z.rect(0, 54, 14, 6, "$")
    z.rect(3, 52, 3, 1, "R"); z.rect(10, 53, 3, 1, "R")
    z.rect(3, 56, 4, 3, "s"); z.prop("lighthouse", 4, 57)
    z.rect(8, 57, 2, 1, "R")
    for y in range(52, 54):
        for x in range(0, 2):
            z.set(x, y, "T")

    # --- the north: the road down from the Beacons, the Liberty, the station, Hafod-Morfa
    z.rect(34, 0, 3, 23, "=")
    z.rect(33, 2, 1, 17, ":"); z.rect(37, 2, 1, 10, ":")
    z.building(41, 2, 14, 9, "football_stadium", "The Liberty Stadium", door=7)
    z.warp(48, 10, "swansea_stadium", 6, 7, "up")
    z.rect(37, 11, 20, 1, "#")
    z.prop("bench", 44, 12); z.prop("lamp_post", 42, 12); z.prop("lamp_post", 54, 12); z.prop("flagpole", 39, 10, variant=0)
    # Swansea station: a terminus, buffers at the town end
    station(z, 40, 14, 8, 4, "Swansea Station")
    z.rect(38, 16, 2, 1, ":"); z.rect(48, 16, 2, 1, ":")
    z.prop("buffer_stop", 39, 17); z.prop("tunnel_portal", 48, 17)
    rail_guard(z, 46, 16, ["Abertawe! Swansea, end of the line. Croeso, that's welcome. Trains back out the way they came in.",
                           "Mind the gap and mind the gulls. They take the crusts off your sandwiches and then complain about the filling."], facing="left")
    # Hafod-Morfa copperworks on the west bank of the Tawe
    z.building(53, 14, 8, 5, "engine_house", "Hafod-Morfa Copperworks", door=4)
    z.warp(57, 18, "swansea_copperworks", 6, 7, "up")
    z.rect(52, 19, 12, 1, "#"); z.rect(57, 12, 1, 2, "#")
    for (x, y) in [(51, 14), (51, 15), (62, 14), (62, 15), (62, 16)]:
        z.set(x, y, "W")
    for (x, y, v) in [(50, 17, 0), (61, 12, 1), (59, 12, 2), (62, 18, 0)]:
        z.prop("slate_heap", x, y, variant=v)
    # the Uplands: Cwmdonkin Park and Cwmdonkin Drive
    blob(z, 14, 6, 8, 3.5, ",", only="g", seed=11, jitter=0.4)
    blob(z, 26, 8, 4, 3, ",", only="g", seed=12, jitter=0.4)
    z.rect(4, 10, 26, 1, "#"); z.rect(16, 3, 1, 8, "#")
    z.prop("standing_stone", 17, 7, variant=1); z.prop("bench", 15, 9); z.prop("bench", 19, 9)
    scatter_props(z, "oak", 3, 3, 28, 9, 12, 13, avoid=("g",))
    z.building(4, 12, 9, 3, "terrace", "Cwmdonkin Drive")
    z.building(13, 12, 5, 3, "terrace", "5 Cwmdonkin Drive", door=2)
    z.warp(15, 14, "swansea_birthplace", 6, 7, "up")
    z.building(19, 12, 9, 3, "terrace", "Uplands Terrace")
    z.rect(3, 15, 31, 1, ":")
    z.prop("lamp_post", 12, 16); z.prop("lamp_post", 24, 16); z.prop("post_box", 18, 16)
    z.height(3, 11, 31, 6, 0)

    # --- the centre: Kingsway, the market, the castle, Wind Street, the Dylan Thomas Centre
    z.rect(2, 20, 62, 3, "=")
    z.rect(2, 19, 31, 1, ":"); z.rect(37, 19, 27, 1, ":")
    z.rect(2, 23, 31, 1, ":"); z.rect(37, 23, 27, 1, ":")
    z.rect(64, 20, 4, 3, "="); z.rect(64, 19, 4, 1, "W"); z.rect(64, 23, 4, 1, "W")
    z.rect(68, 20, 3, 3, "#")
    for x in (6, 16, 26, 40, 52, 60):
        z.prop("lamp_post", x, 19)
    for x in (10, 30, 46):
        z.prop("lamp_post", x, 23)
    z.prop("phone_box", 31, 19); z.prop("bench", 22, 19); z.prop("planter", 44, 19); z.prop("planter", 56, 23)
    z.building(3, 24, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(6, 27, "swansea_sanctuary", 5, 6, "up")
    z.building(10, 24, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(12, 27, "swansea_shop", 4, 5, "up")
    z.building(17, 24, 14, 6, "market_hall", "Swansea Market", door=7)
    z.warp(24, 29, "swansea_market", 6, 7, "up")
    z.rect(34, 23, 3, 10, "=")
    z.building(39, 24, 6, 5, "castle", "Swansea Castle")
    z.rect(46, 24, 1, 9, ":")
    z.building(47, 24, 7, 4, "tudor", "No Sign Bar", door=3)
    z.warp(50, 27, "swansea_nosign", 6, 7, "up")
    z.building(55, 24, 8, 5, "red_brick", "Dylan Thomas Centre", door=3)
    z.warp(58, 28, "swansea_dtc", 6, 7, "up")
    z.rect(16, 30, 48, 1, ":")
    z.rect(14, 31, 50, 2, "=")
    for x in (20, 30, 42, 54):
        z.prop("lamp_post", x, 30)
    z.prop("bunting", 18, 30, variant=1, walk=True); z.prop("market_stall", 31, 29)

    # --- the Maritime Quarter: the Waterfront Museum and the marina
    z.building(40, 33, 13, 5, "waterfront_museum", "National Waterfront Museum", door=6)
    z.warp(46, 37, "swansea_waterfront", 6, 7, "up")
    z.rect(38, 38, 26, 2, ":")
    z.rect(38, 40, 5, 7, ":"); z.rect(61, 40, 3, 7, ":")
    z.rect(43, 40, 18, 6, "~"); z.rect(43, 46, 18, 1, ":")
    for (x, y) in [(46, 41), (50, 43), (55, 41), (58, 44), (52, 41)]:
        z.prop("boat", x, y, variant=1)
    for x in (44, 49, 54, 59):
        z.prop("bollard", x, 39)
    z.prop("statue", 40, 41, variant=0); z.prop("bench", 39, 43); z.prop("lamp_post", 42, 39); z.prop("lamp_post", 62, 39)
    z.prop("lobster_pots", 62, 44); z.prop("buoy", 48, 44)

    # --- the west side: Singleton and the walk down to the Mumbles
    blob(z, 25, 37, 8, 3.5, ",", only="g", seed=21, jitter=0.4)
    scatter_props(z, "oak", 17, 33, 20, 12, 10, 22, avoid=("g",))
    z.rect(15, 23, 1, 25, "#")
    z.rect(16, 41, 22, 1, "#")
    z.rect(0, 40, 16, 3, "#")
    # Oystermouth Castle above the village
    z.building(3, 34, 7, 4, "castle", "Oystermouth Castle")
    z.rect(2, 38, 13, 1, "g")
    z.building(3, 44, 4, 3, "cream_render", "Mumbles Road")
    z.building(7, 44, 5, 3, "white_render", "Oystermouth Cottages")
    z.building(14, 43, 6, 3, "white_render", "Mumbles Pier Pavilion", door=2)
    z.warp(16, 45, "swansea_lifeboat", 6, 7, "up")
    z.rect(13, 46, 8, 1, ":")
    z.building(16, 51, 3, 9, "pier", show_label=False)
    z.prop("washing_line", 6, 50, walk=True); z.prop("bench", 9, 48); z.prop("lamp_post", 13, 47)
    blob(z, 7, 50, 3, 1.5, ",", only="g", seed=31, jitter=0.2)
    # Kilvey Hill: over the bridge, a scramble of bracken
    blob(z, 71, 10, 3, 7, ",", only="g", seed=41, jitter=0.4)
    blob(z, 71, 32, 3, 8, ",", only="g", seed=42, jitter=0.4)
    z.rect(68, 23, 3, 1, "#"); z.rect(69, 24, 1, 20, "#")
    scatter_props(z, "pine", 68, 3, 6, 42, 10, 43, avoid=("g",))
    smooth(z)
    # the prom: Swansea Jack, the old Mumbles Railway, the tide
    z.prop("statue", 31, 46, variant=2); z.prop("bench", 27, 46); z.prop("bench", 45, 46); z.prop("lamp_post", 36, 46)
    z.prop("lamp_post", 24, 46); z.prop("lamp_post", 52, 46); z.prop("buoy", 40, 54); z.prop("boat", 30, 55, variant=1)

    # ---- signs and plaques
    z.sign(33, 3, "ABERTAWE / SWANSEA. Croeso! (Welcome!) North: Bannau Brycheiniog, the Brecon Beacons. West: Gŵyr, the Gower.")
    z.sign(1, 39, "GŴYR / GOWER. Britain's first Area of Outstanding Natural Beauty. Worm's Head, Rhossili and the cockle beds of Penclawdd.")
    plaque(z, "name", 37, 3, "Abertawe",
           "Abertawe means 'mouth of the Tawe'. The English name is probably Norse, Sveinsey, Sveinn's island or inlet, from the Viking traders who sheltered here. Two names, one town, both used every day.")
    plaque(z, "liberty", 47, 12, "The Swans",
           "Swansea City play at the stadium opened in 2005, which the Ospreys rugby side shared for years. In 2011 the Swans became the first Welsh club in the Premier League, and in 2013 they won the League Cup at Wembley, 5-0.")
    plaque(z, "copperopolis", 56, 19, "Copperopolis",
           "In the nineteenth century the lower Swansea Valley smelted much of the world's copper, with ore shipped in from Cornwall and later from Chile and Cuba. The money built the town; the smoke killed every plant for miles. The Hafod-Morfa works closed in 1980, and the valley has been greened again since.")
    plaque(z, "cwmdonkin", 17, 9, "Cwmdonkin Park",
           "Dylan Thomas played here as a boy, and the park turns up in his poem 'The Hunchback in the Park'. A memorial stone near the old reservoir carries lines from his poem 'Fern Hill'.")
    plaque(z, "birthplace", 17, 16, "5 Cwmdonkin Drive",
           "Dylan Thomas was born in this house on 27 October 1914, and wrote a great many of his early poems in the box bedroom upstairs. His father taught English at the grammar school down the road.")
    plaque(z, "market", 21, 30, "Swansea Market",
           "The biggest indoor market in Wales. The old Victorian market burned out in the Three Nights' Blitz of February 1941, and the new one opened under its great glass roof in 1961. Cockles, laverbread and Welsh cakes hot off the bakestone are the order of the day.")
    plaque(z, "castle", 38, 29, "Swansea Castle",
           "A Norman castle founded around 1106, now hemmed in by the shops and offices of the centre. The arcaded parapet on the surviving range is the castle's best-kept secret, and it isn't very well kept.")
    plaque(z, "blitz", 33, 24, "Three Nights' Blitz",
           "On 19, 20 and 21 February 1941 German bombers wrecked the heart of Swansea, a port they wanted to close. Over two hundred people were killed. Dylan Thomas walked the ruins afterwards and said, simply, that our Swansea was dead.")
    plaque(z, "waterfront", 39, 37, "National Waterfront Museum",
           "Part of the national museum of Wales, built in 2005 around a red-brick 1901 dock warehouse. It tells the story of industry and innovation in Wales: copper, coal, tinplate, ships and the people who worked them.")
    plaque(z, "dylan", 41, 43, "Dylan Thomas",
           "Swansea's most famous son, born 1914, died in New York in 1953 aged 39. He called it an 'ugly, lovely town'. His play for voices, Under Milk Wood, was first broadcast on the BBC in 1954 with Richard Burton reading.")
    plaque(z, "jack", 32, 46, "Swansea Jack",
           "Swansea Jack was a black retriever who lived by the docks in the 1930s and pulled a reported 27 people out of the water. He has a monument on the prom, and some say it's why Swansea folk are called Jacks.")
    plaque(z, "railway", 20, 46, "The Mumbles Railway",
           "On 25 March 1807 the Oystermouth Railway began carrying fare-paying passengers in a horse-drawn carriage, the first passenger railway service in the world. It ran on horse, sail, steam and electricity, and closed in January 1960. The prom path follows its line.")
    plaque(z, "tide", 40, 47, "Swansea Bay",
           "The Bristol Channel has one of the biggest tidal ranges in the world, and at a big spring tide the water here rises and falls around ten metres. Low tide uncovers a mile of sand; high tide takes it back, quickly.")
    plaque(z, "mumbles", 12, 41, "The Mumbles",
           "Named, the story goes, by French sailors after 'mamelles', breasts, for the two rounded islands off the head. The sailors had been at sea a long time. The lighthouse on the outer island has shown a light since 1794.")
    plaque(z, "oystermouth", 10, 38, "Oystermouth Castle",
           "Built by the Norman lords of Gower, the de Breoses, from the twelfth century, and wonderfully preserved. Mumbles grew rich on oysters dredged from the bay, and the village name Oystermouth remembers it.")
    plaque(z, "lifeboat", 13, 45, "The Mumbles Lifeboat",
           "On 23 April 1947 the Mumbles lifeboat went out to the Samtampa, aground in a storm off Sker Point. All eight lifeboat crew were lost, with every soul aboard the ship. The station launched again within days, as it still does.")
    plaque(z, "kilvey", 69, 26, "Kilvey Hill",
           "The hill east of the Tawe stood bare for a century under the copper smoke. Tree planting from the 1960s brought it back; the bracken and pines up here are the valley's comeback.")
    z.sign(60, 39, "SWANSEA MARINA. Built in the 1980s in the old South Dock. The boats are newer. The gulls are not.")

    # ---- people (teaching)
    chat(z, "swa_welcome", "villager_3", 35, 5, "Lollipop Lady",
         ["Shwmae! That's hello. You've come down off the Beacons, then. Croeso i Abertawe, welcome to Swansea.",
          "Abertawe is 'the mouth of the Tawe'. Swansea is Viking, they say, Sveinn's island. We answer to both, and to 'oi'."], "down", "wander")
    chat(z, "swa_fan_chat", "festival_goer", 52, 13, "Swans Fan",
         ["First Welsh club in the Premier League, us, 2011. Then the League Cup in 2013, five-nil at Wembley. I cried into a pasty.",
          "We're the Jacks. The Cardiff lot are the Bluebirds. We don't talk about the derby. We talk about it all the time."], "left", "wander")
    chat(z, "swa_copper_chat", "steelworker", 55, 20, "Retired Smelter",
         ["Copperopolis, they called us. Ore from Cornwall, then from Chile, smelted with Welsh coal, because it was cheaper to bring the ore to the coal.",
          "The ships that went round Cape Horn for it were the Cape Horners. Hard men, hard trip. The smoke that came off the works was so bad nothing grew on Kilvey Hill for a hundred years."], "down", "still")
    chat(z, "swa_tide_chat", "angler", 44, 49, "Bait Digger",
         ["Tide's out a mile today. Swansea Bay, see: the water goes up and down ten metres on a big spring. That's a house on a house on a house.",
          "Lugworm for the bass. You find them by the little coils of sand they leave. Diolch, that's thanks, for not stepping on them."], "left", "wander")
    chat(z, "swa_rail_chat", "villager_6", 22, 47, "Retired Tram Driver",
         ["The Mumbles Train ran right along here. First passenger railway in the world, 1807, pulled by a horse. My grandad drove the electric ones.",
          "They shut it in 1960 and the whole town turned out to say goodbye. You can still walk the line. You just can't sit down on it."], "down", "wander")
    chat(z, "swa_icecream", "shopkeeper", 18, 47, "Ice Cream Seller",
         ["Ice cream on Mumbles prom is the law. Italian families came to South Wales a century ago and opened cafes in every valley, and thank God they did.",
          "Two scoops, a flake, and a gull's undivided attention. Off you go."], "down", "still")
    chat(z, "swa_jack_walker", "fox_watcher", 30, 45, "Dog Walker",
         ["This is Swansea Jack's memorial. Best dog in Wales. Twenty-seven people out of the docks, they say, and he never asked for a biscuit.",
          "Mine's called Jack too. He's never saved anyone. He did once eat a whole Welsh cake off a pram."], "down", "wander")
    chat(z, "swa_mumbles_chat", "villager_5", 6, 47, "Mumbles Local",
         ["Oystermouth, this was, for the oysters. They dredged the bay bare by the end of the 1800s, mind. Now there's the Mumbles Mile, pub to pub along the front.",
          "Dylan Thomas drank in the Antelope and the Mermaid round here. Whether he paid is another story."], "right", "wander")
    chat(z, "swa_rugby", "rugby_player", 8, 21, "Ospreys Fan",
         ["The Ospreys play rugby up at the stadium too. Shared it with the Swans for years. It's like sharing a flat, if your flatmate sings.",
          "St Helen's ground, down by the bay, is where Garry Sobers hit six sixes in an over in 1968. First man to do it in first-class cricket. In Swansea!"], "down", "still")
    # ---- Under Milk Wood voices (quest): actors rehearsing around town
    voice(z, "swa_captain_cat", "sailor", 50, 39, "Captain Cat", "captain",
          ["(An old actor, eyes shut, sitting on a bollard.) I am blind Captain Cat. I dream of my drowned shipmates, every night.",
           "To begin at the beginning, as the First Voice says. That's all you're getting for free."], "Captain Cat", "up")
    voice(z, "swa_polly", "villager_4", 7, 49, "Polly Garter", "polly",
          ["(Pegging out washing and singing.) Polly Garter, I am. I loved a little man called Willy Wee, so the song goes, and I'm not telling you the rest.",
           "Dylan wrote my songs to be sung on the doorstep, not in the Albert Hall."], "Polly Garter", "down")
    voice(z, "swa_ogmore", "villager_2", 14, 16, "Mrs Ogmore-Pritchard", "ogmore",
          ["(Polishing a door knocker on Cwmdonkin Drive.) I am Mrs Ogmore-Pritchard, and before you let the sun in, mind it wipes its shoes.",
           "I had two husbands, both dead, both tidy. Wipe your feet."], "Mrs Ogmore-Pritchard", "down")

    # ---- trainers
    trn(z, "swa_jack", "Swans Fan Dewi", "Swans Fan", "festival_goer", [("chipgull", 34), ("starlet", 34), ("swiftlet", 35)], 38, 13, "down",
        ["Jack army! Come on then, I've been singing since 1912 and I haven't stopped for a breath yet."],
        "Fair play. Even the Swans lose sometimes. Usually to Cardiff, sadly.", "Swansea Jack was a dog, a sailor and a nickname. Pick whichever makes you proudest.", 2600)
    trn(z, "swa_trader", "Market Trader Ceri", "Market Trader", "shopkeeper", [("grizzlet", 34), ("cooplet", 34), ("binfox", 35)], 32, 29, "down",
        ["Cockles, laverbread, bara brith! Hold on, a challenger. The cockles can wait. They're not going anywhere. They're cockles."],
        "Duw, you're good. Have a Welsh cake for the road. Not that one, that's mine.", "Penclawdd cockles, Gower salt marsh, the best in the world. Ask anyone in the market. Ask anyone who isn't from Penclawdd, even.", 2600)
    trn(z, "swa_historian", "Industrial Archaeologist Hywel", "Historian", "poet", [("rivetling", 35), ("cutlet", 34), ("tinnet", 34)], 58, 20, "left",
        ["Hafod-Morfa: the Vivians, the Williamses, copper sheathing for the Navy's hulls. History is under your feet, and it's mostly slag."],
        "Smelted. Thoroughly.", "Copper sheathing stopped shipworm eating wooden hulls. Swansea copper went to sea on half the ships of the age of sail.", 2700)
    trn(z, "swa_surfer", "Surfer Lowri", "Surfer", "surfer", [("pupplash", 34), ("dolphlet", 34), ("gannetling", 35)], 26, 49, "right",
        ["Langland and Caswell round the corner have the waves. Swansea Bay has the view. Bit flat for me today, so, battle?"],
        "Wiped out! Lush.", "Lush is Swansea for great. Tidy is good. Now you know Welsh English. Mostly.", 2600)
    trn(z, "swa_poet", "Pub Poet Emrys", "Poet", "poet", [("hootlet", 35), ("pepperling", 34), ("flittermouse", 34)], 46, 29, "down",
        ["Rage, rage against the... no, I can't afford the rights. Let's fight instead."],
        "Do not go gentle, he said. You went very gentle. On me.", "Dylan wrote in the No Sign Bar, they say. Or drank. In Swansea those are the same verb.", 2600, move="still")
    trn(z, "swa_jogger", "Prom Jogger Bethan", "Jogger", "jogger", [("scuttlet", 34), ("swiftlet", 34), ("pipkin", 35)], 56, 46, "left",
        ["Swansea Bay 10K, every September! I'm training. Well, I'm stopping for a battle. That counts as interval training."],
        "Stitch! Go on without me.", "Five miles of prom from the docks to Mumbles, and the wind's always in your face, both ways. Science can't explain it.", 2600)

    # ---- wild creatures
    wild(z, [("binfox", 33, 35, 14, {}), ("grizzlet", 33, 35, 12, {}), ("cooplet", 33, 35, 10, {}), ("starlet", 33, 35, 12, {"time": ["dusk", "dawn", "day"]}),
             ("chipgull", 33, 36, 14, {}), ("pipkin", 33, 35, 8, {}), ("swiftlet", 34, 36, 8, {"season": ["spring", "summer"]}),
             ("smeltling", 33, 35, 9, {}), ("cuprion", 35, 37, 2, {"time": ["night"]}), ("hootlet", 34, 36, 8, {"time": ["night"]}), ("flittermouse", 34, 36, 8, {"time": ["dusk", "night"]}),
             ("marilwyd", 35, 37, 2, {"time": ["night"]}), ("marilwyd", 35, 37, 10, {"time": ["night"], "season": ["winter"]})])
    wild(z, [("pupplash", 33, 35, 18, {}), ("chipgull", 33, 36, 16, {}), ("pinchkin", 33, 35, 16, {}), ("gannetling", 34, 36, 12, {}),
             ("stalklet", 33, 35, 10, {}), ("elverlet", 33, 35, 10, {})], "water")
    z.d["edges"] = {"north": {"to": "beacons", "offset": -11}, "west": {"to": "gower", "offset": -20}}
    z.d["spawn"] = [35, 4]
    done(z)
    z.save(OUT + "/" + zid + ".json")

    # ---- interiors
    sanctuary(OUT, zid, "Swansea", (6, 28))
    sz = json.load(open(OUT + "/swansea_sanctuary.json"))
    sz["npcs"].append({"id": "memory_coach", "sprite": "poet", "x": 8, "y": 4, "facing": "down", "move": "still", "script": "memory_coach", "name": "Retired Keeper"})
    json.dump(sz, open(OUT + "/swansea_sanctuary.json", "w"), indent=1)
    shop(OUT, zid, "Swansea", (12, 28))
    nurse(zid, ["Shwmae, cariad! Croeso, welcome to Swansea Sanctuary. Pop your team on the counter. They look like they've walked down from the Beacons in the rain. Twice.",
                "There we are. A cup of tea, a Welsh cake each, and a sit down out of the wind off the bay.",
                "Tidy! All better. Lush, as we say in Swansea. Ta-ra now, mind the gulls on the prom.",
                "The Ark's in the corner, love. It hums a bit when the tide comes in. Nobody knows why.",
                "No bother at all. Diolch for popping in, that's thank you."])
    shopkeeper(zid, "Shwmae! Snares, tea, bara brith, and a laverbread sandwich if you're feeling brave. What can I get you?",
               "Diolch! Hwyl fawr, that's goodbye. Mind the gulls.")

    interior(OUT, "swansea_market", "Swansea Market", zid, (24, 30), "hall",
             [dict(id="mkt_megan", sprite="villager_5", x=3, y=3, facing="down", move="still", script="mkt_megan", name="Megan Laverbread"),
              dict(id="mkt_baker", sprite="shopkeeper", x=9, y=3, facing="down", move="still", script="mkt_baker", name="Welsh Cake Stall"),
              dict(id="mkt_shopper", sprite="mum", x=6, y=5, facing="left", move="still", script="mkt_shopper", name="Shopper")],
             w=13, h=10, furnish=False, drop=("statue", "table"),
             extra=[P("market_stall", 2, 2), P("market_stall", 4, 2), P("market_stall", 8, 2), P("market_stall", 10, 2),
                    P("market_stall", 2, 5), P("market_stall", 10, 5), P("menu_board", 6, 1), P("bunting", 3, 1, variant=1, walk=True),
                    P("bunting", 9, 1, variant=2, walk=True), P("lobster_pots", 1, 6), P("kettle_table", 11, 6), P("clock", 7, 1, walk=True)])
    DLG["swansea_market"] = {
        "mkt_megan": megan_script(),
        "mkt_baker": say("Welsh Cake Stall", "Picau ar y maen, cakes on the stone. Flour, butter, sugar, currants, cooked on a hot bakestone. Never an oven. An oven is for English people and scones.")
                     + [{"do": "shop", "id": "swansea_market_stall"}]
                     + say("Welsh Cake Stall", "Diolch, bach. Eat them warm with a bit of sugar on, and don't tell your dentist."),
        "mkt_shopper": say("Shopper", "I come in for a pound of cockles and come out with a Welsh cake, a bag of bara brith, a plant and a new kettle. Every week.",
                           "The roof's all glass. On a sunny day it's like shopping in a greenhouse full of gossip."),
    }
    interior(OUT, "swansea_waterfront", "National Waterfront Museum", zid, (46, 38), "museum",
             [dict(id="nwm_guide", sprite="tour_guide", x=6, y=4, facing="down", move="still", script="nwm_guide", name="Museum Guide"),
              dict(id="nwm_kid", sprite="student", x=3, y=6, facing="right", move="still", script="nwm_kid", name="School Trip")],
             extra=[P("display_case", 2, 2, variant=1), P("display_case", 10, 2, variant=2), P("display_case", 2, 4), P("display_case", 10, 4, variant=1),
                    P("steel_plates", 10, 6), P("wall_map", 4, 1, walk=True), P("wall_picture", 8, 1, walk=True)])
    DLG["swansea_waterfront"] = {
        "nwm_guide": say("Museum Guide", "Croeso! Two hundred and more years of Welsh industry under one roof. Copper, coal, iron, tinplate, slate.",
                         "That locomotive replica is Richard Trevithick's Penydarren engine. In 1804, at Merthyr, it pulled the first train ever to run on rails under steam. Ten tons of iron and seventy men.",
                         "Wales made the world's tinplate too. Llanelli, just west of here, was Tinopolis. Your baked beans owe us an apology."),
        "nwm_kid": say("School Trip", "We've got a worksheet. Question one: what did Swansea smelt? I put 'everything'. Miss said nearly."),
    }
    interior(OUT, "swansea_birthplace", "5 Cwmdonkin Drive", zid, (15, 15), "home",
             [dict(id="dt_house_guide", sprite="villager_1", x=4, y=4, facing="down", move="still", script="dt_house_guide", name="House Guide")],
             extra=[P("fireplace", 6, 1), P("piano", 9, 3), P("wall_picture", 3, 1, walk=True), P("clock", 8, 1, walk=True), P("bookshelf", 1, 5)])
    DLG["swansea_birthplace"] = {
        "dt_house_guide": say("House Guide", "Dylan Thomas was born upstairs on 27 October 1914. We've done the house back up as it would have been, right down to the wallpaper.",
                              "The little box bedroom is where he wrote. Two notebooks of poems before he was twenty, a great many of the ones that made his name.",
                              "His father taught English at the grammar school and read him Shakespeare before he could read. Then Dylan went and failed every subject except English. Families, eh."),
    }
    interior(OUT, "swansea_dtc", "Dylan Thomas Centre", zid, (58, 29), "library",
             [dict(id="dtc_curator", sprite="poet", x=6, y=3, facing="down", move="still", script="dtc_curator", name="Curator")])
    DLG["swansea_dtc"] = {"dtc_curator": curator_script()}
    interior(OUT, "swansea_nosign", "No Sign Bar", zid, (50, 28), "cafe",
             [dict(id="nsb_quizmaster", sprite="villager_2", x=3, y=3, facing="down", move="still", script="nsb_quizmaster", name="Quizmaster"),
              dict(id="swa_organ", sprite="choir_singer", x=8, y=6, facing="up", move="still", script="swa_organ", name="Organ Morgan")],
             extra=[P("piano", 9, 7), P("fireplace", 10, 1), P("wall_picture", 7, 1, walk=True)])
    DLG["swansea_nosign"] = {
        "nsb_quizmaster": say("Quizmaster", "Croeso to the No Sign Bar, Wind Street. Dylan Thomas put this place in one of his stories. He didn't put the prices in, thank God.")
                          + [{"do": "choice", "text": "Quiz night. Five questions, no phones.", "options": ["Go on then", "Not tonight"], "set": "_quiz_choice"},
                             {"do": "if", "flag": "_quiz_choice", "eq": 0,
                              "then": [{"do": "quiz", "pub": "swansea", "region": "wales", "who": "Quizmaster"}],
                              "else": say("Quizmaster", "Fair play. Hwyl, and watch the step.")}],
        "swa_organ": voice_script("swa_organ", "Organ Morgan", "organ",
                                  ["(At the piano, practising.) Organ Morgan, at your service. Music, music, all day long, even in my sleep.",
                                   "Bach first thing, Bach last thing. Mrs Organ Morgan would like a word about that."]),
    }
    interior(OUT, "swansea_stadium", "The Liberty Stadium", zid, (48, 11), "hall",
             [dict(id="lib_kitman", sprite="rugby_player", x=6, y=3, facing="down", move="still", script="lib_kitman", name="Kit Man")],
             furnish=False, drop=("statue", "table"),
             extra=[P("stadium_stand", 2, 1), P("stadium_stand", 10, 1), P("pitch_line", 6, 5, walk=True), P("floodlight", 1, 1), P("floodlight", 11, 1),
                    P("flagpole", 3, 6, variant=0), P("bench", 2, 4), P("bench", 10, 4), P("rugby_posts", 6, 1)])
    DLG["swansea_stadium"] = {
        "lib_kitman": say("Kit Man", "Tunnel, dressing rooms, a lot of wet socks. Twenty thousand seats out there and every one of them has opinions.",
                          "The Swans were founded in 1912 as Swansea Town. We moved up here from the Vetch Field in 2005. The Vetch was so near the prison the inmates could hear the goals.",
                          "The Ospreys rugby side played here too. One week football, the next week a scrum. The grass has seen things.")}
    interior(OUT, "swansea_copperworks", "Hafod-Morfa Copperworks", zid, (57, 19), "mill",
             [dict(id="cop_guide", sprite="tin_miner", x=6, y=3, facing="down", move="still", script="cop_guide", name="Volunteer Guide")],
             extra=[P("brazier", 2, 2), P("steel_plates", 10, 2), P("slate_heap", 2, 6, variant=2), P("wall_picture", 6, 1, walk=True)])
    DLG["swansea_copperworks"] = {
        "cop_guide": say("Volunteer Guide", "This is the Musgrave engine house, and the old powerhouse. The Vivian family ran the Hafod works from 1810. It closed in 1980, the last of them.",
                         "Copper ore came in by ship, went into reverberatory furnaces with Welsh coal, and came out as ingots and sheathing. Copper sheathing on a wooden hull keeps the shipworm off.",
                         "The fumes were sulphur and arsenic. Farmers sued, poets complained, and the hills went bare. Now look: trees, a stadium, a bus to Morriston. Mended, mostly.")
                      + flag_l("swansea_copper_tale", [], [setf("swansea_copper_tale"),
                         {"do": "say", "who": "Volunteer Guide", "text": "Here, a bit of old slag from the tip. People used it for doorsteps and walls. Take one, we've got about a million."},
                         {"do": "give_item", "item": "copper_slag", "n": 1}])}
    interior(OUT, "swansea_lifeboat", "Mumbles Pier and Lifeboat Station", zid, (16, 46), "museum",
[dict(id="mlb_cox", sprite="sailor", x=6, y=3, facing="down", move="still", script="mlb_cox", name="Lifeboat Crew")], drop=("statue",),
             extra=[P("boat", 6, 5, variant=1), P("lobster_pots", 1, 2), P("wall_picture", 3, 1, walk=True), P("wall_picture", 9, 1, walk=True), P("telescope", 11, 6)])
    DLG["swansea_lifeboat"] = {
        "mlb_cox": say("Lifeboat Crew", "Mumbles Pier opened in 1898, and the lifeboat house is at the far end. When the maroons go we run the length of the pier and down the slipway.",
                       "In 1947 the whole crew of eight was lost going to the Samtampa off Sker Point. Every one a volunteer. We still remember them every April.",
                       "Volunteers, all of us. I'm a plumber in the week. If you ever see a plumber running down a pier, get out of the way.")}


def voice(z, nid, sprite, x, y, who, key, lines, name, facing):
    _stand(z, x, y)
    z.npc(id=nid, sprite=sprite, x=x, y=y, facing=facing, move="still", script=nid, name=name)
    DLG.setdefault(z.d["id"], {})[nid] = voice_script(nid, who, key, lines)


def voice_script(nid, who, key, lines):
    """an Under Milk Wood actor: in character once the quest is on (that's a voice found), otherwise rehearsing."""
    found = Q + "milkwood_" + key
    return [flag_if(Q + "milkwood_started",
                    say(who, *lines) + flag_l(found, [], [setf(found), {"do": "sfx", "id": "item"},
                                                           {"do": "say", "who": "", "text": "You found the voice of %s for the Dylan Thomas Centre." % who}]),
                    say(who, "(Muttering lines under their breath.) Sorry, love. Rehearsing. There's a reading at the Dylan Thomas Centre and I've got about four words."))]


MILK = ["captain", "polly", "organ", "ogmore"]


def curator_script():
    # nest the four checks: all four found -> done
    inner = [setf(Q + "milkwood_done"),
             {"do": "say", "who": "Curator", "text": "All four! Captain Cat, Polly Garter, Organ Morgan and Mrs Ogmore-Pritchard. We've got our voices for the reading. Diolch yn fawr, thank you very much."},
             {"do": "say", "who": "Curator", "text": "Here, take a copy of the play. And a lovespoon from the gift shop. Carved spoons are how Welsh lads courted, once. Don't read anything into it."},
             {"do": "give_item", "item": "milk_wood_script", "n": 1},
             {"do": "give_item", "item": "welsh_cake", "n": 6},
             {"do": "standing", "nation": "wales", "amount": 5}]
    chain = inner
    for k in reversed(MILK):
        chain = [flag_if(Q + "milkwood_" + k, chain,
                         say("Curator", "Still missing a voice or two. Captain Cat dreams by the boats, Polly Garter sings over her washing, Organ Morgan plays, and Mrs Ogmore-Pritchard polishes. Find them all."))]
    return [flag_if(Q + "milkwood_done",
                    say("Curator", "The reading went beautifully. Somebody sneezed in the quiet bit, but that's live theatre.",
                        "Llareggub, the town in the play, is a rude word spelled backwards. Dylan thought he was very clever. He was."),
                    [flag_if(Q + "milkwood_started", chain,
                             say("Curator", "Croeso to the Dylan Thomas Centre. Dylan wrote Under Milk Wood, a play for voices, about one spring day in a little Welsh seaside town called Llareggub.",
                                 "It was first read on stage in New York in 1953, a few weeks before he died there, and first broadcast on the BBC in 1954. Sixty-odd voices, and nobody leaves the town.",
                                 "We're putting on a reading and our actors are scattered across Swansea, rehearsing in all sorts of places. Could you find four of them for me?")
                             + [setf(Q + "milkwood_started"),
                                {"do": "say", "who": "Curator", "text": "Captain Cat, Polly Garter, Organ Morgan and Mrs Ogmore-Pritchard. Listen for them around town. Pob lwc, good luck!"}])])]


def megan_script():
    started, done = Q + "cockles_started", Q + "cockles_done"
    return [flag_if(done,
                    say("Megan Laverbread", "My best customer! Laverbread's laver seaweed, picked off the rocks, boiled for hours till it's a black purée. Richard Burton called it Welshman's caviar.",
                        "Fry it in a little cake with oatmeal, next to cockles and bacon. That's a Swansea breakfast. Anything else is just toast."),
                    [flag_if(Q + "cockles_2",
                             say("Megan Laverbread", "Penclawdd cockles! Proper ones, the size of a thumbnail, raked off the sands this morning. Look at you. A natural.")
                             + [setf(done), {"do": "say", "who": "Megan Laverbread", "text": "Sit down there. Cockles, laverbread, bacon, a fried egg, a pot of tea. Proper Swansea breakfast. Then take some for the road."},
                                {"do": "give_item", "item": "laverbread", "n": 4}, {"do": "give_item", "item": "welsh_cake", "n": 6},
                                {"do": "standing", "nation": "wales", "amount": 5}],
                             [flag_if(started,
                                      say("Megan Laverbread", "Out west on the north shore of Gower, past the salt marsh. Penclawdd. Ask for Dilys on the cockle beds."),
                                      say("Megan Laverbread", "Shwmae! Laverbread, cockles, the finest stall in the market. Only I'm out of cockles, and the boy who fetches them has gone to Tenerife.",
                                          "Could you nip out to Penclawdd on the Gower and fetch me a bag? Dilys on the sands will see you right. I'll do you a breakfast you'll tell your grandchildren about.")
                                      + [setf(started)])])])]


# ======================================================================================================== Gower
def gower(OUT):
    W, H = 84, 48
    zid = "gower"
    z = Z(zid, "Gower", W, H, kind="route", region=SW, music="route_coast",
          weather={"drizzle": 26, "clear": 22, "sunshine": 22, "gale": 16, "fog": 8, "downpour": 6})
    z.d["stage"] = "coast"; z.d["scaled_floor"] = FLOOR
    z.legend["g"] = {"tile": "grass", "colour": "#86a05a"}
    z.legend["h"] = {"tile": "tall_grass", "colour": "#7a6a5a", "prop": "heather"}
    z.legend["m"] = {"tile": "tall_grass", "colour": "#6f8a5a", "prop": "reeds"}
    z.legend["n"] = {"tile": "grass", "colour": "#9a8f6a"}
    z.rect(0, 0, W, H, "g")
    z.border("T", 2, gaps=[(82, 20, 2, 3)])
    z.scatter(0, 0, W, H, "P", 18, 61, only="T")
    # heights: Rhossili Down (west), Cefn Bryn (middle), the limestone south coast
    hills(z, [(31, 14, 4, 10), (52, 20, 3, 10), (20, 40, 2, 4), (6, 40, 2, 3)])
    # the sea: Rhossili Bay to the west, the Bristol Channel to the south, the Burry estuary to the north
    z.rect(0, 0, W, 3, "$")
    z.rect(0, 0, 18, 37, "$")
    z.rect(0, 36, 30, 12, "$")
    z.rect(28, 45, W - 28, 3, "$")
    # the long beach under the Down
    z.rect(18, 3, 6, 33, "s"); z.rect(17, 4, 1, 31, "o"); z.rect(24, 3, 1, 33, "n")
    for y in range(3, 37):
        for x in range(18, 25):
            z.hg[y][x] = 0
    # Rhossili Down: heather
    blob(z, 31, 14, 5, 9, "h", only="g", seed=71, jitter=0.4)
    # Rhossili village and the cliff top (Kitchen Corner) above the causeway
    z.rect(25, 30, 22, 1, "#"); z.rect(30, 31, 1, 9, "#")
    z.building(32, 26, 5, 3, "chapel", "St Mary's, Rhossili")
    z.building(38, 26, 6, 3, "slate_cottage", "Rhossili Cottages")
    z.building(31, 33, 4, 3, "white_render", "Coastguard Lookout", door=1)
    z.warp(32, 35, "gower_lookout", 6, 7, "up")
    z.rect(29, 36, 3, 4, "g")
    # the Worm: Inner Head, Low Neck, Devil's Bridge, Outer Head, joined to the mainland by a rocky causeway
    z.rect(25, 39, 5, 2, "o")
    for (x, y) in [(26, 38), (28, 41), (27, 38), (29, 41)]:
        z.set(x, y, "R")
    blob(z, 20, 40, 4.5, 2.6, "g", seed=81, jitter=0.2)
    z.rect(12, 39, 5, 3, "g"); blob(z, 14, 40, 3, 1.5, ",", only="g", seed=82)
    z.rect(10, 40, 2, 1, "#")
    blob(z, 6, 40, 3.5, 2.6, "g", seed=83, jitter=0.2)
    for (x, y) in [(12, 39), (16, 41), (21, 38), (18, 42), (5, 38), (8, 42)]:
        z.set(x, y, "R")
    z.set(3, 40, "w"); z.set(2, 40, "w")
    # the south coast: limestone cliffs, Paviland Cave, Three Cliffs Bay
    z.rect(30, 43, 54, 2, "^")
    z.rect(36, 41, 30, 2, "n")
    z.building(43, 38, 4, 3, "cave_mouth", "Paviland Cave", door=2)
    z.warp(45, 40, "gower_paviland", 6, 7, "up")
    # Three Cliffs Bay: sand, the river Pennard Pill, three limestone pinnacles; Pennard Castle above
    z.rect(62, 37, 16, 8, "s"); z.rect(62, 45, 16, 3, "$")
    z.rect(69, 30, 2, 7, "~"); z.rect(69, 37, 2, 5, "w")
    z.rect(68, 34, 1, 1, "#"); z.rect(71, 34, 1, 1, "#")
    z.building(64, 41, 3, 2, "three_cliffs", "Three Cliffs", show_label=False)
    z.building(72, 31, 5, 4, "castle", "Pennard Castle")
    z.rect(60, 29, 22, 1, "#")
    z.rect(69, 29, 2, 1, "=")
    # Cefn Bryn: the ridge and Arthur's Stone
    blob(z, 52, 20, 9, 5, "h", only="g", seed=91, jitter=0.4)
    z.rect(40, 21, 42, 1, "#")
    z.rect(45, 22, 1, 9, "#")
    z.prop("standing_stone", 51, 18, variant=0); z.prop("standing_stone", 53, 18, variant=1); z.prop("rock", 52, 17)
    # the north shore: salt marsh and the cockle beds of Penclawdd
    z.rect(50, 3, 32, 3, "s"); z.rect(50, 3, 32, 1, "w")
    for (x, y) in [(53, 4), (57, 5), (62, 4), (66, 5), (71, 4), (76, 5)]:
        z.set(x, y, "w")
    z.rect(48, 6, 34, 5, "m")
    z.rect(60, 6, 1, 6, "#"); z.rect(60, 11, 22, 1, "#"); z.rect(70, 12, 1, 9, "#")
    z.building(72, 13, 6, 3, "slate_cottage", "Penclawdd Cockle Sheds", door=2)
    z.warp(74, 15, "gower_cocklesheds", 6, 7, "up")
    z.building(63, 13, 6, 3, "terrace", "Penclawdd Terrace")
    z.rect(25, 3, 25, 4, "g")
    # tall grass about the commons, wild ponies, fields
    blob(z, 44, 34, 6, 3, ",", only="g", seed=101, jitter=0.4)
    blob(z, 60, 34, 4, 3, ",", only="g", seed=102, jitter=0.4)
    blob(z, 40, 9, 6, 3, ",", only="g", seed=103, jitter=0.4)
    blob(z, 72, 25, 5, 2, ",", only="g", seed=104, jitter=0.4)
    for (x, y, w, h) in [(56, 13, 1, 6), (36, 24, 8, 1), (75, 23, 1, 5)]:
        z.rect(x, y, w, h, "W")
    z.rect(56, 15, 1, 1, "g")
    scatter_props(z, "oak", 36, 12, 40, 18, 12, 105, avoid=("g",))
    scatter_props(z, "bush", 26, 3, 56, 40, 14, 106, avoid=("g",))
    z.prop("ship_ribs", 21, 20)
    z.prop("sheep", 37, 18); z.prop("sheep", 44, 25, variant=1); z.prop("field_gate", 40, 24)
    z.prop("bench", 29, 31); z.prop("lamp_post", 34, 31); z.prop("washing_line", 66, 16, walk=True); z.prop("lobster_pots", 79, 12)
    smooth(z)
    # signs and plaques
    z.sign(81, 19, "GŴYR / GOWER. Rhossili 15 miles west. Penclawdd north. Abertawe (Swansea) behind you.")
    plaque(z, "aonb", 78, 22, "First of its Kind",
           "In 1956 Gower became the very first Area of Outstanding Natural Beauty in Britain. Gŵyr in Welsh. Limestone cliffs, salt marsh, commons and bays, on a peninsula about fifteen miles long.")
    plaque(z, "worm", 30, 37, "Worm's Head",
           "The Worm takes its name from the Old Norse 'ormr', a serpent or dragon: Viking sailors saw a sea-dragon lying in the water. The causeway is only open for about two and a half hours either side of low tide. Check the tide table, or spend the night.")
    plaque(z, "helvetia", 25, 21, "The Helvetia",
           "The Norwegian barque Helvetia was blown ashore here in a gale in November 1887, with a cargo of timber. Nobody died. Her ribs have stuck out of Rhossili sands ever since, and the photographers love her.")
    plaque(z, "rhossili", 37, 30, "Rhossili Bay",
           "Three miles of sand under the heather of Rhossili Down, the highest point on Gower at 193 metres. It turns up on lists of the best beaches in the world, usually written by people who visited on a sunny day.")
    plaque(z, "paviland", 47, 41, "The Red Lady of Paviland",
           "In 1823 William Buckland dug a skeleton stained with red ochre from Goat's Hole cave here and called it the Red Lady. It was a young man, buried about 33,000 years ago with ivory and shells: the oldest known ceremonial burial in western Europe.")
    plaque(z, "threecliffs", 61, 36, "Three Cliffs Bay",
           "Three limestone pinnacles, a winding river called Pennard Pill and a beach that floods at high tide. Lovely to look at; foolish to swim in, because the currents at the river mouth are strong.")
    plaque(z, "pennard", 74, 36, "Pennard Castle",
           "A ruined castle on the dunes above Three Cliffs, lost to blowing sand in the Middle Ages. Legend says the lord insulted the Tylwyth Teg, the fair folk, at his wedding, and they buried it in a sandstorm overnight.")
    plaque(z, "arthur", 52, 19, "Arthur's Stone",
           "Maen Ceti: a Neolithic burial chamber on Cefn Bryn, around 5,000 years old, under a capstone of some twenty-five tons. Legend says King Arthur found a pebble in his boot and threw it here from Carmarthenshire.")
    plaque(z, "penclawdd", 61, 12, "Penclawdd Cockles",
           "Cockles have been gathered by hand on the sands of the Burry Inlet for centuries, once by women with donkeys and carts. They rake them, then riddle them through a sieve so the small ones fall back to grow. No dredges allowed.")
    plaque(z, "saltmarsh", 50, 11, "Salt Marsh",
           "The marsh along Gower's north shore floods on the big tides. Samphire and sea lavender grow here, and the sheep that graze it give the famous salt marsh lamb.")
    plaque(z, "ponies", 46, 21, "Gower Ponies",
           "Ponies graze the commons of Cefn Bryn and Fairwood all year round. They belong to commoners who have grazing rights, so they are not quite wild and not quite tame, and very definitely not to be fed.")
    # people
    chat(z, "gow_ponyman", "farmer", 47, 23, "Commoner",
         ["Commoners' ponies, these. My family's had grazing rights on Cefn Bryn since before anyone wrote it down.",
          "They're hardy. Gorse for breakfast, wind for dinner. Don't feed them crisps, it gives them ideas."], "down", "wander")
    chat(z, "gow_birder", "birdwatcher", 33, 22, "Birdwatcher",
         ["Choughs! Red beak, red legs. They came back to breed on Gower in the 1990s after a century away. I nearly dropped my flask.",
          "Grey seals haul out on the Worm, and the gannets from Grassholm fish off the point. Bring binoculars and a lot of patience."], "left", "wander")
    chat(z, "gow_surfer", "surfer", 23, 30, "Llangennith Surfer",
         ["Swell's coming in from the Atlantic, nothing between here and America but a few fishing boats. Lush.",
          "Rhossili means something like 'Sili's moor', they reckon. I'm no linguist. I'm a surfer. I know what 'gnarly' means, though."], "up", "wander")
    _stand(z, 58, 4)
    z.npc(id="gow_dilys", sprite="villager_4", x=58, y=4, facing="down", move="still", script="gow_dilys", name="Dilys")
    DLG[zid]["gow_dilys"] = dilys_script()
    _stand(z, 33, 36)
    z.npc(id="gow_coastguard", sprite="sailor", x=33, y=36, facing="down", move="still", script="gow_coastguard", name="Coastwatch Volunteer")
    DLG[zid]["gow_coastguard"] = coastguard_script()
    _stand(z, 23, 40)
    z.npc(id="gow_warden", sprite="warden_grunt", x=23, y=40, facing="right", move="still", script="gow_warden", name="Island Warden")
    DLG[zid]["gow_warden"] = warden_script()
    _stand(z, 14, 41)
    z.npc(id="gow_gwen", sprite="hillwalker", x=14, y=41, facing="up", move="still", script="gow_gwen", name="Gwen of the Worm")
    DLG[zid]["gow_gwen"] = gwen_script()
    _stand(z, 4, 40)
    z.npc(id="gow_wyrm", sprite="creature:ormwyrm", x=4, y=40, facing="right", move="still", script="gow_wyrm", hide_if=Q + "worm_caught")
    DLG[zid]["gow_wyrm"] = wyrm_script()
    z.sign(6, 39, "THE BLOWHOLE. When the tide is just right the sea booms up through the rock here, and the whole Outer Head shudders. The Vikings had a theory.")
    # foalmoor ponies, wandering
    creature(z, zid, "foalmoor", 49, 24, line="The pony looks at you, looks at your pockets, and looks disappointed.", who="Gower Pony")
    creature(z, zid, "greyhaul", 9, 42, move="still", line="A grey seal hauled out on the rock. It regards you the way a duchess regards a draught.", who="Grey Seal")
    # trainers
    trn(z, "gow_trekker", "Pony Trekker Nia", "Pony Trekker", "farmer", [("foalmoor", 34), ("scuttlet", 34), ("kitelet", 35)], 44, 21, "down",
        ["Hold the reins! No, not you, the pony. Right, battle, quick, before he eats the gorse."],
        "Whoa there. Well ridden.", "Gower ponies can live out on the common all winter. I can't live out in a car park for an hour.", 2700)
    trn(z, "gow_climber", "Climber Iwan", "Climber", "hiker", [("kidgruff", 34), ("cragchough", 35), ("slatelet", 34)], 62, 35, "right",
        ["Gower limestone: sharp, grippy and full of fossils. Lovely. You, though, look like you need a rope. Battle!"],
        "Off belay. Off my game, more like.", "The pinnacles at Three Cliffs are the classic. Mind the tide; it's not a classic to drown.", 2700)
    trn(z, "gow_cockler", "Cockler Huw", "Cockle Picker", "fisher", [("pinchkin", 34), ("stalklet", 34), ("pupplash", 35)], 66, 6, "left",
        ["Rake, riddle, bag. Rake, riddle, bag. Oh, a challenger! Rake, riddle, battle."],
        "Riddled me good and proper.", "We work the tide like a timetable. The sand's yours for a few hours, then the sea wants it back.", 2700)
    trn(z, "gow_caver", "Caver Rhian", "Caver", "tin_miner", [("horselet", 34), ("tapknock", 34), ("glowmite", 35)], 41, 41, "right",
        ["Paviland's not much of a cave. It's more of a crack with a past. Bit like me. Fight?"],
        "My lamp's gone out. And my team.", "Bones of mammoth and woolly rhino came out of Paviland too. Gower used to be a lot further from the sea, with the ice ages in charge.", 2700)
    trn(z, "gow_kiter", "Kitesurfer Sion", "Kitesurfer", "surfer", [("petrelash", 34), ("gannetling", 34), ("swiftlet", 35)], 22, 12, "right",
        ["The wind on Rhossili could lift a caravan. It has done, actually. Want to see what it does to your team?"],
        "Becalmed!", "Rhossili's wind blows straight off the Atlantic. The sheep up on the Down have perfect side partings.", 2700)
    # Gwen's full team: fought through her script (the Worm's Head quest)
    T("gow_gwen", "Gwen of the Worm", "Local Legend", "hillwalker",
      [("greyhaul", 36), ("plungebeak", 36), ("cragchough", 36), ("clawcastle", 36), ("forkwing", 36), ("wurmlet", 37)],
      ["Fifty years I've walked out to the Worm on the tide, cariad. I've seen it breathe. Before I let you go out to the Outer Head, show me you can handle what's out there."],
      "Duw, duw. You'll do. The Outer Head's yours.", "Listen at the blowhole when the swell's up. If something answers, be polite.", 4200)
    # wild creatures
    wild(z, [("scuttlet", 33, 35, 20, {}), ("kitelet", 33, 35, 10, {"time": ["day"]}), ("zigzlet", 33, 35, 10, {"weather": ["sunshine", "clear"]}),
             ("cragchough", 34, 36, 8, {}), ("foalmoor", 33, 35, 10, {}), ("pipkin", 33, 35, 8, {}), ("glowmite", 34, 36, 8, {"time": ["night"]}),
             ("hootlet", 34, 36, 6, {"time": ["night"]}), ("stalklet", 33, 35, 8, {}), ("pinchkin", 33, 35, 8, {}),
             ("marilwyd", 35, 37, 2, {"time": ["night"]}), ("marilwyd", 35, 37, 8, {"time": ["night"], "season": ["winter"]})])
    wild(z, [("pupplash", 33, 35, 18, {}), ("gannetling", 34, 36, 14, {}), ("pinchkin", 33, 35, 14, {}), ("dolphlet", 34, 36, 8, {"time": ["day"]}),
             ("baskling", 34, 36, 4, {"season": ["summer"]}), ("wurmlet", 34, 36, 6, {"weather": ["gale", "drizzle", "downpour"]}), ("wurmlet", 34, 36, 2, {}), ("ormwyrm", 36, 37, 1, {"weather": ["gale"]})], "water")
    z.d["edges"] = {"east": {"to": "swansea", "offset": 20}}
    z.d["spawn"] = [80, 21]
    done(z)
    z.save(OUT + "/" + zid + ".json")

    interior(OUT, "gower_lookout", "Coastguard Lookout", zid, (32, 36), "museum",
             [dict(id="look_watcher", sprite="birdwatcher", x=6, y=3, facing="down", move="still", script="look_watcher", name="Watchkeeper")],
             furnish=False, drop=("statue",),
             extra=[P("telescope", 3, 2), P("telescope", 9, 2), P("wall_map", 6, 1, walk=True), P("kettle_table", 11, 5),
                    P("table", 2, 5), P("clock", 4, 1, walk=True)])
    DLG["gower_lookout"] = {"look_watcher": say("Watchkeeper", "Coastwatch, volunteers. We keep an eye on the causeway and the bay from up here and ring the coastguard when somebody gets cut off. Which is most weekends.",
                                               "The tide comes round about every twelve and a half hours, so low water's about fifty minutes later each day. Write it on your hand.",
                                               "Dylan Thomas got stuck out on the Worm as a young man. Fell asleep, woke up surrounded by sea, and wrote about it after. Don't do a Dylan.")}
    interior(OUT, "gower_paviland", "Paviland Cave", zid, (45, 41), "castle",
             [dict(id="pav_archaeo", sprite="poet", x=6, y=3, facing="down", move="still", script="pav_archaeo", name="Archaeologist")],
             furnish=False,
             extra=[P("rock", 1, 1), P("rock", 11, 1), P("rock", 1, 5), P("rock", 11, 6), P("display_case", 3, 2, variant=1), P("display_case", 9, 2, variant=2),
                    P("brazier", 2, 6), P("brazier", 10, 4)])
    pav = json.load(open(OUT + "/gower_paviland.json"))
    pav["dark"] = True
    json.dump(pav, open(OUT + "/gower_paviland.json", "w"), indent=1)
    DLG["gower_paviland"] = {"pav_archaeo": say("Archaeologist", "Goat's Hole, Paviland. You can only get in at low tide, so mind your watch.",
                                                "The Reverend William Buckland found the bones in 1823 stained red with ochre, with ivory rods and periwinkle shells beside them. He decided it was a woman, perhaps a Roman. Wrong twice.",
                                                "It's a young man, about 33,000 years old. Back then the sea was miles away and mammoths walked past the door. The bones are in Oxford now. Swansea would quite like them back.")}
    interior(OUT, "gower_cocklesheds", "Penclawdd Cockle Sheds", zid, (74, 16), "workshop",
             [dict(id="cockle_boiler", sprite="villager_2", x=6, y=3, facing="down", move="still", script="cockle_boiler", name="Cockle Boiler")],
             extra=[P("kettle_table", 2, 5), P("lobster_pots", 10, 5), P("tea_urn", 1, 3)])
    DLG["gower_cocklesheds"] = {"cockle_boiler": say("Cockle Boiler", "In they go, a quick boil, out of the shell, rinsed. The shells go back on the paths. Penclawdd has the crunchiest paths in Wales.",
                                                     "Cockles and laverbread, it's a Swansea marriage. You'd think the two were born together on the same rock.")}


def dilys_script():
    s2 = Q + "cockles_2"
    return [flag_if(s2, say("Dilys", "Off you go to Megan, then. Keep them cool and wet. Cockles are like grandchildren: lovely, but they don't travel well."),
                    [flag_if(Q + "cockles_started",
                             say("Dilys", "Megan sent you? Course she did. Here, take the rake. The trick's in the riddle, the sieve. Watch.")
                             + [setf(Q + "cockles_1"), {"do": "choice", "text": "Dilys shakes the riddle. Which cockles go in the bag?",
                                 "options": ["Every last one you can find", "Only the ones too big to fall through the riddle", "Only the shiny ones"], "set": "_cockle"},
                                {"do": "if", "flag": "_cockle", "eq": 1,
                                 "then": say("Dilys", "That's it! The little ones drop back through to grow on for next year. That's why there are still cockles here after hundreds of years.")
                                         + [setf(Q + "cockles_1"), setf(s2), {"do": "give_item", "item": "penclawdd_cockles", "n": 1},
                                            {"do": "say", "who": "Dilys", "text": "A bag of Penclawdd's finest. Take them to Megan. Tell her she owes me a bara brith."}],
                                 "else": say("Dilys", "Duw, no! Take them all and there's none next year. Look at the riddle again. Have another go.")}],
                             say("Dilys", "Cockling, love. Rake, riddle, bag. My mam did it with a donkey. I do it with a tractor and a bad back.",
                                 "The Burry Inlet, this is. Tide goes out for miles. You get to know it like your own kitchen."))])]


def coastguard_script():
    started, s1 = Q + "worm_started", Q + "worm_1"
    puzzle = [{"do": "say", "who": "Coastwatch Volunteer", "text": "Today's tide table: low water at two in the afternoon. The causeway's open from two and a half hours before low water to two and a half hours after."},
              {"do": "say", "who": "Coastwatch Volunteer", "text": "It's a good hour's scramble from the causeway out to the Outer Head, and an hour back. So, when are you going?"},
              {"do": "choice", "text": "Plan your crossing.",
               "options": ["Leave at 10am, back by noon", "Leave at 11.30am, turn back at 2.30pm", "Leave at 2pm, picnic, turn back at 4pm", "Whenever. It's only water."],
               "set": "_worm_plan"},
              {"do": "if", "flag": "_worm_plan", "eq": 1,
               "then": say("Coastwatch Volunteer", "Spot on. Causeway opens at half eleven, you're back on it by half three, and it's covered by half four. An hour to spare. Off you go, and say hello to Gwen.")
                       + [setf(s1), setf(Q + "worm_safe", True), {"do": "fade_out"}, {"do": "say", "who": "", "text": "You pick your way over the barnacled rocks and mussel beds of the causeway as the last of the sea drains off it."},
                          {"do": "warp", "zone": "gower", "x": 24, "y": 40, "facing": "left"}, {"do": "fade_in"}],
               "else": [{"do": "if", "flag": "_worm_plan", "eq": 2,
                         "then": say("Coastwatch Volunteer", "Hmm. You'll get over all right. Getting back's another matter. Still, you're old enough to learn the hard way.")
                                 + [setf(s1), setf(Q + "worm_safe", False), {"do": "fade_out"}, {"do": "say", "who": "", "text": "You cross the causeway with a picnic and a song in your heart."},
                                    {"do": "warp", "zone": "gower", "x": 24, "y": 40, "facing": "left"}, {"do": "fade_in"}],
                         "else": [{"do": "if", "flag": "_worm_plan", "eq": 0,
                                   "then": say("Coastwatch Volunteer", "At ten the causeway's still a yard under the sea. You'd be swimming with the conger eels. Have another look at the table."),
                                   "else": say("Coastwatch Volunteer", "'It's only water.' That's what everybody says before we ring the lifeboat. Sit down and do the sums.")}]}]}]
    report = flag_if(Q + "worm_caught",
                     say("Coastwatch Volunteer", "You caught it? The Worm's own wyrm? I've watched that blowhole for twenty years and never seen more than spray.")
                     + [setf(Q + "worm_done"),
                        {"do": "say", "who": "Coastwatch Volunteer", "text": "Here, have this. A hag stone off Rhossili beach, a pebble with a hole worn right through. Sailors hung them up for luck. Seems you've got the knack already."},
                        {"do": "give_item", "item": "hag_stone", "n": 1}, {"do": "give_item", "item": "laverbread", "n": 2},
                        {"do": "standing", "nation": "wales", "amount": 5}],
                     say("Coastwatch Volunteer", "Back again? Want another go at the crossing?") + puzzle)
    return [flag_if(Q + "worm_done",
                    say("Coastwatch Volunteer", "The Worm's quiet today. Tide table's on the board if you fancy another stroll. Mind the time, mind the time, mind the time."),
                    [flag_if(started, [report],
                             say("Coastwatch Volunteer", "Bore da! Good morning. That's Worm's Head out there. The Vikings called it 'ormr', the dragon, and on a stormy day you'll see why: the Outer Head lifts its head and the blowhole roars.",
                                 "There's a story it's no story at all. Gwen, who's walked out there for fifty years, swears something lives by the blowhole. You'd need to cross the causeway on the tide to see.")
                             + [setf(started)] + puzzle)])]


def warden_script():
    back = [{"do": "fade_out"}, {"do": "warp", "zone": "gower", "x": 31, "y": 38, "facing": "up"}, {"do": "fade_in"}]
    return [flag_if(Q + "worm_safe",
                    say("Island Warden", "Good timing, you. The causeway's clear for a while yet.")
                    + [{"do": "choice", "text": "Head back over the causeway?", "options": ["Back to the mainland", "Stay a while"], "set": "_worm_back"},
                       {"do": "if", "flag": "_worm_back", "eq": 0, "then": back, "else": say("Island Warden", "Keep half an eye on your watch.")}],
                    say("Island Warden", "Oh dear. Look at the causeway. That's the sea racing over it, that is, and it won't be back down for hours. You're cut off.")
                    + [{"do": "choice", "text": "You're stranded on the Worm.", "options": ["Wait for the next low tide", "Swim for it"], "set": "_worm_stuck"},
                       {"do": "if", "flag": "_worm_stuck", "eq": 1,
                        "then": say("Island Warden", "Swim? In that rip? No chance. People have drowned trying. If you'd come with waders and the sense to wade the shallow bit at low water, fair enough. Not now. We wait.")}]
                    + [{"do": "say", "who": "Island Warden", "text": "We'll sit by the cairn. I've got a flask. The tide turns roughly every six hours and a bit."},
                       {"do": "fade_out"},
                       {"do": "say", "who": "", "text": "You count gulls, then seals, then stars. Dylan Thomas did this once, and wrote about it. You compose a strongly worded postcard to yourself."},
                       setf(Q + "worm_safe", True),
                       {"do": "say", "who": "Island Warden", "text": "There, the causeway's up. Lesson learned: always do the sums. Off you go."},
                       {"do": "warp", "zone": "gower", "x": 31, "y": 38, "facing": "up"}, {"do": "fade_in"}])]


def gwen_script():
    won = "trainer_gow_gwen"
    return [flag_if(won,
                    say("Gwen of the Worm", "The Outer Head's beyond the Devil's Bridge, the stone arch. Listen at the blowhole.")
                    + flag_l(Q + "worm_1", [setf(Q + "worm_2")]),
                    [{"do": "battle", "trainer": "gow_gwen", "intro": True},
                     flag_if(won, [setf(Q + "worm_2")])])]


def wyrm_script():
    return [flag_if(Q + "worm_2",
                    [{"do": "say", "who": "", "text": "The swell comes in. The blowhole booms like a cannon, and out of the spray rises a long grey-green head, crested like a breaking wave."},
                     {"do": "music", "id": "legend_sea"},
                     {"do": "say", "who": "", "text": "The Worm's own wyrm. It looks at you, then at the tide, as if it's checking your sums."},
                     {"do": "legend", "species": "ormwyrm", "level": 36, "scaled_floor": FLOOR, "music": "legend_sea", "flag": Q + "worm_caught"},
                     flag_if(Q + "worm_caught", [setf(Q + "worm_3"), {"do": "say", "who": "", "text": "Tell the coastguard. Nobody's going to believe you, but tell them."}],
                             [{"do": "say", "who": "", "text": "The wyrm slips back into the sea with a slap of its tail. It'll be back with the next swell."}])],
                    [{"do": "say", "who": "", "text": "The blowhole booms. Something long and grey-green shifts in the spray, then is gone. Gwen, on the Low Neck, would know what you're looking at."}])]


if __name__ == "__main__":
    import json
    OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
    swansea(OUT)
    gower(OUT)
    write_all(OUT)
