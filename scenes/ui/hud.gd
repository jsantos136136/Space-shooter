extends CanvasLayer
## Mostra pontuação, recorde, vidas, anúncio de onda e barra de vida do chefe.

const LIFE_ICON := preload("res://assets/sprites/UI/playerLife1_blue.png")

@onready var score_label: Label = %ScoreLabel
@onready var high_score_label: Label = %HighScoreLabel
@onready var lives_box: HBoxContainer = %LivesBox
@onready var wave_label: Label = %WaveLabel
@onready var boss_panel: Control = %BossPanel
@onready var boss_bar: ProgressBar = %BossBar

var _wave_tween: Tween


func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.high_score_changed.connect(_on_high_score_changed)
	GameManager.lives_changed.connect(_update_lives)
	GameManager.wave_started.connect(_on_wave_started)
	GameManager.boss_health_changed.connect(_on_boss_health_changed)
	GameManager.boss_defeated.connect(boss_panel.hide)

	wave_label.modulate.a = 0.0
	boss_panel.hide()
	_on_score_changed(GameManager.score)
	_on_high_score_changed(GameManager.high_score)
	_update_lives(GameManager.lives)


func _on_score_changed(score: int) -> void:
	score_label.text = "%06d" % score
	score_label.pivot_offset = score_label.size * Vector2(0.0, 0.5)
	var tween := create_tween()
	tween.tween_property(score_label, "scale", Vector2.ONE * 1.15, 0.05)
	tween.tween_property(score_label, "scale", Vector2.ONE, 0.1)


func _on_high_score_changed(high_score: int) -> void:
	high_score_label.text = "HI %06d" % high_score


func _update_lives(lives: int) -> void:
	for child in lives_box.get_children():
		child.queue_free()
	for i in lives:
		var icon := TextureRect.new()
		icon.texture = LIFE_ICON
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		lives_box.add_child(icon)


func _on_wave_started(wave: int, is_boss: bool) -> void:
	wave_label.text = "ALERTA: CHEFE!" if is_boss else "ONDA %d" % wave
	wave_label.modulate = Color(1, 0.35, 0.3, 0) if is_boss else Color(1, 1, 1, 0)
	if _wave_tween:
		_wave_tween.kill()
	_wave_tween = create_tween()
	_wave_tween.tween_property(wave_label, "modulate:a", 1.0, 0.3)
	_wave_tween.tween_interval(1.4)
	_wave_tween.tween_property(wave_label, "modulate:a", 0.0, 0.4)
	Audio.play(&"wave_start", -4.0, 0.0)


func _on_boss_health_changed(current: int, maximum: int) -> void:
	boss_panel.show()
	boss_bar.max_value = maximum
	boss_bar.value = current
