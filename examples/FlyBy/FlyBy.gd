extends Node3D

var goals = null


# Called when the node enters the scene tree for the first time.
func _ready():
	goals = $Goals.get_children()


func get_next_goal(current_goal):
	if current_goal == null:
		return goals[0]
	var index = null
	for i in len(goals):
		if goals[i] == current_goal:
			index = (i + 1) % len(goals)
			break

	return goals[index]


func get_last_goal():
	return goals[-1]
