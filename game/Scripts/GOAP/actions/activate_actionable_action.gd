extends GoapAction


func _is_valid() -> bool:
	return true


func _get_cost() -> int:
	return 1


func _get_action_name() -> StringName:
	return "activate_actionable"


func _get_preconditions() -> Dictionary:
	return {"arrived_at_location" : true, "actionable_found" : true}


func _get_effects() -> Dictionary:
	return {"actionable_activated" : true}


func _perform(actor, _delta) -> bool:
	var npc = actor as AnimatedCharacter
	var item = Blackboard.get_data("destination_node")
	if item == null || !is_instance_valid(item):
		return false
	
	item.actionable.interactor = npc
	item.actionable.action.emit()
	return true
