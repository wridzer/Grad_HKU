class_name FleeGoal
extends GoapGoal


func _get_goal_name() -> StringName:
	return "flee_goal"


func _is_goal_met() -> bool:
	# If there is no current enemy, no reason to flee, true
	var data = Blackboard.get_data("enemy")
	if !is_instance_valid(data):
		return true
	
	# If the flee goal is not yet completed, false
	var flee_goal_complete: bool = false
	if Blackboard.get_data("flee_goal_complete"):
		flee_goal_complete = Blackboard.get_data("flee_goal_complete")
	
	if !flee_goal_complete:
		return false
	
	var npc: Npc = Blackboard.get_data("npc")
	var enemy: Enemy = data
	var npc_pos: Vector2 = npc.get_global_position()
	var enemy_pos: Vector2 = enemy.get_global_position()
	var distance_squared = npc_pos.distance_squared_to(enemy_pos)
	
	# If the npc is close to the enemy, false
	if distance_squared < npc.flee_distance_squared:
		Blackboard.add_data("flee_goal_complete", false)
		return false
	
	return true


func _get_priority() -> int:
	if Blackboard.get_data("shoot_priority"):
		return Blackboard.get_data("shoot_priority") + 1

	return 0


func _get_desired_state() -> Dictionary:
	return {"close_to_enemy" : false}
