extends CharacterBody2D

@onready var health_component: HealthComponent = $HealthComponent

const SPEED: float = 4000.0
var last_dir: Vector2


func _ready() -> void:
	health_component.die.connect(die)
	health_component.hit.connect(hit)


func _physics_process(delta: float) -> void:
	var directionx := clampf(last_dir.x + randf_range(-0.01, 0.01), -1.0, 1.0)
	var directiony := clampf(last_dir.y + randf_range(-0.01, 0.01), -1.0, 1.0)
	
	var direction = Vector2(directionx, directiony)
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED * delta
	else:
		velocity.move_toward(Vector2.ZERO, SPEED)
	
	last_dir = direction
	move_and_slide()


func die() -> void:
	queue_free()


func hit() -> void:
	pass
