extends Node3D
class_name Projectile

@export var speed = 40
@export var damage = 10
var velocity = Vector3.ZERO
var shooter = null

var ProjectileImpact = preload("res://projectile_impact.tscn")

var team_materials = {
	0: preload("res://projectile_mat_green_team.tres"),
	1: preload("res://projectile_mat_red_team.tres"),
}

func set_team(value):
	if value != -1:
		$MeshInstance3d.set_surface_override_material(0, team_materials[value])

func _physics_process(delta):
	#look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta

func _on_timer_timeout():
	queue_free()

func _on_projectile_area_entered(area):
	if area is PlayerHitBox and shooter != null:
		shooter.hit_player(area._player)
	
	# create a cool animation  
	#explode()  
	queue_free()

func _on_body_entered(_body):
	#explode()
	queue_free()

func explode():
	print("explode")
	var proj_impact = ProjectileImpact.instantiate()
	shooter.add_child(proj_impact)
	proj_impact.global_position = global_position
	proj_impact.set_as_top_level(true)


func _on_area_shape_entered(_area_rid, _area, _area_shape_index, _local_shape_index):
	queue_free()
