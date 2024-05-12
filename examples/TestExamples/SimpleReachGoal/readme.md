# SimpleReachGoal
A simple reach the goal environment that is designed to be easy to train for running quick tests. 

https://github.com/edbeeching/godot_rl_agents_examples/assets/61947090/cf1f4f71-d92e-4036-916d-322d6986d121

The env comes in three variants (each has its own project folder):
- `GDScript` standard implementation using gdscript for everything except ONNX inference,
- `CSharp` implements most of the game code except the extended AIController using C#,
- `CSharpAll` implements a wrapper for AIController written in C# as well.

Check the [working with CSharp](https://github.com/edbeeching/godot_rl_agents/blob/main/docs/WORKING_WITH_CSHARP.md) guide for more information about the CSharp variants.

# Goal:

The agent needs to enter the green goal area while avoiding the red obstacle area, and without falling outside of the game area. The goal and obstacle areas are randomly set to one of the possible positions at the beginning of each episode. All possible positions are shown in the screenshot below.

![Area spawn positions](https://github.com/edbeeching/godot_rl_agents_examples/assets/61947090/e0b44c9d-6a23-4db9-82a5-5c40f7272f8d)

# Observations:

The agent uses 3 Raycast sensors, each configured to detect different object types:

- GoalRaycastSensor (detects the green goal area using 32 rays)
- ObstacleRaycastSensor (detects the red obstacle area using 32 rays)
- GroundRaycastSensor (detects the ground below the player using 16 rays)

![Raycast sensors](https://github.com/edbeeching/godot_rl_agents_examples/assets/61947090/e1f28658-e5b1-4ea0-b7a8-69dc42efc610)

In addition to the sensors, the agent also has relative positions to the goal and obstacle added to its observations.


# Rewards:

The environment has sparse rewards:

+1 For entering the green area,

-1 For entering the red area,

-1 For falling outside of the game area.

In each of those cases, the episode resets after the event. The episode also resets on timeout.


# Training results (GDScript version):
![Training rewards](https://github.com/edbeeching/godot_rl_agents_examples/assets/61947090/9c19928c-ed47-4ff7-9eb7-160b4a61ef88)
These are the training stats from the training session used to train the onnx file included in the GDScript env. The reward are from training directly, not using deterministic evaluation.

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

- The base (gdscript) environment and CSharp variant was made by [Ivan267](https://github.com/Ivan-267)
- The CSharpAll variant was made by [LorinczAdrien](https://github.com/LorinczAdrien)
