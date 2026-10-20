class_name ZoneCard
extends CanvasLayer
## The name of a town or route, with its region underneath, fading in at the top of the screen as you arrive.
## Not shown for interiors, nor when coming back out into the area you were just in.

const REGIONS := {
	"cheshire": "Cheshire", "peak": "The Peak District", "manchester": "Greater Manchester", "merseyside": "Merseyside",
	"north_wales": "North Wales", "mid_wales": "Mid Wales", "south_wales": "South Wales", "midlands": "The Midlands",
	"south_england": "The West Country", "cornwall": "Cornwall", "yorkshire": "Yorkshire", "north_east": "North East England",
	"cumbria": "Cumbria", "lancashire": "Lancashire", "scotland": "Scotland", "ireland": "Ireland", "ireland_west": "The West of Ireland",
	"ireland_east": "The East of Ireland", "man": "Isle of Man",
}
## Zones whose region id doesn't name them well.
const OVERRIDES := {
	"london": "South East England", "stonehenge": "Wiltshire", "salisbury_plain": "Wiltshire", "lancaster": "Lancashire",
	"belfast": "Northern Ireland", "bushmills": "Northern Ireland", "derry": "Northern Ireland",
	"antrim_coast": "Northern Ireland", "causeway": "Northern Ireland", "mournes": "Northern Ireland",
}
const FADE_IN := 0.5
const HOLD := 2.4
const FADE_OUT := 0.7

var _last := ""
var _panel: PanelContainer
var _name: Label
var _sub: Label
var _tween: Tween

static func subtitle(zone_id: String, region: String) -> String:
	return OVERRIDES.get(zone_id, REGIONS.get(region, ""))

## Records arriving in a zone; true when the card should show. Interiors never count, and don't reset
## the area you came from, so stepping out of a house is not an arrival.
func note(kind: String, zone_id: String) -> bool:
	if kind == "interior":
		return false
	if zone_id == _last:
		return false
	_last = zone_id
	return true

func _ready() -> void:
	layer = 5
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = load("res://ui/theme.tres")
	add_child(root)
	var top := MarginContainer.new()
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.add_theme_constant_override("margin_top", 36)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(top)
	_panel = UIKit.panel(Color("1d2230e6"), 14)
	_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(_panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 2)
	_panel.add_child(v)
	_name = UIKit.label("", 38, UIKit.CREAM)
	_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(_name)
	var rule := ColorRect.new()
	rule.color = UIKit.HEATHER
	rule.custom_minimum_size = Vector2(0, 2)
	v.add_child(rule)
	_sub = UIKit.label("", 22, UIKit.MUTED)
	_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(_sub)
	_panel.modulate.a = 0.0
	Bus.zone_entered.connect(_on_zone_entered)

func _on_zone_entered(zone_id: String) -> void:
	var z: ZoneData = null
	if Router.overworld and is_instance_valid(Router.overworld) and Router.overworld.zone and Router.overworld.zone.id == zone_id:
		z = Router.overworld.zone
	elif Game.zone_exists(zone_id):
		z = ZoneData.load_id(zone_id)
	if z == null or not note(z.kind, zone_id):
		return
	show_card(z.name, subtitle(zone_id, z.region))

func show_card(title: String, sub: String) -> void:
	_name.text = title
	_sub.text = sub
	_sub.visible = sub != ""
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_interval(0.35)  # let the screen fade in first
	_tween.tween_property(_panel, "modulate:a", 1.0, FADE_IN)
	_tween.tween_interval(HOLD)
	_tween.tween_property(_panel, "modulate:a", 0.0, FADE_OUT)
