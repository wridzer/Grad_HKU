class_name MoveToPlayerAction
extends GoapAction


func _is_valid() -> bool:
	return true


func _get_cost() -> int:
	var npc: Npc = Blackboard.get_data("npc")
	var distance_squared: float = npc.global_position.distance_squared_to(Player.instance.get_global_position())
	return max(int(npc.follow_distance_squared - distance_squared), 0)


func _get_action_name() -> StringName:
	return "move_to_player_action"


func _get_preconditions() -> Dictionary:
	return {}


func _get_effects() -> Dictionary:
	return {"close_to_player" : true}


func _perform_physics(actor, _delta) -> bool:
	var npc = actor as Npc
	var npc_pos: Vector2 = npc.get_global_position()
	var player_pos: Vector2 = Player.instance.get_global_position()
	var distance_squared = npc_pos.distance_squared_to(player_pos)
	
	# Let the goal know via blackboard that the npc
	# has moved over the equilibrium and can idle
	var condition: bool = distance_squared < npc.follow_equilibrium_distance_squared
	Blackboard.add_data("stay_close_to_player_goal_complete", condition)
	if condition:
		return true
	else:
		# Initialze a context map and get the direction to the player
		var context_map: PackedFloat32Array = [0,0,0,0,0,0,0,0]
		var target_direction: Vector2 = (player_pos - npc_pos).normalized()
		npc.direction = target_direction
		npc.animation_direction.look_at(player_pos)
		
		# Get the best direction index using a loop, dot product and danger array
		var best_index: int = 0
		var best_interest: float = -INF
		for index in range(DangerSensorComponent.directions.size()):
			var interest: float = DangerSensorComponent.directions[index].dot(target_direction) - npc.danger_sensor_component.danger_array[index]
			context_map[index] = interest
			
			if index != 0 && interest > best_interest:
				best_interest = interest
				best_index = index
		
		# Lerp the enemy's velocity towards the best direction
		var normalized_velocity: Vector2 = npc.get_velocity().normalized()
		var smoothed_direction: Vector2 = normalized_velocity.lerp(DangerSensorComponent.directions[best_index], npc.turning_smoothing_value).normalized()
		
		# Calculate the steering force towards the smoothed best direction
		var steering_force: Vector2 = (smoothed_direction - normalized_velocity) * npc.steering_value
		
		# Interpolate between MIN and MAX speed based on alignment to best direction
		var alignment: float = normalized_velocity.dot(DangerSensorComponent.directions[best_index])
		var target_speed: float = lerp(npc.min_follow_speed, npc.max_follow_speed, (alignment + 1) * 0.5) 
		
		# Smoothly interpolate the current speed to the target speed
		var smoothed_speed: float = lerp(npc.get_velocity().length(), target_speed, npc.speed_smoothing_value)
		
		# Calculate the new velocity
		var new_velocity: Vector2 = (npc.get_velocity() + steering_force).normalized() * smoothed_speed
		
		# Limit the new velocity to a minimum and maximum speed
		var new_velocity_length_squared: float = new_velocity.length_squared()
		if new_velocity_length_squared < npc.min_follow_speed * npc.min_follow_speed:
			new_velocity = new_velocity.normalized() * npc.min_follow_speed
		elif new_velocity_length_squared > npc.max_follow_speed * npc.max_follow_speed:
			new_velocity = new_velocity.normalized() * npc.max_follow_speed
		
		# Apply the new velocity
		npc.set_velocity(new_velocity)
		npc.move_and_slide()
	
	return false
