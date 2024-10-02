class_name State
extends Node


@warning_ignore("unused_signal") signal finished(next_state: int, data: Dictionary)


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func enter(_previous_state: int, _data := {}) -> void:
	pass


func exit() -> void:
	pass


func get_state_type() -> int:
	return 0
