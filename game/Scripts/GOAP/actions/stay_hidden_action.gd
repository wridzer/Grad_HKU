extends GoapAction


func _is_valid() -> bool:
	return true


func _get_cost() -> int:
	return 1


func _get_action_name() -> StringName:
	return "stay_hidden"


func _get_preconditions() -> Dictionary:
	return { "actionable_activated" : true, "found_hiding_spot" : true}


func _get_effects() -> Dictionary:
	return {"hidden" : true}


func _perform(actor, _delta) -> bool:
	var npc = actor as Npc
	
	if Player.instance.room.enemies.size() <= 0:
		npc.toggle_hide(false)
		return true
	
	if npc.health_component.health >= npc._desired_health:
		npc.toggle_hide(false)
		return true
		
	npc.velocity = Vector2.ZERO
	return false
