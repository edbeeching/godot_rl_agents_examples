extends Node3D


@onready var anim = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("AnimationPlayer").get_animation("Main")#.set_loop(true)
	anim.play("Main")
