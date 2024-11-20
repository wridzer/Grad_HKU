extends Node


func _ready() -> void:
	# dialogue_ended has a parameter, throw it away using an inline anonymous lambda function
	DialogueManager.dialogue_ended.connect(func(_resource): input_manager.toggle_input(true))


func start_dialogue(dialogue: DialogueResource, title: String = "start") -> void:
	input_manager.toggle_input(false)
	DialogueManager.show_dialogue_balloon(dialogue, title)
