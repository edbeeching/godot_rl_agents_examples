extends Node3D

enum GameModes { TRAINING, AI_VS_AI, PLAYER_VS_AI }
@export var game_mode: GameModes = GameModes.TRAINING
@export var game_scene: PackedScene

## If set to 0, it will be an infinite race without announcing winners.
@export_range(0, 10, 1, "or_greater") var total_laps := 0

@export var seconds_until_race_begins: int = 5


func _ready():
	var new_game_scene: Node3D = game_scene.instantiate()
	var sync = new_game_scene.get_node("Sync") as SyncAllowHumanControlOnInference
	var cars = new_game_scene.get_node("Cars") as CarManager
	var ui = new_game_scene.get_node("UI") as UI
	var track = new_game_scene.get_node("Track") as Track

	cars.infinite_race = false if total_laps > 0 else true
	cars.total_laps = total_laps
	ui.total_laps = total_laps
	cars.ui = ui
	cars.seconds_until_race_begins = seconds_until_race_begins

	match game_mode:
		GameModes.TRAINING:
			sync.control_mode = sync.ControlModes.TRAINING
			track.training_mode = true
			sync.speed_up = 20.0
		GameModes.AI_VS_AI:
			sync.control_mode = sync.ControlModes.ONNX_INFERENCE
			cars.training_mode = false
			sync.speed_up = 1.0
		GameModes.PLAYER_VS_AI:
			sync.control_mode = sync.ControlModes.ONNX_INFERENCE
			cars.training_mode = false
			cars.player_vs_ai_mode = true
			sync.speed_up = 1.0
	add_child(new_game_scene)
