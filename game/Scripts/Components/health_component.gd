class_name HealthComponent
extends Node


@export var health: int
@export var _max_health: int = 3
@export var _immunity_length: float = .5

signal die
signal health_gained
signal immune

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
	if _immunity_timer.time_left == 0:
		health -= amount
		
		if health <= 0:
			die.emit()
			return
		immune.emit(true)
		_immunity_timer.start()


func _on_immunity_timer_timeout() -> void:
	# Be able to take damage again
	immune.emit(false)
	
	_immunity_timer.stop()


func set_health_blackboard_variables(blackboard_prefix: String) -> void:
	Blackboard.add_data(blackboard_prefix + "_max_health", _max_health)
	Blackboard.add_data(blackboard_prefix + "_health", health)
