class_name ChillAction
extends GoapAction


func _is_valid() -> bool:
	return true


func _get_cost() -> int:
	return 1


func _get_action_name() -> StringName:
	return "chill_action"


func _get_preconditions() -> Dictionary:
	return {}


func _get_effects() -> Dictionary:
	return {"idle" : true}


func _perform(_actor, _delta) -> bool:
	# Never complete performing idling
	return false


func _perform_physics(actor, _delta) -> bool:
	var npc = actor as Npc
	npc.velocity = Vector2.ZERO
	return false
