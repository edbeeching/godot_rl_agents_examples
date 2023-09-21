import os
from decouple import config # config information is take from the .env file

from ray.rllib.algorithms.ppo import PPOConfig
from godot_rl.wrappers import ray_wrapper

if __name__ == "__main__":
    # use predefined function to register godot environment
    ray_wrapper.register_env()
    
    # format env variables such that ray can consume them
    env_config = {
        "env_path": config("ENVIRONMENT_PATH"), 
        "show_window": config("SHOW_WINDOW", cast=bool),
        "framerate": None,
        "seed": 42,
    }

    # configure the algorithm
    algo_config = (  
        PPOConfig()
        .environment("godot", env_config=env_config)
        .framework("torch")
    )

    # build the algorithm
    algo = algo_config.build()
    
    # create algorithm save path
    algo_path = config("MODEL_SAVE_PATH") + "/raylib"
    os.makedirs(algo_path, exist_ok=True)

    # train it
    for _ in range(config("NB_CHECKPOINTS", cast=int)):
        algo.train()
        algo.save(algo_path)
