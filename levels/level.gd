extends Node2D

#Constants
var level_increase_factor : float = GlobalGameSettings.game_settings["level_increase_factor"]
var maze_increase_factor : int = GlobalGameSettings.game_settings["maze_increase_factor"]

var player_scene = preload("res://scenes/characters/player.tscn")
var saved_npcs : int = 0
var exit_point_ready : bool = false

var player : CharacterBody2D = null
var npc : CharacterBody2D = null

@onready var maze = %MazeGenerator
@onready var game_status = %GameStatus

func refresh_level():
	get_tree().call_deferred("reload_current_scene")

func _input(_event):
	if Input.is_action_just_pressed("ui_reset"):
		refresh_level()

#TODO: Delegate this to spawn manager
func _on_start_point_ready(start_position: Vector2):
	player = player_scene.instantiate()
	self.add_child.call_deferred(player)
	player.position = start_position

func _on_maze_generator_exit_point_ready():
	await get_tree().create_timer(1.0).timeout
	if !exit_point_ready:
		exit_point_ready = true
		maze.player_hit_finish_point.connect(_on_maze_generator_player_hit_finish_point)

func _on_maze_generator_player_hit_finish_point():
	if GlobalGameSettings.game_settings["current_level"] >= 10:
		get_tree().quit()
		
	if exit_point_ready:
		GlobalGameSettings.game_settings["maze_size_factor"] += maze_increase_factor
		GlobalGameSettings.game_settings["level_factor"] += level_increase_factor
		SignalBus.increase_level.emit()
		refresh_level()

func _on_maze_generator_clear_maze(retries: int):
	if retries <= 3:
		refresh_level()
	elif retries == 4:
		# One last attempt, by reducing level factor a bit, and increase maze size
		GlobalGameSettings.game_settings["maze_size_factor"] += maze_increase_factor
		GlobalGameSettings.game_settings["level_factor"] -= level_increase_factor
		refresh_level()
	else:
		print("Unable to solve maze given current factors")
		get_tree().quit()
		#TODO: Else, finish game
	
