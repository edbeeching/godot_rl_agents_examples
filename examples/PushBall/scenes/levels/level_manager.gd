extends Node3D
class_name LevelManager

## Nodes to reset, must implement reset() method
@export var nodes_to_reset: Array[Node]

@onready var player := $Robot
@onready var ball := $Ball
@onready var goal := $Goal


func _ready():
	reset_all_resetables()
	player.level_manager = self
	player.ball = ball
	player.goal = goal
	goal.connect("body_entered", player._on_goal_body_entered)


func reset_all_resetables():
	for node in nodes_to_reset:
		node.reset()
