class_name HomeGarden
extends Node3D
## The home base's node in a zone (see HomeBase.dress): the garden plots, kept up to date as things grow, and
## the visitors resting about the place. Checks the plots every few seconds; cheap (six dictionary reads).

const CHECK_SECS := 4.0

var visitors := {}       # Vector2i -> {species, variant, line}
var _plots := {}         # plot number -> {node: Node3D, stage: String, material: String}
var _t := 0.0

func setup(z: ZoneData, plots: Array) -> void:
	for pr in plots:
		var p := Vector2i(int(pr.x), int(pr.y))
		var bed := HomeMeshes.bed_node()
		bed.position = Vector3(p.x + 0.5, ZoneBuilder.ground_y(z, p), p.y + 0.5)
		add_child(bed)
		_plots[int(pr.get("plot", 1))] = {"node": bed, "stage": "", "material": ""}
	refresh()

## Swaps any plant whose stage has moved on.
func refresh() -> void:
	for n in _plots:
		var st := HomeBase.plot_state(Game.data, n)
		var cur: Dictionary = _plots[n]
		if st.stage == cur.stage and st.material == cur.material:
			continue
		cur.stage = st.stage
		cur.material = st.material
		var bed: Node3D = cur.node
		var old := bed.get_node_or_null("Plant")
		if old:
			old.free()
		if st.stage != "empty":
			var plant := HomeMeshes.plant_node(str(st.material), str(st.stage))
			plant.name = "Plant"
			bed.add_child(plant)

func _process(delta: float) -> void:
	if _plots.is_empty():
		set_process(false)
		return
	_t += delta
	if _t >= CHECK_SECS:
		_t = 0.0
		refresh()
