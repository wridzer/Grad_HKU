class_name HideGoal
extends GoapGoal


func _get_goal_name() -> StringName:
	return "hide_goal"


func _is_goal_met() -> bool:
	var hide_goal_complete: bool = false
	if Blackboard.get_data("hide_goal_complete"):
		hide_goal_complete = Blackboard.get_data("hide_goal_complete")

	if !hide_goal_complete && is_instance_valid(Blackboard.get_data("enemy")):
		return false
	
	Blackboard.add_data("hide_goal_complete", false)
	return true


func _get_priority() -> int:
	return 8


func _get_desired_state() -> Dictionary:
	return {"close_to_hiding_spot" : true}
