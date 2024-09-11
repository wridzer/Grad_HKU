extends Area2D

@onready var timer := $Timer

func _on_body_entered(_body: Node2D) -> void:
	timer.start()


func _on_body_exited(_body: Node2D) -> void:
	timer.stop()


func _on_timer_timeout() -> void:
	# Add the level to load under "Level" to the scene tree
	#get_parent().get_parent().add_child(level_to_load.instantiate())
	get_parent().queue_free()
	
	# Get the new level's spawn point location and emit a signal to spawn player there
	game_manager.emit_signal("get_spawn_location")
