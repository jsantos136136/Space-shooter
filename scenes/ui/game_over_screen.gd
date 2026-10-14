extends CanvasLayer
## Tela de fim de jogo com pontuação final, recorde e opções de reiniciar.

@onready var root: Control = $Root
@onready var score_label: Label = %ScoreLabel
@onready var record_label: Label = %RecordLabel
@onready var retry_button: Button = %RetryButton
@onready var menu_button: Button = %MenuButton


func _ready() -> void:
	hide()
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)


func open() -> void:
	score_label.text = "PONTOS: %d" % GameManager.score
	if GameManager.is_new_record():
		record_label.text = "NOVO RECORDE!"
	else:
		record_label.text = "RECORDE: %d" % GameManager.high_score
	show()
	root.modulate.a = 0.0
	create_tween().tween_property(root, "modulate:a", 1.0, 0.4)
	retry_button.grab_focus()


func _on_retry_pressed() -> void:
	Audio.play(&"ui_click")
	GameManager.start_game()


func _on_menu_pressed() -> void:
	Audio.play(&"ui_click")
	GameManager.go_to_title()
