class_name FX
extends RefCounted
## Funções utilitárias de efeitos visuais e de spawn, usadas por várias entidades.

const EXPLOSION_SCENE := preload("res://scenes/effects/explosion.tscn")
const FLASH_SHADER := preload("res://assets/shaders/hit_flash.gdshader")


## Adiciona um nó na cena atual (de forma deferred, seguro dentro de callbacks de física).
static func spawn(context: Node, node: Node2D, at: Vector2) -> void:
	node.position = at
	context.get_tree().current_scene.add_child.call_deferred(node)


static func explosion(context: Node, at: Vector2, size := 1.0) -> void:
	var effect := EXPLOSION_SCENE.instantiate()
	effect.size = size
	spawn(context, effect, at)


## Pisca o sprite em branco (feedback de dano).
static func flash(item: CanvasItem, duration := 0.15, color := Color.WHITE) -> void:
	var mat := item.material as ShaderMaterial
	if mat == null:
		mat = ShaderMaterial.new()
		mat.shader = FLASH_SHADER
		item.material = mat
	mat.set_shader_parameter("flash_color", color)
	var tween := item.create_tween()
	tween.tween_method(func(v: float) -> void: mat.set_shader_parameter("flash_amount", v), 1.0, 0.0, duration)
