extends Node3D
class_name GameSceneManager

@export var goal_manager: AreaPositionRandomizer
@export var obstacle_manager: AreaPositionRandomizer
@export var player: Player


func _ready() -> void:
	reset()


func reset():
	goal_manager.reset()
	obstacle_manager.reset()
	player.reset()
