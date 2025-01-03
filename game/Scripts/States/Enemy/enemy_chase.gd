class_name EnemyChase
extends EnemyState


const STATE_TYPE = StateType.CHASE


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
	for index in range(DangerSensorComponent.directions.size()):
		var interest: float = DangerSensorComponent.directions[index].dot(player_direction) - enemy.danger_sensor_component.danger_array[index]
		context_map[index] = interest
		
		if index != 0 && interest > best_interest:
			best_interest = interest
			best_index = index
	
	# Lerp the enemy's velocity towards the best direction
	var normalized_velocity: Vector2 = enemy.get_velocity().normalized()
	var smoothed_direction: Vector2 = normalized_velocity.lerp(DangerSensorComponent.directions[best_index], enemy.turning_smoothing_value).normalized()
	
	# Calculate the steering force towards the smoothed best direction
	var steering_force: Vector2 = (smoothed_direction - normalized_velocity) * enemy.steering_value
	
	# Interpolate between MIN and MAX speed based on alignment to best direction
	var alignment: float = normalized_velocity.dot(DangerSensorComponent.directions[best_index])
	var target_speed: float = lerp(enemy.min_chase_speed, enemy.max_chase_speed, (alignment + 1) * 0.5) 
	
	# Smoothly interpolate the current speed to the target speed
	var smoothed_speed: float = lerp(enemy.get_velocity().length(), target_speed, enemy.speed_smoothing_value)
	
	# Calculate the new velocity
	var new_velocity: Vector2 = (enemy.get_velocity() + steering_force).normalized() * smoothed_speed
	
	# Limit the new velocity to a minimum and maximum speed
	var new_velocity_length_squared: float = new_velocity.length_squared()
	if new_velocity_length_squared < enemy.min_chase_speed * enemy.min_chase_speed:
		new_velocity = new_velocity.normalized() * enemy.min_chase_speed
	elif new_velocity_length_squared > enemy.max_chase_speed * enemy.max_chase_speed:
		new_velocity = new_velocity.normalized() * enemy.max_chase_speed
	
	# Apply the new velocity
	enemy.set_velocity(new_velocity)
	super.physics_update(delta)
