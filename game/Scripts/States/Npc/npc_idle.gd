class_name NpcIdle
extends NpcState


const STATE_TYPE = StateType.IDLE


func get_state_type() -> int:
	return state_type_to_int(STATE_TYPE)


func enter(previous_state: int, data := {}) -> void:
	npc.actionable.action.connect(start_dialogue)
	
	game_manager.npc_follow.connect(follow)
	game_manager.switch_level_cleanup.connect(cleanup)
	
	npc.health_component.die.connect(die)
	
	super.enter(previous_state, data)


func physics_update(_delta: float) -> void:
	npc.velocity = Vector2.ZERO
	super.physics_update(_delta)


func start_dialogue() -> void:
	input_manager.toggle_input(false)
	DialogueManager.show_dialogue_balloon(npc.idle_dialogue)
	super.start_dialogue()


func exit() -> void:
	npc.actionable.action.disconnect(start_dialogue)
	
	game_manager.npc_follow.disconnect(follow)
	game_manager.switch_level_cleanup.disconnect(cleanup)
	
	npc.health_component.die.disconnect(die)
	
	super.exit()


func follow() -> void:
	if npc.is_talking:
		if !Player.instance.following_npc:
			Player.instance.following_npc = npc
			finished.emit(state_type_to_int(StateType.FOLLOWING))
		else:
			input_manager.toggle_input(false)
			DialogueManager.show_dialogue_balloon(npc.idle_dialogue, "already_following")


func die() -> void:
	npc.die()


func cleanup() -> void:
	die()
