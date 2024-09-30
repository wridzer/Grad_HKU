extends Node2D

@onready var timer: Timer = $Timer

@export var npc_offset: Vector2

var just_spawned := true


func _ready() -> void:
	game_manager.get_spawn_location.connect(spawn)


func spawn() -> void:
	if just_spawned:
		game_manager.spawn.emit(self.position, npc_offset)
		just_spawned = false
		timer.stop()


func _on_timer_timeout() -> void:
	just_spawned = false
