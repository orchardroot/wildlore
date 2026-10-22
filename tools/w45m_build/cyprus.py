from lib import *

WEATHER = {"clear": 40, "sunshine": 40, "fog": 2, "drizzle": 6, "gale": 6, "downpour": 6}
LEGEND = {'g': {'tile': 'grass', 'colour': '#cbb870'}, 'k': {'tile': 'tall_grass', 'colour': '#b8a256'},
          'c': {'tile': 'cobbles', 'colour': '#dcd0b4'}, 'a': {'tile': 'path', 'colour': '#e8dcbc'}}
CITY = {'g': {'tile': 'grass', 'colour': '#c8b98a'}, 'k': {'tile': 'tall_grass', 'colour': '#a5a060'},
        'c': {'tile': 'cobbles', 'colour': '#d8ccae'}, 'a': {'tile': 'path', 'colour': '#e6dcc0'}}
BASIC = ["cup_of_tea", "flask_of_tea", "buxton_water", "smelling_salts", "kendal_mint_cake", "wicker_snare", "iron_snare",
         "night_snare", "water_snare", "silver_snare", "lavender_sachet"]
Q = "q_overseas_cyprus_"
A = "q_overseas_cyprus_agrino_"
UN = "UN Peacekeeper"


def town_grass(lo_extra=None):
    return [enc("moggle", 14), enc("cooplet", 10), enc("swiftlet", 8), enc("chamelet", 3), enc("scuttlet", 8),
            enc("hootlet", 4, time=["night"]), enc("flittermouse", 5, time=["night"]), enc("kitelet", 4, time=["day"])]


def pyla():
    z = Zone("pyla", "Pyla", 56, 44, kind="route", region="overseas_cyprus", music="route_coast", stage="grass",
             weather=WEATHER, legend=LEGEND)
    z.rect(0, 0, 56, 2, 'P'); z.rect(0, 42, 56, 2, 'P'); z.rect(0, 0, 2, 44, 'P'); z.rect(54, 0, 2, 44, 'P')
    z.rect(3, 3, 22, 9, 'k'); z.rect(30, 3, 23, 9, 'k'); z.rect(3, 33, 22, 8, 'k'); z.rect(31, 33, 22, 8, 'k')
    z.rect(26, 0, 3, 44, '=')
    z.rect(14, 18, 29, 8, 'c')
    kaf = z.building(15, 13, 6, 5, "flat_house", "Kafeneio", door=3)
    kah = z.building(31, 13, 6, 5, "flat_house", "Kahvehane", door=3)
    z.building(44, 19, 3, 3, "un_tower", "UN Observation Post")
    for bx, by, bw, bh in [(8, 13, 5, 4), (39, 13, 5, 4), (14, 27, 6, 4), (33, 27, 6, 4), (46, 27, 5, 4), (6, 27, 5, 4)]:
        z.building(bx, by, bw, bh, "flat_house")
    for x, y in [(10, 32), (22, 31), (44, 32), (50, 24), (8, 22), (12, 24)]:
        z.put(x, y, 'T')
    z.prop("bench", 21, 19); z.prop("bench", 35, 19); z.prop("table", 18, 21); z.prop("table", 34, 21)
    z.spawn = (27, 40)
    z.sign(24, 19, "Pyla sits inside the UN buffer zone, on the edge of the Dhekelia Sovereign Base Area, and is one of very few places on the island where Greek Cypriots and Turkish Cypriots still live side by side, as many villages did before the 1960s. The UN keeps a post on the hill. The children mostly ignore it.",
           "cyprus_pyla", "Pyla")
    z.sign(25, 23, "On the square, two coffee houses stand a few steps apart, one Greek Cypriot and one Turkish Cypriot. The coffee is the same coffee: finely ground, boiled in a small long-handled pot and served with the grounds settling in the cup. What you call it depends on which door you went in.",
           "cyprus_pyla_coffee", "Two Coffee Houses")
    z.sign(43, 23, "UNFICYP, the United Nations Peacekeeping Force in Cyprus, arrived in 1964 after fighting between the island's two communities, and has stayed ever since: one of the oldest UN missions anywhere. Its soldiers and police come from many countries, Britain among them, and they patrol a buffer zone that runs right across the island.",
           "cyprus_unficyp", "Blue Berets")
    z.sign(25, 10, "The road north crosses the Mesaoria, whose name means 'between the mountains': the wide plain between the Troodos range in the south-west and the Kyrenia range in the north. It is Cyprus's breadbasket, wheat and barley gold in May and baked brown by August.",
           "cyprus_mesaoria", "The Mesaoria")
    z.sign(29, 3, "NICOSIA, north. DHEKELIA, south. Mind the tractors.")
    z.npc("pyl_un", "rail_guard", 42, 22, "left", script="pyl_un", name=UN)
    z.npc("pyl_choir", "choir_singer", 22, 22, "right", trainer="pyl_choir")
    z.npc("pyl_shepherd", "farmer", 12, 36, "right", trainer="pyl_shepherd")
    z.npc("pyl_farmer", "farmer", 40, 6, "down", trainer="pyl_farmer")
    z.npc("pyl_kids", "villager_6", 30, 24, "left", script="pyl_kids", name="Two Kids")
    z.encounters = {"grass": [enc("chamelet", 10), enc("duneskink", 12), enc("scuttlet", 10), enc("kitelet", 8, time=["dawn", "day"]),
                              enc("stoopfalcon", 6), enc("hootlet", 5, time=["night"]), enc("swiftlet", 8), enc("moggle", 6),
                              enc("flittermouse", 4, time=["night"]), enc("chameleer", 2)]}
    z.dialogue["pyl_un"] = [
        iff(Q + "done", [say(UN, "The cheese summit was a triumph. Two old men agreeing on something. I've put it in my report. My commander thinks it's a code.")], [
            iff(Q + "4", [
                say(UN, "You've been to both sides of Nicosia and back? And the verdict is... the same cheese with two names. Registered by the EU under both of them."),
                say(UN, "Andreas! Hüseyin! You heard that? You both win. No, you can't both have won more. Sit down."),
                say(UN, "They've sent you a basket from both kitchens. I'm told that's the first joint venture on this square since the pear tree."),
                setf(Q + "5"), setf(Q + "done"), give("halloumi", 3), give("loukoumades", 2), give("sheftali_kebab", 2), standing(10)],
                [iff(Q + "started", [say(UN, "Taste both, then take it to the experts in Nicosia: the halloumi seller on the south side and the hellim seller in the Büyük Han, on the north. Come back with a verdict. I'll be here. I'm always here.")],
                     [say(UN, "Afternoon. I'm with UNFICYP, the peacekeepers. Today's crisis is a cheese."),
                      say(UN, "Andreas in the kafeneio and Hüseyin in the kahvehane each say his is the best halloumi on the island. Or hellim. That's half the argument. They've asked the UN to rule on it."),
                      say(UN, "The UN does not do cheese. You, however, are a civilian with an appetite. Taste them both, then ask the experts in Nicosia, on both sides of the line."),
                      setf(Q + "started")])])])]
    z.dialogue["pyl_kids"] = [
        say("Two Kids", "He's Mehmet and I'm Giorgos. We go to different schools and play on the same square."),
        say("Two Kids", "He's teaching me Turkish swear words and I'm teaching him Greek ones. Our mums think we're doing homework."),
    ]
    trainer("pyl_choir", "Eleni and Ayşe", "Local Legends", "choir_singer",
            [("ravanne", 98), ("flamingale", 98), ("brineflame", 98), ("tesserite", 98), ("agrino", 98), ("chameleer", 98)],
            ["We sing in a choir with Greek Cypriots and Turkish Cypriots in it: songs in both languages, and a few that turn out to have the same tune.",
             "We've been friends since the crossings opened in 2003. Two voices, one team. Shall we?"],
            "Beautiful. You found the harmony.",
            "There's a love song both sides sing, with words in Greek on one side and Turkish on the other. Each side was sure it was theirs. We sing it in both, one verse each, and nobody argues.", money=9000)
    trainer("pyl_shepherd", "Goatherd", "Shepherd", "farmer", [("herdlet", 96), ("kidgruff", 96), ("billgruff", 97)],
            ["My goats give the milk for the halloumi. They also eat my hat. Battle?"],
            "My goats are laughing at me. I can hear them.",
            "Real halloumi is made from goat's and sheep's milk. Cow's milk gets in these days, but don't tell my goats.")
    trainer("pyl_farmer", "Barley Farmer", "Farmer", "farmer", [("scuttlet", 96), ("kitelet", 96), ("duneskink", 97), ("chamelet", 97)],
            ["The barley's in, the sun's out and I've got an hour before the next job. Come on, then."],
            "Good harvest, that. For you.",
            "The Mesaoria was the island's granary under the Romans, under the Venetians, and under my grandad. It's still dry as a biscuit in August.")

    k = interior(z, kaf, "pyla_kafeneio", "Kafeneio", counter=(2, 2, 4),
                 props=[{"type": "table", "x": 6, "y": 4}, {"type": "table", "x": 8, "y": 4}, {"type": "kitchen_dresser", "x": 8, "y": 1},
                        {"type": "wall_picture", "x": 6, "y": 1, "walk": True, "variant": 2}, {"type": "potted_plant", "x": 1, "y": 6}],
                 npcs=[npcd("pyl_andreas", "shopkeeper", 3, 1, script="pyl_andreas", name="Andreas"),
                       npcd("pyl_tavli", "villager_5", 7, 5, "up", script="pyl_tavli", name="Tavli Player")])
    k.dialogue["pyl_andreas"] = [
        iff(Q + "done", [say("Andreas", "The same cheese with two names. Fine. Fine! But mine squeaks louder. Kopiaste: come and join us, sit, eat.")], [
            iff(Q + "1", [say("Andreas", "You've had mine. Now go and have his, so you can tell him how much better mine is.")],
                [iff(Q + "started",
                     [say("Andreas", "Ah, the judge! Taste. Sheep's and goat's milk, warmed, curdled, the curds cooked in the hot whey and folded over with dried mint, like my mother did."),
                      say("Andreas", "Grill it, and it doesn't melt. It squeaks on your teeth. That's how you know it's honest."),
                      setf(Q + "1")],
                     [say("Andreas", "Kaliméra! Good morning. Coffee? A Cypriot coffee: you say 'métrios' for medium sweet, 'skétos' for none. The grounds stay in the cup. Don't drink those."),
                      say("Andreas", "Hüseyin across the square calls it Turkish coffee. It's the same pot, the same coffee, the same argument for fifty years.")])])])]
    k.dialogue["pyl_tavli"] = [say("Tavli Player", "Tavli, backgammon. Hüseyin's lot call it tavla. We play each other on Thursdays. Nobody has ever admitted to losing.")]
    h = interior(z, kah, "pyla_kahvehane", "Kahvehane", counter=(2, 2, 4),
                 props=[{"type": "table", "x": 6, "y": 4}, {"type": "table", "x": 8, "y": 4}, {"type": "kitchen_dresser", "x": 8, "y": 1},
                        {"type": "wall_picture", "x": 6, "y": 1, "walk": True, "variant": 1}, {"type": "potted_plant", "x": 9, "y": 6}],
                 npcs=[npcd("pyl_huseyin", "shopkeeper", 3, 1, script="pyl_huseyin", name="Hüseyin"),
                       npcd("pyl_cards", "villager_2", 7, 5, "up", script="pyl_cards", name="Card Player")])
    h.dialogue["pyl_huseyin"] = [
        iff(Q + "done", [say("Hüseyin", "Same cheese, two names. Andreas says his squeaks louder. Let him. Afiyet olsun: enjoy your meal.")], [
            iff(Q + "2", [say("Hüseyin", "You've tasted mine. Now you know. Go and tell the experts, and take your time, they'll agree with me.")],
                [iff(Q + "started",
                     [say("Hüseyin", "Hoş geldiniz, welcome, judge. Hellim: sheep and goat, a little mint, kept in salty whey in a jar, the way my grandmother did in her village near Paphos before we came north."),
                      say("Hüseyin", "Fry it in a pan with tomato and a bit of bread. Andreas puts his on the grill. He is wrong, but he is my neighbour."),
                      setf(Q + "2")],
                     [say("Hüseyin", "Merhaba! Hello. Turkish coffee? Say 'orta' for medium sweet, 'sade' for plain. Leave the grounds."),
                      say("Hüseyin", "Andreas over the square calls it Cypriot coffee. He's been wrong since 1975 and I've told him every morning.")])])])]
    h.dialogue["pyl_cards"] = [say("Card Player", "We play pişti here, a card game. Andreas's men play prefa. Different games, same complaint about the cards.")]
    return [z, k, h]


def nicosia_south():
    z = Zone("nicosia_south", "Nicosia (south)", 64, 52, kind="town", region="overseas_cyprus", music="town_city",
             stage="city", weather=WEATHER, legend=CITY)
    z.rect(0, 0, 64, 2, 'W'); z.rect(0, 0, 2, 52, 'W'); z.rect(62, 0, 2, 52, 'W'); z.rect(0, 50, 64, 2, 'W')
    z.rect(2, 2, 60, 2, 'F')
    z.rect(30, 0, 3, 39, 'a')                       # Ledra Street
    z.rect(2, 22, 60, 3, 'c')
    z.rect(14, 34, 37, 7, 'c')
    z.rect(26, 41, 3, 11, '=')
    z.rect(2, 48, 24, 2, 'k'); z.rect(29, 48, 33, 2, 'k'); z.rect(2, 41, 10, 3, 'k'); z.rect(52, 41, 10, 3, 'k')
    z.building(2, 44, 22, 4, "venetian_wall")
    z.building(30, 44, 6, 4, "venetian_gate", "Famagusta Gate")
    z.building(36, 44, 26, 4, "venetian_wall")
    z.building(33, 5, 3, 2, "checkpoint_booth", "Ledra Street Crossing")
    sanct = z.building(23, 9, 6, 4, "kioski_house", "Sanctuary", door=3)
    tav = z.building(23, 15, 6, 4, "kioski_house", "Taverna", door=3)
    per = z.building(34, 9, 6, 4, "kioski_house", "Periptero", door=2)
    mus = z.building(34, 15, 7, 4, "kioski_house", "Leventis Museum", door=3)
    church = z.building(19, 26, 9, 6, "orthodox_church", "Church", door=4)
    for bx, by, bw, bh in [(34, 26, 6, 5), (41, 26, 6, 5), (4, 9, 6, 4), (11, 9, 6, 4), (44, 9, 6, 4), (51, 9, 6, 4),
                           (4, 15, 6, 4), (11, 15, 6, 4), (44, 15, 6, 4), (51, 15, 6, 4), (4, 26, 6, 5), (11, 26, 6, 5), (51, 26, 6, 5)]:
        z.building(bx, by, bw, bh, "kioski_house")
    for x in [5, 6, 12, 19, 21, 40, 44, 51, 56]:
        z.prop("barrel", x, 4)
    z.prop("market_stall", 39, 36, variant=1); z.prop("market_stall", 41, 36, variant=2)
    for x, y in [(15, 35), (49, 35), (15, 40), (49, 40)]:
        z.prop("palm", x, y)
    for x in [8, 20, 40, 52]:
        z.prop("lamp_post", x, 21)
    z.prop("bench", 22, 38); z.prop("bench", 44, 38)
    z.spawn = (27, 49)
    z.sign(22, 42, "The Venetians built these walls in the 1560s, a great star with eleven bastions, to keep the Ottomans out. In 1570 the Ottoman army took the city anyway. The walls still ring the old town, about three miles round, and the dry moat is now car parks, gardens and a very good place for cats.",
           "cyprus_venetian_walls", "The Venetian Walls")
    z.sign(36, 43, "The Famagusta Gate was the main way into the walled city from the east, on the road to Famagusta. Its long vaulted passage through the rampart is now a cultural centre: concerts and exhibitions where the guards once checked the carts.",
           "cyprus_famagusta_gate", "Famagusta Gate")
    z.sign(29, 30, "Nicosia is Lefkosia in Greek and Lefkoşa in Turkish, and it is the capital of the Republic of Cyprus. A line has run through the middle of it since the 1960s, so it is often called the last divided capital in Europe. Walk to the top of Ledra Street and you'll see why.",
           "cyprus_nicosia", "One City, Three Names")
    z.sign(33, 20, "Britain took over the running of Cyprus from the Ottoman Empire in 1878, annexed it in 1914 and made it a Crown colony in 1925. From 1955 to 1959 EOKA, a Greek Cypriot movement for union with Greece (enosis), fought British rule, while Turkish Cypriot leaders called for partition (taksim). British, Greek Cypriot and Turkish Cypriot lives were lost. Cyprus became independent on 16 August 1960, and Britain kept two Sovereign Base Areas, about three per cent of the island.",
           "cyprus_british_rule", "British Cyprus, 1878 to 1960")
    z.sign(29, 4, "At Christmas 1963 fighting broke out between Greek Cypriots and Turkish Cypriots in Nicosia. To stop it, the story goes, a British officer drew a ceasefire line across a map of the city in green pencil. UN peacekeepers came in 1964. The pencil line became sandbags, then oil drums and walls, and it is still here.",
           "cyprus_green_line", "The Green Line")
    z.sign(33, 8, "In July 1974 a coup backed by the military government in Athens overthrew President Makarios, aiming at union with Greece. Five days later Turkey's army landed in the north. Greek Cypriots remember it as the invasion; many Turkish Cypriots remember it as an intervention that ended years of fear. By August the island was split. Tens of thousands of Greek Cypriots fled south and tens of thousands of Turkish Cypriots moved north, and thousands of people on both sides were killed or never found.",
           "cyprus_1974", "Summer 1974")
    z.sign(29, 7, "Ledra Street, the old city's main shopping street, runs straight up to the buffer zone and stopped dead there for decades. In April 2008 a crossing opened at the top, and now people walk through with a passport or ID card to shop, eat, visit family or just look. The first crossings on the island opened in 2003.",
           "cyprus_ledra", "Ledra Street")
    z.sign(38, 38, "Halloumi is a firm, salty cheese of sheep's and goat's milk (and, these days, often cow's), cooked in its own hot whey and folded with mint. It grills without melting and squeaks on the teeth. In 2021 the EU registered it as a protected product of Cyprus under both its names: halloumi in Greek, hellim in Turkish.",
           "cyprus_halloumi", "Halloumi")
    z.sign(24, 36, "Cyprus joined the European Union in 2004 and swapped the Cypriot pound for the euro in 2008. Your sterling won't buy a coffee here. Look at the small coins: the 1, 2 and 5 cent pieces carry the mouflon, the island's wild sheep.",
           "cyprus_euro", "The Euro and the Mouflon")
    z.sign(34, 7, "In April 2004 both communities voted on a UN plan to reunite the island, the Annan Plan. About two thirds of Turkish Cypriots voted yes and about three quarters of Greek Cypriots voted no, so it fell. A week later the whole island joined the EU, but EU law is on hold in the north until there's a settlement. Talks have come and gone ever since.",
           "cyprus_annan", "The 2004 Vote")
    z.sign(27, 43, "OLD NICOSIA. LEDRA STREET and the crossing, north. PYLA and DHEKELIA, south.")
    z.npc("ns_police", "rail_guard", 29, 5, "down", script="ns_police", name="Police Officer")
    z.npc("ns_cheese", "shopkeeper", 40, 37, "up", script="ns_cheese", name="Halloumi Seller")
    z.npc("ns_busker", "bard", 20, 37, "right", trainer="ns_busker")
    z.npc("ns_student", "student", 45, 23, "left", trainer="ns_student")
    z.npc("ns_yiayia", "villager_3", 16, 23, "down", script="ns_yiayia", name="Yiayia Androulla")
    z.npc("ns_bureau", "commuter", 37, 21, "down", script="ns_bureau", name="Bureau Clerk")
    z.dialogue["ns_police"] = [
        say("Police Officer", "Republic of Cyprus police. Crossing north? Passport or ID card, please. You'll show it again on the other side."),
        say("Police Officer", "From here it's a few steps through the buffer zone. The UN has the bit in the middle. Nobody has the pigeons."),
    ]
    z.dialogue["ns_cheese"] = [
        iff(Q + "3", [say("Halloumi Seller", "Go on, over the line. The hellim seller in the Büyük Han will tell you the same, only louder.")], [
            iff(Q + "2", [iff(Q + "1", [
                say("Halloumi Seller", "Andreas and Hüseyin? Still? They've been at this since before you were born."),
                say("Halloumi Seller", "Here's the truth. It's one cheese, made all over the island by both communities for centuries. In 2021 the EU protected it under two names at once: halloumi and hellim. One cheese, one register, two words."),
                say("Halloumi Seller", "But don't take it from me. Cross at the top of Ledra Street and ask in the Büyük Han. A verdict needs both sides, or it isn't one."),
                setf(Q + "3")], [say("Halloumi Seller", "Taste both first, love. A judge with one mouthful is just a customer.")])],
                [say("Halloumi Seller", "Halloumi! Fresh this morning. Grill it, fry it, eat it with watermelon in August, which sounds mad and isn't."),
                 {"do": "shop", "id": "nicosia_periptero"}])])]
    z.dialogue["ns_yiayia"] = [
        say("Yiayia Androulla", "I was born in Kyrenia, on the north coast. In August 1974 we left with what we could carry. For twenty-nine years I couldn't go back."),
        say("Yiayia Androulla", "When the crossings opened in 2003 I went to see my house. A Turkish Cypriot family lives there. They had lost their own home, near Paphos, in the south. We had coffee. We both cried."),
        say("Yiayia Androulla", "Then we argued about the coffee. We still visit. Her grandson fixed my television."),
    ]
    z.dialogue["ns_bureau"] = [
        say("Bureau Clerk", "Euros on this side. If you're crossing north, they mostly use the Turkish lira, though plenty of places take euros at their own rate. Change some here, or there."),
        {"do": "bureau"},
    ]
    trainer("ns_busker", "Bouzouki Busker", "Busker", "bard", [("swiftlet", 96), ("tesserite", 96), ("parakit", 97)],
            ["The bouzouki has eight strings and I know four of them very well. Battle for a tip?"],
            "You've a good ear. Bad hat, good ear.",
            "Cyprus has its own folk songs, older than the bouzouki. The old ones have the violin and the laouto, a kind of lute. Mine has a tin for coins.")
    trainer("ns_student", "University Student", "Student", "student", [("moggle", 96), ("cooplet", 96), ("chamelet", 97), ("stencilette", 97)],
            ["I'm studying for exams and learning Turkish at an evening class. My grandmother says her mother spoke it at the market in the old days. Help me procrastinate?"],
            "Teşekkürler. That's 'thanks' in Turkish. See? Evening class works.",
            "Most people my age have never known the island in one piece. We cross for coffee, for concerts, for friends. It's not politics. It's Thursday.")

    ins = []
    ins.append(sanctuary(z, sanct, "nicosia_south_sanctuary", "Nicosia Sanctuary",
                         ["Kaliméra. Nicosia Sanctuary. It's forty degrees in August and we're the only building with working air conditioning, so be quick.",
                          "Pop them down. We've had all sorts today: a heatstroke, a cat bite and a man who tried to grill his own halloumi indoors.",
                          "All better. Drink water. Wear a hat. Never argue with a Cypriot grandmother about food.",
                          "The Ark's in the back. Mind the fan, it's older than the Republic.",
                          "Siga siga, slowly slowly. That's the island's motto."]))
    dump("data/shops/nicosia_periptero.json", {"id": "nicosia_periptero", "name": "Periptero, Nicosia",
                                              "stock": BASIC + ["halloumi", "loukoumi", "carob_syrup", "loukoumades", "koupepia", "sheftali_kebab"]})
    ins.append(shop(z, per, "nicosia_south_shop", "Periptero", "nicosia_periptero",
                    "A periptero is a kiosk: newspapers, cold drinks, phone cards, lottery tickets and somebody's uncle. What can I get you?",
                    "Efcharistó! Thanks. Mind the heat out there.", who="Kiosk Owner"))
    t = interior(z, tav, "nicosia_taverna", "Taverna", w=11, h=9, counter=(2, 2, 5),
                 props=[{"type": "table", "x": 6, "y": 4}, {"type": "table", "x": 8, "y": 4}, {"type": "table", "x": 2, "y": 5},
                        {"type": "menu_board", "x": 7, "y": 1, "walk": True}, {"type": "wall_picture", "x": 9, "y": 1, "walk": True, "variant": 2},
                        {"type": "potted_plant", "x": 1, "y": 1}],
                 npcs=[npcd("ns_taverna", "shopkeeper", 3, 1, script="ns_taverna", name="Taverna Owner"),
                       npcd("ns_ranger", "ghillie", 7, 5, "up", script="ns_ranger", name="Forest Ranger"),
                       npcd("ns_teacher_el", "student", 4, 5, "right", script="ns_teacher_el", name="Greek Teacher")])
    t.dialogue["ns_taverna"] = [
        say("Taverna Owner", "Meze tonight? Don't order anything else. We bring you dips, then salad, then halloumi, then sheftalia, then lamb, then you beg us to stop, then the fruit."),
        say("Taverna Owner", "Kopiaste! That's Cypriot: 'come and join us'. You say it to anyone passing while you're eating. And then they sit down. That's the risk."),
    ]
    t.dialogue["ns_teacher_el"] = [
        say("Greek Teacher", "Yiá sou! Hello, to one person; 'yiá sas' to more than one, or to be polite. 'Kaliméra' is good morning, 'efcharistó' is thank you."),
        say("Greek Teacher", "'Parakaló' is please, and also 'you're welcome', and also what the shopkeeper says when you walk in. One word, three jobs. Very efficient people, the Greeks."),
        say("Greek Teacher", "Cypriot Greek has its own sound: Cypriots often say 'éla', come on, and they tend to soften a 'k' into a 'ch' sound. Mainland Greeks can tell a Cypriot in one word."),
    ]
    t.dialogue["ns_ranger"] = [
        iff(A + "done", [say("Forest Ranger", "Look after that agrino. The real ones are still up in the Paphos forest, wild and wary, and counting on all of us.")], [
            iff(A + "started", [when("caught_chamelet", [
                say("Forest Ranger", "You found a Chamelet? People walk past those for years without seeing one. You've got the patience for the hills."),
                say("Forest Ranger", "Then take this one. A young agrino, the mouflon of Cyprus, raised at a forest station and too used to people to go back up the mountain. It needs someone who'll walk it."),
                {"do": "give_creature", "species": "agrino", "level": 95, "scaled_floor": 95},
                setf(A + "1"), setf(A + "done"), standing(5)],
                [say("Forest Ranger", "Catch a Chamelet. They're in the fields round Pyla and the dunes over in Spain, if you ever go. Look twice at every leaf.")])],
                [say("Forest Ranger", "I'm with the Forestry Department, down from the Paphos forest for a meeting and a decent lunch."),
                 say("Forest Ranger", "Up there we look after the agrino, the Cypriot mouflon, a wild sheep found nowhere else. It was hunted almost to nothing a hundred years ago. Protected since, it's come back to the thousands. It's on your one, two and five cent coins."),
                 say("Forest Ranger", "I've a young one that needs a keeper. But you'd need a good eye. Show me you can find a Chamelet, the shyest creature on this island, and we'll talk."),
                 setf(A + "started")])])]
    ins.append(t)
    m = interior(z, mus, "nicosia_leventis", "Leventis Museum", w=13, h=9,
                 props=[{"type": "display_case", "x": 2, "y": 2}, {"type": "display_case", "x": 5, "y": 2}, {"type": "display_case", "x": 8, "y": 2},
                        {"type": "display_case", "x": 2, "y": 5}, {"type": "display_case", "x": 10, "y": 5}, {"type": "wall_map", "x": 10, "y": 1, "walk": True},
                        {"type": "velvet_rope", "x": 6, "y": 5}],
                 npcs=[npcd("ns_curator", "tour_guide", 6, 3, script="ns_curator", name="Curator"),
                       npcd("ns_visitor", "villager_4", 9, 6, "up", script="ns_visitor", name="Visitor")])
    m.dialogue["ns_curator"] = [
        say("Curator", "The Leventis is the museum of Nicosia itself: the city from its first villages to today. Copper Age figures, Lusignan pottery, Ottoman costumes, British stamps."),
        say("Curator", "The island's name and copper go back a long way together: the Latin word for copper comes from 'Cyprus'. Bronze Age Cyprus shipped copper all round the eastern Mediterranean."),
        say("Curator", "Lusignan, Venetian, Ottoman, British, and now this. Every ruler left a building and took a bit of the view. The cats stayed throughout."),
    ]
    m.dialogue["ns_visitor"] = [say("Visitor", "My grandmother's wedding dress is in that case. She'd be furious. She said it never fitted.")]
    ins.append(m)
    c = interior(z, church, "nicosia_church", "Orthodox Church", w=11, h=11,
                 props=[{"type": "candelabra", "x": 2, "y": 2}, {"type": "candelabra", "x": 8, "y": 2},
                        {"type": "wall_picture", "x": 4, "y": 1, "walk": True, "variant": 3}, {"type": "wall_picture", "x": 6, "y": 1, "walk": True, "variant": 0},
                        {"type": "bench", "x": 2, "y": 6}, {"type": "bench", "x": 8, "y": 6}],
                 npcs=[npcd("ns_priest", "pilgrim", 5, 2, script="ns_priest", name="Priest"),
                       npcd("ns_candles", "villager_3", 3, 7, "up", script="ns_candles", name="Churchgoer")])
    c.dialogue["ns_priest"] = [
        say("Priest", "Welcome. The Church of Cyprus is one of the oldest in the world: it has governed itself since the fifth century. The icons on the screen are windows, we say, not pictures."),
        say("Priest", "There were churches in the north and mosques in the south, and there still are. Some are used, some are empty, some are being mended by people from both sides together. That's worth a candle."),
    ]
    c.dialogue["ns_candles"] = [say("Churchgoer", "You light a candle, you say a prayer, you push in front of nobody. That's the whole of the etiquette, love.")]
    ins.append(c)
    z.encounters = {"grass": town_grass()}
    return [z] + ins


def nicosia_north():
    z = Zone("nicosia_north", "Nicosia (north)", 56, 48, kind="town", region="overseas_north_cyprus", music="town_city",
             stage="city", weather=WEATHER, legend=CITY)
    z.rect(0, 0, 56, 2, 'W'); z.rect(0, 0, 2, 48, 'W'); z.rect(54, 0, 2, 48, 'W'); z.rect(0, 46, 56, 2, 'W')
    z.rect(2, 44, 52, 2, 'F')
    z.rect(30, 14, 3, 34, 'a')                     # Arasta, up from the crossing
    z.rect(12, 12, 35, 6, 'c')                     # Selimiye square
    z.rect(2, 27, 52, 3, 'c')
    z.rect(4, 36, 21, 7, 'k'); z.rect(36, 36, 17, 7, 'k')
    mosque = z.building(22, 3, 16, 9, "selimiye", "Selimiye Mosque", door=8)
    han = z.building(4, 20, 11, 6, "han", "Büyük Han", door=5)
    sanct = z.building(36, 20, 6, 4, "kioski_house", "Sanctuary", door=3)
    bak = z.building(44, 20, 6, 4, "kioski_house", "Bakkal", door=3)
    z.building(44, 3, 6, 4, "venetian_gate", "Kyrenia Gate")
    z.building(33, 40, 3, 2, "checkpoint_booth", "Ledra Street Crossing")
    for bx, by, bw, bh in [(17, 20, 6, 4), (24, 20, 5, 4), (4, 31, 6, 4), (12, 31, 6, 4), (20, 31, 6, 4), (36, 31, 6, 4), (44, 31, 6, 4),
                           (4, 3, 6, 4), (12, 3, 6, 4)]:
        z.building(bx, by, bw, bh, "kioski_house")
    for x in [4, 9, 14, 22, 26, 36, 40, 47, 51]:
        z.prop("barrel", x, 43)
    for x, y in [(13, 13), (45, 13), (13, 16), (45, 16)]:
        z.prop("palm", x, y)
    for x in [8, 20, 40, 50]:
        z.prop("lamp_post", x, 26)
    z.prop("table", 16, 14); z.prop("market_stall", 38, 16, variant=3)
    z.spawn = (31, 42)
    z.sign(34, 13, "This was the Cathedral of Saint Sophia, a Gothic church built by the Lusignan kings of Cyprus between the 1200s and the 1300s, where they were crowned. After the Ottoman conquest of 1570 it became a mosque and the two minarets went up on its towers. It was named the Selimiye in 1954, after Sultan Selim II. A French cathedral with minarets: Nicosia in one building.",
           "cyprus_selimiye", "Selimiye Mosque")
    z.sign(24, 14, "Next to the mosque stands the Bedesten, a church of Byzantine and then Gothic times which the Ottomans turned into a bedesten, a covered market for cloth and valuables. It has been restored, and the stone carving over its north door is worth the crick in your neck.",
           "cyprus_bedesten", "The Bedesten")
    z.sign(16, 26, "The Büyük Han, the Great Inn, was built by the Ottomans in 1572, soon after they took the island: two storeys of rooms round a courtyard, where travelling merchants slept upstairs and their animals and goods stayed below. A small mosque stands on pillars over the fountain in the middle. Today it's cafes and craft shops.",
           "cyprus_buyuk_han", "The Büyük Han")
    z.sign(43, 8, "The Kyrenia Gate is one of the gates in the Venetian walls, built in the 1560s on the road north over the mountains to Kyrenia, Girne in Turkish. The Ottomans later put a little domed room on top. Today the road goes round it and the gate stands on its own, like a man who's been left holding a door.",
           "cyprus_kyrenia_gate", "The Kyrenia Gate")
    z.sign(43, 25, "The north uses the Turkish lira. It has lost a great deal of its value in recent years, so prices are big numbers and they change often, and many shops will quote in euros or pounds as well. Check which money a price is in before you nod.",
           "cyprus_lira", "The Lira")
    z.sign(29, 38, "In 1983 Turkish Cypriot leaders declared the Turkish Republic of Northern Cyprus. Only Turkey recognises it as a state; the UN and nearly every other country treat the whole island as the Republic of Cyprus. On the ground, Turkish Cypriots run their own affairs here, with their own parliament, police and passports, and Turkish troops are still stationed in the north.",
           "cyprus_north_1983", "Northern Cyprus")
    z.sign(33, 30, "Turkish-speaking Cypriots have lived on the island since the Ottoman conquest of 1570 and 1571. Before the 1960s they lived all over Cyprus, in mixed villages and their own. From 1963 many lived in enclaves behind barricades, and after 1974 most moved north, as most Greek Cypriots in the north moved south. Both communities lost homes, neighbours and a way of life.",
           "cyprus_turkish_cypriots", "Turkish Cypriots")
    z.sign(20, 30, "Since 1981 the Committee on Missing Persons, with Greek Cypriot and Turkish Cypriot members working side by side, has searched for the people from both communities who went missing in the 1960s and in 1974. Its scientists have identified many hundreds and returned them to their families. It is quiet, slow work, and some of the most trusted on the island.",
           "cyprus_missing", "The Missing")
    z.sign(16, 16, "On this side the cheese is hellim, the same cheese the south calls halloumi: sheep and goat's milk, mint and brine. It's protected by the EU under both names, which is the island in a nutshell, or a cheese rind.",
           "cyprus_hellim", "Hellim")
    z.sign(29, 43, "LEFKOŞA / NICOSIA. The crossing to the south is behind you. ARASTA and the SELİMİYE, straight on.")
    z.npc("nn_police", "rail_guard", 29, 41, "down", script="nn_police", name="Police Officer")
    z.npc("nn_baker", "shopkeeper", 40, 28, "left", trainer="nn_baker")
    z.npc("nn_tavla", "villager_5", 17, 14, "left", trainer="nn_tavla")
    z.npc("nn_dede", "villager_2", 36, 15, "down", script="nn_dede", name="Dede Mehmet")
    z.npc("nn_student", "student", 22, 28, "down", script="nn_student", name="Student")
    z.npc("nn_doviz", "commuter", 50, 25, "down", script="nn_doviz", name="Döviz Clerk")
    z.dialogue["nn_police"] = [
        say("Police Officer", "Hoş geldiniz, welcome. Passport or ID card, please. You showed it on the other side; now you show it here. It's a very well-travelled card."),
        say("Police Officer", "Shops, Selimiye and the Büyük Han are up Arasta. Prices are in lira, mostly. Don't faint at the noughts."),
    ]
    z.dialogue["nn_dede"] = [
        say("Dede Mehmet", "I grew up in a mixed village near Limassol. In 1963 things went bad, and for eleven years we lived in an enclave, behind sandbags, with my father on watch at night."),
        say("Dede Mehmet", "In 1975 we came north. My best friend at school was Greek Cypriot. I didn't see him for twenty-eight years."),
        say("Dede Mehmet", "When the crossings opened in 2003 he walked over with a bag of oranges from my mother's old tree. He remembered which tree. We sat in the square and didn't say anything for an hour."),
    ]
    z.dialogue["nn_student"] = [
        say("Student", "I study here and my best friend studies in the south. We meet for coffee in the middle of Ledra Street, more or less. It drives our parents mad, in a nice way."),
        say("Student", "My grandmother speaks Greek as well as Turkish, from the market in her village. My generation mostly speaks English to each other. Somebody should write a paper about that. Maybe me."),
    ]
    z.dialogue["nn_doviz"] = [
        say("Döviz Clerk", "Döviz means foreign exchange. Pounds into lira, lira into pounds, the day's rate, my small commission and a smile, free of charge."),
        {"do": "bureau"},
    ]
    trainer("nn_baker", "Simit Seller", "Baker", "shopkeeper", [("mustling", 96), ("crockling", 96), ("beancrock", 97)],
            ["Simit! Sesame rings, fresh this morning. You look hungry and argumentative. Let's battle first."],
            "Fair enough. Have a simit anyway.",
            "Pastry here is a serious business. Börek, pirohu, pilavuna at Easter-time for Greek Cypriots and at Bayram for us. Same cheese inside, two names outside. You see the pattern.")
    trainer("nn_tavla", "Tavla Player", "Tavla Champion", "villager_5", [("tesserite", 96), ("wispet", 96), ("roodstone", 97)],
            ["Tavla. You call it backgammon, the south calls it tavli. It's the same game on the same board, and I'm the best on both sides."],
            "Lucky dice. I'm not saying it, the dice are saying it.",
            "In tavla you can play perfectly and still lose. The trick is to play perfectly anyway. That's life, also.")

    ins = []
    ins.append(sanctuary(z, sanct, "nicosia_north_sanctuary", "Lefkoşa Sanctuary",
                         ["Merhaba, hello! Lefkoşa Sanctuary. Too much sun? Too much kebab? Too many crossings in one day?",
                          "Put them here. The doctor's at lunch, but I'm better at this anyway.",
                          "Geçmiş olsun: get well soon, we say. Done. Drink some ayran and stay in the shade.",
                          "The Ark is through that door. It's cool in there. The cats know.",
                          "Yavaş yavaş, slowly slowly. Nothing here is in a hurry except the traffic."]))
    dump("data/shops/nicosia_bakkal.json", {"id": "nicosia_bakkal", "name": "Bakkal, Lefkoşa",
                                           "stock": BASIC + ["halloumi", "loukoumi", "carob_syrup", "loukoumades", "sheftali_kebab", "ayran"]})
    ins.append(shop(z, bak, "nicosia_north_shop", "Bakkal", "nicosia_bakkal",
                    "A bakkal is a corner shop: bread, cheese, tea, washing powder and the news. Prices in lira. What'll it be?",
                    "Teşekkür ederim, thank you! Güle güle: go with a smile.", who="Bakkal"))
    hi = interior(z, han, "nicosia_buyuk_han", "Büyük Han", w=13, h=11,
                  props=[{"type": "cascade", "x": 6, "y": 4}, {"type": "table", "x": 2, "y": 6}, {"type": "table", "x": 10, "y": 6},
                         {"type": "market_stall", "x": 2, "y": 2, "variant": 2}, {"type": "market_stall", "x": 10, "y": 2, "variant": 4},
                         {"type": "loom", "x": 1, "y": 8}, {"type": "potted_plant", "x": 11, "y": 8}],
                  npcs=[npcd("nn_cheese", "shopkeeper", 3, 2, script="nn_cheese", name="Hellim Seller"),
                        npcd("nn_critic", "gown_student", 9, 4, trainer="nn_critic"),
                        npcd("nn_weaver", "villager_4", 2, 8, "right", script="nn_weaver", name="Weaver"),
                        npcd("nn_teacher_tr", "student", 9, 7, "left", script="nn_teacher_tr", name="Turkish Teacher")])
    hi.dialogue["nn_cheese"] = [
        iff(Q + "4", [say("Hellim Seller", "Off you go to Pyla. Tell Hüseyin I said he's right. Tell Andreas I said he's right. That's diplomacy.")], [
            iff(Q + "3", [iff("trainer_nn_critic", [
                say("Hellim Seller", "You beat the critic? Then you're a judge worth listening to. My verdict: same cheese, two names, one island. My mother made it, your Andreas's mother made it. The EU wrote both names on one form in 2021, so it's official."),
                say("Hellim Seller", "Go and tell them in Pyla. And tell them the best one is mine."),
                setf(Q + "4")],
                [say("Hellim Seller", "The south sent you? Good. But first, that critic by the fountain says hellim is 'squeaky rubber'. In front of my stall. Settle it, and I'll give you my verdict.")])],
                [say("Hellim Seller", "Hellim, fresh and in brine! Fry it with tomatoes, or eat it in a sandwich with a slice of watermelon in summer."),
                 {"do": "shop", "id": "nicosia_bakkal"}])])]
    hi.dialogue["nn_weaver"] = [
        say("Weaver", "Lefkara lace is from a village in the south, hand-stitched. My weaving is from the north. We sell at the same craft fairs and admire each other's work very loudly, so the customers hear."),
    ]
    hi.dialogue["nn_teacher_tr"] = [
        say("Turkish Teacher", "Merhaba! That's hello. 'Günaydın' is good morning, 'teşekkür ederim' is thank you, and 'sağ ol' is the quick, friendly thanks."),
        say("Turkish Teacher", "Before a meal, say 'afiyet olsun', enjoy it. To someone at work, say 'kolay gelsin', may it come easy. There's a phrase for everything. It's a very sociable language."),
        say("Turkish Teacher", "Turkish letters to watch: ş is 'sh', ç is 'ch', and ı without a dot is a sound English hasn't got, somewhere between the 'a' in 'about' and a grunt."),
    ]
    trainer("nn_critic", "Food Critic", "Critic", "gown_student", [("stencilette", 96), ("pierlord", 96), ("rhymerick", 97), ("marmalord", 97)],
            ["Hellim. Halloumi. Whatever you call it, it's squeaky rubber that tastes of salt. I've written three columns saying so.",
             "Defend it, if you can."],
            "All right. All right! Squeaky, yes. Rubber, no. I'll write a fourth column.",
            "I ate some hellim fried with tomatoes just now. Don't tell my editor.")
    ins.append(hi)
    s = interior(z, mosque, "nicosia_selimiye", "Selimiye Mosque", w=15, h=11,
                 props=[{"type": "rug", "x": 4, "y": 4, "variant": 2}, {"type": "rug", "x": 8, "y": 4, "variant": 2}, {"type": "rug", "x": 4, "y": 6, "variant": 1},
                        {"type": "rug", "x": 8, "y": 6, "variant": 1}, {"type": "candelabra", "x": 2, "y": 2}, {"type": "candelabra", "x": 12, "y": 2}],
                 npcs=[npcd("nn_caretaker", "pilgrim", 7, 2, script="nn_caretaker", name="Caretaker"),
                       npcd("nn_tourist", "festival_goer", 11, 7, "up", script="nn_tourist", name="Visitor")])
    s.dialogue["nn_caretaker"] = [
        say("Caretaker", "Welcome. Shoes off at the door, please, and visitors cover shoulders and knees. It's a working mosque: five prayers a day, and Friday is the busy one."),
        say("Caretaker", "Look up. Those are Gothic arches, built by French-speaking kings for Christian worship. Now they hold carpets turned towards Mecca. The building has been holy to someone for seven hundred years."),
        say("Caretaker", "The mihrab, the niche that shows the direction of prayer, was set into the old wall at an angle, because Mecca isn't where the cathedral pointed. You can still see the join."),
    ]
    s.dialogue["nn_tourist"] = [say("Visitor", "I came on a day trip from the south. My guidebook calls it Agia Sofia. The sign outside calls it Selimiye. The pigeons don't call it anything. They just live here.")]
    ins.append(s)
    z.encounters = {"grass": town_grass()}
    return [z] + ins


def build():
    p = pyla()
    s = nicosia_south()
    n = nicosia_north()
    p[0].edges["south"] = {"to": "dhekelia", "offset": 4}
    p[0].edges["north"] = {"to": "nicosia_south", "offset": 0}
    s[0].edges["south"] = {"to": "pyla", "offset": 0}
    s[0].edges["north"] = {"to": "nicosia_north", "offset": 0}
    n[0].edges["south"] = {"to": "nicosia_south", "offset": 0}
    return p + s + n
