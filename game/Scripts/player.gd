class_name Player
extends AnimatedCharacter


@onready var camera_2d: Camera2D = $Camera2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var actionable_finder: Area2D = $Direction/ActionableFinder


const SPEED := 70.0
static var instance: Player = null
var following_npc: Npc = null
var saved_spawn_pos: Vector2


func _ready() -> void:	
	# Singleton
	if instance == null:
		instance = self
	if instance != self:
		push_warning("Multiple players found in scene, deleting last loaded")
		queue_free()
	
	animation_tree = $AnimationTree
	animation_player = $AnimationPlayer
	
	# Connect signals
	game_manager.spawn.connect(spawn)
	input_manager.interact.connect(interact)
	health_component.die.connect(respawn)
	health_component.immune.connect(set_immunity_animation_param)
	
	# Enable animations
	animation_tree.active = true


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
