extends Control
## Tela inicial: começar partida, ver recorde e sair (o botão Sair some na versão Web).

@onready var play_button: Button = %PlayButton
@onready var quit_button: Button = %QuitButton
@onready var high_score_label: Label = %HighScoreLabel
@onready var ship: TextureRect = %Ship

var _time := 0.0


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	quit_button.visible = not OS.has_feature("web")
	high_score_label.text = "RECORDE: %d" % GameManager.high_score
	play_button.grab_focus()
	Audio.play_music()


func _process(delta: float) -> void:
	_time += delta
	ship.position.y = sin(_time * 2.0) * 6.0


func _on_play_pressed() -> void:
	Audio.play(&"ui_click")
	GameManager.start_game()


func _on_quit_pressed() -> void:
	get_tree().quit()
