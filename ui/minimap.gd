extends Camera3D

@export var _follow_scan_radius : float
@export var _target : NodePath

var target : Node

func _ready() -> void:
    size = _follow_scan_radius
    target = get_node(_target)


func _process(_delta: float) -> void:
    position = Vector3(target.position.x, 32, target.position.z)
    rotation_degrees.y = target.rotation_degrees.y
