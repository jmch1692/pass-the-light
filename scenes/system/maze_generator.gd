extends Node2D

@export var map_height : int = 25
@export var map_width : int = 25
@export var map_offset : int = 4
@export var chance : float = 0.25

@onready var tile_map = %TileMap
@onready var start_area = %StartPoint
@onready var exit_area = %ExitPoint

var rng = RandomNumberGenerator.new()
var spawn_zones : Array = []
var level_factor : float = GlobalGameSettings.game_settings["level_factor"]
var maze_size_factor : float = GlobalGameSettings.game_settings["maze_size_factor"]
var solid_cells : PackedVector2Array = []

#signals when ready
signal start_point_ready(start_position)
signal exit_point_ready(exit_position)
signal npc_point_ready(npc_position)

#signals when maze is playable
signal player_hit_finish_point
signal debug_values(npc_spawn_rate, level_factor, maze_size_factor, chance, maze_width, maze_height, retries)
signal clear_maze(retries)

# Tilemap constants
const BACKGROUND_TILE_COORDINATES = Vector2i(0, 0) #Layer 0
const WALL_TILE_COODRINATES = Vector2i(9, 3) #Layer 1
	
func generate_maze():
	generate_walls()
	var free_points_packedarray = generate_background()
	var points = randomize_start_and_end_point(free_points_packedarray)
	start_area.position = points[0]
	exit_area.position = points[1]
	if exit_area.position != Vector2.ZERO && start_area.position != Vector2.ZERO:
		var path = tile_map.compute_path(map_width, map_height, map_offset, start_area.position, exit_area.position, solid_cells)
		var solution = tile_map.evaluate_path(path)
		if solution:
			start_point_ready.emit(start_area.position)
			exit_point_ready.emit()
			GlobalGameSettings.game_settings["maze_retries"] = 0
		elif !solution and GlobalGameSettings.game_settings["maze_retries"] <= 3:
			GlobalGameSettings.game_settings["maze_retries"] += 1
			clear_maze.emit(GlobalGameSettings.game_settings["maze_retries"])
			
	set_difficulty(level_factor, maze_size_factor)
			
func _ready():
	set_difficulty(level_factor, maze_size_factor)
	generate_maze()

func set_difficulty(factor: float, maze_factor: float):
	level_factor = factor
	maze_size_factor = maze_factor
	var maze_factori = floori(maze_factor)
	map_height += maze_factori + randi_range(-maze_factori, 2 * maze_factori)
	map_width += maze_factori + randi_range(-maze_factori, 2 * maze_factori)
	GlobalGameSettings.game_settings["map_height"] = map_height
	GlobalGameSettings.game_settings["map_width"] = map_width
	chance *= factor
	#debug_values.emit(max_npc_to_place, level_factor, maze_factori, chance, map_width, map_height, GlobalGameSettings.game_settings["maze_retries"])

func randomize_start_and_end_point(free_points : Array[Vector2]) -> Array:
	var starting_points : Array = spawn_zones[0] + spawn_zones[1]
	var finish_points: Array = spawn_zones[2] + spawn_zones[3]
	var points : Array = []
			
	var start_point = tile_map.map_to_local(starting_points[rng.randi_range(0, len(starting_points) - 1)])
	var finish_point = tile_map.map_to_local(finish_points[rng.randi_range(0, len(finish_points) - 1)])
	
	points.append(start_point)
	points.append(finish_point)
	SignalBus.spawn_points_ready.emit(free_points, start_point, finish_point)
	return points
		
func generate_background() -> Array[Vector2]:
	#--------------------------------- BACKGROUND ------------------------------
	rng.randomize()
	var free_points : Array[Vector2] = []
	for x in range(map_width):
		for y in range(map_height):
			var cell_coords = Vector2i(x, y + map_offset)
			if is_cell_empty(1, cell_coords):
				tile_map.set_cell(0, cell_coords, 0, BACKGROUND_TILE_COORDINATES, 0)
				free_points.append(Vector2(cell_coords.x, cell_coords.y))
					
	return free_points
					
# Checks if tiles at a specific coord on layer are empty or not
func is_cell_empty(layer, coords):
	var data = tile_map.get_cell_tile_data(layer, coords)
	return data == null

func generate_walls():
	#--------------------------------- Ubreakables ------------------------------
	# Generate walls at the borders
	for x in range(map_width):
		for y in range(map_height):
			if x == 0 or x == map_width - 1 or y == 0 or y == map_height - 1:
				tile_map.set_cell(1, Vector2i(x, y + map_offset), 0, WALL_TILE_COODRINATES, 0)
	
	rng.randomize()
	var wall_chance : float = rng.randf_range(0, chance)
	for x in range(1, map_width - 2):  # Stop before the last column
			for y in range(1, map_height - 2):  # Stop before the last row
				if x % 2 == 0 and y % 2 == 0: # Check if row and column are even
					if rng.randf() < wall_chance:
						tile_map.set_cell(1, Vector2i(x, y + map_offset), 0, WALL_TILE_COODRINATES, 0)
	
	# Define an array for the corners and their safe zones
	spawn_zones = [
		# Near top-left corner
		[Vector2i(1, 1 + map_offset), Vector2i(1, 2 + map_offset), Vector2i(1, 3 + map_offset)],
		# Near top-right corner
		[Vector2i(map_width - 2, 1 + map_offset), Vector2i(map_width - 2, 2 + map_offset), Vector2i(map_width - 2, 3 + map_offset)],
		# Near bottom-left corner
		[Vector2i(1, map_height - 2 + map_offset), Vector2i(1, map_height - 3 + map_offset), Vector2i(1, map_height - 4 + map_offset)],
		# Near bottom-right corner
		[Vector2i(map_width - 2, map_height - 2 + map_offset), Vector2i(map_width - 2, map_height - 3 + map_offset), Vector2i(map_width - 2, map_height - 4 + map_offset)]
	]
	
	# Randomly place more walls
	rng.randomize()
	for x in range(1, map_width - 1):
		for y in range(1, map_height - 1):
			wall_chance = rng.randf_range(0, chance)
			var current_cell = Vector2i(x, y  + map_offset)
			var skip_cell : bool = false
			## Skip cells where solid tiles are placed
			#if x % 2 == 0 and y % 2 == 0:
				#skip_current_cell = true
			# Skip cells in the spawn_zones
			for corner in spawn_zones:
				if current_cell in corner:
					skip_cell = true
			if is_cell_empty(1, current_cell) && !skip_cell:
				if rng.randf() < wall_chance: 
					tile_map.set_cell(1, current_cell, 0, WALL_TILE_COODRINATES, 0)
	
	solid_cells.append_array(tile_map.get_used_cells(1))

func _on_exit_point_body_entered(_body):
	player_hit_finish_point.emit()
