extends Node

# Minimum factors
const minimum_npc_to_place : int = 1

# Exports
var max_npc_to_place : int = minimum_npc_to_place

#Pre-loads
var npc_scene = preload("res://scenes/npc/npc.tscn")
var trap_scene = preload("res://scenes/traps/hidden_trap.tscn")

#Nodes
@onready var tile_map = %TileMap

#local vars
var final_start_point : Vector2
var final_finish_point : Vector2
var final_free_points : Array[Vector2]
var level_factor : float = 0.0
var rng = RandomNumberGenerator.new()
var npc : CharacterBody2D = null
var trap_types : Array[TrapType.Type] = [
	TrapType.Type.BLINDNESS,
	TrapType.Type.CONFUSION
]

func _ready():
	SignalBus.spawn_points_ready.connect(_on_spawn_points_ready.bind())
	level_factor = GlobalGameSettings.game_settings["level_factor"]

func is_valid_spawn_point(point: Vector2) -> bool:
	var valid : bool = true
	if final_start_point == point or final_start_point == point:
		valid = false
	
	if are_points_too_close(final_start_point, point, 10):
		valid = false
		
	if are_points_too_close(final_finish_point, point, 10):
		valid = false
	
	return valid

func _on_spawn_points_ready(free_points: Array[Vector2], start_point: Vector2i, finish_point: Vector2i):
	final_start_point = start_point
	final_finish_point = finish_point
	final_free_points = free_points.filter(is_valid_spawn_point)
	
	final_free_points.sort()
	
	locate_spawn_points(final_free_points)

func are_points_too_close(point_a: Vector2, point_b: Vector2, distance_max: int) -> bool:
	if point_a.distance_to(point_b) <= distance_max:
		return true
	return false

func locate_spawn_points(potential_spawn_points : Array[Vector2]):
	rng.randomize()
	var number_of_traps : int = ceili(level_factor) * 2
	max_npc_to_place *= floori(level_factor) * 2
	for npc_spawn in max_npc_to_place:
		var npc_spawn_point = potential_spawn_points.pick_random()
		spawn_npc(npc_spawn_point)
		# Lambda to remove the point we just used to spawn
		potential_spawn_points.filter(func(point): return point != npc_spawn_point)
	
	rng.randomize()
	for potential_trap in number_of_traps:
		var trap_selected = trap_types.pick_random()
		var trap_spawn_point = potential_spawn_points.pick_random()
		spawn_trap(trap_spawn_point, trap_selected)
		potential_spawn_points.filter(func(point): return point != trap_spawn_point)

func spawn_npc(spawn_point: Vector2):
	npc = npc_scene.instantiate()
	self.call_deferred("add_sibling", npc)
	npc.position = tile_map.map_to_local(spawn_point)

func spawn_trap(spawn_point: Vector2, trap_selected: TrapType.Type):
	var trap : Trap = trap_scene.instantiate()
	trap.trap_type = trap_selected
	self.call_deferred("add_sibling", trap)
	trap.position = tile_map.map_to_local(spawn_point)
