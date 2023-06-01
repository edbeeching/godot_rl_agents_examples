extends Node3D
class_name CharacterModel
@onready var animation_tree : AnimationTree = $AnimationTree
@onready var _playerback : AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
@onready var skeleton = $Armature/Skeleton3D
enum States {IDLE, RUN, AIR}

func _ready():
	animation_tree.active = true
	
#    $Armature/Skeleton3D.get_modification_stack().enable_all_modifications(true)
#    $Armature/Skeleton3D.modification_stack.get_modification(0).set_target_node("")
#	$Armature/Skeleton3D.modification_stack.get_modification(0).set_target_node("../../Gun/LeftHandMarker")

func set_team(value):
	var material: Material
	if value == 0:
		material = load("res://tbot_model_green_team.tres")
	elif value == 1:
		material = load("res://tbot_model_red_team.tres")
	print("setting tbot material")
	$Armature/Skeleton3D/Mesh.set_surface_override_material(0, material)

func transition_to(state_id: States): 

	match state_id:
		States.IDLE:
			_playerback.travel("Idle")
		States.RUN:
			_playerback.travel("RunBlend")
		_:
			_playerback.travel("Idle")
			
func set_velocity(velocity: Vector3):
	animation_tree.set("parameters/RunBlend/blend_position", Vector2(velocity.x, velocity.z))
	
		
func set_camera_angle(angle: float):
	$Gun.rotation.x = -angle

func get_gun_info():
	return $Gun/MuzzleMarker.global_position

func toggle_model_mesh(value: bool):
	$Armature/Skeleton3D/Mesh.visible = value
