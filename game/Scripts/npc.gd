class_name Npc
extends CharacterBody2D

@onready var health_component: HealthComponent = $HealthComponent
@onready var actionable: Area2D = $Actionable

@export var display_name : String
@export var hit_dialogue : DialogueResource
@export var action_dialogue : DialogueResource


func _ready() -> void:
	health_component.die.connect(die)
	health_component.hit.connect(hit)
	actionable.action.connect(start_dialogue)
	dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)


func die() -> void:
	queue_free()


func hit() -> void:
	input_manager.toggle_input(false)
	dialogue_manager.show_dialogue_balloon(hit_dialogue, "start")


func start_dialogue() -> void:
	input_manager.toggle_input(false)
	dialogue_manager.show_dialogue_balloon(action_dialogue)


func _on_dialogue_ended(resource: DialogueResource) -> void:
	if resource == hit_dialogue:
		return
	
	pass
