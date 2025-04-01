extends Node2D


@onready var quit_button: Button = $Control/Button


func _ready() -> void:
	input_manager.pause.connect(toggle_pause)
	quit_button.pressed.connect(game_manager.quit)


func toggle_pause(paused: bool):
	visible = paused
