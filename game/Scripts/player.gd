class_name Player
extends CharacterBody2D

const SPEED := 4000.0

@onready var camera_2d: Camera2D = $Camera2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var saved_spawn_pos: Vector2


func _ready() -> void:
	game_manager.spawn_player.connect(spawn)
	health_component.die.connect(respawn)
	health_component.hit.connect(hit)
	animated_sprite_2d.play("idle")


func _physics_process(delta: float) -> void:
	if input_manager.direction != Vector2.ZERO:
		velocity = input_manager.direction * SPEED * delta
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)

	move_and_slide()


func spawn(spawn_pos : Vector2) -> void:
	var reenable_smoothing := camera_2d.is_position_smoothing_enabled()
	camera_2d.set_position_smoothing_enabled(false)
	
	saved_spawn_pos = spawn_pos
	self.position = spawn_pos
	
	await get_tree().process_frame
	camera_2d.set_position_smoothing_enabled(reenable_smoothing)


func respawn() -> void:
	spawn(saved_spawn_pos)
	health_component.gain_health(3)


func hit() -> void:
	pass
