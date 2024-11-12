class_name HealthComponent
extends Node

@onready var timer := $ImmunityTimer

@export var health: int
@export var maxHealth: int = 3
@export var immunityLength: float = .5

signal die
signal immune


func _ready() -> void:
	timer.wait_time = immunityLength


func gain_health(amount: int) -> void:
	if health + amount >= maxHealth:
		health = maxHealth
	else:
		health += amount


func take_damage(amount: int) -> void:
	if !immune:
		health -= amount
		if health <= 0:
			die.emit()
			return
		immune.emit(true)
		timer.start()


func _on_immunity_timer_timeout() -> void:
	# Be able to take damage again
	immune.emit(false)
	
	timer.stop()
