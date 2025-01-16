class_name IdleGoal
extends GoapGoal


func _get_goal_name() -> StringName:
	return "idle"


func _is_goal_met() -> bool:
	# Never stop idling
	return false


func _get_priority() -> int:
	# Get data
	var current_health = Blackboard.get_data("npc_health") if Blackboard.get_data("npc_health") else 30
	var desired_health = Blackboard.get_data("desired_health") if Blackboard.get_data("desired_health") else 0
	
	# If health is low
	if (current_health < desired_health
		&& Blackboard.get_data("flee_goal_complete")
		&& Player.instance.room != null
		&& Player.instance.room.enemies.size() > 0):
		return 99
	return 1


func _get_desired_state() -> Dictionary:
	return {"idle" : true}
