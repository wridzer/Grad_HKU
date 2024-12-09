extends GoapAction


func _is_valid() -> bool:
	return true


func _get_cost() -> int:
	return 1


func _get_action_name() -> StringName:
	return "chill"


func _get_preconditions() -> Dictionary:
	return {}


func _get_effects() -> Dictionary:
	var current_energy = 0
	if Blackboard.get_data("energy"):
		current_energy = Blackboard.get_data("energy") + 1
	Blackboard.add_data("energy", current_energy)
	return {"energy" : current_energy}


func _perform(actor, delta) -> bool:
	#actor.playidleanimation ofzo
	return true
