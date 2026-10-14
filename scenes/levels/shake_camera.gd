extends Camera2D
## Câmera fixa que treme quando GameManager.shake() é chamado (modelo de "trauma").

@export var max_offset := Vector2(16, 12)
@export var decay := 2.2

var _trauma := 0.0


func _ready() -> void:
	GameManager.shake_requested.connect(add_trauma)


func add_trauma(amount: float) -> void:
	_trauma = minf(_trauma + amount, 1.0)


func _process(delta: float) -> void:
	if _trauma <= 0.0:
		offset = Vector2.ZERO
		return
	_trauma = maxf(_trauma - decay * delta, 0.0)
	var strength := _trauma * _trauma
	offset = Vector2(randf_range(-1, 1) * max_offset.x, randf_range(-1, 1) * max_offset.y) * strength
