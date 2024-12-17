class_name FleeGoal
extends GoapGoal


func _get_goal_name() -> StringName:
	return "flee_goal"


func _is_goal_met() -> bool:
	var flee_goal_complete: bool = false
	if Blackboard.get_data("flee_goal_complete"):
		flee_goal_complete = Blackboard.get_data("flee_goal_complete")

	if !flee_goal_complete && is_instance_valid(Blackboard.get_data("enemy")):
		return false
	
	Blackboard.add_data("flee_goal_complete", false)
	return true


func _get_priority() -> int:
	return 9


func _get_desired_state() -> Dictionary:
	return {"close_to_enemy" : false}
