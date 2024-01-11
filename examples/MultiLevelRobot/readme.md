## Multilevel Robot Environment

A simple minigame environment with multiple mini-levels for the robot to pass.
For levels that feature coins, all coins must be picked up before proceeding to the next level is possible.
The final level features some enemy robots to avoid.

### Observations:
- Current n_steps / reset_after,
- Position of the current level's goal in the robot's local reference,
- Position of the closest coin in the robot's local reference,
- Position of the closest enemy in the robot's local reference,
- Movement direction of the closest enemy,
- Robot velocity,
- Whether all coins for the current level have been collected (0 or 1)

### Action space:
```gdscript
func get_action_space() -> Dictionary:
	return {
		"movement" : {
			"size": 2,
			"action_type": "continuous"
		}
		}
```

### Rewards:
- Positive reward for picking up a coin,
- Negative reward (and episode end) on collision with enemy robot,
- Negative reward (and episode end) on robot falling down,
- Positive reward (and episode end) on robot reaching the end of the level by passing through the portal at the end of the level,
- Positive reward every time the robot gets closer to the portal than the previous minimum distance (min distance is restarted each episode).

### Game over / episode end conditions:
An episode ends if the robot falls, collides with an enemy robot or finishes a level by passing through the portal.

### Running inference with the pretrained onnx model:
After opening the project in Godot, open the training_scene and click on `Run Current Scene` or press `F6`

### Training:
The default scene (training_scene) can be used for training.