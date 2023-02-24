#!/bin/bash
if [ -e .env ] ;
then
    set -a; source .env; set +a
else
    echo ".env file is missing. Please run 'cp example.env .env' in the project's root directory."
    exit 0
fi

if [ -z "$GODOT_ENGINE" ] ;
then
    echo "GODOT_ENGINE is not set. Please set GODOT_ENGINE with the path to your godot engine binaries in the .env file."
else
    EXAMPLE_DIRS=$(ls examples)
    for EXAMPLE in $EXAMPLE_DIRS; do
        echo "Building $EXAMPLE"

        mkdir examples/$EXAMPLE/bin
        $GODOT_ENGINE --headless --export-release "Linux/X11" --path examples/$EXAMPLE/ bin/$EXAMPLE.x86_64
        $GODOT_ENGINE --headless --export-release "Windows Desktop" --path examples/$EXAMPLE/ bin/$EXAMPLE.exe
        $GODOT_ENGINE --headless --export-release "macOS" --path examples/$EXAMPLE/ bin/$EXAMPLE.app
        python scripts/example_to_hub.py  --hf_repository="edbeeching/godot_rl_${EXAMPLE}" --dir_path="examples/${EXAMPLE}/" --env_name=$EXAMPLE
    done
fi
