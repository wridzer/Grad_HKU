class_name FindHidingSpotAction
extends GoapAction


func _is_valid() -> bool:
	if Blackboard.get_data("enemies_present"):
		var data = Blackboard.get_data("enemy")
		return is_instance_valid(data)
	
	return false


func _get_cost() -> int:
	# Reverse the distance cost with a maximum distance
	var npc: Npc = Blackboard.get_data("npc")
	var enemy: Enemy = Blackboard.get_data("enemy")
	var distance_squared = npc.global_position.distance_squared_to(enemy.global_position)
	var normalized_distance = max(npc.max_chase_distance_squared - distance_squared, 0) / npc.max_chase_distance_squared
	
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
