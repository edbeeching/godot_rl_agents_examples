extends CharacterBody3D
class_name Platform

@export var speed := 8.0
# Visual rotation speed of the propeller
@export var propeller_rotation_speed := 1.0

@onready var propeller = $flying_platform/flying_platform/Torus/propeller

var requested_movement: float


func _physics_process(delta: float) -> void:
	velocity = Vector3.RIGHT * requested_movement * speed
	move_and_slide()
	propeller.rotate_object_local(Vector3.UP, propeller_rotation_speed * speed)
