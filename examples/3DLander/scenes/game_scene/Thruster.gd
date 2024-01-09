extends MeshInstance3D
class_name Thruster

## Lander thruster. This class keeps track of current activation strength 
## and handles the particle effects.  

var thruster_strength: float
@onready var _particles: GPUParticles3D = $GPUParticles3D
var _material: ParticleProcessMaterial

func _ready():
	_material = _particles.process_material

func _physics_process(delta):
	if thruster_strength > 0.01:
		if not _particles.emitting:
			_particles.emitting = true
			_material.initial_velocity_max = 0.01 + thruster_strength / 300.0
			_material.initial_velocity_min = _material.initial_velocity_max
	else:
		if _particles.emitting:
			_particles.emitting = false
