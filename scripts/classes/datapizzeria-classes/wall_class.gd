extends Resource
## Class for storing walls as bytes for efficiency. The first byte (wall_byte) stores the core properties of the wall.
## Wall types are used to establish the basic shape of walls as well as the specific "cutout" used (eg. door frames, fnaf 2 hallway frames, vent frames, windows, etc).
## Wall flags are used to choose which type of device / gameplay element is actuall used. These require a cutout. Some combinations of flags and types may yield different cutouts and effects.
class_name pizzeria_wall
## enum for using wall type names directly
enum WALL_TYPES {NONE, FLAT, DOOR, FLOORVENT, HALL, ROOFVENT, WALLVENT} # int 0 through 6
## enum for using wall flag names directly.
enum WALL_FLAGS {HAS_DOOR = 1 << 0, HAS_LIGHT = 1 << 1, HAS_GLASS = 1 << 2, DO_INTERACT = 1 << 3} # 4 bits (bools)

## Wall byte for storing the main wall data:
## bits 0-3: Flags (WALL_FLAGS)
## bits 4-7: Type (WALL_TYPES)
var wall_byte : int = 0
## TBD, second byte that store any modifications it gets
var mod_byte : int = 0

var material_id = &""


#TODO: implement the mod byte


#region notes that you should read

# has_door : bool # fnaf 2 hallway type thing if false

# has_glass : bool # for windows and stuff
# mostly a modifier for the shape
# (if it's fnaf 2 hall shape then it becomes fnaf 3, if it has door shape it's a door-window thing
# and so on)

# has_light : bool # whether it has a light mechanic or not

	# do_interact : bool # whether clicking on the device performs an action (eg, running up to the door, walking through the door, custom actions, etc. it will use the default button behavior for devices if not)

# the wall byte is for basics, and the mod byte decides stuff like whether
# the door has to be held open, whether it has a button, whether it's not a barrier at all
# same with light, whether it has a button or not, and other properties
# also maybe some aesthetic things like the door style since maybe you want it to be a lever
# or something but that's it for now

# NOTE, in order to account for things like the fnaf 3 window, fnaf 1 doors and other
# exceptions or special cases, you can handle specific combinations in different ways
# for example door + glass = fnaf 1 door
# hallway + glass = fnaf 3 window
# wall vent + glass = window not connected to the vent systems
# the modifier decides whether doors are held or not, whether they can be passed through,
# and other variation specific stuff
# design it soon plss, also TODO set up the table and attach it here

#endregion

func base_get_flag(x : WALL_FLAGS):
	return bool(wall_byte & x)

func base_set_flag(x : WALL_FLAGS, val : bool):
	if val == true:
		wall_byte |= x
	else:
		wall_byte &= ~x 

func base_get_type(): # returns the type as an int
	return (wall_byte & 0b11110000) >> 4

func base_set_type(x : WALL_TYPES):
	wall_byte &= 0b00001111
	wall_byte |= (x << 4)
