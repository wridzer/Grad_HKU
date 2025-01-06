extends Node2D


@export var _mission_dialogue: DialogueResource
@export var _exlamation_mark_sprite: Sprite2D

@onready var _actionable: Area2D = $Actionable


func _ready() -> void:
	_actionable.action.connect(_activate_display)


func _activate_display() -> void:
	_exlamation_mark_sprite.visible = false
	dialogue_manager.start_dialogue(_mission_dialogue)
