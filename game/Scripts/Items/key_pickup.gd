@tool
class_name KeyPickup
extends Node2D


signal no_keys_left

@onready var _actionable: Area2D = $Actionable

@export var pickup_dialogue: DialogueResource

signal key_used


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	Blackboard.increment_data("keys", 1)
	
	_actionable.action.connect(_pickup)


func _pickup() -> void:
	Blackboard.increment_data("keys", -1)
	
	if Blackboard.get_data("keys") == 0:
		no_keys_left.emit()
	
	# Tell the player how much keys are left
	dialogue_manager.start_dialogue(pickup_dialogue)

	key_used.emit()
	queue_free()
