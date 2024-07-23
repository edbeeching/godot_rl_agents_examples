extends Node3D

@export var LevelScene : PackedScene
var level_scene

func _ready():
	level_scene = LevelScene.instantiate()
	add_child(level_scene)
	level_scene.generate_level()


func _on_target_area_entered(_area:Area3D) -> void:
	print("target picked up")
	reset_target()


func reset_target() -> void:
	$Target.position = level_scene.get_target_location()
