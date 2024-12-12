class_name MoveAwayFromPlayerAction
extends GoapAction


func _is_valid() -> bool:
	return true


func _get_cost() -> int:
	var npc: Npc = Blackboard.get_data("npc")
	var distance_squared: float = npc.global_position.distance_squared_to(Player.instance.get_global_position())
	print(int(distance_squared - npc.follow_distance_squared))
	return max(int(distance_squared - npc.follow_distance_squared), 0)


func _get_action_name() -> StringName:
	return "move_away_from_player_action"


func _get_preconditions() -> Dictionary:
	return {}


func _get_effects() -> Dictionary:
	return {"close_to_player" : true}


func _perform_physics(actor, _delta) -> bool:
	var npc = actor as Npc
	var player_pos: Vector2 = Player.instance.get_global_position()
	var npc_pos: Vector2 = npc.get_global_position()
	var distance_squared = npc_pos.distance_squared_to(player_pos)
	
	# Let the goal know via blackboard that the npc
	# has moved over the equilibrium and can idle
	Blackboard.add_data("stay_close_to_player_goal_complete", distance_squared > npc.follow_equilibrium_distance_squared)
	if distance_squared > npc.follow_equilibrium_distance_squared:
		return true
	else:
		var target_direction: Vector2 = (npc_pos - player_pos).normalized()
		npc.direction = target_direction
		npc.set_velocity(target_direction * npc.follow_speed)
		npc.look_at(player_pos)
		npc.move_and_slide()

	return false
