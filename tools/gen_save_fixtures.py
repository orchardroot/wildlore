#!/usr/bin/env python3
"""Trims the full save from tools/gen_save_fixtures.gd to what each released version could have written.

For each tag it reads that tag's own code (git archive): the keys in GameStateData.to_dict and Creature.to_dict, the
TrainerStats counters, and which flag names / flag prefixes exist anywhere in that tag's core/ and data/ (a flag the
tag never mentions cannot be in its saves). Writes tests/fixtures/saves/save_<tag>.json.

  python3 tools/gen_save_fixtures.py /tmp/full_save.json
"""
import io, json, re, subprocess, sys, tarfile

TAGS = {  # tag: (badges kept, party size kept, ark size kept, play seconds)
    "v2.0.0": (3, 2, 1, 36000),
    "v2.2.1": (4, 3, 3, 43000),
    "v3.0.0": (5, 3, 4, 52000),
    "v3.3.0": (6, 4, 5, 70000),
    "v3.5.0": (6, 4, 6, 90000),
    "v3.7.0": (6, 4, 6, 120000),
}

def archive(tag):
    raw = subprocess.check_output(["git", "archive", tag, "core", "data", "world", "battle", "story"])
    files = {}
    with tarfile.open(fileobj=io.BytesIO(raw)) as t:
        for m in t.getmembers():
            if m.isfile() and m.name.endswith((".gd", ".json")):
                files[m.name] = t.extractfile(m).read().decode("utf-8", "replace")
    return files

def dict_keys(src, fn):
    body = src.split("func " + fn, 1)[1].split("\nfunc ", 1)[0].split("\nstatic func ", 1)[0]
    return set(re.findall(r'"([a-z_]+)":', body))

def main():
    full = json.load(open(sys.argv[1]))
    for tag, (nb, np_, na, secs) in TAGS.items():
        f = archive(tag)
        top = dict_keys(f["core/game_state_data.gd"], "to_dict")
        mon = dict_keys(f["battle/creature.gd"], "to_dict")
        counters = set(re.findall(r'"([a-z_]+)"', f["core/trainer_stats.gd"].split("const COUNTERS", 1)[1].split("]", 1)[0]))
        text = "\n".join(f.values())
        literals = set(re.findall(r'"([A-Za-z0-9_:|]+)"', text))
        prefixes = {s for s in literals if len(s) >= 3 and s.endswith(("_", ":"))}
        prefixes |= set(re.findall(r'"([a-z]+_(?:[a-z]+_)*)%[ds]', text))  # "garden_%d" style keys
        def known(k):
            return k in literals or any(k.startswith(p) for p in prefixes)
        out = {k: v for k, v in full.items() if k in top or k in ("version", "saved_at")}
        out["badges"] = full["badges"][:nb]
        out["party"] = [{k: v for k, v in m.items() if k in mon} for m in full["party"][:np_]]
        out["ark"] = [{k: v for k, v in m.items() if k in mon} for m in full["ark"][:na]]
        out["flags"] = {k: v for k, v in full["flags"].items() if known(k) and not (k.startswith("badge_") and k[6:] not in out["badges"])}
        out["stats"] = {k: v for k, v in full["stats"].items() if k in counters or k == "started"}
        out["play_seconds"] = secs
        out["version"] = 2
        out["saved_at"] = 1760000000
        dropped = sorted(set(full["flags"]) - set(out["flags"]))
        print(tag, "top-level", len(out), "flags", len(out["flags"]), "dropped", dropped)
        with open("tests/fixtures/saves/save_%s.json" % tag, "w") as fh:
            json.dump(out, fh, indent="\t", sort_keys=True)
            fh.write("\n")

main()
