extends Area2D
class_name Player

@export var playing_area: ColorRect
@export var item_manager: ItemManager
@export var movement_speed := 50.0

@onready var ai_controller := $AIController2D
@onready var playing_area_rect = playing_area.get_global_rect()
@onready var color_rect = $ColorRect
@onready var initial_transform = transform

## Value set by ai_controller
var requested_movement: Vector2


func _ready():
	reset()


func _physics_process(delta: float) -> void:
	position += requested_movement * movement_speed * delta
	ensure_within_bounds()


func ensure_within_bounds():
	if not playing_area_rect.encloses(color_rect.get_global_rect()):
		game_over(-1.0)


func reset():
	transform = initial_transform
	item_manager.reset()


func game_over(reward: float = 0.0):
	ai_controller.reward += reward
	ai_controller.end_episode()
	reset()


func _on_area_entered(area: Area2D) -> void:
	if area is Item:
		match area.type:
			Item.Type.GOAL:
				game_over(1.0)
			Item.Type.OBSTACLE:
				game_over(-1.0)
