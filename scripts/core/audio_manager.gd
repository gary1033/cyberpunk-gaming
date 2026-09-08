extends Node
## AudioManager - Handles BGM and SFX playback with crossfade support.

var _bgm_player: AudioStreamPlayer
var _bgm_player_2: AudioStreamPlayer  # For crossfade
var _sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS := 8
const BGM_DIR := "res://assets/audio/bgm/"
const THEME_BGM := BGM_DIR + "welcome_mix_110bpm.ogg"
const CLUB_BGM := BGM_DIR + "night_club_chill_100bpm.ogg"
const INVESTIGATION_BGM := BGM_DIR + "strange_experiments_80bpm.ogg"
var _bgm_tween: Tween

var bgm_volume: float = 0.18
var sfx_volume: float = 1.0
var _current_bgm: String = ""

func _ready() -> void:
	# Keep the volume slider independent of the crossfade envelopes.
	if AudioServer.get_bus_index("Music") == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Music")
	set_bgm_volume(bgm_volume)
	# BGM players
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = "Music"
	add_child(_bgm_player)

	_bgm_player_2 = AudioStreamPlayer.new()
	_bgm_player_2.bus = "Music"
	add_child(_bgm_player_2)

	# SFX player pool
	for i in MAX_SFX_PLAYERS:
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		_sfx_players.append(player)

func play_location_bgm(location: String) -> void:
	match location:
		"main_menu", "rooftop", "office_epilogue", "recovery_annex":
			play_bgm(THEME_BGM)
		"abyss_bar", "abyss_bar_backroom", "memory_black_market", "bitstorm_cafe", "auction_handover_room":
			play_bgm(CLUB_BGM)
		_:
			play_bgm(INVESTIGATION_BGM)

func _exit_tree() -> void:
	stop_bgm(false)
	for player in _sfx_players:
		player.stop()

func play_bgm(path: String, crossfade: bool = true) -> void:
	if path == _current_bgm and _bgm_player.playing:
		return

	var stream := load(path) as AudioStream
	if stream == null:
		push_warning("AudioManager: Cannot load BGM '%s'" % path)
		return
	if stream is AudioStreamOggVorbis:
		stream.loop = true
	_current_bgm = path
	if _bgm_tween:
		_bgm_tween.kill()
	_bgm_player_2.stop()

	if crossfade and _bgm_player.playing:
		# Swap immediately: a newer request can cancel the old fade safely.
		var temp := _bgm_player
		_bgm_player = _bgm_player_2
		_bgm_player_2 = temp
		_bgm_player.stream = stream
		_bgm_player.volume_db = -80.0
		_bgm_player.play()
		_bgm_tween = create_tween().set_parallel(true)
		_bgm_tween.tween_property(_bgm_player_2, "volume_db", -80.0, 1.0)
		_bgm_tween.tween_property(_bgm_player, "volume_db", 0.0, 1.0)
		_bgm_tween.chain().tween_callback(_bgm_player_2.stop)
	else:
		_bgm_player.stream = stream
		_bgm_player.volume_db = 0.0
		_bgm_player.play()

func stop_bgm(fade: bool = true) -> void:
	_current_bgm = ""
	if _bgm_tween:
		_bgm_tween.kill()
	_bgm_player_2.stop()
	if fade:
		_bgm_tween = create_tween()
		_bgm_tween.tween_property(_bgm_player, "volume_db", -80.0, 1.0)
		_bgm_tween.tween_callback(_bgm_player.stop)
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
	if path.is_empty():
		return false
	# Exported audio may only exist through an imported-resource remap.
	if not FileAccess.file_exists(path):
		return ResourceLoader.exists(path, "AudioStream")
	if path.get_extension().to_lower() == "ogg":
		var file := FileAccess.open(path, FileAccess.READ)
		# Even the first Vorbis identification page needs at least 58 bytes.
		if file == null or file.get_length() < 58:
			return false
		var signature := file.get_buffer(4).get_string_from_ascii()
		# This is only a header guard; playback still uses Godot's decoder.
		return signature == "OggS" and file.get_8() == 0
	return ResourceLoader.exists(path)

func set_bgm_volume(vol: float) -> void:
	bgm_volume = clamp(vol, 0.0, 1.0)
	var bus := AudioServer.get_bus_index("Music")
	if bus >= 0:
		AudioServer.set_bus_mute(bus, is_zero_approx(bgm_volume))
		AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(bgm_volume, 0.0001)))

func set_sfx_volume(vol: float) -> void:
	sfx_volume = clamp(vol, 0.0, 1.0)
