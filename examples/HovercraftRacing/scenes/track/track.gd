extends Node3D
class_name Track

@export var track_path: Path3D

@export_group("Checkpoint objects to add to the track:")
@export var checkpoints: Array[PackedScene]
@export var checkpoint_frequency_meters: int

@export_group("Tree objects to add to the track:")
@export var trees: Array[PackedScene]
@export var tree_frequency_meters: int

@export_group("Rock objects to add to the track:")
@export var rocks: Array[PackedScene]
@export var rock_frequency_meters: int

@export_group("Powerup objects to add to the track:")
@export var powerup_scene: Array[PackedScene]

var powerups: Array[Powerup]

## Training mode disables generating decoration objects
var training_mode: bool = false

var _random: RandomNumberGenerator = RandomNumberGenerator.new()

@onready var starting_line = $StartingLine

# Called when the node enters the scene tree for the first time.
func _ready():
	_random.seed = 10
	instantiate_powerups_on_track()
	starting_line.global_transform = get_starting_position()

	if not training_mode:
		instantiate_scene_instances_on_track(checkpoints, checkpoint_frequency_meters)
		instantiate_scene_instances_on_track(trees, tree_frequency_meters, true, true)
		instantiate_scene_instances_on_track(rocks, rock_frequency_meters, true, true)


func get_starting_position() -> Transform3D:
	return track_path.curve.sample_baked_with_rotation(0.0)


func instantiate_scene_instances_on_track(
	scene: Array[PackedScene],
	frequency_meters: int,
	randomize_instances_outside_track: bool = false,
	randomize_rotation: bool = false
):
	for offset in range(frequency_meters, track_path.curve.get_baked_length(), frequency_meters):
		var instance: Node3D = scene[_random.randi_range(0, scene.size() - 1)].instantiate()
		add_child(instance)
		instance.global_transform = track_path.curve.sample_baked_with_rotation(offset)
		if randomize_instances_outside_track:
			var direction: int = 1 if _random.randi_range(0, 1) == 0 else -1
			var z_random_range = frequency_meters / 25.0
			var x_min_distance = 15.0
			var x_random_distance_max_offset = 5.0
			instance.global_transform.origin += (
				(instance.global_basis.z * _random.randf_range(-z_random_range, z_random_range))
				+ (
					instance.global_basis.x
					* direction
					* (x_min_distance + _random.randf_range(0, x_random_distance_max_offset))
				)
			)
		if randomize_rotation:
			instance.rotate_y(_random.randf_range(-PI, PI))


func instantiate_powerups_on_track():
	var min_powerup_distance := 40.0

	var powerup_offsets: Array[float] = []
	for offset in range(
		min_powerup_distance, track_path.curve.get_baked_length(), min_powerup_distance
	):
		powerup_offsets.append(offset)

	# Randomly remove some powerups
	for i in range(0, (powerup_offsets.size() / 2.0)):
		powerup_offsets.remove_at(_random.randi_range(0, powerup_offsets.size() - 1))

	for offset in powerup_offsets:
		# Place a random powerup
		var instance: Powerup = (
			powerup_scene[_random.randi_range(0, powerup_scene.size() - 1)].instantiate()
		)
		add_child(instance)
		instance.global_transform = track_path.curve.sample_baked_with_rotation(offset)
		var random_direction = 1 if _random.randi_range(0, 1) == 0 else -1
		instance.global_transform.origin += instance.basis.x * random_direction * 1.25
		powerups.append(instance)


func get_closest_powerup(from_global_position: Vector3) -> Powerup:
	var smallest_distance = INF
	var closest_powerup: Powerup
	for powerup in powerups:
		var distance = powerup.global_position.distance_to(from_global_position)
		if distance < smallest_distance:
			smallest_distance = distance
			closest_powerup = powerup
	return closest_powerup
