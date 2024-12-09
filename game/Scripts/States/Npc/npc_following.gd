class_name NpcFollowing
extends NpcState


const STATE_TYPE = StateType.FOLLOWING
const FOLLOW_DISTANCE := 15.0
const FOLLOW_SPEED := 60.0

@export var GOAP_ON : bool = false

func get_state_type() -> int:
	return state_type_to_int(STATE_TYPE)


func enter(previous_state: int, data := {}) -> void:
	npc.actionable.action.connect(dialogue_manager.start_dialogue.bind(npc.following_dialogue))
	
	game_manager.npc_stop_following.connect(stop_following)
	game_manager.spawn.connect(spawn)
	
	super.enter(previous_state, data)

func _process(delta):
	if GOAP_ON:
		$"../../GoapAgent".execute(delta, self, $"../../Goap")

func physics_update(delta: float) -> void:
	if !GOAP_ON:
		npc.set_velocity(Vector2.ZERO)
		
		var player_pos: Vector2 = Player.instance.get_global_position()
		var npc_pos: Vector2 = npc.get_global_position()
		
		if npc_pos.distance_to(player_pos) > FOLLOW_DISTANCE:
			var target_pos: Vector2 = (player_pos - npc_pos).normalized()
			# TODO: npc animations
			npc.direction = target_pos
			npc.set_velocity(target_pos * FOLLOW_SPEED)
		npc.look_at(player_pos)
		
		super.physics_update(delta)


func exit() -> void:
	Player.instance.following_npc = null
	
	npc.actionable.action.disconnect(dialogue_manager.start_dialogue)
	
	game_manager.npc_stop_following.disconnect(stop_following)
	game_manager.spawn.disconnect(spawn)
	
	super.exit()


func stop_following(display_name: String) -> void:
	if display_name == npc.display_name && Player.instance.following_npc == npc:
		finished.emit(state_type_to_int(StateType.IDLE))


func spawn(spawn_pos: Vector2, npc_offset: Vector2) -> void:
	npc.saved_spawn_pos = spawn_pos
	npc.position = spawn_pos + npc_offset
