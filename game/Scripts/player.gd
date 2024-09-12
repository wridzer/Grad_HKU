class_name Player
extends CharacterBody2D

const SPEED := 4000.0

@onready var camera_2d: Camera2D = $Camera2D
@onready var health_component: HealthComponent = $HealthComponent
var spawn_pos: Vector2


func _ready() -> void:
	game_manager.connect("spawn_player", spawn.bind())
	health_component.connect("die", die.bind())


func _physics_process(delta: float) -> void:
	var directionx := Input.get_axis("move_left", "move_right")
	var directiony := Input.get_axis("move_up", "move_down")
	var direction = Vector2(directionx, directiony)
	
	velocity = direction * SPEED * delta if direction != Vector2.ZERO else velocity.move_toward(Vector2.ZERO, SPEED)
	
	move_and_slide()


func spawn(spawn_pos : Vector2):
	var reenable_smoothing := camera_2d.is_position_smoothing_enabled()
	camera_2d.set_position_smoothing_enabled(false)
	
	self.spawn_pos = spawn_pos
	self.position = spawn_pos
	
	await get_tree().process_frame
	camera_2d.set_position_smoothing_enabled(reenable_smoothing)


func die():
	spawn(spawn_pos)
	health_component.gain_health(3)
