class_name MoveToHidingSpotAction
extends GoapAction


func _is_valid() -> bool:
	return is_instance_valid(Blackboard.get_data("hiding_spot"))


func _get_cost() -> int:
	var squared_distance = Blackboard.get_data("npc_location").distance_squared_to(Blackboard.get_data("hiding_spot"))
	return int(squared_distance / 7)


func _get_action_name() -> StringName:
	return "move_to_hiding_spot_action"


func _get_preconditions() -> Dictionary:
	return {"found_hiding_spot" : true}


func _get_effects() -> Dictionary:
	return {"close_to_hiding_spot" : true}


func _perform(actor, delta) -> bool:
	var npc = actor as Npc
	
	var npc_pos: Vector2 = npc.get_global_position()
	var hiding_spot_pos: Vector2 = Blackboard.get_data("hiding_spot")
	var squared_distance: float = npc_pos.distance_squared_to(hiding_spot_pos)

	if squared_distance < 2:
		return true
	else:
		var target_direction: Vector2 = (hiding_spot_pos - npc_pos).normalized()
		npc.direction = target_direction
		npc.set_velocity(target_direction * npc.chase_speed)
		npc.look_at(hiding_spot_pos)
		npc.move_and_slide()

	return false
