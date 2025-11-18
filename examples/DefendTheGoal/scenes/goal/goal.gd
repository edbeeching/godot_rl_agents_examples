extends Node3D
class_name Goal

signal ball_entered_goal
signal robot_entered_goal

@export var goal_text: Label3D
var should_show_goal_text: bool = false


func _ready() -> void:
	goal_text.visible = false


func _physics_process(delta: float) -> void:
	process_goal_text(delta)


func _on_area_3d_body_entered(node: Node3D):
	if node is Ball:
		ball_entered_goal.emit()
		show_goal_text()
	elif node is Robot:
		robot_entered_goal.emit()


func show_goal_text():
	should_show_goal_text = true


func process_goal_text(delta):
	if should_show_goal_text:
		if not goal_text.visible:
			goal_text.visible = true
		goal_text.modulate.a -= delta
		if goal_text.modulate.a < 0.1:
			goal_text.visible = false
			should_show_goal_text = false
			goal_text.modulate.a = 1
