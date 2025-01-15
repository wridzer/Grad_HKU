class_name Npc
extends AnimatedCharacter


enum CombatType {ATTACK, DEFEND, AVOID}

const MAX_ARROW_COUNT = 5

@export_file var _arrow_path: String

@export var display_name: String
@export var idle_dialogue: DialogueResource
@export var hit_dialogue: DialogueResource
@export var following_dialogue: DialogueResource
@export var dungeon_dialogue: DialogueResource
@export_file var _home_level: String

@export var _preferred_combat: CombatType
@export var _adapatable_combat: CombatType
@export var _unadaptable_combat: CombatType
@export var goap_agent: GoapAgent
@export var _slash_priority: int = 14
@export var _shoot_priority: int = 14
@export var _block_priority: int = 14
@export var _aggro_priority: int = 14
@export var _desired_health: int = 3

@export var _follow_distance: float = 15.0
@export var _chase_distance: float = 15.0
@export var _max_chase_distance: float = 30.0
@export var _flee_distance: float = 50.0

@export_range(1.0, 20.0) var min_follow_speed: float = 10.0
@export_range(15.0, 100.0) var max_follow_speed: float = 70.0
@export_range(1.0, 20.0) var min_chase_speed: float = 30.0
@export_range(15.0, 100.0) var max_chase_speed: float = 75.0
@export var flee_speed: float = 60.0

@export_range(1.0, 6.0) var steering_value: float = 2.0
@export_range(0.5, 1.0) var turning_smoothing_value: float = 0.5
@export_range(0.0, 1.0) var speed_smoothing_value: float = 0.2

@export_range(0.0, 2.0) var stop_time: float = 0.5

# Info window vars
@export var info_window : Window

var _affection: int
var _arrows: Array[Arrow]

var follow_distance_squared: float = _follow_distance * _follow_distance
var follow_equilibrium_distance_squared: float = follow_distance_squared * 0.5
var min_follow_distance_squared: float = follow_equilibrium_distance_squared * 0.5 # Half of the follow distance
var chase_distance_squared: float = _chase_distance * _chase_distance
var max_chase_distance_squared: float = _max_chase_distance * _max_chase_distance
var flee_distance_squared: float = _flee_distance * _flee_distance
var direction: Vector2 = Vector2.ZERO
var saved_spawn_pos: Vector2

@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var danger_sensor_component: DangerSensorComponent = $DangerSensorComponent
@onready var actionable: Area2D = $Actionable
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var name_label: Label = $AnimatedSprite2D/NameLabel
@onready var state_machine: StateMachine = $StateMachine


func _ready() -> void:
	# Destroy instance if any other instance exists that is following the player
	var data = Blackboard.get_data("npc")
	if is_instance_valid(data):
		var npc: Npc = data
		if npc.display_name == display_name:
			npc.die()
	
	# Assert that all necessary dialogue has been assigned
	assert(is_instance_valid(idle_dialogue), "Please assign a valid idle_dialogue to " + display_name)
	assert(is_instance_valid(hit_dialogue), "Please assign a valid hit_dialogue to " + display_name)
	assert(is_instance_valid(following_dialogue), "Please assign a valid following_dialogue to " + display_name)
	assert(is_instance_valid(dungeon_dialogue), "Please assign a valid dungeon_dialogue to " + display_name)
	
	# Assert that all combat preferences are unique types
	assert(_preferred_combat != _adapatable_combat, display_name + "'s _preferred_combat and _adapatable_combat are the same")
	assert(_adapatable_combat != _unadaptable_combat, display_name + "'s _adapatable_combat and _unadaptable_combat are the same")
	assert(_unadaptable_combat != _preferred_combat, display_name + "'s _unadaptable_combat and _preferred_combat are the same")
	
	# Connect signals
	game_manager.switch_level_cleanup.connect(_reduce_arrows_to.bind(0))
	health_component.die.connect(downed)
	health_component.immunity.connect(update_immunity_animation)
	health_component.health_gained.connect(update_blackboard_health)
	
	# Set display name label
	name_label.text = display_name
	
	# Enable animations
	animation_tree = $CharacterAnimations/AnimationTree
	animation_player = $CharacterAnimations/AnimationPlayer
	animation_tree.active = true
	animation_player.active = true
	
	# Disable info window
	info_window.set_process_mode(ProcessMode.PROCESS_MODE_DISABLED)
	info_window.visible = false
	
	hurtbox_component.hurt.connect(func(_x, _y): hurt())
	immunity(true)


func immunity(immune: bool) -> void:
	if immune:
		hurtbox_component.immune = true
	else:
		hurtbox_component.immune = false


func downed() -> void:
	state_machine.transition_to_next_state(NpcState.state_type_to_int(NpcState.StateType.DOWNED))
	if Player.instance.health_component.health <= 0:
		game_manager.load_level(_home_level)


func die() -> void:
	queue_free()


func update_immunity_animation(immune: bool) -> void:
	set_immunity_animation_param(immune)


func hurt() -> void:
	Blackboard.increment_data("npc_damage_taken", 1)
	update_blackboard_health()


func update_blackboard_health() -> void:
	health_component.set_health_blackboard_variables("npc")


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
	Blackboard.add_data("npc", self)
	
	var data = Blackboard.get_data("npc_choices")
	var npc_choices: Array = data if data else []
	npc_choices.append(display_name)
	Blackboard.add_data("npc_choices", npc_choices)
	
	Blackboard.add_data("slash_priority", _slash_priority)
	Blackboard.add_data("block_priority", _block_priority)
	Blackboard.add_data("shoot_priority", _shoot_priority)
	Blackboard.add_data("adaptable_style", _adapatable_combat)
	Blackboard.add_data("aggro_priority", _aggro_priority)
	Blackboard.add_data("desired_health", _desired_health)
	
	health_component.set_health_blackboard_variables("npc")
	
	info_window.set_process_mode(ProcessMode.PROCESS_MODE_INHERIT)
	info_window.visible = true


func slash(direction: Vector2) -> bool:
	if animation_tree.get("parameters/conditions/slash"):
		return false
	
	return await super.slash(direction)


func block(direction: Vector2) -> bool:
	if animation_tree.get("parameters/conditions/block"):
		return false
	
	return await super.block(direction);


func shoot(direction: Vector2) -> bool:
	if animation_tree.get("parameters/conditions/shoot"):
		return false;

	# Create a new arrow
	var arrow_resource: Resource = ResourceLoader.load(_arrow_path, PackedScene.new().get_class(), ResourceLoader.CACHE_MODE_IGNORE)
	var arrow: Arrow = arrow_resource.instantiate()
	arrow.goal = global_position + direction
	arrow.direction = direction
	add_child(arrow)
	arrow.reparent(get_parent())
	_arrows.append(arrow)
	
	# There should only be MAX_ARROW_COUNT arrows at once
	_reduce_arrows_to(MAX_ARROW_COUNT)
	
	# Remove arrow from list when freeing
	arrow.tree_exiting.connect(func(): _arrows.erase(arrow))
	
	# Animate bow
	return await super.shoot(direction)


func _reduce_arrows_to(amount: int) -> void:
	while _arrows.size() > amount:
		if is_instance_valid(_arrows.front()):
			_arrows.pop_front().queue_free()
		else:
			_arrows.pop_front()
