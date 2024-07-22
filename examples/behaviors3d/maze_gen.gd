extends Node3D

class_name MazeGenerator3D
# const DIRECTIONS = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]

@export var width: int = 10
@export var height: int = 10
@onready var wall = preload("res://Wall2.tscn")
# var grid: Array[Array]
# var wall_scene: PackedScene

# func init(w: int, h: int) -> void:
#     width = w
#     height = h
#     grid = []
#     for y in range(height):
#         var row: Array[int] = []
#         for x in range(width):
#             row.append(1)  # 1 represents a wall
#         grid.append(row)
	
#     wall_scene = preload("res://wall.tscn")  # Assume you have a Wall.tscn with a Box node

# func generate_maze() -> void:
#     var start := Vector2i(1, 1)
#     grid[start.y][start.x] = 0  # 0 represents a path
#     var walls := get_neighboring_walls(start)
	
#     while not walls.is_empty():
#         var wall = walls.pop_at(randi() % walls.size())
#         var neighbors := get_cell_neighbors(wall)
		
#         var path_count = neighbors.filter(func(cell): return grid[cell.y][cell.x] == 0).size()
		
#         if path_count == 1:
#             grid[wall.y][wall.x] = 0
#             var new_walls = get_neighboring_walls(wall)
#             walls.append_array(new_walls)

# func get_neighboring_walls(cell: Vector2i) -> Array[Vector2i]:
#     var walls: Array[Vector2i] = []
#     for dir in DIRECTIONS:
#         var neighbor = cell + dir * 2
#         if is_valid_cell(neighbor) and grid[neighbor.y][neighbor.x] == 1:
#             walls.append(neighbor - dir)
#     return walls

# func get_cell_neighbors(cell: Vector2i) -> Array[Vector2i]:
#     var neighbors: Array[Vector2i] = []
#     for dir in DIRECTIONS:
#         var neighbor = cell + dir
#         if is_valid_cell(neighbor):
#             neighbors.append(neighbor)
#     return neighbors

# func is_valid_cell(cell: Vector2i) -> bool:
#     return cell.x > 0 and cell.x < width - 1 and cell.y > 0 and cell.y < height - 1

# func instantiate_maze() -> void:
#     for y in range(height):
#         for x in range(width):
#             if grid[y][x] == 1:  # If it's a wall
#                 var wall: Node3D = wall_scene.instantiate()
#                 add_child(wall)
#                 wall.translate(Vector3(x, 0.5, y))  # Position the cube

# func print_maze() -> void:
#     print("Maze:")
#     for row in grid:
#         var line := ""
#         for cell in row:
#             line += "#" if cell == 1 else " "
#         print(line)


class MazeCell:
	var NORTH: bool = true
	var EAST: bool = true
	var SOUTH: bool = true
	var WEST: bool = true
	var VISITED: bool = false
	var position: Vector2i

	func _init(pos:Vector2i):
		VISITED = false
		position = pos



func get_unvisited_neighbors(grid: Array, cell: MazeCell) -> Array[MazeCell]:
	var neighbors : Array[MazeCell]= []
	var x = cell.position.x
	var y = cell.position.y

	if x > 0 and not grid[y][x - 1].VISITED:
		neighbors.append(grid[y][x - 1])
	if x < grid[0].size() - 1 and not grid[y][x + 1].VISITED:
		neighbors.append(grid[y][x + 1])
	if y > 0 and not grid[y - 1][x].VISITED:
		neighbors.append(grid[y - 1][x])
	if y < grid.size() - 1 and not grid[y + 1][x].VISITED:
		neighbors.append(grid[y + 1][x])

	return neighbors

func remove_wall(current: MazeCell, next: MazeCell) -> void:
	var x = current.position.x - next.position.x
	if x == 1:
		current.WEST = false
		next.EAST = false
	elif x == -1:
		current.EAST = false
		next.WEST = false

	var y = current.position.y - next.position.y
	if y == 1:
		current.NORTH = false
		next.SOUTH = false
	elif y == -1:
		current.SOUTH = false
		next.NORTH = false


func generate_maze2():
	var grid = []
	for y in range(height):
		var row: Array[MazeCell] = []
		for x in range(width):
			row.append(MazeCell.new(Vector2i(x, y)))
		grid.append(row)

	var stack = []
	var current = grid[0][0]
	current.VISITED = true
	stack.append(current)

	while stack.size() > 0:
		var neighbors = get_unvisited_neighbors(grid, current)
		if neighbors.size() > 0:
			var next = neighbors[randi() % neighbors.size()]
			remove_wall(current, next)
			next.VISITED = true
			stack.append(next)
			current = next
		else:
			current = stack.pop_back()

	for y in range(height):
		for x in range(width):
			var cell = grid[y][x]
			if cell.NORTH:
				var wall_instance = wall.instantiate()
				wall_instance.translate(Vector3(x, 0, y-0.5))
				add_child(wall_instance)
			if cell.EAST:
				var wall_instance = wall.instantiate()
				wall_instance.translate(Vector3(x + 0.5, 0, y))
				wall_instance.rotate(Vector3(0, 1, 0), PI / 2)
				add_child(wall_instance)
			if cell.SOUTH:
				var wall_instance = wall.instantiate()
				# wall_instance.rotate(Vector3(0, 1, 0), PI)
				wall_instance.translate(Vector3(x, 0, y+ 0.5))
				add_child(wall_instance)
			if cell.WEST:
				var wall_instance = wall.instantiate()
				wall_instance.translate(Vector3(x-0.5, 0, y))
				wall_instance.rotate(Vector3(0, 1, 0), PI / 2)
				add_child(wall_instance)



# Example usage
func _ready() -> void:
	generate_maze2()
	# init(width, height)
	# generate_maze()
	# instantiate_maze()
	# print_maze()
