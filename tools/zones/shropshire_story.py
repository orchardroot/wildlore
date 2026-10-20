# Dialogue for the Shropshire zones (shropshire.py): townsfolk in the interiors, the four quests and the
# Devil's Chair. Quest flags are q_shropshire_<quest>_*; see data/quests/shropshire.json.
from wcommon import say

ENG = "england"


def s(who, *lines):
    return say(who, *lines)


def sett(*flags):
    return [{"do": "set", "flag": f} for f in flags]


def iff(flag, then, other=None):
    return {"do": "if", "flag": flag, "then": then, "else": other or []}


def when(cond, then, other=None):
    return {"do": "when", "cond": cond, "then": then, "else": other or []}


def item(i, n=1):
    return {"do": "give_item", "item": i, "n": n}


def standing(n):
    return {"do": "standing", "nation": ENG, "amount": n}


def write(DLG, TRN):
    def put(zone, sid, cmds):
        DLG.setdefault(zone, {})[sid] = cmds

    # ------------------------------------------------------------ quest: Darwin's Beetles (Shrewsbury Library)
    B = "q_shropshire_beetles"
    put("shrewsbury_library", "shr_librarian", [
        iff(B + "_done", s("Librarian",
            "Darwin wrote that no pursuit at Cambridge gave him so much pleasure as collecting beetles. I like to think he started under those trees in the Quarry.",
            "Shh, by the way. It is a library. I'm allowed to say that once a day and I've just used it."),
        [iff(B + "_started", [when("caught_squibbet", s("Librarian",
                "A Squibbet! And it squirted you, didn't it? Then you've collected a beetle exactly as Darwin did.",
                "At Cambridge he once had a rare beetle in each hand, spotted a third, and popped one in his mouth to free a hand. It squirted something burning on his tongue and he lost the lot.",
                "He went on to sail round the world on the Beagle and work out how living things change over time. All from turning over logs. Here, take this; it was found in a donated box of his old books, or so the label says.")
                + sett(B + "_1", B + "_2", B + "_done") + [item("darwin_lens"), standing(3)],
              s("Librarian", "No beetle yet? The Squibbet lives in the long grass in the Quarry and up on the Long Mynd. Ask the head gardener in the Quarry; she knows every log in the park."))],
          s("Librarian",
            "This building was Shrewsbury School when young Charles Darwin was a pupil, from 1818. He boarded here, a few minutes from home, and ran home most evenings anyway.",
            "His headmaster called him a poco curante, a bit of a do-nothing, for messing about with chemistry. He'd rather have been out catching beetles.",
            "Would you do something for the library? Catch a Squibbet, the little beetle creature in the Quarry, and bring it to show me. I want to see a Shrewsbury beetle up close, the way he would have.")
          + sett(B + "_started"))])])
    put("shrewsbury", "shr_gardener", [
        iff(B + "_1", s("Head Gardener", "Long grass in the Quarry, logs by the river, and up on the Long Mynd. Squibbets love a damp log. Mind they don't squirt you."),
            [iff(B + "_started", s("Head Gardener",
                "Beetles for the library? Darwin's old school, I know. Look in the long grass in the Quarry, south of St Chad's, and up on the Long Mynd past Kingsland Bridge.",
                "The Squibbet is the one with the shiny shell. Pick it up and it'll squirt. Young Charles found that out the hard way.") + sett(B + "_1"),
             s("Head Gardener",
               "The Dingle was a quarry pit once. Now it's the prettiest hole in England. Mind the dahlias; they've been entered for August.",
               "If you're after beetles, turn over a log by the river. Gently, and put it back."))])])

    # ------------------------------------------------------------ quest: Iron for the Bridge
    I = "q_shropshire_bridge"
    put("ironbridge_tollhouse", "ib_tollkeeper", [
        iff(I + "_done", s("Toll Keeper", "She's sound as a bell, thanks to you. They charged tolls to cross until 1950, you know. You can go free. Forever, mind."),
            [iff(I + "_2", s("Toll Keeper",
                "Is that it? A new cast bracket, from the Old Furnace itself, made off a pattern from the Flax Mill. Hold it up to the light. Lovely.",
                "The bridge was put together like a wooden barn, dovetails and wedges and all, because nobody yet knew how else to join iron. Every part has to fit just so.",
                "There. She's whole again. Take this ingot as a keepsake, and look after this little one too; a Pigling took a shine to you up at the furnace.")
                + sett(I + "_3", I + "_done") + [item("darby_ingot"), {"do": "give_creature", "species": "pigling", "level": 22}, standing(4)],
             [iff(I + "_1", s("Toll Keeper", "You've got the pattern? Take it up the dale to Darby's Old Furnace, at Coalbrookdale. The furnace master will cast it for you, if you can get past his apprentice."),
              [iff(I + "_started", s("Toll Keeper", "The pattern's at Ditherington Flax Mill, in Shrewsbury, north of the castle. Ask for the mill engineer."),
                s("Toll Keeper",
                  "Welcome to the Tollhouse. Every person and cart that crossed the Iron Bridge used to pay here; there's the board with the prices on.",
                  "Bad news, though. One of the old cast brackets under the deck has cracked in the frost. We need a new one cast the old way, in iron, at Coalbrookdale where the bridge was born.",
                  "The wooden pattern for it is kept up at the Flax Mill in Shrewsbury, of all places, because the mill's engineers were the iron-frame experts. Could you fetch it, and get it cast?")
                + sett(I + "_started"))])])])])
    put("shrewsbury_flaxmill", "shr_engineer", [
        iff(I + "_1", s("Mill Engineer", "Take the pattern up to Coalbrookdale. And tell the furnace master the Flax Mill says hello. He'll pretend not to know us."),
            [iff(I + "_started", s("Mill Engineer",
                "The bridge pattern? We've had it in the cupboard since the last repair. Here. Careful, it's pear wood, older than both of us.",
                "A pattern is the shape the sand mould is pressed round. Pour iron into the hollow and out comes your part. Same trick Darby used on the bridge in 1779.",
                "Mind how you go. The furnace master at Coalbrookdale won't cast for strangers until they've beaten his apprentice. It's tradition. Also he's busy.") + sett(I + "_1"),
             s("Mill Engineer",
               "This mill was built in 1797 for spinning flax into linen thread. Charles Bage designed it with cast-iron columns and beams, so there was no timber to catch fire.",
               "Cast iron is strong when you squash it and weak when you bend it, so Bage shaped his beams like an upside-down T. Every steel-framed skyscraper since is a grandchild of this building.",
               "After the flax, it was a maltings for nearly a century, drying barley for brewers. Now it's been restored, and somebody's always measuring something."))])])
    put("coalbrookdale_furnace", "ib_furnacemaster", [
        iff(I + "_2", s("Furnace Master", "Off you go, the casting won't carry itself. Mind, it's still warm."),
            [iff(I + "_1", [iff("trainer_ib_apprentice", s("Furnace Master",
                "Ned says you beat him. Then you've earned a casting. Give us that pattern.",
                "Into the sand, press, lift, and there's the hollow. Now the iron: coke in, blast on, and wait for it to run.",
                "There. Grey iron, sound as a bell. The same metal that built the bridge, from the same dale. Take it to the toll keeper.") + sett(I + "_2"),
                s("Furnace Master", "Pattern from the Flax Mill, eh? Then you'll know the rule. Beat my apprentice Ned, outside, and I'll cast it."))],
             s("Furnace Master",
               "This is the furnace where Abraham Darby the first smelted iron with coke in 1709. Before that you burnt charcoal, and charcoal meant cutting down whole forests.",
               "Coke is coal baked till the tar and gas are driven off. It burns hot and strong enough to hold up a big charge of ore. Bigger furnaces, cheaper iron, and the Industrial Revolution was away.",
               "Look at the beam over the arch. There's a date cast into it: 1777. That's when Darby the third rebuilt this furnace, just before he cast the bridge."))])])

    # ------------------------------------------------------------ quest: the Wenlock Olympian Games
    G = "q_shropshire_games"
    put("ironbridge_gorge", "ib_secretary", [
        iff(G + "_done", s("Games Secretary", "Our Olympian! Come back in July. Bring your laurel."),
            [iff(G + "_1", [
                {"do": "choice", "text": "Enter the Wenlock Olympian Games? Four events, no rest between.", "options": ["Line me up", "Not yet"], "set": "_wen_choice"},
                {"do": "if", "flag": "_wen_choice", "eq": 0,
                 "then": s("Games Secretary", "Competitors to the Linden Field! On your marks...") + [
                     {"do": "gauntlet", "trainers": ["wen_sprinter", "wen_quoits", "wen_tilter", "wen_champion"], "flag": G + "_2",
                      "exit": {"zone": "ironbridge_gorge", "x": 13, "y": 43}},
                     iff(G + "_2", s("Games Secretary",
                         "All four events! Dr Brookes would have had the band out. Here: a Wenlock medal, as near as we can make it, and a crown of laurel which I'm keeping because it's the only one.")
                         + sett(G + "_done") + [item("wenlock_medal"), standing(4)])],
                 "else": s("Games Secretary", "No hurry. The Games have waited since 1850; they'll wait for you.")}],
             [iff(G + "_started", s("Games Secretary", "Pop into Much Wenlock Museum first and learn the events. The curator will tell you all about Dr Brookes."),
              s("Games Secretary",
                "Welcome to the Linden Field, home of the Wenlock Olympian Games since 1850. Running, jumping, quoits, tilting at the ring, and a great deal of cake.",
                "We're a competitor short for this year's creature pentathlon. Would you have a go? See the curator at the museum first, so you know what you're in for.")
              + sett(G + "_started"))])])])
    put("wenlock_museum", "wen_curator", [
        iff(G + "_started", [iff(G + "_1", s("Curator", "Off to the Linden Field with you. Remember: in quoits, a ringer is when the iron ring lands right over the pin."),
            s("Curator",
              "Dr William Penny Brookes was a Much Wenlock doctor who thought everybody, not just the gentry, should be fit. In 1850 he started the Olympian Class and its yearly Games.",
              "There was running, high jump, quoits, cricket, football, and tilting at the ring on horseback. Winners were crowned with laurel. In the early years there were some sillier events too, like a blindfold wheelbarrow race.",
              "In 1890 a young French baron, Pierre de Coubertin, came to visit. Brookes put on a special Games for him. Six years later Coubertin's modern Olympics opened in Athens. Brookes died a few months before, in 1895.",
              "So when the London Olympics came in 2012, one of the mascots was called Wenlock. Go on, the secretary's waiting.") + sett(G + "_1"))],
            s("Curator",
              "This little museum keeps the story of the Wenlock Olympian Games: medals, programmes and photographs of men in very long shorts.",
              "In 1890 Pierre de Coubertin came here and saw the Games. Six years later he founded the modern Olympics. Much Wenlock likes to mention this. Often."))])

    # ------------------------------------------------------------ quest: Shrewsbury or Shrowsbury?
    P = "q_shropshire_shrews"
    put("shrewsbury", "shr_shrows", [
        iff(P + "_done", s("Shrowsbury Man", "Shrows. Shrews. The Wrekin doesn't care and neither do the ponies. We've agreed to disagree, loudly, every Saturday."),
            [iff(P + "_2", s("Shrowsbury Man",
                "Well? What did they say? ... The Wrekin walker says Shrows, and the pony warden says Shrews. A draw!",
                "That's how it's always been. Shrewsbury School, the old families and half the town say Shrows. The other half, and most visitors, say Shrews. Even the dictionaries give both.",
                "Here, have some cakes for your trouble. Shrewsbury cakes. However you say it.") + sett(P + "_3", P + "_done") + [item("shrewsbury_cake", 3), standing(3)],
             [iff(P + "_started", s("Shrowsbury Man", "Ask the walker on top of the Wrekin, east of here, then the pony warden on the Long Mynd, south. Neutral ground, both of them."),
              s("Shrowsbury Man",
                "It's SHROWS-bury. Rhymes with 'throws'. My family has said it that way since the Tudors.",
                "She says SHROOS-bury, like the animal. We've argued about it since the coronation. Not this one. The one before.",
                "You look impartial. Go and ask the Wrekin walker, east of here past the Iron Bridge road, and the pony warden up on the Long Mynd. Bring back their verdicts.")
              + sett(P + "_started"))])])])
    put("ironbridge_gorge", "ib_toaster", [
        iff(P + "_started", [iff(P + "_1", s("Wrekin Walker", "Shrows. Final answer. To all friends round the Wrekin!"),
            s("Wrekin Walker", "How do I say it? SHROWS-bury, like my grandad, and he could see it from up here on a clear day. Tell them that.") + sett(P + "_1"))],
            s("Wrekin Walker",
              "To all friends round the Wrekin! That's the old Shropshire toast. Raise your flask.",
              "They say a giant meant to dam the Severn and drown Shrewsbury with a spadeful of earth. He met a cobbler carrying a sack of worn-out shoes, who said he'd walked so far from Shrewsbury he'd worn them all through. The giant gave up and dropped his earth here. That's the Wrekin."))])
    put("shropshire_hills", "hills_pony", [
        iff(P + "_1", [iff(P + "_2", s("Pony Warden", "Shrews. Like the little furry beasts. We've got plenty of them in the heather."),
            s("Pony Warden", "SHROOS-bury, of course. Like a shrew. The ponies agree, don't you, Duchess? ... She's eating my map. That's a yes.") + sett(P + "_2"))],
            s("Pony Warden",
              "The Long Mynd hill ponies have grazed up here for centuries. They belong to the commoners, who have the right to graze the hill, and they're tough as old boots.",
              "Don't feed them. They'll have your sandwiches, your map and your hat."))])

    # ------------------------------------------------------------ the Devil's Chair
    put("shropshire_hills", "hills_chair", [
        when("fog", s("", "The mist has come down over the Stiperstones. Something huge and patient is sitting in the Devil's Chair, and it turns its head towards you.")
             + [{"do": "legend", "species": "diaboulder", "level": 26, "flag": "caught_diaboulder", "music": "legend"}],
             s("", "A great jumble of quartzite, shaped very like a throne. Folk say that when the mist comes down, the Devil is sitting in it.",
               "Today it's just rocks. Today."))])
    put("shropshire_hills", "hills_quartz", [
        {"do": "daily", "key": "shropshire_quartz_day",
         "then": s("Rock Hound", "Stiperstones quartzite! Pale as sugar and hard as a tax bill. Frost split it off the tors in the Ice Age. Have a piece, there's plenty.") + [item("stiperstones_quartz")],
         "else": s("Rock Hound", "One a day, mind. The Devil counts them.")}])
    put("hills_tearoom", "hills_teaserver", s("Tea Room",
        "Tea, scones, and a slab of fidget pie if you're walking up the Mynd. Fidget pie is gammon, apples and onion, a proper Shropshire harvest pie.",
        "Watch the ponies by the car park. One of them has learnt to open bags."))

    # ------------------------------------------------------------ Shrewsbury interiors
    put("shrewsbury_market", "shr_marketeer", s("Cheese Stall",
        "Shropshire Blue! Orange as a sunset, blue as a bruise, and creamy with it. Have a taste.",
        "Funny thing, mind. Shropshire Blue was first made in Scotland, near Inverness, in the 1970s. Nobody's quite sure why they called it Shropshire. We've adopted it anyway."))
    put("shrewsbury_market", "shr_marketgran", s("Regular",
        "I've done my shopping in this market hall every Saturday for fifty years. The building's 1960s concrete with a clock tower, and everyone in town has an opinion about it.",
        "Inside it's all little independent stalls: cheese, bread, a Thai kitchen, records, buttons. It's won prizes, you know. Don't tell the concrete."))
    put("shrewsbury_bakery", "shr_baker", s("Baker",
        "Shrewsbury cakes, fresh out of the oven. Crisp and buttery, a little lemon, a crinkled edge. They've been baked in this town since at least the 1500s.",
        "And fidget pie for walkers. Have a look.") + [{"do": "shop", "id": "shrewsbury_bakery"}] + s("Baker", "Ta-ra, duck. Eat them while they snap."))
    put("shrewsbury_museum", "shr_curator", s("Curator",
        "Five miles from here is Wroxeter, the Roman city of Viroconium. In its day it was one of the biggest towns in Roman Britain, with baths and a forum. Some of what they dug up is in these cases.",
        "Upstairs is a gallery about Darwin, and a stretch of the town's story from the Saxons to the shopping centre. The silver Wroxeter mirror is the best thing in the building. Don't tell the other exhibits."))
    put("shrewsbury_castle", "shr_warder", s("Museum Warder",
        "The Soldiers of Shropshire Museum, in the castle's great hall. Regiments from the county, uniforms, medals and colours.",
        "The castle was built to plug the neck of the river loop, the one dry way into the town. With the Severn round everything else, Shrewsbury was very hard to take. The Welsh tried a good few times."))
    put("shrewsbury_abbey", "shr_verger", s("Verger",
        "Shrewsbury Abbey, founded in 1083. The monks brought St Winefride's bones from Wales in 1138 and pilgrims came from far and wide.",
        "Ellis Peters set her Brother Cadfael mysteries here, starting with that very story. Visitors still ask to see Cadfael's herb garden. We've planted one, so nobody leaves disappointed."))
    put("shrewsbury_bearsteps", "shr_bearsteps", s("Guide",
        "The Bear Steps buildings are medieval, timber-framed, and were nearly knocked down in the last century. Local people saved them, and now the hall is used for exhibitions.",
        "The steps run up to St Alkmund's from the old fish market. A shut, we call it. Mind your head on the beams; the medievals were shorter and less bothered."))
    put("shrewsbury_coracle", "shr_landlord", s("Landlord",
        "Ow bist? That's Shropshire for 'how are you'. You say 'Ah, middlin'', and then I pour you something.",
        "We're called The Coracle after the little round boats. There's one on the wall. It's not for hire after closing, whatever my brother-in-law says."))
    put("shrewsbury_coracle", "shr_quizmaster", s("Quizmaster",
        "Quiz night at The Coracle! Five questions. Shropshire questions get extra marks for pronunciation.",
        "Rules: no phones, no shouting out, and no starting the Shrews or Shrows argument. That's a separate event on Saturdays.") + [
        {"do": "choice", "text": "Fancy a round? Five questions, no phones.", "options": ["Count me in", "Not tonight"], "set": "_quiz_choice"},
        {"do": "if", "flag": "_quiz_choice", "eq": 0,
         "then": [{"do": "quiz", "pub": "shrewsbury", "region": "england_south", "who": "Quizmaster"}],
         "else": s("Quizmaster", "Suit yourself. The crisps are cheese and onion either way.")}])
    put("blists_hill_bank", "ib_clerk", s("Bank Clerk",
        "Good day! Change your money into pounds, shillings and pence? Twelve pennies to the shilling, twenty shillings to the pound, two hundred and forty pennies to the pound.",
        "Britain kept that until Decimal Day, 15 February 1971. Older visitors still do the sums in their heads, and get them right, and look very pleased."))
