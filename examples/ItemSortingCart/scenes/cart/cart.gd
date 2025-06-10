extends VehicleBody3D
class_name Cart

var acceleration : float = 15_000
# Used for normalizing velocity for observations, not the exact max velocity
@onready var max_velocity = 12.0

@onready var ai_controller: AIController3D = $AIController3D
@export var destination: Node3D
@export var destination2: Node3D

@export var item: Item

var requested_acceleration: float
var times_restarted: int
var item_collected: int
## Current goal, can be destination or destination2
var goal: Node3D

func get_normalized_velocity():
	return linear_velocity / max_velocity

func _ready():
	ai_controller.init(self)
	reset()

func reset():
	item_collected = 0
	times_restarted += 1

	position.z = randf_range(-5, 5)

	reset_item()

	var state := PhysicsServer3D.body_get_direct_state(get_rid())
	state.linear_velocity = Vector3.ZERO
	state.angular_velocity = Vector3.ZERO
	requested_acceleration = 0
	

func reset_item():
	item.reset()
	goal = destination if item.item_category == 0 else destination2


func _physics_process(delta):
	reset_if_needed()

	if (ai_controller.heuristic != "human"):
		engine_force = (requested_acceleration) * acceleration
	else:
		engine_force = (int(Input.is_key_pressed(KEY_UP)) - int(Input.is_key_pressed(KEY_DOWN))) * acceleration

	reset_if_outside_boundaries()
	if check_item_in_goal():
		ai_controller.reward += 10.0
		reset_item()


func reset_if_outside_boundaries():
	if (position.y < -2 or abs(position.z) > 10):
		ai_controller.reward -= 1.0
		reset()

func reset_if_needed():
	if ai_controller.needs_reset:
		reset()
		ai_controller.reset()


func check_item_in_goal():
	if (
		item_collected and 
		(item.global_position.distance_to(goal.global_position) < goal.scale.z)
	):
		return true
	return false


func _on_item_area_body_entered(body):
	ai_controller.reward += 1.0
	item_collected = 1


func _on_item_area_body_exited(body):
	item_collected = 0


## If the item falls to the ground, gives a negative reward and resets the item
func _on_item_body_entered(body: PhysicsBody3D):
	if body.get_collision_layer_value(3):
		ai_controller.reward -= 1.0
		reset_item()
