class_name Powerup
extends Area2D
## Item que cai de inimigos destruídos. O efeito é aplicado em Player.apply_powerup().

enum Type { WEAPON, SHIELD, LIFE, SCORE }

const TEXTURES := {
	Type.WEAPON: preload("res://assets/sprites/Power-ups/powerupBlue_bolt.png"),
	Type.SHIELD: preload("res://assets/sprites/Power-ups/powerupGreen_shield.png"),
	Type.LIFE: preload("res://assets/sprites/Power-ups/pill_red.png"),
	Type.SCORE: preload("res://assets/sprites/Power-ups/star_gold.png"),
}
## Peso de sorteio de cada tipo (maior = mais comum).
const WEIGHTS := {
	Type.WEAPON: 40,
	Type.SHIELD: 28,
	Type.SCORE: 24,
	Type.LIFE: 8,
}

@export var type := Type.WEAPON
@export var fall_speed := 110.0

var _time := 0.0

@onready var sprite: Sprite2D = $Sprite2D


static func random_type() -> Type:
	var total := 0
	for weight in WEIGHTS.values():
		total += weight
	var roll := randi_range(1, total)
	for key in WEIGHTS:
		roll -= WEIGHTS[key]
		if roll <= 0:
			return key
	return Type.WEAPON


func _ready() -> void:
	sprite.texture = TEXTURES[type]
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	_time += delta
	position.y += fall_speed * delta
	sprite.scale = Vector2.ONE * (1.0 + sin(_time * 6.0) * 0.08)
	if position.y > get_viewport_rect().size.y + 40.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.apply_powerup(type)
		queue_free()
