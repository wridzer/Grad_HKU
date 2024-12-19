class_name EnemyStunned
extends EnemyState


const STATE_TYPE = StateType.STUNNED
var stun_timer: Timer

var finish: Callable = finished.emit.bind(state_type_to_int(StateType.CHASE))

func get_state_type() -> int:
	return state_type_to_int(STATE_TYPE)


func enter(previous_state: int, data: Dictionary = {}) -> void:
	stun_timer = Timer.new()
	add_child(stun_timer)
	stun_timer.start(data.get("stun_length", 0.1))
	stun_timer.timeout.connect(finish)
	super.enter(previous_state, data)


func physics_update(delta: float) -> void:
	var slowdown = min(delta / enemy.stop_time, 1.0)
	enemy.set_velocity(enemy.velocity - enemy.velocity * slowdown)
	super.physics_update(delta)


func exit() -> void:
	stun_timer.timeout.disconnect(finish)
	stun_timer.queue_free()
	super.exit()
