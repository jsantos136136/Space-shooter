class_name Player
extends CharacterBody2D
## Nave do jogador: movimento preso à tela, tiro com cooldown, escudo e níveis de arma.

signal died

const BULLET_SCENE := preload("res://scenes/projectiles/player_bullet.tscn")
const MAX_WEAPON_LEVEL := 3
const DAMAGE_TEXTURES: Array[Texture2D] = [
	null,
	preload("res://assets/sprites/Damage/playerShip1_damage1.png"),
	preload("res://assets/sprites/Damage/playerShip1_damage2.png"),
	preload("res://assets/sprites/Damage/playerShip1_damage3.png"),
]

@export var speed := 420.0
@export var acceleration := 3200.0
@export var fire_cooldown := 0.16
@export var invulnerable_time := 1.5
@export var screen_margin := Vector2(34.0, 30.0)

var weapon_level := 1
var has_shield := false

var _cooldown := 0.0
var _invulnerable := false
var _dead := false
var _blink_tween: Tween

@onready var sprite: Sprite2D = $Sprite2D
@onready var damage_sprite: Sprite2D = $Sprite2D/Damage
@onready var shield_sprite: Sprite2D = $Shield
@onready var thruster: Sprite2D = $Thruster
@onready var muzzle: Marker2D = $Muzzle
@onready var invulnerability_timer: Timer = $InvulnerabilityTimer


func _ready() -> void:
	invulnerability_timer.timeout.connect(_end_invulnerability)
	shield_sprite.visible = false
	_update_damage_sprite()


func _physics_process(delta: float) -> void:
	if _dead:
		return

	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = velocity.move_toward(input * speed, acceleration * delta)
	move_and_slide()
	position = position.clamp(screen_margin, get_viewport_rect().size - screen_margin)

	# Inclina levemente a nave na direção do movimento e anima o propulsor.
	sprite.rotation = lerpf(sprite.rotation, velocity.x / speed * 0.15, 12.0 * delta)
	thruster.scale.y = randf_range(0.8, 1.1) + (0.4 if input.y < 0.0 else 0.0)

	_cooldown -= delta
	if Input.is_action_pressed("shoot") and _cooldown <= 0.0:
		shoot()


func shoot() -> void:
	_cooldown = fire_cooldown
	match weapon_level:
		1:
			_spawn_bullet(Vector2.ZERO, 0.0)
		2:
			_spawn_bullet(Vector2(-12, 0), 0.0)
			_spawn_bullet(Vector2(12, 0), 0.0)
		_:
			_spawn_bullet(Vector2.ZERO, 0.0)
			_spawn_bullet(Vector2(-16, 8), -0.2)
			_spawn_bullet(Vector2(16, 8), 0.2)
	Audio.play(&"player_shoot", -8.0)


func take_damage(_amount := 1) -> void:
	if _dead or _invulnerable:
		return

	FX.flash(sprite, 0.2, Color(1, 0.3, 0.3))
	Audio.play(&"player_hit")

	if has_shield:
		_set_shield(false)
		GameManager.shake(0.4)
		_start_invulnerability(0.6)
		return

	GameManager.shake(0.7)
	weapon_level = maxi(weapon_level - 1, 1)
	GameManager.lose_life()
	_update_damage_sprite()
	if GameManager.lives <= 0:
		_die()
	else:
		_start_invulnerability(invulnerable_time)


func apply_powerup(type: Powerup.Type) -> void:
	match type:
		Powerup.Type.WEAPON:
			if weapon_level < MAX_WEAPON_LEVEL:
				weapon_level += 1
			else:
				GameManager.add_score(500)
			Audio.play(&"powerup")
		Powerup.Type.SHIELD:
			_set_shield(true)
			Audio.play(&"shield_up")
		Powerup.Type.LIFE:
			GameManager.gain_life()
			_update_damage_sprite()
			Audio.play(&"powerup")
		Powerup.Type.SCORE:
			GameManager.add_score(1000)
			Audio.play(&"powerup")
	FX.flash(sprite, 0.25, Color(0.6, 1, 0.6))


func _spawn_bullet(offset: Vector2, angle: float) -> void:
	var bullet: Bullet = BULLET_SCENE.instantiate()
	bullet.direction = Vector2.UP.rotated(angle)
	FX.spawn(self, bullet, muzzle.global_position + offset)


func _set_shield(enabled: bool) -> void:
	has_shield = enabled
	shield_sprite.visible = enabled


func _start_invulnerability(duration: float) -> void:
	_invulnerable = true
	invulnerability_timer.start(duration)
	if _blink_tween:
		_blink_tween.kill()
	_blink_tween = create_tween().set_loops()
	_blink_tween.tween_property(sprite, "modulate:a", 0.3, 0.08)
	_blink_tween.tween_property(sprite, "modulate:a", 1.0, 0.08)


func _end_invulnerability() -> void:
	_invulnerable = false
	if _blink_tween:
		_blink_tween.kill()
	sprite.modulate.a = 1.0


func _update_damage_sprite() -> void:
	var index := clampi(GameManager.START_LIVES - GameManager.lives, 0, DAMAGE_TEXTURES.size() - 1)
	damage_sprite.texture = DAMAGE_TEXTURES[index]


func _die() -> void:
	_dead = true
	FX.explosion(self, global_position, 2.0)
	Audio.play(&"explosion_big")
	GameManager.shake(1.0)
	died.emit()
	queue_free()
