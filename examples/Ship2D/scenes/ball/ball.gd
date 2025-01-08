extends Area2D
class_name Ball

## Removes this instance after n seconds, if no other code removes it before that
@export var remove_after_seconds: int = 10

## Tracks how long this instance exists
var seconds: float

## Linear velocity for movement, initially set by other nodes
var linear_velocity: Vector2

## The ship that spawned this instance
var spawned_by: Ship


func _physics_process(delta: float) -> void:
	process_remove_after_timeout(delta)
	process_movement(delta)


## Moves the asteroid
func process_movement(delta):
	position += linear_velocity * delta


## Removes the asteroid after `remove_after_seconds`, this is a safeguard
## in case the instance is not already removed by collisions or other code
func process_remove_after_timeout(delta):
	seconds += delta
	if seconds > remove_after_seconds:
		queue_free()


## Handles collisions with other physics bodies (for now, only walls)
func _on_body_entered(body: Node) -> void:
	queue_free()


## Handles collisions with other instances, and asteroids
func _on_area_entered(area: Area2D) -> void:
	if area is Asteroid:
		spawned_by.hit_an_asteroid()
		area.destroy()
	queue_free()
