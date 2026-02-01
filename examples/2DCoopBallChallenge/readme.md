# 2DCoopBallChallenge environment


## Goal:
- The ball needs to reach the goal, it must not fall and/or hit any ground tile with grass ("platform" tile), otherwise a negative reward is given (ground tiles the left-right and top sections of the maps are allowed).
- Only one player is allowed to hit the ball at a time, so cooperation / taking turns is required.
- There is a time out period as well with a negative reward if reached.

## Observations:
```gdscript
func get_obs() -> Dictionary:
	var obs: PackedFloat32Array

	for sensor in sensors:
		obs.append_array(sensor.get_observation())

	for player in players.players:
		(
			obs
			. append_array(
				[
					float(player.is_on_floor()),
					float(player.last_to_hit_ball)
				]
			)
		)
	return {"obs": obs}
```

The data collected from sensor includes:
- 2 Raycast sensors from each player, one for ground tiles (that the ball can collide with), and other for the "platform" tiles.
- Each player has a position sensor that tracks relative positions to: ball, goal, and other player.
- There's an additional position sensor that tracks the relative position of the goal from the ball.
- There's a velocity sensor that tracks velocities of both players and the ball.

## Running inference:

If you’d just like to test the env using the pre-trained onnx model, open `res://scenes/training_scene/inference_scene.tscn` in Godot, then press `F6`.

## Training:

There’s an included onnx file that was trained with https://github.com/edbeeching/godot_rl_agents/blob/main/examples/stable_baselines3_example.py

Hyperparams used (you can modify the script to use these):
```python
if args.resume_model_path is None:
    learning_rate = 0.00008 if not args.linear_lr_schedule else linear_schedule(0.0001)

    model: PPO = PPO(
        "MlpPolicy",
        env,
        verbose=2,
        n_steps=32,
        batch_size=32 * env.num_envs,
        n_epochs=80,
        target_kl=0.01,
        learning_rate=learning_rate,
        tensorboard_log=args.experiment_dir,
    )
```

Note that while `MlpPolicy` was used which requires further change to:
`env = SBGSingleObsEnv(
    env_path=args.env_path, show_window=args.viz, seed=args.seed, n_parallel=args.n_parallel, speedup=args.speedup,
)`

and:

`export_model_as_onnx(model, str(path_onnx), use_obs_array=True)`

This is not necessary, you can just use:
`"MultiInputPolicy"` instead, then you don't need the two changes above and it shouldn't affect the performance, but still the original setting is included above for reference.

CL arguments used (also onnx export and model saving was used, enable as needed, add `env_path` too to set the exported executable of the platform):

```python
--onnx_export_path=model.onnx
--timesteps=150_000_000
--env_path=EXPORTED ENV PATH HERE
--n_parallel=4
--speedup=16
--experiment_name=exp
```

Additionally, `--save_checkpoint_frequency=1_000_000` was used, you can optionally add it if you'd like to have checkpoints as the agent trains.

Further note:
It's possible that training was done using a slight modification of the sync node:
`	stream.set_no_delay(false)  # TODO check if this improves performance or not `
it might have been set to `false` instead of the default `true` (to which I returned when using Python inference on Linux, as I noticed with false it seemed laggier),
however this shouldn't affect the training results and you shouldn't need to modify it.

Stats from the training session (success rate only):

![success rate](https://github.com/user-attachments/assets/a134beeb-b383-48af-97a1-8e30195cd72e)
