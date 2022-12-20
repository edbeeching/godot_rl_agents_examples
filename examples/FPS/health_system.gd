extends Node

@export var starting_hp = 30
var hp = starting_hp

var player : Player = null

func init(p):
	player = p
	
func reset():
	hp = starting_hp
	
func take_damage(damage):
	hp -= damage
	#prints("take damage", hp, damage, hp <= 0)
	if hp <= 0:
		die()
	
func die():
	player.died()
	#print("player died")
	
