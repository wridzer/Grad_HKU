extends Node2D

@onready var timer: Timer = $Timer
var spawn := true


func _ready() -> void:
	game_manager.connect("get_spawn_location", spawn_player.bind())


func spawn_player():
	if spawn:
		game_manager.spawn_player.emit(self.position)
		spawn = false
		timer.stop()


func _on_timer_timeout() -> void:
	spawn = false
