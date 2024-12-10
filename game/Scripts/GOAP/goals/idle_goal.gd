class_name IdleGoal
extends GoapGoal


func _get_goal_name() -> StringName:
	return "idle_goal"


func _is_goal_met() -> bool:
	# Never stop idling
	return false


func _get_priority() -> int:
	return 1


func _get_desired_state() -> Dictionary:
	return {"idle" : true}
