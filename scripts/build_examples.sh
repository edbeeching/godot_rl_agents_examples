#!/bin/bash
GODOT_BINARY=/home/edward/play/godot/Godot_v4.0-beta4_linux.x86_64
#GODOT_BINARY=/Applications/Godot.app/Contents/MacOS/Godot

EXAMPLE_DIRS=$(ls examples)
for EXAMPLE in $EXAMPLE_DIRS; do
    echo "Building $EXAMPLE"

    mkdir examples/$EXAMPLE/bin
    $GODOT_BINARY --headless --export-release "Linux/X11" --path examples/$EXAMPLE/ bin/$EXAMPLE.x86_64
    $GODOT_BINARY --headless --export-release "Windows Desktop" --path examples/$EXAMPLE/ bin/$EXAMPLE.exe
    $GODOT_BINARY --headless --export-release "macOS" --path examples/$EXAMPLE/ bin/$EXAMPLE.app
    python scripts/example_to_hub.py  --hf_repository="edbeeching/godot_rl_${EXAMPLE}" --dir_path="examples/${EXAMPLE}/" --env_name=$EXAMPLE
done
