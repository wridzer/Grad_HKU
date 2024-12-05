extends GoapGoal

static var max_follow_distance : float = 25.0

func _get_goal_name() -> StringName:
	return "Test Goal"

func _is_goal_met() -> bool:
	var distance = Blackboard.get_data("npc_location").distance_to(Blackboard.get_data("player_location"))
	return distance > max_follow_distance

func _get_priority() -> int:
	return 1

func _get_desired_state() -> Dictionary:
	return {}
