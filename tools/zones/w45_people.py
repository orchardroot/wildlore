#!/usr/bin/env python3
"""Wave 45 session G, People of these isles: heritage plaques, people to meet and short quests on the many peoples of
these isles, all tallied on the Gazetteer's These Isles page (core/these_isles.gd, data/these_isles.json).

Run once on clean data (it refuses a zone it has already done). It places plaques and people on free, reachable floor tiles that block
nothing (a lectern is read from the tile below it, so that one must be reachable too).
Usage: python3 -I tools/zones/w45_people.py   (from the repo root)
"""
import json
import os
import re
from collections import deque

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
ZONES = os.path.join(ROOT, 'data', 'zones')
DIALOGUE = os.path.join(ROOT, 'data', 'dialogue')
WALK_TILES = {'grass', 'tall_grass', 'path', 'road', 'cobbles', 'sand', 'flowers', 'shallow', 'door', 'floor_wood',
              'floor_tile', 'platform', 'level_crossing'}
WALK = set('.,#=:sfwD|+_&')

# --- plaques: (id, zone, near x,y or None, title, theme, text) ---------------------------------------------------------
PLAQUES = [
    ('london_windrush', 'london', None, 'Empire Windrush', 'windrush',
     "On 22 June 1948 the passengers of the Empire Windrush came ashore at Tilbury, down the Thames from here. Hundreds "
     "had sailed from the Caribbean, answering Britain's call for workers after the war. Many stayed first in a deep "
     "air-raid shelter at Clapham South, and the nearest labour exchange was in Brixton. Since 2018, 22 June has been "
     "Windrush Day."),
    ('london_claudia_jones', 'london', None, 'Claudia Jones', 'windrush',
     "Claudia Jones, born in Trinidad in 1915, founded the West Indian Gazette in Brixton in 1958 and organised a "
     "Caribbean carnival at St Pancras Town Hall in January 1959, one of the roots of the Notting Hill Carnival. She is "
     "buried in Highgate Cemetery, beside Karl Marx. Not a bad neighbour for an argument."),
    ('london_naoroji', 'london', None, 'Dadabhai Naoroji', 'south_asian',
     "In 1892 Dadabhai Naoroji, a Parsi scholar and businessman from Bombay, was elected Liberal MP for Finsbury Central "
     "by just five votes, the first Asian member of the House of Commons. He argued that British rule was draining "
     "India's wealth, and India remembers him as its Grand Old Man."),
    ('london_noor_inayat_khan', 'london', None, 'Noor Inayat Khan', 'south_asian',
     "Noor Inayat Khan, daughter of an Indian Sufi teacher, grew up in Paris and wrote stories for children. In 1943 "
     "she was flown into occupied France as a secret wireless operator for the SOE, the first woman sent in that role. "
     "Betrayed and captured, she was killed at Dachau in 1944. She was awarded the George Cross, and her statue stands "
     "in Gordon Square."),
    ('london_seacole', 'london', None, 'Mary Seacole', 'black_britain',
     "Mary Seacole, born in Kingston, Jamaica, in 1805, learnt healing from her mother. When the War Office turned "
     "down her offer to nurse in the Crimean War, she went anyway, at her own expense, and ran the British Hotel near "
     "Balaclava, feeding and nursing soldiers. Her statue has stood outside St Thomas' Hospital since 2016."),
    ('london_brick_lane', 'london', None, '59 Brick Lane', 'huguenots',
     "The building on the corner of Brick Lane and Fournier Street went up in 1743 as a chapel for Huguenot refugees. "
     "It became a Methodist chapel, then in 1898 a synagogue for Jewish refugees from eastern Europe, and since 1976 it "
     "has been the Brick Lane Jamme Masjid, a mosque for the Bangladeshi community. Same walls, three faiths, one long "
     "story of arriving."),
    ('london_bevis_marks', 'london', None, 'Bevis Marks', 'jewish',
     "Jews were expelled from England in 1290 and allowed back under Oliver Cromwell in 1656. Bevis Marks Synagogue in "
     "the City opened in 1701, built by Sephardi Jews whose families had come from Spain and Portugal by way of "
     "Amsterdam. It is the oldest synagogue in Britain still in use."),
    ('london_southall', 'london', None, 'Southall', 'south_asian',
     "Punjabi families began settling in Southall, in west London, in the 1950s, working in local factories and later "
     "at Heathrow. The station sign is written in English and in Punjabi's Gurmukhi script, and the Sri Guru Singh "
     "Sabha gurdwara, opened in 2003, is one of the largest Sikh temples outside India."),
    ('lincoln_pig_and_pork', 'lincoln', None, 'Pig and Pork', 'normans',
     "After 1066 the Normans ruled in French while the English farmed in English, and you can still taste it. The "
     "animal in the field kept its Old English name: cow, pig, sheep. The meat on the Norman table took a French one: "
     "beef from boeuf, pork from porc, mutton from mouton. Lincoln's castle, begun in 1068, is where the new lords ate it."),
    ('liverpool_chinese_arch', 'liverpool', None, 'The Chinatown Arch', 'chinese',
     "Chinese seamen began settling by the docks after Alfred Holt's Blue Funnel Line started sailing between Liverpool "
     "and China in 1866, and Liverpool's Chinatown is one of the oldest in Europe. The great arch on Nelson Street was "
     "put up in 2000 by craftsmen from Shanghai, Liverpool's twin city since 1999."),
    ('liverpool_chinese_seamen', 'liverpool', None, 'The Chinese Seamen', 'chinese',
     "In the Second World War thousands of Chinese merchant seamen sailed from Liverpool and kept Britain supplied. In "
     "1945 and 1946 the government quietly shipped hundreds of them back to China, many without a chance to say goodbye "
     "to the Liverpool wives and children they left behind. A memorial plaque at the Pier Head, unveiled in 2006, "
     "remembers them."),
    ('liverpool_wootton', 'liverpool', None, 'Charles Wootton', 'black_britain',
     "In June 1919, with work scarce after the war, white mobs attacked Black sailors and their families across "
     "Liverpool. Charles Wootton, a young ship's fireman who had served in the Royal Navy, was chased into Queens Dock "
     "and drowned. A centre for adult education in the city was later named after him."),
    ('liverpool_lilian_bader', 'liverpool', None, 'Lilian Bader', 'black_britain',
     "Lilian Bader was born in Liverpool in 1918, the daughter of a seaman from Barbados who had served in the "
     "First World War. In 1941 she joined the Women's Auxiliary Air Force, one of the first Black women in the British "
     "armed forces, trained as an instrument repairer and was made an acting corporal."),
    ('liverpool_1847', 'liverpool', None, "Black '47", 'irish',
     "In 1847, the worst year of the Great Famine, around 300,000 people landed in Liverpool from Ireland. Some went on "
     "to America, but many stayed, crowded into courts and cellars near the docks, and Liverpool became one of the most "
     "Irish cities anywhere. Plenty of Scousers can trace a line back to that crossing."),
    ('cardiff_tiger_bay', 'cardiff', None, 'Tiger Bay', 'tiger_bay',
     "Butetown, the docklands everyone called Tiger Bay, grew up round the busiest coal port in the world. From the late "
     "1800s sailors from Somalia, Yemen, the Caribbean, West Africa, Norway and dozens of other places settled here, "
     "making it one of the oldest multi-ethnic communities in Britain and home to one of its oldest Muslim communities."),
    ('cardiff_shirley_bassey', 'cardiff', None, 'Shirley Bassey', 'tiger_bay',
     "Dame Shirley Bassey was born in Tiger Bay in 1937, the youngest of seven children of a Nigerian seaman and an "
     "English mother. She sang in local pubs and clubs as a teenager and went on to sing three James Bond themes, "
     "Goldfinger among them. Butetown still claims her, loudly."),
    ('dublin_viking', 'dublin', None, 'Dyflin', 'norse',
     "Viking ships wintered on the Liffey in 841, by a dark pool the Irish called Dubh Linn, and the Norse town of Dyflin "
     "grew into Ireland's busiest port. Digs at Wood Quay in the 1970s found its houses, streets and workshops. A "
     "longship built here around 1042 was found sunk in Denmark, and a replica sailed home to Dublin in 2007."),
    ('dublin_huguenot_cemetery', 'dublin', None, 'The Huguenot Cemetery', 'huguenots',
     "Huguenots, French Protestants driven out by persecution, came to Dublin in large numbers after 1685, bringing "
     "silk weaving, poplin and banking. Their small cemetery on Merrion Row opened in 1693. Huguenot names live on in "
     "the city: the La Touche bank, and the writers Charles Maturin and Sheridan Le Fanu."),
    ('dublin_jewish_museum', 'dublin', None, 'Little Jerusalem', 'jewish',
     "Jewish families fleeing persecution in the Russian Empire settled round Portobello from the 1880s, and the streets "
     "got the nickname Little Jerusalem. The Irish Jewish Museum on Walworth Road, in a former synagogue, was opened in "
     "1985 by Chaim Herzog, who grew up in Dublin. And Joyce made Leopold Bloom, the hero of Ulysses, a Dublin Jew."),
    ('dublin_famine_figures', 'dublin', None, 'The Famine Figures', 'irish',
     "On Custom House Quay stand Rowan Gillespie's thin bronze figures, put up in 1997, walking towards the emigrant "
     "ships. In the Great Famine of 1845 to 1852, after blight destroyed the potato crop, about a million people died and "
     "at least a million more left Ireland. The island's population has never got back to its 1840s peak."),
    ('belfast_chaim_herzog', 'belfast', None, 'Chaim Herzog', 'jewish',
     "Chaim Herzog was born in Belfast in 1918, where his father Yitzhak Herzog was the city's rabbi before becoming Chief "
     "Rabbi of Ireland. Chaim grew up in Dublin, fought in the British Army in the Second World War and became the sixth "
     "President of Israel in 1983."),
    ('edinburgh_gododdin', 'edinburgh', None, 'Y Gododdin', 'celts',
     "Around the year 600 the Gododdin, a British people whose stronghold was Din Eidyn, here at Edinburgh, rode south "
     "to battle at Catraeth, probably Catterick in Yorkshire, and hardly any came back. The poem that mourns them, Y "
     "Gododdin, is one of the oldest in Welsh. So one of the oldest Welsh poems is about Edinburgh."),
    ('edinburgh_wojtek', 'edinburgh', None, 'Wojtek the Soldier Bear', 'eastern_european',
     "Wojtek was a Syrian brown bear cub adopted by soldiers of the Polish II Corps in Iran in 1942. Enlisted so he could "
     "travel with them, he is said to have carried ammunition at Monte Cassino in 1944. After the war his unit came to "
     "Scotland, and he lived at Edinburgh Zoo until 1963. His statue is in Princes Street Gardens."),
    ('newcastle_regina', 'newcastle', None, 'Regina and Barates', 'romans',
     "At Arbeia, the Roman fort at South Shields, a tombstone found in 1878 remembers Regina, a freedwoman of the "
     "Catuvellauni, a British tribe, who died aged 30. Her husband Barates came from Palmyra in Syria, and he added a "
     "line in his own Palmyrene Aramaic: Regina, freedwoman of Barates, alas. Roman Tyneside was full of people from "
     "everywhere."),
    ('newcastle_bede', 'newcastle', None, 'Bede of Jarrow', 'anglo_saxons',
     "Bede spent almost his whole life as a monk at Wearmouth and Jarrow, a few miles down the Tyne, and in 731 finished "
     "his Ecclesiastical History of the English People, the first history of the English. He also made counting years "
     "from the birth of Christ, AD, the normal way to date them."),
    ('york_ivory_bangle_lady', 'york', None, 'The Ivory Bangle Lady', 'romans',
     "In 1901 a stone coffin was dug up on Sycamore Terrace: a wealthy woman buried in the late 300s with ivory and jet "
     "bangles and a blue glass jug. In 2010 researchers found she probably had North African ancestry. Roman York was "
     "a mixed city; the emperor Septimius Severus, born in what is now Libya, died here in 211."),
    ('kilkenny_statutes', 'kilkenny', None, 'The Statutes of Kilkenny', 'normans',
     "The Normans landed in Ireland in 1169, and within two centuries many had gone native, speaking Irish, wearing Irish "
     "dress and marrying into Irish families: more Irish than the Irish themselves, as the saying went. In 1366 a "
     "parliament here passed the Statutes of Kilkenny to stop it, banning settlers from Irish speech, law and marriage. "
     "It did not work."),
    ('limerick_norse', 'limerick', None, 'Norse Limerick', 'norse',
     "Norse raiders sailed up the Shannon and around 922 built a base on King's Island, the start of the town of "
     "Limerick. In 968 the Dál gCais kings Mathgamain and his brother Brian Boru beat them at Sulcoit and took the town. "
     "The Norse stayed on as Limerick merchants, and in time as Limerick people."),
    ('brighton_dean_mahomed', 'brighton', None, 'Sake Dean Mahomed', 'south_asian',
     "Sake Dean Mahomed, from Patna in India, was the first Indian to publish a book in English, in 1794, and opened "
     "London's first Indian restaurant, the Hindoostane Coffee House, in 1810. In Brighton he ran a seafront bath house "
     "offering shampooing, an Indian massage, and became Shampooing Surgeon to George IV. Every bottle of shampoo owes "
     "him a nod."),
    ('dover_walter_tull', 'dover', None, 'Walter Tull', 'black_britain',
     "Walter Tull was born in Folkestone, just along the coast, in 1888, the son of a carpenter from Barbados. Orphaned "
     "young, he became a professional footballer with Tottenham Hotspur and Northampton Town, joined the army in 1914 "
     "and became one of the first Black officers in the British Army. He was killed in France on 25 March 1918."),
    ('cambridge_equiano', 'cambridge', None, 'Olaudah Equiano', 'black_britain',
     "Olaudah Equiano was kidnapped as a child in what is now Nigeria and enslaved. He bought his freedom in 1766 and in "
     "1789 published his life story, The Interesting Narrative, a bestseller and a weapon in the campaign against the "
     "slave trade. In 1792 he married Susannah Cullen at Soham, up the road in Cambridgeshire."),
    ('oxford_lhuyd', 'oxford', None, 'Edward Lhuyd', 'celts',
     "Edward Lhuyd, a Welshman who ran the Ashmolean Museum, travelled through Wales, Cornwall, Brittany, Ireland and "
     "Scotland collecting words. In 1707, in his Archaeologia Britannica, he showed that Welsh, Cornish, Breton, Irish "
     "and Scottish Gaelic were related: the family we now call the Celtic languages."),
    ('birmingham_balti', 'birmingham', None, 'The Balti', 'south_asian',
     "Birmingham's Pakistani and Kashmiri cooks made the balti famous from the 1970s: a curry cooked fast over a high "
     "flame and served sizzling in the thin steel bowl it was cooked in, with naan to scoop it up. Sparkbrook, Balsall "
     "Heath and Moseley became the Balti Triangle. Its exact origins are argued over, usually over a balti."),
    ('manchester_cheetham_hill', 'manchester', None, 'Cheetham Hill', 'jewish',
     "Jewish families from Germany, Russia, Poland and Lithuania settled in Cheetham Hill from the 1800s, many working in "
     "tailoring and the raincoat trade. The Spanish and Portuguese Synagogue on Cheetham Hill Road, built in 1874 in a "
     "Moorish style, is now the Manchester Jewish Museum."),
    ('glasgow_arandora_star', 'glasgow', None, 'The Arandora Star', 'italians',
     "When Italy joined the war in June 1940, Italian men all over Britain, many of them cafe owners who had lived here "
     "for decades, were rounded up as enemy aliens. On 2 July the Arandora Star, taking internees to Canada, was sunk by a "
     "U-boat off Ireland, and more than 400 Italians died, many from Scotland. A garden at St Andrew's Cathedral in "
     "Glasgow remembers them."),
    ('carlisle_appleby_fair', 'carlisle', None, 'Appleby Fair', 'travellers',
     "Every June thousands of Gypsies and Travellers gather at Appleby-in-Westmorland, up the River Eden from here, for "
     "the biggest horse fair of its kind in Europe: trading, washing horses in the river and showing them off along the "
     "flashing lane. Romani people have been recorded in Britain since the early 1500s; their language came with them "
     "from northern India."),
    ('galway_ballinasloe', 'galway', None, 'Ballinasloe Fair', 'travellers',
     "Every October Ballinasloe, east of here in County Galway, holds one of the oldest horse fairs in Europe, and Irish "
     "Travellers have long been at its heart. Travellers, who call themselves Mincéirí and have their own language, "
     "Cant, were recognised by the Irish State as an ethnic minority in 2017."),
]

# existing plaques that belong on the These Isles page: id -> theme
TAGS = {
    'glasgow_strathclyde': 'celts', 'holyhead_hut_circles': 'celts',
    'dover_painted_house': 'romans', 'lancaster_roman_rider': 'romans',
    'potteries_hoard': 'anglo_saxons', 'devon_exeter_book': 'anglo_saxons', 'penshaw_biscop_glass': 'anglo_saxons',
    'lake_district_norse_words': 'norse', 'yorkshire_dales_norse': 'norse', 'shetland_norse': 'norse',
    'kirkwall_maeshowe': 'norse',
    'channel_islands_jerriais': 'normans', 'eastanglia_norwich_castle': 'normans',
    'canterbury_weavers': 'huguenots', 'eastanglia_strangers': 'huguenots',
    'lincoln_jews_house': 'jewish', 'pennines_kirkgate_market': 'jewish',
    'cork_annie_moore': 'irish',
    'liverpool_slavery': 'black_britain', 'lancaster_captured_africans': 'black_britain',
    'bristol_peros_bridge': 'black_britain',
    'bristol_bus_boycott': 'windrush',
    'brighton_pavilion_hospital': 'south_asian',
}
# small fixes to existing plaque text, so the tag makes sense on the page
TEXT_FIX = {
    'pennines_kirkgate_market': ("Michael Marks, a refugee from the Russian Empire", "Michael Marks, a Jewish refugee from the Russian Empire"),
}


def say(who, text):
    return {"do": "say", "who": who, "text": text}


def met(pid):
    return {"do": "set", "flag": "isles_met_" + pid}


def quest_giver(who, q, intro, ask, ask_yes, nudge, checks, reward, done_line):
    """The usual quest-giver shape: done / ready to hand in / started / not yet started. `checks` are the flags that
    must all be set before the hand-in."""
    hand_in = reward + [{"do": "set", "flag": "q_isles_%s_done" % q}]
    ready = hand_in
    for f in reversed(checks):
        ready = [{"do": "if", "flag": f, "then": ready, "else": nudge}]
    tmp = "_t_isles_" + q
    start = intro + [
        {"do": "choice", "text": ask, "options": ["Yes, of course", "Maybe later"], "set": tmp},
        {"do": "if", "flag": tmp, "eq": 0, "then": ask_yes + [{"do": "set", "flag": "q_isles_%s_started" % q}],
         "else": [say(who, "No bother. I'll be here.")]},
    ]
    return [{"do": "if", "flag": "q_isles_%s_done" % q, "then": done_line,
             "else": [{"do": "if", "flag": "q_isles_%s_started" % q, "then": ready, "else": start}]}]


# --- people: (id, zone, near, name, sprite, theme, page line, script commands) -------------------------------------
M = 'Marcia'
L = 'Lily'
A = 'Amina'
MA = 'Maura'
PEOPLE = [
    ('marcia', 'london', None, 'Marcia', 'isles_marcia', 'windrush', 'Windrush granddaughter, Brixton',
     [met('marcia')] + quest_giver(M, 'windrush',
        [say(M, "{greeting} I'm Marcia. My grandad came over on the Windrush in 1948, a carpenter from Kingston with one suitcase and a good coat. The coat was not good enough for a London February."),
         say(M, "People forget the invitation. Britain needed hands after the war, for the buses, the hospitals and the railways, and the Caribbean answered."),
         say(M, "In 2018 it came out that some of the Windrush generation were being told they had no right to be here, after a lifetime of work. Some lost their jobs; some were even deported. That's the Windrush scandal, and part of why we mark Windrush Day.")],
        "Help Marcia mark Windrush Day?",
        [say(M, "Lovely. Read the Windrush plaque, and the one for Claudia Jones, the woman who gave London its carnival. Then come and tell me.")],
        [say(M, "Two plaques: the Windrush, and Claudia Jones. They're both in town. I'll put the kettle on.")],
        ['plaque_london_windrush', 'plaque_london_claudia_jones'],
        [say(M, "You read them both? Then you know more than my nephew, and he's thirty."),
         say(M, "Here. A whistle from my first Notting Hill Carnival, in 1979. Blow it gently; the neighbours have opinions."),
         {"do": "give_item", "item": "isles_carnival_whistle"},
         {"do": "standing", "nation": "england", "amount": 2}],
        [say(M, "Grandad used to say the cold was the easy part. The signs in the boarding-house windows were harder. He outlived every one of those signs, and he made sure to tell us so.")])),
    ('rahima', 'london', None, 'Rahima', 'isles_rahima', 'south_asian', 'Brick Lane, family from Sylhet',
     [met('rahima'),
      say('Rahima', "{greeting} I'm Rahima. My family's from Sylhet, in Bangladesh. Most British Bangladeshis are; walk down Brick Lane and you'll hear more Sylheti than anything."),
      say('Rahima', "Sylheti seamen were cooking and stoking on British ships long before the 1950s. Some came ashore in London and opened cafes. That's the curry house's family tree, more or less."),
      say('Rahima', "In 1978 a young garment worker called Altab Ali was murdered on his way home from work, for nothing but who he was. Thousands marched. The park near where he died is Altab Ali Park now."),
      say('Rahima', "Brick Lane has had Huguenots, Jews and us. Every lot got told they'd never fit in, and every lot made the street better. Have a samosa.")]),
    ('lily', 'liverpool', None, 'Lily', 'isles_lily', 'chinese', "Chinatown, a seaman's granddaughter",
     [met('lily')] + quest_giver(L, 'chinatown',
        [say(L, "{greeting} I'm Lily. My grandad sailed out of Liverpool for the Blue Funnel Line. In 1946 he was put on a ship back to China, and my nan was told nothing. Nothing at all."),
         say(L, "She thought he'd left her. For years. It was only much later that families found out the government had sent the men away.")],
        "Help Lily remember the seamen?",
        [say(L, "Would you read the plaque about the seamen for me, and the one about the arch on your way? I like knowing someone else has read them.")],
        [say(L, "The seamen's plaque and the arch, love. Both in town.")],
        ['plaque_liverpool_chinese_seamen', 'plaque_liverpool_chinese_arch'],
        [say(L, "Thank you. That memorial took sixty years to go up. Sixty years."),
         say(L, "Here, a red envelope, a lai see. We give them at New Year for luck. By rights there'd be money in it, but the luck's the important bit."),
         {"do": "give_item", "item": "isles_lai_see"},
         {"do": "standing", "nation": "england", "amount": 2}],
        [say(L, "Come back for Chinese New Year. Lion dancers, firecrackers, and half of Liverpool pretending they've always liked dim sum.")])),
    ('dot', 'liverpool', None, 'Dot', 'isles_dot', 'black_britain', 'A Liverpool-born Black Scouser, several generations in',
     [met('dot'),
      say('Dot', "{greeting} Dot. Liverpool-born Black Scouser, like my mam, and her dad, and his dad. People ask where I'm really from. Toxteth, love. Next question."),
      say('Dot', "Liverpool's Black community is one of the oldest in Britain. Sailors from West Africa and the Caribbean settled near the docks long before Windrush."),
      say('Dot', "My mam always talked about Lilian Bader, a Liverpool girl who joined the WAAF in the war and fixed aircraft instruments. There's a plaque. Give it some footfall."),
      say('Dot', "The residents of Granby Four Streets did their own houses up when the council had given up on them. Won the Turner Prize, that, in 2015. A street, winning art's biggest prize. Only in Liverpool.")]),
    ('amina', 'cardiff', None, 'Amina', 'isles_amina', 'tiger_bay', "Butetown, a stoker's great-granddaughter",
     [met('amina')] + quest_giver(A, 'tiger_bay',
        [say(A, "{greeting} Shwmae! I'm Amina. My great-grandad came to Cardiff from Somaliland as a ship's fireman, shovelling coal in the stokehold. Hottest job at sea, he said, and he'd know."),
         say(A, "Butetown has had Somali and Yemeni families for more than a hundred years. We're as Cardiff as the castle. Older than some of it, actually.")],
        "Learn about Tiger Bay with Amina?",
        [say(A, "Go and read the Tiger Bay plaque, then find Mr Saleh. Everyone calls him Grandad. He'll tell you about the Yemeni side, at length, with biscuits.")],
        [say(A, "The Tiger Bay plaque, then Mr Saleh. He'll be the one with the flat cap and the opinions.")],
        ['plaque_cardiff_tiger_bay', 'isles_met_saleh'],
        [say(A, "He gave you the biscuits? He likes you, then."),
         say(A, "Here. A lump of Welsh steam coal, polished. It's what brought everyone here, in the end. Keep it in your pocket and remember the stokers."),
         {"do": "give_item", "item": "isles_steam_coal"},
         {"do": "standing", "nation": "wales", "amount": 2}],
        [say(A, "Diolch, and mahadsanid. That's thank you in Welsh and in Somali. In Butetown you get both.")])),
    ('saleh', 'cardiff', None, 'Mr Saleh', 'isles_saleh', 'tiger_bay', 'Butetown, son of a Yemeni sailor',
     [met('saleh'),
      say('Mr Saleh', "{greeting} Saleh. My father came from Aden, in Yemen, on the coal boats in the 1930s, and married a girl from Splott. Her mam nearly fainted. Then she learnt to make his coffee and wouldn't let anyone else touch the pot."),
      say('Mr Saleh', "Yemeni sailors opened boarding houses here, and cafes, and a place to pray. Our lot have been part of this city since before your grandparents were born."),
      say('Mr Saleh', "We kept Ramadan, we cheered for Wales, and we argued about Cardiff City. Faith is one thing. Football is serious."),
      {"do": "if", "flag": "q_isles_tiger_bay_started", "then": [say('Mr Saleh', "Amina sent you? Tell her the biscuits are better at mine. Here, have one. Have two.")]}]),
    ('hussain', 'birmingham', None, 'Mr Hussain', 'isles_hussain', 'south_asian', 'Balti Triangle, family from Mirpur',
     [met('hussain'),
      say('Mr Hussain', "{greeting} Welcome to the Balti Triangle. My dad came from Mirpur, in Pakistani Kashmir, in the 1960s. When the Mangla Dam was built, whole villages went under the water, and a lot of Mirpuri families came to Britain."),
      say('Mr Hussain', "He worked in a foundry first. Then the restaurant. Then he made me do my homework at table six. Every night. Table six."),
      say('Mr Hussain', "Balti means bucket, more or less, in Urdu and Punjabi. Don't tell the customers. They think it sounds romantic.")]),
    ('gill', 'birmingham', None, 'Mr Gill', 'isles_gill', 'south_asian', 'Retired bus driver, Sikh',
     [met('gill'),
      say('Mr Gill', "{greeting} Sat Sri Akal. That's the Sikh greeting, in Punjabi. I drove buses in this city for thirty-one years."),
      say('Mr Gill', "In 1967, over in Wolverhampton, a young Sikh driver called Tarsem Singh Sandhu was sent home for coming to work in his turban. There were marches, and in 1969 the bus company gave way. Every driver in a turban since owes him one."),
      say('Mr Gill', "Sikh soldiers fought for Britain in both world wars. In Smethwick there's a statue of one, the Lions of the Great War, put up in 2018. Go and say hello. He won't say much back.")]),
    ('kasia', 'manchester', None, 'Kasia', 'isles_kasia', 'eastern_european', 'Polish deli, Manchester',
     [met('kasia'),
      say('Kasia', "{greeting} Dzień dobry! That's good day, in Polish. Say JEN DOH-bri. Close enough and you get a pączek."),
      say('Kasia', "My great-grandad flew Hurricanes with 303 Squadron in the Battle of Britain: Poles flying for Britain after they'd lost their own country. After the war many couldn't go home to a Poland under Soviet control, so they stayed. Parliament passed a law to resettle them, in 1947."),
      say('Kasia', "Then in 2004 Poland joined the EU and lots more of us came, me included. Polish is the second most spoken language in England now. Pierogi next to pasties. Everybody wins.")]),
    ('gina', 'glasgow', None, 'Gina', 'isles_gina', 'italians', 'Italian-Scots cafe owner, family from Barga',
     [met('gina'),
      say('Gina', "{greeting} Buongiorno! I'm Gina. My great-granny came from Barga, in Tuscany. So many Barghigiani came to Scotland that they call Barga the most Scottish town in Italy."),
      say('Gina', "The Italians gave Scotland its cafes, its ice cream and a fair few of its chip shops. Scotland gave us the rain. Fair swap."),
      say('Gina', "In 1940 my great-grandad was lifted as an enemy alien, after forty years in Glasgow. He should have been on the Arandora Star. He missed it, by luck. Plenty didn't.")]),
    ('lee', 'carlisle', None, 'Mrs Lee', 'isles_lee', 'travellers', 'Romany, on her way to Appleby Fair',
     [met('lee'),
      say('Mrs Lee', "{greeting} Mrs Lee. I'm Romany, and I'm on my way to Appleby for the fair, same as every June since I was in a pram."),
      say('Mrs Lee', "Our people came from India, a long way round, a long time ago. You use our words without knowing. Pal comes from our word for brother. Cushty's our kushti: good."),
      say('Mrs Lee', "June is Gypsy, Roma and Traveller History Month. Come to Appleby and watch the horses washed in the Eden. Mind your shoes.")]),
    ('bridget', 'galway', None, 'Bridget', 'isles_bridget', 'travellers', 'Irish Traveller',
     [met('bridget'),
      say('Bridget', "{greeting} I'm Bridget, a Traveller. We call ourselves Mincéirí, and we have our own language, Cant. You'll not learn it off me, mind. It's ours."),
      say('Bridget', "In 2017 the State finally recognised Travellers as an ethnic minority. My granny cried. She'd been told her whole life we were just settled people who'd fallen on hard times."),
      say('Bridget', "Ballinasloe's in October. Horses, cousins, and arguments about both.")]),
    ('rafael', 'galway', None, 'Rafael', 'isles_rafael', 'new_irish', 'From Goiás in Brazil, now from Gort',
     [met('rafael'),
      say('Rafael', "{greeting} Bom dia! Rafael, from Goiás in Brazil, and now from Gort, County Galway. In the late 1990s a meat plant in Gort took on Brazilian workers, and now the town has Brazilian shops, churches and some very good footballers."),
      say('Rafael', "Ireland spent two hundred years sending people away. Now people come here instead. The Irish understand that better than anyone. Mostly."),
      say('Rafael', "I play Gaelic football now too. It's like football, but you can pick the ball up, and everyone is very angry.")]),
    ('anju', 'dublin', None, 'Anju', 'isles_anju', 'new_irish', 'Nurse, from Kerala',
     [met('anju'),
      say('Anju', "{greeting} Namaskaram! I'm Anju, a nurse, from Kerala in the south of India. There are thousands of Indian nurses in Irish hospitals. Without us the night shift would be a very quiet place."),
      say('Anju', "Ireland was always the country people left. Since the 1990s people come here instead: from Poland, Brazil, Nigeria, China, India, and since 2022 many from Ukraine."),
      say('Anju', "My daughter has a Dublin accent, does Irish dancing and corrects my Irish. I am very proud and a little annoyed.")]),
    ('maura', 'dublin', None, 'Maura', 'isles_maura', 'irish', 'Famine emigrant descendant',
     [met('maura')] + quest_giver(MA, 'famine',
        [say(MA, "{greeting} I'm Maura. My great-great-grandmother walked out of Mayo in 1847 with two children, took the boat from Dublin to Liverpool and never came home. Her sister went on to New York."),
         say(MA, "Nobody wrote it down. You learn it from the gaps in the family, the names that stop.")],
        "Walk the emigrants' road for Maura?",
        [say(MA, "Read the Famine Figures on the quay here, then the plaque in Liverpool for the year she landed. And in Cork they remember Annie Moore, the first through Ellis Island. Then come back and tell me.")],
        [say(MA, "The Famine Figures here, Black '47 in Liverpool, and Annie Moore in Cork. Take your time. She did.")],
        ['plaque_dublin_famine_figures', 'plaque_liverpool_1847', 'plaque_cork_annie_moore'],
        [say(MA, "You went all that way? Then you've done more than most of my cousins."),
         say(MA, "Here. A copy of a steerage ticket, Liverpool to New York, from a museum shop. Not hers. But it could have been."),
         {"do": "give_item", "item": "isles_steerage_ticket"},
         {"do": "standing", "nation": "ireland", "amount": 3}],
        [say(MA, "There are far more people of Irish descent outside Ireland than in it. Seventy million, by some counts. She's in there somewhere.")])),
    ('sigrid', 'york', None, 'Sigrid', 'isles_sigrid', 'norse', 'Viking re-enactor, weekends only',
     [met('sigrid'),
      say('Sigrid', "{greeting} I'm Sigrid. Viking, weekends only. Every February the Jorvik Viking Festival fills York with people like me, and with people pretending not to stare."),
      say('Sigrid', "The Vikings took York in 866 and called it Jorvik. They left you words: sky, egg, knife, window. Window is vindauga, wind-eye, a hole for the wind. They were honest about Yorkshire houses."),
      say('Sigrid', "And every 'gate' in York, Stonegate, Micklegate, is from gata, a street. So in York a gate is a street, a bar is a gate, and a snickelway is an alley. Keep up.")]),
]

QUESTS = [
    {"id": "isles_windrush", "title": "Windrush Day", "region": "isles", "town": "london", "giver": "Marcia",
     "people": "windrush",
     "summary": "Read the plaques to the Empire Windrush and to Claudia Jones, and tell Marcia.",
     "start_flag": "q_isles_windrush_started",
     "steps": [{"flag": "plaque_london_windrush", "text": "Read the Empire Windrush plaque in London.", "zone": "london"},
               {"flag": "plaque_london_claudia_jones", "text": "Read the plaque to Claudia Jones.", "zone": "london"},
               {"flag": "q_isles_windrush_done", "text": "Tell Marcia what you learnt.", "zone": "london"}],
     "done_flag": "q_isles_windrush_done", "reward": "A Carnival Whistle and standing with England."},
    {"id": "isles_chinatown", "title": "The Seamen's Wives", "region": "isles", "town": "liverpool", "giver": "Lily",
     "people": "chinese",
     "summary": "Read the plaques to Liverpool's Chinese seamen and the Chinatown arch for Lily.",
     "start_flag": "q_isles_chinatown_started",
     "steps": [{"flag": "plaque_liverpool_chinese_seamen", "text": "Read the plaque to the Chinese seamen.", "zone": "liverpool"},
               {"flag": "plaque_liverpool_chinese_arch", "text": "Read the plaque about the Chinatown arch.", "zone": "liverpool"},
               {"flag": "q_isles_chinatown_done", "text": "Go back to Lily.", "zone": "liverpool"}],
     "done_flag": "q_isles_chinatown_done", "reward": "A lai see envelope and standing with England."},
    {"id": "isles_tiger_bay", "title": "Stokers and Sailors", "region": "isles", "town": "cardiff", "giver": "Amina",
     "people": "tiger_bay",
     "summary": "Read the Tiger Bay plaque and hear Mr Saleh out, for Amina.",
     "start_flag": "q_isles_tiger_bay_started",
     "steps": [{"flag": "plaque_cardiff_tiger_bay", "text": "Read the Tiger Bay plaque in Cardiff.", "zone": "cardiff"},
               {"flag": "isles_met_saleh", "text": "Find Mr Saleh and hear about the Yemeni sailors.", "zone": "cardiff"},
               {"flag": "q_isles_tiger_bay_done", "text": "Go back to Amina.", "zone": "cardiff"}],
     "done_flag": "q_isles_tiger_bay_done", "reward": "A lump of Welsh steam coal and standing with Wales."},
    {"id": "isles_famine", "title": "The Emigrants' Road", "region": "isles", "town": "dublin", "giver": "Maura",
     "people": "irish",
     "summary": "Follow the Famine emigrants from Dublin to Liverpool and Cork, for Maura.",
     "start_flag": "q_isles_famine_started",
     "steps": [{"flag": "plaque_dublin_famine_figures", "text": "Read the Famine Figures on Custom House Quay.", "zone": "dublin"},
               {"flag": "plaque_liverpool_1847", "text": "Read the plaque to Black '47 in Liverpool.", "zone": "liverpool"},
               {"flag": "plaque_cork_annie_moore", "text": "Read the plaque to Annie Moore in Cork.", "zone": "cork"},
               {"flag": "q_isles_famine_done", "text": "Go back to Maura in Dublin.", "zone": "dublin"}],
     "done_flag": "q_isles_famine_done", "reward": "A Steerage Ticket and standing with Ireland."},
]

ITEMS = [
    {"id": "isles_carnival_whistle", "name": "Carnival Whistle", "kind": "key", "price": 0, "battle": False, "field": True,
     "desc": "Marcia's whistle from Notting Hill Carnival, 1979. Still loud. The neighbours have been warned."},
    {"id": "isles_lai_see", "name": "Lai See", "kind": "key", "price": 0, "battle": False, "field": True,
     "desc": "A red envelope from Lily, given for luck as at Chinese New Year. Empty, but the luck's the important bit."},
    {"id": "isles_steam_coal", "name": "Welsh Steam Coal", "kind": "key", "price": 0, "battle": False, "field": True,
     "desc": "A polished lump of the coal that made Cardiff a world port and brought the stokers of Tiger Bay. From Amina."},
    {"id": "isles_steerage_ticket", "name": "Steerage Ticket", "kind": "key", "price": 0, "battle": False, "field": True,
     "desc": "A museum copy of a steerage ticket, Liverpool to New York. Not Maura's ancestor's, but it could have been."},
]


def load(path):
    with open(path, encoding='utf-8') as f:
        return json.load(f)


def save(path, data):
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=1, ensure_ascii=False)
        f.write('\n')


def grid(z):
    rows = z['rows']
    H, W = len(rows), len(rows[0])
    walk = set(WALK)
    for k, v in z.get('legend_extra', {}).items():
        (walk.add if v.get('tile') in WALK_TILES else walk.discard)(k)
    hs = z.get('heights', [])

    def h(x, y):
        return int(hs[y][x]) if hs and y < len(hs) and x < len(hs[y]) and hs[y][x].isdigit() else 0
    blocked = {(int(p['x']), int(p['y'])) for p in z.get('props', []) if p.get('type') != 'building' and not p.get('walk')}
    blocked |= {(int(s['x']), int(s['y'])) for s in z.get('signs', [])}
    things = set(blocked) | {(int(n['x']), int(n['y'])) for n in z.get('npcs', [])}
    things |= {(int(e['x']), int(e['y'])) for e in z.get('examine', [])}
    warps = [(int(w['x']), int(w['y'])) for w in z.get('warps', [])]

    def ok(x, y, extra):
        return 0 <= x < W and 0 <= y < H and rows[y][x] in walk and (x, y) not in blocked and (x, y) not in extra

    def reach(extra=frozenset()):
        s = (int(z['spawn'][0]), int(z['spawn'][1]))
        seen, q = {s}, deque([s])
        while q:
            x, y = q.popleft()
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                n = (x + dx, y + dy)
                if n not in seen and ok(n[0], n[1], extra) and abs(h(x, y) - h(*n)) <= 1:
                    seen.add(n)
                    q.append(n)
        return seen
    return rows, W, H, reach, things, warps


def place(z, near, npc):
    """A free tile near `near` (default: the spawn) that blocks no path, clear of doors and other things."""
    rows, W, H, reach, things, warps = grid(z)
    base = reach()
    c = near or (int(z['spawn'][0]), int(z['spawn'][1]))
    for (x, y) in sorted(base, key=lambda p: (abs(p[0] - c[0]) + abs(p[1] - c[1]), p[1], p[0])):
        if x < 2 or y < 2 or x >= W - 2 or y >= H - 2 or rows[y][x] in '=D_&':
            continue
        if abs(x - c[0]) + abs(y - c[1]) < 3:
            continue  # not on the spawn's doorstep
        if any(abs(x - a) <= 1 and abs(y - b) <= 1 for (a, b) in things):
            continue
        if any(abs(x - a) <= 2 and abs(y - b) <= 2 for (a, b) in warps):
            continue
        if not npc and (x, y + 1) not in base:
            continue
        if len(reach(frozenset({(x, y)}))) != len(base) - 1:
            continue
        return x, y
    raise SystemExit('no room in %s' % z['id'])


def _item_text(obj, depth):
    pad = ' ' * depth
    return '\n'.join(pad + line for line in json.dumps(obj, indent=1, ensure_ascii=False).split('\n'))


def _insert_items(text, key, items):
    """Puts `items` at the head of the top-level array `key`, leaving the rest of the file exactly as it was."""
    m = re.search(r'^ "%s": \[(\]?)' % key, text, re.M)
    if not m:
        raise SystemExit('no %s array' % key)
    body = ',\n'.join(_item_text(i, 2) for i in items)
    if m.group(1):  # an empty array
        return text[:m.start()] + ' "%s": [\n%s\n ]' % (key, body) + text[m.end():]
    return text[:m.end()] + '\n' + body + ',' + text[m.end():]


def _tag(text, pid, theme):
    def rep(m):
        return '%s"plaque": "%s",\n%s"people": "%s"%s' % (m.group(1), pid, m.group(1), theme, m.group(2))
    return re.sub(r'^(\s*)"plaque": "%s"(,?)$' % re.escape(pid), rep, text, count=1, flags=re.M)


def main():
    # placements come from the untouched files; writing patches the text so diffs stay small. Run it once, on clean data.
    zones, texts = {}, {}

    def zone(zid):
        if zid not in zones:
            path = os.path.join(ZONES, zid + '.json')
            with open(path, encoding='utf-8') as f:
                texts[zid] = f.read()
            if '"isles_' in texts[zid] or any('"%s"' % p[0] in texts[zid] for p in PLAQUES if p[1] == zid):
                raise SystemExit('%s already has this wave\'s people: restore it first' % zid)
            zones[zid] = json.loads(texts[zid])
        return zones[zid]
    anchors = {}

    def anchor(zid):
        z = zone(zid)
        pts = [(int(w['x']), int(w['y']) + 3) for w in z.get('warps', [])]
        k = anchors.get(zid, 0)
        anchors[zid] = k + 1
        return pts[(k * 5 + 2) % len(pts)] if pts else None
    new_signs, new_npcs = {}, {}
    for pid, zid, near, title, theme, text in PLAQUES:
        z = zone(zid)
        x, y = place(z, near or anchor(zid), False)
        sg = {"x": x, "y": y, "plaque": pid, "title": title, "text": text, "people": theme}
        z['signs'].append(sg)
        new_signs.setdefault(zid, []).append(sg)
    for pid, zid, near, name, sprite, theme, line, script in PEOPLE:
        z = zone(zid)
        x, y = place(z, near or anchor(zid), True)
        n = {"facing": "down", "id": "isles_" + pid, "move": "still", "script": "isles_" + pid, "sprite": sprite, "x": x, "y": y}
        z['npcs'].append(n)
        new_npcs.setdefault(zid, []).append(n)
    for zid, t in texts.items():
        if zid in new_signs:
            t = _insert_items(t, 'signs', new_signs[zid])
        if zid in new_npcs:
            t = _insert_items(t, 'npcs', new_npcs[zid])
        json.loads(t)
        with open(os.path.join(ZONES, zid + '.json'), 'w', encoding='utf-8') as f:
            f.write(t)
    # tags on plaques already in the game
    for fn in sorted(os.listdir(ZONES)):
        if not fn.endswith('.json'):
            continue
        path = os.path.join(ZONES, fn)
        with open(path, encoding='utf-8') as f:
            t = f.read()
        old = t
        for pid, theme in TAGS.items():
            if '"plaque": "%s"' % pid in t and '"people": "%s"' % theme not in t.split('"plaque": "%s"' % pid)[1][:40]:
                t = _tag(t, pid, theme)
            if pid in TEXT_FIX and TEXT_FIX[pid][0] in t and TEXT_FIX[pid][1] not in t:
                t = t.replace(*TEXT_FIX[pid])
        if t != old:
            json.loads(t)
            with open(path, 'w', encoding='utf-8') as f:
                f.write(t)
    # dialogue: new scripts appended before the closing brace
    by_zone = {}
    for pid, zid, near, name, sprite, theme, line, script in PEOPLE:
        by_zone.setdefault(zid, {})['isles_' + pid] = script
    for zid, scripts in by_zone.items():
        path = os.path.join(DIALOGUE, zid + '.json')
        with open(path, encoding='utf-8') as f:
            t = f.read().rstrip()
        assert t.endswith('}')
        add = ''.join(',\n "%s": %s' % (k, _item_text(v, 1).lstrip()) for k, v in scripts.items())
        t = t[:-1].rstrip() + add + '\n}\n'
        json.loads(t)
        with open(path, 'w', encoding='utf-8') as f:
            f.write(t)
    # quests, items, the These Isles people list
    save(os.path.join(ROOT, 'data', 'quests', 'isles.json'), {"quests": QUESTS})
    save(os.path.join(ROOT, 'data', 'items', 'isles.json'), ITEMS)
    ti_path = os.path.join(ROOT, 'data', 'these_isles.json')
    ti = load(ti_path)
    ti['people'] = [{"id": p[0], "name": p[3], "theme": p[5], "zone": p[1], "flag": "isles_met_" + p[0], "line": p[6]}
                    for p in PEOPLE]
    save(ti_path, ti)
    print('plaques %d, tags %d, people %d, quests %d' % (len(PLAQUES), len(TAGS), len(PEOPLE), len(QUESTS)))


if __name__ == '__main__':
    main()
