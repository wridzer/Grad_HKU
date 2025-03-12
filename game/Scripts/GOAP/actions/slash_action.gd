class_name SlashAction
extends GoapAction


func _is_valid() -> bool:
	return true


func _get_cost() -> int:
	if Blackboard.get_data("slash_priority"):
		return 100 - Blackboard.get_data("slash_priority") 
	return 1


func _get_action_name() -> StringName:
	return "slash_action"


func _get_preconditions() -> Dictionary:
	return {"arrived_at_location" : true, "found_enemy" : true}


func _get_effects() -> Dictionary:
	return {"deal_damage" : true}


func _perform(actor, _delta) -> bool:
	var npc = actor as Npc
	var enemy = Blackboard.get_data("enemy")
	if enemy == null || !is_instance_valid(enemy):
		return true
	
	if await npc.slash():
		Blackboard.remove_data("enemy")
		Blackboard.remove_data("arrived_at_location")
		Blackboard.remove_data("found_enemy")
		return true
	
	return false
