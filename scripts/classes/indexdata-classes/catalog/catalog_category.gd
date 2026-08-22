extends Resource
class_name DayshiftCatalogCategory

enum FIELDS {GROUND, WALL, ROOF}

@export var icon : Texture2D
@export var field : FIELDS
@export var members : Array[StringName]
