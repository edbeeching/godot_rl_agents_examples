extends AIController2D
class_name PlayerAIController

@onready var player := get_parent() as Player
@onready var camera_sensor := $RGBCameraSensor2D


func _physics_process(delta):
	n_steps += 1

	if n_steps > reset_after:
		player.game_over()

	# In case of human control, we call set action without providing action values
	if control_mode == ControlModes.HUMAN:
		set_action()


func end_episode():
	done = true
	reset()


func get_obs_space():
	#var vector_obs_shape = [get_vector_obs().size()]
	var image_obs_shape = camera_sensor.get_camera_shape()
	return {
		#"obs": {"size": vector_obs_shape, "space": "box"},
		"camera_2d": {"size": image_obs_shape, "space": "box"},
	}


func get_image_obs() -> String:
	return camera_sensor.get_camera_pixel_encoding()


# Uncomment if using some vector obs
# (make sure to also uncomment the sections in get_obs_space/get_obs)
#func get_vector_obs() -> Array:
	#var vector_obs: Array
	#return vector_obs


func get_obs():
	return {
		#"obs": get_vector_obs(),
		"camera_2d": get_image_obs(),
	}


func get_reward() -> float:
	return reward


func get_action_space() -> Dictionary:
	return {"move_action": {"size": 2, "action_type": "continuous"}}


func set_action(action = null) -> void:
	# In case of human control, we use user input:
	if not action:
		player.requested_movement = Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_down") - Input.get_action_strength("move_up"),
		)
	else:
		player.requested_movement = Vector2(action.move_action[0], action.move_action[1])
