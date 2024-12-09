class_name FleeFromEnemyAction
extends GoapAction


func _is_valid() -> bool:
	return is_instance_valid(Blackboard.get_data("enemy"))


func _get_cost() -> int:
	var squared_distance = Blackboard.get_data("npc_location").distance_squared_to(Blackboard.get_data("enemy").global_position)
	var squared_max_chase_distance = Blackboard.get_data("squared_max_chase_distance")
	var normalized_distance = max(squared_max_chase_distance - squared_distance, 0) / squared_max_chase_distance
	
	var health = Blackboard.get_data("npc_health")
	var max_health = Blackboard.get_data("npc_max_health")
	
	return int((max_health - (max_health - health) - normalized_distance) * 10)


func _get_action_name() -> StringName:
	return "flee_from_enemy_action"


func _get_preconditions() -> Dictionary:
	return {"close_to_enemy" : true}


func _get_effects() -> Dictionary:
	return {"close_to_enemy" : false}


func _perform(actor, delta) -> bool:
	var npc = actor as Npc
	
	var npc_pos: Vector2 = npc.get_global_position()
	var enemy: Enemy = Blackboard.get_data("enemy")
	var enemy_pos: Vector2 = enemy.get_global_position()
	var squared_distance: float = npc_pos.distance_squared_to(enemy_pos)

	if squared_distance > npc.squared_flee_distance:
		return true
	else:
		var target_direction: Vector2 = (npc_pos - enemy_pos).normalized()
		npc.direction = target_direction
		npc.set_velocity(target_direction * npc.flee_speed)
		npc.look_at(target_direction)
		npc.move_and_slide()

	return false
