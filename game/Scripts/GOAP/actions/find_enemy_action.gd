class_name FindEnemyAction
extends GoapAction


func _is_valid() -> bool:
	if !is_instance_valid(Player.instance.room):
		return false
	
	var enemies_present: bool = Player.instance.room.enemies.size() > 0
	Blackboard.add_data("enemies_present", enemies_present)
	return enemies_present


func _get_cost() -> int:
	return 1


func _get_action_name() -> StringName:
	return "find_enemy_action"


func _get_preconditions() -> Dictionary:
	return {}


func _get_effects() -> Dictionary:
	return {"found_enemy" : true, "has_destination" : true}


func _perform(_actor, _delta) -> bool:
	var picked_enemy: Enemy
	var distance = INF
	var npc_pos = _actor.get_global_position()
	for enemy in Player.instance.room.enemies:
		var enemy_distance = npc_pos.distance_to(enemy.get_global_position())
		if enemy_distance < distance:
			picked_enemy = enemy
			distance = enemy_distance
	if picked_enemy != null:
		Blackboard.add_data("enemy", picked_enemy)
		Blackboard.add_data("destination_node", picked_enemy)
		return true
	else:
		return false
