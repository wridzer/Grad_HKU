extends GoapGoal


func _get_goal_name() -> StringName:
	return "revive_player"


func _is_goal_met() -> bool:
	if Player.instance.health_component.health > 0:
		return true
	return false


func _get_priority() -> int:
	return 100


func _get_desired_state() -> Dictionary:
	return {"player_alive" : true}
