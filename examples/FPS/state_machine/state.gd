extends Node
class_name State

var _parent : State = null

@onready var _state_machine : StateMachine = _get_state_machine(self)

func unhandled_input(event):
	return
	
func process(delta):
	return
	
func physics_process(delta):
	return

func enter(msg: ={}):
	return
	
func exit():
	pass
	
func _get_state_machine(node:Node):
	if not node is StateMachine:
		return _get_state_machine(node.get_parent())
	return node
