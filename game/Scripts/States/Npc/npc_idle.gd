class_name NpcIdle
extends NpcState


const STATE_TYPE = StateType.IDLE


func get_state_type() -> String:
	return state_type_to_string(STATE_TYPE)


func enter(previous_state: String, data := {}) -> void:
	game_manager.npc_follow.connect(follow)
	super.enter(previous_state, data)


func physics_update(_delta: float) -> void:
	npc.velocity = Vector2.ZERO
	super.physics_update(_delta)


func follow() -> void:
	if npc.is_talking:
		if !Player.instance.following_npc:
			Player.instance.following_npc = npc
			finished.emit(state_type_to_string(StateType.FOLLOWING))
		else:
			input_manager.toggle_input(false)
			DialogueManager.show_dialogue_balloon(npc.action_dialogue, "already_following")

func exit() -> void:
	game_manager.npc_follow.disconnect(follow)
	super.exit()
