class_name Npc
extends CharacterBody2D

@onready var health_component: HealthComponent = $HealthComponent

@export var display_name : String
@export var dialogue : DialogueResource


func _ready() -> void:
	health_component.die.connect(die)
	health_component.hit.connect(hit)
	dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)


func die() -> void:
	health_component.gain_health(3)
	#TODO npc death functionality


func hit() -> void:
	input_manager.toggle_input(false)
	dialogue_manager.show_dialogue_balloon(dialogue, "start")


func _on_dialogue_ended(_resource: DialogueResource) -> void:
	await get_tree().create_timer(0.4).timeout
