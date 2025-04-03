@tool
extends Area2D


@export_file var _level_to_load: String
@export var condition_failure_dialogue: DialogueResource

var condition: Callable = func() -> bool: 
	return is_instance_valid(Blackboard.get_data("npc")) && \
		   DungeonGenerator.mission_type != DungeonGenerator.MissionType.INVALID

@onready var _timer := $Timer


func _on_body_entered(player: Player) -> void:
	if is_instance_valid(player):
		if condition.call():
			_timer.start()
		elif is_instance_valid(condition_failure_dialogue):
			var time_context: String = "nighttime" if game_manager.night_time else ""
			dialogue_manager.start_dialogue(condition_failure_dialogue, "", time_context)
		else:
			print("no level loader condition_failure_dialogue")


func _on_body_exited(player: Player) -> void:
	if is_instance_valid(player) && _timer.time_left != 0:
		_timer.stop()


func _on_timer_timeout() -> void:
	Blackboard.add_data("mission_success", true)
	game_manager.load_level(_level_to_load)
	_timer.stop()
