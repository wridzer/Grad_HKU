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
var direction: Vector2 = Vector2.ZERO

var affection: int

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
	
	health_component.immune.connect(set_immunity_animation_param)
	health_component.immune.connect(hit)
	health_component.die.connect(die)
	
	# Set display name label
	name_label.text = display_name
	
	# Enable animations
	animation_tree = $CharacterAnimations/AnimationTree
	animation_player = $CharacterAnimations/AnimationPlayer
	animation_tree.active = true
	animation_player.active = true


func die() -> void:
	if Player.instance.following_npc == self:
		Player.instance.following_npc = null
	
	queue_free()


func hit(immune: bool) -> void:
	if immune:
		dialogue_manager.start_dialogue(hit_dialogue)


func update_animation_parameters() -> void:
	# Set blend position parameters and display correct animation direction
	# TODO: npc animations
	animation_tree.set("parameters/conditions/idle", direction == Vector2.ZERO)
	animation_tree.set("parameters/conditions/moving", direction != Vector2.ZERO)
	
	if direction.length() > 0:
		animation_tree.set("parameters/Hit/blend_position", direction)
		animation_tree.set("parameters/Idle/blend_position", direction)
		animation_tree.set("parameters/Walk/blend_position", direction)
	
	super.update_animation_parameters()
