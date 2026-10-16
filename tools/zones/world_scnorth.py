"""Walk-in interiors for the Scottish north: Aberdeen, Inverness, Fort William, Great Glen, Loch Ness,
Cairngorms, Skye, Portree and Kirkwall. Landmarks plus a handful of homes per town.
Run: python3 tools/zones/world_scnorth.py data/zones
(writes interiors, dialogue and patches the town/route doors and warps in place; safe to re-run)"""
import sys, os, json
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from zlib import landmark

OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
DLG = os.path.join(os.path.dirname(os.path.abspath(OUT)), "dialogue")

WALK = set(".,#=:sfwD|+_")
WALK_TILES = ("grass", "tall_grass", "path", "road", "cobbles", "sand", "flowers", "shallow", "door",
              "floor_wood", "floor_tile", "platform")


def say(who, text):
    return {"do": "say", "who": who, "text": text}


L = []


def add(zid, name, zone, bx, by, kind, w, h, npcs, door=None, carve=()):
    """npcs: (id, sprite, who, [lines]) or (..., (flag, item, again_line)) where the LAST line is the gift line."""
    L.append(dict(zid=zid, name=name, zone=zone, bx=bx, by=by, kind=kind, w=w, h=h, npcs=npcs, door=door, carve=carve))


# ---------------------------------------------------------------- ABERDEEN
add("aberdeen_marischal", "Marischal College", "aberdeen", 26, 8, "hall", 15, 10, [
    ("marischal_guide", "prof_garside", "University Guide", [
        "Welcome to Marischal College. Yes, the whole front is granite. No, it does not look any lighter if you stare at it.",
        "It was founded in 1593 by the Earl Marischal. In 1860 it joined King's College to become the University of Aberdeen.",
        "The great granite frontage was finished in 1906. It is often called the second largest granite building in the world, after the Escorial in Spain."]),
    ("marischal_student", "student", "Student", [
        "Fit like? That is Doric for how are you. I can say it in my sleep, usually during lectures.",
        "Sit on the steps and watch the gulls. They have a system. It involves your chips."])])
add("aberdeen_townhouse", "Town House", "aberdeen", 5, 6, "hall", 13, 10, [
    ("townhouse_clerk", "commuter", "Clerk", [
        "Welcome to the Town House. Mind the councillors on the landing, they are not as fast as they look.",
        "Aberdeen's motto is Bon Accord, French for good agreement. Legend says it was the watchword when the town threw out an English garrison in 1308.",
        "The city arms show three towers and two leopards. Aberdeen likes its heraldry the way it likes its granite: solid."])])
add("aberdeen_skene", "Provost Skene's House", "aberdeen", 14, 6, "museum", 12, 10, [
    ("skene_guide", "tour_guide", "House Guide", [
        "Welcome to Provost Skene's House. It dates from 1545, which makes it one of the oldest town houses left in Aberdeen.",
        "It is named after Sir George Skene, who was Provost of Aberdeen in the late 1600s and lived here.",
        "Upstairs the ceilings are painted with scenes from the life of Christ. They were hidden under plaster until the house was saved from being knocked down."])])
add("aberdeen_maritime", "Maritime Museum", "aberdeen", 26, 34, "museum", 14, 10, [
    ("maritime_shipwright", "shipwright", "Museum Guide", [
        "Welcome aboard. Mind the rigging, the models and your head, in that order.",
        "Aberdeen yards built the Aberdeen Bow in 1839, a sharp bow that made clipper ships such as the Scottish Maid very fast.",
        "The museum is built round Provost Ross's House, which dates from 1593. Then came North Sea oil, and the harbour swapped sails for supply boats."]),
    ("maritime_fisher", "fisherman_north", "Old Fisherman", [
        "Orcalets show up at the harbour mouth when the fish are in. Keep your snares ready and your sandwiches hidden."])])
add("aberdeen_home_a", "Granite Terrace Home", "aberdeen", 3, 18, "home", 11, 9, door=4, npcs=[
    ("abdn_home_a_quine", "villager_2", "Resident", [
        "Fit like? That is Doric for how are you. A loon is a boy and a quine is a girl. I will not guess which you are.",
        "This house is granite, like the rest of the street. Grey in the rain, sparkly in the sun, because of the mica.",
        "My gran says granite from the Rubislaw quarry built half the city, and bits of London's Waterloo Bridge too."])])
add("aberdeen_home_b", "The Mitchells' House", "aberdeen", 27, 19, "home", 12, 9, door=29, npcs=[
    ("abdn_home_b_dad", "villager_4", "Resident", [
        "Binfoxes come out on bin day with fur bristling and plans in their eyes. Never leave a bag out. They know.",
        "The haarling comes in with the haar, the cold sea fog off the North Sea. It always arrives on the day of the picnic.",
        "Here, take a bit of tablet. My wife makes it by the tray and I am only allowed to give it away."],
     ("aberdeen_home_b_gift", "tablet", "Another bit? You will be too sweet to stand. Off you go."))])
add("aberdeen_home_c", "Fittie Family House", "aberdeen", 39, 28, "home", 11, 10, [
    ("abdn_home_c_gran", "fisherman_north", "Resident", [
        "My gran grew up in Footdee. We say Fittie. The little houses sit round squares facing the sea, built for fishing families in the 1800s.",
        "Each family kept a boat on the doorstep and a shed in the garden, and some still do. Very Aberdeen: nothing wasted.",
        "Oil came in the 1970s and the town got busy overnight. Even the gulls got ideas above their station."])])
add("aberdeen_home_d", "Rowie Bakery House", "aberdeen", 6, 34, "home", 12, 9, [
    ("abdn_home_d_mum", "mum", "Resident", [
        "A rowie is an Aberdeen buttery: flat, salty and rather greasy, best eaten warm. Any local will argue about it for twenty minutes.",
        "Dinna fash means do not worry. Say it when the cat knocks something off the shelf. Mine does it on purpose.",
        "Orcalets turn up by the harbour at Torry. Bring a flask and patience, and do not wave at them. They are shy."])])

# ---------------------------------------------------------------- INVERNESS
add("inverness_castle", "Inverness Castle", "inverness", 32, 7, "castle", 14, 11, [
    ("invcastle_guide", "tour_guide", "Castle Guide", [
        "Welcome to Inverness Castle. The red sandstone building dates from the 1830s and was built as a courthouse and jail.",
        "There has been a fortress on this hill for around a thousand years. The old castle was blown up by Jacobites in 1746.",
        "Outside stands a statue of Flora MacDonald, who helped Bonnie Prince Charlie escape. She has the best view in town and never complains."])])
add("inverness_market", "Victorian Market", "inverness", 48, 28, "workshop", 14, 9, [
    ("invmarket_stallholder", "villager_5", "Stallholder", [
        "Roll up. Tablet, tartan, tea towels, and a duck that is purely decorative.",
        "There has been a market here since the 1870s. After a fire in 1889 it was rebuilt, with the grand arches you walked under."]),
    ("invmarket_shinty", "shinty_player", "Shinty Player", [
        "Shinty is played with a stick called a caman. It is like hockey, but you may hit the ball in the air. Mind your head.",
        "The sticks are sold on the corner stall. Buy one and the whole town will expect you to turn up on Saturday."])])
add("inverness_home_a", "The Frasers' House", "inverness", 13, 8, "home", 12, 9, [
    ("inv_home_a_mum", "villager_3", "Resident", [
        "Och, come in. The river runs right through town, and the name means mouth of the Ness. Inbhir Nis, in Gaelic.",
        "When it is grey and wet we say dreich. When it is grey and wet and we are in a mood, crabbit. That is the whole forecast.",
        "Flittermice come out over the Ness Islands at dusk. Stand still and they zip past your ears. Frankly, rude."])])
add("inverness_home_b", "Culloden Road House", "inverness", 3, 14, "home", 11, 9, [
    ("inv_home_b_grandad", "villager_6", "Resident", [
        "Culloden Moor is a few miles east. The battle there in 1746 was the last pitched battle fought on British soil. It is quiet now and well worth a visit.",
        "My grandfather said a brownie keeps a tidy house tidy and a messy house messier. I still tidy before bed, just in case."])])
add("inverness_home_c", "Canal Cottage", "inverness", 15, 24, "cottage", 11, 9, [
    ("inv_home_c_mum", "mum", "Resident", [
        "Thomas Telford built the Caledonian Canal, finished in 1822, so boats could cross the Highlands without sailing round the top.",
        "Go and watch the locks at Muirtown. The boats go up like they are climbing a staircase made of water.",
        "There, a cup of tea to go. You look like someone who has been watching boats."],
     ("inverness_home_c_gift", "cup_of_tea", "I have given you a cup already. Do not be greedy, the kettle is tired."))])
add("inverness_home_d", "Hootlet Lane House", "inverness", 38, 28, "home", 11, 10, [
    ("inv_home_d_man", "villager_1", "Resident", [
        "Hootlets nest in the old trees by the churchyard. Listen for them at dusk. They sound like a very polite doorbell.",
        "The Highland Games are held every summer round here: caber, hammer and bagpipes. Do not stand near the caber."])])

# ---------------------------------------------------------------- FORT WILLIAM
add("fw_museum", "West Highland Museum", "fort_william", 28, 16, "museum", 14, 10, [
    ("fwmuseum_curator", "tour_guide", "Curator", [
        "Welcome to the West Highland Museum. We opened in 1922, which is not long by Highland standards.",
        "Fort William is named after King William III. The first fort was built to keep the clans in order, and it was pulled down for the railway.",
        "Our best treasure is a secret portrait of Bonnie Prince Charlie. It looks like a smear of paint until you stand a shiny cylinder on it."])])
add("fw_nevisinn", "The Nevis Inn", "fort_william", 14, 24, "cafe", 14, 9, [
    ("nevisinn_host", "villager_4", "Innkeeper", [
        "Welcome to the Nevis Inn. Walkers get the good seats, and muddy boots go by the door.",
        "Ben Nevis is 1,345 metres, the tallest mountain in Britain. A weather observatory sat on the top from 1883 to 1904.",
        "In Gaelic it is Beinn Nibheis. The view is magnificent on the handful of days the cloud lets you have it."]),
    ("nevisinn_walker", "hillwalker", "Hill Walker", [
        "Allow most of a day for the summit path. Carry a map, a hat, a torch and more snacks than you think. Then add a flask."])])
add("fw_home_a", "Garrison Cottage", "fort_william", 36, 16, "home", 11, 9, [
    ("fw_home_a_woman", "villager_3", "Resident", [
        "An Gearasdan is the Gaelic name for Fort William. It means the garrison. Nothing here is easy to spell, but it is all lovely.",
        "Our midgies are no joke. On a still summer evening they get everywhere. Keep moving, wear a hat, and think brave thoughts."])])
add("fw_home_b", "Canal Bank House", "fort_william", 44, 16, "cottage", 12, 9, [
    ("fw_home_b_mum", "mum", "Resident", [
        "Telford's Neptune's Staircase is a ladder of eight locks at Banavie. A boat takes about ninety minutes to climb it.",
        "The Jacobite steam train crosses the Glenfinnan viaduct. Your friends will say it is from a famous wizard film. They will be right.",
        "Here, a bit of tablet for the road. Please do not tell the dentist."],
     ("fw_home_b_gift", "tablet", "I gave you a piece already. You have been very polite, so you may stay for tea."))])
add("fw_home_c", "Mountain Rescue House", "fort_william", 26, 24, "home", 11, 9, [
    ("fw_home_c_man", "villager_6", "Resident", [
        "Snowhares and ptarmlets go white in winter up on the Ben. In summer they are brown, the colour of the rocks, which is the cheek of it.",
        "Mountain rescue are up the Ben a lot. Tell someone where you are going and when you will be back. Always."])])

# ---------------------------------------------------------------- GREAT GLEN
add("gg_bothy", "Lochside Bothy", "great_glen", 24, 44, "cottage", 11, 9, [
    ("ggbothy_walker", "hillwalker", "Walker", [
        "Welcome to the bothy. The rules are simple: leave it tidier than you found it, and leave some dry wood.",
        "The Mountain Bothies Association has looked after huts like this since 1965. They are free for anybody to use.",
        "The Great Glen is a long straight valley where the land cracked along a fault. You can walk or paddle coast to coast.",
        "Kelpies live in the lochs. If the water looks too calm, do not swim. Have a flask of tea instead."],
     ("gg_bothy_gift", "flask_of_tea", "That was my spare flask. The kettle is on if you want another, but I have only the one mug."))])
add("gg_invergarry", "Invergarry Castle", "great_glen", 24, 56, "castle", 13, 10, [
    ("invergarry_guide", "ghillie", "Local Guide", [
        "Welcome to Invergarry Castle, home of the MacDonnells of Glengarry. It stands on the Raven's Rock, Creag an Fhithich in Gaelic.",
        "Bonnie Prince Charlie slept here for a night in 1746, after Culloden. Soon afterwards government troops burned the castle.",
        "It has been a ruin ever since. Mind the stones. They have been falling down politely for over 270 years."])])

# ---------------------------------------------------------------- LOCH NESS
add("ln_gate", "Gate Tower", "loch_ness", 44, 24, "castle", 11, 9, [
    ("lngate_warden", "villager_5", "Castle Warden", [
        "This is the gatehouse of Urquhart Castle. The drawbridge hung just outside, which was not a restful place to stand in a siege.",
        "In 1692 the garrison blew up part of the castle so the Jacobites could not use it. It has been a ruin ever since, and a very photogenic one."])])
add("ln_grant", "Grant Tower", "loch_ness", 51, 24, "castle", 11, 9, [
    ("lngrant_guide", "tour_guide", "Castle Guide", [
        "Welcome to the Grant Tower, the best preserved tower of Urquhart Castle. The Grants held the castle from 1509.",
        "From the top you can see most of Loch Ness, if the weather agrees and the midgies do not.",
        "Nessie? Saint Columba is said to have met a water beast in the River Ness in AD 565, and told it to leave a man alone. It did."])])
add("ln_monster", "Monster Exhibition", "loch_ness", 8, 11, "museum", 14, 10, [
    ("lnmonster_guide", "tour_guide", "Exhibition Guide", [
        "Welcome to the Monster Exhibition. Nessie is Scotland's most famous shy person.",
        "Loch Ness is about 36 kilometres long and 230 metres deep. It holds more fresh water than all the lakes in England and Wales put together.",
        "The famous Surgeon's Photograph of 1934 was a toy submarine with a sculpted head, as someone admitted in 1994. The loch still has secrets."]),
    ("lnmonster_kid", "student", "Young Monster Hunter", [
        "I have a sonar app. So far it has found a trout and one very confident duck."])])
add("ln_visitor", "Visitor Centre", "loch_ness", 41, 12, "hall", 13, 10, [
    ("lnvisitor_ranger", "ghillie", "Ranger", [
        "Loch Ness never freezes, even in hard winters. There is so much water that it holds its heat.",
        "It is part of the Great Glen, a fault line that runs coast to coast. The Caledonian Canal ties the lochs to the sea at both ends.",
        "Minkshades slip along the shore after dark, and hootlets keep watch from the trees. Take a torch and a sense of humour."])])

# ---------------------------------------------------------------- CAIRNGORMS
add("cairn_ski", "Ski Centre", "cairngorms", 56, 12, "hall", 14, 10, [
    ("cairnski_instructor", "fell_runner", "Instructor", [
        "Welcome to the Ski Centre. Warm up first. Nobody looks good falling over in salopettes.",
        "Cairn Gorm is 1,245 metres, the sixth highest mountain in Britain. The funicular railway up it opened in 2001.",
        "Scottish snow is famously unreliable. On a good day you can ski. On a bad one you can paddle."]),
    ("cairnski_kid", "student", "Young Skier", [
        "I fell over eleven times today. The twelfth I did on purpose."])])
add("cairn_reindeer", "Reindeer Centre", "cairngorms", 26, 33, "cottage", 12, 9, [
    ("cairnreindeer_herder", "farmer", "Reindeer Herder", [
        "Welcome to the Reindeer Centre. They run free on the hill, so I lead the walk and hope for the best.",
        "The herd began in 1952, when Mikel Utsi, a Sami herder from Sweden, and his wife Ethel Lindgren brought reindeer to the Cairngorms.",
        "They are the only free-ranging herd in Britain. Their feet click as they walk, which helps them stay together in a blizzard."])])
add("cairn_bothy", "Cairngorm Bothy", "cairngorms", 9, 10, "cottage", 11, 9, [
    ("cairnbothy_walker", "hillwalker", "Walker", [
        "The Cairngorms are the biggest national park in the whole of the UK, so pack more snacks than you think.",
        "Ptarmlets go white in winter, and so do stoatlets, whose white winter coat is called ermine. The hill goes in for fancy dress.",
        "Calfreins keep close to their mums on the plateau. Be quiet and they may let you look."])])

# ---------------------------------------------------------------- SKYE
add("skye_eilean", "Eilean Donan", "skye", 60, 29, "castle", 14, 10, carve=[(63, 28, "|"), (64, 28, "|")], npcs=[
    ("eilean_guide", "tour_guide", "Castle Guide", [
        "Welcome to Eilean Donan, where three sea lochs meet. It is named after St Donnán, who is said to have lived here about AD 600.",
        "The castle dates from the 13th century. In 1719 English warships bombarded it during a Jacobite rising, and it lay in ruins for about 200 years.",
        "Lt Col John MacRae-Gilstrap rebuilt it between 1912 and 1932. The footbridge you walked across is quite modern, but do not tell the ghosts."])])
add("skye_croft", "Croft House", "skye", 30, 13, "cottage", 11, 9, [
    ("skyecroft_crofter", "farmer", "Crofter", [
        "Come in out of the wind. A croft is a small farm with a big view and no hope of getting rich.",
        "In 1886 the Crofters Act gave families security on their land, after the hard years of the Clearances when many were forced to leave.",
        "Ciamar a tha thu? means how are you. Reply with Tha gu math, tapadh leat: I am well, thank you.",
        "We keep Blackface sheep. They have strong opinions about the weather and the gate."])])
add("skye_bridgecafe", "Bridge Cafe", "skye", 30, 24, "cafe", 13, 9, [
    ("bridgecafe_owner", "shopkeeper", "Cafe Owner", [
        "Welcome to the Bridge Cafe. Everything here is made fresh, apart from the weather.",
        "The Skye Bridge opened in 1995. Before that you took a ferry from Kyle of Lochalsh. The tolls were scrapped in 2004 after a long campaign.",
        "Cragchoughs nest on the sea cliffs. You will see them tumbling in the wind. Here, have some tablet while you watch."],
     ("skye_bridgecafe_gift", "tablet", "You have had your tablet. The rest is for paying customers, and the bridge, apparently."))])
add("skye_house", "Farmhouse by the Loch", "skye", 56, 12, "home", 11, 9, [
    ("skye_house_woman", "villager_2", "Resident", [
        "The Cuillin ridge is made of rough black rock that grips boots wonderfully and shreds knees even better.",
        "Orcalets can be spotted off the point on a calm day. Bring binoculars, and do not mistake a seal for one. They sulk."])])
add("skye_kylecafe", "Kyle Station Cafe", "skye", 63, 12, "cafe", 12, 9, [
    ("kylecafe_guard", "rail_guard", "Station Worker", [
        "Welcome to Kyle Station Cafe. Trains in, tea out, that is the whole system.",
        "The railway from Inverness reached Kyle of Lochalsh in 1897. It is famous as one of the most beautiful rail journeys in Britain.",
        "The line crosses bogs, lochs and glens full of deer. Wave at the deer. They never wave back."])])

# ---------------------------------------------------------------- PORTREE
add("portree_royalhotel", "Royal Hotel", "portree", 6, 22, "cafe", 14, 10, [
    ("royalhotel_host", "villager_2", "Hotel Host", [
        "Welcome to the Royal Hotel. We have sat by the harbour a long time and the view has only improved.",
        "Portree is Port Rìgh in Gaelic, the King's Harbour. King James V landed here in 1540 to calm the island chiefs.",
        "In 1746 Flora MacDonald said goodbye to Bonnie Prince Charlie in Portree, after helping him escape disguised as her maid, Betty Burke."])])
add("portree_kirk", "Portree Kirk", "portree", 17, 22, "church", 12, 10, [
    ("portreekirk_singer", "choir_singer", "Chorister", [
        "Welcome. Do mind the hymn books. Some have been here since your great-grandparents.",
        "In Gaelic psalm singing a precentor sings a line and the congregation follows, each in their own flowing way. It sounds like waves.",
        "Gaelic is still spoken on Skye, and many families keep it alive at home. Fail to say hello and you will be told off in two languages."])])
add("portree_aros", "Aros Centre", "portree", 32, 22, "theatre", 14, 10, [
    ("aros_guide", "tour_guide", "Aros Guide", [
        "Welcome to the Aros Centre. Aros means a dwelling in Gaelic. We tell the story of Skye here, with history, music and legends.",
        "Skye has a Gaelic college, Sabhal Mòr Ostaig, in Sleat. It opened in 1973 and teaches in Gaelic.",
        "The Old Man of Storr, the rock pinnacle you can see from Portree, stands about 50 metres tall. It is what is left of a huge landslip."]),
    ("aros_fiddler", "fiddler", "Fiddler", [
        "Skye is a fiddle island. Nobody has a quiet kitchen party. Come back after dark and bring your dancing feet."])])
add("portree_home_a", "Harbour House", "portree", 4, 13, "home", 11, 9, [
    ("portree_home_a_mum", "villager_3", "Resident", [
        "Our harbour houses are painted in pastel colours. One story says it was so fishermen could spot home from the sea. I think we just like pink.",
        "Mòran taing means many thanks. Say it to anyone who hands you a scone, and to anyone who hands you a second one.",
        "A ceilidh was once simply a visit. Come for tea, stay for the songs, leave at midnight."])])
add("portree_home_b", "Minch View", "portree", 21, 13, "cottage", 11, 9, [
    ("portree_home_b_man", "fisherman_north", "Resident", [
        "The sea between us and the Outer Hebrides is called the Minch. In bad weather it is rather grumpy.",
        "Minchmen turn up in the Minch, just as you would expect. They are never lost. They are just on a long detour."])])
add("portree_home_c", "The MacLeods' House", "portree", 41, 22, "home", 12, 9, [
    ("portree_home_c_mum", "mum", "Resident", [
        "Madainn mhath is good morning in Gaelic, and oidhche mhath is good night. You will hear both in the shop.",
        "Orcalets are seen off Portree harbour in summer, with a bit of luck. Bring waterproofs, because the weather has not heard of luck."])])
add("portree_home_d", "Staffin Road Cottage", "portree", 33, 30, "cottage", 11, 9, [
    ("portree_home_d_kid", "student", "Resident", [
        "My teacher says Skye has dinosaur footprints, up at Staffin. They are around 170 million years old.",
        "I went to see them. They are very big. I stood in one and felt tiny, which was the point."])])

# ---------------------------------------------------------------- KIRKWALL
add("kirkwall_cathedral", "St Magnus Cathedral", "kirkwall", 26, 15, "church", 15, 11, [
    ("kwlcathedral_guide", "tour_guide", "Cathedral Guide", [
        "Welcome to St Magnus Cathedral, the most northerly cathedral in Britain. Please use your indoor voice and your outdoor manners.",
        "Earl Rognvald started it in 1137 in memory of his uncle Magnus. Red and yellow sandstone make stripes in the pillars, like a very holy sweet shop.",
        "In 1919 workers found a box of bones inside one of the pillars. They are thought to be those of St Magnus himself."]),
    ("kwlcathedral_student", "student", "Young Guide", [
        "I am training to be a guide. So far I can tell you where the toilets are and where not to run."])])
add("kirkwall_palace", "Bishop's Palace", "kirkwall", 13, 15, "castle", 13, 10, [
    ("palace_guide", "tour_guide", "Palace Guide", [
        "Welcome to the Bishop's Palace, built in the 12th century, almost as old as the cathedral next door.",
        "In 1263 King Haakon IV of Norway came this way after the Battle of Largs. He fell ill and died here.",
        "Orkney stayed Norse until 1468, when it passed to Scotland in a royal marriage deal, the dowry of Margaret of Denmark.",
        "Next door are the ruins of the Earl's Palace, built about 1600 by Earl Patrick Stewart. Quite a bit grander, quite a bit more roof missing."])])
add("kirkwall_home_a", "Peedie House", "kirkwall", 5, 17, "home", 11, 9, [
    ("kwl_home_a_woman", "villager_3", "Resident", [
        "Peedie means small in Orkney. A peedie cat, a peedie cake, a peedie problem. Nothing is large here but the sky.",
        "In midsummer it never gets properly dark. We call that twilight the simmer dim.",
        "Haarlings drift in with the sea fog, which we call the haar. Keep your voice down. They are very sensitive."])])
add("kirkwall_home_b", "Scapa Road House", "kirkwall", 46, 13, "home", 12, 9, [
    ("kwl_home_b_man", "fisherman_north", "Resident", [
        "Kirkwall comes from the Old Norse Kirkjuvagr, church bay. Orkney was Norse for hundreds of years.",
        "Scapa Flow was a great naval base. After the first world war the captured German fleet was scuttled there in 1919, and divers visit the wrecks."])])
add("kirkwall_home_c", "Ba' Game House", "kirkwall", 31, 30, "home", 11, 10, [
    ("kwl_home_c_dad", "villager_4", "Resident", [
        "Every Christmas Day and New Year's Day the Ba' Game is played through the streets. Uppies against Doonies, one huge scrum round a leather ball.",
        "You are an Uppie or a Doonie depending on where you were born. Nobody explains the rules because nobody is quite sure."])])
add("kirkwall_home_d", "Skara Brae View", "kirkwall", 51, 37, "home", 12, 9, [
    ("kwl_home_d_mum", "mum", "Resident", [
        "Skara Brae is a village older than Stonehenge. A storm in 1850 blew the sand off and showed the houses, stone beds and all.",
        "Even their dressers were stone shelves, which makes dusting easy. Cragchoughs nest on the cliffs near here, with red legs and a talent for stealing sandwiches."])])


# ---------------------------------------------------------------- build
def walk_map(td):
    ext = {}
    for k, v in (td.get("legend_extra") or {}).items():
        ext[k] = v.get("tile") in WALK_TILES
    blocked = {(int(p["x"]), int(p["y"])) for p in td["props"] if p["type"] != "building"}
    rows = td["rows"]

    def ok(x, y):
        if not (0 <= y < len(rows) and 0 <= x < len(rows[0])): return False
        c = rows[y][x]
        if (x, y) in blocked: return False
        return ext[c] if c in ext else c in WALK
    return ok


def reach(td, ok):
    sx, sy = int(td["spawn"][0]), int(td["spawn"][1])
    seen = {(sx, sy)}
    st = [(sx, sy)]
    while st:
        x, y = st.pop()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            p = (x + dx, y + dy)
            if p not in seen and ok(*p):
                seen.add(p); st.append(p)
    return seen


def place_npcs(zid, kind, w, h, name, town, ret, specs):
    """dry-run the interior, then drop NPCs on free floor tiles near the middle, not blocking the entrance lane."""
    z = landmark(OUT, zid, name, town, ret, kind, [], w, h)
    taken = {(int(p["x"]), int(p["y"])) for p in z.d["props"]}
    dx = w // 2
    cands = []
    for y in range(2, h - 3):
        for x in range(2, w - 2):
            if (x, y) in taken or z.g[y][x] in "Cx": continue
            if abs(x - dx) <= 1 and y >= h - 4: continue
            free = sum(1 for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1)) if (x + a, y + b) not in taken and z.g[y + b][x + a] not in "Cx")
            if free >= 3:
                cands.append((abs(x - dx) + abs(y - 3) * 0.5, x, y))
    cands.sort()
    out = []
    for i, s in enumerate(specs):
        pick = None
        for _, x, y in cands:
            if all(abs(x - ox) + abs(y - oy) >= 3 for ox, oy in out):
                pick = (x, y); break
        assert pick, zid
        out.append(pick)
    return out


dlg = {}
towns = {}
problems = []
for e in L:
    zone = e["zone"]
    tj = os.path.join(OUT, zone + ".json")
    td = towns.get(zone) or json.load(open(tj))
    towns[zone] = td
    b = None
    for p in td["props"]:
        if p["type"] == "building" and int(p["x"]) == e["bx"] and int(p["y"]) == e["by"]:
            b = p
    assert b, (e["zid"], "no building")
    bw, bh = int(b["w"]), int(b["h"])
    dy = e["by"] + bh - 1
    dxc = e["door"] if e["door"] is not None else e["bx"] + (bw - 1) // 2
    ret = (dxc, dy + 1)
    row = td["rows"][dy]
    if row[dxc] == "B":
        td["rows"][dy] = row[:dxc] + "D" + row[dxc + 1:]
    else:
        assert row[dxc] == "D", (e["zid"], row[dxc])
    for c in e["carve"]:
        cx, cy = c[0], c[1]
        r = td["rows"][cy]
        td["rows"][cy] = r[:cx] + (c[2] if len(c) > 2 else "#") + r[cx + 1:]
    if zone == "skye":  # the causeway round the castle needs its east flank clear
        for pr in td["props"]:
            if pr["type"] == "rock" and int(pr["x"]) == 64 and int(pr["y"]) == 31:
                pr["x"], pr["y"] = 65, 30
    ok = walk_map(td)
    if not ok(*ret):
        r = td["rows"][ret[1]]
        td["rows"][ret[1]] = r[:ret[0]] + "#" + r[ret[0] + 1:]
        print("  carved path south of", e["zid"])
    if not any(int(wp["x"]) == dxc and int(wp["y"]) == dy for wp in td["warps"]):
        td["warps"].append({"x": dxc, "y": dy, "to": e["zid"], "tx": e["w"] // 2, "ty": e["h"] - 3, "facing": "up"})
    # interior
    spots = place_npcs(e["zid"], e["kind"], e["w"], e["h"], e["name"], zone, ret, e["npcs"])
    nl = []
    for spec, (x, y) in zip(e["npcs"], spots):
        nid, spr, who, lines = spec[:4]
        for t in lines:
            if len(t) > 200: problems.append("LONG %s %d" % (nid, len(t)))
            if "—" in t: problems.append("EMDASH " + nid)
        nl.append(dict(id=nid, sprite=spr, x=x, y=y, facing="down", move="still", script=nid))
        if len(spec) > 4:
            flag, item, again = spec[4]
            script = [say(who, t) for t in lines[:-1]] + [
                {"do": "if", "flag": flag,
                 "then": [say(who, again)],
                 "else": [say(who, lines[-1]), {"do": "give_item", "item": item, "n": 1}, {"do": "set", "flag": flag}]}]
        else:
            script = [say(who, t) for t in lines]
        dlg.setdefault(e["zid"], {})[nid] = script
    landmark(OUT, e["zid"], e["name"], zone, ret, e["kind"], nl, e["w"], e["h"])

for zone, td in towns.items():
    ok = walk_map(td)
    seen = reach(td, ok)
    for e in L:
        if e["zone"] != zone: continue
        wp = [w for w in td["warps"] if w["to"] == e["zid"]][0]
        if (int(wp["x"]), int(wp["y"]) + 1) not in seen:
            problems.append("UNREACHABLE south of %s door (%d,%d)" % (e["zid"], wp["x"], wp["y"] + 1))
    json.dump(td, open(os.path.join(OUT, zone + ".json"), "w"), indent=1, ensure_ascii=False)

# interior reachability
for e in L:
    z = json.load(open(os.path.join(OUT, e["zid"] + ".json")))
    ok = walk_map(z)
    seen = reach(z, ok)
    for n in z["npcs"]:
        nb = [(n["x"] + a, n["y"] + b) for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1))]
        if not any(p in seen for p in nb):
            problems.append("NPC unreachable %s" % n["id"])

os.makedirs(DLG, exist_ok=True)
for zid, d in dlg.items():
    json.dump(d, open(os.path.join(DLG, zid + ".json"), "w"), indent=1, ensure_ascii=False)
print(len(L), "interiors;", "problems:", problems or "none")
