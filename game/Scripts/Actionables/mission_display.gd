extends Node2D


@export var _mission_dialogue: DialogueResource
@export var _exclamation_mark_sprite: Sprite2D

@onready var _actionable: Actionable = $Actionable


func _ready() -> void:
	_actionable.action.connect(_activate_display)
	game_manager.exclamation_marks_visibile += 1


func _activate_display() -> void:
	if _exclamation_mark_sprite.visible:
		game_manager.exclamation_marks_visibile -= 1
	_exclamation_mark_sprite.visible = false
	if game_manager.night_time:
		Player.instance.mission_report.do_mission_report()
	else:
		dialogue_manager.start_dialogue(_mission_dialogue)
