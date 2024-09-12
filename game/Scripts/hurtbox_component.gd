class_name HurtboxComponent
extends Area2D

@export var health : HealthComponent


func _on_area_entered(hitbox: HitboxComponent) -> void:
	if hitbox == null:
		return
