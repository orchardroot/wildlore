"""Walk-in interiors for the named landmark buildings in the Welsh, Irish and Scottish zones.
Run: python3 tools/zones/landmarks_celtic.py data/zones
Writes the interiors, their dialogue, and adds the door warps to the town zone files (idempotent)."""
import json, sys, os
sys.path.insert(0, os.path.dirname(__file__))
from zlib import landmark

out = sys.argv[1] if len(sys.argv) > 1 else "data/zones"
dlg_dir = os.path.join(os.path.dirname(out.rstrip("/")), "dialogue")


def say(who, text):
    return {"do": "say", "who": who, "text": text}


# (zid, name, town, door(x,y), kind, npcs[(id, sprite, x, y, who, [lines])])
L = [
    ("anglesey_bridge", "Bridge Visitor Centre", "anglesey", (62, 5), "museum", [
        ("bridge_guide", "tour_guide", 5, 4, "Bridge Guide", [
            "Croeso! Welcome to Ynys Môn. You came in over the Menai Suspension Bridge, I hope, not by swimming.",
            "Thomas Telford's bridge opened in 1826 and carried the London to Holyhead road over the strait. Its deck hangs from iron chains.",
            "Before it, you took a ferry and prayed to the tide. Now you just pay attention to the wind. Hold your hat.",
        ])]),
    ("bushmills_mill", "The Old Mill", "bushmills", (27, 27), "mill", [
        ("mill_keeper", "shopkeeper", 6, 3, "Mill Keeper", [
            "Mind the wheel, it has no sense of humour. This mill has ground grain beside the river Bush for a very long time.",
            "Bushmills was given its licence to distil in 1608, which is why folk call it the oldest licensed distillery in the world.",
            "The water comes from St Columb's Rill, which runs off the hills. I'm told it's very good in tea. Don't ask me about the rest.",
        ])]),
    ("cambrian_bwlch", "Fferm y Bwlch", "cambrian_coast", (25, 37), "hall", [
        ("bwlch_farmer", "farmer", 6, 2, "Farmer", [
            "Bore da! Fferm y Bwlch, the farm of the pass. Bwlch is the gap in the hills, and we're the ones who live in it.",
            "Out in Cardigan Bay there's a group of bottlenose dolphins that live here all year round, one of the biggest in the UK.",
            "I see them from the top field when I'm meant to be counting sheep. The sheep don't mind. The dolphins are better company.",
        ])]),
    ("causeway_centre", "Giant's Causeway Visitor Centre", "causeway", (20, 30), "museum", [
        ("causeway_guide", "tour_guide", 5, 4, "Causeway Guide", [
            "Welcome! There are about 40,000 stone columns out there, and most of them have six sides. Nobody planned that. It's cooling lava.",
            "It all began some 60 million years ago, when molten basalt cracked as it cooled, like mud drying in a puddle.",
            "The legend says Fionn mac Cumhaill built it to reach Scotland and fight a rival giant. The geologists have rather less fun.",
            "It became a World Heritage Site in 1986. Wear shoes with grip. The columns are slippy and the sea is not sorry.",
        ])]),
    ("derry_guildhall", "The Guildhall", "derry", (48, 11), "hall", [
        ("guildhall_steward", "villager_3", 6, 2, "Steward", [
            "Welcome to the Guildhall, the proudest building in Derry~Londonderry. Look up at the clock tower on the way out.",
            "It opened in 1890, burned down in 1908, and was rebuilt, because this city does not give up on things.",
            "The stained glass windows are the best bit. Take your time. The kettle's on, but not for visitors.",
        ])]),
    ("glasgow_kelvingrove", "Kelvingrove Art Gallery", "glasgow", (10, 11), "museum", [
        ("kelvingrove_guide", "tour_guide", 5, 4, "Gallery Guide", [
            "Welcome to Kelvingrove! Look up. Yes, that's a Spitfire hanging from the ceiling. We get that question a lot.",
            "It's a Spitfire from 602 (City of Glasgow) Squadron, and it has been up there for years without once needing dusted.",
            "Then there's Sir Roger the elephant, the Salvador Dali painting, and a very fine organ. Och, take the whole afternoon.",
        ])]),
    ("glasgow_chambers", "City Chambers", "glasgow", (40, 16), "hall", [
        ("chambers_usher", "villager_2", 6, 2, "Usher", [
            "Welcome to the City Chambers, on George Square. Queen Victoria opened it in 1888, and Glasgow has been showing off since.",
            "Marble, mosaic, a great staircase and more gold leaf than a jeweller's. Merchants of the Second City of the Empire liked to flex.",
            "Mind your manners on the stairs. The councillors are used to being looked at. You, however, may gawp.",
        ])]),
    ("glasgow_ceilidh", "Ceilidh Hall", "glasgow", (63, 26), "theatre", [
        ("ceilidh_caller", "ceilidh_caller", 6, 2, "Caller", [
            "Fàilte! Come in, come in. Ceilidh is a Gaelic word, cèilidh, and it just means a visit, a gathering of friends.",
            "Tonight it's the Gay Gordons, Strip the Willow and the Dashing White Sergeant. Nobody's allowed to sit out. I'll find you.",
            "Slàinte mhath! Don't worry about getting the steps wrong. Everyone's wrong together, and that's the whole point.",
        ]),
        ("ceilidh_fiddler", "fiddler", 9, 2, "Fiddler", [
            "I've played the Dashing White Sergeant four hundred times. It still gets me, mostly in the left wrist.",
        ])]),
    ("holyhead_terminal", "Ferry Terminal", "holyhead", (18, 18), "hall", [
        ("terminal_clerk", "sailor", 6, 2, "Ferry Clerk", [
            "Bore da! Holyhead sits on Holy Island, Ynys Gybi, joined to Anglesey by a causeway and a very long habit.",
            "The ferries run from here to Dublin, Baile Átha Cliath. A bit over three hours, and the tea is better than you'd fear.",
            "Our breakwater is one of the longest in Britain, over a mile and a half of stone. The Victorians built it for ships.",
        ])]),
    ("inverness_cathedral", "St Andrew's Cathedral", "inverness", (7, 27), "church", [
        ("cathedral_verger", "villager_5", 6, 2, "Verger", [
            "Welcome to St Andrew's, on the bank of the River Ness. Inbhir Nis in Gaelic: the mouth of the Ness. Sit and have a breather.",
            "It was built in the 1860s, finished in 1869, and it's the cathedral of the Scottish Episcopal Church in these parts.",
            "The river sounds lovely through the walls on a quiet day. Some of the congregation say it's better than the choir. Don't tell them I said.",
        ])]),
    ("kerry_muckross", "Muckross House", "ring_of_kerry", (12, 16), "hall", [
        ("muckross_guide", "tour_guide", 6, 2, "House Guide", [
            "Céad míle fáilte to Muckross House, a hundred thousand welcomes, and you may have all of them. Mind the carpets.",
            "It was built in 1843 for the Herbert family, beside the Killarney lakes. Everything in it was tidied up for Queen Victoria's visit in 1861.",
            "The Herberts nearly went bankrupt over that visit. A royal tea is very expensive, as it turns out.",
        ])]),
    ("st_davids_cathedral", "St Davids Cathedral", "st_davids", (13, 31), "church", [
        ("cathedral_guide", "choir_singer", 6, 2, "Cathedral Guide", [
            "Croeso i Tyddewi, which means David's house. Our little city is the smallest in Britain, and we are very smug about it.",
            "The cathedral sits down in a hollow on purpose. Raiders sailing past couldn't see the tower from the sea.",
            "Dydd Gŵyl Dewi Sant is on the first of March. We wear daffodils and leeks and we sing, not necessarily in tune.",
        ])]),
    ("wicklow_visitor", "Wicklow Mountains Visitor Centre", "wicklow", (19, 27), "museum", [
        ("wicklow_ranger", "hiker", 5, 4, "Ranger", [
            "Welcome to the Wicklow Mountains. Glendalough is Gleann Dá Loch, the valley of two lakes, and yes, there are two.",
            "St Kevin settled here in the 6th century, and his monks built a round tower about 30 metres high. It's still standing.",
            "Stay on the path, bring a coat, and do not trust a sunny morning. This is Wicklow. We keep a spare sky.",
        ])]),
]


def main():
    os.makedirs(dlg_dir, exist_ok=True)
    for zid, name, town, (dx, dy), kind, npcs in L:
        npc_defs, scripts = [], {}
        for nid, spr, x, y, who, lines in npcs:
            npc_defs.append(dict(id=nid, sprite=spr, x=x, y=y, facing="down", move="still", script=nid))
            scripts[nid] = [say(who, t) for t in lines]
        w, h = 13, 10
        landmark(out, zid, name, town, (dx, dy + 1), kind, npc_defs, w, h)
        with open(os.path.join(dlg_dir, zid + ".json"), "w") as f:
            json.dump(scripts, f, indent=1, ensure_ascii=False)
        p = os.path.join(out, town + ".json")
        d = json.load(open(p))
        if not any(wp["x"] == dx and wp["y"] == dy for wp in d["warps"]):
            d["warps"].append({"x": dx, "y": dy, "to": zid, "tx": w // 2, "ty": h - 3, "facing": "up"})
            with open(p, "w") as f:
                json.dump(d, f, indent=1, ensure_ascii=False)


main()
