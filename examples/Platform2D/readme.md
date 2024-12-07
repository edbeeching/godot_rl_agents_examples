# Platform2D environment

## Goal:

## Observations:

## Actions:

## Running inference:

If you’d just like to test the env using the pre-trained onnx model,

## Training:

There’s an included onnx file that was trained with https://github.com/edbeeching/godot_rl_agents/blob/main/examples/stable_baselines3_example.py

CL arguments used (also onnx export and model saving was used, enable as needed):

```python
--speedup=8
--n_parallel=8
```