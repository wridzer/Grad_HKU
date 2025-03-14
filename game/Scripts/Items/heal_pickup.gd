@tool
class_name HealPickup
extends Node2D


@onready var actionable: Actionable = $Actionable

@export var pickup_dialogue: DialogueResource
@export var heal_amount: int = 3

signal heal_used


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	actionable.action.connect(_pickup)


func _pickup() -> void:
	var actor = actionable.interactor
	var max_health: int = 3
	if is_instance_valid(actor as Player):
		actor = actor as Player
		if Blackboard.get_data("player_max_health"):
			max_health = Blackboard.get_data("player_max_health")
	elif is_instance_valid(actor as Npc):
		actor = actor as Npc
		if Blackboard.get_data("npc_max_health"):
			max_health = Blackboard.get_data("npc_max_health")
	else:
		return
	
	if actor.health_component.health < max_health:
		if is_instance_valid(actor as Player):
			Blackboard.increment_data("player_heal_count", max_health - actor.health_component.health)
		actor.health_component.gain_health(heal_amount)
		heal_used.emit(self)
		queue_free()
