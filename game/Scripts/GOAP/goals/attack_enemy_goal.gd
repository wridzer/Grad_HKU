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
	var agro = Blackboard.get_data("agro_priority") if Blackboard.get_data("agro_priority") else 30
	var player_agro = Blackboard.get_data("enemy_killed_percentage") if Blackboard.get_data("enemy_killed_percentage") else 30
	
	# Add player agro that is above 50, subtract less then 50
	agro += (player_agro - 50)
	
	# Enemie agro
	if Player.instance.room:
		for enemie in Player.instance.room.enemies:
			if(enemie.state_machine._state.get_state_type() == EnemyState.StateType.CHASE):
				agro += 50
				break
	
	Blackboard.add_data("npc_agro", agro)
	return agro


func _get_desired_state() -> Dictionary:
	return {"deal_damage" : true}
