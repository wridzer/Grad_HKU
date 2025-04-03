extends GoapGoal


func _get_goal_name() -> StringName:
	return "heal"


func _is_goal_met() -> bool:
	if !is_instance_valid(Player.instance.room):
		return true
		
	if Player.instance.room.heal_pickups.size() <= 0:
		return true
		
	if Player.instance.room.heal_pickups.size() > 0:
		var npc_health = Blackboard.get_data("npc_health") if Blackboard.get_data("npc_health") else 0
		var desired_health = Blackboard.get_data("desired_health") if Blackboard.get_data("desired_health") else 0
		if (npc_health <= desired_health):
			return false
			
	return true


func _get_priority() -> int:
	# Get data
	var current_health = Blackboard.get_data("npc_health") if Blackboard.get_data("npc_health") else 30
	var desired_health = Blackboard.get_data("desired_health") if Blackboard.get_data("desired_health") else 0
	
	if current_health >= desired_health:
		return 0
	else:
		return 60 * (desired_health - current_health)


func _get_desired_state() -> Dictionary:
	return {"health_up" : true, "actionable_activated" : true}
