extends Node


# These signals are emitted from other scripts, so the warnings can be ignored
@warning_ignore("unused_signal")
signal spawn(value: Vector2, offset: Vector2)
@warning_ignore("unused_signal")
signal npc_follow(display_name: String)
@warning_ignore("unused_signal")
signal npc_stop_following(display_name: String)
signal switch_level_cleanup
signal get_spawn_location

enum MissionType {INVALID, ITEM, SLAY}

@export var _level_parent: Node
@export_file var _level_hub: String

var mission_type: MissionType = MissionType.INVALID


func set_mission_type(type: String) -> void:
	mission_type = MissionType.get(type)
	
	var data = Blackboard.get_data("mission_choices")
	var mission_choices: Array[MissionType] = []
	if is_instance_valid(data):
		mission_choices = data
	mission_choices.append(mission_type)
	Blackboard.add_data("mission_choices", mission_choices)


func _ready() -> void:
	# Clear the blackboard data
	Blackboard.clear_data()
	
	# Get the level parent node
	var main = get_tree().root.get_node("Main")
	if main and main.has_node("Level"):
		_level_parent = main.get_node("Level")
	
	assert(is_instance_valid(_level_parent), "Node \"Level\" not found in Main scene.")


func load_level(level_to_load: String = _level_hub) -> void:	
	# Bring following npc with you when warping
	if Player.instance.following_npc:
		Player.instance.following_npc.get_parent().remove_child(Player.instance.following_npc)
		_level_parent.get_parent().add_child(Player.instance.following_npc)
	
	# Remove leftover npc's
	switch_level_cleanup.emit()
	
	# Add the level to load under "Level" to the scene tree
	var scene = ResourceLoader.load(level_to_load, PackedScene.new().get_class(), ResourceLoader.CACHE_MODE_IGNORE)
	_level_parent.add_child(scene.instantiate())
	
	# Remove the old level
	_level_parent.get_child(0).queue_free()
	
	# Update utilities
	if level_to_load == _level_hub:
		Blackboard.save_data()
		UtilitySystem.instance.calculate()
		UtilitySystem.instance.reset_values()
	
	# Get the new level's spawn point location and emit a signal to spawn player (and following npc) there
	get_spawn_location.emit()
