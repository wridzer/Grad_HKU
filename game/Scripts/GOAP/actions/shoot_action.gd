class_name ShootAction
extends GoapAction


func _is_valid() -> bool:
	var data = Blackboard.get_data("enemies_present")
	if is_instance_valid(data):
		var enemies_present: bool = data
		return enemies_present
	
	return false


func _get_cost() -> int:
	var distance_squared = Blackboard.get_data("npc_location").distance_squared_to(Blackboard.get_data("enemy").global_position)
	return int(distance_squared / 7)


func _get_action_name() -> StringName:
	return "shoot_action"


func _get_preconditions() -> Dictionary:
	return {"close_to_enemy": false}


func _get_effects() -> Dictionary:
	return {"shoot_enemy": true}


func _perform(actor, _delta) -> bool:
	var npc = actor as Npc
	var direction = (Blackboard.get_data("enemy").global_position - npc.global_position).normalized()
	npc.shoot(direction)
	return true


func _perform_physics(actor, _delta) -> bool:
	var npc = actor as Npc
	npc.velocity = Vector2.ZERO
	return false
