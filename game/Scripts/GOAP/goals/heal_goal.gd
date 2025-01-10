extends GoapGoal


func _get_goal_name() -> StringName:
	return "heal"


func _is_goal_met() -> bool:
	if !is_instance_valid(Player.instance.room):
		return true
		
	if Player.instance.room.heal_pickups.size() <= 0:
		return true
		
	if Player.instance.room.heal_pickups.size() > 0:
		var npc_health = Blackboard.get_data("npc_health")
		#var npc_heal_health = Blackboard.get_data("npc_heal_health")
		var npc_heal_health = 1
		if (npc_health <= npc_heal_health):
			return false
			
	return true


func _get_priority() -> int:
	# Get desired_health and current_health from NPC
	# if health >= desried_healt:
	#	return 0
	# else:
	# 	return (desired_health - current_health) / desired_health * 100
	return 75


func _get_desired_state() -> Dictionary:
	return {"health_up" : true, "actionable_activated" : true}
