#!/bin/bash
GODOT_BINARY=/home/edward/play/godot/Godot_v4.0-beta4_linux.x86_64
mkdir builds
EXAMPLE_DIRS=$(ls examples)
EXAMPLE_DIRS=(BallChase)
for EXAMPLE in $EXAMPLE_DIRS; do
    echo $EXAMPLE
    cp -r addons  examples/$EXAMPLE/addons
    # build for linux
    mkdir -p builds/$EXAMPLE/
    $GODOT_BINARY --headless --export "Linux/X11" --path examples/$EXAMPLE/ builds/$EXAMPLE/$EXAMPLE.x86_64
done
