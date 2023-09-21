import os
from decouple import config # config information is take from the .env file

from stable_baselines3 import PPO
from godot_rl.wrappers.stable_baselines_wrapper import StableBaselinesGodotEnv

def initialize_environment():
    env = StableBaselinesGodotEnv(
        env_path=config("ENVIRONMENT_PATH"), 
        show_window=config("SHOW_WINDOW"), 
        speedup=config("SPEEDUP", cast=int),
        convert_action_space=config("CONVERT_ACTIONS")
    )
    return env

def initialize_model(env):
    model_args = {
        "env": env, 
        "policy": "MultiInputPolicy",
        "ent_coef": config("ENTROPY_COEF", cast=float), 
        "verbose": config("VERBOSE", cast=int), 
        "n_steps": config("NB_STEPS", cast=int), 
        "tensorboard_log": config("LOGS_FOLDER")
    }

    model_type = config("MODEL_TYPE")
    if model_type == 'PPO':
        model = PPO(**model_args)
    else:
        raise NotImplementedError(f"Not supported model type {model_type}")
    return model

if __name__ == "__main__":
    env = initialize_environment()
    model = initialize_model(env)

    # create model save path
    model_path = config("MODEL_SAVE_PATH")  + "/sb3"
    os.makedirs(model_path, exist_ok=True)

    # train model
    timesteps = config("TIMESTEPS_CHECKPOINT", cast=int)
    for step_number in range(config("NB_CHECKPOINTS", cast=int)):
        model_name = config("MODEL_TYPE") + f"_{step_number+1}"
        model.learn(timesteps)
        model.save(f"{model_path}/{model_name}.mdl")

    print("closing env")
    env.close()


