class_name Npc
extends AnimatedCharacter

enum CombatType {ATTACK, DEFEND, AVOID}

@export var _preferred_combat: CombatType
@export var _adapatable_combat: CombatType
@export var _unadaptable_combat: CombatType
@export_file var _arrow_path: String

@export var display_name: String
@export var idle_dialogue: DialogueResource
@export var hit_dialogue: DialogueResource
@export var following_dialogue: DialogueResource
@export var goap_agent: GoapAgent

var _affection: int

var direction: Vector2 = Vector2.ZERO
var saved_spawn_pos: Vector2

@onready var _health_component: HealthComponent = $HealthComponent
@onready var _name_label: Label = $NameLabel
@onready var actionable: Area2D = $Actionable


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
	assert(_preferred_combat != _adapatable_combat, name + "'s _preferred_combat and _adapatable_combat are the same")
	assert(_adapatable_combat != _unadaptable_combat, name + "'s _adapatable_combat and _unadaptable_combat are the same")
	assert(_unadaptable_combat != _preferred_combat, name + "'s _unadaptable_combat and _preferred_combat are the same")
	Blackboard.add_data("preferred_combat", _preferred_combat)
	Blackboard.add_data("adapatable_combat", _adapatable_combat)
	Blackboard.add_data("unadaptable_combat", _unadaptable_combat)
	
	_health_component.die.connect(die)
	_health_component.immune.connect(hit)
	_health_component.immune.connect(set_immunity_animation_param)
	
	# Set display name label
	_name_label.text = display_name
	
	# Enable animations
	animation_tree = $CharacterAnimations/AnimationTree
	animation_player = $CharacterAnimations/AnimationPlayer
	animation_tree.active = true
	animation_player.active = true


func _process(delta) -> void:
	Blackboard.add_data("npc_location", self.position)


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


func choose() -> void:
	var data = Blackboard.get_data("npc_choices")
	var npc_choices: Array[CombatType] = []
	if is_instance_valid(data):
		npc_choices = data
	npc_choices.append(_preferred_combat)
	Blackboard.add_data("npc_choices", npc_choices)
