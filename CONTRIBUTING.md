# Contributing

Bug reports and ideas are very welcome: use Settings > Report a bug in the game, or the templates on the issues page.

## Running things

Everything needs Godot 4.7.2; `tools/get_godot.sh` fetches it into `.godot-bin`.

```
$(tools/get_godot.sh) --headless --path . --import   # once, to build the import cache
tools/test.sh                                        # unit tests and the data validator
tools/playtest.sh slice 2                            # the headless playtest bot, a short run
tools/playtest.sh from <zone>/<npc> [seed]           # start at a story beat with a par-level team and play it
```

`test.sh` should report 0 failed, `validate: 0 error(s)` and no `SCRIPT ERROR` lines. Write a failing test first where you can: tests live in `tests/`.

## House rules

- UK English (Irish English in Ireland), warm and a bit wry, no em-dashes in anything the player reads.
- Real facts only. If you are not sure, leave it out.
- 60 fps on a 2013 iMac: no per-frame allocations in hot paths.
- Never break a save. New state must default safely when an old save loads (`core/game_state_data.gd`, `from_dict`).
- Small additive edits to shared files; put new logic in new files.

## Starter tasks

The briefs in `docs/briefs/` are self-contained tasks, and `docs/design/` explains where the game is heading. Pick a brief, open an issue to say you are on it, and send a pull request.
