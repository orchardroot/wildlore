"""World pass (Wildlore 1.1), group scsouth: walk-in interiors for Glasgow, Edinburgh, Central Belt, Cairnryan, Galloway.
Run: python3 tools/zones/world_scsouth.py data/zones
Writes the interiors, their dialogue, and patches the town JSON in place (door tile + warp). Safe to re-run."""
import sys, os, json
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from zlib import landmark

OUT = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
DLG = os.path.join(os.path.dirname(os.path.abspath(OUT)), "dialogue")
WALK = set(".,#=:sfw_+|")


def say(who, text):
    return {"do": "say", "who": who, "text": text}


# (zid, name, town, door(x,y), kind, npcs[(short, sprite, who, lines[, (flag, item, n)])], w, h)
L = []


def add(zid, name, town, door, kind, npcs, w=13, h=10):
    L.append((zid, name, town, door, kind, npcs, w, h))


# ------------------------------------------------------------------ GLASGOW
add("glasgow_cathedral", "Glasgow Cathedral", "glasgow", (65, 19), "church", [
    ("verger", "choir_singer", "Verger", [
        "Welcome to Glasgow Cathedral, also called the High Kirk of Glasgow or St Mungo's. Quiet feet, please. The stones echo.",
        "Most of what you see went up in the 1200s. It is the only medieval cathedral on the Scottish mainland to come through the Reformation with its roof on.",
        "St Mungo, the city's patron saint, is buried in the lower church, among a forest of stone pillars. Pilgrims have come to his tomb for well over a thousand years."]),
    ("visitor", "tour_guide", "Visitor", [
        "The ring in the fish is the best bit of Mungo's story. A queen lost her ring, and it turned up inside a salmon. That is why the city's coat of arms has a fish with a ring.",
        "The Necropolis is next door, a hill of Victorian graves and statues. Spooky? Not really. Mostly it has very good views."])], 15, 11)
add("glasgow_merchant", "Merchant City Rooms", "glasgow", (53, 26), "museum", [
    ("guide", "tour_guide", "Guide", [
        "Welcome to the Merchant City. In the 1700s the Tobacco Lords built their grand townhouses and warehouses on these streets.",
        "By the 1760s Glasgow was Britain's biggest tobacco port. Ships sailed from the Clyde to Virginia and Maryland, and the Clyde is a handy bit closer to America than London.",
        "That fortune rested on tobacco grown by enslaved people. Buchanan, Glassford and Ingram Streets are named for tobacco merchants. Glasgow talks about that openly now."]),
    ("volunteer", "poet", "Volunteer", [
        "Up the road, the Duke of Wellington statue wears a traffic cone. The council once planned to raise the plinth to stop it. Glaswegians took that as a challenge, and the plan was dropped."])])
add("glasgow_science", "Glasgow Science Centre", "glasgow", (33, 50), "museum", [
    ("explainer", "student", "Explainer", [
        "Welcome to Glasgow Science Centre, on the Clyde at Pacific Quay. It opened in 2001. Touch absolutely everything.",
        "The Glasgow Tower outside is 127 metres tall and can turn right round to face the wind. It is the tallest fully rotating freestanding tower in the world.",
        "Inside there is a planetarium, an IMAX cinema and a lot of buttons. Pressing them is the whole point."]),
    ("dad", "villager_4", "Dad", [
        "My bairn dragged me here for the planetarium. I came out knowing the names of five stars, and one of them was the Sun."])], 15, 11)

add("glasgow_home_a", "The MacKays' Flat", "glasgow", (38, 7), "home", [
    ("mrmackay", "mum", "Mrs MacKay", [
        "Come in, come in, wipe your feet. In a Glasgow tenement the shared entrance is the close, and the back garden is the back green.",
        "Wee word for you: gallus. It means bold, cheeky, with a bit of a swagger. Said with a grin, it is the highest compliment.",
        "Here, a bit of tablet. It is butter, sugar and condensed milk, and one square is never enough."],
        ("glasgow_home_a_gift", "tablet", 1))])
add("glasgow_home_b", "Mr Gillespie's House", "glasgow", (66, 7), "home", [
    ("gillespie", "villager_6", "Mr Gillespie", [
        "Glasgow's Subway opened in 1896. It is the third oldest underground railway in the world, after London and Budapest. We call it the Clockwork Orange.",
        "Dreich means dull, grey and drizzly. Today is dreich. So was yesterday.",
        "If you are out after dark, watch the bins. Binfoxes only turn up at dusk and night, and they know your bin day better than you do."])])
add("glasgow_home_c", "Aileen and Rory's Flat", "glasgow", (8, 49), "home", [
    ("aileen", "villager_2", "Aileen", [
        "My granda worked the Clyde shipyards. The Queen Mary was launched on the Clyde in 1934, and the QE2 in 1967. He claimed he held the tea.",
        "Stooshie is a Scots word for a fuss or an uproar. Rory's bedroom is a permanent stooshie."]),
    ("rory", "student", "Rory", [
        "A cooplet pinched a chip right out of my hand. They come out in the drizzle. Hold on to your chips."])])
add("glasgow_home_d", "The Ahmeds' Flat", "glasgow", (50, 49), "home", [
    ("mrahmed", "villager_3", "Mr Ahmed", [
        "A Glasgow restaurant claims to have invented the chicken tikka masala in the 1970s. Nobody can prove it, and that has never stopped the argument.",
        "My brother is peely-wally today, which means pale and a bit poorly. He says he is fine. He is not fine.",
        "Starlets chatter at dawn and dusk and copy whatever they hear. Mine does my phone ringtone. I keep answering the window."])])
add("glasgow_home_e", "Granny Isa's Flat", "glasgow", (61, 49), "home", [
    ("isa", "villager_5", "Granny Isa", [
        "Glaschu is said to mean the dear green place, and we have more than ninety parks and gardens. I try to count them on Sundays.",
        "Come and blether, which is Scots for a good long chat. Put the kettle on, hen.",
        "Sootwings like the fog and the drizzle. They roost in the old stonework, and they have never once apologised for the soot."])])

# ------------------------------------------------------------------ EDINBURGH
add("edinburgh_scott", "Scott Monument", "edinburgh", (27, 15), "museum", [
    ("guide", "tour_guide", "Guide", [
        "Welcome to the Scott Monument. Sir Walter Scott sits under the arches with his deerhound Maida, carved from a single block of Carrara marble.",
        "George Meikle Kemp, a self-taught joiner, won the contest to design it. He drowned in the Union Canal in 1844 and never saw it finished. It opened in 1846.",
        "There are 287 steps to the top, and 64 little statues of Scott's characters round the tower. Bring good knees."]),
    ("reader", "student", "Reader", [
        "I counted the steps twice and got two different answers. Scott would call that a plot twist."])], 11, 9)
add("edinburgh_castle", "Edinburgh Castle", "edinburgh", (19, 40), "castle", [
    ("guide", "tour_guide", "Castle Guide", [
        "Welcome to Edinburgh Castle. Mind the cannon, she is older than your grandparents' grandparents.",
        "In the Crown Room lie the Honours of Scotland, a crown, a sceptre and a sword. They are the oldest crown jewels in the British Isles.",
        "They were locked in a chest in 1707 and forgotten. In 1818 Sir Walter Scott helped lead the search that found them again.",
        "St Margaret's Chapel, up the top, dates from around 1130. It is the oldest building in Edinburgh."]),
    ("piper", "piper", "Piper", [
        "Mons Meg, the big old cannon, is from the 1400s and fired stone balls half a metre across. Her barrel burst in 1680, so she retired.",
        "Practising on the Esplanade keeps the wind out of my sporran. I mean the wind in my pipes."])], 15, 11)
add("edinburgh_stgiles", "St Giles' Cathedral", "edinburgh", (40, 38), "church", [
    ("verger", "choir_singer", "Verger", [
        "Welcome to St Giles'. Strictly it is the High Kirk of Edinburgh, and everyone calls it a cathedral anyway. It was one, briefly, under Charles I.",
        "The crown-shaped spire dates from around 1500. John Knox, the firebrand preacher of the Reformation, was minister here in the 1560s.",
        "The Thistle Chapel, finished in 1911, has an angel playing the bagpipes carved in stone. See if you can find her."]),
    ("visitor", "villager_1", "Visitor", [
        "Tradition says that in 1637 a woman called Jenny Geddes threw her stool at a minister reading from a new prayer book. I say she had a very good arm."])], 15, 11)
add("edinburgh_camera", "Camera Obscura", "edinburgh", (48, 38), "museum", [
    ("guide", "tour_guide", "Guide", [
        "Step into the dark, please, and let your eyes adjust.",
        "A lens and a mirror at the top of the Outlook Tower throw a live picture of the city onto this round white table. It has been doing that since 1853.",
        "No screen, no battery. Just light, a mirror and a very patient Edinburgh sky."]),
    ("visitor", "student", "Visitor", [
        "I held a sheet of paper over the picture and a tiny bus drove across my hand. I am never washing it."])], 11, 9)
add("edinburgh_maryking", "Mary King's Close", "edinburgh", (36, 48), "hall", [
    ("guide", "tour_guide", "Guide", [
        "Welcome to Mary King's Close. Watch your head. The ceilings are older than the building above them.",
        "A close is a narrow lane between tall tenements, and this one is named for a 17th-century resident, Mary King.",
        "When the Royal Exchange, now the City Chambers, was built in the 1750s, the upper floors were taken down and the lower streets were built over. It opened to visitors in 2003."]),
    ("historian", "villager_2", "Historian", [
        "The ghost stories are mostly modern. The real people here were ordinary Edinburgh families, packed in tight, with the best view of a very steep street."])], 13, 10)
add("edinburgh_holyrood", "Palace of Holyroodhouse", "edinburgh", (56, 43), "hall", [
    ("steward", "tour_guide", "Steward", [
        "Welcome to Holyroodhouse, the King's official home in Scotland, at the foot of the Royal Mile.",
        "Mary, Queen of Scots, lived here from 1561 to 1567. Her rooms are in the oldest tower.",
        "The Great Gallery has 89 portraits of Scottish kings, painted in the 1680s. Not all of the kings were real. Some were enthusiastic guesses.",
        "Next door are the ruins of Holyrood Abbey, founded in 1128. Legend says King David saw a stag with a cross between its antlers. Hence Holy Rood."]),
    ("gardener", "farmer", "Gardener", [
        "Arthur's Seat is just behind us, an extinct volcano with a view. The hedges here have more opinions than I do."])], 15, 11)
add("edinburgh_grassmarket", "Grassmarket Traders' Hall", "edinburgh", (9, 59), "hall", [
    ("trader", "shopkeeper", "Trader", [
        "Welcome! Cattle and horses were sold in the Grassmarket from 1477, and the market ran for centuries under the Castle.",
        "Greyfriars Bobby is just up the road. He was a terrier who sat by his master's grave for fourteen years. He has his own statue on Candlemaker Row.",
        "Folk rub the statue's nose for luck. It is a bit shiny. Be kind to the nose."]),
    ("wool", "villager_4", "Wool Seller", [
        "Oxter is a Scots word for armpit. It is the warmest place for a cold lamb. Do not ask how I know."])], 13, 10)
add("edinburgh_lastdrop", "The Last Drop Tea Room", "edinburgh", (19, 59), "cafe", [
    ("waitress", "mum", "Waitress", [
        "Pull up a chair! Tea, scones and a history lesson, free with every order.",
        "The Last Drop is named for the old gallows in the Grassmarket. Public hangings here ended in 1784.",
        "Maggie Dickson was hanged here in 1724, woke up in her coffin on the cart, and the law let her go. She lived on for decades. They called her Half-hangit Maggie."]),
    ("regular", "villager_1", "Regular", [
        "Maggie sold salt in the streets afterwards. Best customer service in town, I imagine."])], 13, 10)

add("edinburgh_home_a", "The Hendersons' Flat", "edinburgh", (8, 7), "home", [
    ("mrshenderson", "villager_3", "Mrs Henderson", [
        "Haar is the cold sea fog that rolls in off the Forth. One minute sunshine, the next you cannot see your own scone.",
        "My wee grandson thinks the Castle follows him around. It does not. It is just very big and very tall.",
        "Hootlets only come out at night in the gardens. Listen for the twit-twoo, and do not argue with them. They are in charge."])])
add("edinburgh_home_b", "Mr Ferguson's Flat", "edinburgh", (40, 7), "home", [
    ("ferguson", "villager_1", "Mr Ferguson", [
        "Gardyloo! That was the old cry from an upstairs window before someone emptied a bucket in the street. It comes from the French for watch out for the water.",
        "The Old Town built up and up because it was squeezed inside the city wall. Some of the tenements climbed ten or eleven storeys, long before anyone said skyscraper."])])
add("edinburgh_home_c", "The Murrays' House", "edinburgh", (60, 7), "home", [
    ("murray", "student", "Murray", [
        "Every August the Fringe fills the city. It began in 1947 and is now the biggest arts festival in the world. I have been in the audience for nine shows and a street juggler.",
        "Wheesht! Which is Scots for hush. My wee brother is rehearsing his own juggling.",
        "Here, take some cranachan, toasted oats, cream and raspberries. Mum makes it. I only eat it."],
        ("edinburgh_home_c_gift", "cranachan", 1))])
add("edinburgh_home_d", "Mrs Rintoul's House", "edinburgh", (44, 48), "home", [
    ("rintoul", "villager_5", "Mrs Rintoul", [
        "People used to say a hopeless job was like painting the Forth Bridge, because it never ended. In 2011 they finished with a coating that should last about twenty-five years.",
        "Railsparks hang about the grass by the railway lines at Waverley. They whistle in the wind, just like the bridge they were born from."])])
add("edinburgh_home_e", "Archie's Gran's Flat", "edinburgh", (27, 59), "home", [
    ("gran", "villager_6", "Gran", [
        "Archie, stop looking glaikit. That means blank and a bit gormless, dear. Archie has a very good glaikit look.",
        "Every day but Sunday, the One O'Clock Gun fires from the Castle. We have never once had to set a clock by anything else."]),
    ("archie", "student", "Archie", [
        "Gran says the gun is an Edinburgh tradition. I say it is an alarm clock for the whole city."])])

# ------------------------------------------------------------------ CENTRAL BELT
add("central_belt_wheel", "Falkirk Wheel Visitor Centre", "central_belt", (62, 8), "museum", [
    ("guide", "canal_boater", "Wheel Guide", [
        "Welcome to the Falkirk Wheel! It joins the Forth and Clyde Canal to the Union Canal, twenty-four metres higher up.",
        "It opened in 2002 and replaced eleven locks that were filled in during the 1930s. A boat needed most of a day. Now it takes about five minutes.",
        "The wheel turns on about as much electricity as boiling eight kettles. A boat weighs exactly what the water it pushes aside weighs, so both gondolas stay balanced."]),
    ("kid", "student", "Visitor", [
        "Dad says the Wheel is like a Ferris wheel for boats. Mum says it is engineering. I say they are both right."])], 13, 10)
add("central_belt_kelpies", "Kelpies Visitor Centre", "central_belt", (10, 35), "museum", [
    ("guide", "tour_guide", "Guide", [
        "The Kelpies are thirty metres tall, made of stainless steel, and were unveiled in 2013. They stand in Helix Park beside the canal.",
        "Sculptor Andy Scott based them on two real Clydesdale horses, Duke and Baron.",
        "In the old tales a kelpie is a water spirit who lures travellers. Ours only lure photographers."]),
    ("horseman", "farmer", "Horse Lover", [
        "Clydesdales get their name from Clydesdale, the valley of the Clyde. They pulled barges, ploughs and carts, and they are very good at being enormous."])], 11, 9)
add("central_belt_linlithgow", "Linlithgow Palace", "central_belt", (45, 35), "castle", [
    ("steward", "tour_guide", "Steward", [
        "Welcome to Linlithgow Palace. The roof is missing, so the weather comes free with the tour.",
        "Mary, Queen of Scots, was born here on 8 December 1542. Her father, James V, was born here too.",
        "The courtyard fountain dates from around 1538 and is among the finest in Scotland.",
        "The palace burned in 1746, reportedly by accident, while government troops were staying here. Nobody has put the roof back since."]),
    ("visitor", "birdwatcher", "Birdwatcher", [
        "The loch below is Linlithgow Loch. Swans, ducks and a heron who watches me eat. Stalklets stand still in the shallows pretending to be sticks."])], 15, 11)
add("central_belt_cottage", "Canal Cottage", "central_belt", (27, 39), "cottage", [
    ("bessie", "canal_boater", "Bessie", [
        "Falkirk folk are called the Bairns. The old saying goes: better meddle wi' the de'il than the bairns o' Falkirk. We were very proud of that.",
        "A stoater is something excellent. A hot roll on a cold morning is a stoater.",
        "Brocklings dig round the canal bank on drizzly evenings. Keep your bin lids shut and they will leave your garden be. Take a flask for the walk."],
        ("central_belt_cottage_gift", "cup_of_tea", 1))], 11, 9)

# ------------------------------------------------------------------ CAIRNRYAN
add("cairnryan_ferry", "Ferry Terminal", "cairnryan", (24, 26), "hall", [
    ("clerk", "commuter", "Ferry Clerk", [
        "Ferry Terminal. Tickets for Belfast and Larne. The ship is the bit you will remember.",
        "Most sailings moved here from Stranraer, further down the loch, in 2011.",
        "Cairnryan was built up as a military port in the Second World War, because it is sheltered and on the west coast, away from the worst of the bombing."]),
    ("driver", "steelworker", "Lorry Driver", [
        "I come through every Thursday. Four hours of road, two hours of sea, one enormous breakfast."])])
add("cairnryan_arms", "The Ryan Arms", "cairnryan", (37, 26), "cafe", [
    ("landlady", "mum", "Landlady", [
        "Welcome to the Ryan Arms. Breakfasts, soup and a very large pot of tea. Wipe your boots.",
        "Loch Ryan holds the last big wild native oyster bed in Scotland. They were here long before the ferries.",
        "Gannetlings show up when the gales and drizzle roll in. They fold their wings and hit the water like darts. Watch from the pier."]),
    ("fisher", "fisherman_north", "Fisherman", [
        "Selkies are seals in the old tales, who take off their skins to walk on land. The real ones lie on the rocks looking smug."])], 13, 10)
add("cairnryan_harbour", "Harbour Office", "cairnryan", (22, 33), "hall", [
    ("harbourmaster", "sailor", "Harbour Master", [
        "Harbour Office. I keep the tide tables, the weather and a large biscuit tin.",
        "Loch Ryan is a sheltered sea loch about eight miles long, so the ferries can run in nearly all weathers.",
        "South of here is the Mull of Galloway, the most southerly point in Scotland. Its lighthouse was lit in 1830.",
        "Ternlets are about at dawn and in the day. Plungebeaks are about all hours. Take binoculars, not sandwiches."])], 11, 9)
add("cairnryan_home_a", "The Fisherman's Cottage", "cairnryan", (44, 17), "cottage", [
    ("morag", "fisher", "Morag", [
        "Smirr is a fine, misty rain, finer than drizzle. You do not see it falling. You just notice you are wearing it.",
        "My boy is learning to bait a hook. His sister catches more. He says it is the bait.",
        "Watch the loch at dawn. Ternlets hover and then dive, and they look so serious about it."])], 11, 9)
add("cairnryan_home_b", "Sandy's House", "cairnryan", (44, 26), "home", [
    ("sandy", "villager_4", "Sandy", [
        "Glaur is thick mud. The path down to the harbour is mostly glaur in November.",
        "In summer the basking sharks drift past, big as a boat and gentle as a cushion. Baskling comes with the warm months.",
        "My sister in Larne sends me soda farls. I will not tell you how many I eat. Have one."],
        ("cairnryan_home_b_gift", "soda_farl", 1))])

# ------------------------------------------------------------------ GALLOWAY
add("galloway_visitor", "Glen Trool Visitor Centre", "galloway", (30, 39), "museum", [
    ("ranger", "hiker", "Ranger", [
        "Welcome to Glen Trool. Maps are free. Midges are free too, I am afraid.",
        "Red kites were brought back to Galloway from 2001. Look up on a bright day for the forked tail.",
        "Galloway Forest Park is the biggest in Britain, and in 2009 it became the UK's first Dark Sky Park. On a clear night, the stars come out in thousands."]),
    ("volunteer", "student", "Volunteer", [
        "At dusk, a Pinewraith hunts in the treetops. They are shy, so stand still and wait. The stags in autumn are anything but shy."])], 13, 10)

# ------------------------------------------------------------------ town edits other than doors/warps
# (town, [(x, y, ch)])
TOWN_TILES = {
    # a lane south of the Grassmarket row, joining the gaps at x=14 and x=23, so the three doors can be reached
    # (rows 60 and 61 both, so the border trees do not hide the doors from the camera)
    "edinburgh": [(x, y, ".") for y in (60, 61) for x in range(5, 31)],
    # sand in front of the Kelpies door instead of shallow water
    "central_belt": [(x, 36, "s") for x in (9, 10, 11)],
    # tall grass south of the Harbour Office door becomes a path
    "cairnryan": [(22, 34, "#")],
}

# ------------------------------------------------------------------ build
EM = ("—", "–")


def free_tiles(z, w, h):
    blocked = {(p["x"], p["y"]) for p in z.d["props"]}
    dx = w // 2
    out = []
    for y in range(2, h - 3):
        for x in range(2, w - 2):
            if (x, y) in blocked or z.g[y][x] not in "|+":
                continue
            if x == dx and y >= h - 4:
                continue
            out.append((x, y))
    return out


dlg = {}
towns = {}
for zid, name, town, door, kind, npcs, w, h in L:
    tj = os.path.join(OUT, town + ".json")
    td = towns.get(town) or json.load(open(tj))
    towns[town] = td
    ret = (door[0], door[1] + 1)
    # pass 1: furniture only, to find free tiles for the NPCs
    z = landmark(OUT, zid, name, town, ret, kind, [], w, h)
    free = free_tiles(z, w, h)
    dx = w // 2
    used = []
    nl = []
    for k, n in enumerate(npcs):
        short, spr, who, lines = n[:4]
        gift = n[4] if len(n) > 4 else None
        tgt = (dx - 2, 4) if k == 0 else (dx + 2, 4)
        cands = [t for t in free if t not in used]
        cands.sort(key=lambda t: (abs(t[0] - tgt[0]) + abs(t[1] - tgt[1]), t))
        px, py = cands[0]
        used.append((px, py))
        nid = zid + "_" + short
        nl.append(dict(id=nid, sprite=spr, x=px, y=py, facing="down", move="still", script=nid))
        for t in lines:
            assert len(t) <= 200, (zid, len(t), t)
            assert not any(c in t for c in EM), (zid, t)
        if gift:
            flag, item, cnt = gift
            script = [say(who, t) for t in lines[:-1]] + [
                {"do": "if", "flag": flag,
                 "then": [say(who, "That is the lot for today, I am afraid. Mind how you go.")],
                 "else": [say(who, lines[-1]), {"do": "give_item", "item": item, "n": cnt},
                          {"do": "set", "flag": flag}]}]
        else:
            script = [say(who, t) for t in lines]
        dlg.setdefault(zid, {})[nid] = script
    landmark(OUT, zid, name, town, ret, kind, nl, w, h)
    # town: door tile + warp
    x, y = door
    row = td["rows"][y]
    assert row[x] in "BD", (zid, row[x])
    td["rows"][y] = row[:x] + "D" + row[x + 1:]
    assert td["rows"][y + 1][x] in WALK or (x, y + 1) in [(tx, ty) for tx, ty, _ in TOWN_TILES.get(town, [])], (zid, td["rows"][y + 1][x])
    assert not any(p["type"] != "building" and int(p["x"]) == x and int(p["y"]) == y + 1 for p in td["props"]), zid
    if not any(int(p["x"]) == x and int(p["y"]) == y for p in td["warps"]):
        td["warps"].append({"x": x, "y": y, "to": zid, "tx": w // 2, "ty": h - 3, "facing": "up"})

for town, tiles in TOWN_TILES.items():
    td = towns[town]
    for (x, y, ch) in tiles:
        r = td["rows"][y]
        td["rows"][y] = r[:x] + ch + r[x + 1:]
# re-check the south tiles now that the lane/path edits are in
for zid, name, town, door, kind, npcs, w, h in L:
    assert towns[town]["rows"][door[1] + 1][door[0]] in WALK, zid

for town, td in towns.items():
    json.dump(td, open(os.path.join(OUT, town + ".json"), "w"), indent=1, ensure_ascii=False)

os.makedirs(DLG, exist_ok=True)
for zid, d in dlg.items():
    json.dump(d, open(os.path.join(DLG, zid + ".json"), "w"), indent=1, ensure_ascii=False)
print("interiors:", len(L), "homes:", sum(1 for e in L if e[4] in ("home", "cottage")))
