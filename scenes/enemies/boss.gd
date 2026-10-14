extends Enemy
## Chefe: entra pelo topo, balança de um lado para o outro e alterna padrões de tiro.
## Abaixo de 50% de vida entra na fase 2 (mais rápido e com mais balas).

@export var enter_y := 170.0
@export var sway_speed := 0.7

var _entered := false
var _sway_time := 0.0
var _phase := 1
var _pattern := 0


func _ready() -> void:
	super()
	_fire_timer = 1.0
	GameManager.boss_health_changed.emit(health, max_health)
	Audio.play(&"boss_warning")


func take_damage(amount := 1) -> void:
	if _dead or not _entered:
		return
	GameManager.boss_health_changed.emit(maxi(health - amount, 0), max_health)
	super(amount)
	if _phase == 1 and not _dead and health <= max_health * 0.5:
		_enter_phase_two()


func die() -> void:
	if _dead:
		return
	for i in 6:
		var offset := Vector2(randf_range(-70, 70), randf_range(-50, 50))
		FX.explosion(self, global_position + offset, randf_range(1.0, 2.0))
	Audio.play(&"explosion_big")
	GameManager.shake(1.0)
	GameManager.boss_defeated.emit()
	super()


func _move(delta: float) -> void:
	if not _entered:
		position.y = move_toward(position.y, enter_y, 110.0 * delta)
		_entered = position.y >= enter_y
		return
	_sway_time += delta
	var width := get_viewport_rect().size.x
	position.x = width * 0.5 + sin(_sway_time * sway_speed) * (width * 0.5 - 110.0)
	position.y = enter_y + sin(_sway_time * 1.4) * 18.0


func _attack(delta: float) -> void:
	if not _entered:
		return
	_fire_timer -= delta
	if _fire_timer > 0.0:
		return

	if _phase == 1:
		_pattern = (_pattern + 1) % 2
		match _pattern:
			0: _fire_fan(5, 0.9)
			1: _fire_aimed(3, 0.14)
		_fire_timer = 1.3
	else:
		_pattern = (_pattern + 1) % 3
		match _pattern:
			0: _fire_ring(16)
			1: _fire_fan(7, 1.2)
			2: _fire_aimed(5, 0.12)
		_fire_timer = 0.85
	Audio.play(&"enemy_shoot", -6.0)


func _fire_fan(count: int, arc: float) -> void:
	for i in count:
		var t := float(i) / (count - 1) - 0.5
		_fire(Vector2.DOWN.rotated(t * arc))


func _fire_aimed(count: int, step: float) -> void:
	var base := _direction_to_player()
	for i in count:
		_fire(base.rotated((i - (count - 1) * 0.5) * step), bullet_speed * 1.3)


func _fire_ring(count: int) -> void:
	for i in count:
		_fire(Vector2.DOWN.rotated(TAU * i / count + _sway_time), bullet_speed * 0.8)


func _enter_phase_two() -> void:
	_phase = 2
	sway_speed *= 1.6
	sprite.modulate = Color(1, 0.7, 0.7)
	FX.flash(sprite, 0.4, Color(1, 0.3, 0.2))
	GameManager.shake(0.6)
	Audio.play(&"boss_warning")
