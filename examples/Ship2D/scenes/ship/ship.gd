extends CharacterBody2D
class_name Ship

@export var boss_ship: ShipEnemyBoss
@export var projectile_scene: PackedScene
@export var ai_controller: ShipAIController
## Used for grouping all spawned instances for easy removal
@export var spawned_objects: SpawnedObjects
@export var ship_acceleration: float = 100000
@export var projectile_velocity: float = 2500
@export var projectile_fire_interval_seconds: float = 0.1

@onready var _initial_transform := global_transform

var can_shoot: bool
var time_since_projectile_spawned: float
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

	time_since_projectile_spawned += delta
	if can_shoot and requested_shoot:
		handle_shoot()


func handle_shoot():
	if time_since_projectile_spawned > projectile_fire_interval_seconds:
		var projectile = projectile_scene.instantiate() as Projectile
		spawned_objects.add_child(projectile)
		projectile.global_position = global_position - global_transform.orthonormalized().y * 100
		projectile.linear_velocity = ((-global_transform.y.normalized()) * projectile_velocity)
		projectile.spawned_by = self
		time_since_projectile_spawned = 0


func game_over(final_reward := 0.0) -> void:
	_time_survived = 0

	# Uncomment if you want to remove all spawned objects on reset
	# currently we keep all objects around
	spawned_objects.remove_all_spawned_items()

	ai_controller.end_episode(final_reward)

	# Uncomment if you want to reposition the player on reset
	reposition_player()
	velocity = Vector2.ZERO


func reposition_player():
	global_transform = _initial_transform
	if boss_ship:  # Might be moved to a scene manager in future updates
		boss_ship.reset()


## Called by an asteroid instance that hits the ship
func hit_by_asteroid() -> void:
	# Check that the ship has survived for longer than n seconds
	# this adds a "protection period" after getting hit by an asteroid
	if _time_survived > 1.0:
		game_over(-1.0)
		_time_survived = 0


## Called by a projectile instance that has hit an asteroid
func hit_an_asteroid():
	ai_controller.reward += 0.1


## Called by a projectile instance that hit the ship
func hit():
	#print("Player hit by boss")
	game_over(-10.0)
