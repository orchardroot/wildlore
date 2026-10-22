# 4.5 "Learn as you go", wave 45 session L: these isles abroad. Five compact destinations, each a small town with a
# Sanctuary, a shop, two or three real interiors, plaques, people who teach, trainers and a short quest, chosen for what
# they teach about the peoples of Britain and Ireland abroad:
#   gaiman       Y Wladfa, the Welsh in Patagonia (Argentina): RAF board, unlock champion, par 95, Argentine pesos
#   baddeck      Cape Breton, Nova Scotia: Scottish Gaelic in Canada: RAF board, par 95, Canadian dollars
#   boston       Boston, Massachusetts: Irish emigration and the Famine: RAF board, par 95, US dollars
#   bristol_tn   Bristol, Tennessee and Virginia: the Ulster Scots in Appalachia: RAF board, par 95, US dollars
#   roscoff      Roscoff, Brittany: Breton, the Celtic cousin of Welsh and Cornish: ferry from Plymouth after badge_storm,
#                par 43 (Plymouth's band), euros
# Regions are `abroad_<place>` (core/standing.gd counts them as the nation "abroad", Kin Abroad; core/wallet.gd gives
# their money; data/timezones.json their clocks). The Brittany ferry is the Plymouth to Roscoff route in data/ferries.json.
# Usage (repo root): python3 tools/zones/abroad.py data/zones
import sys
from os_common import *
from sc_common import creature_npc
from wcommon import _stand

Q = "q_abroad_"
NATION = "abroad"
FLOOR_FAR = 95
FLOOR_BRITTANY = 43   # Plymouth's band; the ferry opens with badge_storm, like the Channel Islands from Poole
GATE_BRITTANY = "badge_storm"


def stand_abroad(amount=2):
    return [{"do": "standing", "nation": NATION, "amount": amount}]


def wild_at(z, floor, rows, kind="grass"):
    wild(z, [(sp, floor, floor + 1, wt, extra) for (sp, wt, extra) in rows], kind)


def base(zid, name, region, music, wx, stage, floor, W=60, H=44, fill="k", grass="#6a8a4a"):
    z = Z(zid, name, W, H, fill=fill, kind="town", region=region, music=music, weather=wx)
    z.d["stage"] = stage
    z.d["town_id"] = zid
    z.d["scaled_floor"] = floor
    z.legend["k"] = {"tile": "grass", "colour": grass}
    return z


def door(z, bx, by, bw, style, label, iid, w=13, h=10, bh=4):
    return door_to(z, bx, by, bw, bh, bw // 2, style, label, iid, w, h)


def scaled_at(tids, floor):
    for t in tids:
        TRN[t]["scaled_floor"] = floor


def legend_trainer(z, nid, script_id, name):
    for n in z.d["npcs"]:
        if n["id"] == nid:
            del n["trainer"]
            n["script"] = script_id
            n["name"] = name


def chain(flag_steps, fight, hint):
    """nested if: every flag in flag_steps set -> fight, else hint."""
    body = fight
    for f in reversed(flag_steps):
        body = [cmd_if(f, body, hint)]
    return body


def add_step(zid, nid, qid, step):
    """an NPC's lines also tick a quest step once the quest has started."""
    DLG[zid][nid] = DLG[zid][nid] + [cmd_if(Q + qid + "_started", [setf(Q + qid + "_" + step)])]


def flight_home(z, zid, terr, x, y, sprite, who, text, facing="down"):
    _stand(z, x, y)
    z.npc(id=zid + "_return", sprite=sprite, x=x, y=y, facing=facing, move="still", script=zid + "_return", name=who)
    script(zid, zid + "_return", say(who, text) + [{"do": "overseas_home", "territory": terr}])


# =====================================================================================================================
# Y Wladfa: Gaiman, in the Chubut valley
# =====================================================================================================================
def gaiman(OUT):
    zid, F = "gaiman", FLOOR_FAR
    WX = {"sunshine": 34, "clear": 34, "gale": 18, "drizzle": 8, "fog": 4, "downpour": 2}
    z = base(zid, "Gaiman", "abroad_patagonia", "town_wales_choir", WX, "town", F, grass="#8a9a5a")
    z.legend["d"] = {"tile": "sand", "colour": "#b8a678"}            # the dry steppe on the valley sides
    z.legend["h"] = {"tile": "tall_grass", "colour": "#9a9a5e", "prop": "short"}
    z.legend["g"] = {"tile": "grass", "colour": "#5e8a3c"}            # irrigated fields and orchards
    z.legend["n"] = {"tile": "tall_grass", "colour": "#4e7a34"}
    W, H = 60, 44
    z.rect(0, 0, W, H, "k")
    z.border("P", 2)
    # the steppe and its low bluffs to the north, the Chubut river along the south
    z.rect(2, 2, W - 4, 9, "d")
    mound(z, 14, 4, 12, 4, 3)
    mound(z, 46, 4, 12, 4, 3)
    smooth(z)
    blob(z, 12, 7, 7, 3, "h", only="d", seed=1, jitter=0.4)
    blob(z, 47, 7, 8, 3, "h", only="d", seed=2, jitter=0.4)
    z.rect(2, 37, W - 4, 3, "~"); z.rect(2, 36, W - 4, 1, "w"); z.rect(2, 40, W - 4, 2, "k")
    z.rect(2, 40, W - 4, 2, "P")
    # an irrigation canal off the river, as the settlers dug them, with a footbridge
    z.rect(8, 27, 1, 9, "~"); z.set(8, 30, "#")
    # fields and orchards below the town, lined with poplars as windbreaks
    z.rect(10, 28, 18, 7, "g"); blob(z, 18, 31, 7, 2, "n", only="g", seed=3, jitter=0.5)
    z.rect(34, 28, 22, 7, "g"); blob(z, 44, 31, 8, 2, "n", only="g", seed=4, jitter=0.5)
    for x in range(10, 28, 3):
        z.set(x, 27, "P")
    for x in range(34, 56, 3):
        z.set(x, 27, "P")
    # the main street (Avenida Eugenio Tello) and pavements
    z.rect(2, 19, W - 4, 2, "="); z.rect(2, 18, W - 4, 1, "#"); z.rect(2, 26, W - 4, 1, "#")
    z.rect(30, 21, 2, 15, "#")   # a lane down to the river
    # north row
    r_museum = door(z, 5, 14, 8, "station", "Museo Histórico Regional", "gaiman_museum")
    r_chapel = door(z, 15, 13, 7, "chapel", "Capel Bethel", "gaiman_chapel", bh=5)
    ret_s, ret_h = town_buildings(z, zid, (24, 14, "sanctuary"), (31, 14, "shop"))
    z.building(37, 14, 6, 4, "gaiman_brick", "Gaiman")
    z.building(44, 14, 5, 4, "gaiman_brick", "Gaiman")
    z.building(50, 14, 6, 4, "gaiman_brick", "Gaiman")
    # south row
    r_tea = door(z, 5, 22, 8, "veranda_shop", "Tŷ Te", "gaiman_tea")
    r_first = door(z, 15, 22, 5, "gaiman_brick", "Tŷ Cyntaf", "gaiman_first", w=11, h=9)
    z.building(22, 22, 6, 4, "gaiman_brick", "Gaiman")
    z.building(34, 22, 6, 4, "gaiman_brick", "Gaiman")
    z.building(41, 22, 6, 4, "gaiman_brick", "Gaiman")
    z.building(48, 22, 8, 4, "gaiman_brick", "Ysgol")
    for (lx, ly) in [(4, 18), (14, 18), (36, 18), (48, 18), (12, 26), (40, 26), (54, 26)]:
        z.prop("lamp_post", lx, ly)
    for (bx, by) in [(27, 26), (33, 26)]:
        z.prop("bench", bx, by)
    scatter_props(z, "bush", 3, 3, 54, 8, 14, 11, avoid=("d", "h"))
    scatter_props(z, "oak", 11, 29, 16, 5, 6, 12, avoid=("g",))
    scatter_props(z, "oak", 35, 29, 20, 5, 7, 13, avoid=("g",))
    z.d["spawn"] = [30, 20]
    # ---- plaques ----
    P = "abroad_gaiman_"
    plaque(z, 28, 18, P + "mimosa", "The Mimosa, 1865",
           "On 28 May 1865 a converted tea clipper, the Mimosa, sailed from Liverpool with about 150 Welsh men, women and children. They landed on 28 July at what became Puerto Madryn, Porth Madryn to them. The day is still kept in Chubut as Gŵyl y Glaniad, the Landing Festival.")
    plaque(z, 13, 18, P + "why", "Why Patagonia?",
           "The settlers wanted a place where Welsh could be the language of chapel, school, court and home, safe from the pressure on it in Wales. Michael D. Jones, a minister from Bala, championed the idea. Argentina, keen to settle the south, offered land in the Chubut valley.")
    plaque(z, 30, 27, P + "canals", "Water in a Dry Land",
           "The first years were hard: drought, failed harvests and floods. The settlers learnt to dig canals from the Chubut river to water the valley, and wheat from Y Wladfa later won prizes abroad. The poplars you see were planted as windbreaks against the Patagonian wind.")
    plaque(z, 20, 26, P + "tehuelche", "The Tehuelche",
           "The land was not empty. The Tehuelche people knew it, traded with the settlers and taught them to hunt guanaco and rhea. Their own story has a darker chapter: the Argentine army's Conquest of the Desert campaigns of the 1870s and 1880s took their land.")
    plaque(z, 7, 18, P + "railway", "The Old Station",
           "The museum is in Gaiman's old railway station. The Central Chubut Railway was built in the 1880s to carry the valley's grain to the port, partly by Welsh workers who came out on the ship Vesta in 1886. The trains have long gone.")
    plaque(z, 15, 26, P + "first_house", "Tŷ Cyntaf",
           "The first house built in Gaiman, in 1874, by David Roberts. It is small, plain and built to last, like most things here. Gaiman itself takes its name from a Tehuelche word.")
    plaque(z, 44, 18, P + "trelew", "Trelew and Rawson",
           "Down the valley, Trelew is named after Lewis Jones, one of the colony's leaders: tre means town, so Tre-Lew is Lewis's town. Rawson, the capital of Chubut, is named after Guillermo Rawson, the Argentine minister who backed the settlement.")
    plaque(z, 52, 26, P + "eisteddfod", "Eisteddfod y Wladfa",
           "Y Wladfa holds its own eisteddfod every year, with competitions in Welsh and Spanish: singing, poetry, recitation and folk dance. Winners take a chair or a crown, as in Wales. Choirs from Wales come out to compete, and sometimes go home beaten.")
    plaque(z, 46, 26, P + "cwm_hyfryd", "Cwm Hyfryd",
           "In the 1880s Welsh riflemen rode west across Patagonia to the Andes and found a green valley they called Cwm Hyfryd, the pleasant valley. In 1902, when Argentina and Chile settled their border, the Welsh there voted to stay in Argentina. Trevelin, the mill town, is still there.")
    plaque(z, 38, 26, P + "today", "Welsh Today",
           "A few thousand people in Chubut speak some Welsh. Since 1997 teachers from Wales have come out each year to teach it, and there are bilingual Welsh and Spanish schools in Gaiman and Trelew. Most people here are Argentines first, with a Welsh grandmother and a very good recipe.")
    # ---- folk ----
    chat(z, "gai_abuela", "villager_6", 26, 18, "Nain Elena",
         ["Bore da! Good morning. My great-grandfather came out on the Mimosa. My mother spoke Welsh at home, Spanish at school, and both at the dinner table, loudly.",
          "Nain, we say, for grandmother, like in the north of Wales. My grandchildren call me abuela, and I answer to both."], "down")
    chat(z, "gai_gaucho", "farmer", 34, 27, "Rhys the Farmer",
         ["Rhys Hughes, cattle and alfalfa. The Welsh brought the plough, the gauchos brought the horse, and we kept the lot. I drink mate in the morning and tea in the afternoon. Both are traditions, and both are very serious.",
          "Mate is a bitter herb tea drunk from a gourd through a metal straw, passed round. You don't say thank you until you've had enough, or they'll keep filling it."], "down")
    chat(z, "gai_teacher", "gown_student", 50, 26, "Welsh Teacher",
         ["Shwmae! I'm out from Aberystwyth for the year, teaching Welsh. My pupils' Welsh is better than my Spanish. Their questions are harder too: why does cath become gath? Because it does, cariad.",
          "Here's one to take home: diolch means thanks. Diolch yn fawr, thanks very much. You'll hear it in every tea house in town, usually followed by more cake."], "down")
    chat(z, "gai_craftswoman", "villager_4", 22, 27, "Tehuelche Weaver",
         ["My family is Tehuelche. Our people lived here long before the ships came. When the Welsh arrived, my ancestors traded with them, guanaco skins for bread, and showed them how to hunt.",
          "People like to tell it as a friendship, and it was, for a while. Then the army came south in the 1870s and 1880s and our people lost their land. Remember both stories. They're both true."], "down")
    chat(z, "gai_kid", "student", 42, 18, "Schoolboy",
         ["Hola! Shwmae! I learn Welsh at school. My nain says if I learn enough Welsh I can go to Wales and nobody there will understand my accent. I can't wait."], "down")
    creature_npc(z, "gai_rhea", "choiquet", 47, 8, "A young rhea eyes you from the scrub, decides you are not a threat, and runs off at an angle that suggests it has somewhere very important to be.")
    flight_home(z, zid, "patagonia", 56, 20, "commuter", "Remis Driver",
                "A remis is a minicab. I'll run you to Trelew for the airport: Buenos Aires, then the long flight to London. Not the RAF, no. The RAF doesn't fly to Argentina, for reasons you can read about in any history book.")
    # ---- wild ----
    wild_at(z, F, [("choiquet", 12, {}), ("leveret", 10, {}), ("duneskink", 10, {"weather": ["clear", "sunshine"]}), ("kitelet", 10, {}),
                   ("flittermouse", 8, {"time": ["dusk", "night"]}), ("croakle", 8, {}), ("hootlet", 6, {"time": ["night"]}), ("swiftlet", 8, {})])
    wild_at(z, F, [("parrlet", 14, {}), ("bradan", 6, {}), ("croakle", 8, {}), ("stalklet", 8, {})], "water")
    trainer(z, "gai_choir", "Côr Leader Mair", "Choir Leader", "choir_singer",
            [("tapknock", 95), ("kitelet", 95), ("starlet", 96), ("murmurant", 96)], 20, 18, "down",
            ["The choir sings in Welsh, the audience claps in Spanish, and I conduct in whatever comes out. Altos, from the top!"],
            "Lovely. That was very nearly in tune.",
            "Y Wladfa's chapels and choirs kept Welsh going for generations: the chapel was school, court and concert hall, and the hymns were the first Welsh many children learnt.", 5600)
    trainer(z, "gai_teahouse", "Tea Lady Gwen", "Tea Room Owner", "jam_maker",
            [("cuppeen", 96), ("jamlet", 95), ("sheridram", 96), ("marmalord", 96)], 7, 26, "down",
            ["Tea, bara brith, scones, cream, five kinds of cake and torta negra. If you can battle after that, you're welcome to try."],
            "You've earned another slice.",
            "Welsh tea houses are one of Gaiman's best-known sights. Visitors come from Buenos Aires and beyond for a proper afternoon tea, a long way from Llandudno.", 5600)
    trainer(z, "gai_irrigator", "Canal Keeper Dafydd", "Irrigator", "fisher",
            [("parrlet", 95), ("bradan", 96), ("stalklet", 95), ("heronarch", 96)], 9, 31, "right",
            ["Every gate on this canal has a family's name on it. I open them in turn and listen to everyone complain about the order."],
            "Fair enough. Mind the canal on your way past.",
            "The canals still water the lower Chubut valley. The river is fed by snowmelt from the Andes, hundreds of kilometres to the west.", 5600)
    trainer(z, "gai_legend", "Prifardd Eluned", "Chief Bard", "keeper_eluned",
            [("choique", 97), ("forkwing", 97), ("marilwyd", 96), ("gwyllgi", 97), ("heronarch", 96), ("coblynn", 97)], 36, 18, "down",
            ["Every year someone thinks the eisteddfod chair is theirs. Every year I disagree. Show me what you've got, and do it with feeling."],
            "That deserves a chair. A small one. Come and sit.",
            "The chair and the crown are the eisteddfod's two great prizes, for strict-metre poetry and free verse. A poet who has won one is a prifardd, a chief bard. Y Wladfa's eisteddfod awards both, as in Wales.", 9500)
    legend_trainer(z, "gai_legend", "gai_legend_talk", "Prifardd Eluned")
    scaled_at(["gai_choir", "gai_teahouse", "gai_irrigator", "gai_legend"], F)
    finish_zone(z)
    z.save(OUT + "/" + zid + ".json")
    # ---- interiors ----
    interior(OUT, "gaiman_museum", "Museo Histórico Regional", zid, r_museum, "museum",
             [npc("gai_curator", "tour_guide", 6, 2, "gai_curator", name="Museum Keeper")],
             signs=[(2, 3, "A ticket from the Mimosa's passage, a hymn book, a flat iron, and a photograph of men digging a canal in their Sunday hats.")])
    script("gaiman_museum", "gai_curator", say("Museum Keeper",
           "Croeso! Welcome. The Mimosa was a tea clipper, built for speed, not for families. Two months at sea, and some of the children didn't live to see land. They named the first town Trerawson, and then had to survive in it.",
           "They had been told Patagonia was green like Wales. It was not. They lived in caves and huts on the shore that first winter. What saved them was stubbornness, and the Tehuelche."))
    interior(OUT, "gaiman_chapel", "Capel Bethel", zid, r_chapel, "church",
             [npc("gai_minister", "choir_singer", 6, 2, "gai_minister", name="Deacon")])
    script("gaiman_chapel", "gai_minister", say("Deacon",
           "Bethel. There are chapels all along the valley, little brick boxes in the fields, each built by the families round it. Sunday school was where most children learnt to read Welsh.",
           "We still have a cymanfa ganu, a hymn-singing festival, every year. The roof has stayed on so far."))
    interior(OUT, "gaiman_tea", "Tŷ Te", zid, r_tea, "cafe",
             [npc("gai_tea_owner", "jam_maker", 3, 1, "gai_tea_owner", name="Tea House Owner")],
             props=[("kettle_table", 9, 1, {})],
             signs=[(9, 6, "TE GYMREIG. Welsh tea: scones, bara brith, cream, jam, and a slice of torta negra. Refills until you surrender.")])
    script("gaiman_tea", "gai_tea_owner", say("Tea House Owner",
           "Sit, sit. This is torta negra, black cake: a dark fruit cake our great-grandmothers made to last through the winter and the long journeys. It keeps for months. It rarely gets the chance."))
    interior(OUT, "gaiman_first", "Tŷ Cyntaf", zid, r_first, "cottage",
             [npc("gai_guide", "villager_3", 3, 3, "gai_guide", name="Volunteer Guide")], w=11, h=9)
    script("gaiman_first", "gai_guide", say("Volunteer Guide",
           "The first house in Gaiman, built in 1874. Two rooms, thick walls and a fireplace. A family of eight lived here and thought it was splendid.",
           "Gaiman wasn't planned as a town. It grew round a mill and a chapel, which is the most Welsh thing I can think of."))
    sanctuary_and_shop(OUT, zid, "Gaiman", ret_s, ret_h,
        ["Bienvenidos, croeso! The Sanctuary. The doctor speaks Spanish, the nurse speaks Welsh, and the creatures don't mind either.",
         "Pop them on the bed. There's a pot of tea on, naturally.",
         "There. Fit to win a chair at the eisteddfod.",
         "The Ark's by the window. It came all the way from Liverpool, like everything else in this valley.",
         "Hwyl! Go well."],
        ("Buenas tardes! Prynhawn da! Prices in pesos, I'm afraid. They change faster than the weather, and the weather here changes a lot.",
         "Diolch! Gracias! Mind the wind."),
        ["cup_of_tea", "flask_of_tea", "smelling_salts", "wicker_snare", "iron_snare", "water_snare", "night_snare",
         "torta_negra", "mate_gourd", "patagonia_lamb"])


def gaiman_quest():
    zid, qid = "gaiman", "gaiman_tea"
    q = Q + qid
    hint = say("Prifardd Eluned", "Gwen at the tea house wants the whole story before she'll cut her best torta negra for you: the Mimosa from the Museum Keeper, the Tehuelche side from the weaver by the fields, and diolch from the teacher. Then a rhea, to show me you've been out on the steppe.")
    show = [when("party_has_choiquet",
                 say("Prifardd Eluned", "A choiquet! They're quicker than they look, and they look very quick. Now then. The chair goes to whoever earns it.") +
                 [setf(q + "_4"), battle("gai_legend")] +
                 say("Prifardd Eluned", "Well sung, as it were. Here: torta negra from Gwen, a mate gourd from Rhys, and the valley's thanks. Diolch yn fawr.") +
                 [give("torta_negra", 3), give("mate_gourd"), give("gaiman_shawl")] + stand_abroad(3) + [setf(q + "_done")],
                 say("Prifardd Eluned", "Now catch a choiquet, a young rhea, out on the steppe north of town, and bring it to show me."))]
    DLG[zid]["gai_legend_talk"] = [cmd_if(q + "_done",
        say("Prifardd Eluned", "Our friend from the old country! Come back for the eisteddfod. Bring a choir."),
        [cmd_if(q + "_started", chain([q + "_1", q + "_2", q + "_3"], show, hint),
                say("Prifardd Eluned", "Shwmae! You've come a long way to a little bit of Wales. Want to understand Y Wladfa? Hear three people: the Museum Keeper on the Mimosa, the Tehuelche weaver by the fields, and the Welsh teacher. Then come back to me.") + [setf(q + "_started")])])]
    DLG["gaiman_museum"]["gai_curator"] += [cmd_if(q + "_started", [setf(q + "_1")])]
    add_step(zid, "gai_craftswoman", qid, "2")
    add_step(zid, "gai_teacher", qid, "3")
    return {"id": "abroad_gaiman_tea", "title": "Te Bach in Patagonia", "region": "abroad_patagonia", "town": zid, "giver": "Prifardd Eluned",
            "summary": "Hear how the Welsh came to Patagonia, from three people who know, then show the Archdruid a rhea.",
            "start_flag": q + "_started",
            "steps": [{"flag": q + "_1", "text": "Hear about the Mimosa from the Museum Keeper in the old station.", "zone": "gaiman_museum"},
                      {"flag": q + "_2", "text": "Hear the Tehuelche side from the weaver by the fields.", "zone": zid},
                      {"flag": q + "_3", "text": "Learn a Welsh word from the teacher by the school.", "zone": zid},
                      {"flag": q + "_4", "text": "Catch a choiquet on the steppe and show the Archdruid, then take her challenge.", "zone": zid}],
            "done_flag": q + "_done", "reward": "Torta negra, a mate gourd, a Gaiman shawl (a Gale charm) and standing with Kin Abroad."}


# =====================================================================================================================
# Cape Breton: Baddeck, on the Bras d'Or Lake
# =====================================================================================================================
def baddeck(OUT):
    zid, F = "baddeck", FLOOR_FAR
    WX = {"clear": 24, "drizzle": 22, "fog": 16, "sunshine": 14, "gale": 10, "downpour": 8, "frost": 6}
    z = base(zid, "Baddeck", "abroad_cape_breton", "town_scotland", WX, "coast", F, grass="#5a8a44")
    z.legend["n"] = {"tile": "tall_grass", "colour": "#4a7a3a"}
    z.legend["_water"] = {"deep": "#14445a", "deep_top": "#2a6a80", "shallow": "#4a8a96"}
    W, H = 60, 44
    z.border("P", 2)
    # the Bras d'Or Lake to the south, a wharf, and Beinn Bhreagh across the water
    z.rect(2, 33, W - 4, 9, "$"); z.rect(2, 32, W - 4, 1, "w"); z.rect(2, 31, W - 4, 1, "s")
    z.rect(40, 38, 14, 4, "k"); mound(z, 47, 41, 8, 4, 3)
    scatter_props(z, "pine", 40, 38, 14, 4, 10, 21, avoid=("k",))
    z.building(26, 31, 8, 3, "pier", "Government Wharf", show_label=False)
    for (bx, by) in [(20, 35), (36, 34), (14, 36)]:
        z.prop("boat", bx, by, variant=1)
    # spruce woods to the north
    z.rect(2, 2, W - 4, 6, "P"); blob(z, 30, 9, 26, 3, "n", only="k", seed=21, jitter=0.5)
    z.rect(2, 8, 14, 4, "n"); z.rect(46, 8, 12, 4, "n")
    # Chebucto Street, Baddeck's main street
    z.rect(2, 19, W - 4, 2, "="); z.rect(2, 18, W - 4, 1, "#"); z.rect(2, 26, W - 4, 1, "#")
    z.rect(29, 21, 2, 10, "#")
    r_bell = door(z, 4, 13, 10, "waterfront_museum", "Alexander Graham Bell Museum", "baddeck_bell", bh=5)
    r_hall = door(z, 16, 14, 8, "whalers_church", "Parish Hall", "baddeck_hall")
    ret_s, ret_h = town_buildings(z, zid, (26, 14, "sanctuary"), (33, 14, "shop"))
    z.building(39, 14, 6, 4, "cb_shingle", "Baddeck")
    z.building(46, 14, 5, 4, "cb_shingle", "Baddeck")
    z.building(52, 14, 5, 4, "weatherboard", "Baddeck")
    r_class = door(z, 4, 22, 8, "cb_shingle", "Gaelic Class", "baddeck_class")
    z.building(14, 22, 6, 4, "cb_shingle", "Baddeck")
    z.building(33, 22, 6, 4, "weatherboard", "Baddeck")
    z.building(40, 22, 7, 4, "cb_shingle", "The Inn")
    z.building(49, 22, 7, 4, "cb_shingle", "Baddeck")
    for (lx, ly) in [(3, 18), (15, 18), (38, 18), (51, 18), (13, 26), (32, 26), (48, 26)]:
        z.prop("lamp_post", lx, ly)
    z.prop("bench", 24, 30); z.prop("bench", 36, 30); z.prop("bollard", 25, 30); z.prop("bollard", 34, 30)
    z.prop("lobster_pots", 22, 30); z.prop("lobster_pots", 38, 30)
    z.d["spawn"] = [30, 20]
    P = "abroad_baddeck_"
    plaque(z, 25, 18, P + "nova_scotia", "New Scotland",
           "Nova Scotia is Latin for New Scotland. The name comes from a charter of 1621, when James VI of Scotland and I of England granted the land to Sir William Alexander. Scots in great numbers only came later, from 1773, when the ship Hector landed some 190 Highlanders at Pictou.")
    plaque(z, 21, 26, P + "clearances", "The Clearances",
           "From the late 1700s to the mid 1800s many Highland landlords cleared tenants off their land to make way for sheep. Whole townships were emptied, and tens of thousands of Gaels emigrated, many of them to Cape Breton, where the hills and the sea looked a little like home.")
    plaque(z, 13, 26, P + "gaelic", "Gàidhlig in Canada",
           "At one time Scottish Gaelic was spoken by tens of thousands of people in Nova Scotia. It faded over the 20th century, but it is taught again in schools and community classes, and Nova Scotia has an Office of Gaelic Affairs.")
    plaque(z, 36, 18, P + "college", "The Gaelic College",
           "A few miles up the road at St Ann's is the Gaelic College, Colaisde na Gàidhlig, founded in 1938. It teaches the language, piping, Highland dance and fiddle. At Iona, on the lake, the Highland Village, Baile nan Gàidheal, shows how the first Gaelic settlers lived.")
    plaque(z, 7, 18, P + "bell", "Beinn Bhreagh",
           "Alexander Graham Bell, born in Edinburgh in 1847, spent his summers here from the 1880s at Beinn Bhreagh, Gaelic for beautiful mountain, across the bay. He died there in 1922 and is buried on the mountain. Visitors then and now say the hills and water look like the Highlands.")
    plaque(z, 30, 30, P + "silver_dart", "The Silver Dart",
           "On 23 February 1909 the Silver Dart, built by Bell's Aerial Experiment Association, took off from the ice of Baddeck Bay with J. A. D. McCurdy at the controls. It was the first powered, controlled flight in Canada. The ice held. Everyone was relieved.")
    plaque(z, 40, 30, P + "bras_dor", "The Bras d'Or Lake",
           "Not quite a lake: the Bras d'Or is an inland sea of salt and fresh water, nearly cutting Cape Breton in two. It is a UNESCO Biosphere Reserve. Bald eagles nest round its shores, and Bell tested his hydrofoil boats on it; the HD-4 set a world water speed record here in 1919.")
    plaque(z, 47, 26, P + "celtic_colours", "Celtic Colours",
           "Every October since 1997, the Celtic Colours festival fills halls all round Cape Breton with fiddlers, pipers, singers and step dancers, just as the maples turn red and gold. Cape Breton fiddling keeps an older Scottish style alive, played for dancers.")
    chat(z, "bad_fiddler", "fiddler", 22, 18, "Fiddler",
         ["Ciamar a tha thu? How are you? I play the Cape Breton way: strathspeys and reels, driving, with the foot going. My great-great-grandparents brought the tunes from Moidart. We kept them, and we kept playing them for dancers.",
          "Some folk say the old Scottish style survived better here than in Scotland. Don't say that in Scotland. Or here, if a piper's listening."], "down")
    chat(z, "bad_milling", "ceilidh_caller", 44, 26, "Milling Frolic Singer",
         ["A milling frolic! Long ago, fresh-woven cloth had to be beaten to thicken it, so everyone sat round a table and thumped it in time to Gaelic songs. In Scotland it's called waulking. Here it's a frolic, because it is one.",
          "We still do it for the songs. The cloth is optional. The tea is not."], "down")
    chat(z, "bad_elder", "villager_6", 18, 26, "Gaelic Speaker",
         ["My mother had no English when she started school. The teachers punished Gaelic in those days, and so people stopped passing it on. I'm learning it back from my granddaughter, which is a strange way round, but it works.",
          "Ceud mìle fàilte, we say: a hundred thousand welcomes. It's only polite to mean all of them."], "down")
    chat(z, "bad_eagle_watcher", "birdwatcher", 52, 30, "Eagle Watcher",
         ["Bald eagles. Dozens nest round the Bras d'Or. They look magnificent and they steal fish off ospreys. Nature has no sense of dignity."], "down")
    chat(z, "bad_lobster", "fisherman_north", 33, 30, "Lobster Fisher",
         ["Lobster season's set by law here, with traps and licences counted. You learn to read a lobster's face. They mostly look annoyed, so it's not a hard read."], "down")
    creature_npc(z, "bad_moose", "mooslet", 10, 9, "A young moose looks up from the willow it is eating, chews thoughtfully, and goes back to it. It is the size of a horse and it is not yet finished growing.")
    flight_home(z, zid, "cape_breton", 57, 20, "commuter", "Airport Shuttle",
                "Sydney for the little airport, named after J. A. D. McCurdy of the Silver Dart, then Halifax and the overnight to London. The RAF can't land a Voyager in Baddeck.")
    wild_at(z, F, [("mooslet", 10, {}), ("fawnlet", 10, {}), ("snowhare", 10, {}), ("stoatlet", 8, {}), ("ospret", 8, {}),
                   ("buntling", 6, {"weather": ["frost", "fog"]}), ("hootlet", 6, {"time": ["night"]}), ("grizzlet", 10, {}), ("eaglet", 6, {})])
    wild_at(z, F, [("pinchkin", 12, {}), ("clawcastle", 4, {}), ("pupplash", 10, {}), ("greyhaul", 6, {}), ("bradan", 8, {}), ("gannetling", 8, {})], "water")
    trainer(z, "bad_piper", "Piper Calum", "Piper", "piper",
            [("caperling", 95), ("capercaillie", 96), ("stagmor", 96), ("snowbunting", 95)], 34, 18, "down",
            ["I've been asked to play quieter. I have declined. Shall we?"],
            "Fair play. I'll do the lament for my team later.",
            "Pipes, fiddles and Gaelic song came over with the settlers and are taught at the Gaelic College at St Ann's.", 5700)
    trainer(z, "bad_stepdancer", "Step Dancer Morag", "Step Dancer", "festival_goer",
            [("leveret", 95), ("gealhare", 96), ("swiftlet", 95), ("stormswift", 96)], 10, 26, "down",
            ["Cape Breton step dancing: close to the floor, the feet doing the talking. Mine never stop talking. Battle?"],
            "My feet are sulking. Well done.",
            "Cape Breton step dance keeps the feet low and the upper body still, and it is danced to the fiddle. It is closely tied to the music.", 5700)
    trainer(z, "bad_skipper", "Skipper Angus", "Lake Skipper", "sailor",
            [("pinchkin", 95), ("clawcastle", 96), ("greyhaul", 96), ("plungebeak", 96)], 27, 30, "left",
            ["The Bras d'Or is calm until it isn't. Same with me."],
            "You'd do on a lobster boat.",
            "The Bras d'Or Lake is fed by the sea through narrow channels, so its water is salty but less salty than the open Atlantic.", 5700)
    trainer(z, "bad_legend", "Bard Catrìona", "Gaelic Bard", "keeper_isla",
            [("bullmoose", 97), ("cailleach", 97), ("selkie", 96), ("goldeneyrie", 97), ("highlynx", 96), ("brownie", 97)], 24, 18, "down",
            ["A bard keeps the songs: who left, who stayed, who was cleared off which glen. I'll sing you one after. First, let's see your mettle."],
            "Math fhèin! Very good indeed. Come in to the frolic.",
            "Gaelic songs carried the memory of the Clearances and the crossing: there are songs of longing for the old country, and songs of praise for the new.", 9500)
    legend_trainer(z, "bad_legend", "bad_legend_talk", "Bard Catrìona")
    scaled_at(["bad_piper", "bad_stepdancer", "bad_skipper", "bad_legend"], F)
    finish_zone(z)
    z.save(OUT + "/" + zid + ".json")
    interior(OUT, "baddeck_bell", "Alexander Graham Bell Museum", zid, r_bell, "museum",
             [npc("bad_curator", "astronomer", 6, 2, "bad_curator", name="Museum Guide")],
             signs=[(2, 3, "Kites made of red silk tetrahedrons, a hydrofoil the length of a bus, and a telephone, of course.")])
    script("baddeck_bell", "bad_curator", say("Museum Guide",
           "Bell grew up in Edinburgh. His father taught elocution, his mother was deaf, and he spent his life teaching deaf people to speak. The telephone came out of that work, in 1876. Baddeck was where he came to think.",
           "He built enormous kites from tetrahedrons, flew aeroplanes off the bay ice and raced hydrofoils on the lake. The neighbours were remarkably patient."))
    interior(OUT, "baddeck_hall", "Parish Hall", zid, r_hall, "hall",
             [npc("bad_caller", "ceilidh_caller", 6, 2, "bad_caller", name="Ceilidh Host")],
             props=[("piano", 2, 1, {})])
    script("baddeck_hall", "bad_caller", say("Ceilidh Host",
           "Céilidh tonight! In Gaelic a cèilidh was just a visit: neighbours dropping in for songs and stories. Now it's a fiddler, a piano player and the whole parish on the floor.",
           "Square sets, step dancing, and a cup of tea at the interval. If you don't know the steps, stand near someone's granny. She'll steer."))
    interior(OUT, "baddeck_class", "Gaelic Class", zid, r_class, "school",
             [npc("bad_tutor", "poet", 6, 2, "bad_tutor", name="Gaelic Tutor")])
    script("baddeck_class", "bad_tutor", say("Gaelic Tutor",
           "Fàilte! Welcome. Tonight: tapadh leat, thank you, and slàinte mhath, good health, which you'll need at the frolic. And Ceap Breatainn: Cape Breton.",
           "Cape Breton Gaelic is Scottish Gaelic, with its own words and turns of phrase, the way a family keeps its own sayings. Irish is a cousin. Related, not the same."))
    sanctuary_and_shop(OUT, zid, "Baddeck", ret_s, ret_h,
        ["Welcome to the Sanctuary. We get a lot of visitors who've been chased by a moose. Have you been chased by a moose?",
         "Lie them down there. I'll put the kettle on.",
         "All better. Steady as a lobster boat.",
         "The Ark's in the back by the woodstove.",
         "Mar sin leibh! Goodbye for now."],
        ("Hello there! Prices in Canadian dollars. Oatcakes, maple syrup, a bit of everything.", "Watch for moose on the road!"),
        ["cup_of_tea", "flask_of_tea", "smelling_salts", "wicker_snare", "iron_snare", "water_snare", "night_snare",
         "maple_syrup", "oatcakes_cb", "lobster_roll"])


def baddeck_quest():
    zid, qid = "baddeck", "baddeck_frolic"
    q = Q + qid
    hint = say("Bard Catrìona", "For a milling frolic I need a fiddler, a singer who knows the songs, and someone who still has the Gaelic. Ask the fiddler on the main street, the milling singer by the inn, and the Gaelic speaker down by the class. Then come back.")
    fight = say("Bard Catrìona", "Fiddle, songs and the Gaelic: we're set. One last thing. A bard tests every guest.") + [battle("bad_legend")] + \
        say("Bard Catrìona", "Sit in, sit in. Here's a length of tweed off the table, some oatcakes and syrup, and a song for the road. Slàinte mhath!") + \
        [give("milled_tweed"), give("oatcakes_cb", 3), give("maple_syrup", 2)] + stand_abroad(3) + [setf(q + "_done")]
    DLG[zid]["bad_legend_talk"] = [cmd_if(q + "_done",
        say("Bard Catrìona", "Ceud mìle fàilte, always. Come back in October for Celtic Colours."),
        [cmd_if(q + "_started", chain([q + "_1", q + "_2", q + "_3"], fight, hint),
                say("Bard Catrìona", "Halò! I'm getting up a milling frolic and I'm short of hands. Find me the fiddler, the milling singer and the Gaelic speaker. They're all in town.") + [setf(q + "_started")])])]
    add_step(zid, "bad_fiddler", qid, "1")
    add_step(zid, "bad_milling", qid, "2")
    add_step(zid, "bad_elder", qid, "3")
    return {"id": "abroad_baddeck_frolic", "title": "The Milling Frolic", "region": "abroad_cape_breton", "town": zid, "giver": "Bard Catrìona",
            "summary": "Gather a fiddler, a singer and a Gaelic speaker for a milling frolic, then face the bard.",
            "start_flag": q + "_started",
            "steps": [{"flag": q + "_1", "text": "Ask the fiddler on Chebucto Street.", "zone": zid},
                      {"flag": q + "_2", "text": "Ask the milling frolic singer by the inn.", "zone": zid},
                      {"flag": q + "_3", "text": "Ask the Gaelic speaker by the Gaelic class, then return to the bard.", "zone": zid}],
            "done_flag": q + "_done", "reward": "Milled tweed (a Frost charm), oatcakes, maple syrup and standing with Kin Abroad."}


# =====================================================================================================================
# Boston: the Irish city
# =====================================================================================================================
def boston(OUT):
    zid, F = "boston", FLOOR_FAR
    WX = {"clear": 28, "sunshine": 18, "drizzle": 18, "downpour": 10, "fog": 8, "gale": 8, "frost": 10}
    z = base(zid, "Boston", "abroad_boston", "town_ireland_session", WX, "city", F, fill=":", grass="#5a8a44")
    z.legend[":"] = {"tile": "cobbles", "colour": "#8a7a6e"}
    z.legend["n"] = {"tile": "tall_grass", "colour": "#4e8a3c"}
    W, H = 60, 44
    z.rect(0, 0, W, H, ":")
    z.border("T", 2)
    # the harbour to the east
    z.rect(50, 2, 10, H - 4, "$"); z.rect(49, 2, 1, H - 4, "w")
    z.rect(48, 2, 1, H - 4, ":")
    z.building(44, 30, 5, 3, "pier", "Long Wharf", show_label=False)
    for (bx, by) in [(53, 10), (55, 24), (52, 36)]:
        z.prop("boat", bx, by, variant=2)
    # the Common, with tall grass and trees, in the south-west
    z.rect(2, 29, 30, 13, "k"); blob(z, 16, 35, 11, 4, "n", only="k", seed=31, jitter=0.4)
    scatter_props(z, "oak", 3, 30, 28, 11, 12, 32, avoid=("k",))
    z.rect(33, 29, 2, 13, "#"); z.rect(14, 34, 3, 3, "~")   # the Frog Pond
    # Washington Street, and the corner of School Street with the Famine Memorial
    z.rect(2, 19, 46, 2, "="); z.rect(2, 18, 46, 1, ":"); z.rect(2, 26, 46, 1, ":")
    z.rect(24, 21, 2, 8, "="); z.rect(36, 27, 11, 2, ":")
    r_church = door(z, 3, 12, 8, "limestone_church", "St Stephen's Church", "boston_church", bh=6)
    r_heritage = door(z, 12, 14, 8, "boston_brick", "Irish Heritage Centre", "boston_heritage")
    ret_s, ret_h = town_buildings(z, zid, (21, 14, "sanctuary"), (28, 14, "shop"))
    z.building(34, 13, 13, 5, "market_hall", "Faneuil Hall")
    r_pub = door(z, 3, 22, 7, "irish_shopfront", "The Emigrant", "boston_pub")
    z.building(11, 22, 5, 4, "boston_brick", "Boston")
    z.building(17, 22, 6, 4, "boston_brick", "Boston")
    z.building(27, 22, 5, 4, "boston_triple", "Boston")
    z.building(33, 22, 5, 4, "boston_triple", "Boston")
    z.building(40, 22, 7, 4, "boston_brick", "Boston")
    # the memorial: two groups of figures, famine and arrival
    z.prop("statue", 37, 28); z.prop("statue", 43, 28)
    for (lx, ly) in [(3, 18), (12, 18), (33, 18), (47, 18), (10, 26), (26, 26), (39, 26)]:
        z.prop("lamp_post", lx, ly)
    z.prop("bench", 40, 27); z.prop("bench", 41, 27); z.prop("bollard", 47, 29); z.prop("bollard", 47, 33)
    z.prop("phone_box", 20, 26)
    z.d["spawn"] = [25, 20]
    P = "abroad_boston_"
    plaque(z, 40, 29, P + "memorial", "Boston Irish Famine Memorial",
           "Unveiled in 1998, 150 years after the worst of the Famine. One group of figures shows a family starving in Ireland; the other, a family stepping ashore in Boston, thin but looking up. Between them is the whole story of a people.")
    plaque(z, 34, 26, P + "famine", "An Gorta Mór",
           "From 1845 potato blight destroyed the crop that most of Ireland's poor lived on. Over the next seven years about a million people died of hunger and disease, and more than a million emigrated. Food was still being exported from Ireland while people starved, which is not forgotten.")
    plaque(z, 46, 29, P + "black_47", "Black '47",
           "1847 was the worst year, Black '47. That year alone, tens of thousands of Irish emigrants landed in Boston, then a city of little over 100,000 people. Many came on overcrowded, disease-ridden vessels people called coffin ships. Many arrived sick.")
    plaque(z, 47, 36, P + "deer_island", "Deer Island",
           "Boston set up a quarantine hospital on Deer Island, out in the harbour, in 1847. Thousands of sick emigrants were treated there, and hundreds who died were buried on the island. A memorial now stands for them.")
    plaque(z, 19, 18, P + "kennedy", "Patrick Kennedy",
           "Patrick Kennedy, a farmer's son from Dunganstown in County Wexford, sailed for Boston in 1849 and became a cooper, making barrels. He died young, of cholera. His great-grandson, John F. Kennedy, became President of the United States in 1961 and visited Dunganstown in 1963.")
    plaque(z, 33, 18, P + "faneuil", "Faneuil Hall",
           "A market and meeting hall since 1742, where Bostonians argued their way towards the American Revolution. Later, the Irish argued their way into the city's politics: by the 1880s Boston had an Irish-born mayor, Hugh O'Brien.")
    plaque(z, 26, 27, P + "evacuation_day", "Evacuation Day",
           "On 17 March 1776 the British army left Boston after a siege. So 17 March is Evacuation Day in Boston as well as St Patrick's Day, and the parade in South Boston celebrates both. Nobody minds a second excuse.")
    plaque(z, 8, 26, P + "american_wake", "The American Wake",
           "Before an emigrant left Ireland, the family held an American wake: a night of music, dancing and tears, like a wake for the dead, because most never expected to see them again. Many emigrants sent money home, paying the fare for the next brother or sister.")
    plaque(z, 30, 30, P + "annie_moore", "Meanwhile, in New York",
           "On 1 January 1892 a 17-year-old from Cork, Annie Moore, became the first immigrant processed at the new Ellis Island station in New York harbour. There are statues of her at Ellis Island and at Cobh, the port she sailed from.")
    chat(z, "bos_genealogist", "tour_guide", 14, 18, "Family Historian",
         ["Half the people who come in here want to know where their great-great-grandmother came from. We start with ship lists, church registers and census records. Spelling was optional in those days.",
          "The Irish came with nothing but each other. They built Boston's streets, canals and railways, and the women went into service in the big houses. Within two generations they were running the city."], "down")
    chat(z, "bos_cop", "warden_grunt", 28, 26, "Police Officer",
         ["My great-grandfather joined the Boston police in the 1890s. The Irish took to the police and the fire service. My captain's a Murphy. So is his captain. It's a whole thing."], "down")
    chat(z, "bos_fan", "rugby_player", 18, 26, "Celtics Fan",
         ["Boston Celtics, founded 1946, named for the city's Irish. Green shirts, a shamrock, and a leprechaun on the badge. Don't get me started. Too late, you got me started."], "down")
    chat(z, "bos_newcomer", "student", 42, 26, "Newcomer",
         ["I came over from Galway on a work visa. My great-great-grandmother came the hard way, in 1847. I did it with a phone and a flat share. I still rang my mam from the airport crying."], "down")
    chat(z, "bos_dock", "steelworker", 46, 33, "Harbour Worker",
         ["They came in right here, off the ships. Some went straight to the hospital on Deer Island, some to a cellar in the North End, ten to a room. And they made something of it."], "left")
    flight_home(z, zid, "boston", 46, 20, "commuter", "Airport Cab",
                "Logan Airport? Seven hours to London overnight, if the wind's behind you. That's a lot quicker than the way your lot came over.", facing="left")
    wild_at(z, F, [("grizzlet", 12, {}), ("raidtail", 6, {}), ("cooplet", 10, {}), ("strutcoo", 6, {}), ("starlet", 10, {}),
                   ("peregrin", 6, {}), ("binfox", 8, {"time": ["dusk", "night"]}), ("flittermouse", 8, {"time": ["dusk", "night"]}), ("pincray", 8, {})])
    wild_at(z, F, [("chipgull", 12, {}), ("pierlord", 4, {}), ("pupplash", 8, {}), ("pinchkin", 10, {}), ("petrelash", 6, {"weather": ["gale"]})], "water")
    trainer(z, "bos_firefighter", "Firefighter Sullivan", "Firefighter", "warden_grunt",
            [("fizzlet", 95), ("catherwheel", 96), ("emberdrey", 96), ("pyredrey", 96)], 31, 18, "down",
            ["Engine company, fourth generation. Grandad, Dad, me and the dog. Let's go."],
            "You'd be good on a ladder.",
            "Irish Americans joined Boston's fire and police services in such numbers that it became a family tradition for many.", 5700)
    trainer(z, "bos_dancer", "Irish Dancer Siobhán", "Irish Dancer", "festival_goer",
            [("leveret", 95), ("gealhare", 96), ("pooka", 96), ("merrow", 96)], 4, 26, "down",
            ["Arms by your sides, chin up, feet like lightning. That's Irish dance. Battling is the same, minus the wig."],
            "Grand. I'll go and sulk at the feis.",
            "Irish dancing schools flourish across the Irish diaspora, from Boston to Birmingham. A feis is a dance and music competition.", 5700)
    trainer(z, "bos_bartender", "Barman Kevin", "Barman", "villager_2",
            [("cuppeen", 96), ("sheridram", 96), ("cluricaun", 95), ("versling", 95)], 11, 27, "down",
            ["There's a session on Thursdays. Fiddles, flutes, a bodhrán and a lad who only knows the one song. You'll battle first."],
            "On the house. Don't tell the owner.",
            "Irish traditional music sessions are held in pubs across Boston and the wider diaspora, and many tunes learnt in America have travelled back to Ireland.", 5700)
    trainer(z, "bos_legend", "Councillor Bridget", "City Councillor", "keeper_nuala",
            [("bansheen", 97), ("merrow", 97), ("connemarr", 96), ("finnmacool", 97), ("pooka", 97), ("cluricaun", 96)], 15, 26, "down",
            ["My great-great-grandmother was a Bridget too. She scrubbed floors on Beacon Hill. I sit on the city council. That's the story of this town in two lines. Shall we?"],
            "Not bad. You'd get my vote.",
            "Boston's Irish rose from labourers and servants to city hall within a few generations. Mayors such as John F. Fitzgerald, JFK's grandfather, came out of the Irish wards.", 9500)
    legend_trainer(z, "bos_legend", "bos_legend_talk", "Councillor Bridget")
    scaled_at(["bos_firefighter", "bos_dancer", "bos_bartender", "bos_legend"], F)
    finish_zone(z)
    z.save(OUT + "/" + zid + ".json")
    interior(OUT, "boston_heritage", "Irish Heritage Centre", zid, r_heritage, "library",
             [npc("bos_archivist", "gown_student", 6, 3, "bos_archivist", name="Archivist")])
    script("boston_heritage", "bos_archivist", say("Archivist",
           "This is the passenger list of a ship from Liverpool, April 1847: Sullivan, Murphy, Kelly, Walsh. Most Irish emigrants sailed from Liverpool, after a crossing of the Irish Sea, then six weeks or more on the Atlantic.",
           "And here, a Boston Pilot newspaper. Its 'Missing Friends' column ran for decades: notices from families trying to find each other. 'Information wanted of Mary Ryan, of Tipperary...' It's the saddest thing in the building."))
    interior(OUT, "boston_church", "St Stephen's Church", zid, r_church, "church",
             [npc("bos_priest", "choir_singer", 6, 2, "bos_priest", name="Parish Priest")])
    script("boston_church", "bos_priest", say("Parish Priest",
           "The Irish built their churches out of pennies, a few a week, for years. The parish was more than the Mass: it was the school, the club, the job board and the marriage bureau.",
           "Not everyone was welcoming. In the 1850s there was a whole political party, the Know Nothings, against Catholic immigrants. The Irish outlasted it. It's a lesson worth remembering when the next people arrive."))
    interior(OUT, "boston_pub", "The Emigrant", zid, r_pub, "cafe",
             [npc("bos_singer", "sean_nos_singer", 9, 3, "bos_singer", name="Session Singer", facing="left")],
             props=[("fireplace", 6, 1, {"walk": True})])
    script("boston_pub", "bos_singer", say("Session Singer",
           "A song from an American wake. The whole parish sang it the night before you left, then walked you to the road at dawn.",
           "There's a fella at the bar from Mayo who's been here forty years and still says 'home' when he means Ireland. We all do it.") +
           [{"do": "quiz", "pub": "boston_pub", "region": "overseas", "who": "Session Singer"}])
    sanctuary_and_shop(OUT, zid, "Boston", ret_s, ret_h,
        ["Hi, welcome to the Sanctuary. We take insurance, cash and wild creatures, no questions.",
         "Put them down there. I'll be quick, this is Boston.",
         "All set. Good as new, maybe better.",
         "The Ark's down the hall, past the vending machine.",
         "Take care now."],
        ("Hey! Prices in dollars. Chowder, soda bread, and something called a frappe, which is a milkshake. Don't argue.", "Have a good one."),
        ["cup_of_tea", "flask_of_tea", "smelling_salts", "wicker_snare", "iron_snare", "water_snare", "night_snare",
         "clam_chowder", "boston_soda_bread", "boston_cream_pie"])


def boston_quest():
    zid, qid = "boston", "boston_letter"
    q = Q + qid
    hint = say("Councillor Bridget", "Find out where my Bridget came from. Ask the Family Historian on Washington Street, then the Archivist in the Heritage Centre, then the priest at St Stephen's. Then come back.")
    fight = say("Councillor Bridget", "Tipperary, 1847, a coffin ship from Liverpool, a quarantine hospital, and floors on Beacon Hill. And she sent half her wages home, every month, for thirty years. Thank you. Now, my family never did anything without a fight first.") + \
        [battle("bos_legend")] + \
        say("Councillor Bridget", "Ha! Here: a claddagh ring, my grandmother's chowder recipe in a pot, and the thanks of the Ward. You'll do.") + \
        [give("emigrant_claddagh"), give("clam_chowder", 3)] + stand_abroad(3) + [setf(q + "_done")]
    DLG[zid]["bos_legend_talk"] = [cmd_if(q + "_done",
        say("Councillor Bridget", "You know where to find me. Everyone does. It's Boston."),
        [cmd_if(q + "_started", chain([q + "_1", q + "_2", q + "_3"], fight, hint),
                say("Councillor Bridget", "You're the one asking about the Famine ships? My great-great-grandmother Bridget came over in 1847. All we have is her name and a letter she sent home. Help me find the rest?") + [setf(q + "_started")])])]
    add_step(zid, "bos_genealogist", qid, "1")
    DLG["boston_heritage"]["bos_archivist"] += [cmd_if(q + "_started", [setf(q + "_2")])]
    DLG["boston_church"]["bos_priest"] += [cmd_if(q + "_started", [setf(q + "_3")])]
    return {"id": "abroad_boston_letter", "title": "The American Letter", "region": "abroad_boston", "town": zid, "giver": "Councillor Bridget",
            "summary": "Trace a famine emigrant through the records of Boston, then take on the councillor.",
            "start_flag": q + "_started",
            "steps": [{"flag": q + "_1", "text": "Ask the Family Historian on Washington Street.", "zone": zid},
                      {"flag": q + "_2", "text": "Read the passenger lists with the Archivist in the Irish Heritage Centre.", "zone": "boston_heritage"},
                      {"flag": q + "_3", "text": "Ask the Parish Priest at St Stephen's, then return to the councillor.", "zone": "boston_church"}],
            "done_flag": q + "_done", "reward": "An emigrant's claddagh ring (a Spirit charm), clam chowder and standing with Kin Abroad."}


# =====================================================================================================================
# Appalachia: Bristol, Tennessee and Virginia
# =====================================================================================================================
def bristol_tn(OUT):
    zid, F = "bristol_tn", FLOOR_FAR
    WX = {"sunshine": 26, "clear": 28, "drizzle": 14, "downpour": 12, "fog": 12, "gale": 4, "frost": 4}
    z = base(zid, "Bristol, Tennessee", "abroad_appalachia", "route_mountain", WX, "town", F, grass="#5a8a3a")
    z.legend["n"] = {"tile": "tall_grass", "colour": "#4a7a30"}
    W, H = 60, 44
    z.border("T", 2)
    # the Blue Ridge to the north, wooded; a creek along the south
    z.rect(2, 2, W - 4, 7, "T")
    mound(z, 30, 4, 30, 6, 4)
    smooth(z)
    blob(z, 30, 10, 26, 2, "n", only="k", seed=41, jitter=0.4)
    z.rect(2, 36, W - 4, 2, "~"); z.rect(2, 35, W - 4, 1, "w"); z.set(30, 36, "#"); z.set(30, 37, "#"); z.set(31, 36, "#"); z.set(31, 37, "#")
    blob(z, 14, 31, 10, 3, "n", only="k", seed=42, jitter=0.5)
    blob(z, 46, 31, 10, 3, "n", only="k", seed=43, jitter=0.5)
    scatter_props(z, "oak", 3, 28, 54, 6, 14, 44, avoid=("k",))
    scatter_props(z, "oak", 3, 38, 54, 4, 10, 45, avoid=("k",))
    # State Street: the state line runs down the middle of it
    z.rect(2, 19, W - 4, 2, "="); z.rect(2, 18, W - 4, 1, ":"); z.rect(2, 26, W - 4, 1, ":")
    z.rect(30, 21, 2, 14, "#")
    r_museum = door(z, 4, 14, 10, "bristol_store", "Birthplace of Country Music Museum", "bristol_tn_museum")
    ret_s, ret_h = town_buildings(z, zid, (16, 14, "sanctuary"), (23, 14, "shop"))
    z.building(29, 14, 6, 4, "bristol_store", "State Street")
    z.building(36, 14, 6, 4, "bristol_store", "State Street")
    r_church = door(z, 44, 13, 7, "chapel", "First Presbyterian", "bristol_tn_church", bh=5)
    z.building(52, 14, 5, 4, "bristol_store", "State Street")
    r_store = door(z, 4, 22, 8, "bristol_store", "Old-Time Music Store", "bristol_tn_store")
    z.building(14, 22, 6, 4, "bristol_store", "State Street")
    z.building(21, 22, 6, 4, "appalachian_frame", "Bristol")
    z.building(34, 22, 7, 4, "appalachian_frame", "Bristol")
    z.building(43, 22, 6, 4, "appalachian_frame", "Bristol")
    z.building(50, 22, 7, 4, "appalachian_frame", "Bristol")
    for (lx, ly) in [(3, 18), (15, 18), (28, 18), (43, 18), (13, 26), (33, 26), (49, 26)]:
        z.prop("lamp_post", lx, ly)
    z.prop("bench", 28, 26); z.prop("bench", 33, 18)
    z.d["spawn"] = [30, 20]
    P = "abroad_bristol_"
    plaque(z, 30, 21, P + "state_line", "The State Line",
           "Bristol is two towns, one in Tennessee and one in Virginia, and the state line runs down the middle of State Street. You can stand with one foot in each. The famous sign over the street says: Bristol VA-TN, A Good Place to Live.")
    plaque(z, 7, 18, P + "sessions", "The Bristol Sessions",
           "In the summer of 1927 Ralph Peer of the Victor Talking Machine Company set up a recording studio here and invited local musicians in. Among them were the Carter Family and Jimmie Rodgers. Country music grew from those recordings, and in 1998 the US Congress named Bristol the Birthplace of Country Music.")
    plaque(z, 25, 26, P + "ulster_scots", "From Ulster to the Mountains",
           "In the 1700s tens of thousands of Presbyterians from Ulster, descended from Scots who had settled there in the 1600s, sailed to America. They were escaping rising rents, bad harvests and laws that barred them from public office. In America they were called the Scotch-Irish.")
    plaque(z, 39, 18, P + "wagon_road", "The Great Wagon Road",
           "Most landed at Philadelphia, then went west and south down the Great Wagon Road, through the Shenandoah Valley into the backcountry of Virginia, the Carolinas and Tennessee. They cleared farms in the hollows and kept their kirk, their tunes and their independence.")
    plaque(z, 18, 26, P + "words", "Redd Up",
           "Some Scots and Ulster words crossed with them. To redd up means to tidy, in Ulster and in the mountains alike. A poke is a paper bag. Language travels light and lasts a long time.")
    plaque(z, 47, 26, P + "ballads", "Ballads in the Hills",
           "Old English and Scottish ballads were still being sung in these mountains long after they faded at home. Between 1916 and 1918 the English folk song collector Cecil Sharp, with Maud Karpeles, wrote down hundreds of songs and tunes in the southern Appalachians.")
    plaque(z, 34, 26, P + "banjo", "The Banjo",
           "The fiddle came from Scotland, Ireland and England. The banjo came from Africa: enslaved Africans brought the idea of the gourd-bodied, skin-headed lute with them. Old-time and country music grew out of all of them playing together, and that mix is the heart of it.")
    plaque(z, 52, 18, P + "jackson", "Andrew Jackson",
           "Andrew Jackson's parents left Boneybefore, near Carrickfergus in County Antrim, for the Carolinas in 1765, and he was born there two years later. He became the seventh President of the United States. A cottage at Boneybefore now tells the family story.")
    chat(z, "btn_fiddler", "fiddler", 22, 26, "Old-Time Fiddler",
         ["This tune came over from Ulster with somebody's great-great-great-grandpa. It's had a few name changes. Most of us play it a bit different. Nobody wrote it down for two hundred years, and it didn't seem to mind."], "down")
    chat(z, "btn_banjo", "bard", 36, 26, "Banjo Player",
         ["Folks forget where the banjo came from. Enslaved Africans made the first ones from gourds. Black and white musicians in these hills learnt from each other, and the music we call old-time is what came out."], "down")
    chat(z, "btn_ballad", "sean_nos_singer", 44, 26, "Ballad Singer",
         ["My granny sang 'Barbara Allen' to us. Turns out it was being sung in Scotland and England three hundred years ago. She had no idea. She just thought it was a sad song about a girl who should've been nicer."], "down")
    chat(z, "btn_ranger", "hiker", 30, 30, "Park Volunteer",
         ["Appalachia is the salamander capital of the world. More kinds of salamander here than anywhere else on Earth, and the biggest is the hellbender. Up to two feet long, flat as a pancake and lives under rocks in clean, fast streams. Bring me one, if you find one."], "down")
    chat(z, "btn_porch", "villager_5", 54, 26, "Porch Sitter",
         ["Redd up the porch, my mama'd say. Then we'd sit on it all evening. That's two Ulster habits right there: tidying, and not moving afterwards."], "down")
    creature_npc(z, "btn_fireflies", "glowmite", 12, 11, "On warm summer evenings in these mountains the fireflies flash. In parts of the Smokies one kind even flashes in time, all together, for a couple of weeks in June.")
    flight_home(z, zid, "appalachia", 57, 20, "commuter", "Shuttle Driver",
                "Tri-Cities Airport, then a hop to a big airport and the overnight to London. The RAF don't do the hop. I asked them for you.")
    wild_at(z, F, [("hellbendlet", 10, {"weather": ["drizzle", "downpour"]}), ("grizzlet", 10, {}), ("fawnlet", 10, {}), ("zigzlet", 8, {}),
                   ("glowmite", 8, {"time": ["dusk", "night"]}), ("croakle", 8, {}), ("hootlet", 6, {"time": ["night"]}), ("flittermouse", 8, {"time": ["dusk", "night"]}),
                   ("pipkin", 8, {})])
    wild_at(z, F, [("hellbendlet", 14, {}), ("pincray", 12, {}), ("croakle", 8, {}), ("parrlet", 8, {})], "water")
    trainer(z, "btn_picker", "Picker Earl", "Guitar Picker", "rocker",
            [("tootlet", 95), ("bombardon", 96), ("starlet", 95), ("murmurant", 96)], 26, 18, "down",
            ["I play guitar the way Maybelle Carter did: thumb on the melody, fingers on the rhythm. You got a minute?"],
            "Well, I'll be. That's a fine thumb you've got.",
            "Maybelle Carter of the Carter Family played the tune on the bass strings and the rhythm on the top, a style called the Carter scratch that guitarists copied for decades.", 5700)
    trainer(z, "btn_moonshine", "Old Man Hollis", "Mountain Farmer", "farmer",
            [("whiffhorn", 95), ("forcelet", 95), ("rhubarbarian", 96), ("bramblehog", 96)], 50, 18, "down",
            ["My people came from County Down by way of Pennsylvania. Took 'em sixty years to get here. Took me sixty seconds to decide to battle you."],
            "Well. I'll redd up and go home.",
            "Many Ulster Scots families moved on several times, from Pennsylvania to Virginia to Tennessee and beyond, a generation at a time.", 5700)
    trainer(z, "btn_cloggers", "Clogger Dolly", "Flatfoot Dancer", "festival_goer",
            [("leveret", 95), ("gealhare", 96), ("swiftlet", 95), ("stormswift", 96)], 9, 26, "down",
            ["Flatfooting, clogging, buck dancing: shoes on a wood floor and the fiddle going. Everybody's grandmother can do it. Mine will beat you."],
            "Shoot. Nice footwork.",
            "Appalachian flatfooting and clogging draw on Irish, Scottish and English step dancing and on African American dance, all mixed on the same floors.", 5700)
    trainer(z, "btn_legend", "Granny Opal", "Old-Time Legend", "keeper_maud",
            [("hellbender", 97), ("adderking", 97), ("lanternis", 96), ("stagmor", 97), ("rookery", 96), ("thornsow", 97)], 12, 18, "down",
            ["I've played every porch, church and county fair from here to Asheville. Now, child, let's see if you can keep time."],
            "You kept time. That's all music asks.",
            "Old-time music is passed on by ear, at jam sessions and on porches, which is why one tune can have a dozen names and a dozen versions.", 9500)
    legend_trainer(z, "btn_legend", "btn_legend_talk", "Granny Opal")
    scaled_at(["btn_picker", "btn_moonshine", "btn_cloggers", "btn_legend"], F)
    finish_zone(z)
    z.save(OUT + "/" + zid + ".json")
    interior(OUT, "bristol_tn_museum", "Birthplace of Country Music Museum", zid, r_museum, "museum",
             [npc("btn_curator", "tour_guide", 6, 2, "btn_curator", name="Museum Guide")],
             signs=[(2, 3, "A 1927 recording machine, a Victor 78 record, and a photograph of the Carter Family looking very serious about being famous.")])
    script("bristol_tn_museum", "btn_curator", say("Museum Guide",
           "In 1927 Ralph Peer put an advert in the paper and musicians came down out of the hills to record. The Carter Family drove in from Maces Spring, Virginia. Jimmie Rodgers came up from Asheville. Records made here sold all over America.",
           "Johnny Cash, who married into the Carter Family, called the Bristol Sessions the most important event in the history of country music. He may have been a little biased."))
    interior(OUT, "bristol_tn_church", "First Presbyterian", zid, r_church, "church",
             [npc("btn_minister", "choir_singer", 6, 2, "btn_minister", name="Minister")])
    script("bristol_tn_church", "btn_minister", say("Minister",
           "The Ulster Scots brought their Presbyterian kirk with them, and wherever they settled they built a church and a school, often the same building.",
           "Plain churches, long sermons and psalms sung without instruments, at first. The fiddle was for Saturday night. Sunday was for repenting of Saturday night."))
    interior(OUT, "bristol_tn_store", "Old-Time Music Store", zid, r_store, "workshop",
             [npc("btn_luthier", "shipwright", 6, 3, "btn_luthier", name="Instrument Maker")])
    script("bristol_tn_store", "btn_luthier", say("Instrument Maker",
           "Fiddles, banjos, dulcimers. The mountain dulcimer was made here in Appalachia, by settlers working from memory of German and Scandinavian zithers. Lap it, strum it, and it sounds like a hillside.",
           "Jam's on Thursday. Bring an instrument or a pie."))
    sanctuary_and_shop(OUT, zid, "Bristol", ret_s, ret_h,
        ["Hey there, welcome to the Sanctuary. Which side of the state line are you on? Doesn't matter, we heal both.",
         "Set 'em down there, sugar.",
         "All better. Fit as a fiddle, as we say.",
         "The Ark's round back.",
         "Y'all come back now."],
        ("Howdy! Biscuits, gravy, cornbread, and the best sweet tea on State Street. In dollars.", "Mind how you go."),
        ["cup_of_tea", "flask_of_tea", "smelling_salts", "wicker_snare", "iron_snare", "water_snare", "night_snare",
         "biscuits_gravy", "cornbread", "sweet_tea"])


def bristol_quest():
    zid, qid = "bristol_tn", "bristol_tune"
    q = Q + qid
    hint = say("Granny Opal", "Every tune has a family tree. Hear it from the old-time fiddler, the banjo player and the ballad singer on State Street. Then find a hellbender in the creek and show the park volunteer. Then come back.")
    fight = say("Granny Opal", "Ulster fiddle, African banjo, English and Scottish ballads, and a salamander for luck. That's Appalachia. Now let's play.") + [battle("btn_legend")] + \
        say("Granny Opal", "Here: a dulcimer pick, a pan of cornbread and a jug of sweet tea. And you play that tune the way you heard it. That's how it lives.") + \
        [give("dulcimer_pick"), give("cornbread", 3), give("sweet_tea", 2)] + stand_abroad(3) + [setf(q + "_done")]
    DLG[zid]["btn_legend_talk"] = [cmd_if(q + "_done",
        say("Granny Opal", "Come back for the jam, honey. Thursday."),
        [cmd_if(q + "_started", chain([q + "_1", q + "_2", q + "_3", q + "_4"], fight, hint),
                say("Granny Opal", "You came all the way from Ulster's side of the water? Then you'll want to hear where our music came from. Go ask the fiddler, the banjo player and the ballad singer, and find a hellbender in the creek for the park volunteer.") + [setf(q + "_started")])])]
    add_step(zid, "btn_fiddler", qid, "1")
    add_step(zid, "btn_banjo", qid, "2")
    add_step(zid, "btn_ballad", qid, "3")
    DLG[zid]["btn_ranger"] += [cmd_if(q + "_started", [when("party_has_hellbendlet",
        say("Park Volunteer", "A hellbender! Look at those wrinkly sides: that's how it breathes, through its skin. They need clean, cold, fast water, so finding one means the creek is healthy.") + [setf(q + "_4")])])]
    return {"id": "abroad_bristol_tune", "title": "Where the Tune Came From", "region": "abroad_appalachia", "town": zid, "giver": "Granny Opal",
            "summary": "Trace the roots of an old-time tune from Ulster, Africa and the old ballads, and find a hellbender.",
            "start_flag": q + "_started",
            "steps": [{"flag": q + "_1", "text": "Hear the old-time fiddler on State Street.", "zone": zid},
                      {"flag": q + "_2", "text": "Hear the banjo player.", "zone": zid},
                      {"flag": q + "_3", "text": "Hear the ballad singer.", "zone": zid},
                      {"flag": q + "_4", "text": "Catch a hellbendlet in the creek and show the park volunteer, then return to Granny Opal.", "zone": zid}],
            "done_flag": q + "_done", "reward": "A dulcimer pick (a Storm charm), cornbread, sweet tea and standing with Kin Abroad."}


# =====================================================================================================================
# Brittany: Roscoff, a ferry from Plymouth
# =====================================================================================================================
def roscoff(OUT):
    zid, F = "roscoff", FLOOR_BRITTANY
    WX = {"clear": 26, "drizzle": 26, "sunshine": 16, "fog": 10, "gale": 12, "downpour": 10}
    z = base(zid, "Roscoff", "abroad_brittany", "town_kernow", WX, "coast", F, grass="#5e8e48")
    z.legend[":"] = {"tile": "cobbles", "colour": "#8a8a84"}
    z.legend["n"] = {"tile": "tall_grass", "colour": "#4e7e3c"}
    z.legend["v"] = {"tile": "sand", "colour": "#7a6a4a"}    # wet sand and wrack at low tide
    W, H = 60, 44
    z.border("H", 2)
    # the sea and the old harbour to the north, the Île de Batz offshore, the ferry port to the east
    z.rect(0, 0, W, 10, "$"); z.rect(0, 10, W, 1, "w"); z.rect(2, 11, W - 4, 2, "s")
    blob(z, 12, 4, 7, 2, "s", only="$", seed=51); blob(z, 12, 4, 5, 1, "k", only="s", seed=52)
    z.rect(48, 6, 3, 5, ":"); z.building(46, 8, 2, 2, "pier", "Port de Bloscon", show_label=False)
    blob(z, 30, 12, 8, 1, "v", only="s", seed=53, jitter=0.4)
    for (bx, by) in [(24, 7), (34, 8), (40, 6)]:
        z.prop("boat", bx, by, variant=0)
    z.prop("lighthouse", 12, 4)
    # rue Gambetta and the quay
    z.rect(2, 13, W - 4, 1, ":")
    z.rect(2, 19, W - 4, 2, "="); z.rect(2, 18, W - 4, 1, ":"); z.rect(2, 26, W - 4, 1, ":")
    z.rect(29, 14, 2, 5, ":")
    r_church = door(z, 4, 13, 9, "pennine_church", "Notre-Dame de Kroaz Batz", "roscoff_church", bh=5)
    ret_s, ret_h = town_buildings(z, zid, (15, 14, "sanctuary"), (22, 14, "shop"))
    z.building(32, 14, 6, 4, "breton_granite", "Roscoff")
    z.building(39, 14, 6, 4, "breton_granite", "Roscoff")
    z.building(52, 14, 5, 4, "breton_granite", "Roscoff")
    r_johnnies = door(z, 4, 22, 8, "breton_granite", "Maison des Johnnies", "roscoff_johnnies")
    r_creperie = door(z, 14, 22, 7, "breton_granite", "Crêperie", "roscoff_creperie")
    z.building(23, 22, 5, 4, "breton_white", "Roscoff")
    z.building(33, 22, 6, 4, "breton_granite", "Roscoff")
    z.building(40, 22, 6, 4, "breton_white", "Roscoff")
    z.building(47, 22, 9, 4, "breton_granite", "Station Biologique")
    # the onion fields and the coast path to the south
    z.rect(2, 28, W - 4, 13, "k")
    for y in range(29, 40, 2):
        z.rect(5, y, 22, 1, "n")
    blob(z, 44, 34, 10, 4, "n", only="k", seed=54, jitter=0.5)
    scatter_props(z, "bush", 33, 29, 22, 11, 10, 55, avoid=("k",))
    z.rect(29, 27, 2, 14, "#")
    for (lx, ly) in [(3, 18), (14, 18), (31, 18), (46, 18), (13, 26), (32, 26), (46, 26)]:
        z.prop("lamp_post", lx, ly)
    z.prop("bench", 26, 13); z.prop("bench", 36, 13); z.prop("bollard", 20, 12); z.prop("bollard", 40, 12)
    z.prop("lobster_pots", 44, 12); z.prop("market_stall", 33, 26)
    z.d["spawn"] = [30, 20]
    z.d["ferry"] = {"x": 49, "y": 11, "route": "plymouth_roscoff"}
    P = "abroad_roscoff_"
    plaque(z, 27, 18, P + "breizh", "Breizh",
           "Brittany, Breizh in Breton, is named after the Britons. Between about the 4th and the 7th centuries, people from south-west Britain, from Cornwall, Devon and Wales, crossed the sea and settled here, bringing their language. Bretagne and Great Britain share a name for a reason.")
    plaque(z, 25, 26, P + "brezhoneg", "Brezhoneg",
           "Breton, Brezhoneg, is a Brythonic Celtic language: its closest relative is Cornish, and then Welsh. Count to five: unan, daou, tri, pevar, pemp. In Welsh: un, dau, tri, pedwar, pump. About two hundred thousand people speak it, most of them older, and UNESCO counts it as endangered.")
    plaque(z, 6, 26, P + "johnnies", "The Onion Johnnies",
           "From 1828, men from Roscoff crossed to Britain each summer to sell the town's pink onions door to door, strung on poles and later hung from bicycles. The British called them Onion Johnnies. In the 1920s and 1930s there were well over a thousand of them.")
    plaque(z, 50, 12, P + "ferries", "Brittany Ferries",
           "In the early 1970s Breton farmers led by Alexis Gourvennec wanted a quicker way to get their cauliflowers and artichokes to British shops, so they started their own ferry company. The first sailing, from Roscoff to Plymouth in January 1973, carried lorries of vegetables.")
    plaque(z, 6, 18, P + "mary", "Mary, Queen of Scots",
           "In August 1548 a five-year-old girl stepped ashore at Roscoff: Mary, Queen of Scots, sent to France to be raised at the French court and, one day, marry the Dauphin. Nearly two hundred years later, in 1746, Bonnie Prince Charlie landed here too, after his escape from Scotland following Culloden.")
    plaque(z, 13, 18, P + "kroaz_batz", "The Stone Ships",
           "The belfry of Notre-Dame de Kroaz Batz, built in the 16th century, is carved with stone ships and cannons, paid for by Roscoff's merchants and privateers. A town that lived off the sea put it on its church.")
    plaque(z, 30, 12, P + "goemon", "Gwemon",
           "The Breton coast is one of Europe's great seaweed shores. For centuries goémoniers, seaweed gatherers, raked it from the rocks to fertilise the fields. Today it goes into food, cosmetics and medicine, and the Station Biologique, founded in 1872, studies everything that lives in it.")
    plaque(z, 47, 26, P + "gwenn_ha_du", "Gwenn ha Du",
           "The Breton flag, Gwenn ha Du, white and black, was designed in 1923 by Morvan Marchal. Its five black stripes stand for the old dioceses of Upper Brittany, where French and Gallo were spoken, and its four white stripes for those of Lower Brittany, where Breton was. The corner is ermine.")
    plaque(z, 40, 26, P + "diwan", "Diwan",
           "Since 1977 Diwan schools have taught children through Breton, from nursery up. Diwan means seed, or sprouting. The first school started with a handful of pupils; today thousands go, and they learn French, English and maths in Breton too.")
    chat(z, "ros_johnny", "villager_3", 10, 26, "Old Johnny",
         ["Demat! Hello! My grandfather sold onions in Swansea and Cardiff every summer of his working life. He spoke Breton, French and enough Welsh to sell onions to a chapel. Onions are a universal language.",
          "Kenavo means goodbye. He'd say it at every door, and the Welsh ladies would say hwyl fawr, and they understood each other perfectly."], "down")
    chat(z, "ros_teacher", "gown_student", 38, 26, "Diwan Teacher",
         ["I teach at the Diwan school. Here is a game for you: ti is house, like tŷ in Welsh. Penn is head, like pen. Aber is a river mouth, as in Aberystwyth. Kêr is a village, like caer. You know more Breton than you think.",
          "Trugarez, thank you. Say it to the crêpe lady and she'll add extra butter."], "down")
    chat(z, "ros_fisher", "fisherman_north", 36, 12, "Seaweed Gatherer",
         ["Goémon, we call it, gwemon in Breton. My family raked it off the rocks for the fields for generations. Now I sell it to a laboratory and a sushi bar. My grandmother would not believe the price."], "down")
    chat(z, "ros_dancer", "festival_goer", 44, 18, "Fest-Noz Dancer",
         ["Fest-noz tonight! A night festival: everyone in a line or a ring, holding little fingers, dancing for hours to singers and a bombard and a biniou. In 2012 UNESCO put it on its list of the world's living heritage."], "down")
    chat(z, "ros_farmer", "farmer", 20, 30, "Onion Grower",
         ["The pink onion of Roscoff. Sweet, keeps all winter, lovely in a tart. The sea air does it, and the seaweed in the soil."], "down")
    creature_npc(z, "ros_vraic", "vraicling", 32, 12, "A heap of wet seaweed rearranges itself on the slipway and looks pleased about something, possibly the tide.")
    _stand(z, 48, 12)
    z.npc(id="ros_ferry", sprite="sailor", x=48, y=12, facing="down", move="still", script="ros_ferry", name="Ferry Hand")
    script(zid, "ros_ferry", say("Ferry Hand", "The ferry for Plymouth! About six hours, if the Channel is in a good mood. Kenavo, Breizh.") + [{"do": "ferry", "route": "plymouth_roscoff"}])
    wild_at(z, F, [("vraicling", 10, {}), ("pixling", 8, {"time": ["dusk", "night"]}), ("flyling", 8, {"weather": ["drizzle", "fog"]}), ("leveret", 10, {}),
                   ("spikkin", 10, {"time": ["dusk", "night"]}), ("kitelet", 8, {}), ("ankou", 2, {"time": ["night"], "weather": ["fog"]}), ("starlet", 10, {}),
                   ("scuttlet", 10, {})])
    wild_at(z, F, [("gannetling", 10, {}), ("pupplash", 8, {}), ("greyhaul", 6, {}), ("pinchkin", 10, {}), ("chipgull", 10, {}), ("vraicling", 8, {}), ("ternlet", 8, {})], "water")
    trainer(z, "ros_bombard", "Piper Yann", "Sonneur", "piper",
            [("tootlet", 42), ("bombardon", 44), ("swiftlet", 43), ("starlet", 43)], 34, 18, "down",
            ["I play the bombard, my friend plays the biniou, a little bagpipe. In Brittany pipers come in pairs, like gendarmes. Ready?"],
            "Yec'hed mat! Good health to you, and to your team.",
            "Breton sonneurs often play in pairs, a bombard (a loud double-reed pipe) answering a biniou (a small bagpipe), call and response.", 1800)
    trainer(z, "ros_crepe", "Crêpe Maker Soazig", "Crêpière", "jam_maker",
            [("cuppeen", 42), ("jamlet", 43), ("mustling", 43), ("gloucelet", 43)], 19, 26, "down",
            ["A galette is buckwheat, savoury. A crêpe is wheat, sweet. Confuse them and we battle. You've confused them. We battle."],
            "Bon. You may have a crêpe.",
            "Buckwheat, blé noir, grows well in Brittany's poor, acid soils, which is why the savoury galette became a Breton staple.", 1800)
    trainer(z, "ros_biologist", "Dr Le Gall", "Marine Biologist", "astronomer",
            [("vraicling", 43), ("pinchkin", 42), ("glimmerjaw", 44), ("clawcastle", 43)], 51, 26, "down",
            ["The Station Biologique has studied this shore since 1872. I study what lives under the seaweed. Mostly it's annoyed with me."],
            "Fascinant. I'll write you up.",
            "The rocky shore at Roscoff has a huge tidal range and very rich marine life, which is why scientists set up a laboratory here in the 19th century.", 1800)
    trainer(z, "ros_legend", "Gwenola the Storyteller", "Kanerez (Singer)", "keeper_morwen",
            [("ankou", 45), ("pixiedell", 44), ("selkie", 44), ("lanternis", 44), ("merrow", 44), ("flintwarden", 44)], 30, 26, "down",
            ["I sing gwerz, the old Breton ballads, and I tell the tales: the drowned city of Ys, the korrigans, and the Ankou with his creaking cart. Shall I tell you one? First, the custom."],
            "Mat-tre! Very good. Sit, and I'll tell you about the Ankou.",
            "In Breton folklore the Ankou is death's servant: the last person to die in a parish each year becomes the Ankou for the next, and drives a creaking cart to collect the souls.", 3000)
    legend_trainer(z, "ros_legend", "ros_legend_talk", "Gwenola the Storyteller")
    scaled_at(["ros_bombard", "ros_crepe", "ros_biologist", "ros_legend"], F)
    finish_zone(z)
    z.save(OUT + "/" + zid + ".json")
    interior(OUT, "roscoff_johnnies", "Maison des Johnnies", zid, r_johnnies, "museum",
             [npc("ros_curator", "tour_guide", 6, 2, "ros_curator", name="Museum Guide")],
             signs=[(2, 3, "A bicycle, a pole hung with strings of pink onions, and a postcard from Swansea, 1931: 'Weather wet, sales good, home soon.'")])
    script("roscoff_johnnies", "ros_curator", say("Museum Guide",
           "The first Johnny was Henri Ollivier, in 1828. He filled a boat with onions, crossed to England and sold the lot. Soon whole crews went each July and came home by Christmas, sleeping in barns and lofts all over Britain.",
           "In Wales they called them Sioni Winwns: Johnny Onions. The trade shrank after the war, but a few Johnnies still cross the Channel each year."))
    interior(OUT, "roscoff_creperie", "Crêperie", zid, r_creperie, "cafe",
             [npc("ros_crepiere", "shopkeeper", 3, 1, "ros_crepiere", name="Crêpière")],
             props=[("menu_board", 9, 1, {})])
    script("roscoff_creperie", "ros_crepiere", say("Crêpière",
           "Galette complète: buckwheat, ham, cheese and an egg. Then a crêpe with salted butter caramel, and a bowl of cider. In Brittany cider comes in a bowl. Don't ask why. It's better that way.",
           "And kouign-amann, from Douarnenez: bread dough, butter and sugar, folded over and over. Kouign is cake, amann is butter. It is exactly what it says."))
    interior(OUT, "roscoff_church", "Notre-Dame de Kroaz Batz", zid, r_church, "church",
             [npc("ros_sacristan", "pilgrim", 6, 2, "ros_sacristan", name="Sacristan")])
    script("roscoff_church", "ros_sacristan", say("Sacristan",
           "Brittany has a saint for everything, and most of them came from Wales, Cornwall and Ireland: Samson, Malo, Brieuc, Pol Aurélien, who gave his name to Saint-Pol-de-Léon next door. The saints sailed over with the Britons.",
           "Every summer the parishes hold their pardons: a procession with banners and the saint's statue, Mass, and then a fair. Repentance first, crêpes after."))
    sanctuary_and_shop(OUT, zid, "Roscoff", ret_s, ret_h,
        ["Demat! Bonjour! Welcome to the Sanctuary. We speak French, Breton and fluent seagull.",
         "Lay them down. Un petit moment.",
         "Voilà. Good as new.",
         "The Ark is by the window, with a view of the Île de Batz.",
         "Kenavo! Goodbye!"],
        ("Bonjour! In euros, s'il vous plaît. Onions, kouign-amann, cider. Everything a Breton needs.", "Trugarez! Thank you!"),
        ["cup_of_tea", "flask_of_tea", "smelling_salts", "wicker_snare", "iron_snare", "water_snare", "night_snare",
         "roscoff_onions", "kouign_amann", "breton_cider"])


def roscoff_quest():
    zid, qid = "roscoff", "roscoff_johnny"
    q = Q + qid
    hint = say("Gwenola the Storyteller", "Before the tale, the words. Learn demat and kenavo from the Old Johnny by the museum, and trugarez from the Diwan teacher. Then take a string of onions over to Plymouth, as the Johnnies did, and give it to someone who'll appreciate it.")
    fight = say("Gwenola the Storyteller", "You've said demat and kenavo, and you've carried onions to Plymouth like a true Johnny. Now, the custom before a tale.") + [battle("ros_legend")] + \
        say("Gwenola the Storyteller", "Trugarez! Here is a triskell pin, the Breton three spirals, and a kouign-amann for the road. Now sit down. Once upon a time, there was a cart that creaked...") + \
        [give("triskell_pin"), give("kouign_amann", 2)] + stand_abroad(3) + [setf(q + "_done")]
    DLG[zid]["ros_legend_talk"] = [cmd_if(q + "_done",
        say("Gwenola the Storyteller", "Come back on a foggy night and I'll tell you about the drowned city of Ys. If you hear bells under the sea, don't go looking."),
        [cmd_if(q + "_started", chain([q + "_1", q + "_2", q + "_3"], fight, hint),
                say("Gwenola the Storyteller", "Demat! A visitor from over the water. The old Johnnies would've sold you an onion by now. Want a tale? Learn three Breton words first, and do a Johnny's job: carry a string of onions to Plymouth.") +
                [setf(q + "_started"), give("onion_string")])])]
    add_step(zid, "ros_johnny", qid, "1")
    add_step(zid, "ros_teacher", qid, "2")
    return {"id": "abroad_roscoff_johnny", "title": "Onion Johnny", "region": "abroad_brittany", "town": zid, "giver": "Gwenola the Storyteller",
            "summary": "Learn three Breton words and carry a string of Roscoff onions to Plymouth, as the Johnnies did.",
            "start_flag": q + "_started",
            "steps": [{"flag": q + "_1", "text": "Learn demat and kenavo from the Old Johnny by the Maison des Johnnies.", "zone": zid},
                      {"flag": q + "_2", "text": "Learn trugarez from the Diwan teacher.", "zone": zid},
                      {"flag": q + "_3", "text": "Take the onion string on the ferry to Plymouth and give it to the Millbay ferry hand, then return to Gwenola.", "zone": "plymouth"}],
            "done_flag": q + "_done", "reward": "A triskell pin (a Fae charm), kouign-amann and standing with Kin Abroad."}


def plymouth_hand(OUT):
    """The Millbay ferry hand in Plymouth: Brittany after badge_storm, and the end of the onion run. Additive edit."""
    p = OUT + "/plymouth.json"
    d = json.load(open(p))
    d["ferry"] = {"x": 5, "y": 32, "route": "plymouth_roscoff"}
    d["npcs"] = [n for n in d["npcs"] if n["id"] != "ply_brittany_ferry"]
    d["npcs"].append({"id": "ply_brittany_ferry", "sprite": "sailor", "x": 6, "y": 31, "facing": "left", "move": "still",
                      "script": "ply_brittany_ferry", "name": "Millbay Ferry Hand"})
    d["signs"] = [s for s in d["signs"] if s.get("plaque") != "abroad_plymouth_millbay"]
    d["signs"].append({"x": 5, "y": 33, "plaque": "abroad_plymouth_millbay", "title": "Millbay",
                       "text": "MILLBAY. Ferries to Roscoff, Brittany. Plymouth has had a ferry to Roscoff since January 1973, when Brittany Ferries' first sailing brought lorries of Breton cauliflowers. The Onion Johnnies used the same crossing long before, in sailing boats."})
    json.dump(d, open(p, "w"), indent=1, ensure_ascii=False)
    q = Q + "roscoff_johnny"
    deliver = cmd_if(q + "_started", [cmd_if(q + "_3", [], [
        {"do": "say", "who": "Millbay Ferry Hand", "text": "Is that a string of Roscoff onions? For me? My nan used to buy these off a Johnny on a bike every summer. Pink, sweet, lovely in a pasty. Thank you!"},
        setf(q + "_3")])])
    sail = [{"do": "say", "who": "Millbay Ferry Hand", "text": "The Roscoff boat. About six hours across the Channel to Brittany: Breizh, where they speak a cousin of Cornish and Welsh."},
            {"do": "ferry", "route": "plymouth_roscoff"}]
    gate = [{"do": "say", "who": "Millbay Ferry Hand", "text": "The Roscoff boat's not taking foot passengers with creatures till you've a few more badges, I'm afraid. Insurance. Come back when you've got the Storm badge."}]
    path = ROOT + "/data/dialogue/plymouth.json"
    dd = json.load(open(path))
    dd["ply_brittany_ferry"] = [deliver, cmd_if(GATE_BRITTANY, sail, gate)]
    json.dump(dd, open(path, "w"), indent=1, ensure_ascii=False)


def ferry_route():
    p = ROOT + "/data/ferries.json"
    txt = open(p).read()
    if '"plymouth_roscoff"' in txt:
        return
    entry = json.dumps({"a": "plymouth", "b": "roscoff", "ship": "the Roscoff ferry",
                        "card": "Six hours south across the Channel, past the Eddystone light and out of sight of land. Then granite islands, a lighthouse, and a little town of grey stone and slate. Demat, Breizh."}, ensure_ascii=False)
    body = txt.rstrip()
    assert body.endswith("}")
    open(p, "w").write(body[:-1].rstrip() + ',\n "plymouth_roscoff": ' + entry + "\n}\n")


# =====================================================================================================================
# items, creatures, quests, registry, quiz
# =====================================================================================================================
def items():
    return [
        heal_item("torta_negra", "Torta Negra", 420, 160, "Black cake: the dark, rich fruit cake of the Welsh in Patagonia, made to keep through a winter and a long journey. Teisen ddu, the old recipe says. Restores 160 HP."),
        heal_item("patagonia_lamb", "Cordero Patagónico", 560, 200, "Patagonian lamb, slow roasted over an open fire on an iron cross, the way the gauchos do it. It takes all afternoon. Restores 200 HP."),
        key_item("mate_gourd", "Mate Gourd", "A hollowed gourd and a metal straw, the bombilla, for mate, the bitter herb tea Argentines pass round a circle. Welsh Patagonians drink it in the morning and tea in the afternoon."),
        charm_item("gaiman_shawl", "Gaiman Shawl", "A woollen shawl woven in the Chubut valley, warm enough for a wind that has come all the way from the Andes.",
                   "Gale moves hurt it 25% less.", {"effect": "resist", "type": "gale", "mult": 0.75}, "{name} held fast in the Gaiman Shawl!"),
        heal_item("maple_syrup", "Maple Syrup", 300, 120, "A tin of Canadian maple syrup, tapped from sugar maples in spring and boiled down: about forty litres of sap for one of syrup. Restores 120 HP."),
        heal_item("oatcakes_cb", "Cape Breton Oatcakes", 240, 100, "Thick, crumbly oatcakes, a little sweeter than the Scottish kind, from a recipe that came over with the Gaels. Restores 100 HP."),
        heal_item("lobster_roll", "Lobster Roll", 520, 190, "Fresh lobster in a buttered bun, a summer treat all along the coast of Atlantic Canada. Restores 190 HP."),
        charm_item("milled_tweed", "Milled Tweed", "A length of tweed thickened at a milling frolic, thumped on a table to the beat of Gaelic songs. Warm as a ceilidh.",
                   "Frost moves hurt it 25% less.", {"effect": "resist", "type": "frost", "mult": 0.75}, "{name} was kept warm by the Milled Tweed!"),
        heal_item("clam_chowder", "Clam Chowder", 420, 160, "New England clam chowder: clams, potatoes, onion and cream, thick enough to stand a spoon in. Boston says Manhattan's red version isn't chowder. Restores 160 HP."),
        heal_item("boston_soda_bread", "Irish Soda Bread", 240, 100, "Soda bread from a Boston bakery, made the way Irish grandmothers made it, with buttermilk and a cross cut on top. Restores 100 HP."),
        heal_item("boston_cream_pie", "Boston Cream Pie", 360, 140, "Which is a cake, not a pie: sponge, custard and chocolate on top. Massachusetts made it the state dessert in 1996. Restores 140 HP."),
        charm_item("emigrant_claddagh", "Emigrant's Claddagh", "A claddagh ring, two hands holding a crowned heart, carried from Ireland by an emigrant and handed down. Love, loyalty and friendship.",
                   "Spirit moves hurt it 25% less.", {"effect": "resist", "type": "spirit", "mult": 0.75}, "{name} was steadied by the Emigrant's Claddagh!"),
        heal_item("biscuits_gravy", "Biscuits and Gravy", 360, 140, "Southern biscuits, which are soft scone-like rolls, under a thick white sausage gravy. Breakfast in the mountains. Restores 140 HP."),
        heal_item("cornbread", "Cornbread", 240, 100, "A wedge of cornbread from a cast-iron skillet. Maize was a Native American crop that every settler family learnt to grow. Restores 100 HP."),
        heal_item("sweet_tea", "Sweet Tea", 200, 80, "Iced tea with a great deal of sugar in it, the house drink of the American South. A British visitor's soul leaves their body. Restores 80 HP."),
        charm_item("dulcimer_pick", "Dulcimer Pick", "A goose-quill pick for a mountain dulcimer, the zither the Appalachian settlers made for themselves.",
                   "Storm moves hurt it 25% less.", {"effect": "resist", "type": "storm", "mult": 0.75}, "{name} kept time with the Dulcimer Pick!"),
        heal_item("roscoff_onions", "Roscoff Onions", 260, 100, "Pink onions from Roscoff, sweet and long-keeping, the ones the Onion Johnnies sold door to door in Britain. Roasted, they restore 100 HP."),
        heal_item("kouign_amann", "Kouign-Amann", 380, 150, "Butter cake from Douarnenez: bread dough folded with butter and sugar until it caramelises. Kouign is cake and amann is butter. Restores 150 HP."),
        heal_item("breton_cider", "Breton Cider", 300, 120, "Dry Breton cider, served in a bowl. Yec'hed mat: good health. Restores 120 HP."),
        key_item("onion_string", "String of Onions", "A string of pink Roscoff onions, plaited by the stalks, the way the Onion Johnnies carried them to Britain. For somebody in Plymouth."),
        charm_item("triskell_pin", "Triskell Pin", "A pin with the triskell, three spirals joined in the middle, an old Celtic pattern that Bretons wear as a sign of Brittany.",
                   "Fae moves hurt it 25% less.", {"effect": "resist", "type": "fae", "mult": 0.75}, "{name} was guarded by the Triskell Pin!"),
        key_item("parish_passport", "Well-Stamped Passport", "Your passport, stamped in Trelew, Sydney (Nova Scotia), Boston, Tri-Cities and Roscoff, and signed in the back by a bard, an archdruid, a councillor, a fiddler and a storyteller. The kin of these isles abroad count you as one of their own."),
    ]


def creatures():
    def sp(id, name, types, base, catch, xp, learn, evo, habitat, text, fact, **kw):
        d = {"id": id, "name": name, "types": types, "base": dict(zip(["hp", "atk", "def", "lore", "ward", "spd"], base)),
             "growth": "medium", "catch_rate": catch, "base_xp": xp, "learnset": learn, "evolves": evo,
             "habitat": habitat, "appendix": True, "dex": {"text": text, "fact": fact}, "sprite": id}
        d.update(kw)
        return d
    lines = {
        "choiquet": [
            sp("choiquet", "Choiquet", ["brawn", "gale"], [50, 60, 45, 35, 40, 70], 160, 64,
               [[1, "shove"], [1, "gust_nudge"], [5, "glower"], [9, "fell_run"], [14, "scrum_push"], [19, "updraught"], [25, "kestrel_dive"]],
               {"to": "choique", "level": 32}, ["gaiman"],
               "A long-legged chick that zigzags across the steppe at a speed its legs did not warn you about.",
               "Darwin's rhea, called choique in Patagonia, is a big flightless bird that can run at over 50 kilometres an hour, swerving to throw off a chase."),
            sp("choique", "Choique", ["brawn", "gale"], [85, 98, 70, 55, 65, 112], 60, 170,
               [[1, "shove"], [1, "gust_nudge"], [5, "glower"], [9, "fell_run"], [14, "scrum_push"], [19, "updraught"], [25, "kestrel_dive"], [32, "pit_pony_charge"], [38, "swoop"], [44, "haymaker"]],
               None, ["gaiman"],
               "Runs the steppe as if it owns it, which, frankly, it did first. The father raises the chicks and will chase you off for looking.",
               "In rheas the male builds the nest, sits on eggs laid by several females and raises the chicks alone. Charles Darwin found the smaller species in Patagonia in 1833."),
        ],
        "mooslet": [
            sp("mooslet", "Mooslet", ["kin", "frost"], [62, 58, 52, 36, 44, 38], 150, 66,
               [[1, "scrap"], [1, "cold_snap"], [5, "glare"], [10, "barge"], [15, "frostbite_snap"], [21, "sleet_shower"], [27, "hunker"]],
               {"to": "bullmoose", "level": 34}, ["baddeck"],
               "Gangly, solemn and taller than you already. Wades into the lake for weed and thinks very slowly about everything.",
               "Moose were reintroduced to the Cape Breton Highlands in 1947 and 1948, with animals brought from Alberta, after the old herd had died out."),
            sp("bullmoose", "Bullmoose", ["kin", "frost"], [108, 102, 86, 55, 70, 62], 50, 182,
               [[1, "scrap"], [1, "cold_snap"], [5, "glare"], [10, "barge"], [15, "frostbite_snap"], [21, "sleet_shower"], [27, "hunker"], [34, "reindeer_charge"], [40, "black_ice_skid"], [46, "whiteout"]],
               None, ["baddeck"],
               "Antlers like a pair of hall tables, and the right of way on every road in Cape Breton. Locals brake for it and so should you.",
               "A bull moose grows a new set of antlers every year and sheds them in winter. Moose are the largest deer in the world and swim well."),
        ],
        "hellbendlet": [
            sp("hellbendlet", "Hellbendlet", ["bog", "brook"], [55, 48, 58, 44, 50, 30], 150, 62,
               [[1, "squelch"], [1, "rill_shot"], [6, "murky_gaze"], [11, "leech_latch"], [16, "eddy_ripple"], [22, "mire_stomp"], [28, "spate_surge"]],
               {"to": "hellbender", "level": 33}, ["bristol_tn"],
               "A flat, wrinkly, unbothered thing under a rock in the creek. Breathes through its skin and judges you through its very small eyes.",
               "The eastern hellbender is North America's biggest salamander. It breathes mostly through the folds of its skin, so it needs clean, cold, fast-flowing water."),
            sp("hellbender", "Hellbender", ["bog", "brook"], [100, 82, 98, 70, 88, 42], 55, 176,
               [[1, "squelch"], [1, "rill_shot"], [6, "murky_gaze"], [11, "leech_latch"], [16, "eddy_ripple"], [22, "mire_stomp"], [28, "spate_surge"], [33, "bog_drag"], [39, "undertow"], [45, "sphagnum_sponge"]],
               None, ["bristol_tn"],
               "Two feet of wrinkles and patience. Local names include snot otter and devil dog, and it has heard all of them.",
               "Hellbenders can live for decades. They have declined where streams are dammed, silted or polluted, so a healthy population is a sign of a healthy river."),
        ],
        "ankou": [
            sp("ankou", "Ankou", ["spirit", "night"], [75, 95, 75, 100, 80, 70], 25, 200,
               [[1, "whisper"], [1, "shadow_nip"], [8, "chain_rattle"], [15, "out_of_the_murk"], [22, "passing_bell"], [30, "dark_of_the_moon"], [38, "washer_at_the_ford"], [46, "wild_hunt"]],
               None, ["roscoff"],
               "A tall figure in a wide hat, with a scythe and a cart whose axle creaks. If you hear the creak at night, it is polite not to look round.",
               "In Breton folklore the Ankou is death's servant. The last person to die in a parish in the year becomes the Ankou for the next, and he drives a creaking cart to collect the dead. He is carved on many Breton churches and ossuaries."),
        ],
    }
    return lines


def write_creatures():
    import os
    moves = set()
    for f in os.listdir(ROOT + "/data/moves"):
        if f.endswith(".json"):
            d = json.load(open(ROOT + "/data/moves/" + f))
            for m in (d if isinstance(d, list) else d.get("moves", [d])):
                moves.add(m["id"])
    for line, species in creatures().items():
        if True:
            for s in species:
                for (_, m) in s["learnset"]:
                    assert m in moves, (s["id"], m)
        sa_write_json("data/creatures/%s.json" % line, {"line": line, "species": species})
    p = ROOT + "/data/dex_order.json"
    txt = open(p).read()
    ids = [s["id"] for sp in creatures().values() for s in sp]
    add = [i for i in ids if '"%s"' % i not in txt]
    if add:
        body = txt.rstrip()
        assert body.endswith("]")
        open(p, "w").write(body[:-1].rstrip() + ", " + ", ".join('"%s"' % i for i in add) + "]\n")


def registry():
    write_registry("patagonia", "Y Wladfa (Patagonia)", "gaiman", 56, 21, "raf",
                   "The Welsh in Patagonia since 1865: chapels, tea houses and Welsh spoken in Gaiman. Airliners via Buenos Aires.",
                   "The RAF doesn't fly to Argentina, so the movements officer books you onto airliners: London to Buenos Aires overnight, then a small plane south to Trelew. A remis runs you up the valley past poplars and brick chapels. Croeso i'r Wladfa. Bienvenidos.")
    write_registry("cape_breton", "Cape Breton (Nova Scotia)", "baddeck", 57, 21, "raf",
                   "New Scotland: Gaelic, fiddles and the Bras d'Or Lake, where the Highlanders went after the Clearances.",
                   "Overnight to Halifax, a little plane to Sydney and an hour's drive round the Bras d'Or Lake. Spruce, shingle houses, a white church and a sign in English and Gaelic: Ceud mìle fàilte.")
    write_registry("boston", "Boston (Massachusetts)", "boston", 46, 21, "raf",
                   "Where the Famine ships came in. Irish Boston, from Black '47 to City Hall.",
                   "Seven hours west, and Logan Airport. A cab takes you through the tunnel into a city of red brick, green paint and shamrocks on the bakery windows. Your great-great-grandparents took six weeks.")
    write_registry("appalachia", "Appalachia (Tennessee and Virginia)", "bristol_tn", 57, 21, "raf",
                   "The Ulster Scots in the mountains: fiddles, ballads and the Birthplace of Country Music.",
                   "Overnight to the States, a hop to the Tri-Cities and a drive into the Blue Ridge. Bristol: one street, two states, and somebody playing a fiddle on a porch.")
    write_registry("brittany", "Brittany (Roscoff)", "roscoff", 49, 12, "ferry",
                   "Breizh, Little Britain: Breton, a cousin of Welsh and Cornish, crêpes, and the Onion Johnnies. A ferry from Plymouth.",
                   "The ferry slides into Roscoff past granite islands and a lighthouse. A sign on the quay says Degemer mat: welcome, in Breton. The Welsh among you will find the shape of it oddly familiar.",
                   port="plymouth")
    # the Brittany ferry is open earlier than the flights: same gate as the Plymouth ferry hand
    p = ROOT + "/data/overseas/brittany.json"
    d = json.load(open(p)); d["unlock_flag"] = GATE_BRITTANY
    sa_write_json("data/overseas/brittany.json", d)


def lang_br():
    sa_write_json("data/lang/br.json", {
        "places": {"roscoff": "Rosko"},
        "greetings": ["Demat!", "Mont a ra?", "Degemer mat!"],
        "phrases": {"hello": "Demat", "how_are_you": "Mont a ra?", "welcome": "Degemer mat", "thanks": "Trugarez",
                    "goodbye": "Kenavo", "cheers": "Yec'hed mat", "good_night": "Noz vat", "brittany": "Breizh", "breton": "Brezhoneg"}})


def quiz():
    append_quiz("overseas", [
        ("history", "In which year did the Mimosa carry Welsh settlers to Patagonia?", "1865", ["1745", "1912", "1801"], "They landed at Puerto Madryn on 28 July 1865, still celebrated in Chubut as Landing Day."),
        ("geography", "Which Patagonian town is named after Lewis Jones, a leader of the Welsh colony?", "Trelew", ["Gaiman", "Rawson", "Trevelin"], "Tre means town in Welsh: Tre-Lew, Lewis's town."),
        ("history", "What does Nova Scotia mean?", "New Scotland", ["New Sea", "Northern Coast", "Scots' Island"], "The name comes from a royal charter of 1621."),
        ("history", "Which inventor, born in Edinburgh, spent his summers at Baddeck in Cape Breton?", "Alexander Graham Bell", ["James Watt", "John Logie Baird", "Charles Babbage"], "He died at Beinn Bhreagh, his estate across the bay, in 1922."),
        ("history", "What was the worst year of the Irish Famine, remembered as 'Black' what?", "'47", ["'45", "'52", "'49"], "1847: tens of thousands of Irish emigrants reached Boston that year alone."),
        ("history", "Who was the first immigrant processed at Ellis Island, on 1 January 1892?", "Annie Moore, from Cork", ["Mary Ryan, from Tipperary", "Bridget Kelly, from Mayo", "Ellen Walsh, from Kerry"], "There are statues of her at Ellis Island and at Cobh."),
        ("culture", "Which town on the Tennessee and Virginia border is the Birthplace of Country Music?", "Bristol", ["Nashville", "Memphis", "Asheville"], "Ralph Peer's 1927 recordings there included the Carter Family and Jimmie Rodgers."),
        ("history", "What were Ulster Presbyterian emigrants to 18th-century America usually called there?", "Scotch-Irish", ["Orangemen", "Lowlanders", "Ulstermen"], "Most landed at Philadelphia and moved south and west down the Great Wagon Road."),
        ("culture", "Which Celtic language is the closest relative of Cornish?", "Breton", ["Welsh", "Manx", "Irish"], "Breton came to Brittany with Britons from Cornwall, Devon and Wales between about the 4th and 7th centuries."),
        ("history", "What did the Onion Johnnies of Roscoff sell door to door in Britain?", "Pink onions", ["Garlic", "Cider", "Crêpes"], "The trade began in 1828 and at its height in the 1920s and 1930s involved well over a thousand men."),
    ])


def main(OUT):
    gaiman(OUT)
    baddeck(OUT)
    boston(OUT)
    bristol_tn(OUT)
    roscoff(OUT)
    quests = [gaiman_quest(), baddeck_quest(), boston_quest(), bristol_quest(), roscoff_quest()]
    for qd in quests:
        sa_write_json("data/quests/%s.json" % qd["id"], {"quests": [qd]})
    write_items("abroad", items())
    write_creatures()
    registry()
    lang_br()
    quiz()
    ferry_route()
    plymouth_hand(OUT)


if __name__ == "__main__":
    OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
    main(OUT)
    write_all(OUT)
    print("abroad: written")
