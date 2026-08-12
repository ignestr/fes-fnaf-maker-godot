extends Resource
class_name pizzeria_floor

var walls : Dictionary[Vector3i, pizzeria_wall]
# TODO: implement
var floodfill_separators : Dictionary[Vector3i, pizzeria_wall]
var groundtiles : Dictionary[Vector2i, pizzeria_room]
var objects : Dictionary[Vector2i, pizzeria_item]
