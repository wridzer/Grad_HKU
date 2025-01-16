extends GoapAction


func _is_valid() -> bool:
	return true


func _get_cost() -> int:
	return 1


func _get_action_name() -> StringName:
	return "revive"


func _get_preconditions() -> Dictionary:
	return {"arrived_at_location" : true, "player_found" : true}


func _get_effects() -> Dictionary:
	return {"player_alive" : true}


func _perform(_actor, _delta) -> bool:
	Player.instance.health_component.gain_health(3)
	return true
