extends Node3D
class_name ObjectScene

# TODO: Properties

var use_power := false
@export var gizmo_mesh : Mesh
# collision_shape to be used. ITS ORIGIN MUST BE THE SAME AS THE MESH'S.
@export var collision_shape : CollisionShape3D
# by how much the mesh had to be scaled
@export var scale_factor : float = 1
# what rotation value does it need to be straight
@export var custom_rotation_degrees : Vector3
# number from 0 to 1 that scales the collision box for the object.
# In case you don't want to be too strict but also don't want a table on a table
@export var overlap_leniency = 1.0
@export var use_point : bool = false
@export var anchors : Dictionary[int, Node3D] = {}
@export var property_offset : Vector2:
	set(val):
		property_offset = val
		match field:
			DayshiftManager.fields.OBJECT_GROUND:
				global_position = original_position + Vector3(val.x, 0, val.y)
			DayshiftManager.fields.OBJECT_ROOF:
				global_position = original_position + Vector3(val.x, 0, val.y)
			DayshiftManager.fields.OBJECT_WALL:
				# it's a vector 4 right?
				var direction = MasterPizzeria.decode_wall_coord(index)[2]
				if !direction:
					global_position = original_position + Vector3(val.x, val.y, 0)
				else:
					global_position = original_position + Vector3(0, val.y, val.x)
@export var property_rotation_offset : float:
	set(val):
		var final_val = deg_to_rad(val)
		property_rotation_offset = final_val
		match field:
			DayshiftManager.fields.OBJECT_GROUND:
				self.rotation.y = final_val
			DayshiftManager.fields.OBJECT_ROOF:
				self.rotation.y = final_val
			DayshiftManager.fields.OBJECT_WALL:
				var direction = MasterPizzeria.decode_wall_coord(index)[2]
				if !direction:
					self.rotation.z = final_val
				else:
					self.rotation.x = final_val
@export var show_transform_properties : bool = true

var original_position

var field
var index
var is_on_anchor
var anchor_number

var properties = {}


func index_anchors():
	for i in anchors:
		anchors[i].index = i
