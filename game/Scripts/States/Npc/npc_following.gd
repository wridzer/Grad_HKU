class_name NpcFollowing
extends NpcState


const STATE_TYPE = StateType.FOLLOWING
const FOLLOW_DISTANCE := 15.0
const FOLLOW_SPEED := 2500.0


func get_state_type() -> String:
	return state_type_to_string(STATE_TYPE)


func enter(previous_state: String, data := {}) -> void:
	game_manager.npc_stop_following.connect(stop_following)
	super.enter(previous_state, data)


func physics_update(delta: float) -> void:
	npc.set_velocity(Vector2.ZERO)
	
	var player_pos: Vector2 = Player.instance.get_global_position()
	var npc_pos: Vector2 = npc.get_global_position()
	
	if npc_pos.distance_to(player_pos) > FOLLOW_DISTANCE:
		var target_pos: Vector2 = (player_pos - npc_pos).normalized()
		npc.set_velocity(target_pos * FOLLOW_SPEED * delta)
	npc.look_at(player_pos)
	
	super.physics_update(delta)


func stop_following() -> void:
	if npc.is_talking && Player.instance.following_npc == npc:
		finished.emit(state_type_to_string(StateType.IDLE))


func exit() -> void:
	Player.instance.following_npc = null
	game_manager.npc_stop_following.disconnect(stop_following)
	super.exit()
