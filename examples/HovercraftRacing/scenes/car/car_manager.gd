extends Node3D

class_name CarManager

@export var track: Track
@export var car_scene: PackedScene

## Each car group consists of 2 cars
@export var number_of_car_groups_to_spawn: int = 2

var ui: UI

var training_mode: bool = true
var player_vs_ai_mode: bool = false
var infinite_race: bool = true
var total_laps: int
var seconds_until_race_begins: int


# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_cars(number_of_car_groups_to_spawn)


func spawn_cars(car_group_amount):
	if not training_mode:
		car_group_amount = 1

	var car1color: Color = Color.from_hsv(randf_range(0, 1), 0.6, 0.6)
	var car2color: Color = car1color
	car2color.h = fmod(car1color.h + randf_range(0.2, 0.8), 1.0)

	var player_car_id: int = randi_range(0, 1)

	for group_id in range(0, car_group_amount):
		var spawned_cars: Array[Car] = []

		for car_id in range(0, 2):
			var car = car_scene.instantiate() as Car
			car.name = "AI-%d%d" % [group_id, car_id]
			car.track = track

			# Detect collision with walls
			car.set_collision_mask_value(1, true)

			# Detect collision with other car
			var current_car_layer := 2 + car_id + (group_id * 2)
			var other_car_layer := 2 + ((car_id + 1) % 2) + (group_id * 2)
			car.set_collision_layer_value(current_car_layer, true)
			car.set_collision_mask_value(other_car_layer, true)

			var car_transform: Transform3D = track.track_path.curve.sample_baked_with_rotation(0.0)
			car_transform = car_transform.rotated_local(Vector3.UP, PI)
			car_transform.origin += Vector3.UP
			car_transform.origin += car_transform.basis.x * (car_id * 2.0 - 1.5)
			car.global_transform = car_transform

			car.infinite_race = infinite_race
			car.total_laps = total_laps
			car.ui = ui
			car.seconds_until_race_begins = seconds_until_race_begins
			car.training_mode = training_mode

			var car_body: MeshInstance3D = car.get_node("car_base/Body") as MeshInstance3D
			var new_material: StandardMaterial3D = (
				car_body.get_active_material(0).duplicate() as StandardMaterial3D
			)

			var color: Color = car1color if car_id == 0 else car2color
			new_material.albedo_color = color
			car_body.set_surface_override_material(0, new_material)

			spawned_cars.append(car)
			add_child(car)

			if car_id == 1:
				car.other_car = spawned_cars[0]
				spawned_cars[0].other_car = car

			if player_vs_ai_mode and player_car_id == car_id:
				car.name = "Player"
				car.get_node("Camera3D").current = true
				car.get_node("CarAIController").human_controlled_on_inference = true

			# Raycast detect collision with other car
			car.raycast_sensor_other_car.set_collision_mask_value(other_car_layer, true)
			car.ai_controller.track = track

			car.reset()
