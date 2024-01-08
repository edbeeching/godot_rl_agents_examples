extends CharacterBody3D
class_name Player

enum PlayerState {IDLE, RUN}
const SPEED : float = 5.0
const JUMP_VELOCITY : float = 4.5

@export var look_sensitivity: float = 0.005
@export var is_controlled: bool = false
@export var reload_speed_ms := 500.0

@onready var camera_pivot : Node3D = $CameraPivot
@onready var character : CharacterModel = $TbotModel
@onready var first_person_camera : Camera3D = $CameraPivot/FirstPersonCamera3d
@onready var third_person_camera : Camera3D = $CameraPivot/ThirdPersonCamera3d
@onready var camera_raycast : RayCast3D = $CameraPivot/FirstPersonCamera3d/RayCast3D
@onready var Proj = preload("res://projectile.tscn")
@onready var ai_controller: AIController3D = $CameraPivot/AIController
@onready var health_system = $HealthSystem

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var player_state := PlayerState.IDLE
var input_dir : Vector2
var can_shoot := true
var needs_respawn = false
var human_control = false
var team = -1

func _ready():
	health_system.init(self)
	third_person_camera.current = is_controlled
	CameraManager.register_player(self)
	ai_controller.init(self)
	$PlayerHitBox._player = self

func set_team(value):
	team = value
	# for detection of different team classes
	ai_controller.set_team(team)
	# update the material of the tbot model
	character.set_team(team)
	
	# update the collision mask
	if team == 0:
		$PlayerHitBox.collision_layer = $PlayerHitBox.collision_layer | 8
		$PlayerHitBox.collision_mask = $PlayerHitBox.collision_mask | 8
	elif team == 1:
		$PlayerHitBox.collision_layer = $PlayerHitBox.collision_layer | 16
		$PlayerHitBox.collision_mask = $PlayerHitBox.collision_mask | 16

func respawn():
	GameManager.respawn(self)
	camera_pivot.rotation.x = 0
	health_system.reset()
	ai_controller.reset()
	needs_respawn = false

func died():
	ai_controller.done = true
	respawn()
	

func _shoot():
	if !can_shoot:
		return
	
		
	var hit_location = global_position + -camera_raycast.global_transform.basis.z * 100.0
	
	if camera_raycast.is_colliding():
		hit_location = camera_raycast.get_collision_point()

	var projectile = Proj.instantiate()
	add_child(projectile)
	projectile.set_as_top_level(true)

	projectile.shooter = self
	projectile.set_team(team)
	var info = character.get_gun_info()
	
	projectile.global_position = info
	projectile.look_at(hit_location)
	projectile.velocity = -projectile.transform.basis.z * projectile.speed
	
	can_shoot = false
	await get_tree().create_timer(reload_speed_ms/1000.0).timeout
	can_shoot = true

func _unhandled_input(event):
	if !human_control and (!is_controlled or ai_controller.heuristic == "model"):
		return
		
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * look_sensitivity)
		camera_pivot.rotate_x(-event.relative.y * look_sensitivity)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-70), deg_to_rad(70))
		character.set_camera_angle(camera_pivot.rotation.x)

func _physics_process(delta):
		# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if needs_respawn:
		respawn()
		
	if !is_controlled and ai_controller.heuristic == "human":
		return

	if Input.is_action_just_pressed("human_control"):
		human_control = !human_control
	# Handle Jump.
	var jump
	var shoot
	if human_control or ai_controller.heuristic == "human":
		jump = Input.is_action_just_pressed("jump")
		shoot = Input.is_action_just_pressed("shoot")
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	else:
		jump = ai_controller.jump_action
		shoot = ai_controller.shoot_action
		input_dir = ai_controller.movement_action
		var look_dir = ai_controller.look_action
		
		rotate_y(-look_dir.x * look_sensitivity*4.0)
		camera_pivot.rotate_x(-look_dir.y * look_sensitivity*4.0)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-70), deg_to_rad(70))
		character.set_camera_angle(camera_pivot.rotation.x)
	
	if  jump and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
#	if camera_raycast.is_colliding():
#		var hit_location = camera_raycast.get_collision_point()
#		$HitDebug.global_position = hit_location
#
#
#		var muzzle_location = character.get_gun_info() + transform.basis.x*0.02 +transform.basis.y*0.02
#		var midpoint = muzzle_location + (hit_location - muzzle_location)/2
#		$LaserSight.global_position = muzzle_location
#		$LaserSight.look_at(hit_location)
#		$LaserSight.rotate_x(deg_to_rad(90))
#		$LaserSight.global_position = midpoint
#		$LaserSight.mesh.height = (hit_location - muzzle_location).length()
		
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
		
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if shoot:
		_shoot()
	move_and_slide()
	
	if Input.is_action_just_pressed("ui_cancel"): 
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE

	# State logic	
	match player_state:
		PlayerState.IDLE:
			character.set_velocity(transform.basis.inverse() * velocity)
			if velocity.length() > 0.01 and is_on_floor():
				player_state = PlayerState.RUN
				character.transition_to(character.States.RUN)
				
		PlayerState.RUN:
			if velocity.length() < 0.01 and is_on_floor():
				player_state = PlayerState.IDLE
				velocity = Vector3.ZERO
				character.transition_to(character.States.IDLE)

	
func hit_player(other_player):
	if other_player == self:
		#print("player hit self")
		return
	if team != -1 and other_player.team == team:
		return
	
	ai_controller.reward += 1.0
	
# Camera toggling, refactor to manager?    
func activate_first_person():
	character.toggle_model_mesh(false)
	first_person_camera.make_current()
	
func activate_third_person():
	character.toggle_model_mesh(true)
	third_person_camera.make_current()
	
func activate_control():
	is_controlled = true
	return

func deactivate_control():
	is_controlled = false
	character.toggle_model_mesh(true)


func _on_player_hit_box_area_entered(area):
	if area is Projectile and area.shooter != self:
		if team != -1 and area.shooter.team != team:
			health_system.take_damage(area.damage)
