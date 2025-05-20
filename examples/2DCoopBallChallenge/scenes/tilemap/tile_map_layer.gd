extends TileMapLayer
class_name MapManager

## Maps tile names to tileset atlas coordinates
class Tiles:
	const PLATFORM_LEFT_EDGE = Vector2i(0, 0)
	const PLATFORM_MIDDLE = Vector2i(1, 0)
	const PLATFORM_RIGHT_EDGE = Vector2i(2, 0)
	const GROUND = Vector2i(0, 1)  # currently not used
	const GROUND_2 = Vector2i(1, 1)  # currently not used
	const SPIKES = Vector2i(2, 1)
	const COIN = Vector2i(0, 2)
	const GOAL = Vector2i(1, 2)
	const SPAWN = Vector2i(2, 2)
