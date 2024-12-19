class_name HitboxComponent
extends Area2D


enum HitboxType {SWORD, SHIELD, ARROW, ENEMY}

@export var hitbox_type: HitboxType
@export var damage: int

# Signal emitted from hurtbox
@warning_ignore("unused_signal") signal hit
