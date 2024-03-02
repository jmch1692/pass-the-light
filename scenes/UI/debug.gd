extends Control

@onready var canvas_layer : CanvasLayer = $CanvasLayer
@onready var npc_spawn_rate_label : Label = $CanvasLayer/NpcSpawnRate
@onready var level_factor_label : Label = $CanvasLayer/LevelFactor
@onready var maze_size_factor_label : Label = $CanvasLayer/MazeSizeFactor
@onready var chance_label : Label = $CanvasLayer/Chance
@onready var maze_width_label : Label = $CanvasLayer/MazeWidth
@onready var maze_height_label : Label = $CanvasLayer/MazeHeight
@onready var retries_label : Label = $CanvasLayer/Retries

var npc_spawn_rate_value : int
var level_factor_value : float
var maze_size_factor_value : float
var chance_value : float
var maze_width_value : float
var maze_height_value : float
var retries_value : int
	
func _draw():
	npc_spawn_rate_label.text += str(npc_spawn_rate_value)
	level_factor_label.text += str(level_factor_value)
	maze_size_factor_label.text += str(maze_size_factor_value)
	chance_label.text += str(chance_value)
	maze_width_label.text += str(maze_width_value)
	maze_height_label.text += str(maze_height_value)
	retries_label.text += str(retries_value)
	

func _on_maze_generator_debug_values(npc_spawn_rate, level_factor, maze_size_factor, chance, maze_width, maze_height, retries):
	npc_spawn_rate_value = npc_spawn_rate
	level_factor_value = level_factor
	maze_size_factor_value = maze_size_factor
	chance_value = chance
	maze_width_value = maze_width
	maze_height_value = maze_height
	retries_value = retries
	
