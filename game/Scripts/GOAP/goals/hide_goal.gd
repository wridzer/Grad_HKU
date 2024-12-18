class_name HideGoal
extends GoapGoal


func _get_goal_name() -> StringName:
	return "hide_goal"


func _is_goal_met() -> bool:
	# If there is no current enemy, no reason to hide, true
	var data = Blackboard.get_data("enemy")
	if !is_instance_valid(data):
		return true
	
	# If the hide goal is not yet completed, false
	var hide_goal_complete: bool = false
	if Blackboard.get_data("hide_goal_complete"):
		hide_goal_complete = Blackboard.get_data("hide_goal_complete")
	
	if !hide_goal_complete:
		return false
	
	Blackboard.add_data("hide_goal_complete", false)
	return true


func _get_priority() -> int:
	return 8


func _get_desired_state() -> Dictionary:
	return {"close_to_hiding_spot" : true}
