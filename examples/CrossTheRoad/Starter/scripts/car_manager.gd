extends Node3D
class_name CarManager

@export var map: Map
@export var car_scene: PackedScene

var car_left_edge_x: int
var car_right_edge_x: int

@onready var cars: Array[Node] = get_children()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for road_row_idx in map.road_rows.size():
		create_car()
	reset()


func create_car():
		var new_car = car_scene.instantiate()
		add_child(new_car)
		cars.append(new_car)


func reset():
	# If there are more cars than the current map layout road rows, remove 
	# the extra cars
	while cars.size() > map.road_rows.size():
		cars[cars.size() - 1].queue_free()
		cars.remove_at(cars.size() - 1)
		
	# If there are less cars than the current map layout road rows,
	# add more cars
	while cars.size() < map.road_rows.size():
		create_car()

	# Set car edge positions (at which they turn), position and other properties
	for car_id in cars.size():
		var car = cars[car_id]
		car.left_edge_x = 0
		car.right_edge_x = (map.grid_size_x - 1) * map.tile_size
		car.step_size = map.tile_size
		
		car.position.x = range(car.left_edge_x + 2, car.right_edge_x - 2, 2).pick_random()
		car.position.y = map.tile_size / 2 + 0.75 # 0.75 is to make the bottom of the car be at road height
		car.position.z = map.road_rows[car_id] * 2

		car.current_direction = 1 if randi_range(0, 1) == 0 else -1
