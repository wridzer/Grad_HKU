extends GoapGoal


func _get_goal_name() -> StringName:
	return ""


func _is_goal_met() -> bool:
	return false


func _get_priority() -> int:
	return 1


func _get_desired_state() -> Dictionary:
	return {}
