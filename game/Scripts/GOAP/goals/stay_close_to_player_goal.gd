class_name StayCloseToPlayerGoal
extends GoapGoal


func _get_goal_name() -> StringName:
	return "stay_close_to_player_goal"


func _is_goal_met() -> bool:
	var data = Blackboard.get_data("npc_location")
	var other_data = Blackboard.get_data("follow_distance_squared")
	if is_instance_valid(data) && is_instance_valid(other_data):
		var npc_pos: Vector2 = data
		var player_pos: Vector2 = Player.instance.global_position
		var distance_squared: float = npc_pos.distance_squared_to(player_pos)
		var follow_distance_squared: float = other_data
		return distance_squared < follow_distance_squared
	
	return false


func _get_priority() -> int:
	return 10


func _get_desired_state() -> Dictionary:
	return {"close_to_player" : true}
