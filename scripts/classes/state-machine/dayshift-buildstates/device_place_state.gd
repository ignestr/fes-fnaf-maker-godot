extends StateMachineState
class_name device_place_state



var projected_cell

var is_floor = true
# horizontal if false, vertical if true
var orientation = false

var gizmo_obj : MeshInstance3D

var is_invalid = false

var scene

#var debug_point : CSGSphere3D

# TODO: make this logic be skippable if hovering over an object (as we can
# just check for those. Wait until objects are implemented)

func encode_wall_coord(flat_idx : Vector2i, anchor : int, vertical : bool, front : bool):
	var w = int(vertical) | int(front) << 1
	return Vector4i(flat_idx.x, flat_idx.y, anchor, w)

func Update(delta, machine : DayshiftManager = null):
	if machine:
		# The way this works is if the normal of the object we hit
		# is up, we can know whether it's a floor or not
		if machine.hit_normal:
			projected_cell = Vector2i(
				floori(float(machine.hit_pos.x) / machine.pizzeria.TILE_SIZE),
				floori(float(machine.hit_pos.z) / machine.pizzeria.TILE_SIZE))
			if machine.collider:
				if machine.collider.get_parent().is_in_group(&"objects"):
					return
			if machine.hit_normal.y < 0.9:
				# if it's not, it's not a floor, defaulting to horizontal
				is_floor = false
				orientation = false
				match machine.hit_normal:
					Vector3(0,0,-1):
						projected_cell += Vector2i(0, 1)
					Vector3(1,0,0):
						orientation = true
					Vector3(-1,0,0):
						orientation = true
						projected_cell += Vector2i(1, 0)
			else:
				projected_cell = machine.current_cell
				is_floor = true
		else:
			projected_cell = machine.current_cell
			is_floor = true
	# if it's in the air, invalid
	
	if !machine.pizzeria.floors[machine.current_floor_idx].walls.has(Vector3i(projected_cell.x, projected_cell.y, orientation)):
		is_invalid = true
	else:
		is_invalid = false
	
	if is_floor:
		is_invalid = true
	
		#debug_point.global_position = gizmo_obj.global_position
	
	# After a value is decided, set the gizmo level
	
	if is_invalid:
		machine.gizmo_level = machine.GIZMO_LEVELS.NEGATIVE
	else:
		machine.gizmo_level = machine.GIZMO_LEVELS.POSITIVE

func InputUpdate(event, machine : DayshiftManager):
	# if we're aiming at the ground
	if !is_floor:
		if orientation:
			# rotate accordingly
			gizmo_obj.rotation_degrees.y = scene.custom_rotation_degrees.y + 90
			
			# same position as vertical walls, object is placed at the center of the
			gizmo_obj.global_position = Vector3(
				projected_cell.x * machine.pizzeria.TILE_SIZE, 
				machine.current_floor_idx * machine.pizzeria.WALL_HEIGHT + machine.pizzeria.WALL_HEIGHT/2, 
				machine.pizzeria.TILE_SIZE * projected_cell.y + machine.pizzeria.TILE_SIZE/2
				)
			
		else:
			gizmo_obj.rotation_degrees.y = scene.custom_rotation_degrees.y
			
			gizmo_obj.global_position = Vector3(
			machine.pizzeria.TILE_SIZE * projected_cell.x + machine.pizzeria.TILE_SIZE/2,
			machine.current_floor_idx * machine.pizzeria.WALL_HEIGHT+machine.pizzeria.WALL_HEIGHT/2,
			projected_cell.y * machine.pizzeria.TILE_SIZE
			)
	else:
		gizmo_obj.global_position = Vector3(
			machine.hit_pos.x,
			machine.current_floor_idx * machine.pizzeria.WALL_HEIGHT,
			machine.hit_pos.z
			)
	
	
	if Input.is_action_just_pressed("lclick"):
		if get_viewport().gui_get_hovered_control():
			return
		
		#TODO: add ERROR sfx
		if is_invalid:
			return
		var old_wall = machine.pizzeria.floors[machine.current_floor_idx].walls[Vector3i(projected_cell.x, projected_cell.y, orientation)].clone()
		old_wall.base_set_type(Devicedex.list_all.devices[machine.current_item].allowed_type)
		if Devicedex.list_all.devices[machine.current_item].allowed_flag == DeviceIndexDataEntry.WALL_FLAGS.NEITHER:
			old_wall.base_set_flag(pizzeria_wall.WALL_FLAGS.HAS_DOOR, false)
			old_wall.base_set_flag(pizzeria_wall.WALL_FLAGS.HAS_GLASS, false)
		else:
			old_wall.base_set_flag(Devicedex.list_all.devices[machine.current_item].allowed_flag, true)
		old_wall.device_model_name = machine.current_item
		machine.place_wall_data(Vector3i(projected_cell.x, projected_cell.y, orientation), old_wall)
		if !Input.is_action_pressed(&"shift"):
			machine.state(machine.default_state)

func Enter(machine : DayshiftManager):
	machine.gizmo_level = machine.GIZMO_LEVELS.POSITIVE
	machine.gizmo_box.visible = false
	gizmo_obj = MeshInstance3D.new()
	if !machine.pizzeria.deviceman.devices.has(machine.current_item):
		await machine.pizzeria.deviceman.load_new(machine.current_item)
		scene = machine.pizzeria.deviceman.devices[machine.current_item].instantiate()
	else:
		scene = machine.pizzeria.deviceman.devices[machine.current_item].instantiate()
	if scene.use_point or scene.gizmo_mesh == null:
		gizmo_obj.mesh = SphereMesh.new()
	else:
		gizmo_obj.mesh = scene.gizmo_mesh
	
	
	gizmo_obj.scale = Vector3(scene.scale_factor, scene.scale_factor ,scene.scale_factor)
	gizmo_obj.rotation = Vector3(deg_to_rad(scene.custom_rotation_degrees.x), deg_to_rad(scene.custom_rotation_degrees.y), deg_to_rad(scene.custom_rotation_degrees.z))
	gizmo_obj.material_overlay = machine.gizmo_box.material
	gizmo_obj.material_overlay.albedo = machine.gizmo_positive_color
	
	
	add_child(gizmo_obj)
	
	#debug_point = CSGSphere3D.new()
	#machine.add_child(debug_point)



func Exit(machine : DayshiftManager):
	machine.gizmo_level = machine.GIZMO_LEVELS.NEUTRAL
	machine.gizmo_box.visible = true
	gizmo_obj.queue_free()
