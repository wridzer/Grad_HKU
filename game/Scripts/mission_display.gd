extends Node2D


@onready var actionable: Area2D = $Actionable

@export var mission_dialogue: DialogueResource


func _ready() -> void:
	actionable.action.connect(activate_display)


func activate_display() -> void:
	dialogue_manager.start_dialogue(mission_dialogue)
