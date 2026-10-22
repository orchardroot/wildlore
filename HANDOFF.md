# Wave 45 L handoff (these isles abroad)

Done: generator `tools/zones/abroad.py` (run `python3 tools/zones/abroad.py data/zones`; it rewrites the zones and edits plymouth/ferries/quiz/dex_order additively) builds Gaiman, Baddeck, Boston, Bristol TN and Roscoff, with a Sanctuary, a shop, 2 or 3 rooms, 9 plaques, trainers, a quest and the registry for each. Plymouth to Roscoff ferry (badge_storm). Nation "abroad" (Kin Abroad), ARS/CAD currencies, time zones, br lang, AbroadStyles buildings, 4 new creature lines (recipes in `tools/zones/abroad_recipes.py`, sprites rendered). `tools/test.sh abroad`: 9 passed.

Left: validator reports 23 errors:
- rename quest flags to `q_abroad_<region suffix>_*`: patagonia, cape_breton, appalachia, brittany, boston
- mate_gourd needs a price or comes out of the shop
- knacks plus genes.json kindred for the new lines
- the final forms (choique, bullmoose, hellbender) need encounter rows

Then screenshots of each town, CI, report.
