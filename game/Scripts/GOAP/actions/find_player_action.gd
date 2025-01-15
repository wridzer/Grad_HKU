extends GoapAction


func _is_valid() -> bool:
	return true


func _get_cost() -> int:
	return 1


func _get_action_name() -> StringName:
	return "find_player"


func _get_preconditions() -> Dictionary:
	return {}


func _get_effects() -> Dictionary:
	return {"player_found" : true, "has_destination" : true}


func _perform(actor, _delta) -> bool:
	Blackboard.add_data("destination_node", Player.instance)
	return true
