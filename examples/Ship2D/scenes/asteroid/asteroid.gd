extends Area2D
class_name Asteroid

@export var downward_speed_min := 500.0
@export var downward_speed_max := 900.0

var _downward_speed: float
var _sideways_speed: float
var _active_sprite: Sprite2D
var _sprite_rotation = randf_range(-5, 5)

@onready var particles := $GPUParticles2D
@onready var _sprites: Array = $Sprites.get_children()


func _ready() -> void:
	var rand_scale := randf_range(0.7, 2)
	scale = Vector2(rand_scale, rand_scale)
	randomize_speed()
	enable_random_sprite()


func _physics_process(delta: float) -> void:
	process_movement(delta)
	process_remove_on_out_of_bounds()

	_active_sprite.rotate(_sprite_rotation * delta)


## Moves the asteroid
func process_movement(delta):
	position.x += _sideways_speed * delta
	position.y += _downward_speed * delta


## Removes the asteroid if outside of the playing area
## (each instance that is not destroyed by ship or another asteroid should be removed by this method)
func process_remove_on_out_of_bounds():
	if position.y > 2000:
		queue_free()


func enable_random_sprite():
	var sprite = _sprites.pick_random()
	_active_sprite = sprite
	_active_sprite.visible = true


## Randomizes the speed of the asteroid
func randomize_speed():
	_downward_speed = randf_range(downward_speed_min, downward_speed_max)
	_sideways_speed = randf_range(-0.1, 0.1) * _downward_speed


## Called when an asteroid is hit
func hit():
	destroy()


## Destroys the asteroid, leaving a particle effect
var destroying: bool


func destroy():
	if destroying:
		return
	particles.emitting = true
	_active_sprite.visible = false
	set_deferred("process_mode", PROCESS_MODE_DISABLED)
	destroying = true
	await particles.finished
	queue_free()


func _on_particles_finished():
	queue_free()


## Handles collision with physics bodies (for now, only player/ship)
func _on_body_entered(body: PhysicsBody2D) -> void:
	if body is Ship:
		body.hit_by_asteroid()
	destroy()


## Handles collisions with other areas (for now, specifically other asteroids)
func _on_area_entered(area: Area2D) -> void:
	if area is Asteroid:
		destroy()
