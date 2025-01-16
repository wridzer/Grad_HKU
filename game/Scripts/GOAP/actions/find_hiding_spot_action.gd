class_name FindHidingSpotAction
extends GoapAction


func _is_valid() -> bool:
	if Player.instance.room == null:
		return true
		
	if Player.instance.room.barrels.size() > 0:
		return true
	return false


func _get_cost() -> int:
	return 1


func _get_action_name() -> StringName:
	return "find_hiding_spot"


func _get_preconditions() -> Dictionary:
	return {}


func _get_effects() -> Dictionary:
	return {"found_hiding_spot" : true, "has_destination" : true,  "actionable_found" : true}


func _perform(_actor, _delta) -> bool:
	Blackboard.add_data("destination_node", Player.instance.room.barrels[0] as Node2D)
	return true
