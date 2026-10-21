class_name Knacks
extends RefCounted
## Knacks: one passive per evolution line (species data, never saved on the creature). data/knacks.json holds the
## definitions ("knacks": id -> {name, desc, msg, ...hook fields}) and "species": species id -> knack id.
## A hand-made species may carry its own "knack" id (tests). Battle calls these hooks; they are pure lookups.
##
## Hook fields (all optional, mixed freely):
##   immune_type: a move type that does nothing to the holder.      block_status: [statuses it can't catch].
##   resist {types, mult}: those types hurt it less.                se_mult: super-effective hits are scaled.
##   speed {weather, mult}: faster in that weather.                 evade {weather, mult}: foes' accuracy against it
##   (an empty weather list means always).                          keen: its accuracy ignores fog and can't be cut.
##   no_drops: foes can't lower its stats.  no_flinch.  no_recoil.  endure_full: a hit at full HP leaves it on 1.
##   endure_once: once a battle, a knockout blow leaves it on 1.    contact_hurt N: physical attackers lose 1/N HP.
##   entry_stage {to: self|foes, stat, stages, weather?, time?} (or a list): on entering the field, when it applies.
##   entry_weather: calls that weather for 5 turns on entry.        weather_turns N: its weather moves last N turns.
##   heal {weather, frac}: heals 1/frac HP each turn in that weather (empty: always).   shake N: N% a turn to shed a status.
##   end_stage {stat, stages}: each turn's end.  after_ko {stat, stages}: after it knocks a foe out.
##   switch_heal N: heals 1/N HP when it switches out.             heal_mult: drain and healing moves heal more.
##   power_weather {weather, mult, types?}: its moves in that weather.   pinch: its own-type moves at 1/3 HP or less.
##   status_power: its moves while it has a status.                 power_time {time, mult}: by the time of day.
##   ally_power: with a partner standing (doubles).                 finisher: against a foe at half HP or less.
##   weather_proof: weather never weakens its moves.                crit_mult: its critical-hit chance.

const PATH := "res://data/knacks.json"
const FIELDS := ["name", "desc", "msg", "legend", "immune_type", "block_status", "resist", "se_mult", "speed", "evade",
	"keen", "no_drops", "no_flinch", "no_recoil", "endure_full", "endure_once", "contact_hurt", "entry_stage",
	"entry_weather", "weather_turns", "heal", "shake", "end_stage", "after_ko", "switch_heal", "heal_mult",
	"power_weather", "pinch", "status_power", "power_time", "ally_power", "finisher", "weather_proof", "crit_mult"]

static var _data: Dictionary = {}

static func data() -> Dictionary:
	if _data.is_empty():
		var d = JsonUtil.read(PATH) if FileAccess.file_exists(PATH) else {}
		_data = d if d is Dictionary else {}
		if not _data.has("knacks"):
			_data["knacks"] = {}
		if not _data.has("species"):
			_data["species"] = {}
	return _data

static func id_for_species(sp: Dictionary) -> String:
	if sp.has("knack"):
		return str(sp.knack)
	return str(data().species.get(str(sp.get("id", "")), ""))

static func id_of(c: Creature) -> String:
	if c == null:
		return ""
	if c.form != "":  # a regional form may have its own knack
		var fk := Forms.knack_for(str(c.species.get("id", "")), c.form)
		if fk != "":
			return fk
	return id_for_species(c.species)

static func get_def(id: String) -> Dictionary:
	return data().knacks.get(id, {})

static func def_of(c: Creature) -> Dictionary:
	return get_def(id_of(c))

static func name_of(id: String) -> String:
	return str(get_def(id).get("name", ""))

static func desc_of(id: String) -> String:
	return str(get_def(id).get("desc", ""))

## The battle line for a trigger: "msg_<trigger>" if the knack has one, else its "msg", else "{name}'s <Knack>!".
static func message(c: Creature, trigger := "") -> String:
	var d := def_of(c)
	var t := str(d.get("msg_" + trigger, d.get("msg", "")))
	return t if t != "" else "{name}'s %s!" % d.get("name", "knack")

static func has_flag(c: Creature, field: String) -> bool:
	return bool(def_of(c).get(field, false))

static func int_field(c: Creature, field: String) -> int:
	return int(def_of(c).get(field, 0))

static func _in_weather(rule: Dictionary, weather: String) -> bool:
	var ws: Array = rule.get("weather", [])
	return ws.is_empty() or weather in ws

# --- defence ---------------------------------------------------------------------------------

static func immune(c: Creature, move: Dictionary) -> bool:
	var t := str(def_of(c).get("immune_type", ""))
	return t != "" and str(move.get("type", "")) == t and str(move.get("category", "")) != "status"

static func blocks_status(c: Creature, status: String) -> bool:
	return status in def_of(c).get("block_status", [])

## Foes can't lower this stat (no_drops: any; keen: accuracy).
static func blocks_drop(c: Creature, stat: String) -> bool:
	var d := def_of(c)
	return bool(d.get("no_drops", false)) or (stat == "acc" and bool(d.get("keen", false)))

static func defend_mult(c: Creature, move: Dictionary, effectiveness: float) -> float:
	var d := def_of(c)
	var m := 1.0
	var r: Dictionary = d.get("resist", {})
	if not r.is_empty() and str(move.get("type", "")) in r.get("types", []):
		m *= float(r.get("mult", 1.0))
	if effectiveness > 1.0 and d.has("se_mult"):
		m *= float(d.se_mult)
	return m

static func evade_mult(c: Creature, weather: String) -> float:
	var e: Dictionary = def_of(c).get("evade", {})
	return float(e.get("mult", 1.0)) if not e.is_empty() and _in_weather(e, weather) else 1.0

# --- speed and offence -----------------------------------------------------------------------

static func speed_mult(c: Creature, weather: String) -> float:
	var s: Dictionary = def_of(c).get("speed", {})
	return float(s.get("mult", 1.0)) if not s.is_empty() and _in_weather(s, weather) else 1.0

static func crit_mult(c: Creature) -> float:
	return float(def_of(c).get("crit_mult", 1.0))

static func heal_mult(c: Creature) -> float:
	return float(def_of(c).get("heal_mult", 1.0))

## Just the weather part of a knack's power (power_weather), for a given weather: the AI weighs weathers with it.
static func weather_power(c: Creature, move: Dictionary, weather: String) -> float:
	var pw: Dictionary = def_of(c).get("power_weather", {})
	if pw.is_empty() or weather not in pw.get("weather", []):
		return 1.0
	return float(pw.get("mult", 1.0)) if not pw.has("types") or str(move.get("type", "")) in pw.types else 1.0

## Everything a knack does to the damage its holder deals with `move` against `target`.
static func attack_mult(c: Creature, target: Creature, move: Dictionary, b: Battle) -> float:
	var d := def_of(c)
	if d.is_empty():
		return 1.0
	var m := 1.0
	var mt := str(move.get("type", ""))
	var pw: Dictionary = d.get("power_weather", {})
	if not pw.is_empty() and b.weather in pw.get("weather", []) and (not pw.has("types") or mt in pw.types):
		m *= float(pw.get("mult", 1.0))
	if d.has("pinch") and mt in c.types() and c.hp * 3 <= c.max_hp():
		m *= float(d.pinch)
	if d.has("status_power") and c.status != "":
		m *= float(d.status_power)
	var pt: Dictionary = d.get("power_time", {})
	if not pt.is_empty() and b.time in pt.get("time", []):
		m *= float(pt.get("mult", 1.0))
	if d.has("ally_power") and b.double and b.actives(0 if c in b.parties[0] else 1).size() > 1:
		m *= float(d.ally_power)
	if d.has("finisher") and target != null and target.hp * 2 <= target.max_hp():
		m *= float(d.finisher)
	if bool(d.get("weather_proof", false)):
		var wm := Weather.damage_mod(b.weather, mt)
		if wm < 1.0:
			m /= wm
	return m

# --- triggers --------------------------------------------------------------------------------

static func entry_weather(c: Creature) -> String:
	return str(def_of(c).get("entry_weather", ""))

## The entry stat changes that apply right now (weather / time conditions met). Each {to, stat, stages}.
static func entry_stages(c: Creature, weather: String, time: String) -> Array:
	var raw: Variant = def_of(c).get("entry_stage", [])
	var list: Array = raw if raw is Array else [raw]
	var out := []
	for st in list:
		if not (st is Dictionary) or st.is_empty():
			continue
		var ws: Array = st.get("weather", [])
		var ts: Array = st.get("time", [])
		if (ws.is_empty() and ts.is_empty()) or weather in ws or time in ts:
			out.append(st)
	return out

static func weather_turns(c: Creature) -> int:
	return int(def_of(c).get("weather_turns", 0))

## HP healed at the end of a turn in this weather (0: none).
static func turn_heal(c: Creature, weather: String) -> int:
	var h: Dictionary = def_of(c).get("heal", {})
	if h.is_empty() or not _in_weather(h, weather):
		return 0
	return maxi(1, c.max_hp() / maxi(1, int(h.get("frac", 16))))

static func switch_heal(c: Creature) -> int:
	var n := int_field(c, "switch_heal")
	return c.max_hp() / n if n > 0 else 0

static func end_stage(c: Creature) -> Dictionary:
	return def_of(c).get("end_stage", {})

static func after_ko(c: Creature) -> Dictionary:
	return def_of(c).get("after_ko", {})

# --- data checks -------------------------------------------------------------------------------

## Errors in data/knacks.json against the dex: every species has a knack, a line shares one, legends' are their own.
static func check(dex: Dex) -> Array:
	var e := []
	var d := data()
	for kid in d.knacks:
		var k: Dictionary = d.knacks[kid]
		if str(k.get("name", "")) == "" or str(k.get("desc", "")) == "":
			e.append("knack %s: needs a name and a desc" % kid)
		for f in k:
			if f not in FIELDS and not str(f).begins_with("msg_"):
				e.append("knack %s: unknown field '%s'" % [kid, f])
		if str(k.get("entry_weather", "")) != "" and str(k.entry_weather) not in Rules.WEATHERS:
			e.append("knack %s: unknown weather '%s'" % [kid, k.entry_weather])
		for s in k.get("block_status", []):
			if s not in Rules.STATUSES:
				e.append("knack %s: unknown status '%s'" % [kid, s])
	var users := {}  # knack -> [species]
	for sid in dex.ids():
		var sp := dex.get_species(sid)
		var kid := id_for_species(sp)
		if kid == "":
			e.append("species %s: has no knack in data/knacks.json" % sid)
			continue
		if not d.knacks.has(kid):
			e.append("species %s: unknown knack '%s'" % [sid, kid])
			continue
		users[kid] = users.get(kid, []) + [sid]
		var evo = sp.get("evolves")
		if evo is Dictionary and dex.has(str(evo.get("to", ""))) and id_for_species(dex.get_species(str(evo.to))) != kid:
			e.append("species %s: evolves into %s but their knacks differ" % [sid, evo.to])
		if bool(d.knacks[kid].get("legend", false)) and not bool(sp.get("legend", false)):
			e.append("species %s: '%s' is a legend's own knack" % [sid, kid])
	for kid in users:
		if bool(d.knacks[kid].get("legend", false)) and users[kid].size() > 1:
			e.append("knack %s: a legend's knack is shared by %s" % [kid, users[kid]])
	for sid in d.species:
		if not dex.has(sid):
			e.append("knacks.json: unknown species '%s'" % sid)
	return e
