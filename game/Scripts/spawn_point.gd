extends Node2D


@export var _npc_offset: Vector2

var _just_spawned := true

@onready var _timer: Timer = $Timer


func _ready() -> void:
	game_manager.get_spawn_location.connect(spawn)


func spawn() -> void:
	if _just_spawned:
		game_manager.spawn.emit(self.position, _npc_offset)
		_just_spawned = false
		_timer.stop()


func _on__timer_timeout() -> void:
	_just_spawned = false
