extends Node2D

func _ready() -> void:
	game_manager.connect("get_spawn_location", spawn_player.bind())


func spawn_player():
	game_manager.emit_signal("spawn_player", self.position)
