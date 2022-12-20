extends Node

var players = {}
var n_waypoints = -1
var waypoints : Node3D = null:
	get: return waypoints
	set(value): 
		waypoints = value
		waypoints.get_children()[0].visible = true
var ui = null
var current_player_index = 0
var player_list = []
var countdown_scene = preload("res://UICountDown.tscn")
var fly_cam : Node3D

func _ready():
	return
	await get_tree().create_timer(1.0).timeout
	var callable = Callable(self, "unpause_players")
	callable.call()
	return
	var countdown = countdown_scene.instantiate()
	add_child(countdown)
	countdown.run_countdown(callable)
	
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"): 
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE	
	
	if Input.is_action_just_pressed("next_player"):
		player_list[current_player_index].set_control(false)
		current_player_index = wrap(current_player_index+1, 0, len(player_list))
		player_list[current_player_index].set_control(true)
		
	if Input.is_action_just_pressed("previous_player"):
		player_list[current_player_index].set_control(false)
		current_player_index = wrap(current_player_index-1, 0, len(player_list))
		player_list[current_player_index].set_control(true)
		
	if Input.is_action_just_pressed("toggle_flycam"):
		if fly_cam.is_controlled:
			fly_cam.set_control(false)
			player_list[current_player_index].set_control(true)
		else:
			player_list[current_player_index].set_control(false)
			fly_cam.set_control(true)
		
func register_player(player : VehicleBody3D):
	players[player] = 0
	if player.controlled:
		current_player_index = len(player_list)
	player_list.append(player)
	#player.set_physics_process(false)
	
func register_flycam(camera : Node3D):
	print("camera registered")
	fly_cam = camera

func player_crossed_waypoint(player : VehicleBody3D, id : int):
	if players[player] == id:		
		#waypoints.get_children()[players[player]].visible = false
		players[player] += 1
		if players[player] == n_waypoints:
			EventManager.lap_finished(player)
			
		players[player] = players[player] % n_waypoints
		player.crossed_waypoint()
		#waypoints.get_children()[players[player]].visible = true

func get_next_waypoint(player : VehicleBody3D):
	return waypoints.get_children()[players[player]]
	
func get_next_next_waypoint(player : VehicleBody3D):
	return waypoints.get_children()[(players[player]+1) % n_waypoints]

func reset_waypoints(player):
	players[player] = 0

func unpause_players():
	for player in players.keys():
		EventManager.lap_started(player)
		player.set_physics_process(true)
