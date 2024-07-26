extends Node3D
class_name Player

## Whether to print the game success/failed messsages to console
@export var print_game_status_enabled: bool

## How far the robot can move per step
@export var movement_step := 2.0

@export var map: Map
@export var car_manager: CarManager

@onready var _ai_controller := $AIController3D
@onready var visual_robot: Node3D = $robot

var last_dist_to_goal

#region Set by AIController
var requested_movement: Vector3
#endregion


#func _ready():


#func _physics_process(delta):


#func _process_movement(_delta):


#func reward_approaching_goal():


#func get_grid_position() -> Vector3i:


#func game_over(reward = 0.0):


#func reset():


#func print_game_status(message: String):
