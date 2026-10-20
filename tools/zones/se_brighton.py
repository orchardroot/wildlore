# Brighton: the Royal Pavilion, the Palace Pier and the West Pier's skeleton, the Lanes, the i360, the Volk's
# Electric Railway along the shingle, mods and rockers, Pride. Town south of the South Downs, region south_east.
from se_common import *
from wcommon import _stand


def build(OUT):
    W, H = 72, 60
    zid = "brighton"
    z = Z(zid, "Brighton", W, H, kind="town", region=SE, music="town_cornwall",
          weather={"sunshine": 26, "clear": 28, "drizzle": 22, "gale": 12, "fog": 6, "downpour": 6})
    z.d["stage"] = "coast"; z.d["town_id"] = "brighton"
    z.legend.update({"p": SHINGLE, "j": {"tile": "floor_wood", "colour": "#8a6a4c"}, "r": {"tile": "fence", "colour": "#8a6a4c"},
                     "g": {"tile": "grass", "colour": "#6f9a48"}})
    z.rect(0, 0, W, H, ":")
    z.border("T", 2, gaps=[(34, 0, 3, 2)])
    z.scatter(0, 0, W, 40, "P", 8, 41, only="T")
    for y in range(H):
        for x in range(W):
            z.hg[y][x] = 1
    # --- the seafront: road, promenade, shingle, sea
    z.rect(0, 37, W, 1, ":")
    for x in (0, 1, W - 2, W - 1):
        z.set(x, 37, "T")
    z.rect(2, 38, W - 4, 3, "=")
    z.rect(0, 41, W, 3, ":")
    z.rect(0, 44, W, 4, "p")
    z.rect(0, 48, W, 1, "w")
    z.rect(0, 49, W, H - 49, "$")
    for y in range(44, H):
        for x in range(W):
            z.hg[y][x] = 0
    for y in range(38, 48):
        z.set(0, y, "F"); z.set(1, y, "F"); z.set(W - 1, y, "F"); z.set(W - 2, y, "F")
    for x in range(4, W - 4, 6):
        if x not in (34, 46):
            z.prop("lamp_post", x, 41)
    for x in (12, 26, 42, 56, 64):
        z.prop("bench", x, 43)
    # --- the main road down from London, and North Street across
    z.rect(34, 0, 3, 38, "=")
    z.rect(2, 20, W - 4, 2, "=")
    sign(z, 37, 2, "BRIGHTON. London 54 miles behind you, the sea about half a mile in front. Please drive slowly: the gulls are crossing.")
    # --- Brighton Station, top left, and the path down past the Pavilion
    station(z, 4, 3, 9, 4, "Brighton Station")
    z.prop("buffer_stop", 3, 6); z.prop("buffer_stop", 13, 6)
    z.rect(13, 5, 21, 1, ":")
    rail_guard(z, 11, 5, ["Brighton Station. The roof's from 1883, all iron and glass. On a summer Saturday half of London comes off these platforms with a bucket and spade.",
                          "All aboard! Trains run to everywhere you've been."], facing="left")
    plaque(z, 14, 4, "brighton_station", "Brighton Station",
           "The London and Brighton Railway reached here in 1841, and a fishing town with a royal palace became London's seaside. Day trippers could now come down and go home the same day, and they still do, by the hundred thousand.")
    # --- the Royal Pavilion and its gardens
    z.rect(12, 7, 21, 12, "g")
    z.building(14, 9, 16, 6, "pavilion", "Royal Pavilion", door=8)
    z.rect(12, 15, 21, 2, "#"); z.rect(33, 7, 1, 13, "#"); z.rect(21, 15, 1, 5, "#"); z.rect(12, 7, 1, 13, "#")
    for (x, y, rx) in [(16, 17.5, 2.5), (27, 17.5, 2.5)]:
        blob(z, x, y, rx, 0.8, "f", only="g", seed=int(x), jitter=0.3)
    blob(z, 30, 8, 2, 0.8, ",", only="g", seed=3, jitter=0.4)
    blob(z, 14, 8, 1.5, 0.7, ",", only="g", seed=4, jitter=0.4)
    for (x, y) in [(13, 8), (31, 9), (13, 18), (31, 18), (24, 18)]:
        z.prop("oak", x, y, variant=x % 3)
    for (x, y) in [(18, 16), (25, 16)]:
        z.prop("bench", x, y)
    plaque(z, 20, 17, "brighton_royal_pavilion", "The Royal Pavilion",
           "The Prince Regent, later George IV, came to Brighton for sea bathing and fun, and had John Nash turn his seaside villa into this between 1815 and 1823: Indian domes and minarets outside, Chinese dragons and bamboo inside. Queen Victoria found it too public, sold it to the town in 1850, and took the furniture.")
    plaque(z, 23, 18, "brighton_pavilion_hospital", "A Hospital in the Palace",
           "In the First World War the Pavilion and the Dome became a hospital for soldiers of the Indian Army wounded on the Western Front. Over 2,000 were treated here. The Chattri, a memorial on the downs above Brighton, marks where Hindu and Sikh soldiers who died were cremated.")
    # --- north-east: the North Laine and the scooter lads
    z.building(38, 4, 14, 3, "terrace", "North Laine")
    z.building(54, 4, 14, 3, "flint_cottage", "Kensington Gardens")
    z.rect(38, 7, 30, 1, ":")
    z.building(38, 9, 12, 4, "regency", "Regency House")
    z.building(52, 9, 16, 4, "regency", "Grand Parade")
    plaque(z, 37, 8, "brighton_north_laine", "The North Laine",
           "The laines were the old open fields round the fishing town, divided into long strips. When the town grew, streets of little terraced houses were built along the strips, and the North Laine is now a maze of independent shops, cafés and buskers. Somebody here will sell you a vintage parka.")
    # --- Sanctuary, shop
    z.building(38, 15, 6, 4, "sanctuary", "Sanctuary", door=3)
    z.warp(41, 18, "brighton_sanctuary", 5, 6, "up")
    z.building(45, 15, 5, 4, "shop", "Corner Shop", door=2)
    z.warp(47, 18, "brighton_shop", 4, 5, "up")
    z.building(52, 15, 16, 4, "regency", "Old Steine Terrace")
    # --- the Lanes: twittens of cobbles, jewellers, antiques, a pub and the rock shop
    z.rect(2, 22, 31, 15, ":")
    z.building(3, 23, 6, 3, "flint_cottage", "Lanes Antiques", door=2)
    z.building(10, 23, 5, 3, "flint_cottage", "Jewellers' Row")
    z.building(16, 23, 7, 3, "weatherboard", "The Lanes Tavern", door=3)
    z.building(24, 23, 7, 3, "regency", "Rock Shop", door=3)
    z.building(3, 28, 7, 3, "flint_cottage", "Meeting House Lane")
    z.building(11, 28, 7, 3, "flint_cottage", "Brighton Square")
    z.building(19, 28, 6, 3, "weatherboard", "Fishermen's Cottages")
    z.building(26, 28, 6, 3, "flint_cottage", "Duke's Lane")
    z.building(3, 33, 14, 4, "regency", "Regency Square")
    z.building(19, 33, 13, 4, "regency", "Bedford Row")
    for (x, y) in [(9, 26), (23, 26), (15, 31), (25, 31)]:
        z.prop("lamp_post", x, y)
    z.prop("hanging_basket", 15, 26); z.prop("planter", 2, 27); z.prop("market_stall", 31, 26, variant=1)
    plaque(z, 2, 26, "brighton_lanes", "The Lanes",
           "The oldest part of Brighton, when it was the fishing village of Brighthelmstone: narrow alleys, called twittens in Sussex, between flint-faced cottages. Now they are full of jewellers and antique shops, and it is still very easy to get lost in them.")
    plaque(z, 18, 32, "brighton_flint", "Flint Cobbles",
           "Many old Brighton walls are built of cobbles: flints rounded by the sea and picked off the beach, set in lime mortar with brick corners to hold the edges straight. The beach was the builders' merchant, and the sea delivered for free.")
    # --- east: Old Steine Gardens (Pride), the Royal Crescent, the aquarium, the scooter café
    z.rect(38, 22, 12, 7, "g")
    z.rect(43, 22, 2, 7, "#")
    z.prop("statue", 43, 25, variant=0)
    for x in range(39, 50, 2):
        z.prop("bunting", x, 22)
    z.prop("flagpole", 39, 27, variant=2); z.prop("flagpole", 48, 27, variant=2)
    blob(z, 40, 27, 1.5, 0.6, "f", only="g", seed=9)
    blob(z, 47, 24, 1.5, 0.8, ",", only="g", seed=10, jitter=0.3)
    plaque(z, 45, 28, "brighton_pride", "Brighton Pride",
           "Brighton has been a haven for LGBTQ+ people for a very long time, and its Pride, which began with a small march in 1973 and grew into a festival every August, is one of the biggest in the UK. The whole town turns rainbow for a weekend, including several of the gulls.")
    plaque(z, 41, 25, "brighton_victoria_fountain", "The Victoria Fountain",
           "The fountain in the Old Steine was put up in 1846, with three dolphins holding up its bowls. The Steine itself was a flat open space where fishermen dried their nets, before it was the smartest place in town to be seen.")
    z.building(51, 23, 17, 4, "regency", "Royal Crescent")
    z.building(38, 31, 9, 4, "white_render", "Brighton Aquarium", door=4)
    z.building(48, 31, 9, 4, "regency", "Marine Parade")
    z.building(58, 31, 6, 4, "white_render", "Scooter Cafe", door=3)
    z.building(65, 31, 4, 4, "regency", "Madeira House")
    plaque(z, 37, 35, "brighton_aquarium", "Brighton Aquarium",
           "Opened in 1872, this is the oldest working aquarium in the world. Its long underground hall was built beneath the road by the pier, with columns of granite and marble and a ceiling of vaulted brick. The fish have not complained about the décor.")
    # --- the Palace Pier
    z.rect(34, 41, 3, 3, "j")
    for y in range(44, 52):
        z.set(33, y, "r"); z.set(37, y, "r")
        for x in range(34, 37):
            z.set(x, y, "j")
    z.rect(27, 51, 17, 8, "r")
    z.rect(28, 52, 15, 6, "j")
    z.rect(28, 51, 15, 1, "j")
    for y in range(41, 59):
        for x in range(27, 44):
            if z.g[y][x] in "jr":
                z.hg[y][x] = 1
    z.building(30, 52, 11, 3, "pier_pavilion", "Palace Pier Arcade", door=5)
    for (x, y) in [(28, 52), (42, 52), (28, 57), (42, 57)]:
        z.prop("lamp_post", x, y)
    z.prop("market_stall", 30, 56, variant=2); z.prop("market_stall", 40, 56, variant=0)
    z.prop("bench", 33, 57); z.prop("bench", 37, 57)
    plaque(z, 33, 42, "brighton_palace_pier", "The Palace Pier",
           "Opened in 1899, over half a kilometre long, with its arcades, its helter skelter and its fish and chips on the end. On winter evenings the starlings gather under the deck in their thousands before they settle to roost among the ironwork.")
    # the West Pier, burnt out, standing in the sea
    z.prop("pier_ruin", 10, 54)
    plaque(z, 9, 43, "brighton_west_pier", "The West Pier",
           "Built in 1866 by Eugenius Birch, the West Pier was a favourite of the Victorians. It closed in 1975, was battered by storms and burned twice in 2003. Its iron skeleton still stands out in the sea, and on winter evenings starlings swirl around it in great murmurations.")
    # --- the i360, at the West Pier's old landward end
    z.building(5, 41, 3, 3, "i360", "i360", door=1)
    plaque(z, 4, 43, "brighton_i360", "The i360",
           "A slender observation tower 162 metres tall, opened in 2016 by the people who made the London Eye. A doughnut-shaped glass pod slides up the mast and gives you the coast from Beachy Head to the Isle of Wight on a clear day.")
    # --- Volk's Electric Railway along the beach
    z.building(46, 41, 5, 2, "white_render", "Volk's Railway Halt")
    z.rect(45, 46, 24, 1, "!")
    z.set(57, 46, "&")
    z.prop("buffer_stop", 45, 46); z.prop("buffer_stop", 68, 46)
    z.rect(46, 45, 5, 1, "_")
    plaque(z, 52, 43, "brighton_volks", "Volk's Electric Railway",
           "Magnus Volk opened his little railway along the beach in 1883. It is the oldest electric railway in the world still running. For a few years he also ran the 'Daddy Long Legs', a tramcar on stilts that waded through the sea on rails laid on the seabed.")
    plaque(z, 60, 37, "brighton_mods_rockers", "Mods and Rockers, 1964",
           "Over the Whitsun bank holiday of 1964, mods on Italian scooters and rockers on motorbikes clashed on Brighton's seafront, as they did at Margate and Clacton. The papers went wild. The film Quadrophenia (1979) is set here, and scooter rallies still roar down Madeira Drive.")
    plaque(z, 24, 43, "brighton_shingle", "The Pebble Beach",
           "No sand here: Brighton's beach is shingle, flint pebbles rounded by the waves and rolled along the coast. Wooden groynes stop it drifting east. Bring shoes, a cushion, or a lot of determination.")
    # punch and judy on the beach, deckchairs
    for (x, y) in [(15, 46), (17, 46), (19, 46), (60, 47), (62, 47)]:
        z.prop("bench", x, y)
    # boats and the odd buoy
    for (x, y) in [(20, 52), (55, 55), (62, 51)]:
        z.prop("boat", x, y, variant=1)
    z.prop("buoy", 48, 53)
    # --- doors into the interiors
    lanes_npcs = []
    # NPCs out and about
    chat(z, "br_rock_seller", "shopkeeper", 29, 26, "Rock Seller",
         ["Brighton rock! Pink on the outside, mint on the inside, and BRIGHTON written all the way through, every slice.",
          "The letters are made long and fat, then the whole lump is stretched and rolled till they're tiny. It's a craft. A sticky, sticky craft."], "down", "still")
    chat(z, "br_gull_victim", "villager_4", 20, 42, "Day Tripper",
         ["A gull took my chips. The whole portion. Looked me in the eye, said nothing, took the lot.",
          "The man on the pier said it's my fault for holding them like that. How else do you hold chips?"], "down", "wander")
    chat(z, "br_volks_driver", "rail_guard", 49, 44, "Volk's Driver",
         ["All aboard for Black Rock! Magnus Volk built this in 1883: the first public electric railway in Britain, and the oldest still running anywhere.",
          "His son reckoned the old man was always tinkering. He wired his own house up for electric light too, when most people in Brighton still had gas."], "down", "still")
    chat(z, "br_starling_watcher", "birdwatcher", 12, 43, "Starling Watcher",
         ["Come back at dusk in winter. Thousands of starlings pour in from the downs and swirl round the West Pier like smoke, then drop into the ironwork all at once.",
          "Nobody knows exactly how they keep from crashing. Each bird watches its seven nearest neighbours, they reckon. I can't even keep track of my own kids."], "down", "still")
    chat(z, "br_pride_steward", "festival_goer", 46, 29, "Pride Steward",
         ["Pride's in August: the parade comes right down the seafront, then up to the park for the party. Everyone's welcome, and I mean everyone. Even the gulls get glitter.",
          "My nan marched in the first one, in 1973. There were a few dozen of them. She says the rain was the same."], "up", "still")
    chat(z, "br_old_salt", "fisherman_north", 30, 43, "Old Fisherman",
         ["Brighton was a fishing town, Brighthelmstone, long before any prince came. The boats were hauled up the shingle by capstan. A few still are.",
          "Dr Russell from Lewes started all this, in the 1750s: drink seawater, bathe in it, he said. People came for the cure. They stayed for the pier."], "down", "still")
    # trainers
    tdef("br_punch", "Professor Pip", "Punch and Judy Man", "villager_4", [("cluricaun", 94), ("pooka", 94), ("pierlord", 95)],
         ["That's the way to do it! The puppeteer's called the Professor, you know. Mr Punch first came to England in 1662. Samuel Pepys saw him in Covent Garden and wrote it in his diary."],
         "Oh no it isn't! Oh yes it is. You won.", "The sausages are the hardest part. Strings of them, every show. The crocodile does his best.", 4100)
    tnpc(z, "br_punch", 18, 45, "up")
    tdef("br_deckchair", "Deckchair Attendant Gladys", "Deckchair Attendant", "villager_3", [("greyhaul", 94), ("clownbill", 94), ("bayrunner", 95)],
         ["That's two pounds for a deckchair, and nobody has ever put one up right first time. Watch your fingers."],
         "Fold yourself up and go, then. Nicely done.", "Deckchairs came in with the Victorians. Before that you just sat on the pebbles and suffered.", 4000)
    tnpc(z, "br_deckchair", 61, 47, "left")
    tdef("br_pride_marshal", "Pride Marshal Robin", "Pride Marshal", "festival_goer", [("prismite", 94), ("linenwisp", 94), ("murmurant", 95)],
         ["Every colour of the rainbow, darling, and my team's got most of them. Let's put on a show!"],
         "Fabulous. Truly. I'm not even cross.", "The best bit is the dog show. Last year a sausage dog came as a Pride flag. He was a long one.", 4000)
    tnpc(z, "br_pride_marshal", 49, 26, "left")
    tdef("br_ace_face", "The Ace Face", "Mod Legend", "mod",
         [{"species": "pierlord", "level": 95}, {"species": "raidtail", "level": 95}, {"species": "shuttlecog", "level": 95},
          {"species": "squawkster", "level": 95}, {"species": "stoopfalcon", "level": 96}, {"species": "prinny", "level": 96, "held": "mod_target"}],
         ["They call me the Ace Face. Best suit, best scooter, best dancer on the pier. Forty mirrors on my Lambretta, and I can see you in every one of them.",
          "You want the mods at the rally? You'll have to beat the best of us first. I don't lose, mate. I've never had the time."],
         "...Fair play. That was sharp. Sharper than my lapels.", "Stay sharp, keep it neat, and never, ever, let a rocker touch your mirrors.", 6800)
    tdef("br_rocker", "Ton-Up Terry", "Rocker", "rocker", [("samsonian", 95), ("steelheart", 95), ("highlynx", 95), ("stormswift", 96)],
         ["A 'ton' is a hundred miles an hour. We used to do it on the bypass, from the café to the roundabout and back before the record finished on the jukebox.",
          "Scooters? Hairdryers on wheels. Come on, then."],
         "Alright, alright. You've got a bit of oil in you after all.", "Leather, grease and a Triumph. That's the uniform. The mods can keep their parkas.", 5200)
    # the mods and rockers rally (q_southeast_mods_*)
    q = "q_southeast_mods_"
    script(zid, "br_rally", [
        IF(q + "done", say("Rally Organiser", "Listen to that: mods and rockers revving side by side down Madeira Drive, and nobody's thrown a deckchair. Lovely."), [
            IF(q + "3", say("Rally Organiser", "You got the Ace Face and Terry to shake hands, and a stick of rock each to seal it. That's diplomacy, that is.",
                            "Here: a mod's target badge. The RAF roundel, nicked for a fashion statement in the sixties. Wear it and you'll be first off the line.") +
               [give("mod_target"), give("brighton_rock", 3), standing(3), setf(q + "done")], [
                IF(q + "started", say("Rally Organiser", "Beat the Ace Face, on the end of the pier, and Ton-Up Terry, down Madeira Drive. Then a peace offering from the Rock Shop in the Lanes. Everybody likes rock."), say(
                    "Rally Organiser", "{greeting} I'm running the anniversary scooter rally. Mods AND rockers, together, down Madeira Drive. Like 1964, but without the arrests.",
                    "In 1964 the papers called it a war. It was mostly a lot of lads in a bad mood in the rain, a few broken deckchairs, and a lot of headlines.",
                    "The Ace Face won't ride with the rockers, and Ton-Up Terry won't ride with the mods. Win them round for me? They only listen to people who beat them.") + [setf(q + "started")])])])])
    z.npc(id="br_rally", sprite="tour_guide", x=40, y=42, facing="down", move="still", script="br_rally", name="Rally Organiser")
    script(zid, "br_terry", [
        IF("trainer_br_rocker", say("Ton-Up Terry", "Ride with the mods? ...Go on, then. But I'm at the front."), [
            IF(q + "started", TRN["br_rocker"]["intro"] + [fight("br_rocker"), IF("trainer_br_rocker", [setf(q + "2"), {"do": "say", "who": "Ton-Up Terry", "text": "Alright, I'll ride in the rally. I'll even nod at a scooter. Once."}])],
               say("Ton-Up Terry", "Clear off, I'm polishing. This tank's seen more Brighton seafront than the gulls have."))])])
    z.npc(id="br_terry", sprite="rocker", x=66, y=42, facing="left", move="still", script="br_terry", name="Ton-Up Terry")
    script(zid, "br_ace", [
        IF("trainer_br_ace_face", say("The Ace Face", "We'll be there. Pressed, polished and in formation. Tell Terry to keep his oil to himself."), [
            IF(q + "started", TRN["br_ace_face"]["intro"] + [fight("br_ace_face"), IF("trainer_br_ace_face", [setf(q + "1"), {"do": "say", "who": "The Ace Face", "text": "Fine. The mods will ride. Somebody has to show the rockers how it's done."}])],
               say("The Ace Face", "Mind the suit. It's mohair. It cost more than your shoes and it looks it."))])])
    z.npc(id="br_ace", sprite="mod", x=35, y=57, facing="up", move="still", script="br_ace", name="The Ace Face")
    _stand(z, 35, 57); _stand(z, 66, 42); _stand(z, 40, 42)
    # --- interiors
    door_to(z, OUT, zid, "brighton_pavilion", "The Royal Pavilion", (22, 14), "hall", [
        talker("brighton_pavilion", "pav_guide", "tour_guide", 8, 3, "Pavilion Guide", [
            "The Banqueting Room. Look up: a silver dragon holding a chandelier that weighs nearly a ton. The Prince's guests ate dinners of a hundred dishes under it.",
            "The kitchen's through there, with cast-iron columns made to look like palm trees. Nash used iron to hold up the domes too. All this fantasy, built with the latest engineering.",
            "George loved this place. When he became king, he hardly came back. Too busy, then too big; he'd eaten too many of those dinners."], "down"),
        talker("brighton_pavilion", "pav_cook", "shopkeeper", 3, 5, "Kitchen Historian", [
            "The great chef Antonin Careme cooked here in 1817. One famous banquet had over a hundred dishes, from soups to towering sugar sculptures.",
            "Careme only stayed a few months. He said the English weather didn't suit him. The weather says the same about everybody."], "right")],
        w=17, h=11, extra_props=[P("candelabra", 6, 2), P("candelabra", 10, 2), P("table", 7, 4), P("table", 8, 4), P("table", 9, 4),
                                 P("piano", 14, 2), P("display_case", 1, 6), P("display_case", 15, 6), P("wall_picture", 4, 1, walk=True, variant=2), P("wall_picture", 12, 1, walk=True, variant=1)])
    door_to(z, OUT, zid, "brighton_antiques", "Lanes Antiques", (5, 25), "museum", [
        scripted("brighton_antiques", "ant_dealer", "villager_5", 6, 2, "Antiques Dealer", [
            IF("q_southeast_knucker_2", say("Antiques Dealer", "Enjoy the pie dish! If the dragon wants a matching gravy boat, I've got one with a crack in."), [
                IF("q_southeast_knucker_1", say("Antiques Dealer", "A pie dish big enough for a dragon? I have exactly that. Victorian, stoneware, made for a harvest supper for sixty.",
                                                "Take it. Anyone feeding a knucker needs all the help they can get. Bring it back if it survives.") + [setf("q_southeast_knucker_2")],
                   say("Antiques Dealer", "Everything in here has a story. That clock was in a Hove hotel for ninety years. That mirror was in a pier ballroom. That chair is just a chair.",
                       "The Lanes have been full of antique dealers since after the war. Jewellers before that. Fishermen before that. We all came for the view and stayed for the rent."))])])],
        extra_props=[P("clock", 3, 1, walk=True), P("display_case", 2, 4), P("display_case", 10, 4), P("wall_picture", 9, 1, walk=True, variant=0)])
    DLG.setdefault("brighton_tavern", {})["quizmaster"] = say("Quizmaster", "Welcome to the Lanes Tavern quiz! Five questions, no phones, and no asking the gulls.") + [
        {"do": "choice", "text": "Fancy a round? Five questions.", "options": ["Go on then", "Not tonight"], "set": "_quiz_choice"},
        IF("_quiz_choice", [{"do": "quiz", "pub": "brighton", "region": "england_south", "who": "Quizmaster"}], say("Quizmaster", "Suit yourself. The crab sandwiches are good, anyway."), eq=0)]
    door_to(z, OUT, zid, "brighton_tavern", "The Lanes Tavern", (19, 25), "cafe", [
        {"id": "quizmaster", "sprite": "villager_1", "x": 3, "y": 1, "facing": "down", "move": "still", "script": "quizmaster", "name": "Quizmaster"},
        talker("brighton_tavern", "tav_local", "villager_6", 9, 5, "Local", [
            "Brighton people are 'Brightonians', but Hove people are from 'Hove, actually'. They've been saying it for a century. It's a joke now. Mostly.",
            "Brighton only became a city in 2000, with Hove. Before that we were a town with a palace, a pier and ideas above our station."], "left")])
    door_to(z, OUT, zid, "brighton_rockshop", "Rock Shop", (27, 25), "cafe", [
        scripted("brighton_rockshop", "rock_maker", "shopkeeper", 4, 1, "Rock Maker", [
            IF("q_southeast_mods_3", say("Rock Maker", "How did the peace talks go? Rock solves most things. Except teeth."), [
                IF("q_southeast_mods_2", [IF("q_southeast_mods_1", say("Rock Maker", "A peace offering for the mods and rockers? Two sticks, then: one says MODS all the way through, one says ROCKERS. I made them years ago for a joke. Nobody bought them.",
                                                                       "There you go. Tell them to share.") + [setf("q_southeast_mods_3")],
                                           say("Rock Maker", "Still need the Ace Face to come round? He's on the end of the pier, admiring himself in his mirrors."))],
                   say("Rock Maker", "The words go in at the start, when the rock's a great hot lump the size of a pillow. Then we roll and stretch it until the letters are tiny. A single batch can make a thousand sticks.",
                       "Sugar, glucose, a drop of peppermint, and a lot of elbow. Want one? The shop's through the back."))])])],
        extra_props=[P("display_case", 9, 3), P("display_case", 9, 5), P("kitchen_dresser", 11, 1)])
    door_to(z, OUT, zid, "brighton_i360", "i360 Viewing Pod", (6, 43), "museum", [
        talker("brighton_i360", "pod_host", "tour_guide", 6, 4, "Pod Host", [
            "Welcome aboard! We're rising 138 metres. On a clear day you can see Beachy Head to the east and the Isle of Wight to the west.",
            "Down there, that skeleton in the sea is the old West Pier. We're standing on the spot where its entrance used to be.",
            "The pod is the world's first vertical cable car. Or a very expensive lift with a bar in it. Both are true."], "down"),
        talker("brighton_i360", "pod_tourist", "student", 2, 5, "Tourist", [
            "I can see my hotel! And my car. And a traffic warden next to my car."], "right")],
        extra_props=[P("telescope", 2, 2), P("telescope", 10, 2), P("city_window", 4, 1, walk=True), P("city_window", 8, 1, walk=True)])

    def tanks(r):
        for (x0, y0, w, h) in [(1, 2, 3, 3), (9, 2, 3, 3)]:
            for y in range(y0, y0 + h):
                for x in range(x0, x0 + w):
                    r.set(x, y, "~")
        r.d["props"] = [p for p in r.d["props"] if r.g[p["y"]][p["x"]] != "~" or p["type"] == "rug"]
    door_to(z, OUT, zid, "brighton_aquarium", "Brighton Aquarium", (42, 34), "museum", [
        talker("brighton_aquarium", "aq_keeper", "angler", 5, 4, "Aquarium Keeper", [
            "This hall opened in 1872. Granite columns, a vaulted roof, and the oldest aquarium still working anywhere in the world.",
            "The local seas are richer than people think: cuttlefish, seahorses, thornback rays, and once a year a few dolphins showing off past the pier.",
            "Our turtle's called Lulu. She arrived with a bad flipper. She's been here so long she's practically staff."], "down"),
        talker("brighton_aquarium", "aq_child", "student", 7, 6, "School Trip", [
            "A seahorse dad has the babies! In a pouch! My dad says he's not doing that."], "left")],
        edit=tanks, extra_props=[P("specimen_shelf", 5, 1, walk=True), P("display_case", 1, 6), P("display_case", 11, 6)])
    door_to(z, OUT, zid, "brighton_scootercafe", "Scooter Cafe", (61, 34), "cafe", [
        talker("brighton_scootercafe", "sc_owner", "shopkeeper", 3, 1, "Café Owner", [
            "Frothy coffee, a jukebox and a row of scooters outside. That was the mod's idea of a good night. Plus the clothes. Mainly the clothes.",
            "Mods were modernists: sharp Italian suits, parkas to keep the suits clean on the scooter, and modern jazz, then soul and ska. Rockers wanted rock and roll, leather and speed."], "down"),
        talker("brighton_scootercafe", "sc_mod", "mod", 9, 4, "Mod", [
            "That's a Vespa outside. Lambrettas are for show-offs. Don't tell the Ace Face I said that."], "left"),
        talker("brighton_scootercafe", "sc_rocker", "rocker", 9, 6, "Rocker", [
            "I only come in for the coffee. And the jukebox. And the warm. Don't make a thing of it."], "left")],
        extra_props=[P("piano", 1, 4, rot=90), P("menu_board", 6, 1, walk=True)])
    door_to(z, OUT, zid, "brighton_pier", "Palace Pier Arcade", (35, 54), "theatre", [
        talker("brighton_pier", "pier_attendant", "villager_2", 6, 3, "Arcade Attendant", [
            "Two-penny falls, a claw machine and a fortune teller who has never once been right. Welcome to the Palace Pier!",
            "The pier opened in 1899. The helter skelter's on the end. The fish and chips are next to it. Order matters."], "down"),
        talker("brighton_pier", "pier_fortune", "villager_6", 1, 5, "Mechanical Fortune Teller", [
            "INSERT COIN. You will... meet a tall dark stranger. Or a gull. Probably a gull."], "right")],
        extra_props=[P("display_case", 2, 2), P("display_case", 10, 2), P("menu_board", 9, 1, walk=True)])
    sanctuary(OUT, zid, "Brighton", (41, 19), music="sanctuary")
    shop(OUT, zid, "Brighton", (47, 19))
    nurse(zid, ["Hello, sweetheart! Welcome to the Brighton Sanctuary. Sand in their feet, salt in their fur. Let's have a look at them.",
                "Pop them on the counter. A bit of sea air does wonders, but so does a lie-down.",
                "All better! Off you go, and don't let the gulls nick anything you love.",
                "The Ark's in the corner. It's got a stick of rock taped to the lid. Long story.",
                "Mind how you go, love. Wear sun cream, even in October. Especially in October."])
    shopkeeper(zid, "Hiya! Snares, tea, and Brighton rock by the stick or the yard. What can I get you?",
               "Ta-ra! If the gulls ask, you didn't buy anything.")
    # wild creatures in the Pavilion gardens and the Old Steine
    lo, hi = LV
    wild(z, [("starlet", lo, hi, 12, {"time": ["dusk", "dawn"]}), ("murmurant", hi, hi, 4, {"time": ["dusk"]}), ("chipgull", lo, hi, 14, {}),
             ("cooplet", lo, hi, 10, {}), ("binfox", lo, hi, 8, {"time": ["night", "dusk"]}), ("parakit", lo, hi, 8, {}),
             ("prinny", lo, hi, 4, {}), ("prinny", hi, hi, 4, {"time": ["night"]}), ("grizzlet", lo, hi, 8, {}),
             ("flittermouse", lo, hi, 6, {"time": ["night"]}), ("hootlet", lo, hi, 6, {"time": ["night"]})])
    wild(z, [("chipgull", lo, hi, 20, {}), ("pupplash", lo, hi, 14, {}), ("pinchkin", lo, hi, 16, {}), ("gannetling", lo, hi, 12, {}),
             ("dolphlet", lo, hi, 8, {"time": ["day"]}), ("pierlord", hi, hi, 4, {})], "water")
    z.d["edges"] = {"north": {"to": "south_downs", "offset": -14}}
    z.d["spawn"] = [35, 2]
    scale_zone(z)
    finish(z)
    z.save(OUT + "/" + zid + ".json")
