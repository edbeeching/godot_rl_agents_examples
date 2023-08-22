extends Node3D

@onready var islands = $Islands
@onready var mines = $Mines
@onready var chests = $Chests

@export var n_islands := 100
@export var n_chests := 100
@export var n_mines := 100

@export var world_size := Rect2(-50, -50, 100, 100)
@export var spawn_zone := Rect2(-5, -5, 10, 10)

var island_scenes = [preload("res://islands.tscn")]
var chest_scenes = [preload("res://chest.tscn")]
var mine_scenes = [preload("res://mine.tscn")]

var bbs : Array[Rect2]= []
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	bbs.append(spawn_zone)
	spawn_world()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func spawn_world():
	spawn_islands()
	spawn_chests()
	spawn_mines()
	
	
func bb_overlaps(rect: Rect2)->bool:
	var expanded_rect = rect.grow(5.0)
	for bb in bbs:
		if bb.intersects(expanded_rect):
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
	print(aabb)
	var spawn_position = find_valid_position(aabb)
	var aabb2d = Rect2(spawn_position, Vector2(aabb.size.x, aabb.size.z))
	
	bbs.append(aabb2d)
	instance.position = Vector3(spawn_position.x, 0.0, spawn_position.y)
	
	#instance.rotate_y(randf_range(0,2*PI))
	
	return instance


func clear_and_spawn(parent, scenes: Array, count):
	for child in parent.get_children():
		child.queue_free()	

	for i in count:
		var scene = scenes.pick_random()
		var instance = spawn_scene(scene)
		parent.add_child(instance)
		instance.set_owner(get_tree().edited_scene_root)

func spawn_islands():
	clear_and_spawn(islands, island_scenes, n_islands)
	
func spawn_chests():
	clear_and_spawn(chests, chest_scenes, n_chests)
	
func spawn_mines():
	clear_and_spawn(mines, mine_scenes, n_mines)
