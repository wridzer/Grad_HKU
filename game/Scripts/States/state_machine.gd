class_name StateMachine
extends Node


@export var _initial_state: State = null

@onready var _state: State = (func get_initial_state() -> State:
	return _initial_state if _initial_state != null else get_child(0)
).call()


func _ready() -> void:
	for state_node: State in find_children("*", "State"):
		state_node.finished.connect(transition_to_next_state)

	await owner.ready
	_state.enter(0)


func _process(delta: float) -> void:
	_state.update(delta)


func _physics_process(delta: float) -> void:
	_state.physics_update(delta)
	

func transition_to_next_state(target_state: int, data: Dictionary = {}) -> void:
	for state_node: State in find_children("*", "State"):
		if state_node.get_state_type() == target_state:
			_state.exit()
			
			var previous_state := _state
			_state = state_node
			_state.enter(previous_state.get_state_type(), data)
			
			return
	
	printerr(owner.name + ": Trying to transition to state " + str(target_state) + " but it does not exist.")
