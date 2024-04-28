extends CharacterBody3D
class_name Player

@export var game_scene_manager: GameSceneManager
@export var goal: Area3D
@export var obstacle: Area3D

@export var ai_controller: PlayerAIController
@export var speed = 5.0

@onready var initial_transform = transform

var requested_movement: Vector2


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# If controlled by human, takes the keyboard arrows as input
	# otherwise, requested_movement will be set by the AIController based on RL agent's output actions
	if ai_controller.heuristic == "human":
		requested_movement = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	requested_movement = requested_movement.limit_length(1.0) * speed

	velocity = Vector3(requested_movement.x, velocity.y, requested_movement.y)

	# We only move when the episode is not marked as done
	# to prevent repeating a possibly wrong action from the previous episode.
	# This is related to the sync node Action Repeat functionality,
	# we don't get a new action for every physics step. This check may
	# not be required for every env, and is not used in all examples.
	if not ai_controller.done:
		move_and_slide()

	reset_on_player_falling()


## Resets the game if the player has fallen down
func reset_on_player_falling():
	if global_position.y < -1.0:
		game_over(-1.0)


## Ends the game, setting an optional reward
func game_over(reward: float = 0.0):
	ai_controller.reward += reward
	game_scene_manager.reset()


## Resets the player and AIController
func reset():
	ai_controller.end_episode()
	transform = initial_transform


## When the goal is entered, we restart the game with a positive reward
func _on_goal_body_entered(body: Node3D) -> void:
	game_over(1.0)


## When the obstacle is entered, we restart the game with a negative reward
func _on_obstacle_body_entered(body: Node3D) -> void:
	game_over(-1.0)
