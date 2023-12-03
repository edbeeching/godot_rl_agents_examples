extends Node

var player_camera_slots = []
var current_id = 0
var is_third_person = false
var fly_cam : Node3D
var orbit_cam : Node3D

func register_player(player):
	print("registering player")
	player_camera_slots.append(player)


func _process(_delta):
	
	if Input.is_action_just_pressed("toggle_next_player"):
		prints("toggle_next_player", current_id)
		var current_player = player_camera_slots[current_id]
		current_player.deactivate_control()
		current_id = wrapi(current_id+1, 0, len(player_camera_slots))
		current_player = player_camera_slots[current_id]
		current_player.activate_control()
		
		if is_third_person:
			current_player.activate_third_person()
		else:
			current_player.activate_first_person()
		
	if Input.is_action_just_pressed("toggle_previous_player"):
		prints("toggle_previous_player", current_id)
		var current_player = player_camera_slots[current_id]
		current_player.deactivate_control()
		current_id = wrapi(current_id-1, 0, len(player_camera_slots))
		current_player = player_camera_slots[current_id]
		current_player.activate_control()
		
		if is_third_person:
			current_player.activate_third_person()
		else:
			current_player.activate_first_person()
			
	if Input.is_action_just_pressed("toggle_first_person_camera"):
		print("toggle_first_person_camera")
		var current_player = player_camera_slots[current_id]
		current_player.activate_first_person()
		is_third_person = false
		
	if Input.is_action_just_pressed("toggle_third_person_camera"):
		print("toggle_third_person_camera")
		var current_player = player_camera_slots[current_id]
		current_player.activate_third_person()
		is_third_person = true  
		
	if Input.is_action_just_pressed("toggle_flycam"):
		var current_player = player_camera_slots[current_id]
		if fly_cam.is_controlled:
			fly_cam.set_control(false)
			current_player.activate_control()
		else:
			current_player.deactivate_control()
			
			fly_cam.set_control(true)    
			
	if Input.is_action_just_pressed("toggle_orbitcam"):
		var current_player = player_camera_slots[current_id]
		if orbit_cam.is_controlled:
			orbit_cam.set_control(false)
			current_player.activate_control()
		else:
			current_player.deactivate_control()
			
			orbit_cam.set_control(true)    
			
	
func register_flycam(camera : Node3D):
	print("fly camera registered")
	fly_cam = camera	

func register_orbitcam(camera : Node3D):
	print("orbit camera registered")
	orbit_cam = camera	
