extends Node3D
class_name GameManager

@export var robot_scene: PackedScene
@export var number_of_robots_to_spawn: int = 4

var _robots: Array[Robot]


func _ready():
	spawn_robots()


func spawn_robots():
	for i in number_of_robots_to_spawn:
		var robot = robot_scene.instantiate()

		add_child(robot)
		robot.set_color(Color.from_hsv(i / float(number_of_robots_to_spawn), 0.9, 0.8))
		_robots.append(robot)
		robot.ai_controller.game_manager = self
