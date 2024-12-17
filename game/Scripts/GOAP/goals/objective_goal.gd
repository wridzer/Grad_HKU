class_name ObjectiveGoal
extends GoapGoal


func _get_goal_name() -> StringName:
	return "objective_goal"


func _is_goal_met() -> bool:
	var objective_goal_complete: bool = false
	if Blackboard.get_data("objective_goal_complete"):
		objective_goal_complete = Blackboard.get_data("objective_goal_complete")
	
	if !objective_goal_complete && is_instance_valid(Blackboard.get_data("enemy")):
		return false
	
	Blackboard.add_data("objective_goal_complete", false)
	return true


func _get_priority() -> int:
	return 7


func _get_desired_state() -> Dictionary:
	return {"close_to_objective" : true}
