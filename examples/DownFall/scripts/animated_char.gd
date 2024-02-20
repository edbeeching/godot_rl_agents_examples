extends Node3D

@onready var materials = [
	preload("res://materials/GreenChar.tres"),
	preload("res://materials/BlueChar.tres"),
	preload("res://materials/GreenYellowChar.tres"),
	preload("res://materials/LightBlueChar.tres"),
	preload("res://materials/LightGreenChar.tres"),
	preload("res://materials/PinkChar.tres"),
	preload("res://materials/RedChar.tres"),
	preload("res://materials/YellowChar.tres"),
]

func play_anim(anim):
	$AnimationPlayer.play(anim)

func _ready():
	var mesh = $"KayKit Animated Character/Skeleton3D/PrototypePete".mesh
	var material = materials.pick_random()
	mesh.surface_set_material(0, material)
