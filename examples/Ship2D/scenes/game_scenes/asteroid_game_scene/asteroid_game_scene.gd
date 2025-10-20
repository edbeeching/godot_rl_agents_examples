extends Node2D
class_name AsteroidGameScene

## Used to differentiate envs
static var env_id: int = 0

@export var ship: Ship

## By default, this is enabled for every 2nd env
## but you can override it for testing here
@export var override_can_shoot_always_enabled: bool = false


func _ready() -> void:
	if override_can_shoot_always_enabled:
		ship.can_shoot = 1
		return

	## Enables ship shooting capability for every 2nd env only
	ship.can_shoot = bool(env_id % 2)
	AsteroidGameScene.env_id += 1
