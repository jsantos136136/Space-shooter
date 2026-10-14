extends Node2D
## Explosão de uso único: brilho + faíscas + destroços. Se apaga sozinha.

@export var size := 1.0

@onready var flash: Sprite2D = $Flash
@onready var sparks: CPUParticles2D = $Sparks
@onready var debris: CPUParticles2D = $Debris


func _ready() -> void:
	scale = Vector2.ONE * size
	sparks.restart()
	debris.restart()

	flash.scale = Vector2.ONE * 0.2
	var tween := create_tween().set_parallel()
	tween.tween_property(flash, "scale", Vector2.ONE * 1.1, 0.25) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(flash, "modulate:a", 0.0, 0.3)

	get_tree().create_timer(1.2, false).timeout.connect(queue_free)
