class_name ShootEnemyGoal
extends GoapGoal


func _get_goal_name() -> StringName:
	return "shoot_enemy_goal"


func _is_goal_met() -> bool:
	var data = Blackboard.get_data("enemy")
	return !is_instance_valid(data)


func _get_priority() -> int:
	var data = Blackboard.get_data("shoot_priority")
	if is_instance_valid(data):
		var shoot_priority: int = data
		return shoot_priority
	
	return 0


func _get_desired_state() -> Dictionary:
	return {"shoot_enemy" : true}
