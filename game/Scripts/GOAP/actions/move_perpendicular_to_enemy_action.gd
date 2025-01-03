class_name MovePerpendicularToEnemyAction
extends GoapAction


func _is_valid() -> bool:
	if Blackboard.get_data("enemies_present"):
		var data = Blackboard.get_data("enemy")
		return is_instance_valid(data)
	
	return false


func _get_cost() -> int:
	var npc: Npc = Blackboard.get_data("npc")
	var enemy: Enemy = Blackboard.get_data("enemy")
	var distance_squared = npc.global_position.distance_squared_to(enemy.global_position)
	if distance_squared > npc.max_chase_distance_squared:
		return int(distance_squared)
	return int(distance_squared / 50)


func _get_action_name() -> StringName:
	return "move_perpendicular_to_enemy_action"


func _get_preconditions() -> Dictionary:
	return {}


func _get_effects() -> Dictionary:
	return {"has_line_of_sight" : true}


func _perform_physics(actor, _delta) -> bool:
	var npc = actor as Npc
	
	var npc_pos: Vector2 = npc.get_global_position()
	var data = Blackboard.get_data("enemy")
	if !is_instance_valid(data):
		return true
	var enemy: Enemy = data
	var enemy_pos: Vector2 = enemy.get_global_position()
	var distance_squared: float = npc_pos.distance_squared_to(enemy_pos)
	var target_direction: Vector2 
	if distance_squared > npc.max_chase_distance_squared:
		target_direction = (enemy_pos - npc_pos).normalized()
		npc.direction = target_direction
		npc.set_velocity(target_direction * npc.max_follow_speed)
		npc.animated_sprite_2d.look_at(enemy_pos)
		npc.move_and_slide()
		return false
	
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(npc_pos, enemy_pos)
	query.collision_mask = LayerNames.PHYSICS_2D.ENVIRONMENT
	query.exclude = [npc, enemy]
	var result: Dictionary = npc.get_world_2d().direct_space_state.intersect_ray(query)
	if !result:
		return true
	
	target_direction = (enemy_pos - npc_pos).normalized().rotated(deg_to_rad(90))
	npc.direction = target_direction
	npc.set_velocity(target_direction * npc.max_follow_speed)
	npc.animated_sprite_2d.look_at(enemy_pos)
	npc.move_and_slide()
	
	return false
