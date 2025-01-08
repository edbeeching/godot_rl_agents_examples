extends CharacterBody2D
class_name Ship

@export var ball_scene: PackedScene
@export var ai_controller: ShipAIController
## Used for grouping all spawned instances for easy removal
@export var spawned_objects: SpawnedObjects
@export var ship_acceleration: float = 100000
@export var ball_velocity: float = 2500
@export var ball_fire_interval_seconds: float = 0.1

@onready var _initial_transform := global_transform

var can_shoot: bool
var time_since_ball_spawned: float
var requested_movement: float
var requested_shoot: float

var _time_survived: float


func _ready() -> void:
	reposition_player()


func _physics_process(delta: float) -> void:
	var direction: float

	_time_survived += delta
	requested_movement = signf(requested_movement)

	direction = requested_movement

	velocity += global_transform.x * direction * ship_acceleration * delta
	velocity = velocity.move_toward(Vector2.ZERO, ship_acceleration * 0.95 * delta)

	move_and_slide()

	time_since_ball_spawned += delta
	if can_shoot and requested_shoot:
		handle_shoot()


func handle_shoot():
	if time_since_ball_spawned > ball_fire_interval_seconds:
		var ball = ball_scene.instantiate() as Ball
		spawned_objects.add_child(ball)
		ball.global_position = global_position
		ball.linear_velocity = ((-global_transform.y.normalized()) * ball_velocity)
		ball.spawned_by = self
		time_since_ball_spawned = 0


func game_over(final_reward := 0.0) -> void:
	_time_survived = 0

	# Uncomment if you want to remove all spawned objects on reset
	# currently we keep all objects around
	#spawned_objects.remove_all_spawned_items()

	ai_controller.end_episode(final_reward)

	# Uncomment if you want to reposition the player on reset
	#reposition_player()
	velocity = Vector2.ZERO


func reposition_player():
	global_transform = _initial_transform
	position.x = randf_range(100, 1800)


## Called by an asteroid instance that hits the ship
func hit_by_asteroid() -> void:
	# Check that the ship has survived for longer than n seconds
	# this adds a "protection period" after getting hit by an asteroid
	if _time_survived > 1.0:
		game_over(-1.0)
		_time_survived = 0


## Called by a ball instance that has hit an asteroid
func hit_an_asteroid():
	ai_controller.reward += 0.1
