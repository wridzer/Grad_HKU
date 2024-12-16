class_name NpcGoap
extends NpcState


const STATE_TYPE = StateType.GOAP
const FOLLOW_DISTANCE := 15.0
const FOLLOW_SPEED := 60.0


func get_state_type() -> int:
	return state_type_to_int(STATE_TYPE)


func enter(previous_state: int, data := {}) -> void:
	npc.actionable.action.connect(dialogue_manager.start_dialogue.bind(npc.following_dialogue))
	
	game_manager.spawn.connect(spawn)
	
	super.enter(previous_state, data)


func update(delta):
	npc.goap_agent.execute(delta, npc, GoapPlanner)


func physics_update(delta: float) -> void:
	npc.goap_agent.physics_update(delta, npc)


func exit() -> void:
	npc.actionable.action.disconnect(dialogue_manager.start_dialogue)
	
	game_manager.spawn.disconnect(spawn)
	
	super.exit()


func spawn(spawn_pos: Vector2, npc_offset: Vector2) -> void:
	npc.saved_spawn_pos = spawn_pos
	npc.position = spawn_pos + npc_offset
