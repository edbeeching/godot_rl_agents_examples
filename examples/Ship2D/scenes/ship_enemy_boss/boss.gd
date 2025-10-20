extends Area2D
class_name ShipEnemyBoss

@export var player_ship: Ship
## Used for grouping all spawned instances for easy removal
@export var spawned_objects: SpawnedObjects
@export var health_bar: HealthBar
## How much damage to receive if hit (by player projectile only for now)
@export var damage_taken_per_hit := 0.45
@export var projectile_scene: PackedScene
## How many projectiles to spawn at once (in sequence)
@export var proj_spawn_count_sequence := [1, 3, 2, 4, 3, 5]
## The cone width of the spawned projectiles
@export var fire_cone_width := PI / 1.25
## Time between spawning projectiles
@export var fire_interval := 1.38
## Velocity of the spawned projectiles
@export var proj_velocity: float = 1000
## The animation (used for different movement sequences of the boss)
@export var animation: AnimationPlayer

@onready var _initial_transform = transform
var _proj_spawn_count_sequence_index := 0

var _fire_timer: float = 0
var _hp := 100.0:
	set = set_hp


func _physics_process(delta: float) -> void:
	handle_shoot(delta)


func handle_shoot(delta):
	_fire_timer += delta
	if _fire_timer > fire_interval:
		var spawn_count = proj_spawn_count_sequence[_proj_spawn_count_sequence_index]
		shoot(spawn_count, fire_cone_width, true)
		_proj_spawn_count_sequence_index += 1
		_proj_spawn_count_sequence_index %= proj_spawn_count_sequence.size()
		_fire_timer = 0


## Spawns projs
func shoot(spawn_count: int, cone_width: float, center_at_player: bool = false):
	var step := cone_width / spawn_count
	var start_angle := -(cone_width / 2.0) + (step / 2.0)

	for i in spawn_count:
		var projectile = projectile_scene.instantiate() as Projectile
		spawned_objects.add_child(projectile)

		projectile.global_position = global_position

		var projectile_direction: Vector2
		if center_at_player:
			projectile_direction = projectile.global_position.direction_to(
				player_ship.global_position
			)
		else:
			projectile_direction = Vector2.DOWN

		projectile.global_position += projectile_direction * 50.0
		projectile.linear_velocity = projectile_direction * proj_velocity

		var angle := start_angle + i * step
		projectile.linear_velocity = projectile.linear_velocity.rotated(angle)
		projectile.spawned_by = self


## Called by a projectile instance that hit the ship
func hit():
	_hp -= damage_taken_per_hit
	if _hp < 0.1:
		reset()
	player_ship.ai_controller.reward += 0.1


func set_hp(value):
	_hp = value
	health_bar.set_health(_hp)


func reset():
	animation.stop()
	animation.play("animation")
	_hp = 100
	_fire_timer = 0
	_proj_spawn_count_sequence_index = 0
	reposition()


func reposition():
	if _initial_transform:
		transform = _initial_transform
