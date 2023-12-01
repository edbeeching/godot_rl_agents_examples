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
