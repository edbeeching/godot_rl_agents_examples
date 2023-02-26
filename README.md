# Godot RL examples
Example Environments for the Godot RL Agents library

## Prerequisites

* Download Python - [download link](https://www.python.org/downloads/)
* Create and activate a virutal environment - [documentation](https://docs.python.org/3/library/venv.html), [tutorial](https://www.geeksforgeeks.org/python-virtual-environment/)

## Step 1 - Install Python dependencies

Choose a library that works on your OS 
| Agent Library      | Works on Windows | Works on Linux | Works on Mac|
|--------------------| -----------------|----------------|-------------|
| Sample Factory     |         ❌       |        ✔      |      ?      |
| Stable Baselines 3 |         ✔        |        ✔      |      ?      |
| Ray RLLib          |         ✔        |        ✔      |      ?      |

```
# create and activate the virtual env
>> python3 -m venv .venv
>> .venv/Source/activate

# install dependencies for your library of choice

## for Stable Baselines 3
>> pip install -r ./stable_baselines/requirements.txt

## for RayLib
>> pip install -r ./stable_baselines/requirements.txt
```

## Step 2 - Experiment with the environment
> see the list of all environments [at this link](https://github.com/edbeeching/godot_rl_agents_examples/tree/main/examples)

You will have to update the `.env` file if you are not running windows on your machine.

```
# by default you'll use BallChase as an environment
>> python ./stable_baselines/00_train.py
```