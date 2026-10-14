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
		if sp:
			set_title("Where to find " + str(sp.name))
			view.highlight = sp.get("habitat", [])
	var here = Game.data.flag("last_town")
	var towns: Dictionary = Travel.world_map().get("towns", {})
	if here and towns.has(str(here)):
		view.centre = Vector2(float(towns[str(here)].x), float(towns[str(here)].y))
	header_right.text = "You are near " + Travel.town_name(str(here)) if here else ""
	view.queue_redraw()
