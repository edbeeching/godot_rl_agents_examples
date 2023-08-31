extends AIController3D


@onready var grid_sensor_3d = $GridSensor3D

var fb_action : float = 0.0
var turn_action : float = 0.0
var _player_positions : = Deque.new()


func _ready():
	super._ready()
	_player_positions.max_size = 80 # 10 steps with repeat of 8

func get_obs() -> Dictionary:
	var obs = grid_sensor_3d.get_observation()
	return {"obs": obs}

func get_reward() -> float:
	return reward + keep_moving_reward()
	
func keep_moving_reward() -> float:
	var mean_position = Vector3.ZERO
	for pos in _player_positions:
		mean_position += pos
	mean_position /= _player_positions.size()
	
	var penalty = 0.0
	
	for pos in _player_positions:
		penalty += (pos-mean_position).length()
	
	#prints("penalty", 0.01*(penalty / _player_positions.size()))
	
	return 0.005*(penalty / _player_positions.size())

func _physics_process(delta):
	_player_positions.push_back(_player.position)

func reset():
	super.reset()
	_player_positions.clear()
	_player_positions.push_back(_player.position)
	


func get_action_space() -> Dictionary:
	return {
		"fb" : {
			"size": 1,
			"action_type": "continuous"
		},
		"turn" : {
			"size": 1,
			"action_type": "continuous"
		},
	}
	
func set_action(action) -> void:	
	fb_action = clamp(action["fb"][0], -1.0, 1.0)
	turn_action = clamp(action["turn"][0], -1.0, 1.0)
