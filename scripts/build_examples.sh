#!/bin/bash
GODOT_BINARY=/home/edward/play/godot/Godot_v4.0-beta4_linux.x86_64
mkdir builds
EXAMPLE_DIRS=$(ls examples)
for EXAMPLE in $EXAMPLE_DIRS; do
    echo "Building $EXAMPLE"
    #cp -r addons  examples/$EXAMPLE/addons
    mkdir -p builds/$EXAMPLE/
    $GODOT_BINARY --headless --export "Linux/X11" --path examples/$EXAMPLE/ ../../builds/$EXAMPLE/$EXAMPLE.x86_64
    $GODOT_BINARY --headless --export "Windows Desktop" --path examples/$EXAMPLE/ ../../builds/$EXAMPLE/$EXAMPLE.exe
done
