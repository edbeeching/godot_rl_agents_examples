extends Node3D
class_name LevelManager

@export var robot: Robot
@export var level_goal_scene: PackedScene

@onready var levels = get_children()

var coins_in_level: Array[Array]
var active_coins_in_level_count: Array[int]
var enemies: Array[Enemy]

var level_start_points: Array
var level_goals: Array


func _ready():
	for node in find_children("Coin_*", "MeshInstance3D"):
		node.set_script(Coin)
		node.set_physics_process(true)


	level_start_points.resize(levels.size())
	level_goals.resize(levels.size())
	active_coins_in_level_count.resize(levels.size())
	active_coins_in_level_count.fill(0)
	coins_in_level.resize(levels.size())

	for level_id in range(0, levels.size()):
		var start_node = levels[level_id].find_child("Start*")
		level_start_points[level_id] = start_node.get_children()
		var end_node = levels[level_id].find_child("End*")
		level_goals[level_id] = end_node.get_children()
		for goal in level_goals[level_id]:
			var level_goal_area = level_goal_scene.instantiate()
			goal.add_child(level_goal_area)
			goal.visible = false
			level_goal_area.position = Vector3.ZERO
		var coins = levels[level_id].find_child("Coins*")
		if coins:
			active_coins_in_level_count[level_id] = coins.get_child_count()
			for node in coins.get_children():
				var coin = node as MeshInstance3D
				var coin_area = Area3D.new()
				var coin_area_shape = CollisionShape3D.new()
				coin_area_shape.shape = SphereShape3D.new()
				coin_area.add_child(coin_area_shape)
				coin_area.monitorable = true
				coin_area.set_collision_layer_value(1, false)
				coin_area.set_collision_layer_value(2, true)
				var coin_parent = coin.get_parent()
				coin_parent.add_child(coin_area)
				coin_area.global_position = coin.global_position
				coin.reparent(coin_area)
				if not coins_in_level[level_id]:
					coins_in_level[level_id] = []
				coins_in_level[level_id].append(coin_area)

		var enemy_parent = levels[level_id].find_child("Enemies*") as Node3D
		if enemy_parent:
			for enemy in enemy_parent.get_children():
				enemy = enemy as Node3D
				var enemy_area = Area3D.new()
				var enemy_area_shape = CollisionShape3D.new()
				enemy_area_shape.shape = SphereShape3D.new()
				enemy_area.add_child(enemy_area_shape)
				enemy_area.monitorable = true
				enemy_area.monitoring = true
				enemy_area.set_collision_layer_value(1, false)
				enemy_area.set_collision_layer_value(4, true)
				enemy_area.set_collision_mask_value(1, true)
				enemy.set_script(Enemy)
				enemy.set_physics_process(true)
				enemy.add_child(enemy_area)
				enemy_area.connect("body_entered", enemy.on_wall_hit)
				enemies.append(enemy)


func randomize_goal(level_id: int):
	var active_goal_id = randi_range(0, level_goals[level_id].size() - 1)
	for goal_id in range(0, level_goals[level_id].size()):
		var goal = level_goals[level_id][goal_id]
		if goal_id == active_goal_id:
			goal.visible = true
			goal.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			goal.visible = false
			goal.process_mode = Node.PROCESS_MODE_DISABLED
	return level_goals[level_id][active_goal_id].global_transform


func get_closest_enemy(from_global_position: Vector3):
	var closest_enemy: Enemy
	var smallest_distance: float = INF
	for enemy in enemies:
		var distance: float = enemy.global_position.distance_to(from_global_position)
		if distance < smallest_distance:
			smallest_distance = distance
			closest_enemy = enemy
	return closest_enemy


func get_closest_active_coin(from_global_position: Vector3, level: int):
	var closest_coin: Area3D
	var smallest_distance: float = INF
	for coin in coins_in_level[level]:
		if coin.visible == false:
			continue
		var distance: float = coin.global_position.distance_to(from_global_position)
		if distance < smallest_distance:
			smallest_distance = distance
			closest_coin = coin
	return closest_coin


func deactivate_coin(coin: Area3D, current_level: int):
	active_coins_in_level_count[current_level] -= 1
	coin.set_deferred("monitorable", false)
	coin.visible = false
	coin.process_mode = Node.PROCESS_MODE_DISABLED


func check_all_coins_collected(current_level: int) -> bool:
	return active_coins_in_level_count[current_level] == 0


func reset_coins(current_level: int):
	var coins: Array = coins_in_level[current_level]
	for coin in coins:
		if not coin.visible:
			coin.set_deferred("monitorable", true)
			coin.visible = true
			coin.process_mode = Node.PROCESS_MODE_INHERIT
	active_coins_in_level_count[current_level] = coins.size()


func get_spawn_position(level: int) -> Vector3:
	var start_points: Array[Node] = level_start_points[min(level, levels.size() - 1)]
	return start_points.pick_random().global_position
