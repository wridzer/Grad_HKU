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
signal return_to_hub
signal day_time

var day: int = 1
var night_time: bool:
	set(value):
		Player.instance.night_time_filter.visible = value
		if !value:
			# Reset values on start of new day
			UtilitySystem.instance.reset_values()
			day += 1
			day_time.emit()
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
	var npc = Blackboard.get_data("npc")
	if is_instance_valid(npc):
		npc = npc as Node
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
		return_to_hub.emit()
		UtilitySystem.instance.calculate()
		Blackboard.dump_data()
		Blackboard.save_data()
	
	# Get the new level's spawn point location and emit a signal to spawn player (and following npc) there
	get_spawn_location.emit()
	
	# Make sure player can move again
	input_manager.toggle_input(true)
