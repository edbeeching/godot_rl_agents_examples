extends "res://addons/godot_rl_agents/sync.gd"


func _initialize():
	super._initialize()
	Engine.physics_ticks_per_second = _get_speedup() * 30 # Replace with function body.
	Engine.time_scale = _get_speedup() * 1.0
