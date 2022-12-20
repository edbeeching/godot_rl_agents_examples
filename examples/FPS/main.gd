extends Node3D

@export var num_players = 2

var current_spawn = 0
var player_scene = preload("res://player.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	_spawn_players()
	GameManager.main = self
	
func _spawn_players():
	for i in num_players:
		var player = player_scene.instantiate()
		set_player_spawn(player)
		$Players.add_child(player)
		
	
func set_player_spawn(player):
	var spawn_position = $SpawnPoints.get_child(current_spawn).position
	player.position = spawn_position
	current_spawn = wrapi(current_spawn+1, 0, $SpawnPoints.get_child_count())
	

