extends Node

# Completed the basic device stuff
# happiness
# 17/07/2026

## Class that handles storing the pizzeria's data, rendering it as a 3D object and editing efficiently. 
class_name MasterPizzeria

## Array that holds each floor. Each floor holds three dictionaries: one for walls, and one for the ground tiles. Walls have Vector3i keys, where z represents whether the wall is vertical or horizontal, and ground tiles have Vector2i keys with simple cartesian coordinates.
var floors : Array[pizzeria_floor] = []
## Most likely deprecated, might use later on.
@export var SIZE : Vector2i = Vector2i(20, 20)
## The size of each tile in standard position units.
@export var TILE_SIZE : float = 4
## The global height all walls use in standard position units. 3.5 is the minimum for hallway devices (3 is possible but it makes the top be flush with the roof
@export var WALL_HEIGHT : float = 3.5
## The global width all walls use in standard position units. Low values recommended, but it can work with higher ones.
@export var WALL_THICK : float = 0.3

# Don't mess around with this value, it's just here for readability. Changing it isn't tested.
const FLOOR_THICK = 0.1
const CHUNK_SIZE = 5.0

var animatronics = []

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


# TODO: Make buttons be a thing with models, the full feature set such
# as being toggeable between proximity prompts and just basic clicking, as well as being able
# to be disabled for the editor view and having a "button" class
# ---
# NOTE: in order to do that you would need to figure out which side of the wall to
# put the button on, so I think it's better to leave it until we make the player-facing
# editor itself

# NOTE: an idea I had for the proximity prompt is that when you get close to it it's
# initially just covered in static but it quickly fades into the action itself with a
# small animation so it looks cooler, also with a small sfx
# imagine like opening the cams in fnac but just the prompts itself


# Blender export settings 4 devices:
# scale = 1.00
# apply scaling fbx units scale
# forward = -x forward
# up = y up
# apply unit, apply space transform and apply transform all off

func to_chunk(x):
	return floori(float(x) / CHUNK_SIZE)

func _ready():
	init_pizzeria()

## Initialize the pizzeria.
func init_pizzeria():
	if !self.has_node("devices"):
		var new = Node3D.new()
		new.name = "devices"
		add_child(new)
		
	if floors.size() == 0:
		floors.append(pizzeria_floor.new())
		render_base_fullfloor(floors[0], 0)
	else:
		# counter for the amount of floors present
		var j = -1
		for i in floors:
			j += 1
			render_base_fullfloor(i, j*WALL_HEIGHT)




# The way chunks work is that tile coordinates are made global and kept that way, 
# but for the rendering routine it's separated into 5x5 chunks.
#
# When rendering a full floor, it will loop through all entries and sort them into CSGCombiner3D nodes
# so they can be baked and rebuilt individually. This is a counter measure to the time it already takes
# to build the whole pizzeria
#
# It gets each chunk's index through floori(float(pos.x) / chunk_size), which is like integer
# division but it works with negatives. All tiles contained inside a chunk will mathematically
# coincide in index, so we don't need to save it anywhere and we can know what chunks to
# rebuild just from selecting multiple floors.
# 
# Then, to rebuild specific chunks, we just have to delete the csg combiner
# whose name is same as the desired chunk, and then in the routine only build specific indexes
# within the floor data.
# The logic for this is that all indexes MUST be equal or more than
# the chunk's index multiplied by the chunk size. At the same time, they must be less than
# minimum_index + chunk_size - 1 (which is how the maximum index can be defined)
#
# So we don't have to change the data structure at all and 
# we still get to keep all of the benefits of chunks!


## Instance CSG pizzeria fully + devices, then bake.
func render_base_fullfloor(floor : pizzeria_floor, floor_level):
	for i in self.get_children():
		i.queue_free()
	await get_tree().process_frame
	
	#TODO change the class naming so that each floor (as in building floors) is called a story
	# and each floor tile (as in the floor you stand on) is called a floor
	
	#region 1: handling the floor tiles
	for i in floor.rooms:
		var room = CSGBox3D.new()
		room.size = Vector3(TILE_SIZE, FLOOR_THICK, TILE_SIZE)
		
		# Added + TILE_SIZE/2 offset to fix visual bug
		# Whenever this shows up there's a 9/10 chance it's because of that
		room.global_position = Vector3(i.x * TILE_SIZE + TILE_SIZE/2, floor_level-FLOOR_THICK/2, i.y * TILE_SIZE + TILE_SIZE/2)
		
		# chunk logic
		var csg : CSGCombiner3D
		var cur_chunk = Vector2i(to_chunk(i.x), to_chunk(i.y))
		
		# If the current chunk has already been created
		if self.get_node_or_null(str(cur_chunk)) != null:
			csg = self.get_node(str(cur_chunk))
		else:
			# If not, it will create it 
			csg = CSGCombiner3D.new()
			csg.name = str(cur_chunk)
			csg.use_collision = true
			self.add_child(csg)
		
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(randf_range(0, 1),randf_range(0, 1),randf_range(0, 1))
		room.material = mat
		csg.add_child(room)
	#endregion
	
	#region 2: walls
	for i in floor.walls:
		var wall = CSGBox3D.new()
		
		# chunk logic
		var csg = CSGCombiner3D.new()
		var cur_chunk = Vector2i(to_chunk(i.x), to_chunk(i.y))
		
		# If the current chunk has already been created
		if self.get_node_or_null(str(cur_chunk)) != null:
			csg = self.get_node(str(cur_chunk))
		else:
			# If not, it will create it 
			csg.name = str(cur_chunk)
			csg.use_collision = true
			self.add_child(csg)
			
		if floor.walls[i].base_get_type() == pizzeria_wall.WALL_TYPES.NONE:
			continue
		
		if i.z == 0: # 0 if the wall is horizontal like ---, and 1 if it's vertical like |
			
			# Adjust size according to orientation
			wall.size = Vector3(TILE_SIZE, WALL_HEIGHT, WALL_THICK)
			# Position math for converting from tile space to world space w/ tile size
			wall.position = Vector3(i.x * TILE_SIZE + TILE_SIZE/2, floor_level+WALL_HEIGHT/2, TILE_SIZE * (i.y - 0.5) + TILE_SIZE/2)
		else:
			# Adjust size according to orientation
			wall.size = Vector3(WALL_THICK, WALL_HEIGHT, TILE_SIZE)
			22 # singlehandedly carrying the entire script yo
			# Position math for converting from tile space to world space w/ tile size
			
			# CRITICAL I've added an offset on the y axisto get rid of Z-fighting, 
			# but you need to keep it in mind in case it ever becomes important 
			wall.global_position = Vector3(TILE_SIZE * (i.x - 0.5) + TILE_SIZE/2, floor_level+WALL_HEIGHT/2 + 0.001, i.y * TILE_SIZE + TILE_SIZE/2)
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
				
			var device_scene = load(device_data.scene)
			
			var new_device = device_scene.instantiate()
			var aabb = new_device.borders.get_aabb()
			
			if alignment == wall_alignments.BOTTOM:
				cutout.position = wall.position - Vector3(0, (WALL_HEIGHT - aabb.size.z)/2, 0)
				new_device.position = wall.position - Vector3(0, WALL_HEIGHT/2, 0)
			elif alignment == wall_alignments.CENTER:
				cutout.position = wall.position
				new_device.position = wall.position
			elif alignment == wall_alignments.TOP:
				cutout.position = wall.position + Vector3(0, (WALL_HEIGHT - aabb.size.z)/2, 0)
				new_device.position = wall.position + Vector3(0, WALL_HEIGHT/2, 0)
			
			cutout.size = Vector3(aabb.size.y, aabb.size.z, 2)
			# if it's vertical
			if i.z == 1:
				new_device.rotate_y(deg_to_rad(90))
				cutout.rotate_y(deg_to_rad(90))
			
			if new_device is security_doorwindow:
				var second_cutout = CSGBox3D.new()
				second_cutout.size = new_device.window_cutout.size
				second_cutout.position = new_device.position + new_device.window_offset
				second_cutout.operation = CSGShape3D.OPERATION_SUBTRACTION
				csg.add_child(second_cutout)
			
			csg.add_child(new_device)
			
			
			# instance the final cutout, end wall loop
			csg.add_child(cutout)
	
	
	for i in self.get_children():
		# In case the player spams the build function and it gets freed in the same frame
		if !i:
			continue
		if i is CSGCombiner3D:
			var new_mesh = MeshInstance3D.new()
			var collide = CollisionShape3D.new()
			var body = StaticBody3D.new()
			
			var chunk_name = " "
			
			await get_tree().process_frame
			if !i:
				continue
			new_mesh.mesh = await i.bake_static_mesh()
			collide.shape = await i.bake_collision_shape()
			
			chunk_name = i.name
			i.name = "delete"

			self.add_child(new_mesh)
			new_mesh.name = chunk_name
			
			new_mesh.add_child(body)
			body.add_child(collide)
			
			for j in i.get_children():
				if j.is_in_group("office_devices"):
					var copy = j.duplicate()
					new_mesh.add_child(copy)
			i.queue_free()
	await get_tree().create_timer(1).timeout
	#endregion

# will need to be redone when multi floors are implemented in the fnaf 3 update
func render_singlechunk(idx : Vector2i , floor_level):
	var chunk = self.get_node(str(idx))
	print(chunk)
	#TODO finish


func _process(delta: float) -> void:
	pass
