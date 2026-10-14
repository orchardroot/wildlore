extends Node
## Autoload Audio: one music player with crossfade, a small pool for sound effects.
## Looks for res://audio/music/<id>.wav (or .ogg) and res://audio/sfx/<id>.wav; missing files are silently skipped.

var _music: AudioStreamPlayer
var _music_id := ""
var _sfx: Array = []

func _ready() -> void:
	_music = AudioStreamPlayer.new()
	add_child(_music)
	for i in 6:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_sfx.append(p)
	Bus.settings_changed.connect(_apply_volume)
	_apply_volume()

func play_music(id: String, fade := 0.6) -> void:
	if id == _music_id:
		return
	_music_id = id
	var stream := _find("res://audio/music/" + id)
	var tw := create_tween()
	tw.tween_property(_music, "volume_db", -40.0, fade)
	await tw.finished
	_music.stop()
	if stream:
		_music.stream = stream
		_music.play()
		var tw2 := create_tween()
		tw2.tween_property(_music, "volume_db", linear_to_db(Settings.music_volume), fade)

func stop_music(fade := 0.6) -> void:
	_music_id = ""
	var tw := create_tween()
	tw.tween_property(_music, "volume_db", -40.0, fade)
	await tw.finished
	_music.stop()

func sfx(id: String) -> void:
	var stream := _find("res://audio/sfx/" + id)
	if stream == null:
		return
	for p in _sfx:
		if not p.playing:
			p.stream = stream
			p.volume_db = linear_to_db(Settings.sfx_volume)
			p.play()
			return

func _apply_volume() -> void:
	if _music.playing:
		_music.volume_db = linear_to_db(Settings.music_volume)

func _find(base: String) -> AudioStream:
	for ext in [".ogg", ".wav"]:
		if ResourceLoader.exists(base + ext):
			return load(base + ext)
	return null
