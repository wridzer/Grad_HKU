extends GoapAction


func _is_valid() -> bool:
	return true


func _get_cost() -> int:
	return 1


func _get_action_name() -> StringName:
	return "find_key"


func _get_preconditions() -> Dictionary:
	return {}


func _get_effects() -> Dictionary:
	return {"has_destination" : true, "actionable_found" : true, "objective_progress_up" : true}


func _perform(_actor, _delta) -> bool:
	var key_item: KeyPickup = Player.instance.room.key_pickups.pick_random()
	Blackboard.add_data("destination_node", key_item)
	return true
