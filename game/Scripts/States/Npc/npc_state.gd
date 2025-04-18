class_name NpcState
extends State


enum StateType {INVALID, IDLE, FOLLOWING, GOAP, DOWNED}

var npc: Npc


func _ready() -> void:
	await owner.ready
	npc = owner as Npc


func physics_update(_delta: float) -> void:
	npc.move_and_slide()
	super.physics_update(_delta)


func get_state_type() -> int:
	return state_type_to_int(StateType.INVALID)


func string_to_state_type(state: int) -> StateType:
	return StateType.find_key(state)


static func state_type_to_int(state: StateType) -> int:
	return int(state)
