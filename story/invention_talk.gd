class_name InventionTalk
extends RefCounted
## The `science` story command (Isles of Invention, 4.5): a science fair puzzle (see ScienceFair).
##   {"do": "science", "kind": "binary"|"cipher"|"dna"|"any", "who": "Dr Howells", "set": "<flag>", "hard": false}
## "any" offers the three to choose from. `set` gets 1 when the puzzle is solved (and is left alone otherwise, so a
## script can test it). The screen is ui/science_fair_screen.gd.

static func run(cmd: Commands, c: Dictionary) -> void:
	var host = cmd.host
	var who := str(c.get("who", "Demonstrator"))
	var kind := str(c.get("kind", "any"))
	if kind not in ScienceFair.KINDS:
		var opts := ["Binary lamps", "Shift cipher", "DNA pairs", "Not now"]
		var i: int = await host.choice("Three tables, three puzzles. Which one?", opts)
		if i < 0 or i >= ScienceFair.KINDS.size():
			await host.say(who, "Fair enough. The lamps will still be here.")
			return
		kind = ScienceFair.KINDS[i]
	var res = await host.open_menu("science:" + kind + (":hard" if bool(c.get("hard", false)) else ""))
	if res is Dictionary and bool(res.get("solved", false)):
		if str(c.get("set", "")) != "":
			cmd._set_flag(str(c.set), 1)
		return
	await host.say(who, "No shame in that. It took the cleverest people in the country to do this for real.")
