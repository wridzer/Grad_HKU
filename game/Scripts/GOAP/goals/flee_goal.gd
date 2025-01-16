class_name FleeGoal
extends GoapGoal


func _get_goal_name() -> StringName:
	return "flee"


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
	
	# If the npc is already hidden we can return
	if npc.is_hidden:
		return true
		
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
	# Get data
	var current_health = Blackboard.get_data("npc_health") if Blackboard.get_data("npc_health") else 30
	var desired_health = Blackboard.get_data("desired_health") if Blackboard.get_data("desired_health") else 0
	
	# If health is low
	if current_health < desired_health:
		return 100
	
	var slash_priority = Blackboard.get_data("slash_priority") if Blackboard.get_data("slash_priority") else 0
	var block_priority = Blackboard.get_data("block_priority") if Blackboard.get_data("block_priority") else 0
	var shoot_priority = Blackboard.get_data("shoot_priority") if Blackboard.get_data("shoot_priority") else 0
	
	# If npc want to shoot arrow but is to close
	if shoot_priority > slash_priority && shoot_priority > block_priority:
		if Player.instance.room:
			var picked_enemy: Enemy
			var distance = INF
			var npc = Blackboard.get_data("npc")
			var npc_pos = npc.get_global_position()
			for enemy in Player.instance.room.enemies:
				var enemy_distance = npc_pos.distance_to(enemy.get_global_position())
				if enemy_distance < distance:
					picked_enemy = enemy
					distance = enemy_distance
			if picked_enemy != null && distance < npc._follow_distance:
				return 100
	
	return 1


func _get_desired_state() -> Dictionary:
	return {"close_to_enemy" : false}
