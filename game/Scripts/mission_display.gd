extends Node2D


@export var _mission_dialogue: DialogueResource

@onready var _actionable: Area2D = $Actionable


func _ready() -> void:
	_actionable.action.connect(_activate_display)


func _activate_display() -> void:
	dialogue_manager.start_dialogue(_mission_dialogue)
