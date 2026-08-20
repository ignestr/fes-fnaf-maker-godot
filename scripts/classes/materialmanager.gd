extends Node
class_name MaterialManager

# Doing this so we will load each material only once if they are used
var materials : Dictionary[StringName, Material] = {}

func load_new_mat(mat : StringName):
	if Materindex.list_all.materials.has(mat):
		materials[mat] = load(Materindex.list_all.materials[mat].material)
	else:
		push_warning("Attempted to load material ", mat, "!")
		print("Attempted to load material ", mat, "!")
