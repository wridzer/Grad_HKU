class_name Npc
extends CharacterBody2D


@onready var health_component: HealthComponent = $HealthComponent
@onready var actionable: Area2D = $Actionable
@onready var name_label: Label = $NameLabel
@onready var state_machine: StateMachine = $StateMachine

@export var display_name: String
@export var idle_dialogue: DialogueResource
@export var hit_dialogue: DialogueResource
@export var following_dialogue: DialogueResource

const SPEED := 2500.0
const FOLLOW_DISTANCE := 10.0

var is_talking: bool = false
var saved_spawn_pos: Vector2


func _ready() -> void:
	# Destroy instance if any other instance exists that is following the player
	if Player.instance.following_npc:
		if Player.instance.following_npc.display_name == display_name:
			die()
	
	# Assert that all necessary dialogue has been assigned
	assert(is_instance_valid(idle_dialogue), "Please assign a valid idle_dialogue to " + name)
	assert(is_instance_valid(hit_dialogue), "Please assign a valid hit_dialogue to " + name)
	assert(is_instance_valid(following_dialogue), "Please assign a valid following_dialogue to " + name)
	
	# Connect signals
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
	# Set display name label
	name_label.text = display_name


func die() -> void:
	queue_free()


func _on_dialogue_ended(_resource: DialogueResource) -> void:
	is_talking = false
