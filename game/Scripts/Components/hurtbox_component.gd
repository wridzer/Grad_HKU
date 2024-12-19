class_name HurtboxComponent
extends Area2D


signal hurt(knockback_direction: Vector2, hitbox_type: HitboxComponent.HitboxType)

@export var _health_component: HealthComponent


func _ready() -> void:
	assert(is_instance_valid(_health_component), "Please assign a valid _health_component to HurtboxComponent")


func _on_area_entered(hitbox: Area2D) -> void:
	if !is_instance_valid(hitbox as HitboxComponent):
		return
	
	var knockback_direction: Vector2 = global_position - hitbox.global_position
	hurt.emit(knockback_direction, hitbox.hitbox_type)
	
	hitbox.hit.emit()
	_health_component.take_damage(hitbox.damage)
