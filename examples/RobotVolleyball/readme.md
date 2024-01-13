## Robot Volleyball

A simple minigame arcade-style Volleyball example with AI vs AI and Human VS AI modes. 

### Observations:
- Position of the ball in robot's local reference,
- Position of the ball in the robot's goal's local reference (to tell on what side of the field the ball is in),
- Velocity of the robot in robot's local reference,
- Velocity of the ball in robot's local reference,
- Whether the jump sensor is colliding (which means that the robot can jump),
- Whether the robot is serving,
- Whether the ball has been served,
- Hit count of the ball in a row (hitting the ball more than 2 times in a row by the same robot causes a fault),
- How many steps has passed without hitting the ball (only counted if serving, there is a time limit in that case).

### Action space:
```gdscript
func get_action_space() -> Dictionary:
	return {
		"jump": {"size": 1, "action_type": "continuous"},
		"movement": {"size": 1, "action_type": "continuous"}
	}
```

### Rewards:
- Positive reward for hitting the ball once when serving,
- Negative reward if the same robot hits the ball more than 2 times in a row,
- Negative reward if the ball hits the robots own goal

### Game over / episode end conditions:
In infinite game mode or training mode, there are no specified end conditions.
It's possible to disable these modes in the GameScene node in which case a winner will be announced,
and the scores will be restarted, after a certain amount of points is reached.

### Running inference:
#### AI vs AI

#### AI vs Player

### Training:
The default scene `res://scenes/training_scene/training_scene.tscn` can be used for training.