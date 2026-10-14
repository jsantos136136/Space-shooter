class_name Enemy
extends Area2D
## Inimigo base. As variantes (cenas herdadas de enemy.tscn) só mudam os valores exportados.

## Emitido quando o inimigo sai do jogo (morto ou fora da tela). Usado pelo WaveSpawner.
signal removed

enum Movement { STRAIGHT, SINE, ZIGZAG, DIVE }
enum ShotPattern { NONE, STRAIGHT, AIMED, SPREAD }

const ENEMY_BULLET_SCENE := preload("res://scenes/projectiles/enemy_bullet.tscn")
const POWERUP_SCENE := preload("res://scenes/powerups/powerup.tscn")

@export_group("Stats")
@export var max_health := 1
@export var speed := 160.0
@export var score_value := 100
@export var dies_on_contact := true

@export_group("Movement")
@export var movement := Movement.STRAIGHT
@export var wave_amplitude := 80.0
@export var wave_frequency := 2.0
## Tempo descendo devagar antes de mergulhar no jogador (só no modo DIVE).
@export var dive_delay := 0.9
@export var spin_speed := 0.0

@export_group("Shooting")
@export var shot_pattern := ShotPattern.NONE
@export var fire_interval := 2.0
@export var bullet_speed := 300.0

@export_group("Death")
@export_range(0.0, 1.0) var drop_chance := 0.08
@export var explosion_size := 1.0

var health := 0
## Ajustado pelo WaveSpawner para aumentar a dificuldade com as ondas.
var speed_multiplier := 1.0

var _time := 0.0
var _origin_x := 0.0
var _fire_timer := 0.0
var _dive_direction := Vector2.ZERO
var _dead := false

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	health = max_health
	_origin_x = position.x
	_fire_timer = randf_range(0.4, fire_interval)
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	_time += delta
	_move(delta)
	if spin_speed != 0.0:
		sprite.rotation += spin_speed * delta
	if position.y > 0.0:
		_attack(delta)
	if not get_viewport_rect().grow(140.0).has_point(position):
		_remove()


func take_damage(amount := 1) -> void:
	if _dead:
		return
	health -= amount
	if health <= 0:
		die()
	else:
		FX.flash(sprite)
		Audio.play(&"enemy_hit", -10.0)


func die() -> void:
	if _dead:
		return
	_dead = true
	GameManager.add_score(score_value)
	FX.explosion(self, global_position, explosion_size)
	Audio.play(&"explosion", -4.0)
	GameManager.shake(0.12 * explosion_size)
	if randf() < drop_chance:
		_drop_powerup()
	_remove()


func _move(delta: float) -> void:
	var current_speed := speed * speed_multiplier
	match movement:
		Movement.STRAIGHT:
			position.y += current_speed * delta
		Movement.SINE:
			position.y += current_speed * delta
			position.x = _origin_x + sin(_time * wave_frequency) * wave_amplitude
		Movement.ZIGZAG:
			position.y += current_speed * delta
			var phase := fmod(_time * wave_frequency * 0.5, 2.0)
			var triangle := phase if phase < 1.0 else 2.0 - phase
			position.x = _origin_x + (triangle * 2.0 - 1.0) * wave_amplitude
		Movement.DIVE:
			if _time < dive_delay:
				position.y += current_speed * 0.6 * delta
			else:
				if _dive_direction == Vector2.ZERO:
					_dive_direction = _direction_to_player()
					sprite.rotation = _dive_direction.angle() - PI / 2.0
				position += _dive_direction * current_speed * 2.6 * delta


## Sobrescreva em subclasses (ex.: Boss) para padrões de tiro próprios.
func _attack(delta: float) -> void:
	if shot_pattern == ShotPattern.NONE:
		return
	_fire_timer -= delta
	if _fire_timer > 0.0:
		return
	_fire_timer = fire_interval
	match shot_pattern:
		ShotPattern.STRAIGHT:
			_fire(Vector2.DOWN)
		ShotPattern.AIMED:
			_fire(_direction_to_player())
		ShotPattern.SPREAD:
			for angle in [-0.3, 0.0, 0.3]:
				_fire(Vector2.DOWN.rotated(angle))
	Audio.play(&"enemy_shoot", -12.0)


func _fire(direction: Vector2, speed_override := -1.0) -> void:
	var bullet: Bullet = ENEMY_BULLET_SCENE.instantiate()
	bullet.direction = direction
	bullet.speed = speed_override if speed_override > 0.0 else bullet_speed
	FX.spawn(self, bullet, global_position + direction * 30.0)


func _direction_to_player() -> Vector2:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return Vector2.DOWN
	return global_position.direction_to(player.global_position)


func _drop_powerup() -> void:
	var powerup: Powerup = POWERUP_SCENE.instantiate()
	powerup.type = Powerup.random_type()
	FX.spawn(self, powerup, global_position)


func _remove() -> void:
	if is_queued_for_deletion():
		return
	_dead = true
	removed.emit()
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if _dead or not body.has_method("take_damage"):
		return
	body.take_damage(1)
	if dies_on_contact:
		die()
