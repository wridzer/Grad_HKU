class_name NpcAttack
extends NpcState


const STATE_TYPE = StateType.INVALID


func get_state_type() -> int:
	return state_type_to_int(STATE_TYPE)


func enter(previous_state: int, data := {}) -> void:
	game_manager.switch_level_cleanup.connect(cleanup)
	
	super.enter(previous_state, data)


func physics_update(_delta: float) -> void:
	npc.velocity = Vector2.ZERO
	# ATTACK WITH SWORD
	super.physics_update(_delta)


func exit() -> void:
	game_manager.switch_level_cleanup.disconnect(cleanup)
	
	super.exit()


func cleanup() -> void:
	npc.die()
