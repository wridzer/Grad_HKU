class_name Actionable
extends Area2D


# This signal is emitted from other scripts
@warning_ignore("unused_signal")
signal action

@export var actionable_priority: int = 0
@export var animated_sprite: AnimatedSprite2D


func highlight() -> void:
	animated_sprite.play("highlighted")


func stop_highlight() -> void:
	animated_sprite.play("idle")
