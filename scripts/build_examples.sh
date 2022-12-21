#!/bin/bash
GODOT_BINARY=/home/edward/play/godot/Godot_v4.0-beta4_linux.x86_64

EXAMPLE_DIRS=$(ls examples)
for EXAMPLE in $EXAMPLE_DIRS; do
    echo "Building $EXAMPLE"

    mkdir examples/$EXAMPLE/bin
    $GODOT_BINARY --headless --export "Linux/X11" --path examples/$EXAMPLE/ bin/$EXAMPLE.x86_64
    $GODOT_BINARY --headless --export "Windows Desktop" --path examples/$EXAMPLE/ bin/$EXAMPLE.exe
    python scripts/example_to_hub.py  --hf_repository="edbeeching/godot_rl_${EXAMPLE}" --dir_path="examples/${EXAMPLE}/" --env_name=$EXAMPLE
done
