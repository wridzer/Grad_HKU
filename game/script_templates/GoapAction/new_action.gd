extends GoapAction


func _is_valid() -> bool:
	return false


func _get_cost() -> int:
	return 1


func _get_action_name() -> StringName:
	return ""


func _get_preconditions() -> Dictionary:
	return {}


func _get_effects() -> Dictionary:
	return {}


func _perform(actor, _delta) -> bool:
	var npc = actor as Npc
	return false


func _perform_physics(actor, _delta) -> bool:
	var npc = actor as Npc
	return false
