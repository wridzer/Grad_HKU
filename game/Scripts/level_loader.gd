extends Area2D


@export_file var _level_to_load: String

@onready var _timer := $Timer


func _on_body_entered(player: Player) -> void:
	if player != null:
		_timer.start()


func _on_body_exited(player: Player) -> void:
	if player != null && _timer.time_left != 0:
		_timer.stop()


func _on_timer_timeout() -> void:
	game_manager.load_level(_level_to_load)
	_timer.stop()
