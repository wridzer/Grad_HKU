@tool
class_name DungeonGenerator
extends Node


enum MissionType {INVALID, ITEM, SLAY}

# Tiles
const INVALID_TILE: Vector2i = Vector2i(-1, -1)
const BORDER_TILE: Vector2i = Vector2i(7, 0)
const OPEN_DOOR_TILE: Vector2i = Vector2i(37, 1)
const CLOSED_DOOR_TILE: Vector2i = Vector2i(39, 0)
const DOOR_BACKGROUND_TILE: Vector2i = Vector2i(6, 0)
const ROOM_TILES: Array[Vector2i] = [Vector2i(7, 2), Vector2i(7, 3)]
const WALL_TILES_HOR: Array[Vector2i] = [Vector2i(9, 2), Vector2i(9, 3)]
const WALL_TILES_VER: Array[Vector2i] = [Vector2i(8, 2), Vector2i(8, 3)]
const HALLWAY_TILES: Array[Vector2i] = [Vector2i(8, 0), Vector2i(8, 1)] 
const BACKGROUND_TILES: Array[Vector2i] = [Vector2i(7, 0),Vector2i(7, 1),Vector2i(9, 0)]

const MIN_WALL_MARGIN: int = 3
const MAX_RECURSION: int = 25
const STEPS_BEFORE_WAITING_FRAME: int = 30
const UNSUCCESFULL_GENERATION_DUNGEON_SIZE_MULTIPLIER: float = 1.05

# Prerequisites
@export_category("Prerequisites")
@export var _dungeon_node: Node2D
@export var _tile_map: TileMapLayer
@export var _tile_map_doors: TileMapLayer
@export var _spawn_point_scene: PackedScene
@export var _enemy_scene: PackedScene
@export var _key_scene: PackedScene
@export var _heal_scene: PackedScene
@export var _barrel_scene: PackedScene
@export var _dungeon_exit_scene: PackedScene
@export var _goal_room_dialogue: DialogueResource

# Generation buttons
@export_category("Generate")
@warning_ignore("shadowed_global_identifier")
@export var _seed: String

@warning_ignore("unused_private_class_variable")
@export var _generate_slay: bool = false:
	set(value):
		if Engine.is_editor_hint() && _dungeon_node.get_child_count() == 0:
			mission_type = MissionType.SLAY
			_generate_dungeon()

@warning_ignore("unused_private_class_variable")
@export var _generate_item: bool = false:
	set(value):
		if Engine.is_editor_hint() && _dungeon_node.get_child_count() == 0:
			mission_type = MissionType.ITEM
			_generate_dungeon()

@warning_ignore("unused_private_class_variable")
@export var _clear: bool = false:
	set(value):
		if Engine.is_editor_hint():
			_clear_dungeon()

# Generation instructions
@export_category("Generation Instructions")
@export var difficulty_modifier: float = 1
@export var _room_types: Dictionary[int, Array] = {14: [12, 13 ,14], 13: [12, 13, 14], 12: [12, 13, 14]}
@export_range(15, 200, 5) var _dungeon_size: int = 120
@export_range(3, 10) var _min_room_amount: int = 4
@export_range(3, 20) var _max_room_amount: int = 5
@export_range(1, 10) var _min_key_items: int = 2
@export_range(3, 20) var _max_key_items: int = 3
@export_range(1, 10) var _min_heal_items: int = 2
@export_range(1, 20) var _max_heal_items: int = 3
@export_range(0, 10) var _extra_room_margin: int = 0
@export_range(15, 40, 5) var _border_margin: int = 20
@export_range(0, 5) var _min_enemies_per_room: int = 1
@export_range(0, 5) var _max_enemies_per_room: int = 3
@export_range(0.5, 5.0) var _enemy_wall_margin: float = 0.5
@export_range(0.5, 5.0) var _item_wall_margin: float = 0.5

static var mission_type: MissionType = MissionType.INVALID
var _rooms: Array[Room] = []
var _keys: Array = []
var _heals: Array = []
var _barrels: Array = []
var _step: int = 0:
	set(value):
		_step = value
		if _step % STEPS_BEFORE_WAITING_FRAME == STEPS_BEFORE_WAITING_FRAME - 1:
			await get_tree().process_frame


func _ready() -> void:
	if !Engine.is_editor_hint() &&  _dungeon_node.get_child_count() == 0:
		_clear_dungeon()
		_generate_dungeon()


static func set_mission_type(type: String) -> void:
	mission_type = MissionType.get(type)
	
	var mission_choices = Blackboard.get_data("mission_choices")
	if !is_instance_valid(mission_choices):
		mission_choices = []
	mission_choices = mission_choices as Array[DungeonGenerator.MissionType]
	mission_choices.append(mission_type)
	Blackboard.add_data("mission_choices", mission_choices)


func _generate_dungeon() -> void:
	assert(_dungeon_size > _border_margin, "dungeon_size needs to be bigger than _border_margin")
	assert(!_room_types.is_empty(), "room_types is empty")
	assert(_max_room_amount >= _min_room_amount , "_max_room_amount < _min_room_amount")
	assert(is_instance_valid(_spawn_point_scene), "assign valid _spawn_point_scene")
	assert(is_instance_valid(_enemy_scene), "assign valid _enemy_scene")
	assert(is_instance_valid(_key_scene), "assign valid _key_scene")
	if mission_type == MissionType.ITEM:
		assert(_max_key_items >= _min_key_items, "_max_key_items < _min_key_items")
		assert(_min_room_amount - 1 >= _max_key_items, "_min_room_amount - 1 < _max_key_items (can not add more keys if minimum rooms generates, and can not generate key in goal room)")
	assert(_min_room_amount - 1 >=  _max_heal_items, "_min_room_amount - 1 < _max_heal_items, can only have 1 heal item per room excluding goal room")
	print("generating dungeon with mission type: ", MissionType.keys()[mission_type])
	
	# Apply seed when generating
	if !_seed.is_empty():
		seed(_seed.hash())
	
	difficulty_modifier = _get_difficulty_modifier()
	
	_make_border()
	
	# Scale room amount with the difficulty modifier
	for i in floori(_max_room_amount * difficulty_modifier):
		_make_room(MAX_RECURSION)
	
	# Only works for 3+ rooms
	var mst_graph: AStar2D = _get_minimum_spanning_tree()
	var door_pairs: Array[DoorPair] = _make_doors(mst_graph)
	
	_make_walls(door_pairs)
	_make_hallways(door_pairs)
	_fill_background()
	
	var goal_room: Room = _choose_goal_room()
	if !is_instance_valid(goal_room):
		return
	
	var spawn_room: Room = _choose_spawn_room(goal_room)
	if !is_instance_valid(spawn_room):
		return
	
	if mission_type == MissionType.ITEM:
		_spawn_key_items(spawn_room, goal_room)
		_spawn_enemies(spawn_room, goal_room)
	else:
		_spawn_enemies(spawn_room)
	_spawn_heal_items(goal_room)
	_spawn_barrels(goal_room)
	_make_spawn_point(spawn_room)
	_make_dungeon_exit(goal_room)


func _clear_dungeon() -> void:
	print("clearing dungeon")
	_tile_map.clear()
	_tile_map_doors.clear()
	_rooms.clear()
	
	for child in _dungeon_node.get_children():
		child.queue_free()


func _get_difficulty_modifier() -> float:
	# Base modifier per day count (day 1 = 1.00)
	var modifier: float = 1.00 + (game_manager.day - 1) * 0.05
	
	# If player failed once already, increase the difficulty by another 10%
	var mission_fail_count: int = Blackboard.get_data("mission_fail_count") if Blackboard.get_data("mission_fail_count") else 0
	if mission_fail_count == 1:
		modifier += 0.10
	
	# Scale the modifier negatively by 10% per average level
	var average_level = Blackboard.get_data("average_level") if Blackboard.get_data("average_level") else 1
	modifier -= 0.10 * (average_level - 1)
	
	return modifier


func _make_border() -> void:
	# Generate the border tiles
	for i in range(-1, _dungeon_size + 1):
		_step += 1
		_tile_map.set_cell(Vector2i(i, -1), 0, BORDER_TILE, 0)
		_tile_map.set_cell(Vector2i(i, _dungeon_size), 0, BORDER_TILE, 0)
		_tile_map.set_cell(Vector2i(_dungeon_size, i), 0, BORDER_TILE, 0)
		_tile_map.set_cell(Vector2i(-1, i), 0, BORDER_TILE, 0)


func _make_room(recursion: int) -> void:
	if recursion <= 0:
		if _rooms.size() < floori(_min_room_amount * difficulty_modifier):
			print("Dungeon size too small to succesfully generate " + str(floori(_min_room_amount * difficulty_modifier)) + "rooms. Only " + str(_rooms.size()) + " were generated. Trying again with 120% dungeon size.")
			_dungeon_size = int(_dungeon_size * 1.2)
			_clear_dungeon()
			_generate_dungeon()
		return
	
	_step += 1
	
	# Generate a random room
	var width: int = _room_types.keys().pick_random()
	var height: int = _room_types[width].pick_random()
	var start_pos: Vector2i = Vector2i(randi_range(0, _dungeon_size - width), randi_range(0, _dungeon_size - height))
	
	# Prevent room overlap
	var wall_margin: int = MIN_WALL_MARGIN + _extra_room_margin
	for x in range(-wall_margin, width + wall_margin):
		for y in range(-wall_margin, height + wall_margin):
			var pos: Vector2i = start_pos + Vector2i(x,y)
			for tile_type in ROOM_TILES:
				if _tile_map.get_cell_atlas_coords(pos) == tile_type:
					_make_room(recursion - 1)
					return
	
	# Prevent wall/border overlap
	for x in range(-_border_margin, width + _border_margin):
		for y in range(-_border_margin, height + _border_margin):
			var pos: Vector2i = start_pos + Vector2i(x,y)
			if _tile_map.get_cell_atlas_coords(pos) == BORDER_TILE:
				_make_room(recursion - 1)
				return
	
	# Generate the room tiles, and save room data
	var room: Room = Room.new(start_pos, width, height)
	_rooms.append(room)
	_dungeon_node.add_child(room)
	room.owner = self
	room.name = "Room " + str(_rooms.size() - 1) + str(room.room_position)
	room.set_global_position(room.room_position * _tile_map.rendering_quadrant_size)
	
	for x in width:
		for y in height:
			_step += 1
			var pos: Vector2i = start_pos + Vector2i(x,y)
			_tile_map.set_cell(pos, 0, ROOM_TILES.pick_random(), 0)
			room.room_tiles.append(pos)
	
	# Generate an Area2D player detector for the room
	var player_detector = Area2D.new()
	room.add_child(player_detector)
	player_detector.collision_mask = LayerNames.PHYSICS_2D.NONE
	player_detector.collision_mask = LayerNames.PHYSICS_2D.PLAYER
	player_detector.name = "PlayerDetector"
	player_detector.owner = self
	room.player_detector = player_detector
	
	var collision_shape = CollisionShape2D.new()
	player_detector.add_child(collision_shape)
	collision_shape.owner = self
	collision_shape.name = "CollisionShape"
	var rect_shape = RectangleShape2D.new()
	rect_shape.extents = float(_tile_map.rendering_quadrant_size) / 2 * Vector2(room.width, room.height)
	collision_shape.shape = rect_shape


func _get_minimum_spanning_tree() -> AStar2D:
	# Set up delaunay triangulation & minimum spanning tree graphs
	var del_graph: AStar2D = AStar2D.new()
	var mst_graph: AStar2D = AStar2D.new()
	
	# Get all room positions and populate the graphs
	var positions: PackedVector2Array = []
	for room in _rooms:
		positions.append(room.room_position)
		del_graph.add_point(del_graph.get_available_point_id(), room.room_position)
		mst_graph.add_point(mst_graph.get_available_point_id(), room.room_position)
	
	# Delauanay triangulation
	var delaunay: Array = Array(Geometry2D.triangulate_delaunay(positions))
	
	@warning_ignore("integer_division")
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


func _make_doors(hallway_graph: AStar2D) -> Array[DoorPair]:
	var door_pairs: Array[DoorPair] = []
	
	# Populate the doors Array with start and end points
	for point_id in hallway_graph.get_point_ids():
		for connection in hallway_graph.get_point_connections(point_id):
			if connection > point_id: # Don't check connections twice
				_step += 1
				var room_from: Room = _rooms[point_id]
				var room_to: Room = _rooms[connection]
				
				# Calculate the midpoint between the two room centers
				var midpoint: Vector2 = (room_from.room_position + room_to.room_position) / 2
				
				# Create the doors
				var door_from: Door = Door.new()
				door_from.room = room_from
				door_from.door_position = room_from.room_tiles[0]
				room_from.doors.append(door_from)
				var door_to: Door = Door.new()
				door_to.room = room_to
				door_to.door_position = room_to.room_tiles[0]
				room_to.doors.append(door_to)
				
				# Find the closest room tile to the other room (for both rooms)
				var current_shortest_dist_from = door_from.door_position.distance_squared_to(midpoint)
				for tile in room_from.room_tiles:
					# Skip the first tile
					if tile as Vector2i == door_from.door_position:
						continue
					
					var possible_shortest_dist = tile.distance_squared_to(midpoint)
					if possible_shortest_dist < current_shortest_dist_from:
						door_from.door_position = tile
						current_shortest_dist_from = possible_shortest_dist
				
				var current_shortest_dist_to = door_to.door_position.distance_squared_to(midpoint)
				for tile in room_to.room_tiles:
					# Skip the first tile
					if tile as Vector2i == door_to.door_position:
						continue
					
					var possible_shortest_dist = tile.distance_squared_to(midpoint)
					if possible_shortest_dist < current_shortest_dist_to:
						door_to.door_position = tile
						current_shortest_dist_to = possible_shortest_dist
				
				# Create a door pair and save it
				var door_pair: DoorPair = DoorPair.new()
				door_pair.door_from = door_from
				door_pair.door_to = door_to
				door_pairs.append(door_pair)
	
	return door_pairs


func _make_walls(door_pairs: Array[DoorPair]) -> void:
	# Generate walls around the rooms
	for room in _rooms:
		var room_width_pos = room.start_pos.x + room.width
		var room_height_pos = room.start_pos.y + room.height
		for i in range(room.start_pos.x - 1, room_width_pos + 1):
			_step += 1
			_tile_map.set_cell(Vector2i(i, room.start_pos.y - 1), 0, WALL_TILES_HOR.pick_random(), 0)
			_tile_map.set_cell(Vector2i(i, room_height_pos), 0, WALL_TILES_HOR.pick_random(), 0)
		for i in range(room.start_pos.y - 1, room_height_pos + 1):
			_step += 1
			_tile_map.set_cell(Vector2i(room.start_pos.x - 1, i), 0, WALL_TILES_VER.pick_random(), 0)
			_tile_map.set_cell(Vector2i(room_width_pos, i), 0, WALL_TILES_VER.pick_random(), 0)
	
	# Break the best wall for each door
	for door_pair in door_pairs:
		var door_from_position: Vector2 = door_pair.door_from.door_position
		var door_to_position: Vector2 = door_pair.door_to.door_position
		
		var door_direction = (door_from_position.direction_to(door_to_position)).normalized()
		var surroundings: PackedVector2Array = [Vector2(-1, 0), Vector2(0, 1), Vector2(1, 0), Vector2(0, -1)]
		var best_index = 0
		var best_interest = -INF
		for index in range(surroundings.size()):
			var interest: float = surroundings[index].dot(door_direction)
			if index != 0:
				if interest > best_interest:
					best_interest = interest
					best_index = index
		
		var sorted_coords: PackedVector2Array
		sorted_coords = [door_from_position + surroundings[best_index], door_from_position + surroundings[posmod(best_index + 1, surroundings.size())], door_from_position + surroundings[posmod(best_index - 1, surroundings.size())], ]
		door_pair.door_from.door_sprite_position = _break_wall(sorted_coords)
		sorted_coords = [door_to_position - surroundings[best_index], door_to_position - surroundings[posmod(best_index + 1, surroundings.size())],door_to_position - surroundings[posmod(best_index - 1, surroundings.size())]]
		door_pair.door_to.door_sprite_position = _break_wall(sorted_coords)


func _break_wall(sorted_coords: PackedVector2Array) -> Vector2i:
	for coord: Vector2i in sorted_coords:
		var tile_atlas_coord = _tile_map.get_cell_atlas_coords(coord)
		for wall_tile in WALL_TILES_HOR + WALL_TILES_VER:
			if tile_atlas_coord == wall_tile:
				_step += 1
				
				# Set tile as door
				_tile_map.set_cell(coord, 0, DOOR_BACKGROUND_TILE, 0)
				_tile_map_doors.set_cell(coord, 0, OPEN_DOOR_TILE, 0)
				
				return coord
	
	return INVALID_TILE


func _make_hallways(door_pairs: Array[DoorPair]) -> void:
	# Set up AStar pathfinding
	var a_star: AStarGrid2D = AStarGrid2D.new()
	a_star.region = Rect2i(Vector2i.ZERO, Vector2i.ONE * _dungeon_size)
	a_star.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	a_star.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	a_star.update()
	
	# Pass AStar the area to work with
	for tile in _tile_map.get_used_cells():
		if _tile_map.get_cell_atlas_coords(tile) == DOOR_BACKGROUND_TILE:
			continue;
		
		var tile_atlas_coord = _tile_map.get_cell_atlas_coords(tile)
		for tile_type in WALL_TILES_HOR + WALL_TILES_VER + ROOM_TILES:
			if tile_atlas_coord == tile_type:
				a_star.set_point_solid(Vector2i(tile))
	
	# Generate the hallway tiles
	for door_pair in door_pairs:
		var door_from_position: Vector2i = door_pair.door_from.door_position
		var door_to_position: Vector2i = door_pair.door_to.door_position
		
		a_star.set_point_solid(door_from_position, false)
		a_star.set_point_solid(door_to_position, false)
		var hallway: PackedVector2Array = a_star.get_point_path(door_from_position, door_to_position)
		
		for point in hallway:
			_step += 1
			if _tile_map.get_cell_atlas_coords(point) == INVALID_TILE:
				_tile_map.set_cell(point, 0, HALLWAY_TILES.pick_random(), 0)


func _fill_background() -> void:
	for x in range(_dungeon_size):
		for y in range(_dungeon_size):
			var pos: Vector2i = Vector2i(x,y)
			if _tile_map.get_cell_atlas_coords(pos) == INVALID_TILE:
				_tile_map.set_cell(pos, 0, BACKGROUND_TILES.pick_random(), 0)


func _choose_goal_room() -> Room:
	var possible_goal_rooms: Array[Room] = []
	for room in _rooms:
		if room.doors.size() == 1:
			possible_goal_rooms.append(room)
	
	if possible_goal_rooms.size() == 0:
		print("no possible goal rooms, retrying generation")
		_clear_dungeon()
		_generate_dungeon()
		return null
	
	var goal_room: Room = possible_goal_rooms.pick_random()
	if mission_type == MissionType.ITEM:
		_tile_map_doors.set_cell(goal_room.doors[0].door_sprite_position, 0, CLOSED_DOOR_TILE, 0)
		goal_room.player_detector.body_entered.connect(_start_goal_room_dialogue.bind(goal_room))
	
	return goal_room


func _start_goal_room_dialogue(_body: Node2D, goal_room: Room) -> void:
	dialogue_manager.start_dialogue(_goal_room_dialogue)
	goal_room.player_detector.body_entered.disconnect(_start_goal_room_dialogue)


func _choose_spawn_room(goal_room: Room) -> Room:
	var possible_spawn_rooms: Array[Room] = _rooms.duplicate()
	possible_spawn_rooms.erase(goal_room)
	
	if possible_spawn_rooms.size() == 0:
		print("no possible spawn rooms, retrying generation")
		_clear_dungeon()
		_generate_dungeon()
		return null
		
	var spawn_room = possible_spawn_rooms.pick_random()
	
	return spawn_room


func _spawn_key_items(spawn_room: Room, goal_room: Room) -> void:
	var possible_key_rooms: Array[Room] = _rooms.duplicate()
	possible_key_rooms.erase(goal_room)
	
	var key_item_amount = randi_range(_min_key_items, _max_key_items)
	for i in range(key_item_amount):
		var key_room: Room
		if !spawn_room.key_pickups:
			key_room = spawn_room
			possible_key_rooms.erase(spawn_room)
		else:
			key_room = possible_key_rooms.pick_random()
		possible_key_rooms.erase(key_room)
		
		var key_pickup: KeyPickup = _key_scene.instantiate()
		key_room.key_pickups.append(key_pickup)
		key_room.add_child(key_pickup)
		key_pickup.name = key_pickup.name + str(i)
		key_pickup.owner = self
		_keys.append(key_pickup)
		_step += 1
		var half_width: float = key_room.width / 2.0 - _item_wall_margin
		var half_height: float = key_room.height / 2.0 - _item_wall_margin
		var pos: Vector2 = Vector2(randf_range(-half_width, half_width), randf_range(-half_height, half_height))
		key_pickup.translate(pos * _tile_map.rendering_quadrant_size)
		key_pickup.no_keys_left.connect(_open_goal_room_door.bind(goal_room))
		key_pickup.key_used.connect(key_room.erase_used_key)


func _open_goal_room_door(goal_room: Room) -> void:
	_tile_map_doors.set_cell(goal_room.doors[0].door_sprite_position, 0, OPEN_DOOR_TILE, 0)


func _spawn_heal_items(goal_room: Room) -> void:
	var possible_heal_rooms: Array[Room] = _rooms.duplicate()
	possible_heal_rooms.erase(goal_room)
	
	# Negatively scale heal item amount range with the difficulty modifier
	var heal_item_amount = randi_range(floori(_min_heal_items / difficulty_modifier), floori(_max_heal_items / difficulty_modifier))
	
	for i in range(heal_item_amount):
		var heal_room = possible_heal_rooms.pick_random()
		possible_heal_rooms.erase(heal_room)
		
		var heal_pickup: HealPickup = _heal_scene.instantiate()
		heal_room.heal_pickups.append(heal_pickup)
		heal_room.add_child(heal_pickup)
		heal_pickup.name = heal_pickup.name + str(i)
		heal_pickup.owner = self
		_heals.append(heal_pickup)
		_step += 1
		var half_width: float = heal_room.width / 2.0 - _item_wall_margin
		var half_height: float = heal_room.height / 2.0 - _item_wall_margin
		var pos: Vector2 = Vector2(randf_range(-half_width, half_width), randf_range(-half_height, half_height))
		heal_pickup.translate(pos * _tile_map.rendering_quadrant_size)
		heal_pickup.heal_used.connect(heal_room.erase_used_heal)


func _spawn_barrels(goal_room: Room) -> void:
	var possible_barrel_rooms: Array[Room] = _rooms.duplicate()
	possible_barrel_rooms.erase(goal_room)
	
	var barrel_amount = possible_barrel_rooms.size()
	for i in range(barrel_amount):
		var barrel_room = possible_barrel_rooms.pick_random()
		possible_barrel_rooms.erase(barrel_room)
		
		var barrel: Barrel = _barrel_scene.instantiate()
		barrel_room.barrels.append(barrel)
		barrel_room.add_child(barrel)
		barrel.name = barrel.name + str(i)
		barrel.owner = self
		_barrels.append(barrel)
		_step += 1
		var half_width: float = barrel_room.width / 2.0 - _item_wall_margin
		var half_height: float = barrel_room.height / 2.0 - _item_wall_margin
		var pos: Vector2 = Vector2(randf_range(-half_width, half_width), randf_range(-half_height, half_height))
		barrel.translate(pos * _tile_map.rendering_quadrant_size)


func _spawn_enemies(spawn_room: Room, goal_room: Room = null) -> void:
	for room in _rooms:
		if room == spawn_room:
			continue
		
		# Scale enemy amount range with the difficulty modifer
		var enemy_amount: int = randi_range(floori(_min_enemies_per_room * difficulty_modifier), floori(_max_enemies_per_room * difficulty_modifier))
		
		if is_instance_valid(goal_room):
			if room == goal_room:
				enemy_amount = 1
		
		for i in range(enemy_amount):
			var enemy: Enemy = _enemy_scene.instantiate()
			room.enemies.append(enemy)
			room.add_child(enemy)
			enemy.name = enemy.name + str(i)
			enemy.owner = self
			_step += 1
			var half_width: float = room.width / 2.0 - _enemy_wall_margin
			var half_height: float = room.height / 2.0 - _enemy_wall_margin
			var pos: Vector2 = Vector2(randf_range(-half_width, half_width), randf_range(-half_height, half_height))
			enemy.translate(pos * _tile_map.rendering_quadrant_size)
			enemy.died.connect(room.erase_dead_enemy)


func _make_spawn_point(spawn_room: Room) -> void:
	var spawn_point: Node2D = _spawn_point_scene.instantiate()
	spawn_room.add_child(spawn_point)
	spawn_point.owner = self
	spawn_point.translate(spawn_room.room_position * _tile_map.rendering_quadrant_size)


func _make_dungeon_exit(goal_room: Room) -> void:
	var dungeon_exit: Node2D = _dungeon_exit_scene.instantiate()
	goal_room.add_child(dungeon_exit)
	dungeon_exit.owner = self
	
	if mission_type == MissionType.SLAY:
		dungeon_exit.condition = func() -> bool: 
			return Blackboard.get_data("enemies_alive") <= 0
