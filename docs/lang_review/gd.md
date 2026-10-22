# Scottish Gaelic (gd): questions for the owner (wave 45, session E)

Thirteen lessons in data/lang/gd.json (gd_01 to gd_13: three at level 1, four at level 2, three at level 3, three at
level 4). Teachers stand indoors in Stornoway (An Lanntair, the Minch Arms, Museum nan Eilean), Lewis and Harris
(Gearrannan, Calanais), Portree (Royal Hotel, Aros Centre), Kyle (station cafe), the Braes, Tobermory, Inverness
(Victorian Market) and Oban (the Oban Inn). Everything in the game is a form I'm confident of. These are worth a
fluent speaker's eye:

1. **Pronunciation guides** are rough English-spelling approximations (no IPA). Gaelic sounds such as the broad and
   slender consonants don't map neatly, e.g. `a h-aon` given as "uh HOON", `ceann` as "KYOWN", `àird` as "AHRJ",
   `teaghlach` as "TCHUH-lach", `cnoc` as "KROCHK". Happy to tune any a speaker winces at.
2. **About line, the 2022 census**: "about 130,000 people in Scotland with some Gaelic". I'm fairly sure of the
   130,161 figure for people aged 3+ with some Gaelic skills; worth checking against Scotland's Census before release.
3. **"is" for "and"** (tì is aran, the cafe sign "Tì, aran is càise", the Inverness stall "Aran, bainne is
   uisge-beatha"): used as the short form of agus. Fine in speech and signs, but a speaker might prefer "agus" on a
   printed sign.
4. **Loanword notes**: whisky from uisge-beatha and slogan from sluagh-ghairm are standard etymologies; galore is
   given as from gu leòr (Gaelic) and go leor (Irish), since dictionaries credit both. Tìoraidh from "cheerio" is the
   usual account.
5. **The article lesson (gd_11)** teaches the standard rules: an / am (before b, f, m, p) / an t- (masculine vowel)
   for masculine; a' + lenition, an before d, t and vowels, an t- before s for feminine. Dialects vary in speech; the
   written forms given are the standard ones. `an t-sràid` with the s silent is given as "un TRAH-tch".
6. **Place-name lesson (gd_12)**: Cille Mhoire (Kilmuir, Skye), Achadh na Sìne (Achnasheen), Druim na Drochaid
   (Drumnadrochit), Caol Loch Aillse (Kyle of Lochalsh), An Tairbeart (Tarbert, Harris), Taigh an Droma (Tyndrum),
   Dail Chuinnidh (Dalwhinnie), Druim Uachdair (Drumochter), An Aghaidh Mhòr (Aviemore). All as signed by Transport
   Scotland or Ainmean-Àite na h-Alba as far as I know; worth a glance against the gazetteer. Left out on purpose:
   Kilmarnock (Cille Mheàrnaig) and Killiecrankie, whose Gaelic spellings I wasn't sure enough of.
7. **Songs and the Mòd (gd_13)**: An Comunn Gàidhealach founded in Oban in 1891 and the first Mòd held in Oban in
   1892 (said by the teacher and the Oban Inn quizmaster) are the usual dates. "Fear a' Bhàta" is described only as
   "a woman watches the sea for her boatman"; its usual attribution to Sìne NicFhionnlaigh of Tong, Lewis, in the
   late 1700s is left out until confirmed. The proverb "Is fheàrr Gàidhlig bhriste na Gàidhlig sa chiste" is given
   as commonly quoted.
8. **Colours (gd_09)**: gorm for blue and the green of growing grass, uaine for other greens, liath for the grey of
   hair and mist, glas for stone and sea: the usual textbook split. Am Monadh Liath facing Am Monadh Ruadh across
   Strathspey is as the OS names them. The Calanais guide's line that Lewisian gneiss is "some of the oldest rock in
   Europe" is the standard claim (about 3,000 million years).
9. **Family (gd_08)**: the tip gives NicLeòid as the woman's form of MacLeòid. The Aros guide's "half of Portree is
   a cousin" is a joke, not a census figure.
10. **Session D's loader (branch claude/w45-d-language) fails to parse under this project's strict typing** at
    core/lang_lessons.gd:286 (`var n := card(...)[1] - d.day_count`: an untyped array element). `var n: int = ...`
    fixes it. With that one change its validator passes all 13 Gaelic lessons with 0 errors. For the integrator, not
    the owner.
11. Left out on purpose: dialect differences between Lewis, Harris, Skye and Argyll; Bal- names, several of which
    come from bealach, a pass, not baile.
12. Not mine, spotted in passing: data/zones/harris_blackhouse.json is named "Gearrannan Blackhouse", but Gearrannan
    is on Lewis (Carloway), not Harris. The zone's own plaque already says Lewis, so it may be deliberate (the Harris
    zone covers both). No change made.
