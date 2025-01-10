class_name ObjectiveGoal
extends GoapGoal


func _get_goal_name() -> StringName:
	return "objective_goal"


func _is_goal_met() -> bool:
	## If there is no current objective, true
	#var data = Blackboard.get_data("objective")
	#if !is_instance_valid(data):
		#return true
	#
	## If the objective goal is not yet completed, false
	#var objective_goal_complete: bool = false
	#if Blackboard.get_data("objective_goal_complete"):
		#objective_goal_complete = Blackboard.get_data("objective_goal_complete")
		#if !objective_goal_complete &&  Player.instance.room.key_pickups.size() > 0:
			#return false
	if !is_instance_valid(Player.instance.room):
		return true
	
	if Player.instance.room.key_pickups.size() <= 0:
		return true
	return false


func _get_priority() -> int:
	return 7


func _get_desired_state() -> Dictionary:
	return {"objective_progress_up" : true}
