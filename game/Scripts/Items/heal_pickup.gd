@tool
class_name HealPickup
extends Node2D

@onready var _actionable: Area2D = $Actionable

@export var pickup_dialogue: DialogueResource
@export var heal_amount: int = 3

signal heal_used

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_actionable.action.connect(_pickup)


func _pickup() -> void:
	var actor = _actionable.interactor
	if is_instance_valid(actor as Player):
		actor = actor as Player
	elif is_instance_valid(actor as Npc):
		actor = actor as Npc
	else:
		return
	
	if actor._health_component.health < actor._health_component._max_health:
		actor._health_component.gain_health(heal_amount)
		heal_used.emit(self)
		queue_free()
		
