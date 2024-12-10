class_name ShootAction
extends GoapAction


func _is_valid() -> bool:
	return is_instance_valid(Blackboard.get_data("enemy"))


func _get_cost() -> int:
	var squared_distance = Blackboard.get_data("npc_location").distance_squared_to(Blackboard.get_data("enemy").global_position)
	return int(squared_distance / 7)


func _get_action_name() -> StringName:
	return "shoot_action"


func _get_preconditions() -> Dictionary:
	return {"close_to_enemy": true}


func _get_effects() -> Dictionary:
	return {"shoot_enemy": true}


func _perform(actor, delta) -> bool:
	var npc = actor as Npc
	npc.velocity = Vector2.ZERO
	var direction = (Blackboard.get_data("enemy").global_position - npc.global_position).normalized()
	npc.shoot(direction)
	return true
