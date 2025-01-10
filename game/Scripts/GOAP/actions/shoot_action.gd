class_name ShootAction
extends GoapAction


func _is_valid() -> bool:
	return true


func _get_cost() -> int:
	#var npc: Npc = Blackboard.get_data("npc")
	#var enemy: Enemy = Blackboard.get_data("enemy")
	#var distance_squared = npc.global_position.distance_squared_to(enemy.global_position)
	#return int(distance_squared / 7)
	
	if Blackboard.get_data("shoot_priority"):
		return 100 - Blackboard.get_data("shoot_priority")
	return 1


func _get_action_name() -> StringName:
	return "shoot_bow"


func _get_preconditions() -> Dictionary:
	return {"has_line_of_sight": true}


func _get_effects() -> Dictionary:
	return {"deal_damage": true}


func _perform(actor, _delta) -> bool:
	var npc = actor as Npc
	var enemy: Enemy = Blackboard.get_data("enemy")
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
