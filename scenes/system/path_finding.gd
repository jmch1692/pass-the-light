extends TileMap

@onready var path : Line2D = %Line2D

var astar_grid : AStarGrid2D
var start_path_at : Vector2i
var finish_path_at : Vector2i

func _ready():
	astar_grid = AStarGrid2D.new()
	
func clear_maze():
	if astar_grid:
		astar_grid.clear()
		path.clear_points()
	self.clear_layer(1)

func compute_path(region_width: int, region_height: int , region_offset: int, start_point: Vector2i, finish_point: Vector2i, obstacles : PackedVector2Array) -> PackedVector2Array:
	astar_grid.region = Rect2i(0, region_offset, region_width, region_height)
	astar_grid.cell_size = Vector2(16, 16)
	astar_grid.offset = astar_grid.cell_size / 2
	astar_grid.update()
	for x in obstacles:
		astar_grid.set_point_solid(x)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	start_path_at = local_to_map(start_point)
	finish_path_at = local_to_map(finish_point)
	var solution = PackedVector2Array(astar_grid.get_point_path(start_path_at, finish_path_at))
	#draw_path()
	return solution

func evaluate_path(potential_path: PackedVector2Array) -> bool:
	if potential_path.is_empty():
		return false
	else: 
		return true

func draw_path():
	for point in PackedVector2Array(astar_grid.get_point_path(start_path_at, finish_path_at)):
		#if astar_grid.is_in_boundsv(point):
		path.add_point(point)
