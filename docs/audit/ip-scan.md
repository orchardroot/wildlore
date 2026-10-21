# IP scan (wave 39 G)

Searched player-facing text, data and UI for Pokémon vocabulary (Pokédex, Poké Ball, gym, trainer card, HM/TM,
IV/EV, nature, egg group, Day Care, evolution stone, Elite Four, Master Ball).

## Fixed
- world/field_moves.gd: "gym badge" in the blocked-path hint -> "one of the Stones".
- ui/pause_menu.gd: "trainer card" in comments -> "Keeper card".

## Reviewed, left
- `nature` / `nature_mod`, "IVs" in core/racing.gd and battle/creature.gd: internal names and comments, never shown
  to the player. Candidate rename (temperament) if the stat model is ever exposed.
- `badges` / `badge_*` flags and the "badge" sfx: internal ids; player text says Stone.
- "Pokes", "gym membership", "Poisoned Glen", "Swilcan Burn": ordinary English or real places, not matches.
- Dialogue "nature" (reserves, quiz category) is the ordinary word.

No Pokémon names, items, or UI terms found in player-facing strings.
