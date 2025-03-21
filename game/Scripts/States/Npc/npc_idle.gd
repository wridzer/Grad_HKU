class_name NpcIdle
extends NpcState


const STATE_TYPE = StateType.IDLE


func get_state_type() -> int:
	return state_type_to_int(STATE_TYPE)


func enter(previous_state: int, data := {}) -> void:
	npc.actionable.action.connect(start_dialogue)
	
	game_manager.npc_follow.connect(follow)
	game_manager.switch_level_cleanup.connect(die)
	
	super.enter(previous_state, data)


func physics_update(_delta: float) -> void:
	npc.velocity = Vector2.ZERO
	super.physics_update(_delta)


func exit() -> void:
	npc.actionable.action.disconnect(start_dialogue)
	
	game_manager.npc_follow.disconnect(follow)
	game_manager.switch_level_cleanup.disconnect(die)
	
	super.exit()


func follow(display_name: String) -> void:
	if display_name == npc.display_name:
		npc.choose()
		finished.emit(state_type_to_int(StateType.FOLLOWING))


func die() -> void:
	npc.die()


func start_dialogue() -> void:
	if game_manager.night_time:
		var playstyle: Array[String] = Blackboard.get_data("playstyle")
		dialogue_manager.start_dialogue(npc.idle_dialogue, npc.display_name, "start_night_" + playstyle[-1])
	else:
		dialogue_manager.start_dialogue(npc.idle_dialogue, npc.display_name)
