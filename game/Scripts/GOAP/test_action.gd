extends GoapAction

static var min_follow_distance : float = 15.0

func is_valid() -> bool:
	var distance = Blackboard.get_data("npc_location").distance_to(Blackboard.get_data("player_location"))
	return distance > min_follow_distance


func get_cost() -> int:
	var distance = Blackboard.get_data("npc_location").distance_to(Blackboard.get_data("player_location"))
	return int(distance / 7)

func _get_action_name(name):
	name = "TEST"

func get_preconditions() -> Dictionary:
	return {}


func get_effects() -> Dictionary:
	return {}


func perform(actor, delta) -> bool:
	var distance = Blackboard.get_data("npc_location").distance_to(Blackboard.get_data("player_location"))

	if distance < min_follow_distance:
		return true
	else:
		actor.move_to(actor.position.direction_to(Blackboard.get_data("player_location")), delta)

	return false
