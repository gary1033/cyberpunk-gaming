extends Node
## AudioManager - Handles BGM and SFX playback with crossfade support.

var _bgm_player: AudioStreamPlayer
var _bgm_player_2: AudioStreamPlayer  # For crossfade
var _sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS := 8

var bgm_volume: float = 0.8
var sfx_volume: float = 1.0
var _current_bgm: String = ""

func _ready() -> void:
	# BGM players
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = "Master"
	add_child(_bgm_player)

	_bgm_player_2 = AudioStreamPlayer.new()
	_bgm_player_2.bus = "Master"
	add_child(_bgm_player_2)

	# SFX player pool
	for i in MAX_SFX_PLAYERS:
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		_sfx_players.append(player)

func play_bgm(path: String, crossfade: bool = true) -> void:
	if path == _current_bgm:
		return

	_current_bgm = path
	var stream := load(path) as AudioStream
	if stream == null:
		push_warning("AudioManager: Cannot load BGM '%s'" % path)
		return

	if crossfade and _bgm_player.playing:
		# Crossfade
		_bgm_player_2.stream = stream
		_bgm_player_2.volume_db = -80.0
		_bgm_player_2.play()

		var tween := create_tween().set_parallel(true)
		tween.tween_property(_bgm_player, "volume_db", -80.0, 1.0)
		tween.tween_property(_bgm_player_2, "volume_db", linear_to_db(bgm_volume), 1.0)
		await tween.finished

		_bgm_player.stop()
		# Swap players
		var temp := _bgm_player
		_bgm_player = _bgm_player_2
		_bgm_player_2 = temp
	else:
		_bgm_player.stream = stream
		_bgm_player.volume_db = linear_to_db(bgm_volume)
		_bgm_player.play()

func stop_bgm(fade: bool = true) -> void:
	_current_bgm = ""
	if fade:
		var tween := create_tween()
		tween.tween_property(_bgm_player, "volume_db", -80.0, 1.0)
		await tween.finished
		_bgm_player.stop()
	else:
		_bgm_player.stop()

func play_sfx(path: String) -> void:
	var stream := load(path) as AudioStream
	if stream == null:
		return

	for player in _sfx_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = linear_to_db(sfx_volume)
			player.play()
			return

	# All players busy, use the first one
	_sfx_players[0].stream = stream
	_sfx_players[0].volume_db = linear_to_db(sfx_volume)
	_sfx_players[0].play()

func play_optional_sfx(path: String) -> void:
	if not is_runtime_audio_ready(path):
		return
	play_sfx(path)

func is_runtime_audio_ready(path: String) -> bool:
	if path == "" or not FileAccess.file_exists(path):
		return false
	if path.get_extension().to_lower() == "ogg":
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null or file.get_length() < 4:
			return false
		var signature := file.get_buffer(4).get_string_from_ascii()
		return signature == "OggS"
	return ResourceLoader.exists(path)

func set_bgm_volume(vol: float) -> void:
	bgm_volume = clamp(vol, 0.0, 1.0)
	if _bgm_player.playing:
		_bgm_player.volume_db = linear_to_db(bgm_volume)

func set_sfx_volume(vol: float) -> void:
	sfx_volume = clamp(vol, 0.0, 1.0)
