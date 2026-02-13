# Virtual Camera 2D
A simple environment for testing the 2D Camera Sensor.

![camera_2d](https://github.com/user-attachments/assets/265f153d-8e71-411e-b73b-c30b12ddeac8)

The goal is for the agent to move toward the green goal, while avoiding the red obstacles.

The observations include an images rendered from agent's local camera using the `RGBCameraSensor2D` scene.

Training:
You can use the SB3 example script with:
```Python
    model: PPO = PPO(
        "MultiInputPolicy",
        env,
        verbose=2,
        n_steps=128,
        batch_size=512,
        target_kl=0.02,
        tensorboard_log=args.experiment_dir
    )
```

It learnt to reach reward of 1 (max) in ~30k timesteps on my PC using the Godot editor / single env single instance. 

This environment was made by [Ivan267](https://github.com/Ivan-267)
