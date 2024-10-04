class_name EnemyIdle
extends EnemyState


const STATE_TYPE = StateType.IDLE
const IDLE_SPEED: float = 4000.0
var last_dir: Vector2 = Vector2.ZERO


func get_state_type() -> int:
	return state_type_to_int(STATE_TYPE)


func enter(previous_state: int, data := {}) -> void:
	if data.find_key("last_dir"):
		last_dir = data[last_dir]
	super.enter(previous_state, data)


func physics_update(delta: float) -> void:
	var directionx := clampf(last_dir.x + randf_range(-0.01, 0.01), -1.0, 1.0)
	var directiony := clampf(last_dir.y + randf_range(-0.01, 0.01), -1.0, 1.0)
	
	var direction = Vector2(directionx, directiony)
	
	if direction != Vector2.ZERO:
		enemy.velocity = direction * IDLE_SPEED * delta
	else:
		enemy.velocity.move_toward(Vector2.ZERO, IDLE_SPEED)
	
	last_dir = direction
	super.physics_update(delta)


func exit() -> void:
	super.exit()
