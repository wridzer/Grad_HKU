class_name Enemy
extends CharacterBody2D


@onready var health_component: HealthComponent = $HealthComponent
@onready var state_machine: StateMachine = $StateMachine


func _ready() -> void:
	health_component.die.connect(die)
	health_component.hit.connect(hit)


func die() -> void:
	queue_free()


func hit() -> void:
	pass
