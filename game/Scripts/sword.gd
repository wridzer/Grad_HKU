class_name Weapon
extends Node

@onready var pivot: Node2D = $Pivot
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	input_manager.attack.connect(attack)


func attack() -> void:
	pivot.set_process_mode(Node.PROCESS_MODE_INHERIT)
	pivot.visible = true
	animation_player.play("slash")


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	pivot.visible = false
	pivot.set_process_mode(Node.PROCESS_MODE_DISABLED)
