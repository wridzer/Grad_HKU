extends Node2D


@export var _mission_dialogue: DialogueResource

@onready var _actionable: Area2D = $Actionable
@onready var _exlamation_mark_sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	_actionable.action.connect(_activate_display)


func _activate_display() -> void:
	_exlamation_mark_sprite.visible = false
	dialogue_manager.start_dialogue(_mission_dialogue)
