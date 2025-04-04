extends Node


var _active_dialogue: bool


func _ready() -> void:
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


func start_dialogue(dialogue: DialogueResource, display_name: String = "", title: String = "start") -> void:
	if !_active_dialogue:
		_active_dialogue = true
		input_manager.toggle_input(false)
		DialogueManager.show_dialogue_balloon(dialogue, title)
		if display_name:
			Blackboard.increment_data("spoken_to_" + display_name, 1)


func _on_dialogue_ended(_resource) -> void:
	input_manager.toggle_input(true)
	_active_dialogue = false
