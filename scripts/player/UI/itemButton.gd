extends Button
@onready var buildSys: DayshiftBuildSystem = $"../../../../../../../dayshiftBuildSystem"

var itemID = ""
var meshIndex = 0
enum TYPES {BASIC, ESTABLISHMENT, OBJECT, DECOR, ANIMATRONIC}
@export var type : TYPES

#TODO: adapt to new structure
func _on_button_up() -> void:
	match type:
		TYPES.ESTABLISHMENT:
			buildSys.selectedEstablishment = itemID
		TYPES.OBJECT:
			buildSys.selectedObject = meshIndex
		TYPES.DECOR:
			buildSys.selectedDecor = meshIndex
		TYPES.ANIMATRONIC:
			print("Animatronics not implemented")
