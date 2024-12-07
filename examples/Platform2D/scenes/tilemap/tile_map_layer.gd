extends TileMapLayer
class_name MapManager


## Maps tile names to tileset atlas coordinates
class Tiles:
	const PLATFORM_LEFT_EDGE = Vector2i(0, 0)
	const PLATFORM_MIDDLE = Vector2i(1, 0)
	const PLATFORM_RIGHT_EDGE = Vector2i(2, 0)
	const GROUND = Vector2i(0, 1)  # currently not used
	const GROUND_2 = Vector2i(1, 1)  # currently not used
	const SPIKES = Vector2i(2, 1)
	const COIN = Vector2i(0, 2)
	const GOAL = Vector2i(1, 2)


@export var rows_between_walkable_platforms: int = 3
## Must be a multiple of rows_between_walkable_platforms
@export var total_rows: int = 40
@export var total_columns: int = 10

## Coin parameters
@export var max_coins := 200
@export var max_coins_per_row := 5

## Remaining coin count
var remaining_coins := 0

## Goal position in global coordinates
var goal_position: Vector2


func _ready() -> void:
	update_map()


func update_map():
	clear_map()
	build_map()


func clear_map():
	remaining_coins = 0
	clear()


func build_map():
	var coins_total = 0

	for y in range(0, total_rows, rows_between_walkable_platforms):
		var coins_in_row = 0
		var walkable_tiles_in_row = total_columns
		# Place a walkable platform
		for x in range(0, total_columns):
			set_cell(Vector2i(x, y), 0, Tiles.PLATFORM_MIDDLE)

		# Carve passages on all but the last platform row
		if y < total_rows - rows_between_walkable_platforms:
			# Carve out up to 5 passages down at random coords
			for i in range(total_columns - 1):
				var rand_x = randi_range(1, total_columns - 2)
				if y > 0:
					# Carve only where there is no carved passage at the same column in the previous platform row
					while (
						get_cell_atlas_coords(Vector2i(rand_x, y - rows_between_walkable_platforms))
						== Vector2i(-1, -1)
					):
						rand_x = randi_range(1, total_columns - 2)

				if not (
					get_cell_atlas_coords(Vector2i(rand_x, y)) == Tiles.PLATFORM_MIDDLE
					and get_cell_atlas_coords(Vector2i(rand_x - 1, y)) == Tiles.PLATFORM_MIDDLE
					and get_cell_atlas_coords(Vector2i(rand_x + 1, y)) == Tiles.PLATFORM_MIDDLE
				):
					continue

				erase_cell(Vector2i(rand_x, y))
				walkable_tiles_in_row -= 1
				set_cell(Vector2i(rand_x - 1, y), 0, Tiles.PLATFORM_RIGHT_EDGE)
				set_cell(Vector2i(rand_x + 1, y), 0, Tiles.PLATFORM_LEFT_EDGE)

		# COINS: Add random coin only if there is no passage below the row
		if y < total_rows - 1 and coins_total < max_coins:
			while coins_in_row < max_coins_per_row and coins_in_row < walkable_tiles_in_row:
				var rand_x = randi_range(0, total_columns - 1)
				var current_cell_coord = get_cell_atlas_coords(Vector2i(rand_x, y))
				var above_cell_coord = get_cell_atlas_coords(Vector2i(rand_x, y - 1))

				if (
					(current_cell_coord != Vector2i(-1, -1))
					and (above_cell_coord == Vector2i(-1, -1))
				):
					var coin_pos := Vector2i(rand_x, y - 1)
					set_cell(coin_pos, 0, Tiles.COIN)
					coins_total += 1
					remaining_coins += 1
					coins_in_row += 1

		# TRAPS: Add traps (up to 1 per row, depending on coins placed)
		if y > 0:
			var rand_x = randi_range(0, total_columns - 1)
			var current_cell_coord = get_cell_atlas_coords(Vector2i(rand_x, y))
			var previous_row_cell_coord = get_cell_atlas_coords(
				Vector2i(rand_x, y - rows_between_walkable_platforms)
			)
			var above_cell_coord = get_cell_atlas_coords(Vector2i(rand_x, y - 1))

			if (
				(previous_row_cell_coord != Vector2i(-1, -1))
				and (above_cell_coord == Vector2i(-1, -1))
				and (current_cell_coord == Tiles.PLATFORM_MIDDLE)
			):
				var spike_pos := Vector2i(rand_x, y - 1)
				remove_coin_from_position(spike_pos, false)
				set_cell(spike_pos, 0, Tiles.SPIKES)

		# GOAL: Add 1 goal on the last level
		if y == total_rows - rows_between_walkable_platforms:
			var rand_x = randi_range(0, total_columns - 1)
			var goal_pos := Vector2i(rand_x, y - 1)
			remove_coin_from_position(goal_pos, false)
			set_cell(goal_pos, 0, Tiles.GOAL)
			goal_position = to_global(map_to_local(goal_pos))


func count_coins_in_grid_row(grid_y: int) -> int:
	var coins := 0
	for x in total_columns:
		if get_cell_atlas_coords(Vector2i(x, grid_y)) == Tiles.COIN:
			coins += 1
	return coins


func remove_coin_from_position(grid_position: Vector2i, clear_cell := true):
	if get_cell_atlas_coords(grid_position) == Tiles.COIN:
		remaining_coins -= 1
		if clear_cell: set_cell(grid_position, -1)


func get_grid_pos(position_global: Vector2) -> Vector2i:
	return local_to_map(to_local(position_global))


func reset():
	call_deferred("update_map")
