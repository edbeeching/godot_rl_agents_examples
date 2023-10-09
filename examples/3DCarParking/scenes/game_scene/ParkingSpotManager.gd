extends Node3D
class_name ParkingSpotManager

var total_cars: int
var parking_spots: Array[Node3D]
var free_parking_spots: Array[Node3D]
var parked_car_transform_randomness

func _ready():
	total_cars = get_child_count()
	parking_spots.append_array(get_children())
	
func disable_random_cars(number_of_cars_to_disable: int):
	assert(number_of_cars_to_disable <= total_cars,
	"Can't disable more than the total number of parking_spots.")
	var disabled_cars: int = 0
	free_parking_spots.clear()

	parking_spots.shuffle()
	
	for parking_spot in parking_spots:
		if disabled_cars < number_of_cars_to_disable:
			parking_spot.process_mode = Node.PROCESS_MODE_DISABLED
			parking_spot.hide()
			free_parking_spots.append(parking_spot)
		else:
			parking_spot.process_mode = Node.PROCESS_MODE_INHERIT
			parking_spot.show()
			
			var car: Node3D = parking_spot.get_child(0)
			randomize_car_transform(car, parking_spot)
			randomize_car_color(car)
		disabled_cars += 1

func randomize_car_color(car: Node3D):
	car.randomize_color()
	
func randomize_car_transform(car: Node3D, parking_space: Node3D):
	var randomness = parked_car_transform_randomness
	var rotation_randomness = randomness * 0.35
	var parking_space_position = parking_space.global_position
	
	car.global_position.x = parking_space_position.x + randf_range(-randomness, randomness)
	car.global_position.z = parking_space_position.z + randf_range(-randomness, randomness)
	car.global_rotation.y = parking_space.global_rotation.y + randf_range(-rotation_randomness, rotation_randomness)

func get_random_free_parking_spot_transform():
	return free_parking_spots.pick_random().global_transform
