class_name Player
extends AnimatedCharacter


const SPEED := 70.0
const MAX_ARROW_COUNT = 5

@export_file var _arrow_path: String

var _arrows: Array[Arrow]
var _saved_spawn_pos: Vector2
var _highest_priority_actionable: Actionable

var room: Room:
	set(value):
		if !is_instance_valid(value):
			Blackboard.remove_data("enemy")
			Blackboard.add_data("enemies_present", false)
		room = value

static var instance: Player = null

@onready var _actionable_finder: Area2D = $CharacterAnimations/Direction/ActionableFinder
@onready var _camera_2d: CameraControl = $Camera2D
@onready var _health_component: HealthComponent = $HealthComponent
@onready var _hurtbox_component: HurtboxComponent = $HurtboxComponent


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
	game_manager.switch_level_cleanup.connect(_health_component.reset_health.bind("player"))
	input_manager.interact.connect(interact)
	_health_component.die.connect(respawn)
	_health_component.immunity.connect(update_immunity_animation)
	_health_component.health_gained.connect(update_blackboard_health)
	_health_component.set_health_blackboard_variables("player")
	_hurtbox_component.hurt.connect(func(_x, _y): hurt())
	
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


func _process(delta: float) -> void:
	update_actionable_highlight()
	super._process(delta)


func update_animation_parameters() -> void:
	# Set blend position parameters and display correct animation direction
	animation_tree.set("parameters/conditions/idle", input_manager.direction == Vector2.ZERO)
	animation_tree.set("parameters/conditions/moving", input_manager.direction != Vector2.ZERO)
	
	var direction = (get_viewport().get_camera_2d().get_global_mouse_position() - global_position).normalized()
	
	if input_manager.direction.length() > 0:
		animation_tree.set("parameters/Hit/blend_position", input_manager.direction)
		animation_tree.set("parameters/Idle/blend_position", input_manager.direction)
		animation_tree.set("parameters/Walk/blend_position", input_manager.direction)
	
	# Make sure the player isn't already performing an action
	if animation_tree.get("parameters/conditions/slash") || animation_tree.get("parameters/conditions/block")|| animation_tree.get("parameters/conditions/shoot"):
		super.update_animation_parameters()
		return
	
	if input_manager.attack:
		Blackboard.increment_data("sword_used_amount", 1)
		await slash(direction)
		super.update_animation_parameters()
		return
	
	if input_manager.block:
		Blackboard.increment_data("shield_used_amount", 1)
		await block(direction)
		super.update_animation_parameters()
		return
	
	if input_manager.bow:
		Blackboard.increment_data("bow_used_amount", 1)
		await shoot(direction)
		super.update_animation_parameters()
		return


func update_actionable_highlight() -> void:
	var actionables: Array[Area2D] = _actionable_finder.get_overlapping_areas()
	
	if actionables.size() > 0:
		_highest_priority_actionable = actionables[0]
		for actionable: Actionable in actionables:
			if actionable.actionable_priority > _highest_priority_actionable.actionable_priority:
				_highest_priority_actionable = actionable
				continue
			
			actionable.stop_highlight()
		
		_highest_priority_actionable.highlight()
	elif is_instance_valid(_highest_priority_actionable):
		_highest_priority_actionable.stop_highlight()
		_highest_priority_actionable = null


func interact() -> void:
	_highest_priority_actionable.action.emit()


func update_blackboard_health() -> void:
	Blackboard.add_data("player_health", _health_component.health)


func update_immunity_animation(immune: bool) -> void:
	set_immunity_animation_param(immune)


func hurt() -> void:
	_camera_2d.apply_shake()
	Blackboard.increment_data("player_damage_taken", 1)
	update_blackboard_health()


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
	room = null
	spawn(_saved_spawn_pos, Vector2.ZERO)
	_health_component.gain_health(3)


func shoot(direction: Vector2) -> bool:
	# Create a new arrow
	var arrow_resource: Resource = ResourceLoader.load(_arrow_path, PackedScene.new().get_class(), ResourceLoader.CACHE_MODE_IGNORE)
	var arrow: Arrow = arrow_resource.instantiate()
	arrow.goal = get_viewport().get_camera_2d().get_global_mouse_position()
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
