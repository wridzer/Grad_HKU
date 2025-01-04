class_name FleeFromEnemyAction
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
	var normalized_distance = max(npc.max_chase_distance_squared - distance_squared, 0) / npc.max_chase_distance_squared
	
	var health = Blackboard.get_data("npc_health")
	var max_health = Blackboard.get_data("npc_max_health")
	
	return int((max_health - (max_health - health) - normalized_distance) * 10)


func _get_action_name() -> StringName:
	return "flee_from_enemy_action"


func _get_preconditions() -> Dictionary:
	return {}


func _get_effects() -> Dictionary:
	return {"close_to_enemy": false}


func _perform_physics(actor, _delta) -> bool:
	var npc = actor as Npc
	
	var npc_pos: Vector2 = npc.get_global_position()
	var data = Blackboard.get_data("enemy")
	if !is_instance_valid(data):
		return true
	var enemy: Enemy = data
	var enemy_pos: Vector2 = enemy.get_global_position()
	var distance_squared: float = npc_pos.distance_squared_to(enemy_pos)
	
	Blackboard.add_data("flee_goal_complete", distance_squared > npc.flee_distance_squared)
	if distance_squared > npc.flee_distance_squared:
		return true
	else:
		var target_direction: Vector2 = (npc_pos - enemy_pos).normalized()
		npc.direction = target_direction
		npc.set_velocity(target_direction * npc.flee_speed)
		npc.animated_sprite_2d.look_at(target_direction)
		npc.move_and_slide()
	
	return false
