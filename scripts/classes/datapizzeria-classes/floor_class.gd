extends Resource
class_name pizzeria_floor

var walls : Dictionary[Vector3i, pizzeria_wall]
var groundtiles : Dictionary[Vector2i, pizzeria_groundtile]

# for objects, the z axis stores the point they're in within the tile
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


var objects_ground : Dictionary[Vector3i, pizzeria_item]
# The w coordinate is bitpacked
# bit 1 is whether the wall is u or v (like z in the wall dict), bit 2 is whether it's on the front or back of the wall
var objects_wall : Dictionary[Vector4i, pizzeria_item]
var objects_roof : Dictionary[Vector3i, pizzeria_item]

var animatronics : Dictionary[Vector3i, pizzeria_animatronic]
