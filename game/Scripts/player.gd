class_name Player
extends AnimatedCharacter


@onready var camera_2d: Camera2D = $Camera2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var actionable_finder: Area2D = $CharacterAnimations/Direction/ActionableFinder

@export_file var arrow_path: String

const SPEED := 70.0
const MAX_ARROW_COUNT = 5
static var instance: Player = null
var following_npc: Npc = null
var saved_spawn_pos: Vector2
var arrows: Array[Arrow]


func _ready() -> void:	
	# Singleton
	if instance == null:
		instance = self
	if instance != self:
		push_warning("Multiple players found in scene, deleting last loaded")
		queue_free()
	
	# Connect signals
	game_manager.spawn.connect(spawn)
	game_manager.switch_level_cleanup.connect(switch_level_cleanup)
	input_manager.interact.connect(interact)
	health_component.die.connect(respawn)
	health_component.immune.connect(set_immunity_animation_param)
	
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


func spawn(spawn_pos: Vector2, _npc_offset: Vector2) -> void:
	var reenable_smoothing := camera_2d.is_position_smoothing_enabled()
	camera_2d.set_position_smoothing_enabled(false)
	
	saved_spawn_pos = spawn_pos
	self.position = spawn_pos
	
	await get_tree().process_frame
	camera_2d.set_position_smoothing_enabled(reenable_smoothing)


func respawn() -> void:
	spawn(saved_spawn_pos, Vector2.ZERO)
	health_component.gain_health(3)


func interact() -> void:
	var actionables := actionable_finder.get_overlapping_areas()
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
	
	if input_manager.block && !animation_tree.get("parameters/conditions/block"):
		block()
	
	if input_manager.bow && !animation_tree.get("parameters/conditions/shoot"):
		var direction = (get_viewport().get_camera_2d().get_global_mouse_position() - global_position).normalized()
		shoot(direction)
	
	super.update_animation_parameters()


func shoot(direction: Vector2) -> void:
	if arrows.size() >= MAX_ARROW_COUNT:
		if is_instance_valid(arrows.front()):
			arrows.pop_front().queue_free()
		else:
			arrows.pop_front()
	
	var arrow_resource: Resource = ResourceLoader.load(arrow_path, PackedScene.new().get_class(), ResourceLoader.CACHE_MODE_IGNORE)
	var arrow: Arrow = arrow_resource.instantiate()
	arrow.mouse_position = get_viewport().get_camera_2d().get_global_mouse_position()
	arrow.direction = direction
	add_child(arrow)
	arrow.reparent(get_parent())
	arrows.append(arrow)
	
	# Animate bow
	super.shoot(direction)


func switch_level_cleanup() -> void:
	for _i in range(arrows.size()):
		arrows.pop_front().queue_free()
