from lib import *

ST = "q_pennines_whit_started"
CORNET, TUBA, DRUM, CONTEST, DONE = ("q_pennines_whit_cornet", "q_pennines_whit_tuba", "q_pennines_whit_drum",
                                     "q_pennines_whit_contest", "q_pennines_whit_done")


def IF(flag, then, els=()):
    return {"do": "if", "flag": flag, "then": list(then), "else": list(els)}


def WHEN(cond, then, els=()):
    return {"do": "when", "cond": cond, "then": list(then), "else": list(els)}


def SET(flag):
    return {"do": "set", "flag": flag}


def build():
    # ------------------------------------------------------------------ interiors
    # Saddleworth Museum: back to the moor door at (6, 22)
    write_json("data/zones/saddleworth_museum.json", interior(
        "saddleworth_museum", "Saddleworth Museum", 11, 9, 5, "saddleworth_moor", 6, 23,
        props=[P("display_case", 2, 2), P("display_case", 4, 2), P("display_case", 8, 2), P("wall_map", 6, 1, walk=True),
               P("wall_picture", 2, 1, walk=True, variant=1), P("wall_picture", 8, 1, walk=True, variant=2),
               P("specimen_shelf", 1, 4), P("bookshelf", 9, 4), P("rug", 4, 4, w=3, h=2, walk=True, variant=1),
               P("potted_plant", 1, 6), P("clock", 4, 1, walk=True)],
        npcs=[N("museum_curator", "tour_guide", 6, 3, script="museum_curator", name="Curator")],
        signs=[{"x": 3, "y": 2, "text": "A weaver's clogs, iron-shod, from a Dobcross mill. Worn down at the heel by forty years of standing still very fast.",
                "kind": "radio"} if False else
               {"x": 9, "y": 6, "text": "Before the big mills, Saddleworth wove woollen cloth at home. The long rows of upstairs windows on the old cottages lit the handlooms in the weavers' top-floor workrooms.",
                "plaque": "pennines_weavers_windows", "title": "Weavers' Windows"}]))

    # Band Room: the Whit Friday quest hub
    band_npcs = [N("band_secretary", "villager_3", 6, 3, script="band_secretary", name="Band Secretary")]
    band_npcs += [
        N("band_cornet", "villager_4", 3, 3, name="Cornet Player", show_if=CORNET,
          text="I've had a word with myself. And a cup of tea. Mostly the tea. Lead on."),
        N("band_tuba", "hillwalker", 9, 3, name="Tuba Player", show_if=TUBA,
          text="Found my way down by following the hare. Wise creatures, hares. Never once got lost in a fog on Standedge."),
        N("band_drum", "student", 9, 5, name="Drummer", show_if=DRUM,
          text="Three miles in the dark on a narrowboat and I kept time the whole way. The echo was cracking."),
        N("band_kettle", "villager_6", 2, 5, name="Tea Lady", script="band_tealady"),
    ]
    write_json("data/zones/saddleworth_bandroom.json", interior(
        "saddleworth_bandroom", "Band Room", 13, 10, 6, "saddleworth_moor", 13, 23,
        props=[P("band_kit", 4, 2, variant=0), P("band_kit", 8, 2, variant=1), P("band_kit", 10, 2, variant=2),
               P("hall_stage", 5, 1, variant=0), P("hall_stage", 6, 1, variant=1), P("hall_stage", 7, 1, variant=2),
               P("stacked_chairs", 1, 7), P("stacked_chairs", 11, 7, variant=1), P("tea_urn", 1, 4),
               P("wall_picture", 2, 1, walk=True, variant=0), P("wall_picture", 10, 1, walk=True, variant=3),
               P("clock", 11, 1, walk=True), P("flagpole", 11, 4, variant=0)],
        npcs=band_npcs,
        signs=[{"x": 3, "y": 1, "text": "Brass bands grew up alongside the mills and pits of the North in the 1800s. Firms and villages paid for instruments and uniforms, and workers rehearsed after their shifts. Many village bands still play in contests today.",
                "plaque": "pennines_brass_bands", "title": "Mill Town Brass"}]))

    # Standedge Tunnel: the narrowboat trip, a dark run from the Diggle portal to the Marsden one
    w = 36
    rows = ["x" * w,
            "x" + "~" * (w - 2) + "x",
            "x" + "|" * (w - 2) + "x",
            "x" + "|" * (w - 2) + "x",
            "x|" + "~" * (w - 4) + "|x",
            "x|" + "x" * (w - 4) + "|x",
            "xD" + "x" * (w - 4) + "Dx",
            "x" * w]
    tunnel = interior("standedge_tunnel", "Standedge Tunnel", w, 8, 1, "saddleworth_moor", 19, 8,
                      props=[P("canal_boat", 6, 4, variant=0), P("canal_boat", 18, 1, variant=1), P("canal_boat", 28, 4, variant=1),
                             P("lamp_post", 2, 5) if False else P("bollard", 2, 5)],
                      npcs=[N("tunnel_guide", "canal_boater", 4, 2, script="tunnel_guide", name="Boat Guide", facing="right"),
                            N("whit_drummer", "student", 22, 2, script="whit_drummer", name="Drummer", hide_if=DRUM, facing="down")],
                      signs=[{"x": 12, "y": 2, "text": "WILLIAM'S ADIT. The tunnel was dug from both ends and from shafts sunk down from the moor. When the two halves met in the middle, they were out by a few feet, and you can still see the kink."} if False else
                             {"x": 12, "y": 1, "text": "Building the tunnel took the best part of seventeen years. It was dug from both portals and from shafts sunk down from the moor above, and the headings did not quite meet in line, so the bore has kinks you can see from the boat.",
                              "plaque": "pennines_tunnel_dig", "title": "Digging Standedge"},
                             {"x": 27, "y": 1, "text": "Three railway tunnels run alongside the canal tunnel, linked to it by cross passages. The tunnel was shut to boats in 1944 and reopened in 2001 after the canal was restored."}],
                      music="", dark=True, rows_override=rows,
                      extra_warps=[{"x": w - 2, "y": 6, "to": "saddleworth_moor", "tx": 51, "ty": 8, "facing": "down"}])
    write_json("data/zones/standedge_tunnel.json", tunnel)

    write_json("data/zones/standedge_visitor.json", interior(
        "standedge_visitor", "Standedge Visitor Centre", 11, 9, 5, "saddleworth_moor", 57, 13,
        props=[P("display_case", 2, 2), P("display_case", 8, 2), P("wall_map", 5, 1, walk=True), P("kettle_table", 1, 5),
               P("table", 8, 5), P("potted_plant", 9, 6), P("wall_picture", 3, 1, walk=True, variant=2)],
        npcs=[N("visitor_volunteer", "canal_boater", 5, 3, script="visitor_volunteer", name="Volunteer")],
        signs=[{"x": 2, "y": 6, "text": "The visitor centre is an old canal warehouse at Tunnel End, where goods were swapped between boats and carts. The Huddersfield Narrow Canal climbs to 645 feet above sea level here, the highest canal summit in Britain.",
                "plaque": "pennines_tunnel_end", "title": "Tunnel End"}]))

    # ------------------------------------------------------------------ dialogue: the moor
    G = "{greeting}"
    moor = {
        "whit_cornet": [IF(ST, [
            say("Cornet Player", "Oh, it's you from the band. Did she send you? I split a top note on Whit Friday last year, right in front of the judge, and I've been hiding at Dovestone ever since."),
            say("Cornet Player", "You can't see the judge, you know. They sit in a car or a back room so they can't tell which band's which. Somehow that makes it worse."),
            {"do": "choice", "text": "Talk her round?", "options": ["Everyone splits a note.", "The band's nowhere without you."], "set": "pennines_cornet_pep"},
            say("Cornet Player", "...You're right. And it's only a march. Cornet up. I'll see you at the Band Room."),
            SET(CORNET),
        ], [
            say("Cornet Player", G + " Lovely and quiet at Dovestone. Just me, the reservoir and the occasional man with a very big camera lens."),
            say("Cornet Player", "Can't play down here though. The sheep get opinions."),
        ])],
        "whit_tuba": [IF(ST, [
            say("Tuba Player", "Is this Saddleworth or Kinder? I've been walking the Pennine Way in this fog since Tuesday. The tuba is heavier than it looks, and it looks very heavy."),
            WHEN("party_has_snowhare", [
                say("Tuba Player", "A mountain hare! Now I know where I am. The only wild ones in England live round here. Right, downhill it is. Tell them I'm coming."),
                SET(TUBA),
            ], [
                say("Tuba Player", "Show me a mountain hare and I'll believe you. They only live wild on these moors in all of England. Find one in the heather and bring it here."),
            ]),
        ], [
            say("Tuba Player", G + " Don't mind me. Just carrying a tuba along the Pennine Way. For training. It's a long story with a lot of hills in it."),
        ])],
        "moor_ranger": chat("RSPB Warden",
            G + " Hear that bubbling call? Curlew. Back on the moor every spring. Biggest wading bird in Europe, that one, with a beak like a sickle.",
            "Twenty years ago the peat up here was bare and black and washing away. We've been blocking the gullies and planting sphagnum moss by the hand-ful. It holds water like a sponge.",
            "Wet peat stores carbon and slows the floods down in the valleys. Dry peat just blows away. So, please, keep to the flags."),
        "moor_weaver": chat("Retired Weaver",
            G + " I started at the mill at fourteen. You learnt to lip-read, because you'd never hear a word over the looms. Some of us still do it in the pub.",
            "We wore clogs. Wooden soles, iron caulkers underneath. Sparked on the cobbles on a dark morning. Lovely sound, a street full of clogs at six o'clock."),
        "moor_yorkie": chat("Saddleworth Farmer",
            G + " Manchester, the sign says. Yorkshire, I say. My postcode can say what it likes.",
            "The Saddleworth Rushbearing's in August. We pull a cart piled with rushes round the villages, with a man sat on top. Sounds daft. It is daft. It's grand."),
        "moor_poet": chat("Walker",
            G + " First proper walk on the Pennine Way? Mind the bogs. If the ground wobbles, it's not the ground's fault.",
            "Golden plover up by the edge this morning. Little sad whistle. They sound like they've lost their keys."),
        "moor_leggers": chat("Narrowboater",
            G + " Leggers used to take boats through Standedge lying on their backs on boards, walking the roof of the tunnel. Three miles of that. Hours of it.",
            "The horses went over the top on the Boat Lane, with a lad, and met the boat at the other end. Better view. Fewer bats."),
        "moor_hare_spot": chat("",
            "A mountain hare sits up in the heather, ears like two exclamation marks. It looks at you. It decides you are not a fox, and goes back to eating."),
    }
    write_json("data/dialogue/saddleworth_moor.json", moor)

    bandroom = {
        "band_secretary": [IF(DONE, [
            say("Band Secretary", G + " Our Whit Friday winners! The cup's on the piano. The piano is not ours, so don't lean on it."),
        ], [IF(ST, [
            IF(CORNET, [IF(TUBA, [IF(DRUM, [
                say("Band Secretary", "Cornet, tuba, drum, and you. That's a band! Right, coats on. The contest march starts at the top of the village."),
                say("Band Secretary", "Oh, heck. The Thornyclough lot are marching up behind us. Their band leader wants a word. He always wants a word."),
                {"do": "battle", "trainer": "pennines_band_rival", "intro": True},
                IF("trainer_pennines_band_rival", [
                    SET(CONTEST),
                    say("", "The band marches down the street to a cheer from the pub doorways, and plays the march for a judge nobody can see."),
                    say("Band Secretary", "First prize! First! We have not been first since the 1990s! Here, love, you've earned these."),
                    {"do": "give_item", "item": "whit_rosette"},
                    {"do": "give_item", "item": "cornet_mouthpiece"},
                    {"do": "give_item", "item": "curd_tart", "n": 3},
                    {"do": "standing", "nation": "england", "amount": 3},
                    SET(DONE),
                ]),
            ], [say("Band Secretary", "Still no drummer. Last seen getting on a boat into Standedge Tunnel. You'll find the portal up the towpath from the village.")])],
                [say("Band Secretary", "Still no tuba. He went for a training walk on the Pennine Way and the fog came down. Look north along the flagstones.")])],
                [say("Band Secretary", "Still no cornet. She's moping down by Dovestone Reservoir. Be kind. Be firm. Mostly be kind.")]),
        ], [
            say("Band Secretary", G + " Whit Friday's tonight and I've a band of three, a tea urn and a man who plays the triangle. He's the urn's backup."),
            say("Band Secretary", "Every village from here to Mossley holds a contest. Bands march into each one in turn and play for a judge who can't see them. We need a full band."),
            say("Band Secretary", "Our cornet is sulking at Dovestone. Our tuba is lost on the Pennine Way. Our drummer went into Standedge Tunnel on a boat trip and hasn't come out. Fetch them for me?"),
            SET(ST),
            say("Band Secretary", "You're a star. Mind, the tuba's stubborn. Take him something that reminds him where he is."),
        ])])],
        "band_tealady": chat("Tea Lady",
            G + " Tea's stewed, buns are fresh, and you're not a band member until you've burnt your tongue on the urn.",
            "Brass bands used to be the mill's band, or the pit's. Now we're the village's. Same hymns, better trousers."),
    }
    write_json("data/dialogue/saddleworth_bandroom.json", bandroom)

    write_json("data/dialogue/standedge_tunnel.json", {
        "tunnel_guide": chat("Boat Guide",
            G + " Welcome aboard. Keep your hands inside the boat, the hill doesn't move for anybody.",
            "Over three miles of tunnel, and about six hundred feet of moor over your head at the deepest. No towpath in here. The leggers walked the boats through with their feet on the walls.",
            "If you hear a rumble, that's a train in the railway tunnels next door. If you hear a tuba, that's something else entirely."),
        "whit_drummer": [IF(ST, [
            say("Drummer", "Is it Whit Friday already? I've been keeping time for the boat. Boom. Boom. The echo in here is unbelievable."),
            say("Drummer", "The band needs me? Say no more. I'll hop off at the Marsden end and leg it round. Ha. Leg it. Tunnel humour."),
            SET(DRUM),
        ], [
            say("Drummer", G + " Best acoustics in the Pennines, this. I'm practising. Shh. Boom."),
        ])],
    })
    write_json("data/dialogue/saddleworth_museum.json", {
        "museum_curator": chat("Curator",
            G + " Saddleworth made woollen cloth long before cotton came. Weavers worked at home, upstairs, in the light of those long windows.",
            "Then the mills came, and the canal, and the railway, all squeezing through the same gap in the hills at Standedge. Everyone needed to get over the Pennines.",
            "We've a whole case of Whit Friday band photos. Every one of them is someone's grandad in a very tight jacket."),
    })
    write_json("data/dialogue/standedge_visitor.json", {
        "visitor_volunteer": chat("Volunteer",
            G + " This was a canal warehouse. Boats unloaded here because it was quicker to carry goods over the moor by cart than to leg them through the tunnel.",
            "When the railway came, the canal lost its trade. By the 1940s it had closed. Volunteers and the waterways folk dug it out again, and boats came back through in 2001."),
    })

    # ------------------------------------------------------------------ trainers (moor)
    trainer("pennines_fellrunner", "Fell Runner Gaz", "Fell Runner", "fell_runner",
            [("pipkin", 14), ("scuttlet", 15), ("gritling", 15)],
            ["Out of the way! I'm doing Saddleworth to Marsden and back before my porridge goes cold.",
             "Fell runners don't stop. We just battle at speed."],
            "Ooh, that's a personal worst. Grand.", "Fell running's simple. Up, down, and lie to everyone about your time.")
    trainer("pennines_rambler", "Rambler Pauline", "Rambler", "hiker",
            [("sphagnet", 15), ("croakle", 15)],
            ["We walked here in 1932 to make a point, and we'll walk here now to make another. Mostly that it's lovely.",
             "Right to roam, right to battle!"],
            "You're a credit to boots everywhere.", "The Kinder trespass was 1932. Without it you'd be looking at this moor through a fence.")
    trainer("pennines_angler", "Angler Clive", "Angler", "angler",
            [("dipling", 15), ("volet", 15), ("stalklet", 16)],
            "Nothing biting at Dovestone, and now you. Let's see if you're more sporting than the trout.",
            "That's the one that got away. Again.", "Wind off the moor puts the fish down. Puts me down too.")
    trainer("pennines_birder", "Birdwatcher Imogen", "Birdwatcher", "birdwatcher",
            [("hootlet", 15), ("pipkin", 15), ("snowhare", 16)],
            ["Shh. Curlew. No, wait. That's my stomach. Ignore it.",
             "Fine, a battle. But whisper."],
            "Beaten! I'm putting it in my notebook. Under 'regrets'.", "The short-eared owl hunts in daylight up here. Watch the heather at teatime.")
    trainer("pennines_boater", "Boater Jim", "Narrowboater", "canal_boater",
            [("volet", 15), ("elverlet", 15), ("croakle", 16)],
            "I've legged my boat through three miles of tunnel, love. You don't scare me.",
            "Well, that's me becalmed.", "Four miles an hour is the speed limit on the cut. It's plenty. Nobody's in a hurry on a narrowboat.")
    trainer("pennines_band_rival", "Bandmaster Horace", "Bandmaster", "choir_singer",
            [("swiftlet", 15), ("hootlet", 16), ("gritling", 16), ("pepperling", 17)],
            ["Thornyclough Silver Band have won this march four years running, and I've the trophy cabinet to prove it.",
             "Before you step off, let's see if your lot can keep time under pressure."],
            "Well. The judge can't see us, but I felt that.",
            "Whit Friday's not about the cups. It's about the cups. Next year, though.", money=900)


if __name__ == "__main__":
    build()
