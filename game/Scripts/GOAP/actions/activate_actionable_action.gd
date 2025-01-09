extends GoapAction


func _is_valid() -> bool:
	if Blackboard.get_data("npc_near_heal"):
		return true
	if Blackboard.get_data("npc_near_key"):
		return true
	
	return false


func _get_cost() -> int:
	return 1


func _get_action_name() -> StringName:
	return "activate_actionable_action"


func _get_preconditions() -> Dictionary:
	return {"near_actionable" : true}


func _get_effects() -> Dictionary:
	if Blackboard.get_data("npc_near_heal"):
		return {"heal_up" : true}
	if Blackboard.get_data("npc_near_key"):
		return {"objective_progress_up" : true}
	return {"" : true}


func _perform(actor, _delta) -> bool:
	var npc = actor as Npc
	return false


func _perform_physics(actor, _delta) -> bool:
	var npc = actor as Npc
	return false
