extends GPUParticles3D
class_name Thruster

var thruster_strength: float

@onready var material: ParticleProcessMaterial = process_material

func set_thruster_strength(strength: float):
	material.initial_velocity_min = 0.022 * strength + 0.015
	material.initial_velocity_max = 0.1 * strength + 0.015
