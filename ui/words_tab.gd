class_name WordsTab
extends RefCounted
## The Fieldbook's "Words of the Isles" tab (after the Stud Book, once a local word has been met): one row per
## language, then in the detail panel each word met and what it means (see Langs). Same shape as CasebookTab.

static func _zone_names() -> Dictionary:
	var out := {}
	var zs: Dictionary = ZoneIndex.get_index().zones
	for zid in zs:
		out[zid] = str(zs[zid].name)
	return out

static func _glossary() -> Array:
	return Langs.glossary(Game.data, _zone_names())

static func ids() -> Array:
	return _glossary().map(func(g): return str(g.code))

static func visible(data: GameStateData) -> bool:
	return not Langs.glossary(data, {}).is_empty()

static func row(id: String, h: HBoxContainer) -> void:
	h.add_child(UIKit.chip(id.to_upper(), UIKit.HEATHER.darkened(0.25), UIKit.CREAM, 16))
	h.add_child(UIKit.label(str(Langs.NAMES.get(id, id)), 26, UIKit.CREAM))

static func show(id: String, detail: VBoxContainer) -> void:
	UIKit.clear(detail)
	for g in _glossary():
		if str(g.code) != id:
			continue
		detail.add_child(UIKit.label(str(g.language), 34, UIKit.GOLD))
		var met: Array = g.rows
		detail.add_child(UIKit.label("%d words met. Where there's a local name, you'll see it on the town banner and the signs." % met.size(), 20, UIKit.MUTED))
		detail.add_child(UIKit.spacer(4))
		for w in met:
			var line := HBoxContainer.new()
			line.add_theme_constant_override("separation", 12)
			line.add_child(UIKit.label(str(w.word), 24, Langs.LOCAL_INK))
			line.add_child(UIKit.label(str(w.meaning), 20, UIKit.MUTED))
			detail.add_child(line)
