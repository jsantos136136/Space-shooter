@tool
extends Node2D
## Desenha um campo de estrelas aleatório (mas determinístico pelo seed).
## Fica dentro de um Parallax2D, que faz o scroll e a repetição infinita.

@export var area := Vector2(540, 960):
	set(value):
		area = value
		queue_redraw()
@export var star_count := 60:
	set(value):
		star_count = value
		queue_redraw()
@export var min_radius := 0.8:
	set(value):
		min_radius = value
		queue_redraw()
@export var max_radius := 1.8:
	set(value):
		max_radius = value
		queue_redraw()
@export var color := Color(1, 1, 1, 0.7):
	set(value):
		color = value
		queue_redraw()
@export var seed_value := 1:
	set(value):
		seed_value = value
		queue_redraw()


func _draw() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in star_count:
		var point := Vector2(rng.randf() * area.x, rng.randf() * area.y)
		var star_color := color
		star_color.a *= rng.randf_range(0.4, 1.0)
		draw_circle(point, rng.randf_range(min_radius, max_radius), star_color)
