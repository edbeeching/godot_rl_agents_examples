extends Node3D



@onready var animation_tree : AnimationTree = $AnimationTree
@onready var _playerback : AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

enum States {IDLE, RUN, AIR}


func _ready():
    animation_tree.active = true

func transition_to(state_id: States): 
    prints("transition to ", state_id)
    match state_id:
        States.IDLE:
            _playerback.travel("Idle")
        States.RUN:
            _playerback.travel("RunBlend")
        _:
            _playerback.travel("Idle")
            
func set_velocity(velocity: Vector3):
    animation_tree.set("parameters/RunBlend/blend_position", Vector2(velocity.x, velocity.z))
    print(velocity)
        
