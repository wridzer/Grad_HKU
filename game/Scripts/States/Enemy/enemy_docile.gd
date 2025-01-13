class_name EnemyDocile
extends EnemyState


const STATE_TYPE = StateType.DOCILE

var finish: Callable = finished.emit.bind(state_type_to_int(StateType.CHASE))


func get_state_type() -> int:
	return state_type_to_int(STATE_TYPE)


func enter(previous_state: int, data := {}) -> void:
	enemy.hurtbox_component.hurt.connect(func(x, y): finish.call())
	super.enter(previous_state, data)


func update(delta) -> void:
	var npc: Npc = Blackboard.get_data("npc")
	var npc_distance_squared: float = npc.global_position.distance_squared_to(enemy.global_position)
	var player_distance_squared: float = Player.instance.global_position.distance_squared_to(enemy.global_position)
	if npc_distance_squared < enemy.aggro_range_squared || player_distance_squared < enemy.aggro_range_squared:
		finish.call()
	super.update(delta)


func physics_update(delta: float) -> void:
	if is_equal_approx(enemy.velocity.length_squared(), 0):
		return
	
	var slowdown = min(delta / enemy.stop_time, 1.0)
	enemy.set_velocity(enemy.velocity - enemy.velocity * slowdown)
	super.physics_update(delta)


func exit() -> void:
	enemy.hurtbox_component.hurt.disconnect(func(x, y): finish.call())
	super.exit()
