extends Node2D


@export var _fireplace_dialogue: DialogueResource
@export var _exclamation_mark_sprite: Sprite2D

@onready var _actionable: Actionable = $Actionable


func _ready() -> void:
	game_manager.return_to_hub.connect(_toggle_fireplace_actionable.bind(true))
	game_manager.day_time.connect(_toggle_fireplace_actionable.bind(false))
	_actionable.action.connect(_interact_fireplace)
	_actionable.set_process_mode(PROCESS_MODE_DISABLED)


func _toggle_fireplace_actionable(enable: bool) -> void:
	# don't fireplace on day 1 or after any day after 2
	if game_manager.day == 1 || game_manager.day > 2:
		return
	
	if enable:
		game_manager.exclamation_marks_visibile += 1
	else:
		game_manager.exclamation_marks_visibile -= 1
	
	_exclamation_mark_sprite.visible = enable
	_actionable.set_process_mode(PROCESS_MODE_INHERIT if enable else PROCESS_MODE_DISABLED)


func _interact_fireplace() -> void:
	_toggle_fireplace_actionable(false)
	var data = Blackboard.get_data("npc")
	if is_instance_valid(data): # currently unused
		var npc: Npc = data
		if game_manager.night_time:
			if game_manager.day < 4: # There's currently no dialogue for day 4 or after
				dialogue_manager.start_dialogue(_fireplace_dialogue, npc.display_name, "day_" + str(game_manager.day) + "_" + npc.display_name)
			_actionable.set_process_mode(PROCESS_MODE_DISABLED)
	else:
		dialogue_manager.start_dialogue(_fireplace_dialogue, "", "no_npc")
