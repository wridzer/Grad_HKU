class_name FindHidingSpotAction
extends GoapAction


func _is_valid() -> bool:
	var data = Blackboard.get_data("enemies_present")
	if is_instance_valid(data):
		var enemies_present: bool = data
		return enemies_present
	
	return false


func _get_cost() -> int:
	# Reverse the distance cost with a maximum distance
	var distance_squared = Blackboard.get_data("npc_location").distance_squared_to(Blackboard.get_data("enemy").global_position)
	var max_chase_distance_squared = Blackboard.get_data("max_chase_distance_squared")
	var normalized_distance = max(max_chase_distance_squared - distance_squared, 0) / max_chase_distance_squared
	
	return int((1.0 - normalized_distance) * 10)


func _get_action_name() -> StringName:
	return "find_hiding_spot_action"


func _get_preconditions() -> Dictionary:
	return {"found_hiding_spot" : false,
			"close_to_enemy" : false,
			"found_enemy" : true}


func _get_effects() -> Dictionary:
	return {"found_hiding_spot" : true}


func _perform(_actor, _delta) -> bool:
	#TODO: Find a hiding spot
	var hiding_spot: Vector2 = Vector2.ZERO
	Blackboard.add_data("hiding_spot", hiding_spot)
	return true
