## 3D Lander Environment

![lander_scr_1](https://github.com/edbeeching/godot_rl_agents_examples/assets/61947090/66bca4d4-17cb-4618-b4be-ac5a04144927)

This environment was inspired by the gymnasium Lunar Lander env. 

The goal is to land safely as close to the goal as possible. 
It is not required to land inside the goal zone, but landing closer to the center of the zone gives a higher reward.

On each (re)start, the lander is randomly positioned with a random velocity added.

### Observations:
Vector based, including:

- Linear and angular velocity of the lander in the lander's frame of reference,
- Current step / episode length in steps,
- How many of the lander's legs are currently in contact with the ground,
- The orientation of the lander (basis y and x vectors),
- The position of the goal (landing zone) relative to the lander,
- The direction difference between the goal direction (Y axis pointing upward) and the current direction,
- Observations from a RayCast sensor attached to the lander.

### Action space:
For each thruster that the RL agent can control, a discrete action is used of size 2 (with possible values being 0 - thruster off, or 1 - thruster on). 
The entire action space is defined as:

```gdscript
func get_action_space() -> Dictionary:
	return {
		"back_thruster" : {
			"size": 2,
			"action_type": "discrete"
		},
		"forward_thruster" : {
			"size": 2,
			"action_type": "discrete"
		},
		"left_thruster" : {
			"size": 2,
			"action_type": "discrete"
		},
		"right_thruster" : {
			"size": 2,
			"action_type": "discrete"
		},
		"turn_left_thruster" : {
			"size": 2,
			"action_type": "discrete"
		},
		"turn_right_thruster" : {
			"size": 2,
			"action_type": "discrete"
		},
		"up_thruster" : {
			"size": 2,
			"action_type": "discrete"
		},
	}
```

### Rewards and episode end conditions:
The requirement for "successfully landing" includes all legs being on the ground, velocities being low and thruster activity being very low (the thresholds can be adjusted in the `_is_goal_reached()` method of `Lander.gd`).

Every time a leg collides the ground, a positive reward is given. Every time a leg loses contact with the ground, a negative reward is given (in the current version, there may be a case where the negative reward is given after restarting the episode, this hasn't been checked in-depth). 

The episode is restarted if:
- The lander successfully lands (along with a positive reward reduced by the distance from the center of the landing area).
- The body of lander collides with the ground or one of the walls around the game area (along with a negative reward)
- The episodes times out (along with a negative reward)

On every physics step, a reward is added based on:
- Distance to goal delta (reward is positive or negative depending on whether the distance is decreasing or increasing)
- Linear velocity delta (positive if the velocity is decreasing, negative if increasing)
- Angular velocity delta (same as above)
- Direction to goal difference delta (positive if the difference from the goal direction is decreasing, negative if increasing)
- Thruster usage delta (positive if less thrusters are used than before, negative if more thrusters are used than before)

### Lander:
![lander](https://github.com/edbeeching/godot_rl_agents_examples/assets/61947090/290d73b1-789d-4af0-8911-3be584b9c0a8)

The lander consists of a RigidBody for the main body and a RigidBody for each leg.
The legs are connected by a `Generic6DOFJoint3D` to the body.

A 360 degree RayCast sensor is added to the lander to enable it to detect the terrain features as well as the invisible walls / game area boundaries.

The motion of the lander is caused by applying forces from the locations of the thrusters.

### Terrain generation:
`Terrain` class attached to the Terrain node in GameScene generates the terrain for the environment:

![lander_terrain](https://github.com/edbeeching/godot_rl_agents_examples/assets/61947090/ff3aa7d7-259a-436e-85b4-039b66f0ff01)

The `training mode`, enabled by default but disabled for the testing scenes, makes the generation slightly faster for training, as it does not calculate the normals or ambient occlusion texture.
In addition, it makes the terrain regenerate only some of the times on episode restart, rather than every time which is used during inference.

![terrain_parameters_noise](https://github.com/edbeeching/godot_rl_agents_examples/assets/61947090/0e3f5176-2c7f-48c6-ad46-b98e880b7b26)

Altering the main noise texture, along with changing `size`, `subdivisions` and the `height multiplier`,
 affects the main shape of the terrain.

A part of the terrain is made relatively flat so that there is always somewhere the lander can land safely. 
You can adjust the radius of that area by changing `Landing Surface Radius`. 

![surface_radius_changes](https://github.com/edbeeching/godot_rl_agents_examples/assets/61947090/29361c4b-2b9d-42e5-bcdc-5b7fa7131775)
(Left: Landing Surface Radius = 10, Right: Landing Surface Radius = 60)

The position of the landing surface is randomized when the terrain is generated.
You can adjust how far away from the center it can be by using the `Landing Surface Max Dist From Center Ratio` parameter.

`Regenerate Terrain` can be used to regenerate the terrain in the inspector after changing settings. This is not done automatically after every change as regenerating the terrain could take some time, especially if a lot of subdivisions are used.

## Training:
The included onnx file was trained with SB3.

Because this is the first environment to use only discrete actions which are not fully supported with Godot-RL with SB3 at this moment, this  environment was trained using relevant files [from the discrete actions branch](https://github.com/edbeeching/godot_rl_agents/tree/discrete_actions_experimental) of Godot-RL.

You may be able to train the environment with the main branch and run inference from Python, but exporting to onnx will need require this branch and is recommended for training as well.

The parameters used during training were (you can set them by modifying [sb3_example](https://github.com/edbeeching/godot_rl_agents/blob/main/examples/stable_baselines3_example.py)):
```
model = PPO("MultiInputPolicy", env, ent_coef=0.02, n_steps=768, verbose=2, tensorboard_log=args.experiment_dir,
                learning_rate=learning_rate, n_epochs=4)
```

And also, `n_parallel=4` argument was used when for training.

Training stats screenshot from Tensorboard:
![lander3d_training_stats](https://github.com/edbeeching/godot_rl_agents_examples/assets/61947090/6e6e432f-6e99-4451-93d2-66c9936ebf8d)

## Running inference:
To start inference using the pretrained onnx, open the `testing_scene` in Godot Editor, then press `F6` or click on the scene starting icon:

![lander3d_testing_scene](https://github.com/edbeeching/godot_rl_agents_examples/assets/61947090/4d54189d-4749-46af-8ba7-2edc955f7b3a)

You can adjust the `Speed Up` parameter of the `Sync` node to change the speed of the environment.

Due to using discrete actions, this environment comes packaged with the plugin from the [discrete actions PR](https://github.com/edbeeching/godot_rl_agents_plugin/pull/16), which adds the support.

## Manually playing:
You can start the `Manual Test Scene` to control the environment manually.

https://github.com/edbeeching/godot_rl_agents_examples/assets/61947090/03b3b316-e2e0-4340-b739-73487484f02a

`WASD` activate the 4-direction `navigation` thrusters, 
`Q` and `E` activate the `rotation` thrusters,
`SPACE` activates the main `up` thruster.

The camera is not optimally adjusted for human control, as the scene is mainly there to test out the behavior of the environment.

## Known issues:
There is a rare error caused by an `inf` value being sent by an observation noticed during training.
