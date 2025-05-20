extends CharacterBody2D
class_name Ball

@export var game_manager: GameManager
@export var approach_goal_reward: ApproachNodeReward2D

@onready var initial_transform = transform

var pre_slide_velocity: Vector2
var drag: float = 1.5
var last_player_collided: Player


func get_approach_goal_reward():
	return approach_goal_reward.get_reward()


func _physics_process(delta: float) -> void:
	pre_slide_velocity = velocity
	velocity.x /= 1 + (drag * delta)
	velocity.y /= 1 + (drag * delta)
	velocity.x = clampf(velocity.x, -2500, 2500)
	velocity.y = clampf(velocity.y, -2500, 2500)

	move_and_slide()
	bounce_on_ground_collision()
	apply_gravity(delta)


func apply_gravity(delta) -> void:
	velocity += Vector2.DOWN * 2500.0 * delta


func bounce_on_ground_collision():
	for i in get_slide_collision_count():
		var last_coll = get_slide_collision(i)
		if last_coll:
			var collider := last_coll.get_collider()
			if collider is MapManager:
				velocity = pre_slide_velocity.bounce(last_coll.get_normal())


func reset():
	approach_goal_reward.reset()
	last_player_collided = null
	transform = initial_transform
	global_position = game_manager.players.get_random_player().global_position + Vector2.UP * 2000
	position.y = max(70, position.y)
	velocity = Vector2.ZERO


var platform_collision_count: int = 0


func episode_failed():
	game_manager.episode_failed()


func _on_area_2d_body_shape_entered(
	body_rid: RID, collider: Node2D, _body_shape_index: int, _local_shape_index: int
) -> void:
	if collider is Player:
		if collider == last_player_collided:
			episode_failed()
		else:
			var move = collider.global_position.direction_to(global_position) * 85
			if not test_move(global_transform, move):
				global_position += move
			velocity = (
				(collider.global_position.direction_to(global_position))
				* (
					1000
					+ collider.get_real_velocity().dot(
						collider.global_position.direction_to(global_position)
					)
				)
			)
			game_manager.player_hit_ball(collider)
			last_player_collided = collider

	elif collider is MapManager:
		var coords = collider.get_coords_for_body_rid(body_rid)
		if (
			collider.get_cell_atlas_coords(coords) == MapManager.Tiles.PLATFORM_LEFT_EDGE
			or collider.get_cell_atlas_coords(coords) == MapManager.Tiles.PLATFORM_MIDDLE
			or collider.get_cell_atlas_coords(coords) == MapManager.Tiles.PLATFORM_RIGHT_EDGE
		):
			if platform_collision_count == 0:
				platform_collision_count += 1
				await get_tree().physics_frame
				episode_failed()
				platform_collision_count = 0


func _on_goal_body_entered(body: Node2D) -> void:
	if body == self:
		game_manager.on_ball_goal_reached()
