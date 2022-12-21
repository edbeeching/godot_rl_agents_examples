extends Node3D

@export var num_players = 2
@export var num_teams = 1
var current_spawn = 0
var player_scene = preload("res://player.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	_spawn_players()
	GameManager.main = self
	
func _spawn_players():
	for i in num_players:
		var player = player_scene.instantiate()
		
		$Players.add_child(player)
		
		if num_teams > 1:
			assert((num_players % num_teams) == 0) # we want even sized teams
			var team = i % num_teams
			player.set_team(team)
		set_player_spawn(player)
		
	
func set_player_spawn(player):
	if num_teams > 1:
		while $SpawnPoints.get_child(current_spawn).team != player.team:
			current_spawn = wrapi(current_spawn+1, 0, $SpawnPoints.get_child_count())
	var spawn_position = $SpawnPoints.get_child(current_spawn).position
	player.position = spawn_position
	current_spawn = wrapi(current_spawn+1, 0, $SpawnPoints.get_child_count())
	

