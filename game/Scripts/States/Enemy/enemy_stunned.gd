class_name EnemyStunned
extends EnemyState


const STATE_TYPE = StateType.STUNNED

var finish: Callable = finished.emit.bind(state_type_to_int(StateType.CHASE))


func get_state_type() -> int:
	return state_type_to_int(STATE_TYPE)


func enter(previous_state: int, data: Dictionary = {}) -> void:
	enemy.stun_timer.timeout.connect(finish, CONNECT_ONE_SHOT)
	super.enter(previous_state, data)


func physics_update(delta: float) -> void:
	if is_equal_approx(enemy.velocity.length_squared(), 0):
		return
	
	var slowdown = min(delta / enemy.stop_time, 1.0)
	enemy.set_velocity(enemy.velocity - enemy.velocity * slowdown)
	super.physics_update(delta)


func exit() -> void:
	enemy.stun_timer.stop()
	super.exit()
