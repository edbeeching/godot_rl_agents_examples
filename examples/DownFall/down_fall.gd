extends Node3D

@onready var levels = [$Level1, $Level2, $Level3, $Level4]
# @onready var levels = [$Level4]
var cam_index = 0
var is_fly_cam = false
# Called when the node enters the scene tree for the first time.
func _ready():
	var index = 0
	for player in $Players.get_children():
		player.reset.connect(reset_player)
		player.current_level = index
		index += 1
		index = index % len(levels)
		player.game_over()
	
func reset_player(player: Player, end=false):
	# reset the player's position
	if end:
		player.current_level = (player.current_level + 1) % len(levels)
	var current_level = levels[player.current_level]

	var spawn_box = current_level.get_node("SpawnBox")
	var goal = current_level.get_node("EndGate")

	var spawn_point = spawn_box.get_spawn_point()
	player.global_position = spawn_point
	player.goal = goal

func _input(event):
	if event.is_action_pressed("ui_right"):
		$Players.get_child(cam_index).deactivate_cam()
		cam_index = (cam_index + 1) % $Players.get_children().size()
		$Players.get_child(cam_index).activate_cam()

	if event.is_action_pressed("ui_left"):
		$Players.get_child(cam_index).deactivate_cam()
		cam_index = (cam_index - 1) % $Players.get_children().size()
		$Players.get_child(cam_index).activate_cam()
	
	if event.is_action_pressed("flycam"):
		print("fly cam")
		if is_fly_cam:
			$Players.get_child(cam_index).activate_cam()
			$FlyCam/Camera3D.set_current(false)
			is_fly_cam = false
		else:
			$Players.get_child(cam_index).deactivate_cam()
			$FlyCam/Camera3D.set_current(true)
			is_fly_cam = true
