extends "res://addons/godot_rl_agents/sync.gd"

## Adds the control mode selection from: https://github.com/edbeeching/godot_rl_agents_plugin/pull/19
enum ControlModes {HUMAN, TRAINING, ONNX_INFERENCE}
@export var control_mode: ControlModes = ControlModes.TRAINING

func _initialize():
	_get_agents()
	_obs_space = agents[0].get_obs_space()
	_action_space = agents[0].get_action_space()
	args = _get_args()
	Engine.physics_ticks_per_second = _get_speedup() * 60 
	Engine.time_scale = _get_speedup() * 1.0
	prints("physics ticks", Engine.physics_ticks_per_second, Engine.time_scale, _get_speedup(), speed_up)
	
	_set_heuristic("human")
	match control_mode:
		ControlModes.TRAINING:
			connected = connect_to_server()
			if connected:
				_set_heuristic("model")
				_handshake()
				_send_env_info()  
			else:
				push_warning("Couldn't connect to Python server, using human controls instead. ",
				"Did you start the training server using e.g. `gdrl` from the console?")
		ControlModes.ONNX_INFERENCE:
				assert(FileAccess.file_exists(onnx_model_path), "Onnx Model Path set on Sync node does not exist: %s" % onnx_model_path)
				onnx_model = ONNXModel.new(onnx_model_path, 1)
				_set_heuristic("model")	
		ControlModes.HUMAN:
			_reset_all_agents()
	
	_set_seed()
	_set_action_repeat()
	initialized = true  
