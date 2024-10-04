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


func update(_delta: float) -> void:
	if enemy.global_position.distance_to(Player.instance.global_position) < 50:
		finished.emit(state_type_to_int(StateType.CHASE))


func physics_update(delta: float) -> void:
	var directionx := clampf(last_dir.x + randf_range(-0.01, 0.01), -1.0, 1.0)
	var directiony := clampf(last_dir.y + randf_range(-0.01, 0.01), -1.0, 1.0)
	
	var direction = Vector2(directionx, directiony)
	enemy.set_velocity(direction * IDLE_SPEED * delta)
	
	last_dir = direction
	super.physics_update(delta)


func exit() -> void:
	super.exit()
