class_name BlockAction
extends GoapAction


func _is_valid() -> bool:
	return true


func _get_cost() -> int:
	var cost = 100
	
	# If npc is cornered by multiple enemies, it will use the shield
	var npc = Blackboard.get_data("npc")
	var npc_pos = npc.get_global_position()
	for enemy in Player.instance.room.enemies:
		var enemy_distance = npc_pos.distance_to(enemy.get_global_position())
		if enemy_distance < 5:
			cost -= 20
	
	if Blackboard.get_data("block_priority"):
		return cost - Blackboard.get_data("block_priority") 
	return 1


func _get_action_name() -> StringName:
	return "block_action"


func _get_preconditions() -> Dictionary:
	return {"arrived_at_location": true, "found_enemy" : true}


func _get_effects() -> Dictionary:
	return {"deal_damage": true}


func _perform(actor, _delta) -> bool:
	var npc = actor as Npc
	var enemy = Blackboard.get_data("enemy")
	if enemy == null || !is_instance_valid(enemy):
		return true
	
	if await npc.block():
		Blackboard.remove_data("enemy")
		Blackboard.remove_data("arrived_at_location")
		Blackboard.remove_data("found_enemy")
		return true
	
	return false


func _perform_physics(actor, _delta) -> bool:
	var npc = actor as Npc
	npc.velocity = Vector2.ZERO
	return false
