extends MenuBase
## The world map (pause menu "Map"). setup("") or setup("species:<id>") to ring that creature's habitats.

var view: MapView

func _build() -> void:
	set_title("The Isles")
	set_hints([["cancel", "Back"]])
	view = MapView.new()
	view.set_anchors_preset(Control.PRESET_FULL_RECT)
	content.add_child(view)

func setup(arg: String) -> void:
	if arg.begins_with("species:"):
		var sp := Game.dex.get_species(arg.substr(8))
		if not sp.is_empty():
			set_title("Where to find " + str(sp.name))
			view.highlight = habitat_zones(str(sp.id))
	var here = Game.data.flag("last_town")
	var towns: Dictionary = Travel.world_map().get("towns", {})
	if here and towns.has(str(here)):
		view.centre = Vector2(float(towns[str(here)].x), float(towns[str(here)].y))
	header_right.text = "You are near " + Travel.town_name(str(here)) if here else ""
	if not arg.begins_with("species:"):
		_show_objective()
	view.queue_redraw()
	if Game.data.flag("champion") == true and not arg.begins_with("species:"):
		set_hints([["fly", "Fly"], ["cancel", "Back"]])
		_can_fly = true
		var fly := make_button("Fly", _fly)
		fly.position = Vector2(20, 14)
		content.add_child(fly)

var _can_fly := false

## Rings the "Where next?" town (or spot) in gold and says what it is along the bottom.
func _show_objective() -> void:
	var o := MenuLogic.next_objective(Game.data, Game.dex.ids().size())
	if o.is_empty():
		return
	view.objective = objective_point(o)
	var p := UIKit.panel(Color("1d2230e6"), 12)
	p.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	p.offset_left = 16
	p.offset_right = -16
	p.offset_bottom = -12
	p.grow_vertical = Control.GROW_DIRECTION_BEGIN
	var l := UIKit.label(("Still to do: " if o.get("postgame", false) else "Where next? ") + str(o.get("text", "")), 24)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	p.add_child(l)
	content.add_child(p)

## Where an objective sits on the map: its "map" point, else its town or place; (-1, -1) if neither.
static func objective_point(o: Dictionary) -> Vector2:
	var m := Travel.world_map()
	var at: Array = o.get("map", [])
	if at.size() == 2:
		return Vector2(float(at[0]), float(at[1]))
	var t := str(o.get("town", ""))
	var src: Dictionary = m.get("towns", {}).get(t, m.get("places", {}).get(t, {}))
	return Vector2(float(src.x), float(src.y)) if not src.is_empty() else Vector2(-1, -1)

func _unhandled_input(event: InputEvent) -> void:
	if _can_fly and not _locked and event.is_action_pressed("fly"):
		get_viewport().set_input_as_handled()
		_fly()

func _fly() -> void:
	if _locked:
		return
	var town = await open_child("travel:fly")
	if town != null and str(town) != "":
		close({"fly": str(town)})

## Zones whose wild encounter tables include this species (the truth, rather than the dex's habitat notes).
static var _habitats: Dictionary = {}  # species id -> zone ids, built once

static func habitat_zones(species_id: String) -> Array:
	if _habitats.is_empty():
		var all := ZoneData.load_all()
		for zid in all:
			for kind in all[zid].encounters:
				for e in all[zid].encounters[kind]:
					var sp := str(e.get("species", ""))
					if not _habitats.has(sp):
						_habitats[sp] = []
					if zid not in _habitats[sp]:
						_habitats[sp].append(zid)
	return _habitats.get(species_id, [])
