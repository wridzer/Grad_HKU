class_name SlashAction
extends GoapAction


func _is_valid() -> bool:
	if !Blackboard.get_data("enemies_present"):
		return false
	
	var data = Blackboard.get_data("enemy")
	return is_instance_valid(data)


func _get_cost() -> int:
	var npc: Npc = Blackboard.get_data("npc")
	var enemy: Enemy = Blackboard.get_data("enemy")
	var distance_squared = npc.global_position.distance_squared_to(enemy.global_position)
	return int(distance_squared / 7)


func _get_action_name() -> StringName:
	return "slash_action"


func _get_preconditions() -> Dictionary:
	return {"close_to_enemy" : true}


func _get_effects() -> Dictionary:
	return {"slash_enemy" : true}


func _perform(actor, _delta) -> bool:
	var npc = actor as Npc
	var enemy: Enemy = Blackboard.get_data("enemy")
	var direction = (enemy.global_position - npc.global_position).normalized()
	if await npc.slash(direction):
		Blackboard.remove_data("enemy")
		return true
	
	return false


func _perform_physics(actor, _delta) -> bool:
	var npc = actor as Npc
	npc.velocity = Vector2.ZERO
	return false
