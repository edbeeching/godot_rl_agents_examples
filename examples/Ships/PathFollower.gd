extends PathFollow3D



@export var speed:=0.3

func _physics_process(delta):
	progress_ratio += delta * speed
