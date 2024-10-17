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
	var level_parent = get_parent().get_parent()
	
	# Bring following npc with you when warping
	if Player.instance.following_npc:
		Player.instance.following_npc.get_parent().remove_child(Player.instance.following_npc)
		level_parent.get_parent().add_child(Player.instance.following_npc)
	
	# Remove leftover npc's
	game_manager.switch_level_cleanup.emit()
	
	# Add the level to load under "Level" to the scene tree
	var scene = ResourceLoader.load(level_to_load, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE)
	level_parent.add_child(scene.instantiate())
	get_parent().queue_free()
	
	# Update utilities
	if(level_to_load == "res://Scenes/smith_level1.tscn"):
		Blackboard.save_data()
		UtilitySystem.instance.calculate()
		UtilitySystem.instance.reset_values()
	
	# Get the new level's spawn point location and emit a signal to spawn player (and following npc) there
	game_manager.get_spawn_location.emit()
	timer.stop()
