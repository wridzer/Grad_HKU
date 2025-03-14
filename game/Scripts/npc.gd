class_name Npc
extends AnimatedCharacter


enum Playstyle {AGGRESSIVE, DEFENSIVE, EVASIVE}

const MAX_ARROW_COUNT = 5

@export_file var _arrow_path: String

@export var display_name: String
@export var idle_dialogue: DialogueResource
@export var hit_dialogue: DialogueResource
@export var following_dialogue: DialogueResource
@export var dungeon_dialogue: DialogueResource
@export_file var _home_level: String

@export var preferred_playstyle: Playstyle
@export var adapatable_playstyle: Playstyle
@export var goap_agent: GoapAgent
@export var base_slash_priority: int = 14
@export var base_shoot_priority: int = 14
@export var base_block_priority: int = 14
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

var level: float = 1.00
var _arrows: Array[Arrow]
var is_hidden : bool = false

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
@onready var actionable: Actionable = $Actionable
@onready var name_label: Label = $NameLabel
@onready var state_machine: StateMachine = $StateMachine


func _ready() -> void:
	# Destroy instance if any other instance exists
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
	
	# Assert that all playstyles are unique types
	assert(preferred_playstyle != adapatable_playstyle, display_name + "'s preferred_playstyle and adapatable_playstyle are the same")
	
	# Connect signals
	game_manager.switch_level_cleanup.connect(_reduce_arrows_to.bind(0))
	health_component.die.connect(downed)
	health_component.immunity.connect(update_immunity_animation)
	health_component.health_gained.connect(update_blackboard_health)
	hurtbox_component.hurt.connect(func(_x, _y): hurt())
	
	# Set display name label
	name_label.text = display_name
	
	# Enable animations
	animation_tree = $CharacterAnimations/AnimationTree
	animation_player = $CharacterAnimations/AnimationPlayer
	animation_tree.active = true
	animation_player.active = true
	
	# Enable immunity at start
	immunity(true)
	
	super._ready()


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
	animation_tree.set("parameters/conditions/idle", direction == Vector2.ZERO)
	animation_tree.set("parameters/conditions/moving", direction != Vector2.ZERO)
	
	if direction.length() > 0:
		animation_tree.set("parameters/Hit/blend_position", direction)
		animation_tree.set("parameters/Idle/blend_position", direction)
		animation_tree.set("parameters/Walk/blend_position", direction)
	
	super.update_animation_parameters()


func choose() -> void:
	Blackboard.add_data("npc", self)
	
	var npc_choices = Blackboard.get_data("npc_choices")
	if !npc_choices:
		npc_choices = []
	npc_choices = npc_choices as Array
	npc_choices.append(display_name)
	Blackboard.add_data("npc_choices", npc_choices)
	
	level = Blackboard.get_data(display_name + "_level") if Blackboard.get_data(display_name + "_level") else level
	
	Blackboard.add_data("slash_priority", base_slash_priority)
	Blackboard.add_data("block_priority", base_block_priority)
	Blackboard.add_data("shoot_priority", base_shoot_priority)
	Blackboard.add_data("aggro_priority", _aggro_priority)
	Blackboard.add_data("desired_health", _desired_health)
	health_component.set_health_blackboard_variables("npc")
	
	if goap_agent.enable_debug_window:
		goap_agent.toggle_debug_window(true)


func slash() -> bool:
	if animation_tree.get("parameters/conditions/slash"):
		return false
	
	return await attack_animation("slash", floori(level))


func block() -> bool:
	if animation_tree.get("parameters/conditions/block"):
		return false
	
	return await attack_animation("block", floori(level))


func shoot(anim_direction: Vector2) -> bool:
	if animation_tree.get("parameters/conditions/shoot"):
		return false;

	# Create a new arrow
	var arrow_resource: Resource = ResourceLoader.load(_arrow_path, PackedScene.new().get_class(), ResourceLoader.CACHE_MODE_IGNORE)
	var arrow: Arrow = arrow_resource.instantiate()
	arrow.goal = global_position + anim_direction
	arrow.direction = anim_direction
	add_child(arrow)
	arrow.reparent(get_parent())
	_arrows.append(arrow)
	
	# There should only be MAX_ARROW_COUNT arrows at once
	_reduce_arrows_to(MAX_ARROW_COUNT)
	
	# Remove arrow from list when freeing
	arrow.tree_exiting.connect(func(): _arrows.erase(arrow))
	
	# Animate bow
	return await attack_animation("shoot", floori(level))


func _reduce_arrows_to(amount: int) -> void:
	while _arrows.size() > amount:
		if is_instance_valid(_arrows.front()):
			_arrows.pop_front().queue_free()
		else:
			_arrows.pop_front()


func toggle_hide(enabled: bool) -> void:
	animation_direction.visible = !enabled
	is_hidden = enabled
	hurtbox_component.immune = enabled
	super.toggle_hide(enabled)
