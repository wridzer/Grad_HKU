class_name HealthComponent
extends Node

@export var health : int


func take_damage():
	health -= 1
