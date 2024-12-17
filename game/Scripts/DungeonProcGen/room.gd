class_name Room
extends Node2D


@export var start_pos: Vector2i
@export var width: int
@export var height: int
@export var room_position: Vector2
@export var enemies: Array[Enemy] = []
@export var player_detector: Area2D:
	set(value):
		player_detector = value
		player_detector.body_entered.connect(_player_entered_room)
		player_detector.body_exited.connect(_player_exited_room)

var room_tiles: PackedVector2Array = []
var objective: Node2D = null


@warning_ignore("shadowed_variable")
func _init(start_pos = self.start_pos, width = self.width, height = self.height) -> void:
	self.start_pos = start_pos
	self.width = width
	self.height = height
	
	if !room_position:
		var average_x: float = start_pos.x + float(width) / 2
		var average_y: float = start_pos.y + float(height) / 2
		room_position = Vector2(average_x, average_y)


func _player_entered_room(body: Node2D) -> void:
	print(body.name + " entered room " + name)
	Player.instance.room = self
	
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.state_machine.transition_to_next_state(EnemyState.state_type_to_int(EnemyState.StateType.CHASE))


func _player_exited_room(body: Node2D) -> void:
	print(body.name + " exited room " + name)
	Player.instance.room = null
	
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.state_machine.transition_to_next_state(EnemyState.state_type_to_int(EnemyState.StateType.IDLE))


func erase_dead_enemy(enemy: Enemy) -> void:
	enemies.erase(enemy)
