# MultiAgent Simple Environment

[Add video]

## Goal:

The robot agent needs to reach the goal (marked by a transparent green square) as many times as possible during the episode. It needs to work together with the platform agent to be able to reach static platforms. Goal position switches to the other static platform after being reached. 

### Rewards:

All agents receive the same rewards, including:

- A negative reward for the robot falling,
- A positive reward for reaching the goal position,
- A reward every step based on the change in distance between the robot and the goal (positive for approaching, negative for moving away from).

## Episode end condition:

Episodes have a fixed length and end at the same time for all agents.

## Agents:

### Robot:

[Add image]

Policy name: `player`

### Actions:

Robot has continuous actions for movement in 2 axes.

```python
func get_action_space() -> Dictionary:
	return {
		"movement": {"size": 2, "action_type": "continuous"},
	}
```

### Observations:

Robot has a Raycast sensor for observations, and has additional observations including the relative positions of the goal and platform agent, as well as its own and the platform agent’s velocities.

### Platform:

[Add image]

Policy name: `platform`

### Actions:

Platform has a single continuous action for movement.

```python
func get_action_space() -> Dictionary:
	return {
		"movement": {"size": 1, "action_type": "continuous"},
	}
```

### Observations:

Platform’s observations include the relative positions of the goal and robot agent, as well as its own and the robot agent’s velocities.

### Onnx inference:

To run the included trained model, open `res://scenes/testing_scene/testing_scene.tscn` in Godot Editor and press F6. 

If you want to change the paths to run your own onnx file in a different folder, you can adjust them in `res://scenes/game_scene/game_scene_onnx_inference.tscn` > `PlayerAIController` and `PlatformAIController` inspector properties.

### Training:

Training this scene is currently only supported using the [Rllib example](https://github.com/edbeeching/godot_rl_agents/blob/main/examples/rllib_example.py) (`env_is_multiagent` should be set to `true` in the config file, and you can adjust the stopping criteria and other settings as needed).

Here are some stats from the session that was used to get the trained onnx model (for testing a single worker / env instance was used and the training time was likely longer than required). Steps are env steps, since there are multiple agents using each policy in the env, there are many more total agent steps than env steps:

[Add image]