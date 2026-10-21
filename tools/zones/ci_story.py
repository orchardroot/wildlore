# Dialogue for the Channel Islands: the three quests, the Black Dog of Bouley Bay, and the scripts the zone files leave
# to be written here. Quest flags are q_channel_islands_<quest>_*; see data/quests/channel_islands.json.
from ci_common import *

Q1 = "q_channel_islands_royals"
Q2 = "q_channel_islands_liberation"
Q3 = "q_channel_islands_chapel"


def write():
    # ------------------------------------------------------------ quest: First Royals (St Helier's market and Le Brocq's farm)
    put("st_helier_market", "sth_royal_stall", [
        iff(Q1 + "_done", s("Potato Stall",
            "Royals! Look at them. Scrape, don't peel, boil with a sprig of mint, butter and nothing else. Mèrcie, my friend, you've saved my season.",
            "Jersey Royals are grown on steep south-facing fields called côtils, and dug by hand from April. First crop of the year, and half the island lines up for them."),
        [iff(Q1 + "_started",
             [iff(Q1 + "_2",
                  s("Potato Stall", "Are those them? Oh, look at the skins. You can rub them off with your thumb. Wonderful. Here, you deserve something for the trouble.")
                  + sett(Q1 + "_done") + [item("jersey_royal", 3), {"do": "give_creature", "species": "crockling", "level": 40}, standing(4),
                                          {"do": "say", "who": "Potato Stall", "text": "And take this little one. It turned up in the bean crock aisle and I think it's yours."}],
                  s("Potato Stall", "Any luck with the Royals? Le Brocq's farm is up the lane north of town. They want a Vraicling's seaweed for the fields and a good fight from the old man first. Jersey hospitality."))],
             s("Potato Stall",
               "Bouônjour. The stall's empty, and it's the Royal season, and I've nothing to sell. The man who usually supplies me is laid up. Could you fetch me a crop of Royals?",
               "Try Le Brocq's farm, up the lane to the north of town. They'll want the right fertiliser and a bit of a show. Old Josué doesn't give his potatoes to anybody.") + sett(Q1 + "_started"))])])
    put("jersey_farm", "jer_farmwife", [
        iff(Q1 + "_done", s("Farmer's Wife", "Did Old Josué's Royals go down well at the market? I told him they would. Don't tell him I said so, he'll want paying."),
        [iff(Q1 + "_2", s("Farmer's Wife", "The Royals are with the market now, I hope. Come and sit down. I've a bean crock on."),
         [iff(Q1 + "_started",
              [iff(Q1 + "_1", [when("caught_vraicling",
                   [iff("trainer_jer_legend",
                        s("Farmer's Wife",
                          "A Vraicling caught, and Josué beaten fair and square in his own field? He won't speak to me all week. Well. The seaweed's the secret of a good Royal, and you've the right stuff.",
                          "Here's a crate, the first Royals of the year. Take them to the stall in the Central Market, and tell them Josué Le Brocq's sent them.")
                        + sett(Q1 + "_2") + [item("jersey_royal", 3)],
                        s("Farmer's Wife", "You've the seaweed creature, good. But Josué won't hand a crate to anyone he hasn't tested. He's in the field by the lane. Go on, he'll enjoy it.")),
                   ],
                   s("Farmer's Wife", "You need a Vraicling for the fields. Vraic's the seaweed we spread on the Royals. Catch one on the shore, in the shallows, and show me. They come in at the tide in rough weather."))],
                 s("Farmer's Wife",
                   "The market's after Royals, is it? We've plenty in the ground, but the old man wants them done properly. Seaweed on the fields, vraic, as his mother did. And a good bout before he'll let one go.",
                   "Catch a Vraicling in the shallows and bring it to show me. Then beat Josué in the field. He's by the lane, and he's been waiting for a challenger since lunchtime.") + sett(Q1 + "_1"))],
              s("Farmer's Wife",
                "I've a bean crock in the oven since last night. Beans, a bit of pork, the trotter, and onions. You put it in with the bread and forget about it. It's the best Sunday dinner there is.",
                "Jersey Royals, black butter, bean crock and ormers. That's an island dinner."))])])])

    # ------------------------------------------------------------ quest: Liberation (Maritime Museum, War Tunnels, Elizabeth Castle)
    put("st_helier_maritime", "sth_tapestry", [
        iff(Q2 + "_done", s("Tapestry Guide",
            "Twelve panels, one for each parish, and every one stitched by islanders, in 1995, for the fiftieth Liberation Day. You've helped tell the story, my friend, and it's rare enough these days."),
        [iff(Q2 + "_started",
             [iff(Q2 + "_2",
                  s("Tapestry Guide",
                    "So the archivist told you about the hidden wirelesses and the castle guide told you about the guns? Then you know what the panels are for. People kept hope alive in the dark, a stitch at a time.",
                    "Liberation Day, 9 May 1945. Crowds on the quay, flags out of every attic, and Union Flags that had spent five years under floorboards. Take this. It's a copy of one of those flags.")
                  + sett(Q2 + "_done") + [item("liberation_flag"), standing(5)],
                  s("Tapestry Guide", "Two people to hear: the archivist at the War Tunnels, up the lane north of town, and the guide at Elizabeth Castle, across the causeway. Come back and tell me what they said."))],
             s("Tapestry Guide",
               "Welcome to the Occupation Tapestry Gallery. The tapestry is twelve panels, one made by each of Jersey's twelve parishes in 1995, fifty years after Liberation. Each tells part of the Occupation story, from the arrival of the Germans to the day the island was freed.",
               "I'm trying to put together a short account for schoolchildren and I need two voices that aren't mine. Would you talk to the archivist at the War Tunnels, and to the guide at Elizabeth Castle? Then come back and tell me what they said.") + sett(Q2 + "_started"))])])
    put("jersey_tunnels", "jer_tunnel_keeper", [
        iff(Q2 + "_1", s("Archivist",
            "Wireless sets were confiscated in 1942, but people hid them in chimneys, inside clocks, under the floors. Listening to the BBC was a punishable offence. A good many went to prison, or were sent away, for the crime of hearing the news.",
            "Tell the Tapestry Guide that. Every household that kept a crystal set was an island of hope."),
        [iff(Q2 + "_started",
             s("Archivist",
               "The Tapestry Guide sent you? Good. Here's what to tell her. Jersey was occupied for five years from 1 July 1940. Islanders were short of food, fuel and news. In 1942 the Germans ordered every wireless to be handed in.",
               "Many hid theirs, and the news from the BBC went from house to house in whispers. The Red Cross ship Vega arrived in December 1944 with parcels. The day the island was liberated was 9 May 1945.") + sett(Q2 + "_1"),
             s("Archivist",
               "Jersey was occupied for five years, from 1 July 1940. Islanders were short of food and fuel by the end. In December 1944 the Red Cross ship Vega brought parcels, and everyone remembers what was in them.",
               "Wireless sets were confiscated in 1942. Many were hidden, and people listened in secret to the BBC. Liberation Day was 9 May 1945. We keep it as a public holiday still."))])])
    put("st_helier_castle", "sth_castle_guide", [
        iff(Q2 + "_2", s("Castle Guide",
            "Welcome to Elizabeth Castle. Raleigh, the Armada, Charles II and, after, the Germans. All of them have left something here. The castle's seen everyone, and the tide still shuts the door twice a day."),
        [iff(Q2 + "_1",
             s("Castle Guide",
               "The Tapestry Guide sent you, and the archivist already told you about the wireless? Then here's my part. The Germans fortified Elizabeth Castle and the whole island with concrete bunkers, gun emplacements and tunnels, using forced labour.",
               "Everywhere you see a bunker on a headland, remember who built it. The island's liberation came on 9 May 1945, and some of those guns never fired a shot. The castle, meanwhile, stayed here, with the tide coming and going as always.") + sett(Q2 + "_2"),
             s("Castle Guide",
               "Welcome to Elizabeth Castle. Sir Walter Raleigh was Governor when it was new, and named it after the queen. He'd have called it Fort Isabella Bellissima; the guidebook says it was 'in her honour', which is kind of him.",
               "Charles II stayed here as a prince, twice, in the Civil War. The island stayed loyal to the king longer than most of England. Then the Germans put guns here too. It's seen everyone, and the tide still shuts the door twice a day."))])])

    # ------------------------------------------------------------ quest: The Little Chapel's China
    put("guernsey_country", "gue_brother", [
        iff(Q3 + "_done", s("Chapel Keeper",
            "That blue shard has gone into the east wall, just above the door. You can see it from the lane. Every time the sun hits it, I smile. Mèrcie, my friend. That's thank you, in the old tongue."),
        [iff(Q3 + "_started",
             [iff(Q3 + "_2",
                  s("Chapel Keeper",
                    "A shell from Cobo Bay and a bit of blue-and-white china? Wonderful. Brother Déodat would have wept. He collected every piece with his own hands, and visitors still bring us their cracked plates.",
                    "Please take this pebble. It came off the wall long ago and it's been in the keeper's pocket ever since. It has the Little Chapel's own good luck.")
                  + sett(Q3 + "_done") + [item("chapel_pebble"), standing(4)],
                  s("Chapel Keeper", "A shell from the beachcomber at Cobo Bay, and a bit of blue-and-white china from the baker in St Peter Port. That's all I'm after. The chapel's always being mended, one fragment at a time."))],
             s("Chapel Keeper",
               "Welcome to the Little Chapel. The walls are covered with pebbles, shells and bits of broken china, and people keep bringing more. We've a bare patch above the door, and I've been waiting for just the right pieces.",
               "Could you fetch me a pretty shell from the beachcomber at Cobo Bay, to the west, and a piece of blue-and-white china from the baker in St Peter Port? I'd go myself, but I have the gardens.") + sett(Q3 + "_started"))])])
    put("guernsey_country", "gue_beachcomber", [
        iff(Q3 + "_1", s("Beachcomber", "Hello again. I've your shell in my pocket still, did you want it twice? No, I see. Right. Tell the Brother the ormer rules are the same as ever."),
        [iff(Q3 + "_started",
             [when("caught_pinchkin",
                   s("Beachcomber",
                     "A Pinchkin! Lovely creature. They're a small crab that thinks it's a castle. You've earned a shell. Here it is: a little pearly one, a bit of the ormer, which is a sea snail with a mother-of-pearl inside.",
                     "Tell the Brother it's from Cobo, where the sunsets are the best in the Channel. And mind how you gather ormers. Only on certain tides, never by diving, and by hand.") + sett(Q3 + "_1"),
                   s("Beachcomber", "Shells for the Little Chapel? I've dozens, but I'll only swap with someone who's befriended a crab. Catch me a Pinchkin in the shallows and I'll give you my best."))],
             s("Beachcomber",
               "I walk this beach every day. Cobo's sunsets are the best in the Channel, and the tide goes out so far you could walk to Alderney, almost. Not quite.",
               "I pick up shells, glass and bits of china. Some of them end up in the Little Chapel. Ormer shells are the best. Mother-of-pearl inside, and only found where the rules are kept."))])])
    put("st_peter_port_bakery", "spp_baker", [
        iff(Q3 + "_2", s("Baker", "Hello again. Mind the oven, and have a slice of gâche on the house. Are you still collecting for the chapel? Marvellous."),
        [iff(Q3 + "_1",
             s("Baker",
               "For the Little Chapel? Of course. I've a saucer that cracked in the oven, blue and white, a good one. Brother Déodat used to collect broken crockery from every house on the island. A bit of my own was in there before I was born.",
               "Here you are. Give it to the Brother with my love, and tell him he still owes me for the last tray of gâche.") + sett(Q3 + "_2"),
             s("Baker",
               "Gâche, hot out of the oven. Raisins, peel and a lot of butter. You cut it thick and spread it thicker. And if you want something to wash it down, we've a pot of tea going.",
               "The old bakers used to bake everyone's bean jar in the cooling oven on a Saturday night. We keep that spirit alive, at higher prices."))])])

    # ------------------------------------------------------------ the Black Dog of Bouley Bay
    put("jersey_country", "tchian_spot", [
        iff("caught_tchian", [], [
            when("night", tchian_meet(), [when("fog", tchian_meet(), s("", "A dip in the cliff path, where the grass has been flattened by something large. It is only a patch of grass. Probably. Come back after dark, or in the fog."))])])])
    put("jersey_country", "tchian_spot_unused", s("", "Nothing."))


def tchian_meet():
    return [
        iff("tchian_met",
            s("", "Two points of light hang in the dark on the cliff path, steady as lamps. They are looking at you."),
            s("", "The wind drops. Down on the path above Bouley Bay, something large and black has stopped walking. Two eyes like lit lamps turn, and the path is suddenly very quiet.",
              "It's a dog the size of a pony, with eyes like lamps and a tail as long as the path. It doesn't growl. It simply waits, the way old dogs wait at gates.",
              "Tchian, the old Jersey word for dog. The Black Dog of Bouley Bay. They say a person who meets him on the cliff path won't see the year out. But the stories never say whether he bites. And, curiously, nobody's ever been bitten.") + sett("tchian_met")),
        {"do": "legend", "species": "tchian", "level": 42, "flag": "caught_tchian", "music": "legend_hound2"},
        iff("caught_tchian", s("", "The dog walks beside you along the cliff path, all the way to the lane. It doesn't look round once. When you turn at the gate, there's only the sea, the stars and a very small dent in the grass."), [])]
