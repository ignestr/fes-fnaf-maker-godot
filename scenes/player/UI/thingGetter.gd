extends GridContainer


enum TYPES {BASIC, DECOR, ANIMATRONIC}
@export var itemType : TYPES
const ITEM = preload("res://scenes/player/UI/basicItem.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mesh_lib
	#var intList = {}
	#var meshLibBased = true
	#match itemType:
	#	TYPES.BASIC:
	#		mesh_lib = items.worldMeshLib
	#	TYPES.OBJECT:
	#		mesh_lib = items.objMeshLib
	#	TYPES.DECOR:
	#		mesh_lib = items.decorMeshLib
	#	TYPES.ESTABLISHMENT:
	#		meshLibBased = false
	#		intList = Establindex.listAll
	#	TYPES.ANIMATRONIC:
	#		meshLibBased = false
	#if mesh_lib and meshLibBased:
	#	for i in mesh_lib.get_item_list():
	#		var curButton = ITEM.instantiate()
	#		curButton.meshIndex = i
	#		curButton.text = mesh_lib.get_item_name(i)
	#		add_child(curButton)
	#if not meshLibBased:
	#	for i in intList:
	#		var curButton = ITEM.instantiate()
	#		curButton.itemID = i
	#		curButton.text = intList[i]["textName"]
	#		add_child(curButton)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
