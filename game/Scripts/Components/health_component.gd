class_name HealthComponent
extends Node

@onready var timer := $ImmunityTimer

@export var health: int
@export var maxHealth: int = 3
@export var immunityLength: float = .5
@export var animated_sprite_2d: AnimatedSprite2D

var immune := false
signal die
signal hit


func _ready() -> void:
	timer.wait_time = immunityLength


func gain_health(amount: int) -> void:
	if health + amount >= maxHealth:
		health = maxHealth
	else:
		health += amount


func take_damage(amount: int) -> void:
	print(amount)
	if !immune:
		health -= amount
		if health <= 0:
			die.emit()
			return
		immune = true
		timer.start()
	
	if is_instance_valid(animated_sprite_2d):
		animated_sprite_2d.play("hit")
		
	hit.emit()


func _on_immunity_timer_timeout() -> void:
	# Be able to take damage again
	immune = false
	
	if is_instance_valid(animated_sprite_2d):
		if animated_sprite_2d.animation == "hit":
			animated_sprite_2d.play("idle")
	
	timer.stop()
