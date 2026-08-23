extends Node
class_name ObjectManager

# Doing this so we will load each material only once if they are used
var objects : Dictionary[StringName, PackedScene] = {}

func load_new(obj : StringName):
	if Objex.list_all.objects.has(obj):
		objects[obj] = load(Objex.list_all.objects[obj].scene)
	else:
		push_warning("Attempted to load object ", obj, "!")
		print("Attempted to load object ", obj, "!")
