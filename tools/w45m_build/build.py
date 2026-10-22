import sys, json
sys.path.insert(0, '/tmp/w45m')
from lib import *
import spain, cyprus
zs = spain.build() + cyprus.build()
for z in zs:
    z.save()
L = "q_overseas_la_linea_"
dump('data/quests/overseas_la_linea.json', {"quests": [{"id": "overseas_la_linea_lunch", "title": "Lunch at the Frontier", "region": "overseas_la_linea",
  "town": "la_linea", "giver": "Carmen", "summary": "Carmen has crossed to work on the Rock for nineteen years, and today she's left her lunch at her mother's bar.",
  "start_flag": L + "started", "steps": [
   {"flag": L + "1", "text": "Fetch Carmen's lunch from her mother, Pilar, at Bar Pilar in La Línea.", "zone": "la_linea_tapas"},
   {"flag": L + "2", "text": "Take it back to Carmen in the frontier queue, and deal with the van driver who's in a mood.", "zone": "la_linea"},
   {"flag": L + "3", "text": "Hand Carmen her lunch.", "zone": "la_linea"}],
  "done_flag": L + "done", "reward": "Tortillitas de Camarones, Churros con Chocolate and standing with the Overseas Territories."}]})
C = "q_overseas_cyprus_"
A = "q_overseas_cyprus_agrino_"
dump('data/quests/overseas_cyprus.json', {"quests": [
 {"id": "overseas_cyprus_halloumi", "title": "Halloumi or Hellim?", "region": "overseas_cyprus", "town": "pyla", "giver": "UN Peacekeeper",
  "summary": "Pyla's two coffee-house owners each say his is the best halloumi on the island. The UN doesn't do cheese, so you'll have to.",
  "start_flag": C + "started", "steps": [
   {"flag": C + "1", "text": "Taste Andreas's halloumi in Pyla's kafeneio.", "zone": "pyla_kafeneio"},
   {"flag": C + "2", "text": "Taste Hüseyin's hellim in Pyla's kahvehane.", "zone": "pyla_kahvehane"},
   {"flag": C + "3", "text": "Ask the halloumi seller in the square of south Nicosia.", "zone": "nicosia_south"},
   {"flag": C + "4", "text": "Cross at Ledra Street and ask the hellim seller in the Büyük Han. A food critic may need persuading.", "zone": "nicosia_buyuk_han"},
   {"flag": C + "5", "text": "Take the verdict back to the UN peacekeeper in Pyla.", "zone": "pyla"}],
  "done_flag": C + "done", "reward": "Halloumi, Loukoumades, Şeftali Kebab and standing with the Overseas Territories."},
 {"id": "overseas_cyprus_agrino", "title": "A Good Eye", "region": "overseas_cyprus", "town": "nicosia_south", "giver": "Forest Ranger",
  "summary": "A Forestry Department ranger has a young agrino, the Cypriot mouflon, that needs a keeper with patience.",
  "start_flag": A + "started", "steps": [
   {"flag": A + "1", "text": "Catch a Chamelet (the fields round Pyla are a good start) and show the ranger in the taverna in south Nicosia.", "zone": "nicosia_taverna"}],
  "done_flag": A + "done", "reward": "An Agrino, the mouflon of Cyprus, and standing with the Overseas Territories."}]})
print(len(zs), 'zones')
