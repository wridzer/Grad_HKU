@tool
class_name DungeonGenerator
extends Node


@onready var tile_map: TileMapLayer = $TileMapLayer

@export var start: bool = false:
	set(value):
		if Engine.is_editor_hint():
			if value:
				generate()
			else:
				tile_map.clear()
			start = value

const room_number: int = 5
const border_size: int = 20
const min_room_size: int = 2
const max_room_size: int = 4


func generate() -> void:
	make_border()
	for i in room_number:
		make_room()


func make_border() -> void:
	for i in range(-1, border_size + 1):
		tile_map.set_cell(Vector2i(i, -1), 0, Vector2i(7,0), 0)
		tile_map.set_cell(Vector2i(i, border_size), 0, Vector2i(7,0), 0)
		tile_map.set_cell(Vector2i(border_size, i), 0, Vector2i(7,0), 0)
		tile_map.set_cell(Vector2i(-1, i), 0, Vector2i(7,0), 0)


func make_room() -> void:
	var width: int = randi() % (max_room_size - min_room_size) + min_room_size
	var height: int = randi() % (max_room_size - min_room_size) + min_room_size
	
	var start_pos: Vector2i
	start_pos.x = randi() % (border_size - width + 1)
	start_pos.y = randi() % (border_size - width + 1)
	
	for x in width:
		for y in height:
			var pos: Vector2i = start_pos + Vector2i(x,y)
			# Set cell
