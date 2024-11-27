extends GoapGoal

static var max_follow_distance : float = 25.0

func is_valid() -> bool:
	var distance = Blackboard.get_data("npc_location").distance_to(Blackboard.get_data("player_location"))
	return distance > max_follow_distance

func priority() -> int:
	return 1


func get_desired_state() -> Dictionary:
	return {
	}
