class_name EnemyChase
extends EnemyState


const STATE_TYPE = StateType.CHASE
const CHASE_SPEED: float = 4000.0


func get_state_type() -> int:
	return state_type_to_int(STATE_TYPE)


func enter(previous_state: int, data := {}) -> void:
	enemy.set_velocity(Vector2.ZERO)
	super.enter(previous_state, data)


func physics_update(_delta: float) -> void:
	super.physics_update(_delta)


func exit() -> void:
	super.exit()
