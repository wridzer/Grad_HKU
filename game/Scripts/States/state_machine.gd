class_name StateMachine
extends Node


@export var initial_state: State = null

@onready var state: State = (func get_initial_state() -> State:
	return initial_state if initial_state != null else get_child(0)
).call()


func _ready() -> void:
	for state_node: State in find_children("*", "State"):
		state_node.finished.connect(_transition_to_next_state)

	await owner.ready
	state.enter(0)


func _process(delta: float) -> void:
	state.update(delta)


func _physics_process(delta: float) -> void:
	state.physics_update(delta)


func _transition_to_next_state(target_state: int, data: Dictionary = {}) -> void:
	for state_node: State in find_children("*", "State"):
		if state_node.get_state_type() == target_state:
			state.exit()
			
			var previous_state := state
			state = state_node
			state.enter(previous_state.get_state_type(), data)
			
			return
	
	printerr(owner.name + ": Trying to transition to state " + str(target_state) + " but it does not exist.")
