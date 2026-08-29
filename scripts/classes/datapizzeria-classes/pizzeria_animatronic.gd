extends Resource
class_name pizzeria_animatronic

var offset : Vector2i = Vector2i.ZERO
var id : StringName
var ai_resource #TBD. Animatronic AI system will use behaviors defined by 
## In degrees

var properties = {}


func clone():
	var clone = pizzeria_animatronic.new()
	clone.offset = offset
	clone.id = id
	clone.properties
	clone.ai_resource = ai_resource
	return clone
