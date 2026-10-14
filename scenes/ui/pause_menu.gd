extends CanvasLayer
## Menu de pausa (Esc / P). Roda com process_mode ALWAYS para funcionar com o jogo pausado.

@onready var resume_button: Button = %ResumeButton
@onready var menu_button: Button = %MenuButton


func _ready() -> void:
	hide()
	resume_button.pressed.connect(_on_resume_pressed)
	menu_button.pressed.connect(_on_menu_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not GameManager.is_game_over:
		_set_paused(not get_tree().paused)
		get_viewport().set_input_as_handled()


func _set_paused(paused: bool) -> void:
	get_tree().paused = paused
	visible = paused
	if paused:
		resume_button.grab_focus()


func _on_resume_pressed() -> void:
	Audio.play(&"ui_click")
	_set_paused(false)


func _on_menu_pressed() -> void:
	Audio.play(&"ui_click")
	GameManager.go_to_title()
