extends Node3D


@onready var player = $AnimationPlayer

func set_animation(anim):
	if player.current_animation == anim:
		return
	
	player.play(anim)
