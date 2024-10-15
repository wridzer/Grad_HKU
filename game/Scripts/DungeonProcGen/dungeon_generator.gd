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
				rooms.clear()
			start = value

const BORDER_TILE: Vector2i = Vector2i(7, 0)
const WALL_TILE: Vector2i = Vector2i(7, 5)
const FLOOR_TILE: Vector2i = Vector2i(7, 2)
const HALLWAY_TILE: Vector2i = Vector2i(11, 8)
const ROOM_AMOUNT: int = 5
const ROOM_MARGIN: int = 1
const MAX_RECURSION: int = 10
const BORDER_SIZE: int = 25
const MIN_ROOM_SIZE: int = 4
const MAX_ROOM_SIZE: int = 8

var rooms: Array[Room] = []


func generate() -> void:
	print("generating")
	make_border()
	for i in ROOM_AMOUNT:
		make_room(MAX_RECURSION)


func make_border() -> void:
	for i in range(-1, BORDER_SIZE + 1):
		tile_map.set_cell(Vector2i(i, -1), 0, BORDER_TILE, 0)
		tile_map.set_cell(Vector2i(i, BORDER_SIZE), 0, BORDER_TILE, 0)
		tile_map.set_cell(Vector2i(BORDER_SIZE, i), 0, BORDER_TILE, 0)
		tile_map.set_cell(Vector2i(-1, i), 0, BORDER_TILE, 0)


func make_room(recursion: int) -> void:
	if recursion <= 0:
		return
	
	# Generate a random room
	var width: int = randi() % (MAX_ROOM_SIZE - MIN_ROOM_SIZE) + MIN_ROOM_SIZE
	var height: int = randi() % (MAX_ROOM_SIZE - MIN_ROOM_SIZE) + MIN_ROOM_SIZE
	
	var start_pos: Vector2i
	start_pos.x = randi() % (BORDER_SIZE - width + 1)
	start_pos.y = randi() % (BORDER_SIZE - height + 1)
	
	# Prevent room overlap
	for x in range(-ROOM_MARGIN, width + ROOM_MARGIN):
		for y in range(-ROOM_MARGIN, height + ROOM_MARGIN):
			var pos: Vector2i = start_pos + Vector2i(x,y)
			if tile_map.get_cell_atlas_coords(pos) == FLOOR_TILE:
				make_room(recursion - 1)
				return
	
	# Display room on tile map, and save room data
	var room: Room = Room.new(start_pos, width, height)
	rooms.append(room)
	
	for x in width:
		for y in height:
			var pos: Vector2i = start_pos + Vector2i(x,y)
			tile_map.set_cell(pos, 0, FLOOR_TILE, 0)
			room.room_tiles.append(pos)
