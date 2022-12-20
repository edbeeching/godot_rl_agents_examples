extends State
class_name PlayerState

var player: Player = null

func init(_player):
	_parent = get_parent() as State
	player = _player
	for child in get_children():
		child.init(player)
	
