class_name HealthComponent
extends Node

@export var health: int
@export var maxHealth: int = 3
@onready var timer := $ImmunityTimer
var immune := false
signal die


func gain_health(amount: int):
	if health + amount >= maxHealth:
		health = maxHealth
	else:
		health += amount


func take_damage(amount: int):
	if !immune:
		health -= amount
		if health <= 0:
			die.emit()
		immune = true
		timer.start()


func _on_immunity_timer_timeout() -> void:
	# Be able to take damage again
	immune = false
	timer.stop()
