extends Node
## Autoload Audio: two music players for real crossfades, a small pool for sound effects.
## Looks for res://audio/music/<id>.ogg|.wav and res://audio/sfx/<id>.wav; missing files are silently skipped.
## Looping comes from the loop points baked into the WAV files (see tools/sfxgen.gd).

const SILENT_DB := -60.0

var _players: Array = []
var _active := 0
var _music_id := ""
var _sfx: Array = []
var _tweens: Array = [null, null]

func _ready() -> void:
	for i in 2:
		var p := AudioStreamPlayer.new()
		p.volume_db = SILENT_DB
		add_child(p)
		_players.append(p)
	for i in 6:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_sfx.append(p)
	Bus.settings_changed.connect(_apply_volume)

func play_music(id: String, fade := 0.6) -> void:
	if id == _music_id:
		return
	_music_id = id
	var stream := _find("res://audio/music/" + id)
	var old: AudioStreamPlayer = _players[_active]
	var old_idx := _active
	_fade(old_idx, SILENT_DB, fade, true)
	if stream == null:
		return
	_active = 1 - _active
	var p: AudioStreamPlayer = _players[_active]
	p.stop()
	p.stream = stream
	p.volume_db = SILENT_DB
	p.play()
	_fade(_active, _music_db(), fade, false)

func stop_music(fade := 0.6) -> void:
	_music_id = ""
	for i in 2:
		_fade(i, SILENT_DB, fade, true)

func sfx(id: String) -> void:
	var stream := _find("res://audio/sfx/" + id)
	if stream == null:
		return
	for p in _sfx:
		if not p.playing:
			p.stream = stream
			p.volume_db = linear_to_db(maxf(Settings.sfx_volume, 0.0001))
			p.play()
			return

func _music_db() -> float:
	return linear_to_db(maxf(Settings.music_volume, 0.0001))

func _fade(idx: int, to_db: float, secs: float, stop_after: bool) -> void:
	var p: AudioStreamPlayer = _players[idx]
	if _tweens[idx] != null and _tweens[idx].is_valid():
		_tweens[idx].kill()
	if secs <= 0.0:
		p.volume_db = to_db
		if stop_after:
			p.stop()
		return
	var tw := create_tween()
	_tweens[idx] = tw
	tw.tween_property(p, "volume_db", to_db, secs)
	if stop_after:
		tw.tween_callback(p.stop)

func _apply_volume() -> void:
	var p: AudioStreamPlayer = _players[_active]
	if p.playing and _music_id != "":
		p.volume_db = _music_db()

func _find(base: String) -> AudioStream:
	for ext in [".ogg", ".wav"]:
		if ResourceLoader.exists(base + ext):
			return load(base + ext)
	return null
