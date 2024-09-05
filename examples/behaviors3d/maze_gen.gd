extends Node3D

class_name MazeGenerator3D


@export var maze_scale = 2.0
@export var width: int = 10
@export var height: int = 10
@onready var ground = $Ground   

@onready var wall = preload("res://Wall2.tscn")

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


func generate_level():
    _adjust_ground()
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

    var shift = Vector3(-width*maze_scale/2 + maze_scale/2, 0, -height*maze_scale/2 + maze_scale/2)

    for y in range(height):
        for x in range(width):
            var cell = grid[y][x]
            if cell.NORTH:
                var wall_instance = wall.instantiate()
                wall_instance.translate(Vector3(x*maze_scale, 0, y*maze_scale-maze_scale/2) + shift)
                add_child(wall_instance)
            if cell.EAST:
                var wall_instance = wall.instantiate()
                wall_instance.translate(Vector3(x*maze_scale + maze_scale/2, 0, y*maze_scale) + shift)
                wall_instance.rotate(Vector3(0, 1, 0), PI / 2)
                add_child(wall_instance)
            if cell.SOUTH:
                var wall_instance = wall.instantiate()
                # wall_instance.rotate(Vector3(0, 1, 0), PI)
                wall_instance.translate(Vector3(x*maze_scale, 0, y*maze_scale+ maze_scale/2) + shift)
                add_child(wall_instance)
            if cell.WEST:
                var wall_instance = wall.instantiate()
                wall_instance.translate(Vector3(x*maze_scale-maze_scale/2, 0, y*maze_scale) + shift)
                wall_instance.rotate(Vector3(0, 1, 0), PI / 2)
                add_child(wall_instance)
    

func _adjust_ground() -> void:
    ground.size = Vector3(width*maze_scale, 1, height*maze_scale)

    get_node("Walls/Left").position = Vector3(-ground.size.x/2, 0, 0)
    get_node("Walls/Right").position = Vector3(ground.size.x/2, 0, 0)
    get_node("Walls/Forward").position = Vector3(0, 0, -ground.size.z/2)
    get_node("Walls/Backward").position = Vector3(0, 0, ground.size.z/2)

func get_spawn_location() -> Vector3:
    return Vector3(
        randf_range(-ground.size.x/2, ground.size.x/2), 
        5,
        randf_range(-ground.size.z/2, ground.size.z/2)
    )

func get_target_location() -> Vector3:
    var target= Vector3(
        floor(randf_range(-ground.size.x/4, ground.size.x/4))*2 +1, 
        5,
        floor(randf_range(-ground.size.z/4, ground.size.z/4))*2 +1
    )
    print(target)
    return target

