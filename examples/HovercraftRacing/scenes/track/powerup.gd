extends Area3D
class_name Powerup

## Direction of impulse that the powerup adds,
## e.g. Vector3(0, 0, -1) would add a forward impulse to the powerup
@export var impulse_direction_relative_to_powerup: Vector3 = Vector3(0.0, 0.0, 1.0)
@export var impulse_to_apply: float = 15

## Used for observations, one hot encoded category, array size should match on all powerups
@export var category_as_array_one_hot_encoded: Array[int] = [0, 1]

@export var ai_controller_reward := 0.0


func _on_body_entered(body):
	var car = body as Car
	if car:
		car.apply_central_impulse(global_transform.basis * impulse_direction_relative_to_powerup * impulse_to_apply)
		car.ai_controller.reward += ai_controller_reward
