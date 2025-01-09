extends StaticBody3D

@onready var raycast = $RayCast3D
@onready var mesh: Mesh = $MeshInstance3D.mesh
@onready var aabb: AABB = mesh.get_aabb()

var placed = false
var use_raycast_positioning: bool


func _physics_process(_delta: float) -> void:
	if use_raycast_positioning and (not placed) and raycast.is_colliding():
		# Set position to hit position
		raycast.force_raycast_update()
		global_position.y = raycast.get_collision_point().y + 0.5 * mesh.size.y
		placed = true
		raycast.queue_free()
