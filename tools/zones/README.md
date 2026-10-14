# Zone authoring scripts

The JSON in `data/zones/` is the source of truth the game loads. These scripts were used to lay out the
slice zones and are kept so layouts can be regenerated after big edits:

    python3 tools/zones/macclesfield.py tools/zones data/zones
    python3 tools/zones/routes.py tools/zones data/zones

Careful: regenerating overwrites hand edits (NPCs added by story scripts live in the JSON). After any zone
change run `tools/test.sh` (the validator checks warps, edges, spawns, buildings) and take a screenshot:

    godot --path . -- --boot=<zone>@<x>,<y> --shot=docs/screens/<name>.png
