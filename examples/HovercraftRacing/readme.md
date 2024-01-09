## Hovercraft Racing Environment

https://github.com/edbeeching/godot_rl_agents_examples/assets/61947090/09cfa8ef-4d1a-46d3-a38a-0b7cdf1e1000

A 1v1 hovercraft racing environment with:

- `Human VS AI` (use `WASD` keys to control the car), or `AI vs AI` mode,
- Adjustable number of laps (can be set to 0 for infinite race),
- Basic powerups (push forward or push backward).

### Observations:
- Velocity of the car in local reference,
- 3 sampled `next track points` in the car's local reference,
- Wall detecting raycast sensor observations,
- Other car detecting raycast sensor observations,
- Position of the other car in the current car's local reference,
- Position of the nearest powerup in the car's local reference,
- Category of the powerup, as there are only two powerups it can be either `[0, 1]` or `[1, 0]`.

### Action space:
```gdscript
func get_action_space() -> Dictionary:
	return {
		"acceleration": {"size": 1, "action_type": "continuous"},
		"steering": {"size": 1, "action_type": "continuous"},
	}
```

### Rewards:
- Step reward based on the car's track offset difference from the previous step (advancing on the track gives a positive reward, moving backward gives a negative reward),
- Negative step reward for moving backward,
- Negative reward for colliding with a wall or the other car,
- Optional reward for driving over a powerup (can be adjusted in Godot Editor in the scene of the powerup), currently set to 0 for both powerups.

### Game over / episode end conditions:
![image](https://github.com/edbeeching/godot_rl_agents_examples/assets/61947090/d9fdf617-0c4a-479e-8feb-cab9880345e6)

The episode ends for each car after each lap in infinite race mode if `total laps` is set to 0, without restarting the cars,
or if larger than 0, after the set amount of total laps has been completed by any car, in that case the winner is announced (except in training mode), and the cars are automatically restarted for the next race.

`Seconds Until Race Begins` is only applicable to inference (`AI vs AI` or `Player vs AI` modes).

### Running inference with the pretrained onnx model:
![image](https://github.com/edbeeching/godot_rl_agents_examples/assets/61947090/2f9dfd2b-9835-42e0-9bf5-5f45e896967b)

After opening the project in Godot, open the main_scene (should open by default), select a game mode, and click on `Play`.

### Training:

- Set the game mode to `Training` before starting starting training. You can use for instance the [sb3 example](https://github.com/edbeeching/godot_rl_agents/blob/main/examples/stable_baselines3_example.py) to train.

- In the `game_scene`'s `Cars` node, there's a property `Number of Car Groups To Spawn` which allows multiple car groups to spawn and collect experiences during training (during inference, only 1 car group is spawned). Since this is a `1v1` example, each car group is set so a car can only collide with the other car from its own group and the walls. This is done by the car manager script by setting each car to its own physics layer and adjusting the masks (also for the raycast sensor that detects the other car). Settings this value too high may make the environment not work correctly, as there is a limit in the number of physics layers available.

![image](https://github.com/edbeeching/godot_rl_agents_examples/assets/61947090/94752856-8729-4cde-8151-3aaf65bab155)



