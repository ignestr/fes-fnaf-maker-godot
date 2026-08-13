extends Node
class_name MaterialManager

var materials : Dictionary[StringName, Material] = {}

func load_new_mat(mat : StringName):
	if Materindex.list_all.materials.has(mat):
		materials[mat] = load(Materindex.list_all.materials[mat].material)
		print(Materindex.list_all.materials[mat].material)
		print(load("uid://ddic8fwek48rw"))
		print(materials[mat])
	else:
		push_warning("Attempted to load material ", mat, "!")
		print("Attempted to load material ", mat, "!")
