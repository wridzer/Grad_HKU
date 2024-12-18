class_name NpcGoap
extends NpcState


const STATE_TYPE = StateType.GOAP
const FOLLOW_DISTANCE := 15.0
const FOLLOW_SPEED := 60.0


func get_state_type() -> int:
	return state_type_to_int(STATE_TYPE)


func enter(previous_state: int, data := {}) -> void:
	game_manager.spawn.connect(spawn)
	game_manager.toggle_goap.connect(disable_goap)
	
	if Blackboard.get_data("usage_percent_sword_shield_bow"):
		var player_usage: Array[Vector3] = Blackboard.get_data("usage_percent_sword_shield_bow")
		match npc._adapatable_combat:
			0:
				var base_priority = npc._slash_priority
				Blackboard.add_data("slash_priority", base_priority + (player_usage[-1].x * 0.5))
			1:
				var base_priority = npc._block_priority
				Blackboard.add_data("block_priority", base_priority + (player_usage[-1].y * 0.5))
			2:
				var base_priority = npc._shoot_priority
				Blackboard.add_data("shoot_priority", base_priority + (player_usage[-1].z * 0.5))
	
	super.enter(previous_state, data)


func update(delta):
	npc.goap_agent.execute(delta, npc, GoapPlanner)


func physics_update(delta: float) -> void:
	npc.goap_agent.physics_update(delta, npc)


func exit() -> void:
	game_manager.spawn.disconnect(spawn)
	game_manager.toggle_goap.disconnect(disable_goap)
	
	super.exit()


func spawn(spawn_pos: Vector2, npc_offset: Vector2) -> void:
	npc.saved_spawn_pos = spawn_pos
	npc.position = spawn_pos + npc_offset


func disable_goap() -> void:
	finished.emit(state_type_to_int(StateType.FOLLOWING))


static func is_bool_and_true(x: Variant) -> bool:
	if !is_instance_valid(x):
		if x:
			return true
		return false
	
	# Impossible to reach with bool
	return false
