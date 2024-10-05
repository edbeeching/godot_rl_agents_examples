extends RigidBody3D
class_name Ball

# Keeps track of the robot that spawned this instance
var spawned_by_robot: Robot

# Reference to the particle effect used on impact
@onready var impact_effect := $BallImpactEffect

var time_since_spawned := 0.0


func _physics_process(delta: float) -> void:
	# 5 seconds after spawning, the ball gets deleted
	# to prevent potential accumulation in case a ball doesn't hit anything
	time_since_spawned += delta
	if time_since_spawned > 5.0:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body is Robot:
		if body.spawn_protection_timer <= 0.0:
			spawned_by_robot.just_hit_another_robot()
			body.just_hit_by_ball(self)
	remove_with_impact_effect()


## Removes the ball and displays a particle effect
func remove_with_impact_effect():
	$MeshInstance3D.hide()
	freeze = true
	$CollisionShape3D.set_deferred("disabled", true)
	impact_effect.emitting = true
	await get_tree().create_timer(0.5, true, true, false).timeout
	queue_free()


## Sets the color of the ball
func set_color(color: Color):
	var material := $MeshInstance3D.get_active_material(0) as StandardMaterial3D
	material.albedo_color = color
