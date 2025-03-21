class_name SlashEnemyGoal
extends GoapGoal


func _get_goal_name() -> StringName:
	return "slash_enemy_goal"


func _is_goal_met() -> bool:
	var data = Blackboard.get_data("enemy")
	return !is_instance_valid(data)


func _get_priority() -> int:
	if Blackboard.get_data("slash_priority"):
		return Blackboard.get_data("slash_priority") 

	return 0


func _get_desired_state() -> Dictionary:
	return {"slash_enemy" : true}
