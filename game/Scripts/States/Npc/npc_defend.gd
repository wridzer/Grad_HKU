class_name NpcDefend
extends NpcState


const STATE_TYPE = StateType.DEFEND


func get_state_type() -> int:
	return state_type_to_int(STATE_TYPE)


func enter(previous_state: int, data := {}) -> void:
	game_manager.switch_level_cleanup.connect(cleanup)
	
	npc.health_component.die.connect(die)
	
	super.enter(previous_state, data)


func physics_update(_delta: float) -> void:
	npc.velocity = Vector2.ZERO
	# DEFEND WITH SHIELD
	super.physics_update(_delta)


func exit() -> void:
	game_manager.switch_level_cleanup.disconnect(cleanup)
	
	npc.health_component.die.disconnect(die)
	
	super.exit()


func die() -> void:
	npc.die()


func cleanup() -> void:
	die()
