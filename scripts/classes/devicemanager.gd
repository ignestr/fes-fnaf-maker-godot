extends Node
class_name DeviceManager

# Doing this so we will load each material only once if they are used
var devices : Dictionary[StringName, PackedScene] = {}

func load_new(obj : StringName):
	if Devicedex.list_all.devices.has(obj):
		devices[obj] = load(Devicedex.list_all.devices[obj].scene)
	else:
		push_warning("Attempted to load device ", obj, "!")
		print("Attempted to load device ", obj, "!")
