extends ObjectScene
class_name WallDevice

# Might be deprecated in the future
enum TYPES {CLEAR, WINDOW, DOOR, WINDOOR}

func _ready() -> void:
	show_transform_properties = false
