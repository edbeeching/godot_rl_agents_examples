extends Area3D
class_name Goal

signal ball_entered(goal: Goal)


func _ready():
	connect("body_entered", on_body_entered)


func on_body_entered(body):
	if body is Ball:
		ball_entered.emit(self)
