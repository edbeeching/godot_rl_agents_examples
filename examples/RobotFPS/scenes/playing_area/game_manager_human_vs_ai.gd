extends GameManager


## Overriden to set a robot as human controlled
func _ready():
	spawn_robots()
	_robots[number_of_robots_to_spawn - 1].ai_controller.control_mode = (
		AIController3D.ControlModes.HUMAN
	)
