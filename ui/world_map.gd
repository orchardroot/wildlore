extends MenuBase
## The world map (pause menu "Map"). setup("") or setup("species:<id>") to ring that creature's habitats.

var view: MapView

func _build() -> void:
	set_title("The Isles")
	set_hint("X  Back")
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
	view.queue_redraw()

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
