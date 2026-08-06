extends Resource
class_name pizzeria_room


enum WALL_TYPES {NONE, FLAT, DOOR, FLOORVENT, HALL, ROOFVENT, WALLVENT} # int 0 through 6
enum ROOM_FLAGS {HAS_DOOR = 1 << 0, HAS_LIGHT = 1 << 1, HAS_GLASS = 1 << 2, DO_INTERACT = 1 << 3} # 4 bits (bools)

var is_on : bool = false
