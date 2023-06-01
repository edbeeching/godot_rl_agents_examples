import argparse
import json
import os
import sys
from huggingface_hub import HfApi, Repository, repocard, upload_file, upload_folder


def generate_dataset_card(
    dir_path: str, 
    env: str,
    repo_id: str,
):
    readme_path = os.path.join(dir_path, "README.md")
    repo_name = repo_id.split("/")[1]

    readme = f"""
A RL environment called {env} for the Godot Game Engine.\n
This environment was created with: https://github.com/edbeeching/godot_rl_agents \n

## Downloading the environment \n
After installing Godot RL Agents, download the environment with: \n
```
gdrl.env_from_hub -r {repo_id}
```
\n

"""

    with open(readme_path, "w", encoding="utf-8") as f:
        f.write(readme)

    metadata = {}
    metadata["library_name"] = "godot-rl"
    metadata["tags"] = [
        "deep-reinforcement-learning",
        "reinforcement-learning",
        "godot-rl",
        "environments",
        "video-games"
    ]
    repocard.metadata_save(readme_path, metadata)

def push_to_hf(dir_path: str, repo_name: str):
    repo_url = HfApi().create_repo(
        repo_id=repo_name,
        private=False,
        exist_ok=True,
        repo_type="dataset"
    )

    upload_folder(
        repo_id=repo_name,
        folder_path=dir_path,
        path_in_repo=".",
        ignore_patterns=[".git/*", ".godot/*"],
        repo_type="dataset"
    )


# def load_from_hf(dir_path: str, repo_id: str):
#     temp = repo_id.split("/")
#     repo_name = temp[1]

#     local_dir = os.path.join(dir_path, repo_name)
#     Repository(local_dir, repo_id)
#     log.info(f"The repository {repo_id} has been cloned to {local_dir}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--hf_repository",
        help="The full repo_id to push to on the HuggingFace Hub. Must be of the form <username>/<repo_name>",
        type=str,
    )
    parser.add_argument(
        "--dir_path",
        help="The path of the environment",
        default="./",
        type=str,
    )
    parser.add_argument(
        "--env_name",
        help="The name of the environment",
        default="unknown",
        type=str,
    )
    args = parser.parse_args()

    generate_dataset_card(args.dir_path, args.env_name, args.hf_repository)
    push_to_hf(args.dir_path, args.hf_repository)


if __name__ == "__main__":
    sys.exit(main())