import argparse
from decouple import config

from stable_baselines3 import PPO
from godot_rl.wrappers.stable_baselines_wrapper import StableBaselinesGodotEnv


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-m', '--model_path')  
    args = parser.parse_args()

    # initialize environment
    env = StableBaselinesGodotEnv(
        env_path=config("ENVIRONMENT_PATH"), 
        show_window=config("SHOW_WINDOW"), 
        speedup=config("SPEEDUP", cast=int),
        convert_action_space=config("CONVERT_ACTIONS")
    )

    model = PPO.load(args.model_path)

    obs = env.reset()
    for _ in range(10000):
        action, _states = model.predict(obs)
        obs, rewards, dones, info = env.step(action)
        env.render()