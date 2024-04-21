# SimpleReachGoal
A simple reach the goal environment that is designed to be easy to train for running quick tests. 


# Goal:

The agent needs to enter the green goal area while avoiding the red obstacle area, and without falling outside of the game area. The goal and obstacle areas are randomly set to one of the possible positions at the beginning of each episode. All possible positions are shown in the screenshot below.


# Observations:

The agent uses 3 Raycast sensors, each configured to detect different object types:

- GoalRaycastSensor (detects the green goal area using 32 rays)
- ObstacleRaycastSensor (detects the red obstacle area using 32 rays)
- GroundRaycastSensor (detects the ground below the player using 16 rays)


In addition to the sensors, the agent also has relative positions to the goal and obstacle added to its observations.


# Rewards:

The environment has sparse rewards:

+1 For entering the green area,

-1 For entering the red area,

-1 For falling outside of the game area.

In each of those cases, the episode resets after the event. The episode also resets on timeout.


# Training results:

These are the training stats from the training session used to train the included onnx file. The reward are from training directly, not using deterministic evaluation.

SB3 example script was used for training, with the following changes:

```python
    policy_kwargs = dict(
        log_std_init=log(0.5)
    )
    model: PPO = PPO(
        "MultiInputPolicy",
        env,
        ent_coef=0,
        verbose=2,
        n_steps=32,
        tensorboard_log=args.experiment_dir,
        learning_rate=learning_rate,
        policy_kwargs=policy_kwargs
    )
```

SB3 example script cmd arguments:

```python
--timesteps=50_000
--onnx_export_path=simplereachgoal.onnx
```

Training was launched from Godot editor, and took about 3 minutes to complete to get the results from the video at the top of this page.

This environment was made by [Ivan267.](https://github.com/Ivan-267)