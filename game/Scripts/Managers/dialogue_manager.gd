extends Node


var active_dialogue: bool


func _ready() -> void:
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


func start_dialogue(dialogue: DialogueResource, title: String = "start") -> void:
	if !active_dialogue:
		active_dialogue = true
		input_manager.toggle_input(false)
		DialogueManager.show_dialogue_balloon(dialogue, title)


func _on_dialogue_ended(_resource) -> void:
	input_manager.toggle_input(true)
	active_dialogue = false
