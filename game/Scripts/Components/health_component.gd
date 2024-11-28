class_name HealthComponent
extends Node


@export var _health: int
@export var _max_health: int = 3
@export var _immunity_length: float = .5

signal die
signal immune

@onready var _immunity_timer := $ImmunityTimer


func _ready() -> void:
	_immunity_timer.wait_time = _immunity_length


func gain_health(amount: int) -> void:
	if _health + amount >= _max_health:
		_health = _max_health
	else:
		_health += amount


func take_damage(amount: int) -> void:
	if _immunity_timer.time_left == 0:
		_health -= amount
		if _health <= 0:
			die.emit()
			return
		immune.emit(true)
		_immunity_timer.start()


func _on__immunity_timer_timeout() -> void:
	# Be able to take damage again
	immune.emit(false)
	
	_immunity_timer.stop()
