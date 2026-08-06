extends Resource
class_name DeviceIndexDataEntry

enum alignments {BOTTOM, CENTER, TOP}

# the NEITHER is here to handle the entries that don't have neither door nor glass enabled
enum WALL_FLAGS {HAS_DOOR = 1 << 0, HAS_LIGHT = 1 << 1, HAS_GLASS = 1 << 2, DO_INTERACT = 1 << 3, NEITHER = -1} # 


@export_file var scene : String
@export var alignment : alignments
@export var allowed_flag : WALL_FLAGS
@export var allowed_type : pizzeria_wall.WALL_TYPES
