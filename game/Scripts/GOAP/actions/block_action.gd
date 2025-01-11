class_name BlockAction
extends GoapAction


func _is_valid() -> bool:
	return true


func _get_cost() -> int:
	if Blackboard.get_data("block_priority"):
		return 100 - Blackboard.get_data("block_priority") 
	return 1


func _get_action_name() -> StringName:
	return "block_action"


func _get_preconditions() -> Dictionary:
	return {"arrived_at_location": true, "found_enemy" : true}


func _get_effects() -> Dictionary:
	return {"deal_damage": true}


func _perform(actor, _delta) -> bool:
	var npc = actor as Npc
	var enemy: Enemy = Blackboard.get_data("enemy")
	if enemy == null || !is_instance_valid(enemy):
		return true
	var direction = (enemy.global_position - npc.global_position).normalized()
	if await npc.block(direction):
		Blackboard.remove_data("enemy")
		Blackboard.remove_data("arrived_at_location")
		Blackboard.remove_data("found_enemy")
		return true
	
	return false


func _perform_physics(actor, _delta) -> bool:
	var npc = actor as Npc
	npc.velocity = Vector2.ZERO
	return false
