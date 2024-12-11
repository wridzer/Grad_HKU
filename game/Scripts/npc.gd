class_name Npc
extends AnimatedCharacter

enum CombatType {ATTACK, DEFEND, AVOID}

const MAX_ARROW_COUNT = 5

@export var _preferred_combat: CombatType
@export var _adapatable_combat: CombatType
@export var _unadaptable_combat: CombatType
@export_file var _arrow_path: String

@export var display_name: String
@export var idle_dialogue: DialogueResource
@export var hit_dialogue: DialogueResource
@export var following_dialogue: DialogueResource
@export var goap_agent: GoapAgent

@export var follow_distance: float = 15.0
@export var chase_distance: float = 10.0
@export var flee_distance: float = 50.0
@export var follow_speed: float = 60.0
@export var chase_speed: float = 70.0
@export var flee_speed: float = 65.0
@export var _max_chase_distance: float = 100.0
@export var _slash_priority: int = 14
@export var _shoot_priority: int = 14
@export var _block_priority: int = 14

var _affection: int
var _arrows: Array[Arrow]

var follow_distance_squared: float = follow_distance * follow_distance
var chase_distance_squared: float = chase_distance * chase_distance
var _max_chase_distance_squared: float = _max_chase_distance * _max_chase_distance
var flee_distance_squared: float = flee_distance * flee_distance
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
	
	# Set Blackboard values
	Blackboard.add_data("follow_distance_squared", follow_distance_squared)
	Blackboard.add_data("max_chase_distance_squared", _max_chase_distance_squared)


func _process(_delta) -> void:
	if Player.instance.following_npc == self:
		Blackboard.add_data("npc_global_position", global_position)


func die() -> void:
	_health_component.gain_health(3)
	
	#if Player.instance.following_npc == self:
		#Player.instance.following_npc = null
	#
	#queue_free()


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
	_health_component.set_blackboard_variables()
	
	var data = Blackboard.get_data("npc_choices")
	var npc_choices: Array[CombatType] = []
	if is_instance_valid(data):
		npc_choices = data
	npc_choices.append(_preferred_combat)
	Blackboard.add_data("npc_choices", npc_choices)
	
	Blackboard.add_data("slash_priority", _slash_priority)
	Blackboard.add_data("shoot_priority", _shoot_priority)
	Blackboard.add_data("block_priority", _block_priority)


func shoot(arrow_direction: Vector2) -> void:
	# Create a new arrow
	var arrow_resource: Resource = ResourceLoader.load(_arrow_path, PackedScene.new().get_class(), ResourceLoader.CACHE_MODE_IGNORE)
	var arrow: Arrow = arrow_resource.instantiate()
	arrow.mouse_position = get_viewport().get_camera_2d().get_global_mouse_position()
	arrow.direction = arrow_direction
	add_child(arrow)
	arrow.reparent(get_parent())
	_arrows.append(arrow)
	
	# There should only be MAX_ARROW_COUNT arrows at once
	_reduce_arrows_to(MAX_ARROW_COUNT)
	
	# Remove arrow from list when freeing
	arrow.tree_exiting.connect(func(): _arrows.erase(arrow))
	
	# Animate bow
	super.shoot(direction)


func _reduce_arrows_to(amount: int) -> void:
	while _arrows.size() > amount:
		if is_instance_valid(_arrows.front()):
			_arrows.pop_front().queue_free()
		else:
			_arrows.pop_front()
