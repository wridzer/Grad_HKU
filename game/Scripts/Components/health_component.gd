class_name HealthComponent
extends Node

@export var health: int
@export var maxHealth: int = 3
@onready var timer := $ImmunityTimer
var immune := false
signal die
@export var animated_sprite_2d: AnimatedSprite2D


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
	
	if is_instance_valid(animated_sprite_2d):
		animated_sprite_2d.play("hit")


func _on_immunity_timer_timeout() -> void:
	# Be able to take damage again
	immune = false
	
	if is_instance_valid(animated_sprite_2d):
		if animated_sprite_2d.animation == "hit":	
			animated_sprite_2d.play("idle")
	
	timer.stop()
