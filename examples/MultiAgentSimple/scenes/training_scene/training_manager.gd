extends Node3D
class_name TrainingManager

## Manages multiple GameScenes.

## Resets all game scenes at this many steps and ends episode
@export var reset_after_steps := 300

@export var game_scene_to_instantiate: PackedScene
@export var scene_count: int = 8
@export var offset_between_scenes: Vector3

# Physics steps since game started
var _steps := 0

var _game_scenes: Array[GameSceneManager]


func _ready():
	var current_position = offset_between_scenes
	for i in range(0, scene_count):
		var new_instance = game_scene_to_instantiate.instantiate() as GameSceneManager
		add_child(new_instance, true)
		new_instance.training_manager = self
		new_instance.global_position += current_position
		current_position += offset_between_scenes
		new_instance.reset_game(0, false)  # Reset game initially to randomize positions
		_game_scenes.append(new_instance)


func _physics_process(delta: float) -> void:
	_steps += 1
	if _steps > reset_after_steps:
		for game_scene in _game_scenes:
			game_scene.reset_game(0, true)
			_steps = 0
