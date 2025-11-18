extends Node3D
class_name Turret

@export var goal: Goal
## Aims at a new target after set time
@export var reset_after_seconds := 2.0
@onready var aim_node: Node3D = $turret/Icosphere
@onready var ball := $Ball

var target_transform: Transform3D
var target_location: Vector3
var is_aiming := false
var reset_timer: float


func _ready():
	# Make the ball invisible until the first launch
	ball.visible = false
	ball.global_position = aim_node.global_position
	reset()


func reset():
	aim_at(get_random_goal_position())


func get_random_goal_position():
	return goal.global_position + Vector3(randf_range(-3, 3), randi_range(0, 1) * 4, 0.0)


func launch_ball():
	ball.global_position = aim_node.global_position + aim_node.global_basis.z
	ball.shoot(target_location, 36)
	if not ball.visible:
		ball.visible = true


func _physics_process(delta: float) -> void:
	reset_timer += delta
	if is_aiming:
		aim_node.global_transform = aim_node.global_transform.interpolate_with(target_transform, delta * 10)
		if aim_node.global_transform.is_equal_approx(target_transform):
			is_aiming = false
			launch_ball()
	if reset_timer > reset_after_seconds:
		reset_timer = 0
		reset()


func get_current_aiming_orientation_obs() -> Array[float]:
	return [aim_node.basis.z.x, aim_node.basis.z.y, aim_node.basis.z.z]


func aim_at(location: Vector3):
	if not is_node_ready():
		await ready

	target_transform = aim_node.global_transform.looking_at(location, Vector3.UP, true)
	target_location = location
	is_aiming = true
