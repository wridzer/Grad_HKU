class_name MoveToEnemyAction
extends GoapAction


func _is_valid() -> bool:
	var data = Blackboard.get_data("enemies_present")
	if is_instance_valid(data):
		var enemies_present: bool = data
		var other_data = Blackboard.get_data("enemy")
		if enemies_present && is_instance_valid(other_data):
			print("move_to_enemy valid")
		return enemies_present && is_instance_valid(other_data)
	
	return false


func _get_cost() -> int:
	var distance_squared = Blackboard.get_data("npc_global_position").distance_squared_to(Blackboard.get_data("enemy").global_position)
	if distance_squared > Blackboard.get_data("max_chase_distance_squared"):
		return int(distance_squared)
	return int(distance_squared / 50)


func _get_action_name() -> StringName:
	return "move_to_enemy_action"


func _get_preconditions() -> Dictionary:
	return {}


func _get_effects() -> Dictionary:
	return {"close_to_enemy" : true}


func _perform_physics(actor, _delta) -> bool:
	var npc = actor as Npc
	
	var npc_pos: Vector2 = npc.get_global_position()
	var data = Blackboard.get_data("enemy")
	if !is_instance_valid(data):
		return true
	var enemy: Enemy = data
	var enemy_pos: Vector2 = enemy.get_global_position()
	var distance_squared: float = npc_pos.distance_squared_to(enemy_pos)

	if distance_squared < npc.chase_distance_squared:
		return true
	else:
		var target_direction: Vector2 = (enemy_pos - npc_pos).normalized()
		npc.direction = target_direction
		npc.set_velocity(target_direction * npc.chase_speed)
		npc.look_at(enemy_pos)
		npc.move_and_slide()

	return false
