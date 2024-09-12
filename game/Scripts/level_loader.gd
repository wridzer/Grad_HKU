extends Area2D

@onready var timer := $Timer
@export_file var level_to_load : String


func _on_body_entered(_body: Node2D) -> void:
	timer.start()


func _on_body_exited(_body: Node2D) -> void:
	timer.stop()


func _on_timer_timeout() -> void:
	# Add the level to load under "Level" to the scene tree
	
	var scene = ResourceLoader.load(level_to_load, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE)
	get_parent().get_parent().add_child(scene.instantiate())
	get_parent().queue_free()
	
	# Get the new level's spawn point location and emit a signal to spawn player there
	game_manager.get_spawn_location.emit()
