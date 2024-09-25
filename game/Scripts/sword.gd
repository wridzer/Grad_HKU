class_name Weapon
extends Node

@onready var pivot: Node2D = $Pivot
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	input_manager.attack.connect(attack)
	toggle_sword(false)


func attack() -> void:
	toggle_sword(true)
	animation_player.play("slash")


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	toggle_sword(false)


func toggle_sword(on : bool) -> void:
	pivot.visible = on
	pivot.set_process_mode(Node.PROCESS_MODE_INHERIT if on else Node.PROCESS_MODE_DISABLED)
