extends Node3D
class_name Tile

## Tile class it allows setting the visible tile design by 
## hiding the nodes with not currently used tile designs.
## (Intended to be used with tile.tscn)

## Tile names, must be in the same order as child nodes
enum TileNames {
	orange,
	road,
	tree,
	goal
}

## ID of the current set tile
var id: int

@onready var tiles: Array = get_children()

## Sets the specified tile mesh to be visible, and hides others
func set_tile(tile_name: TileNames):
	hide_all()
	id = int(tile_name)
	tiles[id].visible = true

## Hides all tiles
func hide_all():
	for tile in tiles:
		tile.visible = false
