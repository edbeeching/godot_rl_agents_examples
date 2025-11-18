extends RigidBody3D
class_name Pusher

@export var score_font_size = 32
@export var reset_score_at_points := 2
@export var acceleration := 1000
@export var puck: Puck
@export var goal: Area3D
@export var other_player: Pusher

var requested_movement: Vector3

var _initial_position: Vector3
var _time_since_puck_pushed: float
var _penalty_if_puck_not_pushed_for_seconds: float = 3
var _score: int

## Used during the "winner" text being displayed
## to prevent the option of two players being marked winners at once
var _freeze_score_update: bool

@onready var _above_player_label: Label3D = $Label3D
@onready var _AIController3D: AIController3D = $AIController3D


func _ready():
	_AIController3D.init(self)
	_initial_position = position


func reset():
	position = _initial_position


var movement: Vector3


func _physics_process(delta):
	if _AIController3D.needs_reset:
		_AIController3D.reset()
		reset()

	if _AIController3D.heuristic != "human":
		movement = requested_movement
	else:
		movement.x = Input.get_axis("left", "right")
		movement.z = -Input.get_axis("backward", "forward")

	if movement:
		apply_central_force(global_transform.basis * movement.limit_length(1) * acceleration)
		movement = Vector3.ZERO

	# Small penalty for standing still
	if linear_velocity.length() < 0.1:
		_AIController3D.reward -= 0.00075

	_time_since_puck_pushed += delta

	if _time_since_puck_pushed > _penalty_if_puck_not_pushed_for_seconds:
		_AIController3D.reward -= 1 * delta


func _on_body_entered(body: PhysicsBody3D):
	if body == puck:
		_time_since_puck_pushed = 0


func _on_goal_body_entered(_body):
	_AIController3D.reward += 10
	_AIController3D.done = true
	_AIController3D.needs_reset = true
	_score += 1
	update_score_text()

	other_player._AIController3D.reward -= 10
	other_player._AIController3D.done = true
	other_player._AIController3D.needs_reset = true


func reset_score():
	_score = 0
	update_score_text()


func update_score_text():
	if _freeze_score_update:
		return

	_above_player_label.text = str(_score)

	if _score >= reset_score_at_points:
		_above_player_label.text = "Winner"
		_above_player_label.font_size = score_font_size * 2.0
		_above_player_label.modulate = Color.GREEN
		_freeze_score_update = true
		await get_tree().create_timer(0.5, true, true).timeout
		_freeze_score_update = false
		_above_player_label.font_size = score_font_size
		_above_player_label.modulate = Color.WHITE
		reset_score()
		other_player.reset_score()
