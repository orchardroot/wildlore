# plan 5 group A (Northern Ireland): python3 tools/zones/ni_a.py tools/zones data/zones
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from wcommon import write_all
import ni_routes, ni_towns

out = sys.argv[2] if len(sys.argv) > 2 else "data/zones"
ni_routes.build(out)
ni_towns.build(out)
write_all(out)
