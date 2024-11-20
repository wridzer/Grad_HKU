class_name HurtboxComponent
extends Area2D


@export var health: HealthComponent


func _ready() -> void:
	assert(is_instance_valid(health), "Please assign a valid HealthComponent to HurtboxComponent")


func _on_area_entered(hitbox: HitboxComponent) -> void:
	if hitbox == null:
		return
	
	health.take_damage(hitbox.damage)
