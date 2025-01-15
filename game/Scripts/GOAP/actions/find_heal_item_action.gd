extends GoapAction


func _is_valid() -> bool:
	return true


func _get_cost() -> int:
	return 1


func _get_action_name() -> StringName:
	return "find_heal_item"


func _get_preconditions() -> Dictionary:
	return {}


func _get_effects() -> Dictionary:
	return {"has_destination" : true, "actionable_found" : true, "health_up" : true}


func _perform(_actor, _delta) -> bool:
	var heal_item: HealPickup = Player.instance.room.heal_pickups.pick_random()
	Blackboard.add_data("destination_node", heal_item)
	return true
