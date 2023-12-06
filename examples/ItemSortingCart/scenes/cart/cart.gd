extends VehicleBody3D
class_name Cart

var acceleration : float = 350
@onready var max_velocity = acceleration / mass * 40

@onready var ai_controller: AIController3D = $AIController3D
@export var destination: Node3D
@export var destination2: Node3D

@export var item: Item

var requested_acceleration: float
var initial_position: Vector3
var times_restarted: int
var item_collected: int

func get_normalized_velocity():
	return linear_velocity.normalized() * (linear_velocity.length() / max_velocity)

func _ready():
	initial_position = position
	ai_controller.init(self)

func reset():
	item_collected = 0
	times_restarted += 1

	position = Vector3(0, 0, randf_range(-8, 8))
	rotation = Vector3.ZERO

	reset_item()

	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	pass

func reset_item():
	var item_position : Vector3 = Vector3(0, 20, randf_range(-0.0, 0.0))
	item.position = item_position
	item.rotation = Vector3.ZERO
	item.linear_velocity = Vector3.ZERO
	item.angular_velocity = Vector3.ZERO
	item.apply_central_force(Vector3(0.0, 0.0, randf_range(-70.0, 70.0)))
	item.force_update_transform()
	item.sleeping = false
	item.set_category(randi_range(0, 1))

func _physics_process(delta):
	reset_if_needed()
	update_reward()

	if (ai_controller.heuristic != "human"):
		engine_force = (requested_acceleration) * acceleration
	else:
		engine_force = (int(Input.is_key_pressed(KEY_UP)) - int(Input.is_key_pressed(KEY_DOWN))) * acceleration

	restart_if_outside_boundaries()
	pass

func restart_if_outside_boundaries():
	if (position.y < -2 or abs(position.z) > 10):
		ai_controller.reward -= 1.0
		ai_controller.needs_reset = true
		ai_controller.done = true

func reset_if_needed():
	if ai_controller.needs_reset:
		reset()
		ai_controller.reset()

## The reward function uses a simple form of curriculum learning, where initially
## a shaped reward tells the agent to move toward the item horizontally until it collects it,
## and after some episodes, only the sparse reward for collecting and delivering the item rewards.
func update_reward():
	if times_restarted < 50:
		if not item_collected:
			ai_controller.reward -= 0.00001 * (item.position.z - position.z)
		else:
			if item.item_category == 0:
				ai_controller.reward -= 0.00001 * (destination.position.z - position.z)
			else:
				ai_controller.reward -= 0.00001 * (destination2.position.z - position.z)

	if item_collected:
		if (position.distance_to(destination.position) < destination.scale.z):
			if item.item_category == 0:
				ai_controller.reward += 1.0
			else:
				ai_controller.reward -= 1.0
			reset_item()
		elif (position.distance_to(destination2.position) < destination2.scale.z):
			if item.item_category == 1:
				ai_controller.reward += 1.0
			else:
				ai_controller.reward -= 1.0
			reset_item()

func _on_item_area_body_entered(body):
	ai_controller.reward += 1.0
	item_collected = 1

func _on_item_area_body_exited(body):
	item_collected = 0

## If the item falls to the ground, gives a negative reward and resets the item
func _on_item_body_entered(body: PhysicsBody3D):
	if body.get_collision_layer_value(3):
		ai_controller.reward -= 0.05
		reset_item()
