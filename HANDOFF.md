# Wave 45 session D handoff (language lessons)

Done (pushed on claude/w45-d-language):
- core/lang_lessons.gd (LangLessons): loader (data/lang/<code>.json "lessons" + data/lang/lessons/<code>.json plain array),
  progress flags, certificates lang_cert_<code>_<level>, Leitner review (flag lang_srs), questions, word of the day,
  learnt greetings, sign glosses, Say it, validator check (wired in tools/validate.gd).
- story/lesson_talk.gd: {"do": "lesson"} (teacher NPCs via LangLessons.npcs_for in overworld._side_npcs) and {"do": "say_it"}
  (after a won wild battle, overworld._after_battle). data/dialogue/lang_lessons.json.
- ui/lang_screen.gd/.tscn: menu "lang:lesson:<id>" and "lang:review:<code>". Words tab, pause word of the day, Almanac blurb,
  TrainerStats counters. Welsh cy_01, cy_02 in data/lang/cy.json; review questions docs/lang_review/cy.md.
- tests/core/test_lang_lessons.gd. Screens in docs/shots/w45d (dev: --menu=lang:..., pedia:words, pause:words).

Left: check CI; re-shoot lesson check + words tab after layout fixes.
Gotchas: teachers must stand in a zone where Langs.code_for == their code (validator). Machine is slow: no full local test.sh.
