extends GoapGoal

func _get_goal_name() -> StringName:
	return "restore energy"

func _is_goal_met() -> bool:
	return Blackboard.get_data("energy") >= 100

func _get_priority() -> int:
	return 1

func _get_desired_state() -> Dictionary:
	return {"rested" : true}
