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
	# Get data
	var aggro = Blackboard.get_data("aggro_priority") if Blackboard.get_data("aggro_priority") else 30
	var player_aggro = Blackboard.get_data("enemy_killed_percentage_in_room") if Blackboard.get_data("enemy_killed_percentage_in_room") else 30
	
	# Add player aggro that is above 50, subtract less then 50
	aggro += (player_aggro - 50)
	
	# Enemy aggro
	if Player.instance.room:
		for enemy in Player.instance.room.enemies:
			if(enemy.state_machine._state.get_state_type() == EnemyState.StateType.CHASE):
				aggro += 50
				break
	
	Blackboard.add_data("npc_aggro", aggro)
	return aggro


func _get_desired_state() -> Dictionary:
	return {"deal_damage" : true}
