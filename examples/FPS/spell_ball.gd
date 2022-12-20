extends Node3D


var velocity = Vector3.ZERO
@export var speed = 10

func _physics_process(delta):
    look_at(transform.origin + velocity.normalized(), Vector3.UP)
    transform.origin += velocity * delta



func _on_hurtbox_area_entered(area):
    print("Spellball hit")
    queue_free()
