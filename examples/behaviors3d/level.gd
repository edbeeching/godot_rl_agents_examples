extends Node3D


@onready var ground = $Ground
# @export var object_pool : Array[PackedScene]
@export var level_generator : BaseLevelGen
@onready var level_scene = preload("res://level_builder.tscn")

func _ready() -> void:
	level_generator.generate_level(self)

	# adjust_ground()
	# spawn_objects()

	reset_target()



	



	# var ground_aabb = AABB(ground.global_transform.origin, ground.size)
	# aabbs.append(ground_aabb)




func _on_target_area_entered(_area:Area3D) -> void:
	print("target picked up")
	reset_target()



func reset_target() -> void:
	$Target.position = Vector3(
		randf_range(-ground.size.x/2, ground.size.x/2), 
		1,
		randf_range(-ground.size.z/2, ground.size.z/2)
	)
