extends Node2D


func _ready() -> void:
	input_manager.pause.connect(toggle_pause)


func toggle_pause(paused: bool):
	visible = paused
