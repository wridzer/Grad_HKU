@tool
class_name Key
extends Node2D


signal no_keys

@onready var _actionable: Area2D = $Actionable

@export var pickup_dialogue: DialogueResource


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	Blackboard.increment_data("keys", 1)
	
	_actionable.action.connect(_pickup)


func _pickup() -> void:
	Blackboard.increment_data("keys", -1)
	
	if Blackboard.get_data("keys") == 0:
		no_keys.emit()
	
	# Tell the player how much keys are left
	dialogue_manager.start_dialogue(pickup_dialogue)
	queue_free()
