class_name FleeGoal
extends GoapGoal


func _get_goal_name() -> StringName:
	return "flee_goal"


func _is_goal_met() -> bool:
	var data = Blackboard.get_data("flee_goal_complete")
	if !NpcGoap.is_bool_and_true(data):
		return false
	
	Blackboard.add_data("flee_goal_complete", false)
	return true


func _get_priority() -> int:
	return 9


func _get_desired_state() -> Dictionary:
	return {"close_to_enemy" : false}
