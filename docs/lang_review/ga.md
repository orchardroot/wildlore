# Irish (ga) lessons: questions for the owner

Lessons: `data/lang/lessons/ga.json`, ga_01 to ga_06, 48 words. Sound guides follow Connacht by default (said once,
in the ga_01 tip); Munster and Ulster differences sit in word notes. Nothing below is in the game except where a
line says "in game, check".

## Format and placement
- The wave 45 contract puts `lessons` inside `data/lang/ga.json`; this brief asked for a separate array in
  `data/lang/lessons/ga.json`. Session D's loader must read this path (or the array is moved into ga.json).
  `name`, `endonym` and `about` were not added to ga.json (session E may own them).
- Teachers (all Ireland interiors, tiles checked by script as floor with no prop, NPC, warp or sign; Godot validator
  not run): galway_crann (3,5), tory_club (5,6), connemara_kylemore (10,6), dingle_pierbar (9,2),
  dingle_books (7,6), gweedore_colaiste (3,8). Kylemore is in Connemara but not a Gaeltacht village; a Connemara
  Gaeltacht interior (An Spidéal, Ros Muc, Carna) would fit better if one is added. No Aran Islands zone exists.
- Tory and Gweedore teachers speak Ulster Irish in reality; the cards still give Connacht guides. Fine as a house
  convention, but a native Donegal speaker would say some words differently.

## Pronunciation to confirm (in game, check)
- Dia duit: given as DEE-uh gwitch, with a note that many say JEE-uh. Which should lead?
- Go raibh maith agat: "guh roh MAH ug-ut". Connacht "raibh" varies (roh / rev / row).
- a ceathair: KAH-hir; some Connacht speakers say nearer KYAH-hir.
- a cúig: KOO-ig; Ulster is often nearer KOO-ee.
- arán: AR-awn for Connacht, uh-RAWN for Munster. Confirm Connacht stress.
- crann and gleann: "crown" / "glyown" for Connacht and Munster, "krann" / "glan" for Ulster.
- a Sheáin: "uh HYAWN" is an approximation of a slender final n.
- Cad é mar atá tú (Ulster) appears in a note with no sound guide on purpose.

## Facts kept out of the game
- Glenveagh, Gleann Bheatha: often glossed "glen of the birches"; left unglossed.
- Carrick-a-Rede, Carraig a' Ráid: second element's meaning disputed; only "carraig = rock" is used.
- Ardnacrusha, Ard na Croise ("height of the cross"): the card says only "ard = high", not the full gloss.
- Ballycastle, Baile an Chaistil (town of the castle), Kilkenny, Cill Chainnigh, Donegal, Dún na nGall (fort of the
  foreigners), Enniskillen, Inis Ceithleann, Lough Neagh, Loch nEathach: used, believed standard. Please confirm.
- English "bog" from Irish bog (soft): true as far as I know, left out to keep lesson 3 at 8 words.
