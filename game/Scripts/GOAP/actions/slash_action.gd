class_name SlashAction
extends GoapAction


func _is_valid() -> bool:
	var data = Blackboard.get_data("enemies_present")
	if is_instance_valid(data):
		var enemies_present: bool = data
		return enemies_present
	
	return false


func _get_cost() -> int:
	var squared_distance = Blackboard.get_data("npc_location").distance_squared_to(Blackboard.get_data("enemy").global_position)
	return int(squared_distance / 7)


func _get_action_name() -> StringName:
	return "slash_action"


func _get_preconditions() -> Dictionary:
	return {"close_to_enemy" : true}


func _get_effects() -> Dictionary:
	return {"slash_enemy" : true}


func _perform(actor, _delta) -> bool:
	var npc = actor as Npc
	npc.slash()
	return true


func _perform_physics(actor, _delta) -> bool:
	var npc = actor as Npc
	npc.velocity = Vector2.ZERO
	return false
