class_name NpcGoap
extends NpcState


const STATE_TYPE = StateType.GOAP


func get_state_type() -> int:
	return state_type_to_int(STATE_TYPE)


func enter(previous_state: int, data := {}) -> void:
	npc.actionable.action.connect(dialogue_manager.start_dialogue.bind(npc.dungeon_dialogue, npc.display_name + "_dungeon"))
	
	game_manager.spawn.connect(spawn)
	game_manager.toggle_goap.connect(disable_goap)
	
	npc.immunity(false)
	
	super.enter(previous_state, data)


func update(delta):
	npc.goap_agent.execute(delta, npc, GoapPlanner)


func physics_update(delta: float) -> void:
	npc.goap_agent.physics_update(delta, npc)


func exit() -> void:
	npc.actionable.action.disconnect(dialogue_manager.start_dialogue)
	
	game_manager.spawn.disconnect(spawn)
	game_manager.toggle_goap.disconnect(disable_goap)
	
	npc.immunity(true)
	
	super.exit()


func spawn(spawn_pos: Vector2, npc_offset: Vector2) -> void:
	npc.saved_spawn_pos = spawn_pos
	npc.position = spawn_pos + npc_offset


func disable_goap() -> void:
	finished.emit(state_type_to_int(StateType.FOLLOWING))
