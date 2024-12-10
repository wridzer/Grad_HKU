class_name FindEnemyGoal
extends GoapGoal


func _get_goal_name() -> StringName:
	return "find_enemy_goal"


func _is_goal_met() -> bool:
	var data = Blackboard.get_data("enemy")
	return is_instance_valid(data)


func _get_priority() -> int:
	return 15


func _get_desired_state() -> Dictionary:
	return {"found_enemy" : true}
