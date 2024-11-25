class_name EnemyIdle
extends EnemyState


const STATE_TYPE = StateType.IDLE
var stop_time: float = 0.5


func get_state_type() -> int:
	return state_type_to_int(STATE_TYPE)


func enter(previous_state: int, data := {}) -> void:
	super.enter(previous_state, data)


func physics_update(delta: float) -> void:
	var slowdown = min(delta / stop_time, 1.0)
	enemy.set_velocity(enemy.velocity - enemy.velocity * slowdown)
	super.physics_update(delta)


func exit() -> void:
	super.exit()
