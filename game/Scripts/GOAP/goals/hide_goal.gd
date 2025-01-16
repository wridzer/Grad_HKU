class_name HideGoal
extends GoapGoal


func _get_goal_name() -> StringName:
	return "hide"


func _is_goal_met() -> bool:
	if Player.instance.room == null:
		return true
		
	if Player.instance.room.enemies.size() <= 0:
		return true
				
	if Player.instance.room.barrels.size() <= 0:
		return true
	
	return false


func _get_priority() -> int:
	# Get data
	var current_health = Blackboard.get_data("npc_health") if Blackboard.get_data("npc_health") else 30
	var desired_health = Blackboard.get_data("desired_health") if Blackboard.get_data("desired_health") else 0
	
	# If health is low
	if current_health < desired_health:
		return 99
	
	return 0


func _get_desired_state() -> Dictionary:
	return {"hidden" : true}
