class_name HideGoal
extends GoapGoal


func _get_goal_name() -> StringName:
	return "hide_goal"


func _is_goal_met() -> bool:
	var data = Blackboard.get_data("hide_goal_complete")
	if is_instance_valid(data):
		var hide_goal_complete: bool = data
		if hide_goal_complete:
			Blackboard.add_data("hide_goal_complete", false)
			return true
	
	return false


func _get_priority() -> int:
	return 8


func _get_desired_state() -> Dictionary:
	return {"close_to_hiding_spot" : true}
