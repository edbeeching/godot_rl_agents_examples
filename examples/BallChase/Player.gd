extends CharacterBody2D

const pad = 100
const WIDTH = 1280
const HEIGHT = 720
const MAX_FRUIT = 10
var _bounds := Rect2(pad, pad, WIDTH - 2 * pad, HEIGHT - 2 * pad)

@export var speed := 500
@export var friction = 0.18
var _velocity := Vector2.ZERO
var _action = Vector2.ZERO
@onready var fruit = $"../Fruit"
@onready var raycast_sensor = $"RaycastSensor2D"
@onready var walls := $"../Walls"
@onready var colision_shape := $"CollisionShape2D"
@onready var ai_controller := $AIController2D
var fruit_just_entered = false
var just_hit_wall = false
var best_fruit_distance = 10000.0
var fruit_count = 0


func _ready():
	ai_controller.init(self)
	raycast_sensor.activate()


func _physics_process(_delta):
	var direction = get_direction()
	if direction.length() > 1.0:
		direction = direction.normalized()
	# Using the follow steering behavior.
	var target_velocity = direction * speed
	_velocity += (target_velocity - _velocity) * friction
	set_velocity(_velocity)
	move_and_slide()
	_velocity = velocity

	update_reward()

	if Input.is_action_just_pressed("r_key"):
		game_over()


func game_over():
	fruit_just_entered = false
	just_hit_wall = false
	fruit_count = 0
	_velocity = Vector2.ZERO
	_action = Vector2.ZERO
	position = _calculate_new_position()
	spawn_fruit()
	best_fruit_distance = position.distance_to(fruit.position)
	ai_controller.reset()


func _calculate_new_position(current_position: Vector2 = Vector2.ZERO) -> Vector2:
	var new_position := Vector2.ZERO
	new_position.x = randf_range(_bounds.position.x, _bounds.end.x)
	new_position.y = randf_range(_bounds.position.y, _bounds.end.y)

	if (current_position - new_position).length() < 4.0 * colision_shape.shape.get_radius():
		return _calculate_new_position(current_position)

	var radius = colision_shape.shape.get_radius()
	var rect = Rect2(new_position - Vector2(radius, radius), Vector2(radius * 2, radius * 2))
	for wall in walls.get_children():
		#wall = wall as Area2D
		var cr = wall.get_node("ColorRect")
		var rect2 = Rect2(cr.get_position() + wall.position, cr.get_size())
		if rect.intersects(rect2):
			return _calculate_new_position()

	return new_position


func get_direction():
	if ai_controller.done:
		_velocity = Vector2.ZERO
		return Vector2.ZERO

	if ai_controller.heuristic == "model":
		return _action

	var direction := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)

	return direction


func get_fruit_position():
	return $"../Fruit".global_position


func update_reward():
	ai_controller.reward -= 0.01  # step penalty
	ai_controller.reward += shaping_reward()


func shaping_reward():
	var s_reward = 0.0
	var fruit_distance = position.distance_to(fruit.position)

	if fruit_distance < best_fruit_distance:
		s_reward += best_fruit_distance - fruit_distance
		best_fruit_distance = fruit_distance

	s_reward /= 100.0
	return s_reward


func spawn_fruit():
	fruit.position = _calculate_new_position(position)
	best_fruit_distance = position.distance_to(fruit.position)


func fruit_collected():
	fruit_just_entered = true
	ai_controller.reward += 10.0
	fruit_count += 1
	spawn_fruit()


func wall_hit():
	ai_controller.done = true
	ai_controller.reward -= 10.0
	just_hit_wall = true
	game_over()


func _on_Fruit_body_entered(_body):
	fruit_collected()


func _on_LeftWall_body_entered(_body):
	wall_hit()


func _on_RightWall_body_entered(_body):
	wall_hit()


func _on_TopWall_body_entered(_body):
	wall_hit()


func _on_BottomWall_body_entered(_body):
	wall_hit()
