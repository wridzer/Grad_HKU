class_name Key
extends Node2D


@onready var _actionable: Area2D = $Actionable

@export var pickup_dialogue: DialogueResource


func _ready() -> void:
	print("test")
	_actionable.action.connect(_pickup)
	Blackboard.increment_data("keys", 1)


func _pickup() -> void:
	# Tell the player how much keys are left
	dialogue_manager.start_dialogue(pickup_dialogue)
	Blackboard.increment_data("keys", -1)
	var keys = Blackboard.get("keys")
	print(keys)
	print("picked up")
	queue_free()
