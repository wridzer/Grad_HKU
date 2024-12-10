class_name BlockEnemyGoal
extends GoapGoal


func _get_goal_name() -> StringName:
	return "block_enemy_goal"


func _is_goal_met() -> bool:
	var data = Blackboard.get_data("enemy")
	return !is_instance_valid(data)


func _get_priority() -> int:
	var data = Blackboard.get_data("block_priority")
	if is_instance_valid(data):
		var block_priority: int = data
		return block_priority
	
	return 0


func _get_desired_state() -> Dictionary:
	return {"block_enemy" : true}
