extends Node


# These signals are emitted from other scripts, so the warning can be ignored
@warning_ignore("unused_signal") signal spawn(value: Vector2, offset: Vector2)
@warning_ignore("unused_signal") signal npc_follow(display_name: String)
@warning_ignore("unused_signal") signal npc_stop_following(display_name: String)
signal switch_level_cleanup
signal get_spawn_location

@export_file var level_hub: String
@export var level_parent: Node


func _ready() -> void:
	# Get the level parent node
	var main = get_tree().root.get_node("Main")
	if main and main.has_node("Level"):
		level_parent = main.get_node("Level")
	
	assert(is_instance_valid(level_parent), "Node \"Level\" not found in Main scene.")


func load_level(level_to_load: String = level_hub) -> void:	
	# Bring following npc with you when warping
	if Player.instance.following_npc:
		Player.instance.following_npc.get_parent().remove_child(Player.instance.following_npc)
		level_parent.get_parent().add_child(Player.instance.following_npc)
	
	# Remove leftover npc's
	switch_level_cleanup.emit()
	
	# Add the level to load under "Level" to the scene tree
	var scene = ResourceLoader.load(level_to_load, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE)
	level_parent.add_child(scene.instantiate())
	
	# Remove the old level
	level_parent.get_child(0).queue_free()
	
	# Update utilities
	if level_to_load == level_hub:
		Blackboard.save_data()
		UtilitySystem.instance.calculate()
		UtilitySystem.instance.reset_values()
	
	# Get the new level's spawn point location and emit a signal to spawn player (and following npc) there
	get_spawn_location.emit()
