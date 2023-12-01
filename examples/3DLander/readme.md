## 3D Lander Environment

![lander_scr_1](https://github.com/edbeeching/godot_rl_agents_examples/assets/61947090/66bca4d4-17cb-4618-b4be-ac5a04144927)

The goal is to land safely, with faster landing or using less thrusters giving higher rewards. 
It is not required to land inside of the goal zone, but landing closer to the center of the zone gives a higher reward.

### Observations:
Vector based, including:

- Linear and angular velocity of the lander in the lander's frame of reference,
- Current step / episode length in steps,
- How many of the lander's legs are currently in contact with the ground,
- The orientation of the lander (basis y and x vectors),
- The location of the lander relative to the center of the terrain (was previously used to tell the agent how close it is to the game area boundaries, may not be needed in current version as CollisionShape walls are added which the RayCast sensor can detect),
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
**TODO**

### Terrain generation:
`Terrain` class attached to the Terrain node in GameScene generates the terrain for the environment:

![lander_terrain](https://github.com/edbeeching/godot_rl_agents_examples/assets/61947090/ff3aa7d7-259a-436e-85b4-039b66f0ff01)

The `training mode`, enabled by default but disabled for the testing scenes, makes the generation slightly faster for training, as it does not calculate the normals or ambient occlusion texture.
In addition, it makes the terrain regenerate only some of the times on episode restart, rather than every time which is used during inference.

![terrain_parameters_noise](https://github.com/edbeeching/godot_rl_agents_examples/assets/61947090/0e3f5176-2c7f-48c6-ad46-b98e880b7b26)

Altering the main noise texture affects the main shape of the terrain, along with changing `size`, `subdivisions` and the `height multiplier`.

A part of the terrain is made relatively flat so that there is always somewhere the lander can land safely. 
You can adjust the radius of that area by changing `Landing Surface Radius`. 

The position of the landing surface is randomized when the terrain is generated.
You can adjust how far away from the center it can be by using the `Landing Surface Max Dist From Center Ratio` parameter.

`Regenerate Terrain` can be used to regenerate the terrain in the inspector after changing settings. This is not done automatically after every change as regenerating the terrain could take some time, especially if a lot of subdivisions are used.

