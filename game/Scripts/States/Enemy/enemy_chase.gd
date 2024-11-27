class_name EnemyChase
extends EnemyState


const STATE_TYPE = StateType.CHASE

const directions: PackedVector2Array = [Vector2(1,0),Vector2(1,-1),Vector2(0,-1),Vector2(-1,-1),Vector2(-1,0),Vector2(-1,1),Vector2(0,1),Vector2(1,1)]


func get_state_type() -> int:
	return state_type_to_int(STATE_TYPE)


func enter(previous_state: int, data := {}) -> void:
	super.enter(previous_state, data)


func physics_update(delta: float) -> void:
	# Initialze a context map and get the direction to the player
	var context_map: PackedFloat32Array = [0,0,0,0,0,0,0,0]
	var player_direction: Vector2 = (Player.instance.global_position - enemy.global_position).normalized()
	
	# Get the best direction index using a loop, dot product and danger array
	var best_index: int = 0
	var best_interest: float = -INF
	for index in range(directions.size()):
		var interest: float = directions[index].dot(player_direction) - enemy.danger_sensor_component.danger_array[index]
		context_map[index] = interest
		
		if index != 0 && interest > best_interest:
			best_interest = interest
			best_index = index
	
	# Lerp the enemy's velocity towards the best direction
	var normalized_velocity: Vector2 = enemy.get_velocity().normalized()
	var smoothed_direction: Vector2 = normalized_velocity.lerp(directions[best_index], enemy.smoothing_value).normalized()
	
	# Calculate the steering force towards the smoothed best direction
	var steering_force: Vector2 = (smoothed_direction - normalized_velocity) * enemy.steering_value
	
	# Calculate the alignment between current velocity and the smoothed direction
	var alignment: float = normalized_velocity.dot(smoothed_direction)
	
	# Interpolate between MIN and MAX speed based on alignment
	var target_speed: float = lerp(enemy.min_chase_speed, enemy.max_chase_speed, (alignment + 1) * 0.5) 
	
	# Calculate the new velocity with dynamic speed adjustment
	var new_velocity = (enemy.get_velocity() + steering_force).normalized() * target_speed
	
	# Limit the new velocity to a minimum and maximum speed
	var new_velocity_length_squared = new_velocity.length_squared()
	if new_velocity_length_squared < enemy.min_chase_speed * enemy.min_chase_speed:
		new_velocity = new_velocity.normalized() * enemy.min_chase_speed
	elif new_velocity_length_squared > enemy.max_chase_speed * enemy.max_chase_speed:
		new_velocity = new_velocity.normalized() * enemy.max_chase_speed
	
	enemy.set_velocity(new_velocity)
	super.physics_update(delta)


func exit() -> void:
	super.exit()
