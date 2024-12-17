class_name Player
extends AnimatedCharacter


const SPEED := 70.0
const MAX_ARROW_COUNT = 5

@export_file var _arrow_path: String

var _arrows: Array[Arrow]
var _saved_spawn_pos: Vector2

var room: Room

static var instance: Player = null

@onready var _actionable_finder: Area2D = $CharacterAnimations/Direction/ActionableFinder
@onready var _camera_2d: Camera2D = $Camera2D
@onready var _health_component: HealthComponent = $HealthComponent


func _ready() -> void:	
	# Singleton
	if instance == null:
		instance = self
	if instance != self:
		push_warning("Multiple players found in scene, deleting last loaded")
		queue_free()
	
	# Connect signals
	game_manager.spawn.connect(spawn)
	game_manager.switch_level_cleanup.connect(_reduce_arrows_to.bind(0))
	input_manager.interact.connect(interact)
	_health_component.die.connect(respawn)
	_health_component.immune.connect(set_immunity_animation_param)
	_health_component._owner = "player"
	
	# Enable animations
	animation_tree = $CharacterAnimations/AnimationTree
	animation_player = $CharacterAnimations/AnimationPlayer
	animation_tree.active = true
	animation_player.active = true


func _physics_process(_delta: float) -> void:
	if input_manager.direction != Vector2.ZERO:
		velocity = input_manager.direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	
	move_and_slide()
	Blackboard.add_data("player_location", self.position)


func spawn(spawn_pos: Vector2, _npc_offset: Vector2) -> void:
	var reenable_smoothing := _camera_2d.is_position_smoothing_enabled()
	_camera_2d.set_position_smoothing_enabled(false)
	
	# Reset animation parameters
	super.reset_animation_parameters()
	
	_saved_spawn_pos = spawn_pos
	self.position = spawn_pos
	
	await get_tree().process_frame
	_camera_2d.set_position_smoothing_enabled(reenable_smoothing)


func respawn() -> void:
	spawn(_saved_spawn_pos, Vector2.ZERO)
	_health_component.gain_health(3)


func interact() -> void:
	var actionables := _actionable_finder.get_overlapping_areas()
	if actionables.size() > 0:
		actionables[0].action.emit()
		return


func update_animation_parameters() -> void:
	# Set blend position parameters and display correct animation direction
	animation_tree.set("parameters/conditions/idle", input_manager.direction == Vector2.ZERO)
	animation_tree.set("parameters/conditions/moving", input_manager.direction != Vector2.ZERO)
	
	if input_manager.direction.length() > 0:
		animation_tree.set("parameters/Hit/blend_position", input_manager.direction)
		animation_tree.set("parameters/Idle/blend_position", input_manager.direction)
		animation_tree.set("parameters/Walk/blend_position", input_manager.direction)
	
	if input_manager.attack && !animation_tree.get("parameters/conditions/slash"):
		slash()
		Blackboard.increment_data("sword_used_amount", 1)
	
	if input_manager.block && !animation_tree.get("parameters/conditions/block"):
		block()
		Blackboard.increment_data("shield_used_amount", 1)
	
	if input_manager.bow && !animation_tree.get("parameters/conditions/shoot"):
		var direction = (get_viewport().get_camera_2d().get_global_mouse_position() - global_position).normalized()
		shoot(direction)
	
	super.update_animation_parameters()


func shoot(direction: Vector2) -> void:
	# Create a new arrow
	var arrow_resource: Resource = ResourceLoader.load(_arrow_path, PackedScene.new().get_class(), ResourceLoader.CACHE_MODE_IGNORE)
	var arrow: Arrow = arrow_resource.instantiate()
	arrow.mouse_position = get_viewport().get_camera_2d().get_global_mouse_position()
	arrow.direction = direction
	add_child(arrow)
	arrow.reparent(get_parent())
	_arrows.append(arrow)
	
	# There should only be MAX_ARROW_COUNT arrows at once
	_reduce_arrows_to(MAX_ARROW_COUNT)
	
	# Remove arrow from list when freeing
	arrow.tree_exiting.connect(func(): _arrows.erase(arrow))
	
	# Animate bow
	super.shoot(direction)
	
	Blackboard.increment_data("bow_used_amount", 1)


func _reduce_arrows_to(amount: int) -> void:
	while _arrows.size() > amount:
		if is_instance_valid(_arrows.front()):
			_arrows.pop_front().queue_free()
		else:
			_arrows.pop_front()
