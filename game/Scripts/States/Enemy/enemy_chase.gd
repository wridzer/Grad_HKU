class_name EnemyChase
extends EnemyState


const STATE_TYPE = StateType.CHASE
const MIN_CHASE_SPEED: float = 35.0
const MAX_CHASE_SPEED: float = 60.0
const CHASE_STOP_DISTANCE: float = 100.0
const STEERING_VALUE: float = 1.2
const SMOOTHING_VALUE: float = 0.01
var directions: PackedVector2Array = [Vector2(1,0),Vector2(1,-1),Vector2(0,-1),Vector2(-1,-1),Vector2(-1,0),Vector2(-1,1),Vector2(0,1),Vector2(1,1)]


func get_state_type() -> int:
	return state_type_to_int(STATE_TYPE)


func enter(previous_state: int, data := {}) -> void:
	enemy.set_velocity(Vector2.ZERO)
	super.enter(previous_state, data)


func update(_delta: float) -> void:
	if enemy.global_position.distance_to(Player.instance.global_position) > CHASE_STOP_DISTANCE:
		finished.emit(state_type_to_int(StateType.IDLE))


func physics_update(delta: float) -> void:
	# Initialze a context map and get the direction to the player
	var context_map: PackedFloat32Array = [0,0,0,0,0,0,0,0]
	var player_direction: Vector2 = (Player.instance.global_position - enemy.global_position).normalized()
	
	# Get the best direction index
	var best_index: int = 0
	for index in directions.size():
		context_map[index] = directions[index].dot(player_direction) - enemy.danger_sensor_component.danger_array[index]
		if index != 0 && context_map[index] > context_map[best_index]:
			best_index = index
	
	# Lerp the enemy's velocity towards the best direction
	var smoothed_direction: Vector2 = enemy.get_velocity().normalized().lerp(directions[best_index], SMOOTHING_VALUE).normalized()
	
	# Calculate the steering force
	var steering_force: Vector2 = (directions[best_index] - enemy.get_velocity().normalized()) * STEERING_VALUE
	
	# Limit the velocity to a minimum and maximum speed
	var new_velocity = enemy.get_velocity() + steering_force
	if new_velocity.length() < MIN_CHASE_SPEED:
		new_velocity = new_velocity.normalized() * MIN_CHASE_SPEED
	if new_velocity.length() > MAX_CHASE_SPEED:
		new_velocity = new_velocity.normalized() * MAX_CHASE_SPEED
	
	enemy.set_velocity(new_velocity)
	super.physics_update(delta)


func exit() -> void:
	super.exit()
