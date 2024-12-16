extends Area2D


@export_file var _level_to_load: String
@export var condition_failure_dialogue: DialogueResource

var condition: bool:
	get(): return is_instance_valid(Blackboard.get_data("npc")) && \
				  game_manager.mission_type != game_manager.MissionType.INVALID

@onready var _timer := $Timer


func _on_body_entered(player: Player) -> void:
	if is_instance_valid(player):
		if condition:
			_timer.start()
		else:
			dialogue_manager.start_dialogue(condition_failure_dialogue)


func _on_body_exited(player: Player) -> void:
	if is_instance_valid(player) && _timer.time_left != 0:
		_timer.stop()


func _on_timer_timeout() -> void:
	game_manager.load_level(_level_to_load)
	_timer.stop()
