class_name ObjectiveGoal
extends GoapGoal


func _get_goal_name() -> StringName:
	return "objective_goal"


func _is_goal_met() -> bool:
	var data = Blackboard.get_data("objective_goal_complete")
	if !NpcGoap.is_bool_and_true(data):
		return false
	
	Blackboard.add_data("objective_goal_complete", false)
	return true


func _get_priority() -> int:
	return 7


func _get_desired_state() -> Dictionary:
	return {"close_to_objective" : true}
