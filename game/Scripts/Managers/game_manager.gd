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
signal toggle_goap

var night_time: bool:
	set(value):
		Player.instance.night_time_filter.visible = value
		night_time = value

var is_npc_following: bool: 
	get: 
		return is_instance_valid(Blackboard.get_data("npc"))

@export var _level_parent: Node
@export_file var _level_hub: String


func _ready() -> void:
	# Get the level parent node
	var main = get_tree().root.get_node("Main")
	if main and main.has_node("Level"):
		_level_parent = main.get_node("Level")
	
	assert(is_instance_valid(_level_parent), "Node \"Level\" not found in Main scene.")


func load_level(level_to_load: String = _level_hub) -> void:	
	# Bring following npc with you when warping
	var data = Blackboard.get_data("npc")
	if is_instance_valid(data):
		var npc: Npc = data
		npc.reparent(_level_parent.get_parent())
	
	# Perform any cleanup like: Remove leftover npc's, Reset health
	switch_level_cleanup.emit()
	
	# Add the level to load under "Level" to the scene tree
	var scene = ResourceLoader.load(level_to_load, PackedScene.new().get_class(), ResourceLoader.CACHE_MODE_IGNORE)
	_level_parent.add_child(scene.instantiate())
	
	# Remove the old level
	_level_parent.get_child(0).queue_free()
	
	# Toggle npc GOAP system
	toggle_goap.emit()
	
	# Dump blackboard & update utilities
	if level_to_load == _level_hub:
		night_time = true
		UtilitySystem.instance.calculate()
		Blackboard.dump_data()
		Blackboard.save_data()
	else:
		# Reset values on start of run
		UtilitySystem.instance.reset_values()
	
	# Get the new level's spawn point location and emit a signal to spawn player (and following npc) there
	get_spawn_location.emit()
