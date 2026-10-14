class_name Bullet
extends Area2D
## Projétil genérico. Quem atinge o quê é definido pelas collision layers/masks da cena.

@export var speed := 900.0
@export var damage := 1

var direction := Vector2.UP

var _has_hit := false


func _ready() -> void:
	rotation = direction.angle() + PI / 2.0
	area_entered.connect(_on_hit)
	body_entered.connect(_on_hit)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	if not get_viewport_rect().grow(64.0).has_point(position):
		queue_free()


func _on_hit(target: Node) -> void:
	if _has_hit or not target.has_method("take_damage"):
		return
	_has_hit = true
	target.take_damage(damage)
	queue_free()
