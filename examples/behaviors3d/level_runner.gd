extends Node3D

@export var LevelScene : PackedScene
var level_scene

func _ready():
	level_scene = LevelScene.instantiate()
	add_child(level_scene)
	level_scene.generate_level()
	reset_target()

func _process(_delta):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _on_target_area_entered(_area:Area3D) -> void:
	print("target picked up")
	reset_target()


func reset_target() -> void:
	$Target/Snapper.attached = false
	$Target.position = level_scene.get_target_location()



func _on_area_3d_area_entered(area:Area3D) -> void:
	print("target picked up")
	reset_target()
