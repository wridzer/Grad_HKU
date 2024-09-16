class_name Weapon
extends Node

@onready var pivot: Node2D = $Pivot
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	input_manager.attack.connect(attack)


func attack() -> void:
	pivot.visible = true
	animation_player.play("slash")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pivot.visible = false
