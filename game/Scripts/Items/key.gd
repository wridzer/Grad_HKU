class_name Key
extends Node2D


@onready var _actionable: Area2D = $Actionable


func _ready() -> void:
	_actionable.action.connect(_pickup)


func _pickup() -> void:
	# Dialogue how much keys are left
	#dialogue_manager.start_dialogue(null)
	
	queue_free()
