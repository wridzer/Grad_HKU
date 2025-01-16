@tool
class_name Barrel
extends Node2D


@onready var actionable: Actionable = $Actionable


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	actionable.action.connect(_pickup)


func _pickup() -> void:
	var actor:AnimatedCharacter = actionable.interactor
	if is_instance_valid(actor as Player):
		actor = actor as Player
	elif is_instance_valid(actor as Npc):
		actor = actor as Npc
	else:
		return
		
	actor.toggle_hide(true)
	actor.global_position = self.global_position
