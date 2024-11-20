extends Area2D


@onready var timer := $Timer
@export_file var level_to_load: String


func _on_body_entered(player: Player) -> void:
	if player != null:
		timer.start()


func _on_body_exited(player: Player) -> void:
	if player != null && timer.time_left != 0:
		timer.stop()


func _on_timer_timeout() -> void:
	game_manager.load_level(level_to_load)
	timer.stop()
