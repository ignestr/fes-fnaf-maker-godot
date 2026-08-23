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
## The global height all walls use in standard position units. 3.5 is the minimum for hallway devices (3 is possible but it makes the top be flush with the roof. CANNOT BE HIGHER THAN TILE_SIZE.
@export var WALL_HEIGHT : float = 3.5
## The global width all walls use in standard position units. Low values recommended, but it can work with higher ones.
@export var WALL_THICK : float = 0.3

# Don't mess around with this value, it's just here for readability. Changing it isn't tested.
const FLOOR_THICK = 0.1
const CHUNK_SIZE = 7.0

@export var default_ground_material := &"fnaf1_ground_1"
@export var default_wall_material := &"fnaf1_wall_1"
@export var wall_cap_material : Material = load("res://resources/materials/basic/misc/concrete.tres")

var objman : ObjectManager

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

const tile_quadrant_lut = {
	0:Vector2i(-1, 1),
	1:Vector2i(0 , 1),
	2:Vector2i(1, 1),
	3:Vector2i(-1, 0),
	4:Vector2i(0, 0),
	5:Vector2i(1, 0),
	6:Vector2i(-1, -1),
	7:Vector2i(0, -1),
	8:Vector2i(1, -1)
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

var use_random_colors = false

func to_chunk(n : Vector2i):
	return Vector2i(floori(float(n.x) / CHUNK_SIZE), floori(float(n.y) / CHUNK_SIZE))

func _ready():
	init_pizzeria()

func decode_wall_coord(vector : Vector4i):
	return [Vector2i(vector.x, vector.y), vector.z, vector.w & 1, vector.w & 2]

## Initialize the pizzeria.
func init_pizzeria():
	if !self.has_node("MaterialManager"):
		var new = MaterialManager.new()
		new.name = "MaterialManager"
		self.add_child(new)
	
	if !self.has_node("ObjectManager"):
		var new = ObjectManager.new()
		new.name = "ObjectManager"
		self.add_child(new)
		objman = self.get_node("ObjectManager")
		
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
		if i is MeshInstance3D:
			i.free()
	await get_tree().process_frame
	
	
	var chunks = []
	
	# this will tally up all chunks that should be rendered
	for i in floor.groundtiles:
		if not chunks.has(to_chunk(i)):
			chunks.append(to_chunk(i))
	
	for i in floor.walls:
		if not chunks.has(to_chunk(Vector2i(i.x, i.y))):
			chunks.append(to_chunk(Vector2i(i.x, i.y)))
	
	for chunk in chunks:
		render_chunk(chunk, floor, floor_level)



# will need to be redone when multi floors are implemented in the fnaf 3 update
func render_chunk(idx : Vector2i , floor : pizzeria_floor, floor_level : float):
	var csg : CSGCombiner3D
	# If the current chunk has already been created
	# If it has, it must override it
	
	csg = CSGCombiner3D.new()
	var leftover = self.get_node_or_null(str(idx))
	if leftover:
		leftover.name = "trash"
		for child in self.get_children():
			if child.name.contains("trash"):
				child.queue_free()
	csg.name = str(idx)
	csg.use_collision = true
	self.add_child(csg)
	
	#region 0: splitting the floor into the chunk we want
	var chunk_data = pizzeria_floor.new()
	
	# the range of allowed coordinates is from min x to max x, min y to max y
	# the minimum tile in a chunk is C.idx * C.size (where C.idx is the chunk vector and its size is CHUNK_SIZE)
	# the maximum tile is min + Vec2(C.size, C.size) - Vec2.one (where min is the minimum from before,
	# and Vec2.one is just Vec2(1, 1) )
	#
	# using this, we can then:
	
	var min_tile = idx * CHUNK_SIZE
	var max_tile = min_tile + Vector2(CHUNK_SIZE, CHUNK_SIZE) - Vector2.ONE
	for x in range(min_tile.x, max_tile.x + 1):
		for y in range(min_tile.y, max_tile.y + 1):
			# copying the ground tiles
			if floor.groundtiles.has(Vector2i(x,y)):
				chunk_data.groundtiles[Vector2i(x,y)] = floor.groundtiles[Vector2i(x,y)]
			
			#copying the horizontal walls
			if floor.walls.has(Vector3i(x,y,0)):
				chunk_data.walls[Vector3i(x,y,0)] = floor.walls[Vector3i(x,y,0)]
				
			#copying the horizontal walls
			if floor.walls.has(Vector3i(x,y,1)):
				chunk_data.walls[Vector3i(x,y,1)] = floor.walls[Vector3i(x,y,1)]
			
			#copying the ground objects walls
			for anchor in range(9):
				if floor.objects_ground.has(Vector3i(x,y,anchor)):
					chunk_data.objects_ground[Vector3i(x,y,anchor)] = floor.objects_ground[Vector3i(x,y,anchor)]
				for byte in range(4):
					if floor.objects_wall.has(Vector4i(x,y,anchor,byte)):
						chunk_data.objects_wall[Vector4i(x,y,anchor,byte)] = floor.objects_wall[Vector4i(x,y,anchor,byte)]
	# If it's empty
	if chunk_data.groundtiles.is_empty() and chunk_data.walls.is_empty():
		csg.queue_free()
		return
	#endregion
	#region 1: handling the floor tiles
	for tile in chunk_data.groundtiles:
		var ground = CSGBox3D.new()
		csg.add_child(ground)
		ground.size = Vector3(TILE_SIZE, FLOOR_THICK, TILE_SIZE)
		
		# Added + TILE_SIZE/2 offset to fix visual bug
		# Whenever this shows up there's a 9/10 chance it's because of that
		ground.global_position = Vector3(tile.x * TILE_SIZE + TILE_SIZE/2, floor_level-FLOOR_THICK/2, tile.y * TILE_SIZE + TILE_SIZE/2)
		
		if use_random_colors == true:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = Color(randf_range(0, 1),randf_range(0, 1),randf_range(0, 1))
			ground.material = mat
		else:
			if chunk_data.groundtiles[tile].material_id == &"":
				chunk_data.groundtiles[tile].material_id = default_ground_material
				
			var matman : MaterialManager = self.get_node("MaterialManager")
			if matman.materials.has(chunk_data.groundtiles[tile].material_id):
				ground.material = matman.materials[chunk_data.groundtiles[tile].material_id]
			else:
				await matman.load_new_mat(chunk_data.groundtiles[tile].material_id)
				ground.material = matman.materials[chunk_data.groundtiles[tile].material_id]

		
	#endregion
	#region 2: walls
	for wall_tile in chunk_data.walls:
		var wall = CSGBox3D.new()
		var wall_cap = CSGBox3D.new()
		
		# chunk logic
		var vec2_i = Vector2i(wall_tile.x, wall_tile.y)
		var cur_chunk = Vector2i(to_chunk(vec2_i).x, to_chunk(vec2_i).y)
			
		if floor.walls[wall_tile].base_get_type() == pizzeria_wall.WALL_TYPES.NONE:
			continue
		
		if wall_tile.z == 0: # 0 if the wall is horizontal like ---, and 1 if it's vertical like |
			# Adjust size according to orientation
			wall.size = Vector3(TILE_SIZE, WALL_HEIGHT, WALL_THICK)
			# Position math for converting from tile space to world space w/ tile size
			wall.position = Vector3(
				wall_tile.x * TILE_SIZE + TILE_SIZE/2, 
				floor_level+WALL_HEIGHT/2, 
				TILE_SIZE * wall_tile.y
				)
			
			wall_cap.size = Vector3(TILE_SIZE, 0.1, WALL_THICK)
			wall_cap.position = wall.position
			wall_cap.position.y += WALL_HEIGHT/2 + 0.05
		else:
			# Adjust size according to orientation
			wall.size = Vector3(WALL_THICK, WALL_HEIGHT, TILE_SIZE)
			# 22
			# Position math for converting from tile space to world space w/ tile size
			
			# CRITICAL I've added an offset on the y axis to get rid of Z-fighting, 
			# but you need to keep it in mind in case it ever becomes important 
			wall.global_position = Vector3(
				TILE_SIZE * wall_tile.x,
				floor_level+WALL_HEIGHT/2 + 0.001,
				wall_tile.y * TILE_SIZE + TILE_SIZE/2
				)
			wall_cap.size = Vector3(WALL_THICK, 0.1, TILE_SIZE)
			wall_cap.position = wall.position
			wall_cap.position.y += WALL_HEIGHT/2 + 0.05
		
		wall_cap.material = wall_cap_material
		
		if use_random_colors == true:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = Color(randf_range(0, 1),randf_range(0, 1),randf_range(0, 1))
			wall.material = mat
		else:
			if chunk_data.walls[wall_tile].material_id == &"":
				chunk_data.walls[wall_tile].material_id = default_wall_material
				
			var matman : MaterialManager = self.get_node("MaterialManager")
	
			if matman.materials.has(chunk_data.walls[wall_tile].material_id):
				wall.material = matman.materials[chunk_data.walls[wall_tile].material_id]
			else:
				await matman.load_new_mat(chunk_data.walls[wall_tile].material_id)
				if matman.materials.has(chunk_data.walls[wall_tile].material_id):
					wall.material = matman.materials[chunk_data.walls[wall_tile].material_id]
				else:
					push_warning("Failed to get material ", chunk_data.walls[wall_tile].material_id, "!")
					print("Failed to get material ", chunk_data.walls[wall_tile].material_id, "!")
		
		# after the wall is set up, instance the basic wall
		csg.add_child(wall_cap)
		csg.add_child(wall)
		
		# if the wall doesn't need a cutout for windows, doors etc, the loop ends here
			
		# if not, it uses csg to make one
	#endregion
	#region 3: devices
		if chunk_data.walls[wall_tile].base_get_type() != pizzeria_wall.WALL_TYPES.FLAT:
			var cutout := CSGBox3D.new()
			var current_wall = chunk_data.walls[wall_tile]
			cutout.operation = CSGShape3D.OPERATION_SUBTRACTION
			# different cutout positions and dimensions for each type, using a look up table
			var alignment = null
			
			
			# the case where it has both the door and glass flags is being intentionally overshadowed here
			# I only implmented the door flag + glass cutout
			# The door flag + glass flag would functionally do the same anyway
			# at least for now
			
			# -1 (for the LUT key) means that neither flag is true, hence why
			# it is set as default
			
			# Choosing the alignment (for the positioning routine)
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
				if requested_device.alignment == alignment:
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
			if wall_tile.z == 1:
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
	#endregion
	#region 4: objects ☆
	for index in chunk_data.objects_ground:
		var item_data : pizzeria_item = chunk_data.objects_ground[index]
		if Objex.list_all.objects[item_data.id].scene:
			var object : Node3D
			if objman.objects.has(item_data.id):
				object = objman.objects[item_data.id].instantiate()
			else:
				await objman.load_new(item_data.id)
				object = objman.objects[item_data.id].instantiate()
			
			# Start at the middle of the correct place in the cell
			var quadrant = tile_quadrant_lut[index.z]
			object.global_position = Vector3(index.x * TILE_SIZE + TILE_SIZE/2, floor_level, index.y * TILE_SIZE + TILE_SIZE/2) + Vector3(quadrant.x * TILE_SIZE/2, 0, quadrant.y * TILE_SIZE/2)
			+ Vector3(item_data.offset.x, 0, item_data.offset.y)
			object.add_to_group(&"objects")
			object.rotate_y(deg_to_rad(item_data.rotate_y))
			csg.add_child(object)
			object.index = index
	
	for index in chunk_data.objects_wall:
		var item_data : pizzeria_item = chunk_data.objects_wall[index]
		if Objex.list_all.objects[item_data.id].scene:
			var object : Node3D
			if objman.objects.has(item_data.id):
				object = objman.objects[item_data.id].instantiate()
			else:
				await objman.load_new(item_data.id)
				object = objman.objects[item_data.id].instantiate()
			
			# Start at the middle of the correct place in the cell
			var direction = decode_wall_coord(index)[2]
			var side = decode_wall_coord(index)[3]
			var quadrant = tile_quadrant_lut[index.z]
			csg.add_child(object)
			object.scale = Vector3(object.scale_factor, object.scale_factor, object.scale_factor)
			
			if direction:
				object.rotate_y(deg_to_rad(90))
				object.global_position = Vector3(
					index.x * TILE_SIZE, 
					floor_level+WALL_HEIGHT/2, 
					TILE_SIZE * index.y + TILE_SIZE/2
					)
					
				object.global_position += Vector3(0, quadrant.y, quadrant.x)
				if side:
					object.global_position.x += WALL_THICK
				else:
					object.rotate_y(deg_to_rad(180))
					object.global_position.x -= WALL_THICK
				object.rotate_z(deg_to_rad(item_data.rotate_y))
			
			else:
				object.global_position = Vector3(
				TILE_SIZE * index.x + TILE_SIZE/2,
				floor_level+WALL_HEIGHT/2,
				index.y * TILE_SIZE
				)
				
				if side:
					object.global_position.z -= WALL_THICK
					object.rotate_y(deg_to_rad(180))
				else:
					object.global_position.z += WALL_THICK
				object.rotate_x(deg_to_rad(item_data.rotate_y))
				
				print(quadrant)
				object.global_position += Vector3(quadrant.x, quadrant.y, 0)
				
			object.add_to_group(&"objects")
			
			object.index = index
		
		pass
	for obj in chunk_data.objects_roof:
		pass
	
	
	#endregion
	#region Closing off - baking and adding collisions
	# In case the player spams the build function and it gets freed in the same frame
	if self.get_node_or_null(str(idx)) == null:
		push_warning("Chunk", str(idx), "failed to bake because it was freed before it could do it. Try building less often!")
		return

		
	var new_mesh = MeshInstance3D.new()
	var collide = CollisionShape3D.new()
	var body = StaticBody3D.new()
	
	var chunk_name = " "
	
	await get_tree().process_frame
	if self.get_node_or_null(str(idx)) == null or csg == null:
		push_warning("Chunk", str(idx), "failed to bake because it was freed before it could do it. Try building less often!")
		return
	new_mesh.mesh = await csg.bake_static_mesh()
	collide.shape = await csg.bake_collision_shape()
	
	chunk_name = csg.name
	csg.name = "delete"
	self.add_child(new_mesh)
	new_mesh.name = chunk_name
	
	new_mesh.add_child(body)
	body.add_child(collide)
	
	for child in csg.get_children():
		if child.is_in_group(&"objects"):
			var copy = child.duplicate()
			#TODO CRITICAL: If objects have properties that aren't being copied
			# it might be this
			copy.index = child.index
			new_mesh.add_child(copy)
	csg.queue_free()
	await get_tree().process_frame
	#endregion


func _process(delta: float) -> void:
	pass
