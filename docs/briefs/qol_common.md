# Common rules for Wildlore QoL/immersion agents

- Repo ~/Projects/wildlore (Godot 4.7.2 GDScript). You are in a git worktree. FIRST: `git fetch -q origin && git checkout -b <your branch> origin/main`, then seed the import cache: `rsync -a --ignore-existing ~/Projects/wildlore/.godot/ .godot/` and run `$(tools/get_godot.sh) --headless --path . --import` once (if get_godot.sh would download, use the binary path it prints in the main checkout: `~/Projects/wildlore/tools/get_godot.sh`).
- The owner is actively playing the game. Never break saves: new save fields must default safely when loading old saves (see core/game_state_data.gd from_dict), new settings must default in core/settings.gd.
- Don't change balance (levels, stats, catch rates, money) unless your task says so.
- TDD where testable: tests live in tests/ (see tests/run_tests.gd, TestCase asserts, tests/battle_ui/fake_ui.gd for battle flow tests). Write the failing test first, watch it fail, then implement.
- Match the surrounding code style and comment density. No em-dashes in player-facing text. UK English. Age 11+.
- 60 fps on a 2013 iMac (Compatibility renderer): no per-frame allocations in hot paths, keep node counts sane.
- The machine has 4 cores and other agents are running: run `tools/test.sh` (unit tests + validator) sparingly, at the end and when needed; grep its output for `SCRIPT ERROR` (0 expected; "Parse JSON failed" lines are expected).
- Screenshots ONLY via `tools/shot.sh <out.png> 14 <game args>` (silent, off-screen; use --boot=<zone>@<x>,<y>, --menu=<name>, --battle=<species> etc; see core/dev_args.gd and ui/dev_menu.gd for dev switches). Never launch the game any other way. Read the PNGs to check UI changes look right.
- Commit on your branch with messages ending:

Co-Authored-By: Claude <Model Name> <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01ScZErCU1AdyrXuMs3LAqNr

  (use your own model name, e.g. Claude Sonnet 5.5 or Claude Opus 5.5). Don't push.
- Report: each item done (files, tests RED->GREEN), anything skipped and why, test counts, branch and commit.
