extends Node2D


@export var _tent_dialogue: DialogueResource

@onready var _actionable: Actionable = $Actionable


func _ready() -> void:
	_actionable.action.connect(_activate_tent)


func _activate_tent() -> void:
	if game_manager.night_time:
		dialogue_manager.start_dialogue(_tent_dialogue, "", "start_night")
	else:
		dialogue_manager.start_dialogue(_tent_dialogue)
