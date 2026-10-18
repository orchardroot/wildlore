class_name LayoutAudit
extends RefCounted
## Dev check (`--audit` with `--shot`): lists every visible control that spills out of its menu's content area
## or off the screen, so a screenshot run can say "this menu fits" instead of a squint at the PNG.
## Controls inside a ScrollContainer, or under any clipping control, are judged by that clip instead.

const SLACK := 1.0  # px of rounding we forgive

## Problems as readable lines, e.g. "PauseMenu/…/Button 'Settings' (48,690 380x56) past content (48,102 1184x552)".
static func report(root: Node, screen: Rect2) -> Array:
	var out := []
	_walk(root, screen, screen, out, null)
	return out

static func _walk(n: Node, bounds: Rect2, screen: Rect2, out: Array, skip: Node) -> void:
	if n == skip:
		return
	if n is CanvasItem and not (n as CanvasItem).visible:
		return
	if n is CanvasLayer and not (n as CanvasLayer).visible:
		return
	var inner := bounds
	if n is Control:
		var c := n as Control
		var r := _rect(c)
		if r.size.x > 0 and r.size.y > 0 and not _inside(r, bounds):
			out.append("%s (%d,%d %dx%d) past (%d,%d %dx%d)" % [_name(c), r.position.x, r.position.y, r.size.x, r.size.y,
				bounds.position.x, bounds.position.y, bounds.size.x, bounds.size.y])
			return  # one line per spill, not one per descendant
		if n is MenuBase:
			var m := n as MenuBase
			if m.hint_label != null:
				var hr := _rect(m.hint_label)
				if not _inside(hr, screen):
					out.append("%s hint bar (%d wide) off screen" % [_name(c), hr.size.x])
				var fnt := m.hint_label.get_theme_font("font")
				var fs := m.hint_label.get_theme_font_size("font_size")
				if fnt.get_string_size(m.hint_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > hr.size.x + SLACK and m.hint_label.autowrap_mode == TextServer.AUTOWRAP_OFF:
					out.append("%s hint text wider than its bar" % _name(c))
			for ch in m.get_children():
				_walk(ch, screen, screen, out, m.content)  # the frame: title, header, hint bar
			for ch in m.content.get_children():
				_walk(ch, _rect(m.content), screen, out, null)
			return
		if c is ScrollContainer:  # its content may run on (that's scrolling) but not sideways unless it scrolls that way
			var sc := c as ScrollContainer
			for ch in sc.get_children():
				if ch is Control and (ch as Control).visible and sc.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED \
						and (ch as Control).size.x > sc.size.x + SLACK:
					out.append("%s wider than its scroll box (%d > %d)" % [_name(ch), ch.size.x, sc.size.x])
			return
		if c.clip_contents:
			inner = r
	for ch in n.get_children():
		_walk(ch, inner, screen, out, skip)

static func _rect(c: Control) -> Rect2:
	return c.get_global_rect()

static func _inside(r: Rect2, b: Rect2) -> bool:
	return r.position.x >= b.position.x - SLACK and r.position.y >= b.position.y - SLACK \
		and r.end.x <= b.end.x + SLACK and r.end.y <= b.end.y + SLACK

static func _name(c: Control) -> String:
	var s := str(c.get_path()).replace("/root/", "")
	if s.length() > 70:
		s = "…" + s.right(69)
	if c is Label or c is Button:
		s += " '%s'" % str(c.text).left(24)
	return s
