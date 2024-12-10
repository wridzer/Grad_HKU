class_name KillEnemyGoal
extends GoapGoal


func _get_goal_name() -> StringName:
	return "kill_enemy_goal"


func _is_goal_met() -> bool:
	var data = Blackboard.get_data("enemy")
	return !is_instance_valid(data)


func _get_priority() -> int:
	return 10


func _get_desired_state() -> Dictionary:
	return {"hit_enemy" : true}
