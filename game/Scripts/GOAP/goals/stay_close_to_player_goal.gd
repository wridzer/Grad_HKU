class_name StayCloseToPlayerGoal
extends GoapGoal


func _get_goal_name() -> StringName:
	return "stay_close_to_player_goal"


func _is_goal_met() -> bool:
	var data = Blackboard.get_data("npc_location")
	var other_data = Blackboard.get_data("squared_follow_distance")
	if is_instance_valid(data) && is_instance_valid(other_data):
		var npc_pos : Vector2 = data
		var player_pos : Vector2 = Player.instance.global_position
		var squared_distance = npc_pos.distance_squared_to(player_pos)
		var squared_follow_distance
		return squared_distance < squared_follow_distance
	return false


func _get_priority() -> int:
	return 10


func _get_desired_state() -> Dictionary:
	return {"close_to_player" : true}
