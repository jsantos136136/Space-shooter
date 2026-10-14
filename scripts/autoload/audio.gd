extends Node
## Toca efeitos sonoros usando um pool de AudioStreamPlayers e a música de fundo.
## Registrado como autoload "Audio" em project.godot. Uso: Audio.play(&"explosion")

const SOUNDS := {
	&"player_shoot": preload("res://assets/audio/sfx/player_shoot.ogg"),
	&"enemy_shoot": preload("res://assets/audio/sfx/enemy_shoot.ogg"),
	&"enemy_hit": preload("res://assets/audio/sfx/enemy_hit.ogg"),
	&"explosion": preload("res://assets/audio/sfx/explosion.ogg"),
	&"explosion_big": preload("res://assets/audio/sfx/explosion_big.ogg"),
	&"player_hit": preload("res://assets/audio/sfx/player_hit.ogg"),
	&"shield_up": preload("res://assets/audio/sfx/shield_up.ogg"),
	&"powerup": preload("res://assets/audio/sfx/powerup.ogg"),
	&"game_over": preload("res://assets/audio/sfx/game_over.ogg"),
	&"ui_click": preload("res://assets/audio/sfx/ui_click.ogg"),
	&"wave_start": preload("res://assets/audio/sfx/wave_start.ogg"),
	&"boss_warning": preload("res://assets/audio/sfx/boss_warning.ogg"),
}

## Coloque um arquivo .ogg com este nome para ter música de fundo.
const MUSIC_PATH := "res://assets/audio/music/music.ogg"
const POOL_SIZE := 16

var _pool: Array[AudioStreamPlayer] = []
var _next := 0
var _music: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in POOL_SIZE:
		var player := AudioStreamPlayer.new()
		add_child(player)
		_pool.append(player)
	_music = AudioStreamPlayer.new()
	_music.volume_db = -10.0
	add_child(_music)


func _exit_tree() -> void:
	for player in _pool:
		player.stop()
		player.stream = null
	_music.stop()


func play(sound: StringName, volume_db := 0.0, pitch_variation := 0.08) -> void:
	var stream: AudioStream = SOUNDS.get(sound)
	if stream == null:
		push_warning("Som desconhecido: %s" % sound)
		return
	var player := _get_player()
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = randf_range(1.0 - pitch_variation, 1.0 + pitch_variation)
	player.play()


func play_music() -> void:
	if _music.playing or not ResourceLoader.exists(MUSIC_PATH):
		return
	var stream := load(MUSIC_PATH) as AudioStream
	if stream is AudioStreamOggVorbis:
		stream.loop = true
	_music.stream = stream
	_music.play()


func _get_player() -> AudioStreamPlayer:
	for player in _pool:
		if not player.playing:
			return player
	# Todos ocupados: reaproveita em rodízio.
	_next = (_next + 1) % POOL_SIZE
	return _pool[_next]
