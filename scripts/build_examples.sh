#!/bin/bash
GODOT_BINARY=/home/edward/play/godot/Godot_v4.2.1-stable_mono_linux_x86_64/Godot_v4.2.1-stable_mono_linux.x86_64

EXAMPLE_DIRS=$(ls examples)
for EXAMPLE in $EXAMPLE_DIRS; do
    echo "Building $EXAMPLE"

    mkdir examples/$EXAMPLE/bin
    $GODOT_BINARY --headless --export-debug "Linux/X11" --path examples/$EXAMPLE/ bin/$EXAMPLE.x86_64
    $GODOT_BINARY --headless --export-debug "Windows Desktop" --path examples/$EXAMPLE/ bin/$EXAMPLE.exe
    python scripts/example_to_hub.py  --hf_repository="edbeeching/godot_rl_${EXAMPLE}" --dir_path="examples/${EXAMPLE}/" --env_name=$EXAMPLE
done
