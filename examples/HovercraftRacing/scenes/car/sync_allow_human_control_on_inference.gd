extends "res://addons/godot_rl_agents/sync.gd"
class_name SyncAllowHumanControlOnInference

func _set_heuristic(heuristic):
	for agent in agents:
		# If an agent instance is to be controlled by the player, skip changing heuristic from "human" (the default)
		if not agent.human_controlled_on_inference:
			agent.set_heuristic(heuristic)
