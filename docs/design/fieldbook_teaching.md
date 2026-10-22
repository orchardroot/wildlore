# Fieldbook teaching: `real` and `names`

Wave 45, session R. Data only; this note says how to wire it into `ui/pedia_screen.gd`.

## The data

Every species in `data/creatures/*.json` has two new keys, placed straight after `"id"`:

```json
"real": "A beaver's front teeth are orange because the enamel is laced with iron, which makes it tougher.",
"names": {"cy": "afanc / llostlydan", "ga": "béabhar", "gd": "biobhair"}
```

- `real`: one or two sentences, a true fact about the real animal, plant, legend or thing the creature is based on.
  It never repeats `dex.fact`.
- `names`: the real basis's name in Welsh, Irish and Scottish Gaelic. Any key may be missing (we only include words
  we are sure of), and `names` may be `{}` for a creature based on a place or machine. Never show an empty slot.
- Gaps and composites are listed in `docs/lang_review/animal_names.md`; filling one there means editing the JSON.

Both keys are optional for safety: read them with `sp.get("real", "")` and `sp.get("names", {})`.

## How to show it

In `_show_detail()`, inside the `if st == "caught":` block, after the "Did you know?" fact:

1. **The real line.** `UIKit.add_words(words, str(sp.get("real", "")), -2, Color("d8cfb4"))`, the same size and
   colour as the fact, under a small gold heading "In real life". Skip both if `real` is empty.
2. **The three names, one line.** Build `"cy llwynog · ga sionnach · gd sionnach"` in a fixed order (cy, ga, gd)
   from whichever keys exist, joined with a middle dot, and add it with `UIKit.add_words(words, line, -3,
   Langs.LOCAL_INK)` so it reads in the same warm ink as signs and town banners. Show the language code in muted
   text if the label helper allows rich text; otherwise plain is fine. Skip the line if `names` is empty.

Only show these once caught, like the fact: they are part of the reward for catching it.

## Wired in

`PediaScreen.add_real_life()` adds both, called from `_show()` after the fact; `MenuLogic.fieldbook_names_line()`
builds the names line and `Langs.CREATURE_NAME_CODES` fixes the order. Three more lines under the picture meant the
words box needed more give: its line separation is 6 (`WORD_SEP`) and the body sizes step down to 15
(`WORD_SIZES`), at which every entry, Macaquet's long fact included, fits the 682x296 box at 1280x720 without
scrolling (`tests/ui/test_fieldbook_teaching.gd` measures all of them). Most entries settle at 16 or 17.
`--menu=pedia:<id>` now opens any species caught, for screenshots.

## Nice extras (later, optional)

- Tooltip on the names line: "Welsh · Irish · Scottish Gaelic" (done, plain text).
- If session D's "Say it" system wants animal words, `names` is a ready word list (the `say` guide is not included).
- A Fieldbook goal: "Read the real-life note for 25 creatures" could use the existing seen/caught counters.

## Tests

- Validator: `real`, if present, is a non-empty string with no em-dash; `names`, if present, is a dictionary whose
  keys are only `cy`, `ga`, `gd` and whose values are non-empty strings.
- A UI test that a caught species with `names = {}` adds no names line.
