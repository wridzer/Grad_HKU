class_name EnemyState
extends State


enum StateType {INVALID, IDLE, CHASE}

var enemy: Enemy


func _ready() -> void:
	await owner.ready
	enemy = owner as Enemy


func physics_update(_delta: float) -> void:
	enemy.move_and_slide()
	super.physics_update(_delta)
	

func get_state_type() -> int:
	return state_type_to_int(StateType.INVALID)


func string_to_state_type(state: int) -> StateType:
	return StateType.find_key(state)


func state_type_to_int(state: StateType) -> int:
	return int(state)