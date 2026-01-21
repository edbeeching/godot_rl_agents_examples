extends GridSensor2D

## Simple modification to enable detecting a single physics layer of tilemap
## without needing to check the collision layer of the specific tile
## it also clamps all observation values to 0-1 range, and overrides some of 
## the export variable ranges.
## Note: Meant to be used with only a single `detection mask` layer per sensor 

@export_range(1, 10_000, 0.1) var cell_width_override := 20.0
@export_range(1, 10_000, 0.1) var cell_height_override := 20.0
@export_range(1, 21, 1, "or_greater") var grid_size_x_override := 2
@export_range(1, 21, 1, "or_greater") var grid_size_y_override := 1


func _ready() -> void:
	cell_width = cell_width_override
	cell_height = cell_height_override
	grid_size_x = grid_size_x_override
	grid_size_y = grid_size_y_override
	super._ready()

func get_observation():
	# There can be more than one object in a cell at a time
	# to simplify the obs, we clamp the values to 0-1 range
	var obs: Array[float]
	obs.resize(_obs_buffer.size())
	for obs_idx in _obs_buffer:
		obs[obs_idx] = clampf(_obs_buffer[obs_idx], 0, 1)
	return obs

func _on_cell_body_entered(_body: Node2D, cell_i: int, cell_j: int):
	#prints("_on_cell_body_entered", cell_i, cell_j)
	_update_obs(cell_i, cell_j, detection_mask, true)
	if debug_view:
		_toggle_cell(cell_i, cell_j)


func _on_cell_body_exited(_body: Node2D, cell_i: int, cell_j: int):
	#prints("_on_cell_body_exited", cell_i, cell_j)
	_update_obs(cell_i, cell_j, detection_mask, false)
	if debug_view:
		_toggle_cell(cell_i, cell_j)
