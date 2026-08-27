extends Resource
class_name pizzeria_item

var offset : Vector2i = Vector2i.ZERO
var id : StringName
## In degrees
var anchors : Dictionary[int, pizzeria_item]
var properties = {}


func clone():
	var clone = pizzeria_item.new()
	clone.offset = offset
	clone.id = id
	clone.properties
	clone.anchors = anchors
	return clone
