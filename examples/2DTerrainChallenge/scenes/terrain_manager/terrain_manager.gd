extends StaticBody2D
class_name TerrainManager

@onready var terrain_polygon: Polygon2D = $Polygon2D
@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon2D

@export_group("Terrain settings")
@export var fixed_seed: bool = false
@export var x_point_count: float = 300
@export var x_offset_between_points: int = 200
@export var y_offset_multiplier: float = 1400
@export var octaves: int = 3
@export var frequency: float = 0.05

var noise: FastNoiseLite = FastNoiseLite.new()
var _point_heights: Array[float]


func _init() -> void:
	noise.frequency = frequency
	noise.fractal_octaves = octaves
	noise.fractal_lacunarity = 1.5


func generate_terrain():
	_point_heights.clear()

	noise.seed = randi() if not fixed_seed else 0
	var x_points = x_point_count
	var x_offset = x_offset_between_points
	var max_y_offset = y_offset_multiplier

	var new_poly := PackedVector2Array()

	var point_height: float

	var start_end_area_point_size: float = 150

	for point_idx in range(0, x_points):
		point_height = noise.get_noise_1d(point_idx) * max_y_offset

		if point_idx < start_end_area_point_size:
			point_height *= 1 - (start_end_area_point_size - point_idx) / start_end_area_point_size
		elif point_idx >= (x_points - start_end_area_point_size):
			point_height *= (x_points - point_idx - 1) / (start_end_area_point_size)

		var point := Vector2(point_idx * x_offset, point_height)
		new_poly.append(point)
		_point_heights.append(point_height)

	point_height = noise.get_noise_1d(x_points - 1) * max_y_offset
	(
		new_poly
		. append_array(
			[
				Vector2((x_points - 1) * x_offset, max_y_offset + 1000),
				Vector2(0, max_y_offset + 1000),
			]
		)
	)

	collision_polygon.call_deferred("set_polygon", new_poly)
	terrain_polygon.polygon = new_poly


func get_terrain_length() -> float:
	return x_point_count * x_offset_between_points


func get_goal_position(x_offset_from_end, y_offset) -> Vector2:
	return get_terrain_position(
		(x_point_count * x_offset_between_points) - x_offset_from_end, y_offset
	)


func get_terrain_position(x_offset, y_offset) -> Vector2:
	var scaled_x_offset = int(x_offset) / int(x_offset_between_points)
	if scaled_x_offset < 0 or scaled_x_offset >= _point_heights.size():
		return Vector2(0.0, 0.0)

	return Vector2(
		global_position.x + x_offset, global_position.y + _point_heights[scaled_x_offset] + y_offset
	)
