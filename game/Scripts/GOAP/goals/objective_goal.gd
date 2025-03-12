class_name ObjectiveGoal
extends GoapGoal


func _get_goal_name() -> StringName:
	return "get_objective"


func _is_goal_met() -> bool:
	if !is_instance_valid(Player.instance.room):
		return true
	
	if Player.instance.room.key_pickups.size() <= 0:
		return true
	return false


func _get_priority() -> int:
	return 25


func _get_desired_state() -> Dictionary:
	return {"objective_progress_up" : true, "actionable_activated" : true}
