class_name MovePerpendicularToEnemyAction
extends GoapAction


func _is_valid() -> bool:
	return true


func _get_cost() -> int:
	#var npc: Npc = Blackboard.get_data("npc")
	#var enemy: Enemy = Blackboard.get_data("enemy")
	#var distance_squared = npc.global_position.distance_squared_to(enemy.global_position)
	#return int(distance_squared / 45)
	return 5


func _get_action_name() -> StringName:
	return "move_perpendicular_to_enemy_action"


func _get_preconditions() -> Dictionary:
	return {"found_enemy" : true}


func _get_effects() -> Dictionary:
	return {"has_line_of_sight" : true}


func _perform_physics(actor, _delta) -> bool:
	# Get needed data
	var npc = actor as Npc
	var data = Blackboard.get_data("enemy")
	if !is_instance_valid(data):
		return false
	var enemy: Enemy = data
	var npc_pos: Vector2 = npc.get_global_position()
	var enemy_pos: Vector2 = enemy.get_global_position()
	
	# Check if close enough to see
	var distance: float = npc_pos.distance_to(enemy_pos)
	if distance <= npc._max_chase_distance:
		# Raycast to check if theres a line of sight
		var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(npc_pos, enemy_pos)
		query.collision_mask = LayerNames.PHYSICS_2D.ENVIRONMENT
		query.exclude = [npc, enemy]
		var result: Dictionary = npc.get_world_2d().direct_space_state.intersect_ray(query)
		if result == {}:
			return true
		
	elif distance > npc._max_chase_distance:
		# Move closer
		var target_direction: Vector2 = (enemy_pos - npc_pos).normalized()
		npc.direction = target_direction
		npc.set_velocity(target_direction * npc.max_follow_speed)
		
	else:
		# Move to side
		var target_direction: Vector2 = (enemy_pos - npc_pos).normalized().rotated(deg_to_rad(90))
		npc.direction = target_direction
		npc.set_velocity(target_direction * npc.max_follow_speed)
	
	# Move
	npc.animation_direction.look_at(enemy_pos)
	npc.move_and_slide()
	
	return false
