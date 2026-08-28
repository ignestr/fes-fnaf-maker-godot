extends Resource
class_name ObjectIndexDataEntry

enum allowed_positions {GROUND, WALL, ROOF} # BOTTOM, CENTER, TOP...

@export_file var scene : String
@export var icon : Texture2D
@export var natural_name : String
@export var allowed_position : allowed_positions
@export var can_be_in_anchor : bool
