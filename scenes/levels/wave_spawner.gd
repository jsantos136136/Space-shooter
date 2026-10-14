extends Node
## Gera ondas de inimigos em grupos/formações, com dificuldade crescente.
## A cada `boss_every` ondas aparece um chefe. Meteoros caem de forma independente.

enum State { INTERMISSION, SPAWNING, WAITING_CLEAR }

const ENEMY_BASIC := preload("res://scenes/enemies/enemy_basic.tscn")
const ENEMY_SINE := preload("res://scenes/enemies/enemy_sine.tscn")
const ENEMY_SHOOTER := preload("res://scenes/enemies/enemy_shooter.tscn")
const ENEMY_KAMIKAZE := preload("res://scenes/enemies/enemy_kamikaze.tscn")
const METEOR := preload("res://scenes/enemies/meteor.tscn")
const BOSS := preload("res://scenes/enemies/boss.tscn")

const SPAWN_Y := -60.0
const SIDE_MARGIN := 50.0

@export var boss_every := 5
@export var time_between_waves := 2.5
@export var meteor_interval := Vector2(3.0, 7.0)

var wave := 0

var _state := State.INTERMISSION
var _groups_left := 0
var _alive := 0

@onready var wave_timer: Timer = $WaveTimer
@onready var meteor_timer: Timer = $MeteorTimer


func _ready() -> void:
	wave_timer.timeout.connect(_on_wave_timer_timeout)
	meteor_timer.timeout.connect(_on_meteor_timer_timeout)
	meteor_timer.start(randf_range(meteor_interval.x, meteor_interval.y))
	# Deferred para o HUD (que entra na árvore depois) já estar ouvindo wave_started.
	_start_next_wave.call_deferred()


func _start_next_wave() -> void:
	wave += 1
	GameManager.wave = wave
	_state = State.INTERMISSION
	GameManager.wave_started.emit(wave, _is_boss_wave())
	wave_timer.start(time_between_waves)


func _on_wave_timer_timeout() -> void:
	if GameManager.is_game_over:
		return
	match _state:
		State.INTERMISSION:
			if _is_boss_wave():
				_spawn_boss()
				_state = State.WAITING_CLEAR
			else:
				_groups_left = 3 + wave * 2
				_state = State.SPAWNING
				wave_timer.start(0.1)
		State.SPAWNING:
			_spawn_group()
			_groups_left -= 1
			if _groups_left > 0:
				wave_timer.start(maxf(0.6, 1.8 - wave * 0.08))
			else:
				_state = State.WAITING_CLEAR
				_check_wave_cleared()


func _on_meteor_timer_timeout() -> void:
	if not GameManager.is_game_over:
		var meteor := _spawn(METEOR, Vector2(_random_x(), SPAWN_Y), false)
		meteor.speed *= randf_range(0.8, 1.3)
	meteor_timer.start(randf_range(meteor_interval.x, meteor_interval.y))


@warning_ignore("integer_division")
func _spawn_group() -> void:
	var options: Array[StringName] = [&"basic", &"basic"]
	if wave >= 2:
		options.append(&"sine")
	if wave >= 3:
		options.append(&"shooter")
	if wave >= 4:
		options.append(&"kamikaze")
	if wave >= 6:
		options.append(&"shooter")
		options.append(&"kamikaze")

	match options.pick_random():
		&"basic":
			_spawn_v_formation(ENEMY_BASIC, mini(3 + wave / 2, 7))
		&"sine":
			_spawn_column(ENEMY_SINE, mini(4 + wave / 3, 7))
		&"shooter":
			for i in 1 + wave / 4:
				_spawn(ENEMY_SHOOTER, Vector2(_random_x(80.0), SPAWN_Y - i * 90.0))
		&"kamikaze":
			for i in 2 + wave / 5:
				_spawn(ENEMY_KAMIKAZE, Vector2(_random_x(), SPAWN_Y - i * 70.0))


func _spawn_v_formation(scene: PackedScene, count: int) -> void:
	var spacing := 58.0
	var half_width := (count - 1) * spacing * 0.5
	var center_x := _random_x(half_width + SIDE_MARGIN)
	for i in count:
		var offset := i - (count - 1) * 0.5
		_spawn(scene, Vector2(center_x + offset * spacing, SPAWN_Y - absf(offset) * 45.0))


func _spawn_column(scene: PackedScene, count: int) -> void:
	var x := _random_x(110.0 + SIDE_MARGIN)
	for i in count:
		_spawn(scene, Vector2(x, SPAWN_Y - i * 70.0))


@warning_ignore("integer_division")
func _spawn_boss() -> void:
	var boss: Enemy = BOSS.instantiate()
	var boss_level := wave / boss_every
	boss.max_health = 70 + (boss_level - 1) * 45
	boss.position = Vector2(get_viewport().get_visible_rect().size.x * 0.5, -120.0)
	_track(boss)
	get_parent().add_child(boss)


func _spawn(scene: PackedScene, at: Vector2, counts_for_wave := true) -> Enemy:
	var enemy: Enemy = scene.instantiate()
	enemy.position = at
	enemy.speed_multiplier = _difficulty()
	if counts_for_wave:
		_track(enemy)
	get_parent().add_child(enemy)
	return enemy


func _track(enemy: Enemy) -> void:
	_alive += 1
	enemy.removed.connect(_on_enemy_removed)


func _on_enemy_removed() -> void:
	_alive -= 1
	_check_wave_cleared()


func _check_wave_cleared() -> void:
	if _state == State.WAITING_CLEAR and _alive <= 0 and not GameManager.is_game_over:
		_start_next_wave()


func _is_boss_wave() -> bool:
	return wave % boss_every == 0


func _difficulty() -> float:
	return minf(1.0 + (wave - 1) * 0.07, 1.8)


func _random_x(margin := SIDE_MARGIN) -> float:
	var width := get_viewport().get_visible_rect().size.x
	return randf_range(margin, maxf(margin, width - margin))
