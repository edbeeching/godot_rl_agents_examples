extends CharacterBody2D
class_name Player

@export var speed := 700.0
@export var jump_velocity := -1400.0
@export var map_manager: MapManager
@export var ai_controller: PlayerAIController

var requested_movement: float
var requested_jump: bool

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var initial_transform := transform


func _physics_process(delta: float) -> void:
	handle_movement(delta)
	move_and_slide()
	end_episode_on_fell_down()


func handle_movement(delta: float):
	# Gravity
	if not is_on_floor():
		velocity += Vector2.DOWN * 4000 * delta

	# Controls (human or AI controlled)
	var direction: float
	if ai_controller.control_mode == AIController2D.ControlModes.HUMAN:
		direction = Input.get_axis("move_left", "move_right")
		requested_jump = Input.is_action_just_pressed("jump")
	else:
		direction = requested_movement

	# Horizontal movement
	velocity.x = direction * speed
	if velocity.x:
		animated_sprite.flip_h = velocity.x < 0
		if is_on_floor():
			animated_sprite.animation = "move"
			animated_sprite.play()
	
	# Jump
	if requested_jump and is_on_floor():
		velocity.y = jump_velocity
		animated_sprite.animation = "jump"
		animated_sprite.play()
	
	# Stop animation if not moving
	if velocity.length_squared() < 0.01 and is_on_floor():
		animated_sprite.animation = "move"
		animated_sprite.stop()


func end_episode_on_fell_down() -> void:
	if (position.y - map_manager.total_rows * map_manager.tile_set.tile_size.y) > 0:
		end_episode(-1.0)


func end_episode(final_reward := 0.0, success := false) -> void:
	ai_controller.end_episode(final_reward, success)
	transform = initial_transform
	map_manager.reset()


func _on_area_2d_body_shape_entered(
	body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int
) -> void:
	if body is MapManager:
		var coords = body.get_coords_for_body_rid(body_rid)
		if body.get_cell_atlas_coords(coords) == MapManager.Tiles.COIN:
			body.remove_coin_from_position(coords)
			player_picked_up_coin()
		elif body.get_cell_atlas_coords(coords) == MapManager.Tiles.GOAL:
			player_reached_goal()
		elif body.get_cell_atlas_coords(coords) == MapManager.Tiles.SPIKES:
			player_hit_spikes()


func player_picked_up_coin() -> void:
	ai_controller.reward += 1


func player_reached_goal() -> void:
	if map_manager.remaining_coins == 0:
		end_episode(+10, true)


func player_hit_spikes() -> void:
	end_episode(-0.1)
