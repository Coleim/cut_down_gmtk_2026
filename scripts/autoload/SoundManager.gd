extends Node

var _sfx_player: AudioStreamPlayer
var _voice_player: AudioStreamPlayer
var _music_player: AudioStreamPlayer


func _ready() -> void:
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.name = "SFXPlayer"
	add_child(_sfx_player)

	_voice_player = AudioStreamPlayer.new()
	_voice_player.name = "VoicePlayer"
	add_child(_voice_player)

	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	add_child(_music_player)


func play_sfx(sound_name: String) -> void:
	var stream := _load_sfx(sound_name)
	if stream:
		_sfx_player.stream = stream
		_sfx_player.play()
	else:
		print("[SoundManager] SFX not found: %s" % sound_name)


func play_music(sound_name: String, loop: bool = false) -> void:
	var stream: AudioStream = load("res://assets/music/%s.mp3" % sound_name)
	if stream:
		if stream is AudioStreamMP3:
			(stream as AudioStreamMP3).loop = loop
		_music_player.stream = stream
		_music_player.play()
	else:
		print("[SoundManager] Music not found: %s" % sound_name)


func stop_music() -> void:
	_music_player.stop()


func play_oneshot(sound_name: String) -> void:
	var stream: AudioStream = _load_sfx(sound_name)
	if stream == null:
		for ext in ["mp3", "wav"]:
			var path := "res://assets/music/%s.%s" % [sound_name, ext]
			if ResourceLoader.exists(path):
				stream = load(path)
				break
	if stream:
		_voice_player.stream = stream
		_voice_player.play()
	else:
		print("[SoundManager] Oneshot not found: %s" % sound_name)


func _load_sfx(sound_name: String) -> AudioStream:
	var path_wav := "res://assets/sounds/%s.wav" % sound_name
	var path_mp3 := "res://assets/sounds/%s.mp3" % sound_name
	if ResourceLoader.exists(path_wav):
		return load(path_wav)
	if ResourceLoader.exists(path_mp3):
		return load(path_mp3)
	return null
