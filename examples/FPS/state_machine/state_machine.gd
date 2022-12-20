extends Node
class_name StateMachine

signal transitioned
var _state_name : String 
var controlled : bool = true

@export_node_path var state_path
@onready var state = get_node(state_path):
	get: return state
	set(value):
		state = value
		_state_name = state.name

func init(player):
	for child in get_children():
		child.init(player)
	state.enter()

func _process(delta):
	state.process(delta)
	
func _physics_process(delta):
	return
	if controlled:
		state.physics_process(delta)
	
func transition_to(target_state_path:String, msg={}):
	if not has_node(target_state_path):
		return
	
	var target_state = get_node(target_state_path)
	state.exit()
	self.state = target_state
	state.enter(msg)
	emit_signal("transitioned")
	
func _unhandled_input(event):
	if controlled:
		state.unhandled_input(event)
