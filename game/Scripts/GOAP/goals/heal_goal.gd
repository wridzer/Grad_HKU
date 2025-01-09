extends GoapGoal


func _get_goal_name() -> StringName:
	return "heal_goal"


func _is_goal_met() -> bool:
	if Player.instance.room.heal_pickups.size() > 0:
		if (Blackboard.get_data("npc_health") < Blackboard.get_data("npc_heal_health")):
			return false
	return true


func _get_priority() -> int:
	return 75


func _get_desired_state() -> Dictionary:
	return {"health_up" : true}
