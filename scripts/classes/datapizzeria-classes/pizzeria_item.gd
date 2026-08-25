extends Resource
class_name pizzeria_item

var offset : Vector2i = Vector2i.ZERO
var id : StringName
## In degrees
var rotate_y : int = 0
var anchors : Dictionary[int, pizzeria_item]

func clone():
	var clone = pizzeria_item.new()
	clone.offset = offset
	clone.id = id
	clone.rotate_y = rotate_y
	clone.anchors = anchors
	return clone
