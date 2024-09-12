extends CharacterBody2D

const SPEED : float = 4000.0

var last_dir : Vector2


func _physics_process(delta: float) -> void:
	var directionx := clampf(last_dir.x + randf_range(-0.01,0.01),-1.0, 1.0)
	var directiony := clampf(last_dir.y + randf_range(-0.01,0.01),-1.0, 1.0)
	
	var direction = Vector2(directionx, directiony)
	
	velocity = direction * SPEED * delta if direction != Vector2.ZERO else velocity.move_toward(Vector2.ZERO, SPEED)
	
	last_dir = direction
	move_and_slide()
