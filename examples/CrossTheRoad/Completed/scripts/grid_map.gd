extends Node3D
class_name Map

@export var tile: PackedScene

# Grid positions
var instantiated_tiles: Dictionary
var tile_positions: Array[Vector3i]

var player_start_position: Vector3i
var goal_position: Vector3i

## Size of each tile, adjust manually if using larger or smaller tiles
var tile_size: int = 2

## Determines the width of the grid, tested with 6
## may need adjustments for the AIController obs as it captures
## 6 cells from the left and right of the player
var grid_size_x = 6

## Number of rows in the grid
var grid_size_z = 0

var road_rows: Array[int]

var tiles_instantiated: bool = false

## Removes all tile nodes on first launch (if any are added in the editor)
## and on subsequent calls, it hides all tiles
func remove_all_tiles():
	for tile in $Tiles.get_children():
		if not tiles_instantiated:
			tile.queue_free()
		else:
			tile.hide_all()
			
	tile_positions.clear()
	road_rows.clear()
	grid_size_z = 0

## Adds a tile to the grid, takes a scene containing the tile and grid position
func create_tile(tile_name: Tile.TileNames, grid_position: Vector3i):
	if instantiated_tiles.has(grid_position):
		instantiated_tiles[grid_position].set_tile(tile_name)
		tile_positions.append(grid_position)
		return

	var new_tile = tile.instantiate() as Tile
	new_tile.position = grid_position * tile_size
	$Tiles.add_child(new_tile)
	instantiated_tiles[grid_position] = new_tile
	new_tile.set_tile(tile_name)
	tile_positions.append(grid_position)

func _ready():
	set_cells()

## You can set the layout by adjusting each row with set_row_cells()
## Note: Changing size after initial start is not supported
## you can change the order or rows or how many of the second tiles to add
## as long as the total size (number of rows, width) remains the same

func set_cells():
	remove_all_tiles()
	
	add_row(Tile.TileNames.orange, Tile.TileNames.goal, 1)
	add_row(Tile.TileNames.orange)
	add_row(Tile.TileNames.orange, Tile.TileNames.tree, 2)
	add_row(Tile.TileNames.road)
	add_row(Tile.TileNames.orange, Tile.TileNames.tree, 2)
	add_row(Tile.TileNames.orange)
	add_row(Tile.TileNames.orange)
	
	set_player_position_to_last_row()

	tiles_instantiated = true
	
func reset():
	if not is_node_ready():
		await ready
	set_cells()

func get_tile(grid_pos: Vector3i):
	if not grid_pos in tile_positions:
		return null
	return instantiated_tiles[grid_pos]
	

func get_grid_position(global_pos: Vector3i):
	var grid_pos = Vector3i(to_local(global_pos) / 2.0)
	return grid_pos
	
func set_row_tiles(row: int, tile: Tile.TileNames, second_tile: Tile.TileNames = Tile.TileNames.orange, second_tile_count: int = 0):
	var first_tile_columns: Array = range(grid_size_x)
	 
	if second_tile_count:
		for i in second_tile_count:
			first_tile_columns.remove_at(randi_range(0, first_tile_columns.size() - 1))
	
	for column in range(grid_size_x):
		var tile_to_create: Tile.TileNames
		if column in first_tile_columns:
			tile_to_create = tile
		else:
			tile_to_create = second_tile
		var tile_grid_coords := Vector3i(column, 0, row)
		create_tile(tile_to_create, tile_grid_coords)
		if tile_to_create == Tile.TileNames.goal:
			goal_position = tile_grid_coords
		
	if tile == Tile.TileNames.road:
		road_rows.append(row)

func add_row(tile: Tile.TileNames, second_tile: Tile.TileNames = Tile.TileNames.orange, second_tile_count: int = 0):
	set_row_tiles(grid_size_z, tile, second_tile, second_tile_count)
	grid_size_z += 1

func set_player_position_to_grid_row(row: int):
	player_start_position = to_global(Vector3i(range(0, grid_size_x - 1, 2).pick_random(), 0, row * tile_size))
	
func set_player_position_to_last_row():
	set_player_position_to_grid_row(grid_size_z - 1)
