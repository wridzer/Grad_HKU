extends GoapGoal


func _get_goal_name() -> StringName:
	return "attack"


func _is_goal_met() -> bool:
	if Player.instance.room:
		var enemies_present: bool = Player.instance.room.enemies.size() > 0
		Blackboard.add_data("enemies_present", enemies_present)
		return !enemies_present
	return true


func _get_priority() -> int:
	return 90


func _get_desired_state() -> Dictionary:
	return {"deal_damage" : true}
