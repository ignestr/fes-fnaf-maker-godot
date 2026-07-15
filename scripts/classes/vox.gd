extends Node
## Class that handles storing the pizzeria's data, rendering it as a 3D object and editing efficiently. 
class_name master_pizzeria

## Array that holds each floor. Each floor
var floors = []
## Most likely deprecated, might use later on.
@export var SIZE : Vector2i = Vector2i(20, 20)
## The size of each tile in standard position units. Uses an int for simplicity.
@export var TILE_SIZE : int = 4
## The global height all walls use in standard position units.
@export var WALL_HEIGHT : float = 3
## The global width all walls use in standard position units. make it AS HIGH AS YOU WANT BABYYYY
@export var WALL_THICK : float = 0.3

# Don't mess around with this value, it's just here for readability. Changing it isn't tested.
const FLOOR_THICK = 0.1

var animatronics = []

# holy grail that took me 1 day to come up with
# -1 is for when both are off

enum wall_alignments {BOTTOM, CENTER, TOP}

const wall_lut = {
	pizzeria_wall.WALL_FLAGS.HAS_DOOR : {
		pizzeria_wall.WALL_TYPES.DOOR: wall_alignments.BOTTOM,
		pizzeria_wall.WALL_TYPES.FLOORVENT: wall_alignments.BOTTOM,
		pizzeria_wall.WALL_TYPES.HALL: wall_alignments.BOTTOM,
		pizzeria_wall.WALL_TYPES.ROOFVENT: wall_alignments.TOP,
		pizzeria_wall.WALL_TYPES.WALLVENT: wall_alignments.CENTER
		}, 
	pizzeria_wall.WALL_FLAGS.HAS_GLASS: {
		pizzeria_wall.WALL_TYPES.DOOR: wall_alignments.BOTTOM,
		pizzeria_wall.WALL_TYPES.HALL: wall_alignments.CENTER, 
		pizzeria_wall.WALL_TYPES.WALLVENT: wall_alignments.CENTER 
		}, 
	-1: {
		pizzeria_wall.WALL_TYPES.DOOR: wall_alignments.BOTTOM,
		pizzeria_wall.WALL_TYPES.FLOORVENT: wall_alignments.BOTTOM, 
		pizzeria_wall.WALL_TYPES.HALL: wall_alignments.BOTTOM, 
		pizzeria_wall.WALL_TYPES.ROOFVENT: wall_alignments.TOP,
		pizzeria_wall.WALL_TYPES.WALLVENT: wall_alignments.CENTER 
		}
	}


# TODO: Change to use different door types per wall (once you have one more type for everything)

# TODO: Make buttons be a thing with models, the full feature set such
# as being toggeable between proximity prompts and just basic clicking, as well as being able
# to be disabled for the editor view and having a "button" class

# no

# ok fine

# NOTE: an idea I had for the proximity prompt is that when you get close to it it's
# initially just covered in static but it quickly fades into the action itself with a
# small animation so it looks cooler, also with a small sfx
# imagine like opening the cams in fnac but just the prompts itself

# also search 128 on jukebox and click on serani poji's it's peak working music

const DEFAULT_SECURITY_DOOR := preload("uid://cf20nw056d12u") 


# Blender export settings 4 devices:
# scale = 1.00
# apply scaling fbx units scale
# forward = -x forward
# up = y up
# apply unit, apply space transform and apply transform all off

func _ready():
	pass

## Initialize the pizzeria.
func init_pizzeria():
	
	if !self.has_node("devices"):
		var new = Node3D.new()
		new.name = "devices"
		add_child(new)
		
	if floors.size() == 0:
		floors.append(pizzeria_floor.new())
		render(floors[0], 0) #consider deprecating floor_level?
	else:
		# counter for the amount of floors present
		for i in floors:
			render(i, 0)

## Instance CSG pizzeria fully, then bake.
# Needs work with the chunking system that I'll implement soon
func render(floor : pizzeria_floor, floor_level, idx=0):
	
	# If there is no CSGCombiner3D present,
	if !self.has_node("pizzeria_csg"):
		var newcsg = CSGCombiner3D.new()
		newcsg.name = "pizzeria_csg"
		newcsg.use_collision = true
		add_child(newcsg)
	
	var csg = self.get_node("pizzeria_csg")
	print(csg)
	
	#region 1: handling floors
	for i in floor.rooms:
		var room = CSGBox3D.new()
		room.size = Vector3(TILE_SIZE, FLOOR_THICK, TILE_SIZE)
		room.global_position = Vector3(i.x * TILE_SIZE, floor_level-FLOOR_THICK/2, i.y * TILE_SIZE)
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(randf_range(0, 1),randf_range(0, 1),randf_range(0, 1))
		room.material = mat
		#INFO x is temporarily the opposite of what it's supposed to be because the debug editor is flipped for whatever reason
		csg.add_child(room)
	#endregion
	
	#region 2: walls
	for i in floor.walls:
		var wall = CSGBox3D.new()
		if floor.walls[i].base_get_type() != pizzeria_wall.WALL_TYPES.NONE:
			continue
		
		if i.z == 0: # 0 if the wall is horizontal like ---, and 1 if it's vertical like |
			
			# Adjust size according to orientation
			wall.size = Vector3(TILE_SIZE, WALL_HEIGHT, WALL_THICK)
			# Position math for converting from tile space to world space w/ tile size
			print("one")
			wall.position = Vector3(i.x * TILE_SIZE, floor_level+WALL_HEIGHT/2, TILE_SIZE * (i.y - 0.5))
		else:
			# Adjust size according to orientation
			wall.size = Vector3(WALL_THICK, WALL_HEIGHT, TILE_SIZE)
			# Position math for converting from tile space to world space w/ tile size
			22 # singlehandedly carrying the entire script yo
			wall.global_position = Vector3(TILE_SIZE * (i.x - 0.5), floor_level+WALL_HEIGHT/2, i.y * TILE_SIZE)
		# after the wall is set up, instance the basic wall
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(randf_range(0, 1),randf_range(0, 1),randf_range(0, 1))
		wall.material = mat
		csg.add_child(wall)
		# if the wall doesn't need a cutout for windows, doors etc, the loop ends here
#endregion
		
		# if not, it uses csg to make one
		
#region 3: devices
		if floor.walls[i].base_get_type() != pizzeria_wall.WALL_TYPES.FLAT:
			
			# wow we have so many colors ALERT BUG NOTE INFO
			# you should use them here is the link:
			# https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#comments
			
			var cutout := CSGBox3D.new()
			var current_wall = floor.walls[i]
			cutout.operation = CSGShape3D.OPERATION_SUBTRACTION
			
			# different cutout positions and dimensions for each type, using a look up table
			var alignment = -1
			
			
			# Choosing the alignment (for the positioning routine)
			
			# the case where it has both the door and glass flags is being intentionally overshadowed here
			# I only implmented the door flag + glass cutout
			# The door flag + glass flag would functionally do the same anyway
			# at least for now
			
			# -1 (for the LUT key) means that neither flag is true, hence why
			# it is set as default
			
			var key = -1
			
			if current_wall.base_get_flag(pizzeria_wall.WALL_FLAGS.HAS_DOOR):
				key = pizzeria_wall.WALL_FLAGS.HAS_DOOR
			elif current_wall.base_get_flag(pizzeria_wall.WALL_FLAGS.HAS_GLASS):
				key = pizzeria_wall.WALL_FLAGS.HAS_GLASS
			
			alignment = wall_lut[key][current_wall.base_get_type()]
			
			
			# Choosing the device
			var device_data : DeviceIndexDataEntry
			
			# If it has to fallback to defaults
			if current_wall.device_model_name == &"":
				# Set to the default for the flag type combo
				device_data = Devicedex.list_all.devices[Devicedex.defaults[key][current_wall.base_get_type()]]
			
			# if it's a valid entry
			elif Devicedex.list_all.devices.has(current_wall.device_model_name):
				var requested_device = Devicedex.list_all.devices[current_wall.device_model_name]
				# if it has the same alignment
				if requested_device.aligment == alignment:
					# if they match the allowed flag and allowed type
					if requested_device.allowed_flag == key && requested_device.allowed_type == current_wall.base_get_type():
						device_data = requested_device
						# if any of the checks fail, just fall back to the default
					else:
						device_data = Devicedex.list_all.devices[Devicedex.defaults[key][current_wall.base_get_type()]]
				else:
						device_data = Devicedex.list_all.devices[Devicedex.defaults[key][current_wall.base_get_type()]]
			else:
				# Fall back to the default
				device_data = Devicedex.list_all.devices[Devicedex.defaults[key][current_wall.base_get_type()]]
			
			
			if alignment == wall_alignments.BOTTOM:
				# about to implement the scene index thing
				# God give me strength...
				
				var device_scene := load(device_data.scene)
				
				var new_device = device_scene.instantiate()
				print(device_scene)
				var aabb = new_device.borders.get_aabb()
				print(aabb.size.x)
				print(WALL_HEIGHT)
				cutout.position = wall.position - Vector3(0, (WALL_HEIGHT - aabb.size.z)/2, 0)
				new_device.position = wall.position - Vector3(0, WALL_HEIGHT/2, 0)
				
				cutout.size = Vector3(aabb.size.y, aabb.size.z, 2)
				# if it's vertical
				if i.z == 1:
					new_device.rotate_y(deg_to_rad(90))
					cutout.rotate_y(deg_to_rad(90))
				csg.add_child(new_device)
				
				
			# instance the final cutout, end wall loop
			csg.add_child(cutout)
	#endregion
	
func _process(delta: float) -> void:
	pass
