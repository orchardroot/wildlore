# Handoff: wave 45 session F (Scots, Ulster Scots, small languages)

Done (CI green on 39711223657: 2417 passed, 0 failed, validate 0 errors, slice playtest passed):
- core/langs.gd: `sco`, `sco_ulster` in CODES/NAMES; PREFIX_LANG maps Lowlands/Doric/Orkney/Shetland to Scots and
  Belfast/Bushmills/Antrim coast/Causeway to Ulster Scots; fixed the NOT_LOCAL ids for Irish (mournes, causeway, marblearch).
- data/lang: sco and sco_ulster get 4 lessons each; gv, kw, jer and nrf_gg get 2 each (owner's "don't overwhelm" steer).
- tests/core/test_langs_scots.gd checks the contract and the teacher tiles.
- docs/lang_review/*.md hold the owner questions.

Gotchas: commit c376e704 is the "STUB langs.gd check" that allows the new keys; drop it if D's check lands.
test_greetings now uses Derry, because Belfast has Ulster Scots hellos.

Left: only the final report. No new screens, so no screenshots were taken.
