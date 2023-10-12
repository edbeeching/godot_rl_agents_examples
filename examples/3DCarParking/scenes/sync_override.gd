extends "res://addons/godot_rl_agents/sync.gd"

# Lowers the physics ticks per second
func _initialize():
	super._initialize()
	Engine.physics_ticks_per_second = _get_speedup() * 30
