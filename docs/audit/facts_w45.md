# Wave 45 fact audit

## Session K: life lessons ("Things worth knowing")

Verified by web search on 2026-10-22 and used in game:
- National Gambling Helpline, 0808 8020 133 (GamCare; free, 24 hours; serves Great Britain). Used at Glasgow bookies and the Douglas Palace pit boss.
- Samaritans 116 123 (free, 24 hours, UK and Ireland). Used in Cork (St Finbarre's).
- Cruse Bereavement Support helpline 0808 808 1677 (free; opening hours vary, so the game gives none). Used in Glasgow Cathedral.
- 7726: forward scam texts, free (Ofcom). report@phishing.gov.uk: NCSC Suspicious Email Reporting Service.
- 159: Stop Scams UK, connects to your bank (most major banks). Used in Edinburgh.
- Emergency numbers: 999 (UK), 999 or 112 (Ireland).

Stated from established knowledge (no number involved):
- Tax code 1257L means a £12,570 personal allowance; employee NI main rate 8% above the same threshold; 35 qualifying years for a full new state pension; auto-enrolment from age 22, employer minimum 3%. The £2,000 a month example (about £190.50 tax, £76.20 NI) is arithmetic on those rates. Rates and thresholds can change; the dialogue only claims "the usual" code.
- European roulette: 37 pockets, pays as 36, house edge 2.7% (matches core/roulette.gd).
- GAMSTOP exists as a free online self-exclusion scheme. Its phone number and web address differ between sources, so none is given in game.

Left out, for the owner to decide:
- Action Fraud / Report Fraud contact details (the reporting centre appears to have been renamed; not sure of the current number).
- A gambling helpline for the Isle of Man, Northern Ireland and Ireland (the National Gambling Helpline is for Great Britain; the Palace pit boss says so explicitly). Irish and NI equivalents not confirmed.
- Debt advice phone numbers (Citizens Advice, StepChange, MoneyHelper are named without numbers).
- Cruse Scotland / Northern Ireland local lines (the national line is used).
- Whether the Welsh rates of income tax still match England's in 2026-27 (not mentioned in game).

# Wave 45 facts to check

## Session N (biology): in the game now, worth a second look

These are in data/biology.json and Dr Keir's lines (data/dialogue/roslin_lab.json). I'm confident of all of them, but these are the ones a pedant would check first:

- The first dark peppered moth recorded in Manchester in 1848; the cortex gene identified in 2016 (van't Hof et al., Nature).
- Kettlewell's experiments in the 1950s and Michael Majerus's later ones (published after his death, 2012).
- The Wellcome Sanger Institute read "nearly a third" of the Human Genome Project's sequence.
- "Today a whole genome can be read in a day or two for a few hundred pounds": this is about right for 2025, but the price moves fast.
- England's 100,000 Genomes Project finished in 2018 (December).
- Casgevy: the MHRA approved it in November 2023, the first CRISPR treatment approved anywhere.
- Roslin's PRRS-resistant gene-edited pigs.
- The Millennium Seed Bank at Wakehurst opened in 2000. The game says "tens of thousands of wild plant species", which is deliberately vague.
- The Svalbard Global Seed Vault opened in 2008.
- Przewalski's horse: "about a dozen" wild-caught founders, captured around 1900.
- Wilhelm Johannsen coined "gene" in 1909; Bateson's "allelomorph".
- Humans are born with "a few dozen" new mutations (the usual estimate is 40 to 80).

## Session N: kept out of the game until the owner confirms

- The year Saving Wildcats first released cats in the Cairngorms (I believe 2023, the design doc flagged June 2023). The Biology page only says wildcat breeders keep studbooks and test for domestic cat genes.
- Whether the Rare Breeds Survival Trust itself runs a frozen gene bank. The Biology page only says "rare breed keepers freeze semen and embryos".

## Session N: deliberately simplified

- The moor model is a toy, and the screen says so. Real mountain hares change coat with the season; the model has a fixed heritable coat so that selection is what you see.
- The Manchester model has the right shape (rising after 1850, falling after the 1956 Clean Air Act) but its numbers are made up.

# Facts to check, wave 45

## Session O (crossbreeds)
Kept out of the game until the owner confirms:
- **Capercaillie x ptarmigan** (Tetrao x Lagopus). Galliform intergeneric hybrids are common in general, and I believe capercaillie x willow grouse is on record in Scandinavia, but I am not sure of capercaillie x rock ptarmigan. If confirmed, add `["Tetrao", "Lagopus"]` to `families.Phasianidae.pairs` in data/taxa.json.
- **Common toad x natterjack** (Bufo x Epidalea). I have a vague memory of hybrids reported in Britain; not sure enough, so they are refused.
- **The leveret / gealhare line.** The authored blue-brown hare treats it as the brown hare (Lepus europaeus), so taxa.json does too. "Geal" suggests the Irish hare, which is a mountain hare subspecies (Lepus timidus hibernicus); if that was the intent, leveret x snowhare is one species, not two.
- **Orca x bottlenose** stays refused for the Shannon dolphin line (no record), while the authored wholphin allows it for the other bottlenose line as a declared game invention.

In the game and believed right: sheep 54 and goat 60 chromosomes; lion and tiger both 38; female ligers have had cubs; horse 64, donkey 62, mule 63; brown hare 48, rabbit 44; American mink now in genus Neogale; red and grey squirrels not known to interbreed.

# Wave 45 facts to check

## Session G, People of these isles

Everything below is in the game, worded cautiously; these are the claims I'd most like a second pair of eyes on.

- **Charles Wootton (liverpool_wootton)**: "A centre for adult education in the city was later named after him" (the
  Charles Wootton Centre / College, Toxteth). Is it still open, or should this be past tense?
- **Appleby Fair (carlisle_appleby_fair)**: "the biggest horse fair of its kind in Europe". Widely said; the safer
  wording would be "the largest gathering of Gypsies and Travellers in Europe".
- **Southall (london_southall)**: Sri Guru Singh Sabha's Havelock Road gurdwara "opened in 2003".
- **Arandora Star (glasgow_arandora_star)**: "more than 400 Italians died"; the memorial is the Italian Cloister
  Garden at St Andrew's Cathedral, Glasgow (2011). Figures range from about 446 to 470.
- **Noor Inayat Khan (london_noor_inayat_khan)**: "the first woman sent in that role" (first female wireless operator
  flown into occupied France). Standard, but worth confirming.
- **Lilian Bader (liverpool_lilian_bader)**: made "an acting corporal". Her father Marcus Bailey was from Barbados
  (an earlier draft said Sierra Leone; corrected). Sources split on whether he was Royal Navy or a merchant seaman in
  the First World War, so the plaque says only that he served.
- **Ivory Bangle Lady (york_ivory_bangle_lady)**: the 2010 Reading study "probably had North African ancestry" is
  how the Yorkshire Museum puts it; the jug is described as blue glass.
- **Wojtek (edinburgh_wojtek)**: "is said to have carried ammunition at Monte Cassino" is kept as a "said to".
- **Mr Gill (Birmingham NPC)**: Tarsem Singh Sandhu, Wolverhampton, sent home in 1967 for wearing a turban; the
  bus company gave way in 1969. The Lions of the Great War statue, Smethwick, 2018.
- **Rafael (Galway NPC)**: Gort's Brazilian community began with a meat plant recruiting in the late 1990s, many from
  Goiás (Anápolis).

Left out because I wasn't sure: the first mosque in Wales (date and place), how many dragons are on the Liverpool
Chinatown arch, the exact number of Windrush passengers from the Caribbean (492? 802? 1,027?), whether Michael Marks
is buried in Manchester, Shelta/Cant words (Travellers often keep them private, so Bridget declines to teach them).

Fictional people (Marcia, Rahima, Lily, Dot, Amina, Mr Saleh, Mr Hussain, Mr Gill, Kasia, Gina, Mrs Lee, Bridget,
Rafael, Anju, Maura, Sigrid) have invented family stories set against the real history above; no real living person
is quoted.

# Wave 45 facts held back for the owner

## Session I (economics)

Kept out of the game until confirmed:

1. **The price of a pint since 1971.** The brief asks for "a pint's price since decimalisation". I'm not sure of the
   average pint price in 1971 (I've seen figures from about 12p to 20p) or of good figures for later decades, so
   Derek (Whitelock's, Leeds) tells the story with dates and rates I'm sure of (Decimal Day 15 February 1971, about
   25% inflation in 1975, the 2% target, 11.1% CPI in October 2022) plus worked sums. If you have a source (ONS,
   BBPA or CAMRA series), a line like "about Xp in 1971, about £Y in 2025" can go into his script.
2. **The Cayman Islands dollar's exact peg.** Sources give CI$1 = US$1.20 or US$1.227 (CI$0.82 = US$1). The plaque
   in Stanley just says it is "tied to" the US dollar. The Wallet already uses 1.2.
3. **Clydesdale Bank notes after the Nationwide takeover (2024).** The Edinburgh plaque names the Bank of Scotland,
   RBS and the Clydesdale Bank as the three note issuers. I believe Clydesdale notes are still issued under that
   name; worth a check.
4. **Northern Rock "the first run on a British bank in well over a century".** Usually given as the first since
   Overend, Gurney in 1866; the plaque keeps it vague on purpose.

# Wave 45 fact questions for the owner

## Session J: the politics of these isles

Left out of the game on purpose, or worded with care. Owner to confirm or veto.

- **Chagos after October 2024.** The game says the UK and Mauritius announced a deal in principle in October 2024
  (sovereignty to Mauritius, the Diego Garcia base staying) and stops there. Anything signed, ratified or challenged
  in 2025-26 is deliberately not described. Should it stay that vague?
- **Senedd size and the 2026 election.** Not mentioned (the expansion to 96 members took effect at the May 2026
  election, whose results the game doesn't know).
- **Northern Ireland 2021 census identity.** The student says "about a third British only, nearly as many Irish only,
  about one in five just Northern Irish" (published figures: 31.9%, 29.1%, 19.8%). Rounded on purpose.
- **"Stroke City".** Credited loosely to "a local radio man" (usually said to be the broadcaster Gerry Anderson); not
  named in game.
- **Belfast Agreement vs Good Friday Agreement.** The game says unionists tend to say Belfast Agreement, nationalists
  Good Friday Agreement. A tendency, not a rule; reword if it reads as a stereotype.
- **Troubles deaths.** "More than 3,500, over half of them civilians" (CAIN/Sutton index: about 3,530, roughly 52%
  civilian).
- **Gibraltar 1967 referendum, 12,138 to 44**, and **Brexit vote, 96% Remain** (95.9%). Both well documented.
- **Women's vote on the Isle of Man, 1881.** Property-owning women only; worded as "some women".
- **Commonwealth realms.** "Fourteen countries besides the UK" (15 realms in all since Barbados became a republic in
  2021). Will go stale if another realm becomes a republic.
- **Tynwald** "says it is" the oldest continuous parliament in the world: worded as Tynwald's own claim.

# Facts to check (wave 45)

Questions for the owner from the wave 45 sessions. Anything here is either kept out of the game or worded loosely
until it is confirmed. Add to the list; don't rewrite other sessions' entries.

## Session L, these isles abroad

Everything in the five towns was written from well-documented sources. These are the points I was least sure of,
and how they are worded in the game meanwhile.

- **Gaiman, "Welsh Today" plaque**: "bilingual Welsh and Spanish schools in Gaiman and Trelew". Ysgol yr Hendre in
  Trelew is certain. Gaiman has Welsh taught at Coleg Camwy and a Welsh-medium nursery and primary (Ysgol y Gaiman,
  opened in the 2010s). If the Gaiman school is not a full bilingual school, change the line to "in Trelew and Trevelin".
- **Gaiman, "Welsh Today" plaque**: "a few thousand people in Chubut speak some Welsh". Estimates run from 1,500 to
  5,000 depending on what counts as speaking it. Kept vague on purpose.
- **Gaiman, Tŷ Cyntaf**: built 1874 by David D. Roberts. The year is on the museum's own signage; the builder's name
  varies between sources (David Roberts / David D. Roberts).
- **Gaiman, name**: "Gaiman itself takes its name from a Tehuelche word" (usually glossed as "sharp stone" or "stone
  point"). The gloss is left out of the game as sources differ.
- **Choique Fieldbook fact**: Darwin's rhea (Rhea pennata) was named Rhea darwinii by John Gould in 1837 from the
  remains of a bird Darwin's party had eaten at Port Desire in January 1834. The game says "collected it on the Beagle
  voyage in the 1830s, after the crew had eaten most of one", which is safe either way.
- **Baddeck, "The Clearances" plaque**: "tens of thousands of Gaels emigrated, many of them to Cape Breton". The scale
  is right for Nova Scotia as a whole (around 50,000 Highland Scots by 1850); if you want a number in the game, use
  that one and say Nova Scotia rather than Cape Breton.
- **Baddeck, Bell**: "spent his summers here from the 1880s" (first visit 1885; the Beinn Bhreagh estate grew through
  the late 1880s and 1890s). Fine as worded; sharpen to 1885 if wanted.
- **Boston, "Black '47" plaque**: "tens of thousands of Irish emigrants landed in Boston" in 1847 (about 37,000 is the
  usual figure) "then a city of little over 100,000 people" (114,000 in 1845). Both rounded on purpose.
- **Boston, Annie Moore**: her age on 1 January 1892 is given as 17 in most accounts and 15 in some (the ship's
  manifest and later family research disagree). The game and the quiz say 17; change to "a teenager from Cork" if
  you would rather not pick.
- **Bristol, the zone's name**: the town is called "Bristol, Tennessee" on the map, but the Birthplace of Country Music
  Museum stands on the Virginia side of State Street. The State Line plaque explains the two towns; rename the zone to
  "Bristol, Tennessee and Virginia" if the Tennessee-only name grates.
- **Bristol, "Redd Up" plaque**: "a poke is a paper bag" is attested in Scots, Ulster and Appalachian usage. Fine.
- **Bristol, mountain dulcimer**: "working from memory of German and Scandinavian zithers". The German scheitholt is
  the accepted ancestor; the Scandinavian (langeleik, hummel) link is argued by some scholars only. Drop "and
  Scandinavian" if you prefer the strict version.
- **Roscoff, Breton speakers**: "about two hundred thousand" (the 2018 TMO survey gave about 207,000). Right for now,
  and falling; revisit if the game's year moves on.
- **Roscoff, "Gwemon" plaque**: the Breton for seaweed is given as "gwemon" (also spelt gouemon; French goémon comes
  from it). "Bezhin" is the other common Breton word. Please check with a Breton speaker; the plaque title is the
  only place the word is used.
- **Roscoff, Mary, Queen of Scots**: landed at Roscoff in August 1548 (the traditional date is 13 or 15 August; the
  Chapelle Sainte-Barbe area has a commemorative plaque). The game says "August 1548" only.
- **Brittany Ferries**: first sailing 2 January 1973, Roscoff to Plymouth, with lorries of cauliflowers and artichokes
  (the ship was the Kerisnel). The game says "January 1973" and "cauliflowers and artichokes".
- **Currency**: Argentine peso rates move fast. core/forex.gd walks the AR$ rate inside a wide band so prices in Gaiman
  look right for 2026 without claiming a figure; check the band if the game's year moves on.

## Breton words used (docs/lang_review/br.md would be the better home once session F or a later wave adds one)
demat (hello), kenavo (goodbye), trugarez (thank you), degemer mat (welcome), mont a ra? (how are you?),
yec'hed mat (cheers, good health), noz vat (good night), Breizh (Brittany), Brezhoneg (Breton), Rosko (Roscoff),
ti (house), penn (head), aber (river mouth), kêr (village, home), gwenn ha du (white and black), gwerz (ballad),
kanerez (a woman singer), sonneur (French: piper), bombard and biniou (the pipes), fest-noz (night festival),
unan, daou, tri, pevar, pemp (one to five), mat-tre (very good), kouign-amann (butter cake).

# Wave 45 facts to check

Questions for the owner from the wave 45 sessions. Anything listed here is either kept out of the game or
worded cautiously until it is confirmed.

## Session T: arts and letters

Facts used in the game that I am confident of but could not double-check against a primary source here:

- Jane Austen's memorial tablet in Poets' Corner is dated 1967 (the Westminster guide says "only since 1967").
- The Belfast Harp Festival, July 1792: ten Irish harpers played (a Welsh harper also attended); Edward Bunting was 19.
- Beatrix Potter's bequest to the National Trust: "fifteen farms and more than four thousand acres" (the Trust's
  own figure; some sources say fourteen farms).
- Grace Williams scored the film Blue Scar (1949). The claim that she was the first Welsh woman to score a feature
  film is left out as unverified.
- The Hallé: described as "one of the oldest professional orchestras in Britain" rather than "the oldest", since
  Liverpool's Philharmonic Society (1840) is older as an institution.
- L. S. Lowry declined five honours including a knighthood (widely reported; the count is from the Lowry's own
  material).
- The Bee Gees' statue on Loch Promenade, Douglas (unveiled 2021) and their 1997 recording of "Ellan Vannin".
- Seamus Heaney's family moved from Mossbawn to Bellaghy in 1953.
- T. E. Brown's "My Garden": the line "A garden is a lovesome thing, God wot!" is quoted without a date.
- Joe Heaney (Seosamh Ó hÉanaí): the Carna festival in his name is described only as "every year" (the month is
  not stated).

Left out on purpose:

- Any line from Dylan Thomas, Sorley MacLean, Heaney, MacNeice, Friel or Percy French's later songs that is still
  in copyright. Only titles and short public-domain lines (Burns, Wordsworth, Housman, Woolf, Joyce's Ulysses,
  Shakespeare, Percy French 1896, T. E. Brown, Ó Criomhthain 1929) are quoted.
- The exact date Corn Uí Riada was first awarded (sometimes given as 1972).
- Rory Gallagher's Stratocaster as "the first in Ireland" (lore, not fact).
- A plaque for Michael Longley: his death in January 2025 is recent and I did not want to risk the date.

# Facts to confirm, wave 45

Questions for the owner. Anything here is kept out of the game (or worded vaguely in it) until confirmed.

## Session U, Land and Sky (geology, weather, climate)

Facts used in the game that the session is confident of, listed so they can be spot-checked: the UK's 40.3C at
RAF Coningsby on 19 July 2022 (previous record 38.7C, Cambridge Botanic Garden, 25 July 2019); Wales 37.1C at
Hawarden on 18 July 2022; Scotland 34.8C at Charterhall on 19 July 2022; Northern Ireland 31.3C at Castlederg on
21 July 2021; Ireland 33.3C at Kilkenny Castle on 26 June 1887; the Met Office founded 1854 under Robert FitzRoy,
first storm warnings and first printed forecasts 1861; sea area Finisterre renamed FitzRoy in 2002; 31 sea areas,
Viking first, Southeast Iceland last, the late broadcast at 0048; Beaufort's scale 1805; the Old Man of Hoy 137 m,
first climbed 1966 (Bonington, Patey, Baillie), televised climb 1967; the Giant's Causeway and Staffa basalts about
60 million years old as the North Atlantic opened; the Channel megafloods about 450,000 and 160,000 years ago
(Gupta and others, 2007 and 2017); the Jurassic Coast 95 miles, 185 million years, World Heritage 2001; Mary Anning's
ichthyosaur 1811 to 1812, plesiosaur 1823, pterosaur 1828, Geological Society admitting women from 1919; Cwm Idwal
the first National Nature Reserve in Wales, 1954, Darwin's visits 1831 and 1842; Limestone Pavement Orders under the
Wildlife and Countryside Act 1981; Knepp rewilding from 2001, white stork chicks fledged 2020, Wilding published
2018; River Otter beavers: trial licence 2015, allowed to stay 2020; Scotland's Knapdale trial 2009 and legal
protection 2019; wild-release licences in England from 2025; Ratcliffe-on-Soar closed 30 September 2024, Holborn
Viaduct 1882; Climate Change Act 2008; UK peatlands holding about three billion tonnes of carbon; Tyndall's 1859
experiments; Valentia Observatory from 1868; the Flow Country a World Heritage Site in 2024.

Left out or softened because the session was not certain enough:

- **Met Office move to Exeter.** The game says its headquarters are in Exeter, not when it moved there (2003 or
  2004 depending on the source). Confirm the year if a date is wanted.
- **Shipping Forecast broadcast times.** Only the 0048 broadcast is named. The number and timing of the daytime
  broadcasts changed with the BBC's long wave changes in 2024 to 2025, so the game says "several times a day".
  Confirm the current schedule if a number is wanted.
- **Sea-level rise round the UK since 1900.** Figures of about 16 to 19 cm are quoted by the Met Office's State of
  the UK Climate reports in different years. Left out.
- **The Flow Country's carbon store.** Commonly given as about 400 million tonnes; the game says "hundreds of
  millions of tonnes". Confirm the figure if a number is wanted.
- **Chalk streams.** "Most of the world's chalk streams are in England" (the usual figure is about 85 per cent).
  The game uses "most".
- **Old Man of Hoy's second leg.** The 1817 drawing with an arch is widely cited; the date the arch fell is not
  given in the game ("a storm took one").
- **Old Harry Rocks.** The game places them "across the harbour mouth at Studland" from Poole Quay, which is the
  general direction; they are on the Studland peninsula's Handfast Point.
- **UK emissions "about half what they were in 1990".** Government figures for 2023 put the fall at roughly 50 per
  cent (territorial emissions). Confirm the wording is acceptable.
- **Snowdon summit fossils.** Fossil shells (brachiopods) near the summit are widely reported; the game does not
  name the species.
- **Mary Anning and "she sells sea shells".** The game says the rhyme "may be about her"; the link is popular but
  not proven.
- **Peat growth rate.** "About a millimetre a year" is the usual rule of thumb; rates vary between bogs.
