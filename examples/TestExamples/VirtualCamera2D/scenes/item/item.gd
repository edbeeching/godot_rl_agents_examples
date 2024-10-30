extends Area2D
class_name Item

enum Type {
	GOAL,
	OBSTACLE,
}

var type: Type


func set_type(new_type: Type):
	match new_type:
		Type.GOAL:
			$GoalColor.visible = true
			$ObstacleColor.visible = false
		Type.OBSTACLE:
			$ObstacleColor.visible = true
			$GoalColor.visible = false
	type = new_type
