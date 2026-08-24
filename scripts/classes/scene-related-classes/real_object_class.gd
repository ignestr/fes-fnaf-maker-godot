extends Node3D
class_name ObjectScene

# TODO: Properties

var use_power := false
@export var gizmo_mesh : Mesh
@export var aabb_mesh : Mesh
@export var scale_factor : float = 0.01
@export var use_point : bool = false
var index = Vector3i.ZERO
