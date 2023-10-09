extends Node3D
class_name ParkingManager

@export var disable_random_amount_of_cars_each_episode := true
@export var disable_parked_cars_count := 1
@export var parked_car_transform_randomness := 0.2

@onready var _parking_spot_manager: ParkingSpotManager = $ParkingSpots

func _ready():
	_parking_spot_manager.parked_car_transform_randomness = parked_car_transform_randomness

func disable_random_cars():
	_parking_spot_manager.disable_random_cars(
		disable_parked_cars_count if not disable_random_amount_of_cars_each_episode 
		else randi_range(1, _parking_spot_manager.total_cars)
	)
	
func get_parking_spots() -> Array[Node3D]:
	return _parking_spot_manager.parking_spots

func get_closest_free_parking_spot_transform(from_global_position: Vector3):
	var closest_distance: float = INF
	var closest_transform: Transform3D
	
	for parking_spot in _parking_spot_manager.parking_spots:
		if not parking_spot.visible:		
			var distance: float = from_global_position.distance_to(parking_spot.global_position) 
			if distance < closest_distance:			
				closest_distance = distance
				closest_transform = parking_spot.global_transform
	
	assert(closest_distance != INF, "Closest distance is INF")
	return closest_transform

func get_random_free_parking_spot_transform():
	return _parking_spot_manager.get_random_free_parking_spot_transform()
