extends PlayerState


func unhandled_input(event):
	_parent.unhandled_input(event)
	
func process(delta):
	_parent.process(delta)
	
func physics_process(delta):
	_parent.physics_process(delta)
	if player.velocity.length() < 0.01 and player.is_on_floor():
		_state_machine.transition_to("Move/Idle")
	player.character.set_velocity(player.transform.basis.inverse() * player.velocity)
	

func enter(msg: ={}):
	player.character.transition_to(player.character.States.RUN)
	_parent.enter(msg)
	
func exit():
	_parent.exit()
