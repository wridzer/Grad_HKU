extends GoapGoal

static var follow_distance : float = 25.0

func _get_goal_name() -> StringName:
	return "Test Goal"

func _is_goal_met() -> bool:
	if Blackboard.get_data("npc_location"):
		var npc_pos : Vector2 = Blackboard.get_data("npc_location")
		var player_pos : Vector2 = Blackboard.get_data("player_location")
		var distance = npc_pos.distance_to(player_pos)
		return distance > follow_distance
	return false

func _get_priority() -> int:
	return 10

func _get_desired_state() -> Dictionary:
	return {"close_to_player" : true}
