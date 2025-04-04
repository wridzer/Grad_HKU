class_name EnemyIdle
extends EnemyState


const STATE_TYPE = StateType.IDLE


func get_state_type() -> int:
	return state_type_to_int(STATE_TYPE)


func enter(previous_state: int, data := {}) -> void:
	enemy.immunity(true)
	super.enter(previous_state, data)


func physics_update(delta: float) -> void:
	if is_equal_approx(enemy.velocity.length_squared(), 0):
		return
	
	var slowdown = min(delta / enemy.stop_time, 1.0)
	enemy.set_velocity(enemy.velocity - enemy.velocity * slowdown)
	super.physics_update(delta)


func exit() -> void:
	enemy.immunity(false)
	super.exit()
