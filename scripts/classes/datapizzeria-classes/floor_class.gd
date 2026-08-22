extends Resource
class_name pizzeria_floor

var walls : Dictionary[Vector3i, pizzeria_wall]
var groundtiles : Dictionary[Vector2i, pizzeria_groundtile]

# the z axis stores the point they're in within the tile
# the order is like this
#
#  .----------------.
#  |  0    1    2   |
#  |                |
#  |  3    4    5   |
#  |                |
#  |  6    7    8   |
#  .----------------.
# so 0 is topleft, and 8 is bottomright
#

var objects_ground : Dictionary[Vector3i, pizzeria_item]
var objects_wall : Dictionary[Vector3i, pizzeria_item]
var objects_roof : Dictionary[Vector3i, pizzeria_item]
