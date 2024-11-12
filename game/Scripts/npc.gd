class_name Npc
extends AnimatedCharacter


enum CombatType {ATTACK, DEFEND, AVOID}

@onready var health_component: HealthComponent = $HealthComponent
@onready var actionable: Area2D = $Actionable
@onready var name_label: Label = $NameLabel
@onready var state_machine: StateMachine = $StateMachine

@export var display_name: String
@export var idle_dialogue: DialogueResource
@export var hit_dialogue: DialogueResource
@export var following_dialogue: DialogueResource
@export var preferred_combat: CombatType
@export var adapatable_combat: CombatType
@export var unadaptable_combat: CombatType

var affection: int

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
	
	# Assert that all combat preferences are unique types
	assert(preferred_combat != adapatable_combat, name + "'s preferred_combat and adapatable_combat are the same")
	assert(adapatable_combat != unadaptable_combat, name + "'s adapatable_combat and unadaptable_combat are the same")
	assert(unadaptable_combat != preferred_combat, name + "'s unadaptable_combat and preferred_combat are the same")
	
	animation_tree = $CharacterAnimations/AnimationTree
	animation_player = $CharacterAnimations/AnimationPlayer
	
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	health_component.immune.connect(set_immunity_animation_param)
	health_component.immune.connect(hit)
	
	# Set display name label
	name_label.text = display_name


func die() -> void:
	queue_free()


func hit() -> void:
	input_manager.toggle_input(false)
	DialogueManager.show_dialogue_balloon(hit_dialogue, "start")
	is_talking = true


func _on_dialogue_ended(_resource: DialogueResource) -> void:
	is_talking = false
