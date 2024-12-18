class_name StayCloseToPlayerGoal
extends GoapGoal


func _get_goal_name() -> StringName:
	return "stay_close_to_player_goal"


func _is_goal_met() -> bool:
	# If the bool "stay_close_to_player_goal_complete", false
	var stay_close_to_player_goal_complete: bool = false
	if Blackboard.get_data("stay_close_to_player_goal_complete"):
		stay_close_to_player_goal_complete = Blackboard.get_data("stay_close_to_player_goal_complete")
	
	if !stay_close_to_player_goal_complete:
		return false
	
	var npc: Npc = Blackboard.get_data("npc")
	var npc_pos: Vector2 = npc.get_global_position()
	var player_pos: Vector2 = Player.instance.get_global_position()
	var distance_squared = npc_pos.distance_squared_to(player_pos)
	
	# If the npc is outside the bounds, false
	if distance_squared > npc.follow_distance_squared || \
	   distance_squared < npc.min_follow_distance_squared:
		Blackboard.add_data("stay_close_to_player_goal_complete", false)
		return false
	
	# Npc is within bounds, true
	return true


func _get_priority() -> int:
	return 10


func _get_desired_state() -> Dictionary:
	return {"close_to_player" : true}
