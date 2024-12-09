class_name MoveToEnemyAction
extends GoapAction


func _is_valid() -> bool:
	return is_instance_valid(Blackboard.get_data("enemy"))


func _get_cost() -> int:
	var squared_distance = Blackboard.get_data("npc_location").distance_squared_to(Blackboard.get_data("enemy").global_position)
	if squared_distance > Blackboard.get_data("squared_max_chase_distance"):
		return 1000
	return int(squared_distance / 7)


func _get_action_name() -> StringName:
	return "move_to_enemy_action"


func _get_preconditions() -> Dictionary:
	return {"found_enemy" : true}


func _get_effects() -> Dictionary:
	return {"close_to_enemy" : true}


func _perform(actor, delta) -> bool:
	var npc = actor as Npc
	
	var npc_pos: Vector2 = npc.get_global_position()
	var enemy: Enemy = Blackboard.get_data("enemy")
	var enemy_pos: Vector2 = enemy.get_global_position()
	var squared_distance: float = npc_pos.distance_squared_to(enemy_pos)

	if squared_distance < npc.squared_chase_distance:
		return true
	else:
		var target_direction: Vector2 = (enemy_pos - npc_pos).normalized()
		npc.direction = target_direction
		npc.set_velocity(target_direction * npc.chase_speed)
		npc.look_at(enemy_pos)
		npc.move_and_slide()

	return false
