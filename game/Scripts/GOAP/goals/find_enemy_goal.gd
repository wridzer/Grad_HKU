class_name FindEnemyGoal
extends GoapGoal


func _get_goal_name() -> StringName:
	return "find_enemy_goal"


func _is_goal_met() -> bool:
	if is_instance_valid(Player.instance.room):
		var enemies_present: bool = Player.instance.room.enemies.size() > 0
		Blackboard.add_data("enemies_present", enemies_present)
		if enemies_present:
			var data = Blackboard.get_data("enemy")
			return is_instance_valid(data)
	
	return true


func _get_priority() -> int:
	return 15


func _get_desired_state() -> Dictionary:
	return {"found_enemy" : true}
