class_name MoveToObjectiveAction
extends GoapAction


func _is_valid() -> bool:
	if is_instance_valid(Player.instance.room):
		return is_instance_valid(Player.instance.room.objective)
	
	return false


func _get_cost() -> int:
	var distance_squared = Blackboard.get_data("npc_global_position").distance_squared_to(Player.instance.room.objective.global_position)
	return int(distance_squared / 50)


func _get_action_name() -> StringName:
	return "move_to_objective_action"


func _get_preconditions() -> Dictionary:
	return {"found_objective" : true}


func _get_effects() -> Dictionary:
	return {"close_to_objective" : true}


func _perform_physics(actor, _delta) -> bool:
	var npc = actor as Npc
	
	var npc_pos: Vector2 = npc.get_global_position()
	var objective: Node2D = Player.instance.room.objective
	var objective_pos: Vector2 = objective.get_global_position()
	var distance_squared: float = npc_pos.distance_squared_to(objective_pos)
	
	Blackboard.add_data("objective_goal_complete", distance_squared < npc.follow_distance_squared)
	if distance_squared < npc.follow_distance_squared:
		return true
	else:
		npc.set_velocity(Vector2.ZERO)
		var target_direction: Vector2 = (objective_pos - npc_pos).normalized()
		npc.direction = target_direction
		npc.set_velocity(target_direction * npc.chase_speed)
		npc.look_at(objective_pos)
		npc.move_and_slide()

	return false
