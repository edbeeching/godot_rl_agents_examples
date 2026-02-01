extends ISensor2D

## Reports character body velocities
## Note: velocity is in global reference, not transformed
## (as the players in this env do not rotate, it should be sufficient)

@export var objects_to_observe: Array[CharacterBody2D]
## Max expected velocity used for normalization (larger values will be clipped)
@export var max_velocity := 1500


func get_observation():
	var observations: Array[float]

	for obj in objects_to_observe:
		var velocity := obj.get_real_velocity().limit_length(max_velocity) / max_velocity
		observations.append_array([velocity.x, velocity.y])

	return observations
