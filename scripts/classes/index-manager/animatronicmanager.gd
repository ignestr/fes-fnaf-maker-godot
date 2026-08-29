extends Node
class_name AnimatronicManager

# Doing this so we will load each material only once if they are used

var tronics : Dictionary[StringName, PackedScene] = {}

func load_new(obj : StringName):
	if Animatrindex.list_all.animatronics.has(obj):
		tronics[obj] = load(Animatrindex.list_all.animatronics[obj].scene)
	else:
		push_warning("Attempted to load animatronic ", obj, "!")
		print("Attempted to load animatronic ", obj, "!")
