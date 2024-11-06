class_name Room
extends Node2D


var start_pos: Vector2i
var width: int
var height: int
var room_position: Vector2
var room_tiles: PackedVector2Array = []
var enemies: Array[Enemy] = []


func _init(start_pos, width, height) -> void:
	self.start_pos = start_pos
	self.width = width
	self.height = height
	
	var average_x: float = start_pos.x + float(width)/2
	var average_y: float = start_pos.y + float(height)/2
	room_position = Vector2(average_x, average_y)
