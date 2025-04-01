extends Node2D


@onready var quit_button: Button = $Control/Button


func _ready() -> void:
	game_manager.fired.connect(fired)
	quit_button.pressed.connect(game_manager.quit)


func fired():
	input_manager.toggle_pause()
	visible = true
