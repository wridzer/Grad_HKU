class_name NpcDowned
extends NpcState


const STATE_TYPE = StateType.DOWNED


func get_state_type() -> int:
	return state_type_to_int(STATE_TYPE)


func enter(previous_state: int, data := {}) -> void:
	npc.actionable.action.connect(revive)
	game_manager.toggle_goap.connect(disable_goap)
	
	super.enter(previous_state, data)


func update(delta):
	npc.goap_agent.execute(delta, npc, GoapPlanner)


func physics_update(delta: float) -> void:
	if is_equal_approx(npc.velocity.length_squared(), 0):
		return
	
	var slowdown = min(delta / npc.stop_time, 1.0)
	npc.set_velocity(npc.velocity - npc.velocity * slowdown)
	super.physics_update(delta)


func exit() -> void:
	game_manager.toggle_goap.disconnect(disable_goap)
	npc.actionable.action.disconnect(revive)
	super.exit()


func disable_goap() -> void:
	finished.emit(state_type_to_int(StateType.FOLLOWING))


func revive() -> void:
	npc.health_component.reset_health()
	npc.state_machine.transition_to_next_state(state_type_to_int(StateType.GOAP))
