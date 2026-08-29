extends Node3D
class_name AnimatronicScene

# TODO: Properties

var use_power := false
@export var gizmo_mesh : Mesh
# collision_shape to be used. ITS ORIGIN MUST BE THE SAME AS THE MESH'S.
@export var collision_shape : CollisionShape3D
# by how much the mesh had to be scaled
@export var scale_factor : float = 1
# what rotation value does it need to be straight
@export var custom_rotation_degrees : Vector3
@export var collision_displacement : Vector3
# number from 0 to 1 that scales the collision box for the object.
# In case you don't want to be too strict but also don't want a table on a table
@export var use_point : bool = false
@export var anchors : Dictionary[int, Node3D] = {}


@export var property_offset : Vector2 = Vector2.ZERO: 
	set(val):
		property_offset = val
		if original_position:
			global_position = original_position + Vector3(val.x, 0, val.y)

@export var property_rotation_offset : float = 0:
	set(val):
		var final_val = deg_to_rad(val)
		property_rotation_offset = final_val
		self.rotation.y = final_val

@export var show_transform_properties : bool = true

var original_position

var index
var is_on_anchor
var anchor_number
var field

var properties = {}


func index_anchors():
	for i in anchors:
		anchors[i].index = i
