@tool
class_name Heal
extends Node2D

@onready var _actionable: Area2D = $Actionable

@export var pickup_dialogue: DialogueResource
@export var heal_amount: int = 3


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_actionable.action.connect(_pickup)


func _pickup() -> void:
	var actor = _actionable.interactor
	if is_instance_valid(actor as Player):
		actor = actor as Player
		actor._health_component.gain_health(heal_amount)
	elif is_instance_valid(actor as Npc):
		actor = actor as Npc
		actor._health_component.gain_health(heal_amount)
	else:
		return
		
	queue_free()
