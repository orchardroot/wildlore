# Minimal stand-in for llanberis (replaced by the North Wales group). Only written if data/zones/llanberis.json is absent.
import os
from wcommon import *


def build(OUT):
    if os.path.exists(OUT + "/llanberis.json"):
        return
    z = Z("llanberis", "Llanberis", 40, 30, kind="town", region="north_wales", music="town_wales")
    z.d["stage"] = "town"; z.d["town_id"] = "llanberis"
    z.border("T", 3, gaps=[(24, 27, 3, 3)]); z.rect(24, 10, 3, 20, "#")
    z.d["edges"] = {"south": {"to": "cambrian_coast", "offset": 0}}
    z.d["spawn"] = [25, 20]
    z.save(OUT + "/llanberis.json")
