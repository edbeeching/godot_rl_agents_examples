extends Node3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var velocity = Vector3(0, 0, 0)
var falling = false
var original_position

func _ready():
	original_position = position


func _physics_process(delta):
	if falling:
		velocity.y += -gravity * delta * 2.0
		position += velocity * delta

func _on_fall_timer_timeout():
	falling = true
	$FallResetTimer.start()

func _on_fall_reset_timer_timeout():
	falling = false
	velocity = Vector3(0, 0, 0)
	position = original_position

	$BlueMesh.visible = true
	$RedMesh.visible = false

func _on_area_3d_body_entered(_body:Node3D):
	if falling:
		return
	if $FallTimer.is_stopped():
		$FallTimer.start()
		$BlueMesh.visible = false
		$RedMesh.visible = true
