class_name ShootAction
extends GoapAction


func _is_valid() -> bool:
	return true


func _get_cost() -> int:
	var cost = 100
	
	# Find closest enemy, retract distance
	# so when the npc is far away it will prefer the bow because it is easier,
	# except for when the other weapons have higher prio
	var picked_enemy: Enemy
	var distance = INF
	var npc = Blackboard.get_data("npc")
	var npc_pos = npc.get_global_position()
	for enemy in Player.instance.room.enemies:
		var enemy_distance = npc_pos.distance_to(enemy.get_global_position())
		if enemy_distance < distance:
			picked_enemy = enemy
			distance = enemy_distance
	if picked_enemy != null:
		cost = cost - (distance / 2)
	
	if Blackboard.get_data("shoot_priority"):
		return cost - Blackboard.get_data("shoot_priority")
	
	return 1


func _get_action_name() -> StringName:
	return "shoot_bow"


func _get_preconditions() -> Dictionary:
	return {"has_line_of_sight": true}


func _get_effects() -> Dictionary:
	return {"deal_damage": true}


func _perform(actor, _delta) -> bool:
	var npc = actor as Npc
	var enemy = Blackboard.get_data("enemy")
	if enemy == null || !is_instance_valid(enemy):
		return true
	var direction = (enemy.global_position - npc.global_position).normalized()
	if await npc.shoot(direction):
		Blackboard.remove_data("enemy")
		return true
	
	return false


func _perform_physics(actor, _delta) -> bool:
	var npc = actor as Npc
	npc.velocity = Vector2.ZERO
	return false
