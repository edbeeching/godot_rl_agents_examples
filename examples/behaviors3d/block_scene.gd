extends Level

const AABB_MARGIN := Vector3(1.0, 1.0, 1.0)
var aabbs : Array[AABB] = []

@export var object_pool : Array[PackedScene]

@onready var ground = $Ground   


func generate_level() -> void:
    _adjust_ground()
    _spawn_objects()

func get_spawn_location() -> Vector3:
    return Vector3(
        randf_range(-ground.size.x/2, ground.size.x/2), 
        5,
        randf_range(-ground.size.z/2, ground.size.z/2)
    )

func get_target_location() -> Vector3:
    return Vector3(
        randf_range(-ground.size.x/2, ground.size.x/2), 
        1,
        randf_range(-ground.size.z/2, ground.size.z/2)
    )

func _intersects_aabb(aabb:AABB) -> bool:
    for other_aabb in aabbs:
        if aabb.intersects(other_aabb):
            return true
    return false


func _adjust_ground() -> void:
    ground.size = Vector3(randf_range(10, 40), 1, randf_range(10, 40))

    get_node("Walls/Left").position = Vector3(-ground.size.x/2, 0, 0)
    get_node("Walls/Left").size.x = ground.size.z
    get_node("Walls/Right").position = Vector3(ground.size.x/2, 0, 0)
    get_node("Walls/Right").size.x = ground.size.z
    get_node("Walls/Forward").position = Vector3(0, 0, -ground.size.z/2)
    get_node("Walls/Forward").size.x = ground.size.x
    get_node("Walls/Backward").position = Vector3(0, 0, ground.size.z/2)
    get_node("Walls/Backward").size.x = ground.size.x

func _spawn_objects() -> void:
    var total_area = ground.size.x * ground.size.z
    var max_objects = int(total_area)
    for i in range(max_objects):
        var object = object_pool.pick_random().instantiate()
        add_child(object)
        # object.rotate_y(deg_to_rad(randf_range(0, 360)))
        object.position = Vector3(
            randf_range(-ground.size.x/2 + object.size.x/2, ground.size.x/2 - object.size.x/2), 
            5, 
            randf_range(-ground.size.z/2 + object.size.z/2, ground.size.z/2 - object.size.z/2)
        )
        # TODO: this is not perfect, but it's good enough for now
        var object_aabb = AABB(Vector3.ZERO, object.size + AABB_MARGIN)
        var rotated_aabb = object.transform * object_aabb
        rotated_aabb.position = object.position
        if _intersects_aabb(rotated_aabb):
            object.queue_free()
            continue
        

        aabbs.append(rotated_aabb)
