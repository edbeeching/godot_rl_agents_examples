extends Node

#@export var ship: Ship
@export var asteroid_scene: PackedScene

## Used for grouping all spawned instances for easy removal when needed
@export var spawned_objects: SpawnedObjects

@export var asteroid_spawn_interval_min := 0.2
@export var asteroid_spawn_interval_max := 0.5
var _asteroid_spawn_interval: float
var _asteroid_spawn_timer: float


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	_asteroid_spawn_timer += delta

	if _asteroid_spawn_timer > _asteroid_spawn_interval:
		spawn_asteroid(randi_range(1, 2))
		reset_spawn_timer()


func reset_spawn_timer() -> void:
	_asteroid_spawn_interval = randf_range(asteroid_spawn_interval_min, asteroid_spawn_interval_max)
	_asteroid_spawn_timer = 0


func spawn_asteroid(count: int = 1):
	for i in count:
		var asteroid := asteroid_scene.instantiate() as Asteroid
		spawned_objects.add_child(asteroid)
		asteroid.position = Vector2(randf_range(0, 1920), -500)
		asteroid.randomize_speed()
