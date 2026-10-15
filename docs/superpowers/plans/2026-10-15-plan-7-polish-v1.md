# Plan 7: Polish to v1.0 (M5) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** v1.0.0: the post-game, accessibility, an art and audio pass, performance and balance checks. No new regions or species.

**Spec:** `docs/superpowers/specs/2026-10-14-wildlore-design.md` (M5: post-game, balance, audio pass, accessibility (text speed, colour-blind-safe type icons, remapping), performance pass; section 5 post-game: remaining legendaries, rematches, Orkney and Isle of Man secrets, dex completion).

## Global Constraints

- Everything in plans 1 to 6's Global Constraints still applies (age 11 to adult, warm and witty, regional voices kind, no em-dashes).
- Branch `plan-7-polish`; agents `p7-<task>`. PR to `main`, tag `v1.0.0`.
- Testing scope (user ruling 2026-10-14): unit tests (watch for SCRIPT ERROR lines), validator, CI slice bot; one full route bot run at the end, in the background.
- Screenshots only via `tools/shot.sh` (silent, off-screen, never focused; user ruling 2026-10-15).
- Old saves (v0.1 to v0.5) must load.

## Review Focus

1. Rematches never block story progress and can't be farmed endlessly for money in one sitting.
2. Remapped controls persist, can always be reset, and a player can never unbind confirm/cancel into a soft-lock.
3. Colour-blind mode: every type distinguishable without colour (glyph plus name).
4. Post-game secrets only after `game_complete`, never twice.
5. Performance: the largest zones (London, Newcastle, Sheffield) hold a playable frame rate on the user's 2013-era iMac (Kepler GPU) at medium quality.

## Task 0: Deferred minors (controller)
- Retake any `docs/screens` image that shows a `?` placeholder. A validator rule now fails on NPC sprites with no art.

## Task 1: Post-game (subagent: Sonnet)
- Keeper rematches: after `game_complete`, each of the ten Keepers offers a rematch (teams L95 to 100, six creatures), once per in-game day; Garside and Kit rematches at Macclesfield. Prize money paid on a win only.
- Secrets: Orkney (the Ring of Brodgar at night) and the Isle of Man (Douglas Head / the Fairy Bridge, say hello to the fairies) each give a small post-game event with a rare high-level encounter of an existing species and a unique keepsake item (key item, flavour only).
- Fieldbook complete: Garside awards a diploma (key item) when all 200 are caught; a counter when asked before then.

## Task 2: Accessibility (subagent: Sonnet)
- Type glyphs: a small distinct shape per type drawn beside the name on every type chip; a "Colour-blind friendly" setting switching to a palette safe for deuteranopia/protanopia.
- Remapping: Settings > Controls lists every action with keyboard and pad bindings; rebind by pressing a key; reset to defaults; confirm and cancel can never be left unbound; saved in settings.json.
- Text speed gains "instant"; a "Reduce flashing" setting tones down hit flashes and screen shake.

## Task 3: Art pass (subagent: Sonnet)
- Review creature and character contact sheets, redraw the weakest dozen; fix the washed-out midday look (sun/ambient/tonemap tuning in the day cycle) without darkening nights.

## Task 4: Audio pass (subagent: Haiku or Sonnet)
- Measure loudness (RMS/peak) of every music track and sfx; normalise outliers so tracks sit within about 2 dB of each other; check loop seams.

## Task 5: Performance (controller)
- `--fps` timings on the largest zones on the user's iMac; fix anything under 30 fps at medium quality (merge static meshes, cull props, shadow distance).

## Task 6: Balance and release (controller)
- Full route bot run in the background; level curve versus key fights; README for 1.0; Opus whole-branch review; PR; tag `v1.0.0`.
