@tool
class_name KeyPickup
extends Node2D


@onready var actionable: Actionable = $Actionable

@export var pickup_dialogue: DialogueResource


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	Blackboard.increment_data("keys", 1)
	
	actionable.action.connect(_pickup)


func _pickup() -> void:
	Blackboard.increment_data("keys", -1)
	
	if Blackboard.get_data("keys") == 0:
		game_manager.no_keys_left.emit()
	
	# Tell the player how much keys are left
	dialogue_manager.start_dialogue(pickup_dialogue)
	
	game_manager.key_used.emit(self)
	queue_free()
