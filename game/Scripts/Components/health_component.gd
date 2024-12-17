class_name HealthComponent
extends Node


@export var health: int
@export var _max_health: int = 3
@export var _immunity_length: float = .5
var _owner: String = ""

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
	
	if _owner != "enemy":
		Blackboard.add_data(_owner + "_health", health)
	health_gained.emit()


func take_damage(amount: int) -> void:
	if _immunity_timer.time_left == 0:
		health -= amount
		
		if health <= 0:
			die.emit()
			return
		immune.emit(true)
		_immunity_timer.start()
		
		if _owner != "enemy":
			Blackboard.add_data(_owner + "_health", health)
			Blackboard.increment_data(_owner + "_damage_taken", 1)


func _on_immunity_timer_timeout() -> void:
	# Be able to take damage again
	immune.emit(false)
	
	_immunity_timer.stop()


func set_blackboard_variables() -> void:
	if _owner != "enemy":
		Blackboard.add_data(_owner + "_max_health", _max_health)
		Blackboard.add_data(_owner + "_health", health)
