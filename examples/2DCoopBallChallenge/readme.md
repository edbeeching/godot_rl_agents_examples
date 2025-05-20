# 2DCoopBallChallenge environment


## Goal:

## Observations:

## Running inference:

If you’d just like to test the env using the pre-trained onnx model, open `[SceneName]` in Godot, then press `F6`.

## Training:

There’s an included onnx file that was trained with https://github.com/edbeeching/godot_rl_agents/blob/main/examples/stable_baselines3_example.py

CL arguments used (also onnx export and model saving was used, enable as needed, add `env_path` too to set the exported executable of the platform):

```python
```

Stats from the training session (success rate only):
