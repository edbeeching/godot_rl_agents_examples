extends Node3D

@onready var islands = $Islands
@onready var mines = $Mines
@onready var chests = $Chests

@export var n_islands := 100
@export var n_chests := 100
@export var n_mines := 100

var world_size := Rect2(-50, -50, 100, 100)
var spawn_zone := Rect2(-5, -5, 10, 10)

var island_scene = preload("res://island.tscn")
var chest_scene = preload("res://chest.tscn")
var mine_scene = preload("res://mine.tscn")

var bbs : Array[Rect2]= []
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	spawn_world()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func spawn_world():
	spawn_islands()
	spawn_chests()
	spawn_mines()
	
	
func bb_overlaps(rect: Rect2)->bool:
	for bb in bbs:
		if bb.intersects(rect):
			return true
	
	return false


func find_valid_position(aabb) -> Vector2:
	var x_pos = randf_range(world_size.position.x, world_size.end.x)
	var z_pos = randf_range(world_size.position.y, world_size.end.y)
	var aabb2d = Rect2(Vector2(aabb.position.x+x_pos, aabb.position.z+z_pos), Vector2(aabb.size.x, aabb.size.z))

	while bb_overlaps(aabb2d): # change to n_tries
		x_pos = randf_range(world_size.position.x, world_size.end.x)
		z_pos = randf_range(world_size.position.y, world_size.end.y)
		aabb2d = Rect2(Vector2(aabb.position.x+x_pos, aabb.position.z+z_pos), Vector2(aabb.size.x, aabb.size.z))
		
	return Vector2(aabb.position.x+x_pos, aabb.position.z+z_pos)
	
func spawn_scene(scene):
	var instance = scene.instantiate()
	var aabb = instance.get_mesh_aabb()
	var spawn_position = find_valid_position(aabb)
	var aabb2d = Rect2(spawn_position, Vector2(aabb.size.x, aabb.size.z))
	
	bbs.append(aabb2d)
	instance.position = Vector3(spawn_position.x, 0.0, spawn_position.y)
	
	return instance

func spawn_islands():
	for i in n_islands:
		islands.add_child(spawn_scene(island_scene))
	
	
func spawn_chests():
	for i in n_chests:
		chests.add_child(spawn_scene(chest_scene))
	
func spawn_mines():
	for i in n_mines:
		mines.add_child(spawn_scene(mine_scene))
