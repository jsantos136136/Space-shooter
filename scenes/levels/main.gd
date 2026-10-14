extends Node2D
## Cena principal da partida. Liga o fim de jogo à tela de Game Over.

@export var game_over_delay := 1.5

@onready var game_over_screen: CanvasLayer = $GameOverScreen


func _ready() -> void:
	GameManager.game_over.connect(_on_game_over)
	Audio.play_music()


func _on_game_over() -> void:
	Audio.play(&"game_over")
	get_tree().create_timer(game_over_delay).timeout.connect(game_over_screen.open)
