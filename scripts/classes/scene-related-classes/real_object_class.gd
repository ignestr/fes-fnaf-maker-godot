extends Node3D
class_name ObjectScene

# TODO: Properties

var use_power := false
@export var gizmo_mesh : Mesh
# collision_shape to be used. ITS ORIGIN MUST BE THE SAME AS THE MESH'S.
@export var collision_shape : CollisionShape3D
# by how much the mesh had to be scaled
@export var scale_factor : float = 0.01
# what rotation value does it need to be straight
@export var custom_rotation_degrees : Vector3
# number from 0 to 1 that scales the collision box for the object.
# In case you don't want to be too strict but also don't want a table on a table
@export var overlap_leniency = 1.0
@export var use_point : bool = false
@export var anchors : Dictionary[int, Node3D] = {}
var index = Vector3i.ONE


func index_anchors():
	for i in anchors:
		anchors[i].index = i
