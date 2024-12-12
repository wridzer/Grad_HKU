class_name MoveToHidingSpotAction
extends GoapAction


func _is_valid() -> bool:
	if is_instance_valid(Blackboard.get_data("hiding_spot")):
		var data = Blackboard.get_data("enemies_present")
		if is_instance_valid(data):
			var enemies_present: bool = data
			return enemies_present
	
	return false


func _get_cost() -> int:
	var npc: Npc = Blackboard.get_data("npc")
	var distance_squared = npc.global_position.distance_squared_to(Blackboard.get_data("hiding_spot"))
	return int(distance_squared / 50)


func _get_action_name() -> StringName:
	return "move_to_hiding_spot_action"


func _get_preconditions() -> Dictionary:
	return {"found_hiding_spot" : true}


func _get_effects() -> Dictionary:
	return {"close_to_hiding_spot" : true}


func _perform_physics(actor, _delta) -> bool:
	var npc = actor as Npc
	
	var npc_pos: Vector2 = npc.get_global_position()
	var data = Blackboard.get_data("hiding_spot")
	if !is_instance_valid(data):
		return true
	var hiding_spot_pos: Vector2 = data
	var distance_squared: float = npc_pos.distance_squared_to(hiding_spot_pos)
	
	var condition: bool = distance_squared < npc.follow_distance_squared
	Blackboard.add_data("hide_goal_complete", condition)
	if condition:
		return true
	else:
		var target_direction: Vector2 = (hiding_spot_pos - npc_pos).normalized()
		npc.direction = target_direction
		npc.set_velocity(target_direction * npc.chase_speed)
		npc.look_at(hiding_spot_pos)
		npc.move_and_slide()

	return false
