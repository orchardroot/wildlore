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
- **Lilian Bader (liverpool_lilian_bader)**: made "an acting corporal".
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
