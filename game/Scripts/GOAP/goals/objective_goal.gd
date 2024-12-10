class_name ObjectiveGoal
extends GoapGoal


func _get_goal_name() -> StringName:
	return "objective_goal"


func _is_goal_met() -> bool:
	var data = Blackboard.get_data("objective_goal_complete")
	if is_instance_valid(data):
		var objective_goal_complete: bool = data
		return objective_goal_complete
	
	return false


func _get_priority() -> int:
	return 7


func _get_desired_state() -> Dictionary:
	return {"close_to_objective" : true}
