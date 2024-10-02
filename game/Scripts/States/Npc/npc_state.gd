class_name NpcState
extends State


enum StateType {INVALID, IDLE, FOLLOWING}

var npc: Npc


func _ready() -> void:
	await owner.ready
	npc = owner as Npc


func physics_update(_delta: float) -> void:
	npc.move_and_slide()
	super.physics_update(_delta)


func get_state_type() -> String:
	return state_type_to_string(StateType.INVALID)


func string_to_state_type(state: String) -> StateType:
	return StateType.find_key(state)


func state_type_to_string(state: StateType) -> String:
	return str(state)
