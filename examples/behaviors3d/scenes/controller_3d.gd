extends AIController3D

var best_goal_distance: float = 0.0

#-- Methods that need implementing using the "extend script" option in Godot --#
func get_obs() -> Dictionary:
    var target_vector = _player.to_local(_player.target.global_transform.origin).normalized()
    var target_distance = _player.position.distance_to(_player.target.position)
    target_distance = clamp(target_distance, 0.0, 20.0) / 20.0
    var obs = [target_vector.x, target_vector.y, target_vector.z, target_distance]
    obs.append_array($RayCastSensor3D.get_observation())

    return {"obs": obs}


func get_reward() -> float:
    var current_reward = reward
    reward = 0.0
    return current_reward


func set_action(action):
    _player.forward_backward_action = action["movement"][0]
    #_player.straf_left_right_action = action["movement"][1]
    _player.turn_left_right_action = action["movement"][2]
    _player.jump_action = action["movement"][3] > 0


func get_action_space():
    return {
        "movement": {"size": 4, "action_type": "continuous"},

    }

func _physics_process(_delta: float) -> void:
    update_reward()

func update_reward() -> void:
    reward -= 0.01
    var target_distance = _player.position.distance_to(_player.target.position)
    if target_distance < best_goal_distance:
        reward += best_goal_distance - target_distance
        best_goal_distance = target_distance

func reset():
    super.reset()
    reset_best_goal_distance()
    reward = 0.0

func reset_best_goal_distance():
    # wait for target to be snapped to ground
    await get_tree().create_timer(0.03).timeout
    best_goal_distance = _player.position.distance_to(_player.target.position)
