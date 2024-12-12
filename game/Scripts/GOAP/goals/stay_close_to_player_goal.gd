class_name StayCloseToPlayerGoal
extends GoapGoal


func _get_goal_name() -> StringName:
	return "stay_close_to_player_goal"


func _is_goal_met() -> bool:
	var data = Blackboard.get_data("stay_close_to_player_goal_complete")
	if is_instance_valid(data):
		var stay_close_to_player_goal_complete: bool = data
		if stay_close_to_player_goal_complete:
			Blackboard.add_data("stay_close_to_player_goal_complete", false)
			return true
	
	return false


func _get_priority() -> int:
	return 10


func _get_desired_state() -> Dictionary:
	return {"close_to_player" : true}
