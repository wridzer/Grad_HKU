class_name State
extends Node


signal finished(next_state: String, data: Dictionary)


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func enter(previous_state: String, data := {}) -> void:
	pass


func exit() -> void:
	pass


func get_state_type() -> String:
	return "INVALID"
