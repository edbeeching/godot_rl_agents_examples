extends Camera3D



@export var lerp_speed = 3.0
@export_node_path("VehicleBody3D") var target_path
@export var offset := Vector3.ZERO

var target = null


func _ready():
	target = get_node(target_path)

func _physics_process(delta):
	
	if target == null:
		return
	
	var target_pos = target.global_transform.translated_local(offset)
	global_transform = global_transform.interpolate_with(target_pos, lerp_speed * delta)
	look_at(target.global_transform.origin, Vector3.UP)
