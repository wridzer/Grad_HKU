class_name HurtboxComponent
extends Area2D


@export var _health_component: HealthComponent


func _ready() -> void:
	assert(is_instance_valid(_health_component), "Please assign a valid _health_component to HurtboxComponent")


func _on_area_entered(hitbox: Area2D) -> void:
	if !is_instance_valid(hitbox as HitboxComponent):
		return
	
	_health_component.take_damage(hitbox.damage)
	hitbox.hit.emit()
