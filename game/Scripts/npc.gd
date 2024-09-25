class_name Npc
extends CharacterBody2D

@onready var health_component: HealthComponent = $HealthComponent

@export var display_name : String


func _ready() -> void:
	health_component.die.connect(die)
	health_component.hit.connect(hit)


func die() -> void:
	health_component.gain_health(3)
	#TODO npc death functionality


func hit() -> void:
	DialogueManager.show_example_dialogue_balloon(load("res://Dialogue/test.dialogue"), "start")
