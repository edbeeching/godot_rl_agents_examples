extends AIController3D

var best_goal_distance: float = 0.0

#-- Methods that need implementing using the "extend script" option in Godot --#

var goal_distance: Array[float]
var goal_dir: Array[Vector3]

func get_obs() -> Dictionary:
	var target_vector = _player.to_local(_player.target.global_transform.origin).normalized()
	var target_distance = _player.position.distance_to(_player.target.position)
	target_distance = clamp(target_distance, 0.0, 20.0) / 20.0
	#var obs = [target_vector.x, target_vector.y, target_vector.z, target_distance]
	var obs: Array[float]
	obs.append_array($RayCastSensor3D.get_observation())

	var memory_steps: int = 2
	if goal_distance.is_empty():
		goal_distance.resize(memory_steps)
		goal_distance.fill(target_distance)
		goal_dir.resize(memory_steps)
		goal_dir.fill(target_vector)
		
	for i in goal_dir.size():
		obs.append_array(
			[
				goal_dir[i].x, 
				goal_dir[i].y, 
				goal_dir[i].z, 
				goal_distance[i]
			]
		)
		
	goal_distance.remove_at(0)
	goal_distance.append(target_distance)
	goal_dir.remove_at(0)
	goal_dir.append(target_vector)

	if actions.is_empty():
		actions.resize(memory_steps)
		actions.fill([0, 0, 0])

	
	for action in actions:
		obs.append_array(action)
	
	return {"obs": obs}


func get_reward() -> float:
	var current_reward = reward
	reward = 0.0
	return current_reward

var actions: Array[Array]
func set_action(action):
	_player.forward_backward_action = action["movement"][0]
	_player.turn_left_right_action = action["movement"][1]
	_player.jump_action = action["movement"][2] > 0
	
	actions.remove_at(0)
	actions.append(action["movement"])
	


func get_action_space():
	return {
		"movement": {"size": 3, "action_type": "continuous"},

	}

func _physics_process(_delta: float) -> void:
	super._physics_process(_delta)
	update_reward()
	if self.needs_reset:
		reset()

func update_reward() -> void:
	reward -= 0.01
	var target_distance = _player.position.distance_to(_player.target.position)
	if target_distance < best_goal_distance:
		reward += best_goal_distance - target_distance
		best_goal_distance = target_distance

func reset():
	done = true
	super.reset()
	reset_best_goal_distance()
	_player.reset()

func reset_best_goal_distance():
	# wait for target to be snapped to ground
	await get_tree().create_timer(0.03).timeout
	best_goal_distance = _player.position.distance_to(_player.target.position)
	goal_distance.clear()
	goal_dir.clear()
