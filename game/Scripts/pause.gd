extends Node2D


@onready var pause_text: RichTextLabel = $Control/PauseText


func _ready() -> void:
	input_manager.pause.connect(toggle_pause)


func toggle_pause(paused: bool):
	visible = paused
