@tool
extends Node3D

enum TileColor {
  Green, Desert, Blue, Red, Yellow
}

@export var tileColor : TileColor = TileColor.Green:
	set(value):
		$Meshes.get_child(0).visible = false
		$Meshes.get_child(1).visible = false
		$Meshes.get_child(2).visible = false
		$Meshes.get_child(3).visible = false
		$Meshes.get_child(4).visible = false
		
		match value:
			TileColor.Green:
				$Meshes.get_child(0).visible = true	
			TileColor.Desert:
				$Meshes.get_child(1).visible = true	
			TileColor.Blue:
				$Meshes.get_child(2).visible = true	
			TileColor.Red:
				$Meshes.get_child(3).visible = true	
			TileColor.Yellow:
				$Meshes.get_child(4).visible = true	
		tileColor = value

