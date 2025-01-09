extends Node
var player_camera_slots = []
var current_id = 0

func register_player(player):
	player_camera_slots.append(player)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("switch_camera"):
		prints("Switching camera", current_id)
		player_camera_slots[current_id].toggle_camera(false)

		current_id += 1
		current_id = current_id % player_camera_slots.size()
		player_camera_slots[current_id].toggle_camera(true)
