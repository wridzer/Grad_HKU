class_name FindEnemyAction
extends GoapAction


func _is_valid() -> bool:
	if is_instance_valid(Player.instance.room):
		return Player.instance.room.enemies.size() > 0
	else:
		return false


func _get_cost() -> int:
	return 0


func _get_action_name() -> StringName:
	return "find_enemy_action"


func _get_preconditions() -> Dictionary:
	return {"found_enemy" : false}


func _get_effects() -> Dictionary:
	return {"found_enemy" : true}


func _perform(_actor, _delta) -> bool:
	var enemy: Enemy = Player.instance.room.enemies.pick_random()
	Blackboard.add_data("enemy", enemy)
	return true
