class_name Player
extends CharacterBody2D

@onready var camera_2d: Camera2D = $Camera2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var actionable_finder: Area2D = $Direction/ActionableFinder
@onready var animation_player: AnimationPlayer = $AnimationPlayer

const SPEED := 4000.0
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
	
	# Connect signals
	game_manager.spawn.connect(spawn)
	input_manager.interact.connect(interact)
	health_component.die.connect(respawn)
	health_component.hit.connect(hit)
	
	# Enable animations
	animation_tree.active = true


func _process(_delta: float) -> void:
	update_animation_parameters()


func _physics_process(delta: float) -> void:
	if input_manager.direction != Vector2.ZERO:
		velocity = input_manager.direction * SPEED * delta
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	
	move_and_slide()


func update_animation_parameters() -> void:
	# Set blend position parameters and display correct animation direction
	animation_tree.set("parameters/conditions/hit", health_component.immune)
	animation_tree.set("parameters/conditions/idle", input_manager.direction == Vector2.ZERO)
	animation_tree.set("parameters/conditions/moving", input_manager.direction != Vector2.ZERO)
	
	if input_manager.direction.length() > 0:
		animation_tree.set("parameters/Hit/blend_position", input_manager.direction)
		animation_tree.set("parameters/Idle/blend_position", input_manager.direction)
		animation_tree.set("parameters/Walk/blend_position", input_manager.direction)
	
	if input_manager.attack && !animation_tree.get("parameters/conditions/slash"):
		# Easiest way to get the right direction at this point
		animation_tree.set("parameters/Slash/blend_position", animation_tree.get("parameters/Idle/blend_position"))
		slash()


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


func hit() -> void:
	pass


func interact() -> void:
	var actionables := actionable_finder.get_overlapping_areas()
	if actionables.size() > 0:
		actionables[0].action.emit()
		return


func slash() -> void:
	animation_tree.set("parameters/conditions/slash", true)
	
	# Can't find a way to get the length from the Animation Tree Blend Space 2D
	await get_tree().create_timer(animation_player.get_animation("slash_right").length).timeout
	
	animation_tree.set("parameters/conditions/slash", false)
