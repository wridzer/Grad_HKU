class_name NpcIdle
extends NpcState


const STATE_TYPE = StateType.IDLE


func get_state_type() -> int:
	return state_type_to_int(STATE_TYPE)


func enter(previous_state: int, data := {}) -> void:
	npc.actionable.action.connect(dialogue_manager.start_dialogue.bind(npc.idle_dialogue))
	
	game_manager.npc_follow.connect(follow)
	game_manager.switch_level_cleanup.connect(npc.die)
	
	super.enter(previous_state, data)


func physics_update(_delta: float) -> void:
	npc.velocity = Vector2.ZERO
	super.physics_update(_delta)


func exit() -> void:
	npc.actionable.action.disconnect(dialogue_manager.start_dialogue)
	
	game_manager.npc_follow.disconnect(follow)
	game_manager.switch_level_cleanup.disconnect(npc.die)
	
	super.exit()


func follow(display_name: String) -> void:
	if display_name == npc.display_name:
		if !Player.instance.following_npc:
			Player.instance.following_npc = npc
			finished.emit(state_type_to_int(StateType.FOLLOWING))
			
			npc.choose()
		else:
			dialogue_manager.start_dialogue(npc.idle_dialogue, "already_following")
