extends Node
## Estado global da partida: pontuação, vidas, recorde e troca de cenas.
## Registrado como autoload "GameManager" em project.godot.

signal score_changed(score: int)
signal high_score_changed(high_score: int)
signal lives_changed(lives: int)
signal wave_started(wave: int, is_boss: bool)
signal boss_health_changed(current: int, maximum: int)
signal boss_defeated
signal shake_requested(amount: float)
signal game_over

const MAIN_SCENE := "res://scenes/levels/main.tscn"
const TITLE_SCENE := "res://scenes/ui/title_screen.tscn"
const SAVE_PATH := "user://save.cfg"
const START_LIVES := 3
const MAX_LIVES := 5

var score := 0
var high_score := 0
var lives := START_LIVES
var wave := 0
var is_game_over := false

var _high_score_at_start := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_high_score()


func start_game() -> void:
	score = 0
	lives = START_LIVES
	wave = 0
	is_game_over = false
	_high_score_at_start = high_score
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_SCENE)


func go_to_title() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(TITLE_SCENE)


func add_score(points: int) -> void:
	if is_game_over:
		return
	score += points
	score_changed.emit(score)
	if score > high_score:
		high_score = score
		high_score_changed.emit(high_score)


func lose_life() -> void:
	if is_game_over:
		return
	lives = maxi(lives - 1, 0)
	lives_changed.emit(lives)
	if lives == 0:
		_trigger_game_over()


func gain_life() -> void:
	lives = mini(lives + 1, MAX_LIVES)
	lives_changed.emit(lives)


func is_new_record() -> bool:
	return score > _high_score_at_start


func shake(amount: float) -> void:
	shake_requested.emit(amount)


func _trigger_game_over() -> void:
	is_game_over = true
	_save_high_score()
	game_over.emit()


func _load_high_score() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		high_score = config.get_value("scores", "high_score", 0)


func _save_high_score() -> void:
	var config := ConfigFile.new()
	config.set_value("scores", "high_score", high_score)
	config.save(SAVE_PATH)
