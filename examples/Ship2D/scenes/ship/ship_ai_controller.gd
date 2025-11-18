extends AIController2D
class_name ShipAIController

@export var player: Ship
@export var raycast_sensors: Array[Node2D]


## Overriden to remove resetting after n steps
func _physics_process(_delta):
	n_steps += 1
	if needs_reset:
		reset()

	if heuristic == "human":
		set_action()


func end_episode(final_reward := 0.0) -> void:
	reward += final_reward
	done = true
	reset()


func reset():
	super.reset()


func get_raycast_obs() -> Array[float]:
	var obs: Array[float]
	for sensor in raycast_sensors:
		obs.append_array(sensor.get_observation())
	return obs


#var previous_raycast_obs: Array
func get_obs() -> Dictionary:
	var obs: Array[float]

	var raycast_obs: Array[float] = get_raycast_obs()

	obs.append_array(raycast_obs)

	var velocity_x = clampf(player.get_real_velocity().x / 3000, -1.0, 1.0)

	obs.append_array(
		[
			float(player.can_shoot),
			clampf(player.time_since_projectile_spawned / 
			player.projectile_fire_interval_seconds, 0, 1.0),
			velocity_x
		]
	)

	return {"obs": obs}


func get_reward() -> float:
	return reward


func get_action_space() -> Dictionary:
	return {
		"move": {"size": 3, "action_type": "discrete"},
		"shoot": {"size": 2, "action_type": "discrete"},
	}


func set_action(_action = null) -> void:
	var move_dir: float
	var shoot: float
	if _action:
		move_dir = _action.move - 1
		shoot = bool(_action.shoot)
	else:
		move_dir = Input.get_axis("move_left", "move_right")
		shoot = Input.is_action_pressed("shoot")

	player.requested_movement = move_dir
	player.requested_shoot = shoot
