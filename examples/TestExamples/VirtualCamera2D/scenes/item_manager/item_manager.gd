extends Node2D
class_name ItemManager

@onready var items := get_children()

## Randomly sets an item as goal
func reset():
	var goal_index = randi_range(0, items.size() - 1)
	for item_idx in items.size():
		var type
		if item_idx == goal_index:
			type = Item.Type.GOAL
		else:
			type = Item.Type.OBSTACLE

		items[item_idx].set_type(type)
