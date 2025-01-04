class_name HealthComponent
extends Node


@export var _max_health: int = 3
@export var health: int = _max_health
@export var _immunity_length: float = .5

signal die
signal health_gained
signal immunity(immune: bool)

@onready var _immunity_timer := $ImmunityTimer


func _ready() -> void:
	_immunity_timer.wait_time = _immunity_length


func gain_health(amount: int) -> void:
	if health + amount >= _max_health:
		health = _max_health
	else:
		health += amount
	
	health_gained.emit()


func take_damage(amount: int) -> void:
	if !immune():
		health -= amount
		
		if health <= 0:
			die.emit()
			return
		
		immunity.emit(true)
		_immunity_timer.start()


func reset_health(blackboard_prefix: String) -> void:
	health = _max_health
	health_gained.emit()


func _on_immunity_timer_timeout() -> void:
	# Be able to take damage again
	immunity.emit(false)
	_immunity_timer.stop()


func immune() -> bool:
	return _immunity_timer.time_left != 0


func set_health_blackboard_variables(blackboard_prefix: String) -> void:
	Blackboard.add_data(blackboard_prefix + "_max_health", _max_health)
	Blackboard.add_data(blackboard_prefix + "_health", health)
