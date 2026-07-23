extends Node

## Placeholder sound manager. Sound artist can hook real streams later
## by filling in the `sounds` dictionary with AudioStream resources.
## Autoloaded as "SoundManager".

@export var sounds: Dictionary = {
	"cable_cut": null,
	"correct_cut": null,
	"wrong_cut": null,
	"explosion": null,
	"win": null,
	"tick": null,
	"menu_click": null,
}

var _sfx_player: AudioStreamPlayer
var _music_player: AudioStreamPlayer


func _ready() -> void:
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.name = "SFXPlayer"
	add_child(_sfx_player)

	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	add_child(_music_player)


func play_sfx(sound_name: String) -> void:
	var stream: AudioStream = sounds.get(sound_name)
	if stream:
		_sfx_player.stream = stream
		_sfx_player.play()
	else:
		print("[SoundManager] (placeholder) play sfx: %s" % sound_name)


func play_music(sound_name: String) -> void:
	var stream: AudioStream = sounds.get(sound_name)
	if stream:
		_music_player.stream = stream
		_music_player.play()
	else:
		print("[SoundManager] (placeholder) play music: %s" % sound_name)


func stop_music() -> void:
	_music_player.stop()
