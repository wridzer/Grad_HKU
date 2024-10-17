@tool
class_name DungeonGenerator
extends Node


@onready var tile_map: TileMapLayer = $TileMapLayer
@onready var tile_map_decor: TileMapLayer = $TileMapLayer2

@export var seed: String
@export var generated: bool = false:
	set(value):
		if Engine.is_editor_hint():
			if value:
				generate(seed)
			else:
				tile_map.clear()
				tile_map_decor.clear()
				for room in rooms:
					for enemy in room.enemies:
						enemy.queue_free()
				rooms.clear()
				if is_instance_valid(spawn_point):
					spawn_point.queue_free()
			generated = value
@export var spawn_point_scene: PackedScene
@export var enemy_scene: PackedScene

# Tiles
const INVALID_TILE: Vector2i = Vector2i(-1, -1)
const BORDER_TILE: Vector2i = Vector2i(7, 0)
const DOOR_TILE: Vector2i = Vector2i(32, 0)
const ROOM_TILES: Array[Vector2i] = [Vector2i(7, 2), Vector2i(7, 3)]
const WALL_TILES_HOR: Array[Vector2i] = [Vector2i(9, 2), Vector2i(9, 3)]
const WALL_TILES_VER: Array[Vector2i] = [Vector2i(8, 2), Vector2i(8, 3)]
const HALLWAY_TILES: Array[Vector2i] = [Vector2i(8, 0), Vector2i(8, 1)] 
const BACKGROUND_TILES: Array[Vector2i] = [Vector2i(7, 0),Vector2i(7, 1),Vector2i(9, 0)]

# Generation instructions
const ROOM_AMOUNT: int = 10
const MIN_WALL_MARGIN: int = 3 #don't edit pls
const EXTRA_ROOM_MARGIN: int = 0
const BORDER_MARGIN: int = 20
const MAX_RECURSION: int = 10
const BORDER_SIZE: int = 150
const MIN_ROOM_SIZE: int = 8
const MAX_ROOM_SIZE: int = 16
const MIN_ENEMIES_PER_ROOM: int = 1
const MAX_ENEMIES_PER_ROOM: int = 3
const ENEMY_WALL_MARGIN: float = 0.5

var rooms: Array[Room] = []
var step: int = 0:
	set(value):
		step += value
		if step % STEPS_BEFORE_WAITING_FRAME == STEPS_BEFORE_WAITING_FRAME - 1:
			await get_tree().create_timer(0).timeout
const STEPS_BEFORE_WAITING_FRAME: int = 20
var spawn_point: Node2D

func generate(seed: String) -> void:
	print("generating")
	
	# Apply seed when generating
	if !seed.is_empty():
		seed(seed.hash())
	
	make_border()
	var t: int = 0
	for i in ROOM_AMOUNT:
		make_room(MAX_RECURSION)
	
	var mst_graph: AStar2D = get_minimum_spanning_tree()
	var doors: Array[PackedVector2Array] = make_doors(mst_graph)
	
	make_walls(doors)
	make_hallways(doors)
	fill_background()
	
	var spawn_room = rooms.pick_random()
	spawn_enemies(spawn_room)
	make_spawn_point(spawn_room)


func make_border() -> void:
	# Generate the border tiles
	for i in range(-1, BORDER_SIZE + 1):
		step += 1
		tile_map.set_cell(Vector2i(i, -1), 0, BORDER_TILE, 0)
		tile_map.set_cell(Vector2i(i, BORDER_SIZE), 0, BORDER_TILE, 0)
		tile_map.set_cell(Vector2i(BORDER_SIZE, i), 0, BORDER_TILE, 0)
		tile_map.set_cell(Vector2i(-1, i), 0, BORDER_TILE, 0)


func make_room(recursion: int) -> void:
	if recursion <= 0:
		return
	
	step += 1
	
	# Generate a random room
	var width: int = randi() % (MAX_ROOM_SIZE - MIN_ROOM_SIZE) + MIN_ROOM_SIZE
	var height: int = randi() % (MAX_ROOM_SIZE - MIN_ROOM_SIZE) + MIN_ROOM_SIZE
	
	var start_pos: Vector2i
	start_pos.x = randi() % (BORDER_SIZE - width + 1)
	start_pos.y = randi() % (BORDER_SIZE - height + 1)
	
	# Prevent room overlap
	for x in range(-(MIN_WALL_MARGIN + EXTRA_ROOM_MARGIN), width + MIN_WALL_MARGIN + EXTRA_ROOM_MARGIN):
		for y in range(-(MIN_WALL_MARGIN + EXTRA_ROOM_MARGIN), height + MIN_WALL_MARGIN + EXTRA_ROOM_MARGIN):
			var pos: Vector2i = start_pos + Vector2i(x,y)
			for tile_type in ROOM_TILES:
				if tile_map.get_cell_atlas_coords(pos) == tile_type:
					make_room(recursion - 1)
					return
	
	# Prevent wall/border overlap
	for x in range(-BORDER_MARGIN, width + BORDER_MARGIN):
		for y in range(-BORDER_MARGIN, height + BORDER_MARGIN):
			var pos: Vector2i = start_pos + Vector2i(x,y)
			if tile_map.get_cell_atlas_coords(pos) == BORDER_TILE:
				make_room(recursion - 1)
				return
	
	# Generate the room tiles, and save room data
	var room: Room = Room.new(start_pos, width, height)
	
	for x in width:
		for y in height:
			step += 1
			var pos: Vector2i = start_pos + Vector2i(x,y)
			tile_map.set_cell(pos, 0, ROOM_TILES.pick_random(), 0)
			room.room_tiles.append(pos)
	
	rooms.append(room)


func get_minimum_spanning_tree() -> AStar2D:
	# Set up delaunay triangulation & minimum spanning tree graphs
	var del_graph: AStar2D = AStar2D.new()
	var mst_graph: AStar2D = AStar2D.new()
	
	# Get all room positions and populate the graphs
	var positions: PackedVector2Array = []
	for room in rooms:
		positions.append(room.position)
		del_graph.add_point(del_graph.get_available_point_id(), room.position)
		mst_graph.add_point(mst_graph.get_available_point_id(), room.position)
	
	# Delauanay triangulation
	var delaunay: Array = Array(Geometry2D.triangulate_delaunay(positions))

	# Triangles contain 3 points, so we can only have to loop 1/3 of the time
	for _i in delaunay.size() / 3:
		var p1: int = delaunay.pop_front()
		var p2: int = delaunay.pop_front()
		var p3: int = delaunay.pop_front()
		
		# Connect the points
		del_graph.connect_points(p1, p2)
		del_graph.connect_points(p2, p3)
		del_graph.connect_points(p1, p3)
	
	# Get the starting point
	var visited_points: PackedInt32Array = []
	visited_points.append(0)
	
	# Generate the minimum spanning tree
	while visited_points.size() != mst_graph.get_point_count():
		# Step 1: Get all visited points' connections to unvisited points
		var possible_connections: Array[PackedInt32Array] = []
		for point in visited_points:
			for connection in del_graph.get_point_connections(point):
				if !visited_points.has(connection):
					possible_connections.append(PackedInt32Array([point, connection]))
		
		# Step 2: Get the shortest connection of the possible connections
		var shortest_connection: PackedInt32Array = possible_connections.pick_random()
		for connection in possible_connections:
			var possible_shortest_dist: float = positions[connection[0]].distance_squared_to(positions[connection[1]])
			var current_shortest_dist: float = positions[shortest_connection[0]].distance_squared_to(positions[shortest_connection[1]])
			if possible_shortest_dist < current_shortest_dist:
				shortest_connection = connection
		
		# Step 3: Save the found connection & prevent it from being analysed again next loop
		visited_points.append(shortest_connection[1])
		mst_graph.connect_points(shortest_connection[0], shortest_connection[1])
		del_graph.disconnect_points(shortest_connection[0], shortest_connection[1])
	
	return mst_graph


func make_doors(hallway_graph: AStar2D) -> Array[PackedVector2Array]:
	var doors: Array[PackedVector2Array] = []
	
	# Populate the doors Array with start and end points
	for point_id in hallway_graph.get_point_ids():
		for connection in hallway_graph.get_point_connections(point_id):
			if connection > point_id: # Don't check connections twice
				step += 1
				var room_from: Room = rooms[point_id]
				var room_to: Room = rooms[connection]
				
				# Find the closest room tile to the other room (for both rooms)
				var tile_from: Vector2i = room_from.room_tiles[0]
				var tile_to: Vector2i = room_to.room_tiles[0]
				
				var current_shortest_dist_from = tile_from.distance_squared_to(room_to.position)
				for tile in room_from.room_tiles:
					# Skip the first tile
					if tile as Vector2i == tile_from:
						continue
					
					var possible_shortest_dist = tile.distance_squared_to(room_to.position)
					if possible_shortest_dist < current_shortest_dist_from:
						tile_from = tile
						current_shortest_dist_from = possible_shortest_dist
				
				var current_shortest_dist_to = tile_to.distance_squared_to(room_from.position)
				for tile in room_to.room_tiles:
					# Skip the first tile
					if tile as Vector2i == tile_to:
						continue
					
					var possible_shortest_dist = tile.distance_squared_to(room_from.position)
					if possible_shortest_dist < current_shortest_dist_to:
						tile_to = tile
						current_shortest_dist_to = possible_shortest_dist
				
				# Save the door locations
				var door: PackedVector2Array = [tile_from, tile_to]
				doors.append(door)
				
				# Set the door tiles
				tile_map_decor.set_cell(tile_from, 0, DOOR_TILE, 0)
				tile_map_decor.set_cell(tile_to, 0, DOOR_TILE, 0)
	
	return doors


func make_walls(doors: Array[PackedVector2Array]) -> void:
	for room in rooms:
		var room_width_pos = room.start_pos.x + room.width
		var room_height_pos = room.start_pos.y + room.height
		for i in range(room.start_pos.x - 1, room_width_pos + 1):
			step += 1
			tile_map.set_cell(Vector2i(i, room.start_pos.y - 1), 0, WALL_TILES_HOR.pick_random(), 0)
			tile_map.set_cell(Vector2i(i, room_height_pos), 0, WALL_TILES_HOR.pick_random(), 0)
		for i in range(room.start_pos.y - 1, room_height_pos + 1):
			step += 1
			tile_map.set_cell(Vector2i(room.start_pos.x - 1, i), 0, WALL_TILES_VER.pick_random(), 0)
			tile_map.set_cell(Vector2i(room_width_pos, i), 0, WALL_TILES_VER.pick_random(), 0)
	
	for door_pair in doors:
		for door in door_pair:
			var surroundings: PackedVector2Array = [Vector2(-1, 0) + door, Vector2(1, 0) + door, Vector2(0, -1) + door, Vector2(0, 1) + door]
			break_random_wall(surroundings)


func break_random_wall(locations: PackedVector2Array) -> void:
	for point in locations:
		var tile_atlas_coord = tile_map.get_cell_atlas_coords(point)
		for wall_tile in WALL_TILES_HOR + WALL_TILES_VER:
			if tile_atlas_coord == wall_tile:
				step += 1
				tile_map.set_cell(point, 0, INVALID_TILE, 0)
				return


func make_hallways(doors: Array[PackedVector2Array]) -> void:
	# Set up AStar pathfinding
	var a_star: AStarGrid2D = AStarGrid2D.new()
	a_star.region = Rect2i(Vector2i.ZERO, Vector2i.ONE * BORDER_SIZE)
	a_star.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	a_star.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	a_star.update()
	
	# Pass AStar the area to work with
	for tile in tile_map.get_used_cells():
		if tile_map_decor.get_cell_atlas_coords(tile) == DOOR_TILE:
			continue;
		
		var tile_atlas_coord = tile_map.get_cell_atlas_coords(tile)
		for tile_type in WALL_TILES_HOR + WALL_TILES_VER + ROOM_TILES:
			if tile_atlas_coord == tile_type:
				a_star.set_point_solid(Vector2i(tile))
	
	# Generate the hallway tiles
	for door in doors:
		var door_from: Vector2i = Vector2i(door[0])
		var door_to: Vector2i = Vector2i(door[1])
		
		a_star.set_point_solid(door_from, false)
		a_star.set_point_solid(door_to, false)
		var hallway: PackedVector2Array = a_star.get_point_path(door_from, door_to)
		
		for point in hallway:
			step += 1
			if tile_map.get_cell_atlas_coords(point) == INVALID_TILE:
				tile_map.set_cell(point, 0, HALLWAY_TILES.pick_random(), 0)


func fill_background() -> void:
	for x in BORDER_SIZE:
		for y in BORDER_SIZE:
			var pos: Vector2i = Vector2i(x,y)
			if tile_map.get_cell_atlas_coords(pos) == INVALID_TILE:
				tile_map.set_cell(pos, 0, BACKGROUND_TILES.pick_random(), 0)


func spawn_enemies(spawn_room: Room) -> void:
	var enemies_node: Node = get_node("Enemies")
	for room in rooms:
		if room == spawn_room:
			continue
		
		var enemy_count: int = randi() % MAX_ENEMIES_PER_ROOM + MIN_ENEMIES_PER_ROOM
		
		for i in enemy_count:
			step += 1
			var enemy: Enemy = enemy_scene.instantiate()
			room.enemies.append(enemy)
			enemies_node.add_child(enemy)
			enemy.name = str(room.position) + enemy.name + str(i)
			enemy.owner = self
			var x_pos: float= ENEMY_WALL_MARGIN + fposmod(randf() * room.width, room.width - ENEMY_WALL_MARGIN)
			var y_pos: float = ENEMY_WALL_MARGIN + fposmod(randf() * room.height, room.height - ENEMY_WALL_MARGIN)
			enemy.translate((room.start_pos as Vector2 + Vector2(x_pos, y_pos)) * tile_map.rendering_quadrant_size)


func make_spawn_point(spawn_room: Room) -> void:
	spawn_point = spawn_point_scene.instantiate()
	self.add_child(spawn_point)
	spawn_point.owner = self
	spawn_point.translate(spawn_room.position * tile_map.rendering_quadrant_size)
