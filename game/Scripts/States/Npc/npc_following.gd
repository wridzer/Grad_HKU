class_name NpcFollowing
extends NpcState


const STATE_TYPE = StateType.FOLLOWING
const FOLLOW_DISTANCE := 15.0
const FOLLOW_SPEED := 60.0


func get_state_type() -> int:
	return state_type_to_int(STATE_TYPE)


func enter(previous_state: int, data := {}) -> void:
	npc.actionable.action.connect(dialogue_manager.start_dialogue.bind(npc.following_dialogue))
	
	game_manager.npc_stop_following.connect(stop_following)
	game_manager.toggle_goap.connect(activate_goap)
	game_manager.spawn.connect(spawn)
	
	super.enter(previous_state, data)


func physics_update(delta: float) -> void:
	npc.set_velocity(Vector2.ZERO)
	
	var player_pos: Vector2 = Player.instance.get_global_position()
	var npc_pos: Vector2 = npc.get_global_position()
	var distance_squared = npc_pos.distance_squared_to(player_pos)
	
	# TODO: npc animations
	if distance_squared > npc.follow_distance_squared:
		var direction: Vector2 = (player_pos - npc_pos).normalized()
		npc.direction = direction
		npc.set_velocity(direction * FOLLOW_SPEED)
	elif distance_squared < npc.follow_distance_squared / 2:
		var direction: Vector2 = (npc_pos - player_pos).normalized()
		npc.direction = direction
		npc.set_velocity(direction * FOLLOW_SPEED)
		
	npc.look_at(player_pos)
	
	super.physics_update(delta)


func exit() -> void:
	npc.actionable.action.disconnect(dialogue_manager.start_dialogue)
	
	game_manager.toggle_goap.disconnect(activate_goap)
	game_manager.npc_stop_following.disconnect(stop_following)
	game_manager.spawn.disconnect(spawn)
	
	super.exit()


func stop_following(display_name: String) -> void:
	if display_name == npc.display_name:
		Blackboard.remove_data("npc")
		finished.emit(state_type_to_int(StateType.IDLE))


func spawn(spawn_pos: Vector2, npc_offset: Vector2) -> void:
	npc.saved_spawn_pos = spawn_pos
	npc.position = spawn_pos + npc_offset


func activate_goap() -> void:
	var data = Blackboard.get_data("npc")
	if is_instance_valid(data):
		var blackboard_npc: Npc = data
		if npc == blackboard_npc:
			finished.emit(state_type_to_int(StateType.GOAP))
