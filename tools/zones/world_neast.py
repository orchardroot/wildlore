"""World pass: walk-in interiors for the north-east group (Newcastle, Northumberland coast, Hadrian's Wall,
North York Moors, Whitby, York). Run: python3 tools/zones/world_neast.py data/zones
Writes interiors (landmark()), dialogue, and patches doors + warps into the existing town JSON in place."""
import sys, os, json
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from zlib import landmark

OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
DLG = os.path.join(os.path.dirname(os.path.abspath(OUT)), "dialogue")


def say(who, text):
    return {"do": "say", "who": who, "text": text}


# (zone, zid, name, (bx, by, bw, bh), kind, w, h, npcs)
# npc = (id, sprite, x, y, who, lines[, (flag, item, thanks_line)])   last line is the gift line when a gift is given
L = []
DCOL = {"nym_moorcock": 5}  # a bench sits south of the centre tile


def add(zone, zid, name, bld, kind, w, h, npcs):
    L.append((zone, zid, name, bld, kind, w, h, npcs))


# ============================== NEWCASTLE ==============================
add("newcastle", "newcastle_grainger", "Georgian Flat, Grainger Town", (4, 11, 10, 4), "home", 11, 9, [
    ("grainger_resident", "mum", 5, 3, "Mrs Armstrong", [
        "Come in, pet, and mind the stairs. They are Georgian, which means narrow and opinionated.",
        "Richard Grainger rebuilt the middle of Newcastle in the 1830s, with John Dobson and Thomas Oliver drawing the plans.",
        "Grainger Market opened in 1835, and Marks and Spencer's Original Penny Bazaar has been in there since 1895.",
        "Our bairn says canny means nice, and howay means come on. Both are true, and both are used on the stairs daily."])])
add("newcastle", "newcastle_greystreet", "Grey Street Hall", (15, 11, 12, 4), "hall", 13, 10, [
    ("greystreet_steward", "commuter", 6, 5, "Steward", [
        "Grey Street curves down the hill like it was drawn that way, because it was.",
        "It is named for Earl Grey, prime minister when the Great Reform Act passed in 1832. His monument stands at the top, 41 metres high.",
        "Yes, the tea is named after him too, though how it happened is more legend than record.",
        "A radio poll in 2002 voted this the finest street in Britain. Nobody here was surprised."])])
add("newcastle", "newcastle_bigg", "Bigg Market Deli", (4, 24, 8, 4), "cafe", 12, 9, [
    ("bigg_baker", "shopkeeper", 3, 3, "Deli Owner", [
        "Howay in, hinny! Mind the stottie, it is bigger than your head.",
        "Bigg is an old word for a hardy kind of barley, and this market sold grain long before it sold anything else.",
        "Pease pudding and ham in a stottie is proper Geordie scran. Scran is food, in case you wondered.",
        "Here, a pork pie for the road. Eat it before the chipgulls spot it."],
     ("bigg_deli_gift", "pork_pie", "Another pie? Divvent be greedy. Off you go, pet."))])
add("newcastle", "newcastle_posada", "The Crown Posada", (21, 24, 6, 4), "cafe", 12, 9, [
    ("posada_landlady", "villager_6", 3, 3, "Landlady", [
        "Mind the stained glass, it is older than most of the visitors.",
        "This little room has barely changed since the 1880s. Look up at the ornate ceiling, that is the star of the show.",
        "Posada is the Spanish word for an inn, which surprises a lot of people on a street called The Side.",
        "The Side is one of the oldest streets in Newcastle, and steep enough to build your legs for you."])])
add("newcastle", "newcastle_stjames", "St James' Park", (4, 38, 14, 6), "hall", 15, 10, [
    ("stjames_guide", "tour_guide", 7, 4, "Stadium Guide", [
        "Welcome to St James' Park, where football has been played since the 1880s.",
        "Newcastle United moved in as the home club in 1892, so this is one of the oldest grounds still in use.",
        "More than 52,000 can sit in here, and every one of them is sure they could pick a better team.",
        "The black and white stripes give the club its nickname, the Magpies, and the fans are the Toon Army."]),
    ("stjames_fan", "jogger", 11, 5, "Fan", [
        "Howay the lads! I come on days with no match, just to stand on the grass. Well, near it.",
        "Toon means town, by the way. Say it like toon, not tune. You will be forgiven once."])])
add("newcastle", "newcastle_quays", "Quayside Visitor Hut", (70, 30, 10, 4), "museum", 13, 10, [
    ("quays_keeper", "shipwright", 6, 4, "Bridge Keeper", [
        "Welcome to the Quayside. Look out of the window, the bridge is the one that blinks.",
        "The Gateshead Millennium Bridge opened in 2001 and tilts like an eyelid so tall ships can pass underneath.",
        "The Tyne Bridge opened in 1928. The firm that built it, Dorman Long, went on to build the Sydney Harbour Bridge.",
        "Seven bridges link Newcastle and Gateshead. We like bridges here, and the river has never had a quiet day."])])
add("newcastle", "newcastle_terraces", "Terrace House, Gateshead", (58, 38, 10, 4), "home", 11, 9, [
    ("terraces_resident", "villager_3", 5, 3, "Mrs Robson", [
        "Come in, pet. Mind the cat, she thinks she is the landlady.",
        "If a chipgull spots your bag of chips, you are already too slow. Tuck them under your arm and walk like you mean it.",
        "My Callum is off to the Toon with his scarf on, and his pyjama bottoms still on underneath. Bairns, eh.",
        "The Angel of the North is up the road. When I was little it was brand new, and now bairns say it has always been there."])])
add("newcastle", "newcastle_library", "Gateshead Library", (70, 38, 9, 4), "library", 13, 10, [
    ("gateshead_librarian", "villager_2", 6, 3, "Librarian", [
        "Shh. Well, quietly. Geordie quiet is nearly a whisper.",
        "Gateshead is home to the Angel of the North, by Antony Gormley, put up in 1998. It stands 20 metres tall with a 54 metre wingspan.",
        "That is wider than the wings of a Boeing 757. It is made of weathering steel, which rusts on purpose to protect itself.",
        "It stands on a hill where a colliery's pithead baths once stood. The coal went, and the angel came."])])

# ============================== NORTHUMBERLAND COAST ==============================
add("northumberland_coast", "nc_lindisfarne_castle", "Lindisfarne Castle", (63, 7, 7, 3), "castle", 13, 10, [
    ("lcastle_steward", "tour_guide", 6, 4, "Castle Steward", [
        "Welcome to Lindisfarne Castle. It began as a Tudor fort in the 1540s, built with stone from the old priory.",
        "Edward Hudson, who ran Country Life magazine, bought it in 1901 and had the architect Edwin Lutyens turn it into a holiday home.",
        "That is why it feels cosy rather than fierce. Lutyens liked a snug room as much as a good wall.",
        "Mind the tides on the way out. The causeway is covered twice a day, and the tide table is not a suggestion."])])
add("northumberland_coast", "nc_priory", "Lindisfarne Priory", (65, 18, 5, 3), "church", 11, 9, [
    ("priory_guide", "poet", 5, 3, "Heritage Guide", [
        "Welcome to Lindisfarne. St Aidan came from Iona in 635 and founded a monastery on this island.",
        "Around the year 700 the monks made the Lindisfarne Gospels, which are painted with astonishing patience. They live in the British Library now.",
        "St Cuthbert was bishop here. They say he got along with seabirds, and the eider ducks are still called Cuddy ducks after him.",
        "Viking raiders arrived in 793 and gave the monks a very bad week. The island has been peaceful for a long while since."])])
add("northumberland_coast", "nc_fenwick", "Fenwick Farm", (30, 8, 6, 3), "cottage", 11, 9, [
    ("fenwick_farmer", "farmer", 5, 3, "Farmer Charlton", [
        "Come in, come in. Wipe your boots, mind, the dog has opinions about mud.",
        "Up here we say bairn for a child, canny for nice, and clarty for muddy. The yard is very clarty today.",
        "If you spot a leveret sat still in the field, leave it be. Its mother is never far, and it is born with its eyes open.",
        "My grandad said you could tell a good day by the sound of the sea. Today it sounds like a very good day."])])
add("northumberland_coast", "nc_holburn", "Holburn Farm", (38, 18, 5, 3), "cottage", 12, 9, [
    ("holburn_wife", "mum", 5, 3, "Mrs Wilson", [
        "You must be walking the coast. Sit down, pet, and tell me nothing while I put the kettle on.",
        "The Farne Islands, just down the coast, are home to thousands of grey seals. The pups are born in autumn, all fluffy and white.",
        "If you meet a pupplash on the shore, keep your distance and your voice down. Its mum is usually watching from the waves.",
        "Our lad calls the sea the bait tin. Bait is packed lunch round here, and the sea is the biggest tin of the lot."])])
add("northumberland_coast", "nc_elwick", "Elwick Cottage", (6, 20, 6, 3), "cottage", 11, 9, [
    ("elwick_fisher", "fisherman_north", 5, 3, "Old Tom", [
        "Ey up, a visitor. Sit yourself down by the stove, hinny.",
        "Puffins nest on Inner Farne from about April and leave in August. Take a boat trip in June and they will land right beside you.",
        "Mind the terns, though. Arctic terns dive at heads. Wear a hat and look wise, it helps a little.",
        "A flask of tea, that is what the sea wants from a man. Here, take one for your walk."],
     ("elwick_tea_gift", "flask_of_tea", "I have only the one spare flask. Go on, you will manage."))])
add("northumberland_coast", "nc_budle", "Budle Farm", (36, 46, 6, 3), "cottage", 11, 9, [
    ("budle_farmer", "villager_5", 5, 3, "Mr Dodds", [
        "Welcome to Budle. We grow tatties and barley, and the sea air does the seasoning.",
        "Down the coast at Bamburgh lived Grace Darling. In 1838 she and her father rowed out in a storm to rescue survivors from the Forfarshire.",
        "Pinchkins live under stones on the mud at Budle Bay. Turn one over gently and put it back, they hold a grudge.",
        "My marra says the best view in England is Bamburgh Castle at sunrise. He has not seen much of England, but he is right."])])

# ============================== HADRIAN'S WALL ==============================
add("hadrians_wall", "hw_milecastle37", "Milecastle 37", (14, 22, 4, 2), "castle", 11, 9, [
    ("milecastle_volunteer", "hiker", 5, 3, "Wall Volunteer", [
        "Welcome to the milecastle. The Wall had one every Roman mile, with two turrets in between to watch from.",
        "Hadrian's Wall was begun in AD 122 and runs about 73 modern miles, from Wallsend on the Tyne to Bowness-on-Solway.",
        "Each milecastle had a gate through the Wall, so people and goods could cross, with soldiers checking who came and went.",
        "This one is number 37. The Romans named things by counting. Very tidy, and quite short on poetry."])])
add("hadrians_wall", "hw_granary", "The Granary", (43, 32, 6, 3), "workshop", 12, 9, [
    ("granary_curator", "shopkeeper", 5, 3, "Fort Curator", [
        "This is the granary. Spot the stone pillars under the floor? They are not for show.",
        "They held the floor up so air could flow underneath. That kept the grain dry and the rats from feeling at home.",
        "Soldiers were issued grain as part of their pay, and ground it and baked their own bread. Very good for marching on.",
        "Fort food was mostly wheat, a little meat and plenty of beans. Roman soldiers were not fussy, only well drilled."])])
add("hadrians_wall", "hw_headquarters", "Headquarters", (53, 32, 6, 3), "hall", 13, 10, [
    ("hq_guide", "tour_guide", 6, 4, "Fort Guide", [
        "This is the headquarters, which the Romans called the principia. It was the heart of the fort.",
        "In the middle was a shrine for the regimental standards, with a strongroom below where soldiers' savings were kept.",
        "Pay was kept here for safekeeping, minus charges for food and kit. Payslips are older than the Wall.",
        "The commander gave orders from here, and the soldiers were drilled outside. Not a place to forget your boots."])])
add("hadrians_wall", "hw_hospital", "The Fort Hospital", (43, 40, 6, 3), "school", 12, 9, [
    ("hospital_medicus", "villager_4", 5, 3, "Medicus", [
        "Welcome to the hospital. Roman forts often had one, with wards built around a courtyard.",
        "Army doctors had scalpels, forceps and probes made of bronze, and they were very good with bandages.",
        "They used honey and vinegar on wounds. Honey really does fight infection, so they were not as daft as they sound.",
        "Rest and fresh air were the other half of the treatment. We still say much the same, only with better beds."])])
add("hadrians_wall", "hw_barracks", "Barrack Block", (53, 40, 6, 3), "cottage", 12, 9, [
    ("barracks_soldier", "rugby_player", 6, 3, "Auxiliary Soldier", [
        "Welcome to the barracks. Eight of us share each room, and that includes the snoring.",
        "A century of about 80 men lived in a block of ten rooms, with a larger room for the centurion at the end.",
        "Down the road at Vindolanda they found wooden writing tablets. One is a birthday party invitation from about AD 100.",
        "Not everyone on the Wall was Italian, by the way. Many soldiers came from Gaul, Germany and further afield."])])
add("hadrians_wall", "hw_latrines", "The Latrines", (55, 37, 3, 2), "hall", 11, 9, [
    ("latrine_guide", "villager_1", 5, 3, "Latrine Guide", [
        "Sorry about the smell. Well, there is none. Two thousand years has taken care of that.",
        "Soldiers sat in a row over a channel of flowing water. No doors, no walls, and a surprising amount of chat.",
        "For wiping, they used a sponge on a stick, rinsed in a channel of water and shared. Please do not ask the next question.",
        "The best-preserved Roman latrine in Britain is at Housesteads. It is a very good reason to visit, strange as it sounds."])])

# ============================== NORTH YORK MOORS ==============================
add("north_york_moors", "nym_signalbox", "Goathland Signal Box", (40, 36, 4, 2), "workshop", 11, 9, [
    ("signalman", "rail_guard", 5, 3, "Signalman", [
        "Mind the levers, they bite. Each one moves a signal or a set of points somewhere along the line.",
        "This railway began in 1836 as the Whitby and Pickering Railway, with George Stephenson as engineer. The first trains were pulled by horses.",
        "Steam came along in 1847, and these days the North York Moors Railway runs heritage steam trains through the heather.",
        "Goathland Station played Hogsmeade in the first Harry Potter film. We try not to let it go to our heads."])])
add("north_york_moors", "nym_moorfarm", "Moor Farm", (8, 30, 6, 3), "cottage", 12, 9, [
    ("moorfarm_farmer", "farmer", 5, 3, "Farmer Dale", [
        "Ey up. Come in, but leave your boots by the door, there is nowt worse than moor mud on a clean floor.",
        "Nowt means nothing, owt means anything, and a gimmer is a young ewe. You will get used to it.",
        "Keep to the paths in the heather in summer. Zigzlets like to sunbathe where you least expect them.",
        "My mother bakes parkin every November. Ginger, oats and treacle, and it gets better after a week. Take a slice."],
     ("moorfarm_parkin_gift", "parkin", "You have had your slice. The rest is for bonfire night, so hands off."))])
add("north_york_moors", "nym_rosedale", "Rosedale Farm", (66, 22, 6, 3), "cottage", 11, 9, [
    ("rosedale_wife", "villager_5", 5, 3, "Mrs Hartley", [
        "Welcome to Rosedale. The dale was not always this quiet. In the 1800s it was full of ironstone mines.",
        "A railway carried the ore over the moor, and the old chimney of the kilns still stands as a reminder.",
        "Down at the beck you might see a dipling bobbing on a stone, then walking straight under the water. We never tire of it.",
        "Our Joe says it is mardy weather, which means grumpy, when it drizzles all day. He says it a lot. He is a mardy lad."])])
add("north_york_moors", "nym_moorcock", "The Moorcock Inn", (60, 48, 9, 3), "cafe", 13, 10, [
    ("moorcock_landlord", "shopkeeper", 3, 3, "Landlord", [
        "Welcome in, you look like you have walked a fair way. The North York Moors will do that to a person.",
        "The National Park was made in 1952, and it holds one of the biggest stretches of heather moorland in England.",
        "In August and September the whole moor goes purple. There is also a Roman road across Wheeldale Moor, called Wade's Causeway.",
        "Here, a Yorkshire pudding. It is eaten first with gravy, to fill you up so you want less beef. Tradition, and good sense."],
     ("moorcock_yorkie_gift", "yorkshire_pudding", "One is plenty, or I will have none for the Sunday crowd. Off with you."))])

# ============================== WHITBY ==============================
add("whitby", "whitby_stmary", "St Mary's Church", (41, 9, 5, 3), "church", 13, 10, [
    ("stmary_verger", "choir_singer", 6, 3, "Verger", [
        "Welcome. You climbed the 199 steps, yes? Everyone counts them, and everyone gets a different number.",
        "Parts of this church date from the 1100s. Inside are box pews and a tall pulpit with three levels, and it feels like a ship.",
        "Bram Stoker stayed in Whitby in 1890 and used the churchyard in Dracula, which came out in 1897. We do not mind the visitors.",
        "The view is the best in town. On a clear day you can see the harbour, the abbey and a great deal of sea."])])
add("whitby", "whitby_henrietta", "Henrietta Street Cottage", (48, 29, 8, 3), "cottage", 11, 9, [
    ("henrietta_resident", "villager_3", 5, 3, "Mrs Pickering", [
        "Come in, bairn. Sit by the fire. The wind off the harbour finds every gap in this house.",
        "Henrietta Street sits at the foot of the abbey steps, and the abbey above us is over 1,300 years old.",
        "If a jetling is eyeing your shiny things, give it something small and bright instead. It will forgive you, mostly.",
        "Our Billy says mither when he means bother. He mithers me every day, bless him, and I would not swap him."])])
add("whitby", "whitby_church", "Church Street Cottage", (48, 34, 8, 3), "cottage", 12, 9, [
    ("church_fisher", "fisher", 5, 3, "Skipper Storr", [
        "Ey up, lad or lass. Church Street is the old road to the steps, and the cobbles have seen a lot of boots.",
        "Whitby was a whaling port, and its ships went hunting from the 1750s into the 1830s. That is long gone, thank goodness.",
        "Chipgulls will have your chips off the harbour wall before you blink. Eat with your back to the wall.",
        "I say chuffed for pleased. I was chuffed when my granddaughter caught her first crab. Pinchkin, that was, and not best pleased."])])
add("whitby", "whitby_flowergate", "Flowergate Terrace", (4, 35, 8, 4), "home", 11, 9, [
    ("flowergate_lass", "mum", 5, 3, "Mrs Laidler", [
        "Come in, lovey. Whitby jet is in every window up this street, and I have a bit of it in my pocket.",
        "Queen Victoria wore jet jewellery after Prince Albert died, and it became fashionable. Over a thousand people worked in the trade here.",
        "Jet is fossilised wood from monkey puzzle trees, millions of years old. You can find it on the beach after a storm.",
        "I take my dog to the pier every morning. If a dolphlet breaks the water, she barks like she invented it."])])
add("whitby", "whitby_smugglers", "Smugglers' Alley Hall", (41, 38, 14, 4), "hall", 15, 10, [
    ("smuggler_storyteller", "sailor", 7, 4, "Storyteller", [
        "Pull up a bench. In the 1700s smuggling along the Yorkshire coast was a busy trade in tea, silk and other taxed goods.",
        "Taxes were high, so folk found ways round them, with hidden cupboards, cellars and false bottoms in chests.",
        "Robin Hood's Bay, down the coast, tells how a parcel could cross the whole village through connected houses, without touching the street.",
        "The revenue men were always one step behind. They had the law, and the smugglers had the better knowledge of the tide."])])
add("whitby", "whitby_cook", "Captain Cook Memorial Museum", (17, 25, 8, 4), "museum", 13, 10, [
    ("cook_guide", "tour_guide", 6, 4, "Museum Guide", [
        "Welcome to Captain Cook's Whitby lodgings. This was the home of John Walker, a Quaker shipowner.",
        "James Cook came to Whitby as an apprentice in 1746, and slept in the attic. He learned seamanship on Whitby colliers.",
        "His ship Endeavour was a Whitby collier, built here in 1764 as the Earl of Pembroke. They have flat bottoms and deep holds, ideal for exploring.",
        "She sailed in 1768 to Tahiti, then charted New Zealand and the east coast of Australia. Not bad for a coal boat."])])
add("whitby", "whitby_harbour", "The Harbour Inn", (4, 41, 8, 4), "cafe", 13, 10, [
    ("harbour_landlord", "fisherman_north", 3, 3, "Landlord", [
        "Welcome in, and mind the nets. The harbour has been the heart of Whitby for a thousand years.",
        "The swing bridge over the Esk opens to let boats through. When it opens, everybody stops to watch. Nobody ever tires of it.",
        "On the West Cliff stands an arch made of whale jawbones, a reminder that Whitby was once a whaling port.",
        "Fish and chips taste best on the harbour wall. Mind the gulls, though. They have been practising."])])
add("whitby", "whitby_pannett", "Pannett Park Museum", (17, 45, 8, 3), "museum", 15, 10, [
    ("pannett_curator", "prof_garside", 7, 4, "Curator", [
        "Welcome to the museum. Whitby's cliffs are famous for fossils, about 180 million years old, from when this was a warm sea.",
        "People here have found ammonites, which are coiled shells, and ancient sea reptiles called ichthyosaurs. Pay attention to the rocks.",
        "Three ammonites even appear on Whitby's coat of arms. The old story says St Hilda turned a plague of snakes to stone.",
        "Our jet collection shows what Queen Victoria made fashionable. It is shiny, black, and very, very old wood."]),
    ("pannett_volunteer", "student", 4, 5, "Volunteer", [
        "I look after the fossil drawers. The trick is not to sneeze near anything labelled Jurassic.",
        "The beach below the cliff is a good place to find them, but stay away from the cliff base. Check the tides first."])])

# ============================== YORK ==============================
add("york", "york_bootham", "Bootham Bar", (11, 11, 3, 2), "castle", 11, 9, [
    ("bootham_gatekeeper", "villager_6", 5, 3, "Gatekeeper", [
        "Welcome to Bootham Bar. In York, a bar is a gate, and a gate is a street. It confuses visitors to this day.",
        "This gate stands on the site of a Roman gate into the fortress of Eboracum. Most of the stone is medieval, with some Norman bits.",
        "York's city walls run for about two miles, and you can walk almost the whole way around on top of them.",
        "Mind your head on the way up. Medieval folk were shorter, and this archway did not plan for visitors."])])
add("york", "york_micklegate_bar", "Micklegate Bar", (11, 17, 3, 2), "castle", 11, 9, [
    ("micklegate_keeper", "villager_2", 5, 3, "Bar Keeper", [
        "Micklegate Bar is the grandest gate in York, because it faces the road to London.",
        "Tradition says that when a monarch visits York, they stop here and ask the Lord Mayor for permission to enter the city.",
        "The Lord Mayor offers the Sword of State, and the monarch touches it. Then they are welcomed in.",
        "Micklegate comes from the Old Norse for great street. The Vikings named it, and nobody has improved on it since."])])
add("york", "york_walmgate", "Walmgate Bar", (61, 27, 3, 2), "castle", 11, 9, [
    ("walmgate_warden", "poet", 5, 3, "Bar Warden", [
        "Welcome to Walmgate Bar. This one is special. It is the only city gate in England still to have its barbican.",
        "A barbican is an extra walled passage in front of the gate, so anyone arriving had to pass under the guards' eyes before they got in.",
        "There is a timber-framed house built onto the back. People lived in the gatehouse for centuries, with a view of the street.",
        "If you walk the walls, this is one of the best places to stop. You can see the whole barbican from the top."])])
add("york", "york_fishergate", "Fishergate Bar", (27, 53, 3, 2), "castle", 11, 9, [
    ("fishergate_guard", "student", 5, 3, "Gate Guide", [
        "Welcome to Fishergate Bar. This one has had a quiet life, mostly with its doors closed.",
        "It was walled up for centuries after a rebellion in the 1480s, and reopened in the 1800s to let traffic through.",
        "York has four main bars, and several smaller gates. Count them on a walk and you can claim you saw the whole set.",
        "The old name comes from the fishermen who once worked the river nearby. The walls have been listening to fish tales for ages."])])
add("york", "york_multangular", "Multangular Tower", (21, 12, 5, 3), "castle", 12, 9, [
    ("multangular_guide", "tour_guide", 5, 3, "Museum Gardens Guide", [
        "This is the Multangular Tower, a corner of the Roman fortress of Eboracum. Built around AD 300, it is nearly 1,700 years old.",
        "The lower stonework is Roman, and the upper part is medieval. You can see the join if you look hard enough.",
        "In AD 306, Constantine was proclaimed Roman emperor right here in York. He went on to rule the whole empire.",
        "Eboracum was one of the most important places in Roman Britain. Now it has better teashops."])])
add("york", "york_merchants", "Merchant Adventurers' Hall", (50, 12, 10, 5), "hall", 15, 10, [
    ("merchants_steward", "shopkeeper", 7, 4, "Hall Steward", [
        "Welcome to the Merchant Adventurers' Hall, built between 1357 and 1361 by a guild of York traders.",
        "It is one of the best-preserved medieval guild halls in Britain. Look up at the great timber roof, it is a wonder.",
        "The undercroft below was used as a hospital and a chapel. The guild looked after its members and the poor too.",
        "The guild is still going. Medieval trade organisations had a good grip, and a better dress code."])])
add("york", "york_shambles", "Shambles Sweet Shop", (34, 34, 6, 4), "cafe", 12, 9, [
    ("shambles_shopkeeper", "villager_4", 3, 3, "Shopkeeper", [
        "Welcome to the Shambles. It is thought to be mentioned in the Domesday Book of 1086, which makes it older than most of the street.",
        "Shambles comes from shamels, the shelves where butchers laid out meat. The overhanging upper floors kept the street cool and shaded.",
        "Look up. The top floors lean so close together that neighbours could nearly shake hands across the street.",
        "Visitors say it looks like a wizard's alley. We smile, and sell more fudge."])])
add("york", "york_house_a", "Shambles Flat", (41, 34, 6, 4), "home", 11, 9, [
    ("house_a_resident", "villager_1", 5, 3, "Mr Ibbotson", [
        "Ey up, come in. Mind your head on the beam, it has had better men than you.",
        "In York, a narrow alley is a snickelway. A man named Mark W. Jones invented the word in 1983 for his book of walks.",
        "Round here a ginnel or a snicket is the same thing, and there are dozens of them. I use them all to dodge the crowds.",
        "If a peregrin is on the Minster tower, stop and watch. They love a tall tower, and they are the fastest bird in the world."])])
add("york", "york_house_b", "Tudor House, York", (48, 34, 5, 4), "home", 11, 9, [
    ("house_b_resident", "villager_5", 5, 3, "Mrs Calvert", [
        "Come in, love. Mind the floor, it slopes. Everything in York slopes in the end.",
        "The Vikings captured York in 866 and called it Jorvik. Archaeologists found a whole Viking street under Coppergate in the 1970s.",
        "Nowt means nothing and owt means anything. My husband says nowt when I ask what is for tea, which is not an answer.",
        "The grizzlets in the garden steal the bird seed. I have stopped being angry. They have better manners than the pigeons."])])
add("york", "york_house_c", "Terrace Home, York", (54, 34, 5, 4), "home", 11, 9, [
    ("house_c_resident", "mum", 5, 3, "Mrs Hill", [
        "Come in, pet. You can smell the chocolate on the wind, can you not? York is the city of sweets.",
        "Rowntree's made Kit Kat here. It began in 1935 as a Chocolate Crisp, and got the name in 1937.",
        "Terry's of York made the Chocolate Orange in 1932. Whack it on the table, and every orange has its own piece.",
        "My bairn feeds the starlets crumbs from the window. At dusk they gather in the thousands, and it is lovely."])])
add("york", "york_micklegate", "Micklegate Townhouse", (18, 34, 11, 4), "home", 13, 10, [
    ("micklegate_resident", "villager_3", 6, 3, "Miss Thackray", [
        "Welcome to Micklegate, dear. It is Old Norse for great street. The Vikings had a way with names.",
        "In York a gate is a street and a bar is a gate. Stonegate, Petergate, Coney Street, I get them mixed up myself.",
        "At dusk, flittermice come out round the old walls. If you look up near a street lamp, you might see them swoop.",
        "I have lived on this street for fifty years. Every winter I say I will move somewhere warmer, and every spring I forget."])])
add("york", "york_bishy", "Bishy Road Deli", (18, 40, 11, 4), "cafe", 13, 10, [
    ("bishy_owner", "shopkeeper", 4, 3, "Deli Owner", [
        "Welcome to Bishy Road. Its proper name is Bishopthorpe Road, but nobody has used that since before I was born.",
        "York is a chocolate city. Kit Kat and Terry's Chocolate Orange were made here, and the smell used to drift across town.",
        "The street is full of small independent shops, and they all know each other. Gossip travels faster than the post.",
        "Here, a cup of tea. It is on the house. Do not tell the Rowntrees."],
     ("bishy_tea_gift", "cup_of_tea", "That is one cup each. Come back tomorrow."))])
add("york", "york_nrm", "National Railway Museum", (20, 53, 6, 3), "museum", 15, 10, [
    ("nrm_guide", "rail_guard", 7, 4, "Museum Guide", [
        "Welcome to the National Railway Museum. Admission is free, and that is not a trap.",
        "Mallard is here. In 1938 she set the world speed record for steam, at 126 miles an hour. It still stands.",
        "York became a railway hub in the 1840s, thanks to George Hudson, who was called the Railway King.",
        "We have royal carriages, too. Queen Victoria's has a proper bedroom. It is much grander than a bunk on the sleeper."])])


# ---------------------------------------------------------------------------------------------
def walkable_chars(d):
    ok = set(".,#=:sfw_D|+")
    for k, v in d.get("legend_extra", {}).items():
        if v.get("tile") in ("grass", "tall_grass", "path", "road", "cobbles", "sand", "flowers"):
            ok.add(k)
    return ok


def reachable(d, start, goal):
    ok = walkable_chars(d)
    rows = d["rows"]
    block = {(p["x"], p["y"]) for p in d["props"] if p["type"] != "building"}
    seen = {start}
    st = [start]
    while st:
        x, y = st.pop()
        if (x, y) == goal:
            return True
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, ny = x + dx, y + dy
            if 0 <= ny < len(rows) and 0 <= nx < len(rows[0]) and (nx, ny) not in seen \
                    and rows[ny][nx] in ok and (nx, ny) not in block:
                seen.add((nx, ny))
                st.append((nx, ny))
    return False


def free_spot(z, px, py, taken):
    w, h = z.w, z.h
    block = {(p["x"], p["y"]) for p in z.d["props"]}
    best = None
    for y in range(2, h - 3):
        for x in range(2, w - 2):
            if z.g[y][x] not in "|+" or (x, y) in block or (x, y) in taken:
                continue
            if any(abs(x - tx) + abs(y - ty) <= 1 for tx, ty in taken):
                continue
            dist = abs(x - px) + abs(y - py)
            if best is None or dist < best[0]:
                best = (dist, x, y)
    return best[1], best[2]


towns = {}
dlg = {}
for zone, zid, name, (bx, by, bw, bh), kind, w, h, npcs in L:
    tj = os.path.join(OUT, zone + ".json")
    if zone not in towns:
        towns[zone] = json.load(open(tj))
    td = towns[zone]
    dcol = DCOL.get(zid, bw // 2)
    dx, dy = bx + dcol, by + bh - 1
    rows = td["rows"]
    assert rows[dy][dx] in "BD", (zid, rows[dy][dx])
    ok = walkable_chars(td)
    if rows[dy][bx:bx + bw].count("D") == 0:
        r = list(rows[dy]); r[dx] = "D"; rows[dy] = "".join(r)
        if rows[dy + 1][dx] not in ok:
            r = list(rows[dy + 1]); r[dx] = "#"; rows[dy + 1] = "".join(r)
        if not any(wp["x"] == dx and wp["y"] == dy for wp in td["warps"]):
            td["warps"].append({"x": dx, "y": dy, "to": zid, "tx": w // 2, "ty": h - 3, "facing": "up"})
    assert not any(n["x"] == dx and n["y"] == dy + 1 for n in td["npcs"]), zid
    if not reachable(td, tuple(td["spawn"]), (dx, dy + 1)):
        print("UNREACHABLE doorstep", zid, dx, dy + 1)
    z0 = landmark(OUT, zid, name, zone, (dx, dy + 1), kind, [], w, h)
    taken = {(w // 2, h - 3)}
    nl = []
    for n in npcs:
        nid, spr, px, py, who, lines = n[:6]
        x, y = free_spot(z0, px, py, taken)
        taken.add((x, y))
        nl.append(dict(id=nid, sprite=spr, x=x, y=y, facing="down", move="still", script=nid))
        assert all(len(t) < 200 for t in lines), (nid, [len(t) for t in lines])
        if len(n) > 6:
            flag, item, thanks = n[6]
            script = [say(who, t) for t in lines[:-1]] + [
                {"do": "if", "flag": flag,
                 "then": [say(who, thanks)],
                 "else": [say(who, lines[-1]), {"do": "give_item", "item": item, "n": 1}, {"do": "set", "flag": flag}]}]
        else:
            script = [say(who, t) for t in lines]
        dlg.setdefault(zid, {})[nid] = script
    landmark(OUT, zid, name, zone, (dx, dy + 1), kind, nl, w, h)

for zone, td in towns.items():
    json.dump(td, open(os.path.join(OUT, zone + ".json"), "w"), indent=1, ensure_ascii=False)
os.makedirs(DLG, exist_ok=True)
for zid, d in dlg.items():
    json.dump(d, open(os.path.join(DLG, zid + ".json"), "w"), indent=1, ensure_ascii=False)
print(len(L), "interiors")
