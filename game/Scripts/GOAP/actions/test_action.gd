extends GoapAction


static var min_follow_distance : float = 15.0
static var follow_speed : float = 60.0


func _is_valid() -> bool:
	return true


func _get_cost() -> int:
	var distance = Blackboard.get_data("npc_location").distance_to(Blackboard.get_data("player_location"))
	return int(distance / 7)


func _get_action_name() -> StringName:
	return "test_action"


func _get_preconditions() -> Dictionary:
	return {}


func _get_effects() -> Dictionary:
	return {"close_to_player" : true}


func _perform(actor, delta) -> bool:
	var player_pos: Vector2 = Blackboard.get_data("player_location")
	var npc_pos: Vector2 = Blackboard.get_data("npc_location")
	var distance = npc_pos.distance_to(player_pos)
	var npc = actor as Npc

	if distance < min_follow_distance:
		return true
	else:
		npc.set_velocity(Vector2.ZERO)
		var target_pos: Vector2 = (player_pos - npc_pos).normalized()
		npc.direction = target_pos
		npc.set_velocity(target_pos * follow_speed)
		npc.look_at(player_pos)
		npc.move_and_slide()

	return false
